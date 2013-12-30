---
layout: post
title: Adapter#getView(...)での非同期実行を管理する
category : Languages
tags : [Android]
alias : /android/2013/02/10/managed-executor/index.html
---

Androidで一覧画面の使うようなケースではAdapterを使うと思われるが、このgetViewが非常に曲者で参った。。

安易にAsyncTaskでさばくと、非同期部分の負荷次第でスレッドを使い果たしRejectExecutionExceptionが発生する。
なので、代わりにExecutorServiceを使ってみた。

---------------------
## newFixedThreadPoolが良さげ

結論から言うと、Executors.newFixedThreadPoolがこの状況では一番適してる気がする。
内部キューはLinkedBlockingQueueなので、呼び出し側がブロックされるケースは無いし、数値的な根拠はないが実機での操作感が一番良かった…(；´∀｀)

Executors.newCachecThreadPool()だと、内部キューにSynchronousQueueを使用してるので、受け取り側の取得が遅れると呼び出し側がブロックされる。
(一気にスクロールダウンしていくとGUIスレッドのプチフリが発生した)


が、Androidの挙動やライフサイクルを考慮すると、ExecutorService＋で以下のような機能がほしくなった。

* onPause時に現在実行中のタスクをすべてキャンセルすることできる

	ExecutorService#shutdown系はonDestoryで呼びたい。  
	（shutdown系は一回のみなのでonPauseから復活する可能性があるライフサイクルには適していない）

* 同じIDを処理するタスクが既に実行中の場合はキャンセルしてくれる

	getViewはスクロールするたびに大量に呼ばれるので、既に不要なスレッド資源は早めに停止して再利用したい。

---------------------
## ExecutorServiceライクな自作Wrapperクラス

なので、Executorを拡張して、ExecutorServiceライクな簡易ラッパーを作成してみた。

↓インタフェースはこんな感じ
{% highlight java %}
package com.ogaclejapan;

import java.util.concurrent.Executor;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.TimeUnit;

/**
 * 送信された Runnable タスクを実行するオブジェクトです。
 * <p>id毎にタスクを管理しているため、同一idのタスクがまだ動作中の場合は実行をキャンセルしてくれます。</p>
 */
public interface ManagedExecutor extends Executor {
  
	/**
	 * すべてのタスクが実行を完了していたか、タイムアウトが発生するか、現在のスレッドで割り込みが発生するか、そのいずれかが最初に発生するまでブロックします。
	 * @param timeout 待機する最長時間
	 * @param unit 引数の時間単位
	 * @return この executor が終了した場合は true、終了前にタイムアウトが経過した場合は false
	 * @throws InterruptedException 待機中に割り込みが発生した場合
	 */
	boolean await(long timeout, TimeUnit unit) throws InterruptedException;
	
	/**
	 * 指定した{@link Runnable}を非同期で実行します
	 * @param r 実行するタスク
	 * @param id タスクを識別するためのID
	 * @throws RejectedExecutionException タスクの実行をスケジュールできない場合
	 */
	void execute(Runnable r, int id);
	
	/**
	 * 実行中のアクティブなすべてのタスクを停止します。
	 * <p>このメソッドはActivity#onPauseで呼び出すことを想定しています</p>
	 */
	void cancel();
	
	/**
	 * すべてのタスクを停止し、リソースを解放します。
	 * <p>このメソッドはActivity#onDestoryで呼び出すことを想定しています</p>
	 */
	void dispose();

}
{% endhighlight %}


↓そして実装はこんな感じ
{% highlight java %}
package com.ogaclejapan;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import android.support.v4.util.SparseArrayCompat;


public class ManagedExecutors implements ManagedExecutor {
  
	/**
	 * 必要に応じ、新規スレッドを作成するスレッドプールを作成しますが、利用可能な場合には以前に構築されたスレッドを再利用します。
	 * @param corePoolSize
	 * @param maximumPoolSize
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static ManagedExecutors newCachedThreadPool(int corePoolSize, int maximumPoolSize) {
		return new ManagedExecutors(new ThreadPoolExecutor(corePoolSize, maximumPoolSize, 60L, TimeUnit.SECONDS, new SynchronousQueue()));		
	}
	
	/**
	 * 必要に応じ、新規スレッドを作成するスレッドプールを作成しますが、利用可能な場合には以前に構築されたスレッドを再利用します。
	 * @return
	 */
	public static  ManagedExecutors newCachedThreadPool() {
		return new ManagedExecutors(Executors.newCachedThreadPool());
	}
	
	/**
	 * 固定数のスレッドを再利用するスレッドプールを作成します。
	 * @param nThreads
	 * @return
	 */
	public static ManagedExecutors newFixedThreadPool(int nThreads) {
		return new ManagedExecutors(Executors.newFixedThreadPool(nThreads));
	}
	
	/**
	 * 単一のワーカースレッドを使用する executor を作成します。
	 * @return
	 */
	public static  ManagedExecutors newSingleThreadExecutor() {
		return new ManagedExecutors(Executors.newSingleThreadExecutor());
	}
	
	private final ExecutorService es;
	private final SparseArrayCompat<ManagedTask> managedMap = new SparseArrayCompat<ManagedTask>(); 
	private final AtomicInteger serialId = new AtomicInteger(Integer.MAX_VALUE);
	private final AtomicBoolean disposed = new AtomicBoolean(false);
	private final AtomicBoolean cancelling = new AtomicBoolean(false);
	
	private ManagedExecutors(ExecutorService es) {
		this.es = es;
	}
	
	@Override
	public void execute(Runnable r) throws IllegalStateException {
		assertDisposed();
		if (cancelling.get()) return;
		submit(r, serialId.getAndDecrement());
	}

	@Override
	public void execute(Runnable r, int id) throws IllegalStateException {
		assertDisposed();
		if (cancelling.get()) return;
		submit(r, id);
	}

	@Override
	public void cancel() {
		if (cancelling.compareAndSet(false, true)) {
			try {
				final int size = managedMap.size();
				for (int i = 0; i < size; i++) {
					final ManagedTask storedTask = managedMap.get(i);
					if (storedTask != null && !storedTask.future.isDone()) {
						storedTask.future.cancel(true);
					}										
				}
			} finally {
				cancelling.set(false);
			}
		}
	}

	@Override
	public void dispose() {
		if (disposed.compareAndSet(false, true)) {
			es.shutdownNow();
			managedMap.clear();
		}
	}
	
	@Override
	public boolean await(long timeout, TimeUnit unit) throws InterruptedException {
		if (disposed.compareAndSet(false, true)) {
			if(!es.isShutdown()) es.shutdown(); 
		}
		return es.awaitTermination(timeout, unit);
	}

	private void submit(Runnable r, int id) {
		final ManagedTask storedTask = managedMap.get(id);
		if (storedTask != null && !storedTask.future.isDone()) {
			storedTask.future.cancel(true);
		}
		managedMap.put(id, new ManagedTask(es.submit(r)));		
	}
	
	private void assertDisposed() throws IllegalStateException {
		if (disposed.get()) throw new IllegalStateException("already disposed.");
	}
	
	@SuppressWarnings("rawtypes")
	private static class ManagedTask {		
		final Future future;
		private ManagedTask(Future future) {
			this.future = future;
		}
	}
	
}
{% endhighlight %}

これで少しでも資源を有効に活用できたら万々歳(　ﾟ∀ﾟ)o彡°ヌルサク！ヌルサク




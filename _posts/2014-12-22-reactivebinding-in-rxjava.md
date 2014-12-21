---
layout: post
title: RxJavaでリアクティブなデータバインディング
category : Languages
tags : [Android, Java]
---

この記事は [CyberAgent エンジニア Advent Calendar 2014][ca_advent_calendar] 22日目の投稿です。  
昨日は[@k66dango][ca_advent_prev_user] さんの「[Odd Sketchesを使ったJaccard係数の推定][ca_advent_prev_blog]」でした。  
22日目は今年の6月にサーバサイドJavaエンジニアからAndroiderへ暗黙な型変換した@ogaclejapanが担当します。  

会社では[9日目の記事](http://blog.horimisli.me/2014/12/09/objc-to-swift/)を担当した
若手の有望株である[@horimislime](https://twitter.com/horimislime)さんと同じ部署で、  
`POAA(Plain Old Android Application)`の開発を担当しています( ´∀｀)人(´∀｀ )


## はじめに
----

弊社では、エンジニア各人が興味を持つ分野について研究レポートを発表する制度として、
「[テックレポート](https://www.cyberagent.co.jp/recruit/techreport/)」というものがあります。  
Androiderへ型変換した直後にテックレポートを発表する機会があったので、
流行りの__リアクティブプログラミング__*1などを取り入れたAndroidアプリを作ってみました。

*1: [2015年に備えて知っておきたいリアクティブアーキテクチャの潮流 - hirokidaichi](http://qiita.com/hirokidaichi/items/9c1d862099c2e12f5b0f)


当初はすぐアプリを公開する予定でしたが、、、  
コードやMaterialデザインのリファクタを繰り返してたら時は過ぎ、今に至る今日この頃です。。

…ということで「__今日というよき日__」にリリースしましたーー！！　(　；∀；) ﾅﾝﾃｲｲﾋﾀﾞﾅｰ

<a href="https://play.google.com/store/apps/details?id=com.ogaclejapan.qiitanium">
<img alt="Android app on Google Play"
src="https://developer.android.com/images/brand/ja_app_rgb_wo_60.png" />
</a>

*このアプリは`Android 5.x(Lollipop)`のみ対応ですのでご注意ください*

<a href="https://github.com/ogaclejapan/Qiitanium">
{% image https://raw.githubusercontent.com/ogaclejapan/Qiitanium/master/art/qiitanium_logo.png %}
</a>

Githubでコードも公開してますので、ぜひ興味のある方は見てください。

[https://github.com/ogaclejapan/Qiitanium](https://github.com/ogaclejapan/Qiitanium)


はい、前置きが若干長くなってしまいました。。  

公開したアプリの中で[RxJava](https://github.com/ReactiveX/RxJava)をベースにしたデータバインディングを自作してみましたので、
これをテーマに書きたいと思います。


※RxJavaについてはある程度知識がある前提で書いてますので、
初めて聞いた人は先にこのあたりの記事を読むとわかりやすいかもしれません。

* [RxJavaについて調べた試した - みんからきりまで](http://kirimin.hatenablog.com/entry/20141012/1413126770)


## RxBinding
----

RxJavaは実行スレッドの制御や非同期処理やデータ加工、結合などにとても優れている強力なライブラリです。  
APIへ非同期リクエストして結果を内部データ形式に変換して返すようなバックエンド部分から導入してみるのがベストだと思います。  
そして実際に使っていくと、すごい便利なので`Observable<T>`でどんどんデータを返却したくなってきます。

しかし、Androidアプリ全体に適用するにはいくつか注意が必要です

* Android固有のActivity/Fragmentライフサイクル
* UIスレッド以外でのGUI操作


### Android固有のActivity/Fragmentライフサイクル問題

Androidアプリでネットワーク通信を非同期処理して結果をUIへ反映するコールバック処理を書く場合、  
このようなコードが最初に書いてあります。


```java

class HogeActivity extends Activity {

	void requestOnNetwork() {

		AsyncHttp.get("http://ogaclejapan.com/api/hoge", new OnCompletionListener() {

			@Override
			public void onSuccess(Hoge hoge) {
				if (isFinishing()) {
					return;
				}

				/* ここからUI操作処理 */
			}

			@Override
			public void onFailure(Throwable t) {
				if (isFinishing()) {
					return;
				}

				/* ここからUI操作処理 */
			}

		});
	}
}

```

`isFinishing()`の定義が無い状態でリクエスト中にBackキーなどで他画面へ遷移した後にリクエストが返却されると、  
予期せぬエラーでアプリが落ちる可能性があります。


### UIスレッド以外でのGUI操作問題

Androidに限らず、大抵のGUIアプリケーションではUIスレッド以外からのGUI操作はエラーとなります。  
RxJavaは実行スレッドを柔軟に制御できるため大変便利ですが、反面UIスレッドの指定が漏れると実行時エラーになります。

例外メッセージ: _Only the original thread that created a view hierarchy can touch its views_

```java
class HogeActivity extends Activity {

	private TextView mTextView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		mTextView = (TextView) findViewById(R.id.text);

		Observable.create(new Observable.OnSubscribe<String>() {
			@Override
			public void call(Subscriber<? super String> subscriber) {
				SystemClock.sleep(1000);
				subscriber.onNext("hoge");
				subscriber.onCompleted();
			}
		})
		.subscribeOn(Schedulers.io()) //.observeOn(xx)の定義漏れ！！
		.subscribe(setTextAction());

	}

	Action1<String> setTextAction() {
		return new Action1<String>() {
			@Override
			public void call(String text) {
				mTextView.setText(text);
			}
		};
	}

}

```

このようにちょっとした定義漏れで例外によりアプリが落ちてしまいます。  
実はRxJavaにはAndroidのUIスレッドを指定できるSchdulerクラスがありません^^;  

### そこでRxBinding！！

RxJavaの`rx.Observable<T>`をUI側でより使いやすく、安全にデータバインディングできるようなライブラリを作ってみました。  
あくまで補完するラッパー的な目的で作っているので非常にコンパクトなライブラリです^^;

__RxBinding__:  [https://github.com/ogaclejapan/RxBinding](https://github.com/ogaclejapan/RxBinding)


{% image https://raw.githubusercontent.com/ogaclejapan/RxBinding/master/art/architecture.png %}

もともとは.Netの[ReactiveUI](https://github.com/reactiveui/ReactiveUI)ライクなMVVMバインディングをRxJavaでも作れないかな〜？  
という感じで作り始めたので、`Tuple`とか`Unit`というClass名は.Netで使われている名前が由来になってます。

### 主なClass

#### `Rx<T>`

[Rx\<T>][rx.java]はデータバインディングの対象となるオブジェクトをデータバインディングするためのInterfaceです。  
このInterface実装したClassをいくつか用意してあります。

* [RxObject\<T>][rxobject.java]
* [RxWeakRef\<T>][rxweakref.java]
* [RxActivity\<T extends Activity>][rxactivity.java]
* [RxFragment\<T extends Fragment>][rxfragment.java]
* [RxSupportFragment\<T extends v4.Fragment>][rxsupportfragment.java]
* [RxView\<T extends View>][rxview.java]


各実装は対象オブジェクトのライフサイクルに応じてデータバインディングを制御したり、  
データ変更を反映する実行スレッドを内部で制御してます。  

```java

public class RxActivity<T extends Activity> extends RxWeakRef<T> {

    protected RxActivity(final T activity) {
        super(activity);
    }

    public static <T extends Activity> RxActivity<T> of(T activity) {
        return new RxActivity<T>(activity);
    }

    @Override
    protected boolean isBindable(final T activity) {
        return !activity.isFinishing();
    }

    @Override
    protected final Scheduler observeOn() {
        return MAIN_THREAD_SCHEDULER;
    }

```

先ほど書いた注意が必要な点はこのクラスを使うことで、  
各ライフサイクルに応じて強制的に制御されるので開発者の定義漏れによるエラーなどは解消されます。

```java

/* Rxの使い方 */

//どのクラスも`RxXX.of(T)`staticメソッドで既存のオブジェクトから変換できます。
Rx<HogeActivity> mThisActivity = RxActivity.of(this);
Rx<HogeFragment> mThisFragment = RxFragment.of(fragment);
Rx<HogeView> mHogeView = RxView.of(view);

//RxViewのみButterKnifeみたいに`RxView.findById(..)`で直接View/Activityから取得し変換することもできます。
Rx<TextView> mTextView = RxView.findById(activity, R.id.text);
Rx<ImageView> mImageView = RxView.findById(view, R.id.image);

//上記に図にも書いてある通り、後述するRxPropery<E>やRxEvent<E>, Observable<E>からバインディングできます
Rx<TextView> mTextView = RxView.findById(activity, R.id.text);
Subscription s = mTextView.bind(Observable.from("hoge"), RxActions.setText());

RxProperty<String> mText = RxProperty.of("hoge");
Subscription s = mTextView.bind(mText, RxActions.setText());

RxEvent<String> mOnTextChanged = RxEvent.create();
Subscription s = mTextView.bind(mOnTextChanged, RxActions.setText());
mOnTextChanged.post("hoge");

```


#### `RxProperty<E>`

[RxProperty\<E>][rxproperty.java]はRxjavaの[BehaviorSubject][rxjava_ref1]を内部に利用しています。  
BehaviorSubjectは初期値をもつことができ、最後に更新された値を保持し続ける無限ストリームです。

```java

/* RxPropertyの使い方 */

//RxProperty\<E>は初期値を制御できます
RxProperty<String> mHoge = RxProperty.of("hoge");
RxProperty<String> mHoge = RxProperty.create(); //初期値なし

//RxProperty\<E>はpull型の`E get()`とpush型の`Observable<E> asObservable()`メソッドを公開しています
String hoge = mHoge.get();
Observable<String> hoge = mHoge.asObservable();

//`set(E)`メソッドで値の更新します
mHoge.set("age") //mHoge.get() => "age"

//値を更新できない参照用のRxReadOnlyProperty<E>をベースClassにもってます
RxReadOnlyProperty<E> mNotWritableHoge = mHoge;

//RxPropertyは他のRxPropertyや`Observable<E>`からデータを連結することもできます
RxProperty<String> mAge = RxProperty.of("age");
Subscription s = mHoge.bind(mAge); //mHoge.get() => "age"
RxProperty<Date> mNow = RxProperty.of(new Date());
Subscription s = mHoge.bind(mNow, RxUtils.formatDate("yyyy-MM-dd")); //mHoge.get() => "2014-12-22"

```

#### `RxEvent<E>`

[RxEvent\<E>][rxevent.java]はRxJavaの[PublishSubject][rxjava_ref2]を内部に利用しています。  
PublishSubjectは値を一切保持せず、AndroidのUIイベント同じく一度限りの値をpostする無限ストリームです。

```java

/* RxEventの使い方 */

//RxPropertyと違い、生成メソッドは１つしかありません
RxEvent<String> mOnTextChanged = RxEvent.create();

//post(E)メソッドで値を通知します
mOnTextChanged.post("hoge");

//値を保持していないのでpush型の`E asObservable()`メソッドしかありません
Observable<String> mHogeObservable = mOnTextChanged.asObservable();

//RxPropertyと同様に他のObservableなどからデータを連結通知させることができます
RxEvent<Date> mNow = RxEvent.create();
Subscription s = mOnTextChanged.bind(mNow, RxUtils.formatDate("yyyy-MM-dd"));
mNow.post(new Date()); //=> mOnTextChanged.post("yyyy-MM-dd")

```

#### `RxList<E>`

[RxList\<E>][rxlist.java]はJavaでおなじみの`List<E>`を実装したClassです  

```java

/* RxListの使い方 */

//RxListは生成メソッドが2種類あります
RxList<String> mList = RxList.create(); //=>デフォルトはArrayList型になります
RxList<String> mList = RxList.of(list); //=>指定したList型になります

//他のList型とデータ連動できます
RxList<String> mMasterList = RxList.create();
Subscription s = mList.bind(mMasterList);

```

#### `RxListAdapter<E>`

[RxListAdapter\<E>][rxlistadapter.java]はListView,GridViewに使うListAdapterを実装したClassです

```java

/* RxListAdapterの使い方 */

//RxListAdapterはabstractなので継承して使います
class RxStringListAdapter extends RxListAdapter {...};
RxStringListAdapter<String> mListAdapter = RxStringListAdapter.create();

//List型とデータ連動できます
RxList<String> mMasterList = RxList.create();
Subscription s = mStringListAdapter.bind(mMasterList);

mMasterList.add("hoge");
mMasterList.add("age");
mMasterList.add("foo");
//MasterList.toString() => ["hoge", "age", "foo"]
//mListAdapter.list => ["hoge", "age", "foo"]

```

### うーん、、実際にどう使うかイメージ沸きませんな。。。

当初はDemoアプリをライブラリに同封する予定でしたが、全く間に合う気がしませんでした(´・ω・｀)ｼｮﾎﾞｰﾝ　　

公開した「[Qiitanium][qiitanium_github]」には過剰なほどRxBindingを使ってます。  

[presentation][qiitanium_github_ui]パッケージあたりを見てもらえると、  
モデルが更新されて表示面のビューも更新されるようなデータバインディングの仕組みを理解できると思います。


### …えっ、それRxAndroidでも解決できない？

はい、RxAndroidでもAndroidアプリ全体をリアクティブに処理するときの注意点は解決できます。  

__RxAndroid__: [https://github.com/ReactiveX/RxAndroid](https://github.com/ReactiveX/RxAndroid)

実行スレッドにUIスレッドを指定できる`AndroidSchedulers#mainThread()`に含まれています。  
(RxBindingもUIスレッド実行用のSchdulerはこのコードを使ってます)

ライフサイクルまわりを制御するメソッドは、6月頃にはなかったような記憶ですが、  
非常に開発が活発でいつのまにかも用意されてました。


あとRxAndroidはUIまわりのイベントをObservable化する機能をもってたりするので、  
RxBindingと組み合わせて使うとMVVMライクな双方向データバインディングも作れるかもしれません。


## まとめ
----

ザ・Bootstrapのサイトでブログが大変読みづらくてすみませんｍ（＿＿）ｍ  
次回参加する機会があればそのときは格好良くしておきます。

Material…　…　…Bootstrapとかに( ；∀；)

[CyberAgent エンジニア Advent Calendar 2014][ca_advent_calendar]
の23日目は[@brfrn169](https://twitter.com/brfrn169)さんが担当します。

それではAndroiderにとって来年も良い年でありますようにー☆


[ca_advent_calendar]: http://www.adventar.org/calendars/358
[ca_advent_prev_user]: https://twitter.com/k66dango
[ca_advent_prev_blog]: https://gist.github.com/k66dango/0bf77c84021d5a684e3d
[qiitanium_github]: https://github.com/ogaclejapan/Qiitanium
[qiitanium_github_ui]: https://github.com/ogaclejapan/Qiitanium/tree/master/qiitanium/src/main/java/com/ogaclejapan/qiitanium/presentation

[rx.java]: https://raw.githubusercontent.com/ogaclejapan/RxBinding/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/Rx.java
[rxobject.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxObject.java
[rxweakref.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxWeakRef.java
[rxactivity.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxActivity.java
[rxfragment.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxFragment.java
[rxsupportfragment.java]:
https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxSupportFragment.java
[rxview.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxView.java
[rxproperty.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxProperty.java
[rxevent.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxEvent.java
[rxlist.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxList.java
[rxlistadapter.java]: https://github.com/ogaclejapan/RxBinding/raw/master/rxbinding/src/main/java/com/ogaclejapan/rx/binding/RxListAdapter.java

[rxjava_ref1]: http://reactivex.io/RxJava/javadoc/rx/subjects/BehaviorSubject.html
[rxjava_ref2]: http://reactivex.io/RxJava/javadoc/rx/subjects/PublishSubject.html

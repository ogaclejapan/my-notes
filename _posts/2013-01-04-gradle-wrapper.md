---
layout: post
title: Gradle環境要らずのGradleチームビルド
category : Tools
tags : [Gradle]
alias : /groovy/2013/01/04/gradle-wrapper/index.html
---

Androidビルド自動化への道のりで`Gradle Wrapper`が便利過ぎたので、メモしておく。

もっと詳しい情報は[Gradleユーザマニュアル](http://gradle.org/docs/current/userguide/gradle_wrapper.html)を参照のこと


利点はただ１つ、

* 一度Wrapperファイルを生成してしまえば、各端末にGralde環境が無くてもGradleビルドが使える。

	(正確にはネットに繋がる環境とjava実行環境は必要ですが。。)

antにもmavenにも無い、チームビルドにもってこいなGradle…素晴らしい(・∀・)ﾆﾔﾆﾔ

----------------
## Gradle Wrapperファイルを生成する

Wrapperファイルを生成するには`build.gradle`ファイルに以下のタスクを追加する。

{% highlight groovy %} 
task wrapper(type: Wrapper) {
	gradleVersion = '1.2'
}
{% endhighlight %}

次にコマンドラインから定義した`wrapper`タスクをGradleで実行する。

{% highlight bash %}
gradle wrapper
{% endhighlight %}

実行後、以下のGradle Wrapperファイルが生成されていれば準備おｋ。
{% highlight bash %}
.
|-- build.gradle
|-- ...
|-- gradle
|   `-- wrapper
|       |-- gradle-wrapper.jar
|       `-- gradle-wrapper.properties
|-- gradlew
|-- gradlew.bat
{% endhighlight %}

このWrapperファイル毎VCSにコミットしておけば、チームビルドが完成( ´∀｀)人(´∀｀ )

----------------
## Gradle Wrapperでビルド

Gradle環境要らずGradleタスクをビルドするには`gradle`の代わりに`gradlew`を使用する。
色々ダウンロードが始まり、`.gradle`というフォルダが自動生成されるはず。

{% highlight bash %}
gradlew (tasks...)
{% endhighlight %}

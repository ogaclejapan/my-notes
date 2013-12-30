---
layout: post
title: Gradleの基本的なスクリプトコード集
category : Tools
tags : [Gradle]
alias : /groovy/2013/01/05/gradle-guide/index.html
---

Gradleでよく使う基本的なスクリプトコードをメモしておく。

もっと詳しい内容は[Gradle日本語ユーザガイド](http://gradle.monochromeroad.com/docs/index.html)を参照のこと

----------------
## 変数の定義

`def (変数名)＝(値)`で宣言する
{% highlight groovy %} 
def foo = "bar"

println foo
//bar
{% endhighlight %}

文字列中で変数値を使用する場合は`$`を先頭につける
{% highlight groovy %} 
def foo = "bar"

println "foo is $foo"
//foo is bar
{% endhighlight %}

----------------
## タスクの定義

`task (タスク名) << {(タスクの処理...)}`で宣言する
{% highlight groovy %}
task foo << {
	println "bar"
}
{% endhighlight %}

他タスクへの依存を宣言するには`dependsOn`パラメータを加える
{% highlight groovy %}
task foo(dependsOn: bar) << {
	println "foo"
}
task bar << {
	println "bar"
}
{% endhighlight %}

既存タスクをトリガーに処理を追加するには`(既存タスク名) << {(タスクの処理...)}`で宣言する
{% highlight groovy %}
foo << {
	println "foo called."
}
{% endhighlight %}

__※この宣言方法だと既存タスクの処理終了後のタイミングで呼び出されることに注意すること__

----------------
## 拡張プロパティの定義

`project.ext {...}`で宣言する
{% highlight groovy %}
project.ext {
	foo = "bar"
	hoge = "baz"
}

println project.foo
//bar
println "hoge is ${project.hoge}"
//hoge is baz
{% endhighlight %}

----------------
## プロパティファイルの読み込み

普通にgroovyコードを書くしかないと思われる
{% highlight groovy %}
def props = new Properties()
file("foo.properties").withInputStream {
	stream -> props.load(stream)
}

println props['bar']
//baz
{% endhighlight %}

{% highlight properties %}
#foo.properties
bar=baz
{% endhighlight %}



---
layout: post
title: IntelliJ IDEAに関するメモ書き
category : Tools
tags : [IntelliJ]
---

IntelliJの最新バージョンがAndroidに対応したのでインストールしてみた。  
困ったとこなどをちょこっとメモ書きを残しておく。

↓参考にしたサイト

* [IntelliJ IDEA Advent Calendar 2012](http://masanobuimai.hatenablog.jp/entry/20121225/1356362339)


-------------------
## Project設定の表示／変更

プロジェクトルートを選択した状態で、

{% highlight text %}
ツールバー > [File] > [Project Structure...]
{% endhighlight %}

を辿る。

-------------------
## Dark Themeへの変更

IntelliJのサイトにも載っているDarkテーマへに切り替えるには、

{% highlight text %}
ツールバー > [IntelliJ IDEA] > [Preferences..] > [Appearance]
{% endhighlight %}

を辿り、Themeを「Deacula」に変更する。

-------------------
## Propertiesファイルの日本語表示

デフォルトだとマルチバイト系の日本語が表示できない。

日本語を表示できるように切り替えるには、

{% highlight text %}
ツールバー > [File] > [Reload 'ShiftJIS' file in another encoding] > [Configure Default Encoding...]
{% endhighlight %}

右端のボタン上部にある「Transparent native-to-ascii conversion」チェックボックスにチェックをつける。

-------------------
## 行末カーソルの制御

どういう思想か不明だが、intelljはデフォルトだと改行以降にもカーソルが移動できる。

一般的なエディタと同様に改行以降のカーソルが移動できないようにするには、

{% highlight text %}
ツールバー > [IntelliJ IDEA] > [Preferences..] > [Editor]
{% endhighlight %}

を辿り、Vitual Space欄「Allow placement of caret after end of line」チェックボックスのチェックを外す。

-------------------
## Macの選択ダイアログを変更

デフォルトだと`/usr`とか選択できない。

表示するためには、

{% highlight text %}
ツールバー > [Help] > [Find Action...]
{% endhighlight %}

「include non-menu actions」チェックボックスにチェックをつける。

アクション検索ボックスに「registy」と入力する。

以下の項目を変更する。

* `ide.mac.filechooser.native` ⇒ チェック外す
* `ide.mac.filechooser.showhidden.files` ⇒ チェックをつける

-------------------
## 便利なショートカットキー

* Quick Definition `[Shift]+[Command]+I`

	カーソル中のクラスソースをポップアップ表示してくれる

* Quick Documentation `[Ctrl]+J`

	EclipseだとマウスオーバーとかでJavadocが表示されるやつ

* Find Action `[Shift]+[Command]+A`

	コードアシストみたいにアクションを検索して実行できる

* File Structure `[Command]+F12`

	Eclipseのアウトラインみたいなもの

* Basic code completion `[Ctrl]+[Space]`

	Eclipseでもお馴染みのコードアシスト

* Live Template `[Ctrl]+J`

	コードスニペット？？Eclipseだと`syso`で`System.out.pritnln`に展開してくれるやつ  
	ちなみにIntelljだと`sout`らしい


---
layout: post
title: Homebrewでバージョンを指定してインストール
category : Tools
tags : [Homebrew]
---

androidのgradleビルドを調べてたら、
バージョン指定したインストール方法が必要になったので忘れぬうちにメモ。  
(なぜか`brew help`コマンドには書いてない。。)

--------
## インストールてきるバージョンを確認する

`brew versions (FORMULA)`でインストール可能なバージョン一覧を表示できる

{% highlight bash %}
brew versions gradle
1.3      git checkout 1715215 /usr/local/Library/Formula/gradle.rb
1.2      git checkout 9b7d294 /usr/local/Library/Formula/gradle.rb
1.1      git checkout 7941972 /usr/local/Library/Formula/gradle.rb
1.0      git checkout dff67fb /usr/local/Library/Formula/gradle.rb
1.0-rc-3 git checkout 5f9e348 /usr/local/Library/Formula/gradle.rb
1.0-rc-2 git checkout f72e33f /usr/local/Library/Formula/gradle.rb
1.0-rc-1 git checkout e2438cf /usr/local/Library/Formula/gradle.rb
...
{% endhighlight %}

※同じ表示にならない場合は`brew update`で最新版へ更新してみたほうがよい

--------
## 特定バージョンをインストールする

一覧からインストールしたいバージョンが見つかったら、バージョンに対応する形で右側に表示された`git checkout .../gradle.rb`までの1行をコピぺしてターミナルから実行する。

{% highlight bash %}
#バージョン1.2をいれたい場合...
git checkout 9b7d294 /usr/local/Library/Formula/gradle.rb
{% endhighlight %}

 これでbrew内のgradleインストールバージョンが`1.2`になる（はず）。  
 （この時点では確認してないけど`brew info gradle`でバージョンが`1.2`だと思う）

 あとは通常の`brew install`コマンドでインストールするのみ。

{% highlight bash %}
brew install gradle
==> Downloading http://services.gradle.org/distributions/gradle-1.2-bin.zip
{% endhighlight %}

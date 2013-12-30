---
layout: post
title: ImageMagickで既存画像からテスト画像を大量生成する
category : Tools
tags : [ImageMagick]
---

Android開発で画像一覧の動作確認をする際に大量のテスト画像がほしくなってしまった(´・ω・｀)  
（実際の画像だと重複とか、順番とか分かりずらかったり、大量に用意するのが意外とメンドかったり…）

なので、ImageMagickというツールのconvertコマンドで一意なテスト画像を大量に生成する方法をメモしておく。  


今回試した環境

* Max OS X
* [ImageMagick 12.2.0](http://www.imagemagick.org/download/binaries/ImageMagick-x86_64-apple-darwin12.2.0.tar.gz)

ImageMagickはWindows用バイナリも公開されているので、おそらく使えるはず。

----------------
## ImageMagickのインストール

homebrewでもパッケージは用意されているが、試してみたら実行時エラーが発生した。  
なので、普通にMac用のtarをDLしてインストールした。

↓参考サイト  
<http://www.imagemagick.org/script/binary-releases.php#macosx>

----------------
## 既存画像から連番のテスト画像を生成

↓ここのサイトが大変参考になった。  
[ImageMagickでテスト用画像を大量に作成する／GENDOSU@NET](http://gendosu.jp/archives/1108)

参考にさせていただいたサイトのやり方だと生成される容量がどうしても小さくなってしまった。  
なので実際に撮った画像にテキストで連番を加えてみた。

(既存画像の例)

* ファイル名: BASE.JPG
* 大きさ: 4000 x 3000

例えば、100枚の画像を生成する場合は
{% highlight bash %}
for i in $(seq -w 1 100); do convert -font "/Library/Fonts/Arial.ttf" -pointsize 1500 -draw "text 100,2250 T${i}" BASE.JPG test${i}.JPG; done

#100,2250あたりは既存画像やpointsizeに依存するので、0,(写真の縦サイズ)にすると左下に必ず文字が入るようになる
{% endhighlight %}

をターミナルで実行すると、ファイル名が`test1.JPG~test100.JPG`で各画像に`T1~T100`の文字が埋め込まれるはず。





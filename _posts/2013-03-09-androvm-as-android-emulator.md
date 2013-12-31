---
layout: post
title: AndroidエミュレータはAndroVM一択
category : Tools
tags : [Android, AndroVM]
alias : /android/2013/03/09/androvm-as-android-emulator/index.html
---


「お前のエミュレータはもう死んでいる…」

去年発見してから開発現場で使い続けてるAndroidエミュレータ  
「[AndroVM(旧Buildroid)](http://androvm.org/blog/download/)」
が爆速かつ使い易すぎて鼻血が止まらん。。


-----------------------
## AndroVMとは何奴！？

簡単にいうと、  
ORACLE社が無償で提供する仮想化ソフトウェア[VirtualBox](https://www.virtualbox.org/)上で動作させるAndroidのOSイメージみたいなもの。

VirtualBox自体はWindows,Linux,Macいずれもサポートしているので、
よほど古いPCでなければAndroVMは動くはず。

現在のところ、AndroVMでは３つのイメージファイルが配布されている。

* 擬似phoneイメージ(480x800)
* 擬似tabletイメージ(1024x600)
* phone機能を内蔵した擬似tabletイメージ(1024x600)

OVFという仮想化標準フォーマット(らしい)で配布しているので、
もしかしたら他の仮想化ソフトウェアでも利用可能かもしれないが知らん。

詳細はサイトの[ドキュメント](http://androvm.org/blog/androvm-documentation/)を読むべし。

-----------------------
## AndroVM導入

VirtualBoxを既に使っている人なら瞬殺レベル。

0. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)をインストール
1. [AndroVM](http://androvm.org/blog/download/)をダウンロード
	
	`gapps-houdini-flash`と付くほうがgoogleの基本アプリをバンドルしたイメージ。  
	最新の[gapps](http://goo.im/gapps)を自分で導入できる人以外はバンドルを選択するのがベター。  
	→ドキュメントによるとGoogleTTSはクラッシュするので取り除いたほうがよいとのこと。

2. VirtualBoxを起動し、`[ファイル]→[仮想アプライアンスのインポート]`からダウンロードしたAndroVM(ova)ファイルをインポート。

{% image https://www.googledrive.com/host/0B30bERhjS_icZGxLRlRoRUlmM1k %}
→アプライアンスの設定はデフォルトで問題なし  

これで起動準備おk。


### 〜開発者向けの設定〜

実機と同様にデバッグ接続するためにはadbデバイスとして認識させる必要があり、
ネットワーク設定のポートフォワーディングに`localhost:5555→10.0.3.15:5555`を追加することで実現できる。

インポートしたAndroVMのネットワーク設定を選択し、ポートフォワーディングボタンを押下。
{% image https://www.googledrive.com/host/0B30bERhjS_icTDVMU004bE9zMXM %}

TCPの5555番ポートをAndroVMの仮想IP:5555番ポートに流すようにする。
{% image https://www.googledrive.com/host/0B30bERhjS_icazFIOU9WMk45WjQ %}

これでvm起動後、adbのconnectコマンドで接続できるはず。

{% highlight bash %}
adb connect localhost
#* daemon not running. starting it now on port 5037 *
#* daemon started successfully *
#connected to localhost:5555

adb devices
#List of devices attached
#localhost:5555	device
{% endhighlight %}

参考にしたサイト:

* [android 開発でエミュレーターの代わりに x86版 + Virtualbox を使ってみる](http://poozxxx.hatenablog.com/entry/2012/07/25/013740)

-----------------------

## AndroVMのキーボード操作表

一部のキーはAndroVMplayerというフロントエンドアプリ経由で起動することで使用可能になる。  
ただ自分の環境ではBSキーがなぜか認識されず入力操作に難があるため今のところ使ってない。

（複数認識するキーがある場合はorで記載）

<table class="table">
	<tr>
		<th>AndroVM Device Key</th>
		<th>PC Keyboard Key</th>
	</tr>
	<tr>
		<td>Homeボタン</td>
		<td>[HOME] or [Fn + Left]</td>		
	</tr>
	<tr>
		<td>Menuボタン</td>
		<td>[F1] or [F10]</td>		
	</tr>	
	<tr>
		<td>Backボタン</td>
		<td>[ESC]</td>		
	</tr>	
	<tr>
		<td>履歴ボタン？？</td>
		<td>[F3]</td>		
	</tr>
	<tr>
		<td>電源ボタン</td>
		<td>[END] or [F4] or [Fn + Right]</td>		
	</tr>
	<tr>
		<td>音量UPボタン</td>
		<td>不明（AndroVM Playerのみ使用可？）</td>		
	</tr>
	<tr>
		<td>音量DOWNボタン</td>
		<td>不明（AndroVM Playerのみ使用可？）</td>		
	</tr>
	<tr>
		<td>カメラボタン</td>
		<td>不明（AndroVM Playerのみ使用可？）</td>		
	</tr>
	<tr>
		<td>画面向き変更</td>
		<td>たぶん不可能</td>		
	</tr>

</table>

-----------------------
## AndroVMおすすめアプリ

実際に使ってみて、便利だったアプリをいくつかあげておく。

* [Fake GPS location](https://play.google.com/store/apps/details?id=com.lexa.fakegps)

	擬似ロケーションを設定できるアプリ。
	GEO付きのアプリを開発するなら導入必須もの。

* [Hosts Editor](https://play.google.com/store/apps/details?id=com.treb.hosts)

	androidのhostsを編集できるアプリ。
	ローカルPC内でサーバサイド含むオールインワン環境まで作るときに重宝する。

* [BusyBox](https://play.google.com/store/apps/details?id=stericson.busybox)

	実機でもroot系端末では必須のアプリ。
	使えるshellコマンドが増えるのでadb shell多用なら迷わず導入するべき

* [Power Toggles](https://play.google.com/store/apps/details?id=com.painless.pc)

	ウィジェット系一押しアプリ。
	AndroVMは電源OFFまでのキー操作が意外とメンドクサイので、
	電源OFFとかウィジェットをHOMEに置いておくと、マジ便利。

* [日本語106/109キーボードレイアウト](https://play.google.com/store/apps/details?id=net.init0.android.keyboard109)

	AndroVMはデフォルト英語キーボードレイアウトになるので、
	日本語キーボードから使用している場合は入れた方が無難だろうと思われる。  
	変更方法は[こちら](http://hirara.seesaa.net/article/297608063.html)のサイトを参考にするとよい

* [Google Chrome to Phone](https://play.google.com/store/apps/details?id=com.google.android.apps.chrometophone)

	PCのchromeに表示しているURLを転送できる。
	web系のアプリ開発なら導入しておくと楽チン。

* [Google日本語入力](https://play.google.com/store/apps/details?id=com.google.android.inputmethod.japanese)

	デフォルトでも日本語入力できるが、入れた方が快適。

-----------------------
## まとめ

SDK標準エミュレータと比べて、AndroVMではOSの選択肢や画面回転などはできないが、
それ以外の部分は同じようなことが実現できるし、なにより快適に動作する。

また、VirtualBox上で動作するため、予め環境設定したイメージを配布してチームで共有することもできるし、
スナップショット機能で状態を復元できる点はSDK標準エミュレータよりも使い勝手が良いと感じた。

AndroVMはアプリ開発者や関係者がローカル環境で動作確認する分には十分使えるレベルじゃないかなと思う。


---
layout: post
title: Androidの新ビルドツール「Android Gradle Plugin」
category : Tools
tags : [Android, Gradle]
alias : /android/2013/06/23/new-build-system-for-gradle/index.html
---

2013年5月、ついに…   
ｷﾀ━━━(ﾟ∀ﾟ)━( ﾟ∀)━( 　ﾟ)━(　　)━(　　)━(ﾟ 　)━(∀ﾟ )━(ﾟ∀ﾟ)━━━!!   
Google I/O 2013にてGradleビルドがAndroidの正式ビルドシステム採用されました！！！   

去年書いた「[GradleでAndroidを継続的インテグレーションするための雛形]({{ site.baseurl }}{% post_url 2012-12-25-build-template-for-gradle %})」の頃より、
かなりバージョンアップしてたり、ちゃんとユーザガイド「[Gradle Plugin User Guide](http://tools.android.com/tech-docs/new-build-system/user-guide)」が作成されてたりで、こりゃ〜もう最新版を学習するっきゃないの巻。

-----------------------
## Androidを動かす最低限のGradleビルド設定

Gradleプロジェクトでは通常プロジェクト直下にbuild.gradleというビルドファイルを作成する必要がある。

このままだと、ただのGradleプロジェクトでAndroidとしてのビルド機能は何一つ使えないので、
build.gradleにAndroidプラグインを利用するための内容を書き加え、最低限の機能を使えるようにする。

{% highlight groovy %}

// (1)
buildscript { 
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:0.4.2'
    }
}

// (2)
apply plugin: 'android'

// (3)
android { 
    compileSdkVersion 17
}

{% endhighlight %}

1. `buildscript { ... }`　にはビルドを実行する上で必要な情報を定義することができる。

	Androidプラグインを利用する場合はMavenリポジトリから取得可能であるため、リポジトリ情報と依存するプラグインのバージョン情報を定義すればよい。

2. Androidプラグインを利用する上でのおまじない。

3. `android { ... }`　にはAndroidビルドに関するパラメータ情報を定義することができる。  

	デフォルトでは、compileSdkVersionというプロパティのみあればよい。
	このプロパティは旧Androidプロジェクトでいうところのproject.propertiesに定義されていたtargetと同じ役割をもつ。
	compileSdkVersionプロパティはSDKのAPIレベルで定義してもいいし、従来通りの文字列で定義してもよい。  


あとは以下のいずれかの方法でSDKの場所を教えてやればおｋ。  
（複数人で開発することを考慮すると後者の方を推奨する）

* プロジェクト直下にlocal.propertiesを配備し、sdk.dirプロパティにSDKまでのパスを定義する
* ANDROID_HOME環境変数にSDKまでのパスを定義する

これでAndroidをビルドする準備は整っただろう。

ちなみに最新版(0.4.2)を動かすには以下の要件を満たす必要がらしいので注意すること。

* Gradle 1.6
* SDK with Build Tools 17.0.0 (released 5/16/2013) 

-----------------------
## Androidプロジェクト構成

Gradle版Androidプロジェクトの構成は、実アプリ用コードとテスト用コードの２つ分かれている。

* src/main/
* src/InstrumentTest/

各コードの中にmavenと同様にJava用フォルダのjava,resourcesに加わり、さらにAndroid用のフォルダー類が加わる。

（Java用）
* java/
* resources/

（Android用）
* AndroidManifest.xml　※テスト用コードには自動生成するため不要
* res/
* assets/
* aidl/
* rs/
* jni/

### 構成を変更する

`android { sourceSets { ... } }` にはプロジェクトの構成を定義することができる。
既存プロジェクトへの適用など、デフォルトのプロジェクト構成に合わせられないときは構成を変更すればよい。

{% highlight groovy %}

android {
    sourceSets {
        main {
            manifest.srcFile 'AndroidManifest.xml'
            java.srcDirs = ['src']
            resources.srcDirs = ['src']
            aild.srcDirs = ['src']
            renderscript.srcDirs = ['src']
            res.srcDirs = ['res']
            assets.srcDirs = ['assets']
        }

        instrumentTest.setRoot('tests')
    }
}

{% endhighlight %}

-----------------------
## Androidプラグインのタスク

javaおよびandroidプラグインでは共通のanchorタスク(※1)が４つある。

* assemble プロジェクトコードをビルドし、成果物を生成する 
* check すべての依存するチェックタスクを実行する
* build assembleとcheckの両方を一度で実行する
* clean プロジェクトビルドで生成した成果物をすべて削除する

_(※1)依存させた具象タスクをすべて実行できるフック的な役割の抽象タスク_


例えば、単純なjavaプラグインだとタスクの処理はこんな感じになる。

* assemble　jarを生成する
* check　testコードに対してJUnitを実行する


### ＜Buildタスク＞

androidプラグインではassembleタスクを環境毎に細分化したanchorタスクを用意している。

* assemble　細分化したすべてのタスクを実行する
* assembleDebug　debug環境用の成果物を生成する　（たとえばdebug.keystoreを使うとか）
* assembleRlease　release環境用の成果物を生成する
* assembleTest　test環境用の成果物を生成する


### ＜Verificationタスク＞

androidプラグインではcheckタスクに加えて、２つほど新たにanchorタスクを定義している。

* connectedCheck　実行環境に接続されているすべての端末またはエミュレータ上でcheckタスクを実行する
* deviceCheck　リモートデバイスに接続するAPIを利用してcheckタスクを実行する（CIサーバ上での利用を想定しているらしい）

_buildタスクではconnectedCheck,deviceCheckタスクは実行されないらしい_

いくつかのVerificationのanchorタスクにはandroidプラグインが独自の依存タスクを定義している。

checkタスク:

* lint（まだ実装されてないらしいが…）

connectedCheckタスク:

* connectedInstrumentTest
* connectedUiAutomatorTest （まだ実装されてないらしいが…）

deviceCheckタスク:

* connectedInstrumentTest	


### ＜Installタスク＞

androidプラグインには成果物として生成されたapkを端末に導入するinstall/uninstallタスクも存在する。  
このタスクは環境毎(debug, release, test)のビルドをサポートしている。

* install{Debug/Release/Test}
* uninstall{Debug/Release/Test}


### ＜Gradle標準タスク＞

Gradleでは利用可能なタスクをtasksコマンドでいつでも確認できる。

{% highlight bash %}

# コマンドで実行可能なタスクの一覧を表示する
gradle tasks

# 依存するタスクも含め、タスクの一覧を表示する
gradle tasks --all

{% endhighlight %}

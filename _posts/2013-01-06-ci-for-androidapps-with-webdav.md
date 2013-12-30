---
layout: post
title: Androidアプリ開発de継続的インテグレーション
category : Techniques
tags : [Android, Gradle]
alias : /android/2013/01/06/ci-for-androidapps-with-webdav/index.html
---

CentOS上にAndroid自動化ビルド環境と簡易apk配布用webdav環境を構築したので、一応メモしておく  
（JenkinsはジョブからGradleをKickするだけなので割愛し、ここでは単に手動でGradleをKickして実行する）


構築したときの各パッケージバージョンはこんな感じ↓

* CentOS : 5.8(x86_64)
* JDK : 1.6.38 ※1.7はAndroidが未サポート
* Android SDK : r21.0.1
* Gradle : 1.2 ※[GradleWrapper](/groovy/2013/01/04/gradle-wrapper/)を既に組み込んだプロジェクトのみをビルドする場合は不要
* Apache Httpd : 2.2.3

__※このメモはローカルLAN内など外部から閉じた環境を想定しているため、SSLなどのセキュリティを考慮した設定は無視していることに注意すること！__

---------------------------
## JDKのインストール

JDKはOracle社の[サイト](http://www.oracle.com/technetwork/java/javase/downloads/index.html)からDL
{% highlight bash %}
wget -O jdk-6u38-linux-x64-rpm.bin http://download.oracle.com/otn-pub/java/jdk/6u38-b05/jdk-6u38-linux-x64-rpm.bin
chmod a+x ./jdk-6u38-linux-x64-rpm.bin
./jdk-6u38-linux-x64-rpm.bin
{% endhighlight %}

__※wgetコマンドオプション`-O`を指定しないとよく分からんhtmlファイルが保存されるので注意！__

環境変数`JAVA_HOME`とbin配下にPATHを通す
{% highlight bash %}
#.bash_profile

export JAVA_HOME=/usr/java/default
export PATH=${PATH}:${JAVA_HOME}/bin
{% endhighlight %}

---------------------------
## AndroidSDKのインストール

SDKはAndroid Developersの[サイト](http://developer.android.com/intl/ja/sdk/index.html)からDL
{% highlight bash %}
wget http://dl.google.com/android/android-sdk_r21.0.1-linux.tgz
tar zxvf android-sdk_r21.0.1-linux.tgz
mv android-sdk-linux /usr/local/
{% endhighlight %}

環境変数`ANDROID_HOME`とtools,platform-tools配下にPATHを通す
{% highlight bash %}
#.bash_profile

export ANDROID_HOME=/usr/local/android-sdk-linux
export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
{% endhighlight %}

__※ANDROID_HOMEはGradleビルド時のSDKパスを解決するときに使用するので必ずこの名前で定義すること！__

SDKをアップデートして各バージョンのSDKをダウンロードする
{% highlight bash %}
android update sdk -u
# -uはコマンドラインのみでアップデートするためのオプションらしい(たぶん)
{% endhighlight %}

`${ANDROID_HOME}/platform`配下のパーミッションを書き込み可にしておく

{% highlight bash %}
cd $ANDROID_HOME
chmod a+w -R ./platforms
{% endhighlight %}

何を書き込んでいるか不明だが、Jenkinsからビルドする際に書き込みエラーとなったため  
(たしかGradleのAndroidタスク`compilexxxAidl`というところで発生したと思う)

---------------------------
## Gradleのインストール

Gradleの[サイト](http://www.gradle.org/downloads)からバージョン1.2をDL
{% highlight bash %}
wget http://services.gradle.org/distributions/gradle-1.2-bin.zip
unzip gradle-1.2-bin.zip
mv gradle-1.2 /usr/local/
ln -s /usr/local/gradle-1.2 /usr/local/gradle
{% endhighlight %}

環境変数`GRADLE_HOME`とbin配下にPATHを通す
{% highlight bash %}
#.bash_profile

export GRADLE_HOME=/usr/local/gradle
export PATH=${PATH}:${GRADLE_HOME}/bin
{% endhighlight %}

一応、実行できるか確認するべし
{% highlight bash %}
gradle --version

#Gradle build time: 2012年9月12日 10時46分02秒 UTC
#Groovy: 1.8.6
#Ant: Apache Ant(TM) version 1.8.4 compiled on May 22 2012
#Ivy: 2.2.0
#JVM: 1.6.0_38 (Sun Microsystems Inc. 20.13-b02)
#OS: Linux 2.6.18-308.el5 amd64
{% endhighlight %}

---------------------------
## Apache Httpdのインストール

今回はビルドしたapkの配布用にWebDAVを使ったので、yumからインストール  
{% highlight bash %}
yum install -y httpd
{% endhighlight %}

WebDAV用モジュールは標準で含まれているので、コメントアウトされている場合は解除する
{% highlight apache %}
#/etc/httpd/conf/httpd.conf

LoadModule dav_module modules/mod_dav.so
LoadModule dav_fs_module modules/mod_dav_fs.so
{% endhighlight %}

apache公開ディレクトリに配布用apksフォルダを作成する
{% highlight bash %}
mkdir /var/www/html/apks
chown -R apache. /var/www/html/apks
chmod 666 /var/www/html/apks
{% endhighlight %}


あとはWebDAV用のconfを定義する
{% highlight apache %}
#/etc/httpd/conf.d/webdav.conf

<IfModule mod_dav.c>
    DAVMinTimeout 600
    <Directory /var/www/html/apks>
        DAV On
        Options Indexes
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from all
    </Directory>
</IfModule>
{% endhighlight %}

httpd起動後、ブラウザから`http://(hostname)/apks/`へアクセスし、空のディレクトリが見えれば準備おｋ

---------------------------
## AndroidプロジェクトをGradleビルド

ここまで構築できたら、あとはビルドするだけ。

ここでは以前書いた
「[コマンドラインからAndroidプロジェクトを生成する](/android/2012/12/24/create-project-for-commandline/)」を参考に最小限のAndroidプロジェクトを作成し、ビルドを試してみる

プロジェクトを作成したら、次に
「[GradleでAndroidを継続的インテグレーションするための雛形](/android/2012/12/25/build-template-for-gradle/)」
を参考にbuild.gradleファイルをプロジェクト直下に生成する

最後に`assembleDebug`タスクでDEBUGビルドしてみる
{% highlight bash %}
gradle assembleDebug
{% endhighlight %}

__※64bit環境だと`/lib/libz.so.1: no version information available`というエラーメッセージ？？がコンソールに出力される模様__
__↑(1/7追記)　エラーメッセージを解決、記事の最後に追記しました。__

{% highlight bash %}
#gradle assemblDebug

:prepareDebugDependencies
:compileDebugAidl
:generateDebugBuildConfig
:crunchDebugRes
/usr/local/android-sdk-linux/platform-tools/aapt: /lib/libz.so.1: no version information available (required by /usr/local/android-sdk-linux/platform-tools/aapt)
:processDebugManifest
:processDebugRes
/usr/local/android-sdk-linux/platform-tools/aapt: /lib/libz.so.1: no version information available (required by /usr/local/android-sdk-linux/platform-tools/aapt)
:compileDebug
:dexDebug
:processDebugJavaRes UP-TO-DATE
:packageDebug
:zipalignDebug
:assembleDebug

BUILD SUCCESSFUL
{% endhighlight %}

色々調べてみるとzlibのソースをDLして32bit用にコンパイルすれば直るらしいが、
今のところ同様に試してみたが直らず。。[参考サイト](http://kamosan-android.blog.so-net.ne.jp/2011-05-05-1)

AndroidSDKダウンロードページのSYSTEM REQUIREMENTSにも以下のような記載があることから、
32bitで動作させる必要があるのは間違いない。

> 64-bit distributions must be capable of running 32-bit applications.

実際のところ、ビルドが最後まで成功すればこのメッセージが出力されてもapkは使えたが、
ディストリビューションの縛りが無ければ公式にテスト済みと書いてあるUbuntu32bit版がよさげと思われる

---------------------------
## WebDAV上にapkデプロイするGradleタスク追加

今回はapkビルドを継続的に行い、配布することを考慮した仕様のタスクを作成してみた。

* 開発最新版ビルドのapkには`SNAPSHOT`という文字列を加える
* 開発最新版ビルドはDEBUG用,STAGING用の2環境分のapkを個々のタスクで生成する
* リリース版ビルドのapkにはmanifestファイルのバージョン文字列`android:versionName`を加える
* リリース版ビルドはDEBUG用,STAGING用,RELEASE用の3環境分のapkを同時に生成する

追加したコードはこんな感じ↓

{% highlight groovy %}
//build.gradle

task deployDebug(dependsOn: assembleDebug) << {
        deploy(["debug"])
}

task deployStaging(dependsOn: assembleStaging) << {
        deploy(["staging"])
}

task deployRelease(dependsOn: [assemble]) << {
        def ver = project.manifest.@versionName.text()
        deploy(["debug", "staging", "release"], ver)
}

void deploy(envlist) {
        deploy(envlist, "SNAPSHOT")
}

void deploy(envlist, ver) {
        def buildApkDir = "$buildDir/apk"
        envlist.each { env ->
                def compiledApk = "${project.name}-${env}"
                def compiledApkWithVer = "${compiledApk}-${ver}"
                file("${buildApkDir}/${compiledApk}.apk").renameTo(file("${buildApkDir}/${compiledApkWithVer}.apk"))

                logger.lifecycle("deploy to ${compiledApkWithVer}.apk")
                copy {
                        from(buildApkDir) { include "${compiledApkWithVer}.apk" }
                        into deployApkDir
                }
        }
}

{% endhighlight %}

{% highlight properties %}
#gradle.properties

#WebDAVの公開ディレクトリパス
deployApkDir=/var/www/html/apks
{% endhighlight %}

---------------------------
## 「/lib/libz.so.1: no version information available」を解決

色々なサイトを参考に64bit環境でのビルド時に出力されるエラーメッセージをなんとか解決できた。。  
参考にさせていただいたサイトとHackした人に感謝×２ ｍ（＿＿）ｍ

やり方を簡単に説明すると、32bit版のzlib(今回確認したのはver1.2.5)をコンパイルして、
aapt(AndroidSDK付属ツール)の実行直前に`LD_PRELOAD`でコンパイルしたsoライブラリを読み込ませる。

### 32bit版zlibをコンパイル

zlibのソースをダウンロードし、32bitオプションを追加してmakeビルド  

__※今回試した環境以外のOSバージョンやディストリビューションでは32bitオプションの指定は異なるかも__

{% highlight bash %}
cd /tmp
wget http://downloads.sourceforge.net/project/libpng/zlib/1.2.5/zlib-1.2.5.tar.gz
tar -zxvf zlib-1.2.5.tar.gz
cd zlib-1.2.7
export CFLAGS=-m32 LDFLAGS=-m32
./configure
./make
{% endhighlight %}

lddコマンドで生成されたlibz.soライブラリに64bitらしき記述がなければおｋ

{% highlight bash %}
zlib-1.2.5]# ldd libz.so
    linux-gate.so.1 =>  (0xffffe000)
    libc.so.6 => /lib/libc.so.6 (0xf7d83000)
    /lib/ld-linux.so.2 (0x00943000)

#ちなみに32bitオプションなしの64bit版だとこんな感じでした
#zlib-1.2.5]# ldd libz.so
#    linux-vdso.so.1 =>  (0x00007fff73db7000)
#    libc.so.6 => /lib64/libc.so.6 (0x00002b22d894c000)
#    /lib64/ld-linux-x86-64.so.2 (0x000000349fc00000)
{% endhighlight %}

### aaptをHack

↓ここのサイトに記載されているHack方法を参考にさせていただきました   
<http://www.systemtoolbox.com/article.php?articles_id=1100>  

ちなみにzlibのビルドは参考サイトの方法だとうまくできなかったので、それ以降を参考にした

生成した32bit版zlibライブラリのハードリンクをAndroidの`platform-tools`配下に作成する

>>6) Hard linked the resulting libz.* to the android platform tools directory. (Hard link in case a future Android update clobbers that directory, I don't have to recompile libz.) In this case, I have my Android SDK files in /opt, replace as needed.

{% highlight bash %}
ln libz.* /usr/local/android-sdk-linux/platform-tools/
{% endhighlight %}


apptをリネームし、`LD_PRELOAD`を直前に加えた形のapptラッパーshellを作成する

>>So I noticed that I had to write a wrapper script which preloaded libz from the installed directory versus the system libz. Just rename aapt to aapt.bin, and create a new file called aapt. Call the aapt.bin file using the LD_PRELOAD environment variable pointing to the new libz, passing all the command line arguments to the aapt.bin file. Make aapt shell script executable, and everything should load OK.

{% highlight bash %}
cd /usr/local/android-sdk-linux/platform-tools/
mv aapt aapt.org
touch aapt
cat <<EOF>aapt
#!/bin/bash
#
# Loads the libz library from the current directory.
# libz 32bit library differs from system's libz
#
 
LD_PRELOAD=/usr/local/android-sdk-linux/platform-tools/libz.so /usr/local/android-sdk-linux/platform-tools/aapt.bin $@
EOF
{% endhighlight %}

この方法だとaapt以外は元のsoライブラリを参照するため何の影響も受けない。  
（逆にHackしたAndroidSDKのUpdateする際には元に戻すとか、一時的な対策は必要と思われる）



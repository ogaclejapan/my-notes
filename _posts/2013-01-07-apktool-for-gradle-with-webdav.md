---
layout: post
title: Gradleを使ったWin/Mac対応のapkインストールツール
category : Tools
tags : [Gradle, Android]
alias : /android/2013/01/07/apktool-for-gradle-with-webdav/index.html
---

[Androidアプリ開発de継続的インテグレーション]({{ site.baseurl }}{% post_url 2013-01-06-ci-for-androidapps-with-webdav %})
をプロジェクトに導入してみたら、社内無線LANに繋げるテスト端末よりも個人端末など直接繋げない端末のほうが多くて非常に困った(´・ω・｀)

「AndroidSDKぐらい全員入れろよ！」…とは言えないので、
セットアップ不要のPC経由でapkを半自動でインストールするツールをGradleで作成してみた。
一応、開発者以外にもチームに関わる色々な人が導入できるよう最低限の機能と操作にしたつもり。


このツールで可能なことは以下の３つ

1. showタスク

	特定のWebDAVディレクトリに存在するapk一覧を表示する  
	→不要なファイルが見えても困るので、apkのみを表示するようにした

2. downloadタスク

	特定のWebDAVディレクトリに存在するapkをダウンロードする  
	→デフォルト(apkファイル指定なし)だと一番使うであろう開発最新版がダウンロードされるようにした

3. installタスク

	特定のWebDAVディレクトリに存在するapkをPCに接続された端末にadb経由で直接インストールする  
	→デフォルト(apkファイル指定なし)だと一番使うであろう開発最新版がインストールされるようにした  
	→ローカルにapkが存在しない場合は自動でダウンロードされるようにした

記事上、WebDAVは以下の仕様であることを前提とする

* apkが格納されたWebDAVのURLは`http://192.168.0.1/apks/`とする
* apkのファイル形式は`sample-(env)-(version).apk`でUPされているものとする
* プロジェクト環境はdebug,staging,releaseの３つあるものとする
* 最新開発中のものは`SNAPSHOT`というversionを意味するものとする

-----------------

最終的なツールの構成はこんな感じ↓
{% highlight bash %}
.
├── build.gradle
├── gradle
│   └── wrapper
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── gradlew
├── gradlew.bat
└── tool
    ├── forMac
    │   └── adb
    └── forWindows
        ├── AdbWinApi.dll
        ├── AdbWinUsbApi.dll
        └── adb.exe
{% endhighlight %}

tool配下はMac/WinのAndroidSDKが入った端末からadbに必要なファイルを事前に抜き出したものをセットし、
GradleWrapperは以前書いた「
[Gradle環境要らずのGradleチームビルド](/groovy/2013/01/04/gradle-wrapper/)
」のやり方で生成する

-----------------

最終的な[build.gradle](https://gist.github.com/4518163)はこんな感じ↓

{% highlight groovy %}
buildscript {
    repositories {
        mavenCentral()
        maven {
        	url 'http://sardine.googlecode.com/svn/maven/'
        }
    }
    dependencies {
        classpath 'com.googlecode.sardine:sardine:314'
    }
}

project.ext {
	baseUrl = 'http://192.168.0.1/apks/'
	sardine = SardineFactory.begin();
	defaultApk = 'sample-debug-SNAPSHOT.apk'
}

import com.googlecode.sardine.SardineFactory
import org.apache.tools.ant.taskdefs.condition.Os

task wrapper(type: Wrapper) {
  gradleVersion = '1.2'
}

//特定のWebDAVディレクトリに存在するapk一覧を表示する
task show(description: 'gradle[w] show') << {
	showApks()
}

//特定のWebDAVディレクトリに存在するapkをダウンロードする
task download(description: 'gradle[w] download -[Ptarget=(filename)]') << {
	def apk = project.defaultApk
	if (project.hasProperty('target')) {
		apk = target
	}
	downloadApk(apk)
}

//特定のWebDAVディレクトリに存在するapkをPCに接続された端末にadb経由で直接インストールする
task install(description: 'gradle[w] install [-Ptarget=(filename)] -Pforce=true') << {
	def apk = project.defaultApk
	if (project.hasProperty('target')) {
		apk = target
	}
	def isForce = false
	if (project.hasProperty('force')) {
		isForce = force
	}
	installApk(apk, isForce)
}

boolean isApk(mime) {
	mime.equals('application/vnd.android.package-archive')
}

void showApks() {
	def dav = project.sardine
	dav.list(project.baseUrl).collect { 
		if (isApk(it.contentType)) {
			println "[${it.modified}] ${it.name}"		
		}
	}	
}

void downloadApk(name) {
	downloadApk(name, true)
}

void downloadApk(name, overwrite) {
	def out = new File(projectDir, name)
	if (out.exists()) {
		if (!overwrite) return
		out.delete()
	}

	def apk = "${project.baseUrl}${name}"
	def dav = project.sardine
	if (!dav.exists(apk)) {
		logger.error("file not found. ${apk}")
		throw new StopActionException()
	}

	logger.lifecycle("download.. ${apk}")

	out.withOutputStream { stream ->
		dav.get(apk).eachByte { b ->
        	stream.write(b as int)
    	}
	}	
}

void installApk(name, isForce) {
	downloadApk(name, isForce)
	if (Os.isFamily(Os.FAMILY_WINDOWS)) {
		installApkForWindows(name, isForce)
		return
	}
	if (Os.isFamily(Os.FAMILY_MAC)) {
		installApkForMac(name, isForce)
		return
	}
	logger.error("not supported os. must be windows or mac")
	throw new StopActionException()
}

void installApkForWindows(name, isForce) {
	adbInstall("${projectDir}\\tool\\forWindows\\adb", name, isForce)
}

void installApkForMac(name, isForce) {
	adbInstall("${projectDir}/tool/forMac/adb", name, isForce)	
}

void adbInstall(adb, apk, isForce) {
	logger.lifecycle("adb install ${apk}")

	def stdout = new StringBuffer()
	def stderr = new StringBuffer()
	def cmd = "${adb} install"
	if (isForce) {
		cmd = "${cmd} -r" //reinstall option
	}

	def proc = "${cmd} ${apk}".execute()
	proc.consumeProcessOutput(stdout, stderr)
	proc.waitForOrKill(1000 * 60) //wait for 1min

	if (stdout.length() > 0) {
		logger.lifecycle(stdout.toString())
	}
	if (stderr.length() > 0) {
		logger.error(stderr.toString())
	}
}
{% endhighlight %}

ちなみに今回はWebDAVクライアントに[serdine](http://code.google.com/p/sardine/)を使ってみた。
Antタスクとしても提供しているので、簡潔で良い感じ。

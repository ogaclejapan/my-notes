---
layout: post
title: GradleでAndroidを継続的インテグレーションするための雛形
category : Tools
tags : [Android, Gradle]
alias : /android/2012/12/25/build-template-for-gradle/index.html
---

GradleでAndroidビルドを検証したので雛形をUPしておく。

参考にしたのは「Android Tools Project Site」のサイト

* [Using the new Bulld System](http://tools.android.com/tech-docs/new-build-system/using-the-new-build-system)

__※ちなみにGradleはバージョン`1.2`じゃないと動かないらしいので注意！__


--------------
## build.gradleの雛形

以下のコードをAndroidプロジェクト直下に`build.gradle`という名前で保存する。

__※2012/12/29 一部訂正__  
__※2013/1/6 ビルド設定をmanifestやprojectプロパティから読み込むように訂正__  

{% highlight groovy %}
buildscript {
  repositories {
    mavenCentral()
  }

  dependencies {
    classpath 'com.android.tools.build:gradle:0.2'
  }
}

project.ext {
  def projectProps = new Properties()
  file("project.properties").withInputStream {
    stream -> projectProps.load(stream)
  }
  props = new ConfigSlurper().parse(projectProps)
  manifest = new XmlSlurper().parse(file("AndroidManifest.xml"))
}

apply plugin: 'android'

android {
  target = project.props.target
  defaultConfig {
    //manifestファイルと異なるビルドをする場合のみコメント外すこと
    //packageName = manifest.@package.text()
    //versionCode = manifest.@versionCode.text()
    //versionName = manifest.@versionName.text()
  }
  buildTypes {
    debug {
      //packageNameSuffix = ".dev"
      debuggable = true
      debugSigned = true
      zipAlign = true
    }
    staging {
      //packageNameSuffix = ".stg"
      debugSigned = true
      zipAlign = true
    }
    release {
      debugSigned = false
      zipAlign = true
    }
  } 
  sourceSets {
    main {
      manifest {
        srcFile 'AndroidManifest.xml'
      }
      java {
        srcDir 'src'
      }
      res {
        srcDir 'res'
      }
      assets {
        srcDir 'src'
      }
      resources {
        srcDir 'src'
      }
    }
    test {
      java {
        srcDir 'tests/src'
      }
      resources {
        srcDir 'tests/src'
      }
    }
    debug {
      java {
        srcDir 'profiles/dev/src'
      }
      resources {
        srcDir 'profiles/dev/src'
      }
    }
    staging {
      java {
        srcDir 'profiles/stg/src'
      }
      resources {
        srcDir 'profiles/stg/src'
      }
    }
    release {
      java {
        srcDir 'profiles/release/src'
      }
      resources {
        srcDir 'profiles/release/src'
      }
    }
  }
}

sourceCompatibility=1.6
targetCompatibility=1.6

repositories {
  mavenCentral()
  mavenLocal()
}

dependencies {
  compile fileTree(dir: 'libs', include: '*.jar')
}

tasks.withType(Compile) {
  options.encoding = 'UTF-8'
}
{% endhighlight %}

### packageNameSuffixについて __※2012/12/29追記__
生成するapkに指定した名前を付加してくれるものと思ってたら、全く違った。。

このパラメータの用途は環境ごとに異なるapkを１つの端末に同時にインストールすることができるようにするための設定だと思われる。
manifestファイルの`package`属性を環境ごとに一意にすることで別物のアプリとして認識させるためのパラメータのようだ。

生成されるmanifestファイルはこんな感じかな。

(debug版ビルド)
{% highlight xml %}
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="com.ogaclejapan.dev"
      android:versionCode="1"
      android:versionName="1.0">
      ...
</manifest>
{% endhighlight %}

(staging版ビルド)
{% highlight xml %}
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="com.ogaclejapan.stg"
      android:versionCode="1"
      android:versionName="1.0">
      ...
</manifest>
{% endhighlight %}

ただし、このパラメータを使用するにはmanifestファイルの書き方に注意する必要があるのでメモしておく。

* manifestファイルの`application`要素以下すべてのパッケージ名をフルパスで定義すること

  ⇒ドット`.`からの相対パスで要素を定義すると`package`属性を基準にされてしまうので定義したクラスまでのパッケージパスがズレる


--------------
## プロファイル環境毎に設定ファイルを切り替える

mavenのprofiles機能と同様にdevやstagingなど環境毎に変わるものを上書きすることができる。
この雛形では`profiles/xx/src`がprofilesと同じ役目を果たしている。

現状、切り替え可能なことを確認できたのは、

* resources配下のプロパティファイル(xx.properties)
* res/values配下の設定ファイル

のみ。

現段階のバージョンが未実装なのか不明だが、
Javaコードや画像ファイル類は反映されなかった。

{% highlight groovy %}
...
    debug {
      resources {
        srcDir 'profiles/dev/src'
      }
      res {
        srcDir 'res'
      }      
    }
    staging {
      resources {
        srcDir 'profiles/stg/src'
      }
      res {
        srcDir 'res'
      }            
    }
    release {
      resources {
        srcDir 'profiles/release/src'
      }
      res {
        srcDir 'res'
      }            
    }
...
{% endhighlight %}

__※sourceSetsより前でbuildTypesを定義しないとビルド時にエラーが発生するようなので注意！__

--------------
## フォルダ構成がMaven系の場合

既にフォルダ構成が`src/main/java,src/main/resources`などmaven系プロジェクトの場合は`sourceSets`を以下のように変更してやる必要がある。

{% highlight groovy %}
...
  sourceSets {
    main {
      manifest {
        srcFile 'src/main/AndroidManifest.xml'
      }
      java {
        srcDir 'src/main/java'
      }
      res {
        srcDir 'src/main/res'
      }
      assets {
        srcDir 'src/main/assets'
      }
      resources {
        srcDir 'src/main/resouces'
      }
    }
    test {
      java {
        srcDir 'src/test/java'
      }
      resources {
        srcDir 'src/test/resources'
      }
    }
    debug {
      java {
        srcDir 'src/dev/java'
      }
      resources {
        srcDir 'src/dev/resources'
      }
    }
    staging {
      java {
        srcDir 'src/staging/java'
      }
      resources {
        srcDir 'src/staging/resources'
      }
    }
    release {
      java {
        srcDir 'src/release/java'
      }
      resources {
        srcDir 'src/release/resources'
      }
    }
  }
...
{% endhighlight %}

ちなみにこのプラグインはデフォルトmaven形式を推奨しているので、sourceSetsのデフォルトが上記のような値になっていると思われる。従ってsourceSetsの定義はいらないかも。。

__※あと現時点ではEclipseのADTがこのフォルダ構成を認識してくれないので、おすすめしない。__

--------------
## ネイティブ共有ライブラリ(libxx.so)をApkに含める方法

__※2013/01/07 追記__  

実際のところ、これが一番ハマった。。  
EclipseのADTプラグインはlibs/armeabi配下に置いとけば自動で含めてくれてたし、
そもともADTプラグインがどうやってapkを生成しているかなんて全く知らん。

色々なサイトを探しまわった結果、adt-devのForumに同じ質問をしているスレを発見。  
<https://groups.google.com/forum/?fromgroups=#!topic/adt-dev/SOs6mxZGjMM>

>> Support for .so libraries in Gradle builds?
で、結論からいうと、現段階のバージョンでは未実装とのこと…orz  

しかし、神現る！！
このスレにHackしたという人の書き込みがあり、Hack方法を[Gist](https://gist.github.com/4226923)にアップしてくれている。  

ただGistのコードだと要らない部分も含まれていたり、
libs配下にsoファイルを置いているケースではなかったりするので、実際に試してたHack定義をメモしておく。

{% highlight groovy %}
task copyNativeLibs(type: Copy) {
  def libsDir = "$projectDir/libs"
  from(libsDir) { include '**/*.so' }
  into new File(buildDir, 'native-libs')
}

tasks.withType(Compile) { compileTask -> compileTask.dependsOn copyNativeLibs }
 
clean.dependsOn 'cleanCopyNativeLibs'

//この定義があるとgradle tasksコマンドが例外で発生する
tasks.withType(com.android.build.gradle.PackageApplicationTask) { pkgTask ->
  pkgTask.jniDir new File(buildDir, 'native-libs')
}
{% endhighlight %}

一応コード中にコメントで記載したが、
この定義をしてからGradleタスクのtasksコマンド使用できなくなった。。  
解決方法があるのか今のところ不明なため、共有ライブラリが必要なければムリにこのHackを入れないほうが良さげ。

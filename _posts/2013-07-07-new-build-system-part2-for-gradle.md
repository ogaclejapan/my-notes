---
layout: post
title: Androidの新ビルドツール「Android Gradle Plugin」その２
category : Tools
tags : [Android, Gradle]
alias : /android/2013/07/07/new-build-system-part2-for-gradle/index.html
---

前回の[続き]({{ site.baseurl }}{% post_url 2013-06-23-new-build-system-for-gradle %})を書くの巻。


-----------------------
## Gradleビルド設定のカスタマイズ

Androidプラグインでは次のManifest情報をビルド時に書き換えることができる。

* minSdkVersion
* targetSdkVersion
* versionCode
* versionName
* packageName
* Package Name for the test application
* Insturument test runner

`android { defaultConfig { ... } }`に定義すると環境毎の設定デフォルト値として適用される。

{% highlight groovy %}

def getVersionName() {
    ...
}

android {
    compileSdkVersion 15

    defaultConfig {
        versionCode 12
        versionName getVersionName()
        minSdkVersion 16
        targetSdkVersion 16
    }
}

{% endhighlight %}

プロパティを定義してないときのDSL上の値とデフォルト値は次のとおり。

<table class="table">
    <tr>
        <th>Property Name</th>
        <th>Default value in DSL object</th>
        <th>Default value</th>
    </tr>
    <tr>
        <td>versionCode</td>
        <td>-1</td>
        <td>Manifestファイルの値</td>
    </tr>
    <tr>
        <td>versionName</td>
        <td>null</td>
        <td>Manifestファイルの値</td>
    </tr>
    <tr>
        <td>minSdkVersion</td>
        <td>-1</td>
        <td>Manifestファイルの値</td>
    </tr>
    <tr>
        <td>targetSdkVersion</td>
        <td>-1</td>
        <td>Manifestファイルの値</td>
    </tr>
    <tr>
        <td>packageName</td>
        <td>null</td>
        <td>Manifestファイルの値</td>
    </tr>
    <tr>
        <td>testPackageName</td>
        <td>null</td>
        <td>app package name + “.test”</td>
    </tr>
    <tr>
        <td>testInstrumentationRunner</td>
        <td>null</td>
        <td>android.test.InstrumentationTestRunner</td>
    </tr>
    <tr>
        <td>signingConfig</td>
        <td>null</td>
        <td>null</td>
    </tr>
    <tr>
        <td>proguardFile</td>
        <td>N/A</td>
        <td>N/A</td>
    </tr>
    <tr>
        <td>proguardFiles</td>
        <td>N/A</td>
        <td>N/A</td>
    </tr>
</table>


-----------------------
## ビルド環境のカスタマイズ

デフォルトでアプリケーションをdebug,releaseビルドするためのビルド設定を自動的に設定する。  
Androidのプラグインはこれら2つの環境をカスタマイズするだけでなく、独自のビルド環境を作成することができる。

{% highlight groovy %}

android {
    buildTypes {
        // (1)
        debug {
            packageNameSuffix ".debug"
        }

        // (2)
        jnidebug.initWith(buildTypes.debug)

        // (3)
        jnidebug {
            packageNameSuffix ".jnidebug"
            jnidebugBuild true
        }
    }
}

{% endhighlight %}

1. `debug { ... }` はdebug環境に関するビルド設定を定義できる
2. debugビルドの設定をベースに独自のビルド設定を作成する(これでjnidebugという新しい環境を定義できる)
3. `jnidebug { ... }` はjnidebugという独自環境に関するビルド設定を定義できる


ビルド環境に関するデフォルト設定値は次のとおり。  
debugとreleaseのデフォルト値が異なるようので要注意。

<section class="table-responsive">
    <table class="table">    
        <tr>
            <th>Property Name</th>
            <th>Default value for debug</th>
            <th>Default value for release / other</th>
        </tr>
        <tr>
            <td>debuggable</td>
            <td>-true</td>
            <td>false</td>
        </tr>
        <tr>
            <td>jniDebugBuild</td>
            <td>-false</td>
            <td>false</td>
        </tr>
        <tr>
            <td>renderscriptDebugBuild</td>
            <td>-false</td>
            <td>false</td>
        </tr>
        <tr>
            <td>renderscriptOptimLevel</td>
            <td>-3</td>
            <td>3</td>
        </tr>
        <tr>
            <td>packageNameSuffix</td>
            <td>-null</td>
            <td>null</td>
        </tr>
        <tr>
            <td>versionNameSuffix</td>
            <td>-null</td>
            <td>null</td>
        </tr>
        <tr>
            <td>signingConfig</td>
            <td>android.signingConfigs.debug</td>
            <td>null</td>
        </tr>
        <tr>
            <td>zipAlign</td>
            <td>false</td>
            <td>true</td>
        </tr>
        <tr>
            <td>runProguard</td>
            <td>false</td>
            <td>true</td>
        </tr>
        <tr>
            <td>proguardFile</td>
            <td>N/A</td>
            <td>N/A</td>
        </tr>
        <tr>
            <td>proguardFiles</td>
            <td>N/A</td>
            <td>N/A</td>
        </tr>ope
    </table>
</section>

独自のビルド環境を定義することで環境に依存したコードやリソースをビルドに含めることができる。
デフォルトではsourceSetに`src/<buildtypename>/`として自動で設定される。
なお、他のsourceSetと同様に`setRoot('path')`で格納先を変更することもできるようになっている。

{% highlight groovy %}

android {
    sourceSets.jnidebug.setRoot('foo/jnidebug')
}

{% endhighlight %}

また、独自のビルド環境を定義すると、新しい`assemble<buildtypename>`タスクも自動で作成される。
これはAndroidプラグインに組み込まれているdebug,release環境のタスクと同様に利用することができる。

独自のビルド環境に定義したコードやリソースはビルド時、次のように適用される

* AndroidManifestファイルはmainに定義してあるものにマージされる
* ソースコードはコードを含むフォルダがソースフォルダの１つとしてコンパイル対象に含まれる
* リソースはmainに定義してあるものを上書きする


-----------------------
## 証明書の設定

Androidプラグインではアプリケーションの署名に必要な項目を`android { signingConfigs {...} }`に定義する。
なお、debug環境用のビルド設定には`$HOME/.android/debug.keystore`を使用するように自動的に設定されている。

{% highlight groovy %}

android {
    signingConfigs {

        debug {
            storeFile file("debug.keystore")
        }

        myConfig {
            storeFile file("other.keystore")
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
    }

    buildTypes {
        foo {
            debuggable true
            jniDebugBuild true
            signingConfig signingConfigs.myConfig
        }
    }
}

{% endhighlight %}

debugキーストアはデフォルトの`$HOME/.android/debug.keystore`が設定されているときのみ自動で生成される。
それ以外の場所に変更している場合は自動で生成されないので事前に自分で作成しておくこと。

-----------------------
## ProGuardの設定

バージョン0.4からProGuard(version:4.9)がサポートされている。
ProGuardのプラグインはAndroidプラグインが自動的にロードしているので、`runProguard`プロパティが有効なら自動でタスクに組み込まれて実行されるようになっている。

{% highlight groovy %}

android {
    buildTypes {
        release {
            runProguard true
            proguardFile getDefaultProguardFile('proguard-android.txt')
        }
    }

    productFlavors {
        flavor1 {
        }
        flavor2 {
            proguardFile 'some-other-rules.txt'
        }
    }
}

{% endhighlight %}

-----------------------
## マルチプロジェクトの設定

Gradleではマルチプロジェクト構成もサポートしている。

例えば、次のような構成のプロジェクトがある場合、
プロジェクトルート直下にsettings.gradleファイルを置き、各プロジェクト内にbuild.gradleファイルを置く。

{% highlight bash %}

MyProject
└　app
└　libraries
 　└　lib1　
 　└　lib2

{% endhighlight %}

Gradleでは各プロジェクトのフォルダ階層を`:`に表現した名前を一意なIDとして使用する。
settings.gradleにはこの各GradleプロジェクトのIDを定義すればよい。

{% highlight groovy %}

include ':app', ':libraries:lib1', ':libraries:lib2'

{% endhighlight %}

appプロジェクトがlib1プロジェクトに依存している場合は、appプロジェクトのbuild.gradleに依存を定義すればよい。

{% highlight groovy %}

dependencies {
    compile project(':libraries:lib1')
}

{% endhighlight %}

-----------------------
## ライブラリプロジェクトの設定

AndroidのリソースやAPIを使用するライブラリを開発する場合にはAndroidライブラリプロジェクトとして作成する。
Gradleのビルド設定は基本的にAndroidプロジェクトと同様だが、`apply plugin`の部分を`android-library`と定義する必要があることに注意すること。

{% highlight groovy %}

buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:0.4.2'
    }
}

apply plugin: 'android-library'

android {
    compileSdkVersion 15
}

{% endhighlight %}

LibraryプロジェクトはAndroidプロジェクトと違い、apkは生成されない。
代わりにAndroid標準の`.aar`パッケージを生成する。

また、ビルド環境に関してもAndroidプラグイン標準で組み込まれている`debug`,`release`のみが使用可能となっている。

-----------------------
## テストの設定

GradleのAndroidプロジェクトではテストビルドを組み込んでいるので、従来のようにテストプロジェクトを別途用意する必要がない。

次の２つのパラメータはテスト用に予め用意されている。

* testPackageName
* testInstrumentationRunner

テスト結果のレポートは単一プロジェクトであれば`build/reports/instrumentTests`に出力される。
出力場所を変更したい場合には`android { testOptions { ... } }`に`reportDir`プロパティを定義すればよい。

{% highlight groovy %}

android {
    ...

    testOptions {
        reportDir = "$project.buildDir/foo/report"
    }
}

{% endhighlight %}

-----------------------
##  ビルドタスクのカスタマイズ

実際のプロジェクトでは「コンパイル時にxxの処理を実行したい」とか、特定のタスクをフックしたい思うことがある。
Androidプラグインではタスクを内容を書き換えたり、依存を加えたりできるようなポイントが用意されている。

作成するプロジェクトタイプにより、使用できるプロパティは異なるがandroidオブジェクトには次の３つが定義されている。

* applicationVariants　（アプリケーションを生成するプロジェクトでのみ利用可能）
* libraryVariants　（ライブラリプロジェクトでのみ利用可能）
* testVariants　（上記両方のプロジェクトで利用可能）

applicationVariantsにアクセスするには以下のように記述するばよい。

{% highlight groovy %}

android.applicationVariants.each { variant ->
    ....
}

{% endhighlight %}

従って、(未だ実装されていない)ネイティブ共有ライブラリsoファイルをapkに含める[hack](https://gist.github.com/khernyo/4226923)処理は新バージョンだと次のように書くこともできる。

{% highlight groovy %}

task copyNativeLibs(type: Copy) {
    def libsDir = "$projectDir/libs"
    from(libsDir) { include '**/*.so' }
    into new File(buildDir, 'native-libs')
}

tasks.clean.dependsOn 'cleanCopyNativeLibs'

android.applicationVariants.each { variant -> 
    variant.javaCompile.dependsOn copyNativeLibs
    variant.packageApplication.jniDir new File(buildDir, 'native-libs')
}

{% endhighlight %}

うん、前よりステキになった(・∀・)

-----------------------
##  まとめ

0.2系の時代からだと、proguardが実装されたり、タスクのフック処理が簡単になったりと0.4系にあげるメリットは結構あると思われる。
欲を言えば、soファイルあたりは早く正式に実装してもらいたいところだが…。

現状ではEclipseがIDEレベルでAndroidのGradleビルドをサポートしていないので、
当面はUnitテストやapk生成の自動化用途で活躍することになるだろう。

あー早くAndroidStudio流行らないかな−(´・ω・｀)

一応最新版のbuild.gradleテンプレを作成したので[Gist](https://gist.github.com/ogaclejapan/5943052)にあげておく。






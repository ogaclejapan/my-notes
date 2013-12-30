---
layout: post
title: コマンドラインからAndroidプロジェクトを生成する
category : Platforms
tags : [Android]
alias : /android/2012/12/24/create-project-for-commandline/index.html
---

AndroidのビルドツールGradle化でコマンドラインツールからプロジェクトを生成する機会があったので、忘れぬうちにメモ。


--------------
## 使用可能なAndroidターゲットバージョンを確認する

プロジェクトを生成するにはターゲットバージョンを予め決めておく必要があるため、
コンソールから`android list`コマンドで一覧を表示する。

{% highlight bash %}
android list target
Available Android targets:
----------
id: 1 or "android-3"
     Name: Android 1.5
     Type: Platform
     API level: 3
     Revision: 4
     Skins: HVGA (default), HVGA-L, HVGA-P, QVGA-L, QVGA-P
     ABIs : armeabi
----------
...(省略)
----------
id: 26 or "Google Inc.:Google APIs:16"
     Name: Google APIs
     Type: Add-On
     Vendor: Google Inc.
     Revision: 3
     Description: Android + Google APIs
     Based on Android 4.1.2 (API level 16)
     Libraries:
      * com.google.android.media.effects (effects.jar)
          Collection of video effects
      * com.android.future.usb.accessory (usb.jar)
          API for USB Accessories
      * com.google.android.maps (maps.jar)
          API for Google Maps
     Skins: WVGA854, WQVGA400, WSVGA, WXGA800-7in, WXGA720, HVGA, WQVGA432, WVGA800 (default), QVGA, WXGA800
     ABIs : armeabi-v7a
{% endhighlight %}

※全く表示されない場合はSDKManagerを起動してインストール済みか確認してみること

--------------
## 指定したAndroidターゲットバージョンのプロジェクトを生成する

導入したいターゲットバージョンが決まったら、`android create`コマンドのtarget引数に一覧で確認したidを指定してプロジェクトを生成する。

{% highlight bash %}
#id: 26 or "Google Inc.:Google APIs:16"の場合
android create project --target 26 --path ./HelloApp --activity HelloActivity --package com.ogaclejapan
{% endhighlight %}




---
layout: post
title: コマンドラインからAndroid JUnitテストを実行する
category : Platforms
tags : [Android]
alias : /android/2013/06/02/test-for-commandline/index.html
---

AndroidのJUnitテストをコマンドラインから実行する方法を忘れぬうちにメモしておく。

-----------------------
## すべてのテストケースをテストする場合

{% highlight bash %}
# testプロジェクトのパッケージが「com.ogaclejapan.myproject.test」だった場合
adb shell am instrument -w com.ogaclejapan.myproject.test/android.test.InstrumentationTestRunner
{% endhighlight %}

-----------------------
## 特定のテストケースをテストする場合

{% highlight bash %}
# テストクラスの名前が「com.ogaclejapan.myproject.test.MyTestCase」だった場合
adb shell am instrument -w -e class com.ogaclejapan.myproject.test.MyTestCase com.ogaclejapan.myproject.test/android.test.InstrumentationTestRunner
{% endhighlight %}

-----------------------
## 特定の1メソッドのみテストする場合

{% highlight bash %}
# 1メソッドの名前が「com.ogaclejapan.myproject.test.MyTestCase#testMyMethod」だった場合
adb shell am instrument -w -e class com.ogaclejapan.myproject.test.MyTestCase\#testMyMethod com.ogaclejapan.myproject.test/android.test.InstrumentationTestRunner
{% endhighlight %}

-----------------------
## 特定カテゴリーのみテストする場合

{% highlight bash %}
# @SmallTestアノテーションをついてるテストメソッドのみの場合
adb shell am instrument -w -e size small com.ogaclejapan.myproject.test/android.test.InstrumentationTestRunner
{% endhighlight %}

-----------------------
## 独自アノテーションを付与したカテゴリーのみテストする場合

まず、独自アノテーションを定義する

{% highlight java %}
package com.ogaclejapan.myproject.test;

/**
 * CI環境でテストすべきテストメソッドであることを示すマーカーアノテーションです。
 */
public @interface TestCI {}
{% endhighlight %}

そして、テストメソッドに定義したら準備おｋ

{% highlight java %}
package com.ogaclejapan.myproject.test;

public class MyTestCase extends TestCase {
	@TestCI
	public void testMyMethod() {
		//testcode...
	}
}

{% endhighlight %}


{% highlight bash %}
# @TestCIアノテーションをついてるテストメソッドのみの場合
adb shell am instrument -w -e annotation TestCI com.ogaclejapan.myproject.test/android.test.InstrumentationTestRunner
{% endhighlight %}



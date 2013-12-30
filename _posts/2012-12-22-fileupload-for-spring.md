---
layout: post
title: SpringMVCでのファイルアップロード
category : Frameworks
tags : [Spring]
alias : /java/2012/12/22/fileupload-for-spring/index.html
---

最近ファイルアップロードを使う機会があったので忘れぬうちにメモしておく。

主なポイントは３つ

* CommonsMultipartResolverのDI定義を追加する
* formタグにenctype属性を追加する
* Controllerのメソッド引数にRequestParamアノテーションを宣言する

---------
## CommonsMultipartResolverのDI定義を追加する

MVC系View定義がされているところあたりのDIに以下のBean定義を追加する。  

{% highlight xml %}
<bean id="multipartResolver"
    class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
    <property name="maxUploadSize" value="100000"/>
</bean>
{% endhighlight %}

id属性の`multipartResolver`はSpringさんが認識するための決まりごとなので、  
誤って違う名前で宣言しないように注意すること!

また、`CommonsMultipartResolver`は内部でapacheの`commons-fileupload.jar`を使用しているので、pomの依存ライブラリとして以下の宣言が含まれている確認しておくこと。

{% highlight xml %}
<dependency>
	<groupId>commons-fileupload</groupId>
	<artifactId>commons-fileupload</artifactId>
	<version>1.2.2</version>
</dependency>
{% endhighlight %}

---------
## formタグにenctype属性を追加する

multipartデータであることを伝えるためには`enctype="multipart/form-data"`という属性をformタグに宣言する。

{% highlight html %}
<form method="post" action="/fileupload" enctype="multipart/form-data">
	<input type="file" name="fileupload">
</form>
{% endhighlight %}

---------
## Controllerのメソッド引数にRequestParamアノテーションを宣言する

ファイルアップロードを受け取るメソッドに対して、`MultipartFile`型の引数を加えて`@RequestParam`アノテーションでformタグに定義したnameを指定すればおk。

{% highlight java %}
@Controller
public class FileuploadController {
	@RequestMapping(value="/fileupload", method=RequestMethod.POST)
	public void fileupload(@RequestParam("fileupload") MultipartFile file) {
		//file未選択時もnull値ではないため、サイズ0比較で検証するのがよさげ
		if (file.getSize() > 0) {
			System.out.println(file.getOriginalFilename());
		}
	}
}
{% endhighlight %}






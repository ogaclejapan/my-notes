---
layout: post
title: Bootstrap臭のする静的サイトが作れるJekyllテンプレ
category: Tools
tags: [Jekyll, Bootstrap]
---

新年あけましておめでとうございます。 彡^･∋★A Happy New Year★∈･^ミ

以前使っていた[Jekyll][jekyll]テンプレートのデザインに飽きたので、
「[【難しく考えすぎ！？】bootstrap臭のしないお洒落なレスポンシブWEBデザインの作り方](http://megane84.com/blog/2013/12/25/post-2682/)」
を横目に**Bootstrap臭のするお洒落じゃないレスポンシブなテンプレ**を自分で作ってみました。

ｽ、ｽﾐﾏｾﾝ…、CSSへの理解が足りないエンジニアの自分にはBootstrapのオイニーがとれない(´；ω；｀)ﾌﾞﾜｯ

*[Jekyllstrap][jekyllstrap]* - ([Source Code][jekyllstrap-github])
<a href="http://ogaclejapan.github.io/jekyllstrap/">
{% image https://www.googledrive.com/host/0B30bERhjS_icVDU0ZEpTdXhaOXM %}
</a>

---

## 主な機能

このサイトのデザインを刷新する目的で作ったので、ブログ向けの実装がメインになってます。  

また、広告とか設置する予定がなかったのでPC向けのレイアウトでよく見かける一般的なサイド領域は無視しました。

### 実装したもの

* **アーカイブ、カテゴリー、タグ一覧**

  一年毎の投稿一覧、カテゴリー毎（投稿が多い順）の投稿一覧、タグ毎（投稿が多い順）の投稿一覧を生成します。  

* **インデックス一覧のページング**

  `_config.yml`で5件毎のページング処理を有効にして、ページネーションをインデックスページに追加しました。

* **ATOMフィード**

  一応ブログなのでRSS的な配信ができるように[atom.xml][atom-feed]を生成します。

* **SEO対策**

    Google先生がインデックスし易いように[sitemap.xml][seo-sitemap]と[robots.txt][seo-robots]を生成します。

* **Google Analytics対応**

    サイト計測用に[Googleアナリティクス][ga]のjsを各ページに埋め込んでます。
    `_config.yml`に取得したトラッキングコードを定義するだけで機能が有効になります。

        google_analytics :
          tracking_id : 'UA-XXXXXXXX-X'    

* **AddThis対応**

    投稿ページの共有用と記事レコメンド用に[AddThis][addthis]のjsを埋め込んでます。  
    Analyticsと同様に`_config.yml`に取得したコードを定義するだけで機能が有効になります。

        addthis:
          pub_id: 'ra-XXXXXXXXXXXX'      

* **レスポンシブ画像対応**

    Bootstrap3からレスポンシブ画像に対応したようなので、対応したimgタグを生成できるように簡単なJekyllプラグイン作りました。  
    ※Markdownの画像指定`![image](hogehoge.jpeg)`ではレスポンシブになりません

    {% raw %}
        e.g. {% image hogehoge.jpeg %}
        ビルドすると、↓こうなります
        <img src="hogehoge.jpeg" class="img-responsive">
    {% endraw %}


### （今後実装したいもの）

* **SEO強化（[schema.org][schema-org]の構造化データ対応）**

    最近記事でちょいちょい見かけるやつ。全然理解してないのでSEO勉強がてら実装してみたい。

* **テーブル構造のレスポンシブ対応**

    Bootstrap自体はtableタグのレスポンシブに対応してるんですが、どうもdivタグでtableタグを囲むと定義した部分より1つ前の部分に記載されたMarkdown構文が解釈されず、そのまま出力されるという現象に悩まされてます。
    Markdownの仕様なのか、パーサーで使用している[redcarpet][redcarpet]の仕様なのか、もしくは不具合なのか原因不明ですが、なんとかしたいﾃﾞｽ。。

---

## まとめ

Bootstrap臭でよかったら使ってやってください。

*[Jekyllstrap][jekyllstrap]* - ([Source Code][jekyllstrap-github])

もっとJekyllについて詳しく知りたい方はこの辺のサイトを参考にすると分かりやすいでしょう。

* [Jekyllいつやるの？ジキやルの？今でしょ！][jekyll-about-ref1]
* [静的HTMLジェネレータ jekyllを考えるの巻][jekyll-about-ref2]

Gruntを組み込んで使ってる方もいるようです。

* [静的ページをJekyllとGrunt/Yeomanで作る][jekyll-about-ref3]


会社でもGHEが導入されたのでプライベートリポジトリで社内用メモ帳として使ってみるかな〜
|ﾟДﾟ)))ｺｿｰﾘ!!!!

[jekyllstrap]: http://ogaclejapan.github.io/jekyllstrap/
[jekyllstrap-github]: https://github.com/ogaclejapan/jekyllstrap
[jekyll]: http://jekyllrb.com/
[jekyll-about-ref1]: http://melborne.github.io/2013/05/20/now-the-time-to-start-jekyll/
[jekyll-about-ref2]: http://meusonho41.com/blog/?p=474
[jekyll-about-ref3]: http://qiita.com/shoito/items/5dad6e715d4e4d49e752
[atom-feed]: http://ja.wikipedia.org/wiki/Atom
[seo-sitemap]: http://holy-seo.net/blog/seo/sitemap-sml-method-described-merit/
[seo-robots]: http://bazubu.com/robots-txt-16678.html
[ga]: http://www.google.co.jp/intl/ja/analytics/
[addthis]: https://www.addthis.com/get/smart-layers
[schema-org]: http://tech.naver.jp/blog/?p=1038
[redcarpet]: https://github.com/vmg/redcarpet



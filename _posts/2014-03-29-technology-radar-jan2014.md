---
layout: post
title: Technology Radar - Jan 2014
category : Insights
tags : [Radar]
---

最新動向の発表ﾏﾀﾞｧ-? （･∀･ ）っ/凵⌒☆ﾁﾝﾁﾝ
…って、１月に出てるやないかぁーｺﾞﾙ━━━((((　ﾟДﾟ)=○)ﾟ∀ﾟ);'.;'.･━━━ｧｧ!!  

な、なぜ気づけない…これだけのためにメール購読登録までしてるのに。。埋もれた…ﾄﾎﾎ  
とりあえず気を取り直して、、見ていくことにするー  

[Thoughtworks社が発表した２０１４年１月版技術動向 - Technology Radar Jan 2014][tech-radar]


Technology Radarでは次の４部門に大きく技術を分類し、１部門毎に４段階の評価レンジで区切っています。

* [Techniques](#techniques)
* [Tools](#tools)
* [Platforms](#platforms)
* [Languages & Frameworks](#languages-and-frameworks)


各評価レンジはそれぞれ以下のような意味を持つようです（…たぶん。）

> **ADOPT** : *We feel strongly that the industry should be adopting these items. We use them when appropriate on our projects.*  

プロジェクトで積極的に採用するべき価値があるもの  

> **Trial** : *Worth pursuing. It is important to understand how to build up this capability. Enterprises should try this technology on a project that can handle the risk.*

多少のリスクを伴えるプロジェクトなら試してみるべき価値があるもの

> **Assess** : *Worth exploring with the goal of understanding how it will affect your enterprise.*

プロジェクトにとって価値があるかどうか調査してみるべきもの

> **Hold** : *Proceed with caution.*

今後の採用を慎重に行うべきもの（ちょっと衰退傾向にあるもの？？）


## <span id="techniques" class="anchor-hack"></span>Techniques

http://www.thoughtworks.com/radar/#/techniques

ADOPTに入ったのは次の５つ。

> **Capturing client-side JavaScript errors**

`New Relic`のようなツールを使い、
ユーザ影響を及ぼすクライアントサイドのJavaScriptエラーを検知できる仕組みを導入する。

* [VOYAGE GROUP　エンジニアブログ New Relicのなかなか凄い新機能を試してみた][tech-ref1]

> **Continuous delivery for mobile devices**

ビルドやテストを`xctool`や`Travis-CI`などで自動化し、モバイル端末上からビルド済みアプリを取得できるようにする。

* [Xcodeと自動化 - Qiita][tech-ref2]

> **Mobile testing on mobile networks**

モバイル端末の動作確認はちゃんと3G回線／LTE回線と同等の速度環境で実施する。

* [Webページを表示するテストの際に、通信速度を3Gに制限して表示してみよう - YoheiM .NET][tech-ref3]

> **Segregated DOM plus node for JS Testing**

これはあまりよく分からないが、jQueryでDOMを直接操作するのはカオスになるから`AngularJS`がよいと聞いたことがある。  
とりあえずマーチンファウラーさんがブログで書いた記事が見つかった。

* [SegregatedDOM][tech-ref4]

> **Windows infrastructure automation**

`Powershell`と組み合わせることで`Chef`や`Puppet`がWindows上でも動作するのでインフラ環境を自動化する。

* [Windows Serverにchef-soloでIISをインストールする ｜ Developers.IO][tech-ref5]

## <span id="tools" class="anchor-hack"></span>Tools

http://www.thoughtworks.com/radar/#/tools

ADOPTに入ったのは次の２つ。

> **D3**

オライリー本も出てるくらい有名なデータ可視化ライブラリ。

* [「D3.js」を使ったデータビジュアライゼーション : CodeZine][tools-ref1]

> **Dependency management for JavaScript**

JavaScriptの依存するライブラリを一元管理する。Twitter社の`Bower`とか？

* [Bower入門(基礎編) - from scratch][tools-ref2]

## <span id="platforms" class="anchor-hack"></span>Platforms

http://www.thoughtworks.com/radar/#/platforms

ADOPTに入ったのは次の５つ。

> **Elastic Search**

検索プラットフォーム。  
ログ解析とか全文検索とか大抵Elastic Searchが一緒に現れる。

* [ElasticSearch+Kibanaでログデータの検索と視覚化を実現するテクニックと運用ノウハウ][platforms-ref1]

> **MongoDB**

ドキュメント指向データベース。  
JSON形式なのでNode.jsのバックエンドとしてよく使われているような気がする。

* [噂のMongoDBその用途は？][platforms-ref2]

> **Neo4J**

グラフ指向データベース。  
これ使えばフォロー関係とか、2ホップ以内のフォローしてないユーザ抽出とかいい感じで処理できるんだろうなーと思っている。

* [グラフDBのNeo4jを1日触ってみた - Wantedly Engineer Blog][platforms-ref3]

> **Node.js**

ノンブロッキングIOで大量リクエストを捌けるサーバサイドJavaScript。  
最近だと`rubygems`みたいに`npm`を使うためだけにインストールする機会も増えてきた気がする。

* [Node.js を選ぶとき 選ばないとき][platforms-ref4]

> **Redis**

永続化機能をもつインメモリ型キーバリューストア。  
ランキングは作れるし、リストやセットも便利だし、キャッシュしても使えるし、個人的にはほんと使えるやつという印象;

* [ニコニコ生放送に見る Redis 活用ノウハウ：特集｜gihyo.jp][platforms-ref5]

> **SMS and USSD as a UI**

ほとんどのモバイル端末がSMSまたはUSSDに対応しているからメッセージング手段として使う価値あるということかな、、これもよく分からんw  

## <span id="languages-and-frameworks" class="anchor-hack"></span>Languages & Frameworks

http://www.thoughtworks.com/radar/#/languages-and-frameworks

ADOPTに入ったのは次の4つ。

> **Clojure**

Javaで書かれたLisp系の関数型プログラミング言語。  
全く活用事例を見たことないな、、前回もADOPTに含まれてたから何かの分野ではきっと凄いんだろうね…

* [イミュータブル時代の言語としてのClojure][lang-ref1]

> **Dropwizard**

アプリケーションサーバ不要な軽量フルスタックJavaフレームワーク？？的なもの。  
Springも同じような仕組みで`SpringBoot`を昨年発表したし、来年あたり本格的に流行出しそうな感じするねー  
個人的には軽量WEBコンテナの`Undertow`も気になってる。

* [今年流行るかもしれないDropwizardフレームワークを使ってみる ｜ Developers.IO][lang-ref2]

> **Scala, the good parts**

JVM上で動作するオブジェクト指向と関数型のハイブリッドな言語。  
Twitterのバックエンドに採用されているらしい。個人的には`Play Framework`と`Akka`のイメージが強い。    
Javaライブラリとか、そういうパーツとしてScalaを使うのは良いってことかな。

* [Scalaの現状と課題][lang-ref3]

> **Sinatra**

Ruby製のWEBアプリケーション用DSL。  
うーん、これも今のところWEB+DB PRESSの記事で読んだことあるぐらいで、あまり見かけないなー。

* [たった5行のコードでWebサービス！Sinatra, Rubyとは？][lang-ref4]


[tech-radar]: http://www.thoughtworks.com/radar

[tech-ref1]: http://tech.voyagegroup.com/archives/7584491.html
[tech-ref2]: http://qiita.com/keroxp/items/de5b1982345cfb1e2320
[tech-ref3]: http://www.yoheim.net/blog.php?q=20140211
[tech-ref4]: http://martinfowler.com/bliki/SegregatedDOM.html
[tech-ref5]: http://dev.classmethod.jp/cloud/aws/windows-chef-iis/

[tools-ref1]: http://codezine.jp/article/detail/7459
[tools-ref2]: http://yosuke-furukawa.hatenablog.com/entry/2013/06/01/173308

[platforms-ref1]: http://www.slideshare.net/y-ken/elasticsearch-kibnana-fluentd-management-tips
[platforms-ref2]: http://www.slideshare.net/crumbjp/db-tech-showcase-mongodb
[platforms-ref3]: http://engineer.wantedly.com/2014/01/02/neo4j-introduction.html
[platforms-ref4]: http://www.slideshare.net/tricknotes/nodejs-27589695
[platforms-ref5]: https://gihyo.jp/dev/feature/01/redis

[lang-ref1]: http://qiita.com/kawasima/items/c695e2f4ee079a6debf5
[lang-ref2]: http://dev.classmethod.jp/server-side/java/dropwizard/
[lang-ref3]: http://www.slideshare.net/kmizushima/scala-12334929
[lang-ref4]: http://it.typeac.jp/article/show/5

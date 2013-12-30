---
layout: post
title: Technology Radar - May 2013
category : Insights
tags : [Radar]
alias : /tech/2013/06/09/technology-radar-may2013/index.html
---

著者でも有名なマーチンファウラーさん率いる[Thoughtworks社](http://www.thoughtworks.com/)から最新の技術動向が発表されていました＼(^O^)／

* [Technology Radar May 2013](http://www.thoughtworks.com/radar)
* [PDF版](http://thoughtworks.fileburst.com/assets/technology-radar-may-2013.pdf)

すっかり半期毎に発表だと思ってたので、なかなか発表されず終了かと思ってたよ…(；´∀｀)

-------------------------------
## Radarの読み方

Radarでは大きく以下の４部門に分けて、それぞれの技術動向をレンジで区切っています。

* Techniques
* Tools
* Platforms
* Languages & Frameworks

レンジは４段階に分かれていて、それぞれ以下のような意味を持つようです。

* Adopt: 積極的にプロジェクトで採用すべきもの

	> We feel strongly that the industry should be adopting these items. We use them when appropriate on our projects.

* Trial: 多少のリスクを伴えるプロジェクトなら試してみるべきもの

	> Worth pursuing. It is important to understand how to build up this capability. Enterprises should try this technology on a project that can handle the risk.

* Assess: プロジェクトにどれだけ価値があるか調査してみる価値があるもの

	> Worth exploring with the goal of understanding how it will affect your enterprise.

* Hold: 先行きが怪しいので慎重に採用すべきもの

	> Proceed with caution.

-------------------------------
## Techniques部門の技術動向

◎〜Adopt〜◎

* Aggregates as documents: _ドキュメントを集約すべき_  
 →GitHubのmarkdownみたいな関係ことかなー？？

* Automated deployment pipeline: _デプロイを自動化すべき_  
 →[Jenkins](http://jenkins-ci.org/)とか、最近だとDevOpsツールの「[Chef](http://www.opscode.com/chef/)」とか

* Guerrilla testing: 
* In-process acceptance testing: 
* Mobile testing on mobile networks: _モバイルのテストはモバイルネットワーク上ですべき_  
 →擬似で再現するならローカルプロキシの[Charles](http://www.charlesproxy.com/)とかで帯域制御もありなのかも

* Performance testing as a first-class citizen: _重要となるクラスは性能テストをすべき_
* Promises for asynchronous programming: _非同期通信を考慮すべき_  
 →Promiseという定義からjQueryまわりの話っぽい

* Windows infrastructure automation: _Windows環境のインフラを自動化するべき_  

-------------------------------
## Tools部門の技術動向

◎〜Adopt〜◎

* [D3](http://d3js.org/)
* Embedded servlet containers
* Frank
* [Gradle](http://www.gradle.org/)
* [Graphite](http://graphite.wikidot.com/)
* Immutable servers4
* [NuGet](http://nuget.org/)
* [PSake](https://github.com/psake/psake)

-------------------------------
## Platforms部門の技術動向

◎〜Adopt〜◎

* [Elastic Search](http://www.elasticsearch.org/)
* [MongoDB](http://www.mongodb.org/)
* [Neo4j](http://www.neo4j.org/)
* [Redis](http://redis.io/)
* SMS and USSD as a UI

-------------------------------
## Language & Frameworks部門の技術動向

◎〜Adopt〜◎

* [Clojure](http://clojure.org/)
* CSS frameworks
* [Jasmine paired with Node.js](http://pivotal.github.io/jasmine/)
* [Scala](http://www.scala-lang.org/)
* [Sinatra](http://www.sinatrarb.com/)


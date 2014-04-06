---
layout: post
title: 学ぶぜ、Java8！！ part2
category: Languages
tags: [Java]
---

さて、Java8を動かすためのMaven雛形を前回作ったので、
さっそくJava8で実装された新機能をいくつか試めしてみましたー (・∀・)/  

かなり簡易的なコードサンプルですが、Java7以前のユーザならJava8の進化が感じられると思います！

一応、前回の記事はこちらになります ⇒
「[学ぶぜ、Java8！！]({{ site.baseurl }}{% post_url 2014-03-22-learn-java8 %})」


## Collections API

StreamAPIのおかげで、ちょっとしたコレクション系の処理ならワンライナーで書けちゃいます。  
いやーほんと便利な機能だわ、早く業務でも使いたい…(；´∀｀)

```java

package com.ogaclejapan;

import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static java.util.Comparator.comparing;
import static java.util.stream.Collectors.*;

public class CollectionsTest {

    //名前と年齢をもつPersonクラスをコレクションテストの例として使います
    static class Person {

        private String name;
        private int age;

        public Person(String name, int age) {
            this.name = name;
            this.age = age;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getAge() {
            return age;
        }

        public void setAge(int age) {
            this.age = age;
        }

        @Override
        public String toString() {
            return "Person{" +
                    "name='" + name + '\'' +
                    ", age=" + age +
                    '}';
        }

    }

    List<Person> people;

    @Before
    public void setUp() throws Exception {

        people = Arrays.asList(
                new Person("sato", 23),
                new Person("suzuki", 30),
                new Person("aoki", 20),
                new Person("watanabe", 20));

    }

    // 年齢の昇順にリストを並び替えて表示する
    @Test
    public void testSorted() throws Exception {

        people.stream().sorted(comparing(p -> p.getAge())).forEach(System.out::println);
        /*
        output:
            Person{name='aoki', age=20}
            Person{name='watanabe', age=20}
            Person{name='sato', age=23}
            Person{name='suzuki', age=30}
        */

    }

    // 名前だけを抽出したリストに変換して表示する
    @Test
    public void testMap() throws Exception {

        List<String> names = people.stream().map(p -> p.getName()).collect(toList());
        System.out.println(names);
        /*
        output:
            [sato, suzuki, aoki, watanabe]
        */

    }

    // 名前と年齢を交互に格納したリストに変換して表示する
    // (実際だと複数のサブリストをフラットな１つのリストに変換したりするときに使えるはず)
    @Test
    public void testFlatMap() throws Exception {

        people.stream().flatMap(p -> Arrays.stream(
                new String[]{p.getName(), String.valueOf(p.getAge())})).forEach(System.out::println);
        /*
        output:
            sato
            23
            suzuki
            30
            aoki
            20
            watanabe
            20
        */

    }

    // 年齢をキーにグループ化した名前リストのMap<Integer, List<String>>型に変換して表示する
    @Test
    public void testGroupBy() throws Exception {

        Map<Integer, List<String>> peopleByAge = people.stream().collect(
                groupingBy(p -> p.getAge(), mapping((Person p) -> p.getName(), toList())));

        System.out.println(peopleByAge);
        /*
        output:
            {20=[aoki, watanabe], 23=[sato], 30=[suzuki]}        
        */

    }

    // 年齢が22歳より上の人を抽出して表示する
    @Test
    public void testFilter() throws Exception {

        people.stream().filter(p -> p.getAge() > 22).forEach(System.out::println);
        /*
        output:
            Person{name='sato', age=23}
            Person{name='suzuki', age=30}        
        */

    }

    // リスト先頭から2名分の人を抽出して表示する
    @Test
    public void testLimit() throws Exception {

        people.stream().limit(2).forEach(System.out::println);
        /*
        output:
            Person{name='sato', age=23}
            Person{name='suzuki', age=30}        
        */

    }

    // リスト先頭から2名分の人を除いて表示する
    @Test
    public void testSkip() throws Exception {

        people.stream().skip(2).forEach(System.out::println);
        /*
        output:
            Person{name='aoki', age=20}
            Person{name='watanabe', age=20}        
        */

    }

    // 年齢のリストに変換して、重複を除いた年齢を表示する
    @Test
    public void testDistinct() throws Exception {

        people.stream().map(Person::getAge).distinct().forEach(System.out::println);
        /*
        output:
            23
            30
            20        
        */

    }

    // 全員の年齢が19歳より上かどうかを判定する
    @Test
    public void testAllMatch() throws Exception {

        if (people.stream().allMatch(p -> p.getAge() > 19)) {
            System.out.println("all adult");
        }
        /*
        output:
            all adult            
        */

    }

    // 30歳以上の人が存在するかを判定する
    @Test
    public void testAnyMatch() throws Exception {

        if (people.stream().anyMatch(p -> p.getAge() >= 30)) {
            System.out.println("found around the age of 30");
        }
        /*
        output:
            found around the age of 30
        */

    }

}

```

### Optional\<T\>

今まで`if (foo != null && foo.equals("hoge")) {..}`とか`bar = (foo != null) ? foo.getBar() : null`、   
みたいなコードを何度書いたことか…素晴らしい進化だ(´；ω；｀)ﾌﾞﾜｯ
ライブラリとかコアな部分の内部で使うと凄く幸せになれそうな気がしてる。

```java

public class OptionalTest {

    @Test
    public void testOptional() throws Exception {

        Optional<String> name = Optional.of("foo");

        if (name.isPresent()) {
            System.out.println(name.get());
        }

        name.ifPresent(System.out::println);

        System.out.println(name.orElse("hoge"));

        /*
        output:
            foo
            foo
            foo        
        */
    }

    @Test
    public void testEmpty() throws Exception {

        Optional<String> name = Optional.empty();

        if (name.isPresent()) {
            System.out.println(name.get());
        }

        System.out.println(name.orElse("empty"));

        /*
        output:
            empty
        */

    }

    @Test
    public void testNull() throws Exception {

        Optional<String> name = Optional.ofNullable(null);

        if (name.isPresent()) {
            System.out.println(name.get());
        }

        System.out.println(name.orElse("null"));

        /*
        output:
            null
        */

    }

    @Test
    public void testFilter() throws Exception {

        Optional<String> name = Optional.of("foo");

        name.filter(x -> x.equals("foo")).ifPresent(System.out::println);

        /*
        output:
            foo
        */
    }

    @Test
    public void testFilterCaseOfNull() throws Exception {

        Optional<String> name = Optional.ofNullable(null);

        name.filter(x -> x.equals("foo")).ifPresent(System.out::println);

        /*
        output:

        */

    }

    @Test
    public void testMap() throws Exception {

        Optional<String> name = Optional.of("  foo  ");

        name.map(String::trim).filter(s -> s.length() > 0).ifPresent(System.out::println);

        /*
        output:
            foo
        */
    }

    @Test
    public void testMapCaseOfNull() throws Exception {

        Optional<String> name = Optional.ofNullable(null);

        name.map(String::trim).filter(s -> s.length() > 0).ifPresent(System.out::println);

        /*
        output:

        */

    }
}


```

## おしまい

あと他にもinterfaceのデフォルトメソッドとかDate and Time APIとかちょっと試したけど、  
時間切れにより終了〜。とりあえずJava8が便利だということは体感できた(・´з`・)♪


試したコードはGitHubに上げてありますので、気になる方はcloneでもして実行してみてくださいな。

https://github.com/ogaclejapan/java-samples/tree/java8



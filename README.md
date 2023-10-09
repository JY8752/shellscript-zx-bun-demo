# シェルスクリプトとzx(Bun)の比較

簡単なスクリプトをシェルスクリプトと[zx](https://github.com/google/zx)で書き比べてみる。せっかくなのでJSのランタイムには[Bun](https://bun.sh/)を使ってみる。

## スクリプトの内容

あらかじめ、配置したデータをもとにガチャのシュミレーションを実行するスクリプト。データには以下の2ファイルを配置しスクリプト内で読み込んでいる。

- ```themes.txt``` 有効なガチャテーマの一覧。

```:themes.txt
theme1 これはtheme1のガチャです
theme2 これはtheme2のガチャです
theme3 これはtheme3のガチャです
```

- ```gacha/<theme number>.csv``` 各ガチャテーマに含まれるアイテム情報。

```csv
id,name,rarity,weight
1,item1,N,10
2,item2,N,10
3,item3,N,10
4,item4,N,10
5,item5,N,10
6,item6,R,5
7,item7,R,5
8,item8,R,5
9,item9,R,5
10,item10,SR,1
```

## シェルスクリプトの実行

```
./main.sh
```

## zx(Bun)

### setup

#### init

```
% bun init
```

#### module

- zx ^7.2.3
- inquirer ^9.2.11
- papaparse ^5.4.1

```
bun add zx inquirer papaparse
```

### zxスクリプトの実行

```
./index.ts
```
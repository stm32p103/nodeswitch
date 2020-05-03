switch-node
====

複数のバージョンのNode.jsを簡易的に管理するためのPowershellスクリプトと、それを起動するバッチファイル一式。
Node.jsのインストールと、使用するバージョンの切り替えができる。

# 使い方
このリポジトリを Node.js をインストールしたい場所\<switch-node>にクローンする。

```
<switch-node>
+- script
   +- install-node.bat
   +- switch-node.bat
   +- common.ps1
```

## Node.jsのインストール
install-node.batを、\<Verseion>に`14.1.0`のようにNode.jsのバージョンを指定して実行する。

```
install-node <Version>
```

インストール後は以下のようなフォルダ・ファイルが作られるので、Node.jsやnpmを実行する前に`<switch-node>\common\node`および`<switch-node>\common\npm_global`をPATHに追加する。

```
<switch-node>
+- script
|  +- install-node.bat
|  +- switch-node.bat
|  +- common.ps1
|
+- common
|  +- node      : PATH環境変数に追加すること
|  +- npm_global: PATH環境変数に追加すること
|
+- versions
   +- node-v14.1.0-win-x64
      +- npm_global
```

### 注意
このコマンドを実行すると、npmのグローバル設定ファイル(.npmrc)の`prefix`を`<switch-node>\common\npm_global`に書き換えるので注意すること。

## Node.jsのバージョン切り替え
Node.jsのインストール後、別のバージョンのNode.jsを使いたければ、以下のコマンドを実行する。

```
switch-node <Version>
```

# 仕組み
`common\node`と`common\npm_global`は、それぞれディストリビューションごとのフォルダ`node-v.X.Y.Z-win-x[86|64]`と`node-v.X.Y.Z-win-x[86|64]\npm_global`へのシンボリックリンクである。これらをPATH環境変数に追加しておけば、シンボリックリンクのリンク先のディストリビューションを切り替えることで、バージョンを変えることが可能となっている。

日本語の説明はこのファイルの後半にあります。

# LaTeX Build Tools

LaTeX Build Tools is a tool to maintain big LaTeX source files.
This version is different from the old versions as follows.

- Use `lbt` command to run every sub commands.
- It is provided as a gem.

The old versions, the one with rake and the other of bash scripts, are moved to the other branches, `rake_version` and `bash` respectively.

LaTeX Build Tools supports `lualatex` engine only.
If you want to use another engine, you need to modify `lib/lbt/build.rb` and `lib/lbt/part_typeset.rb`.

## Prerequisite

- Linux operating system
- Ruby. You can install it by one of the followings.
  - Install the distribution package
  - Install it with rbenv. Refer to [Rbenv's GitHub repository](https://github.com/rbenv/rbenv)
- LuaLaTeX. You can install it by one of the followings.
  - Install the distribution package
  - Install TexLive. Refer to [TexLive website](https://tug.org/texlive/)

## Installation

You can install `lbt` from RubyGems.org with gem command.

```
$ gem install lbt
```

If you want to install it from the source code, do the following.

1. Click the `Code` button, then click `Download ZIP` in the small dialog.
2. Unzip the downloaded Zip file, then a new directory `LaTeX-BuildTools-master` will be created.
3. Type `gem build lbt` under the directory, then the gem file `lbt-0.5.1.gem` is created.
The number `0.5.1` is the version number.
4. Type `gem install lbt-0.5.1.gem`.

## Document

See [Tutorial](Tutorial.md).

## License

GPL. See [License.md](License.md).

----------

# LaTeX Build Tools

LaTeX Build Toolsは大きなLaTeXソースファイルを管理するためのツールである。
現在の版は次の2点が旧版と異なっている。

- lbtというコマンドからすべてを起動
- gemとして提供される

旧版の、rakeを用いる版とbashスクリプト版は、それぞれ`rake_version`ブランチと`bash`ブランチに移動した。

LaTeX Build ToolsがサポートするLaTeXエンジンはlualatexである。
その他のエンジンを使いたい場合は`lib/lbt/build.rb`と`lib/lbt/part_typeset.rb`の修正が必要である。

## 動作条件

- Linux オペレーティング・システム
- Ruby。Rubyのインストール方法は次の2通りがある
  - ディストリビューションのパッケージをインストール
  - Rbenvを用いてインストール。詳しくは[RbenvのGitHubレポジトリ](https://github.com/rbenv/rbenv)を参照してほしい
- LuaLaTeX。LuaLaTeXのインストール方法は次の2通りがある
  - ディストリビューションのパッケージをインストール
  - TexLiveをインストール。詳しくは[TexLiveのウェブサイト](https://tug.org/texlive/)を参照してほしい

## インストール

gemコマンドでRubyGems.orgから`lbt`をインストールする。

```
$ gem install lbt
```

以上が最も簡単なインストール方法だが、ソースコードからインストールしたい場合は次のようにする。

1. GitHubのレポジトリを開き`Code`ボタンをクリック。小さいダイアログが現れるので、`Download ZIP`をクリックする
2. ZIPファイルを解凍すると`LaTeX-BuildTools-master`というディレクトリが作られる
3. 端末をそのディレクトリに移動して`gem build lbt`とタイプすると、`lbt-0.5.1.gem`というGemファイルが作られる。
数字`0.5.1`はバージョン番号である
4. `gem install lbt-0.5.1.gem`とタイプしてインストールする

## ドキュメント

[チュートリアル](Tutorial.ja.md)を参照してほしい。

## ライセンス

GPL。[License.md](License.md)を参照。

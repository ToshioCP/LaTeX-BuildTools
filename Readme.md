日本語の説明はこのファイルの後半にあります。

# LaTeX Build Tools

LaTeX Build Tools is a tool to maintain big LaTeX source files.
This version is different from the old versions as follows.

- Use `lbt` command to run every sub commands.
- It is provided as a gem.

The old versions, the one with rake and the other of bash scripts, are moved to the other branches, `rake_version` and `bash` respectovely.

LaTeX Build Tools supports `lualatex` engine only.
If you want to use another engine, you need to modify `lib/lbt/build.rb` and `lib/lbt/part_typeset.rb`.

## Prerequisite

- Linux operationg system
- Ruby. You can install it by one of the followings.
  - Install the distribution package
  - Install it with rbenv. Refer to [Rbenv's GitHub repository](https://github.com/rbenv/rbenv)
- LuaLaTeX. You can install it by one of the followings.
  - Install the distribution package
  - Install TexLive. Refer to [TexLive website](https://tug.org/texlive/)

## Installation

Install `lbt` with gem command.

~~~
$ gem install lbt
~~~

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

旧版の、rakeを用いる版とbashスクリプト版は、それぞれrake\_versionブランチとbashブランチに移動した。

LaTeX Build ToolsがサポートするLaTeXエンジンはlualatexである。
その他のエンジンを使いたい場合はlib/lbt/build.rbとlib/lbt/part\_typeset.rbの修正が必要である。

## 動作条件

- Linux オペレーティング・システム
- Ruby。Rubyのインストール方法は次の2通りがある
  - ディストリビューションのパッケージをインストール
  - Rbenvを用いてインストール。詳しくは[RbenvのGitHubレポジトリ](https://github.com/rbenv/rbenv)を参照してほしい
- LuaLaTeX。LuaLaTeXのインストール方法は次の2通りがある
  - ディストリビューションのパッケージをインストール
  - TexLiveをインストール。詳しくは[TexLiveのウェブサイト](https://tug.org/texlive/)を参照してほしい

## インストール

gemコマンドで`lbt`をインストールする。

~~~
$ gem install lbt
~~~

## ドキュメント

[チュートリアル](Tutorial.ja.md)を参照してほしい。

## ライセンス

GPL。[License.md](License.md)を参照。

# インストール

Latex-Buildtoolsを使うには次の3つが必要です。

- Rubyのインストール
- LuaLaTeXのインストール
- Lbt（lbtはLatex-Buildtoolsのことです）のインストール

最初の2つはディストリビューションのパッケージをインストールするのが最も簡単です。
例えばUbuntuであればaptコマンドを使います。

LbtはRubyのgemとして提供されるので、gemコマンドでインストールします。

```
$ gem install lbt
```

# ソースファイル用ディレクトリとテンプレートの作成

ここでは、このチュートリアルをPDFファイルに変換することを通してLbtの使い方を示します。

最初にソースファイル用ディレクトリとテンプレートを作成するために、newサブコマンドを使います。
newサブコマンドには、ディレクトリ名、ドキュメントクラス名、作業ディレクトリ名を引数に与えますが、後ろの2つは省略できます。
省略した場合のデフォルト値はそれぞれbookと\_buildです。
ここではltjsarticleドキュメントクラスを使います。

```
$ lbt new Tutorial ltjsarticle
$ cd Tutorial
$ ls -a
.  ..  .config  helper.tex  main.tex
```

.configファイルには作業ディレクトリ名の定義が書かれています。

```
$ cat .config
build_dir = _build
```

newサブコマンドで作業ディレクトリ名を省略したので、デフォルト値の\_buildになっています。
これはbuildとpart\_typesetサブコマンド実行時に参照されます。

main.texはLaTeXソースのルートファイルです。

```
$ cat main.tex
\documentclass{ltjsarticle}
\input{helper.tex}
\title{Title}
\author{Author}
\begin{document}
\maketitle
\tableofcontents

\end{document}
```

タイトルと著者は書き換えが必要です。
タイトルを「チュートリアル」に、著者を「関谷　敏雄」に変更しておきます。

helper.texはプリアンブル部に取り込まれます。
主にパッケージの取り込みとコマンドの定義をします。

```
$ cat helper.tex
\usepackage{amsmath,amssymb}
\usepackage[luatex]{graphicx}
\usepackage{tikz}
\usepackage[margin=2.4cm]{geometry}
\usepackage[colorlinks=true,linkcolor=black]{hyperref}
% If your source includes Markdown, you may need the following lines.
% It is because Pandoc generates some undefined commands.
% The Pandoc template file shows how to define them.
% You can see it by 'pandoc --print-default-template=latex'.
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
```

今回はtikzは必要ないので削除しても構いませんが、ここではそのままにしておきます。
最後の2行は、PandocでMarkdownファイルをLaTeXファイルに変換するときに必要です。
今回のソースはMarkdownなので、このまま残しておきます。

# 本文ファイルの作成

今回はこのファイル（Readme.ja.md）をセクションごとに別ファイルにしてトップディレクトリに配置します。
最初の節（インストール）をsec1.mdとし、以下sec2.md、sec3.md・・・とします。
このファイルからコピペしてそれぞれのファイルを作ってください。

# タイプセット

LaTeXのソースファイルからPDFファイルを作ることをタイプセットといいます。
タイプセットはbuildサブコマンドで実行できます。

```
$ lbt build
```

この実行によってトップディレクトリにPDFファイルが生成されます。
ファイル名にはタイトルが使われるので、「チュートリアル.pdf」となります。

# 部分タイプセット

LaTexのソースが大きくなると全体のタイプセットに時間がかかるようになります。
1つのファイルを書いていて、そのPDFの出来栄えを確かめたいときに全体をタイプセットするのは時間がかかりすぎます。
そのときは、該当のファイルのみをタイプセットすることができます。

```
$ lbt part_typeset 1
```

引数の1はsec1.mdのことです。
もしsec5.mdをタイプセットしたければ1の代わりに5を使ってください。

PartやChapterのある大きな文書では、例えばpart1/chap2/sec4.texに対して「1-2-4」と引数を指定してください。

コンパイル結果は`_build/main.pdf`に保存されます。

# リナンバー

ときにはsec1.mdとsec2.mdの間にセクションを挿入したいことがあるかもしれません。
そのときにはsec1.5.mdとしてください。
これらをsec1.md、sec1.5.md、sec2.mdからsec1.md、sec2.md、sec3.mdのように連続する正整数に直すことをリナンバーと呼ぶことにします。
renumサブコマンドを実行することでリナンバーできます。

```
$ lbt renum
```

# Pandoc と Top-Level-Division オプション

LbtはPandocを用いてMarkdownをLaTeXに変換しています。
デフォルトでは、PandocはATX見出しの`#`を`\section`に変換します。
詳しくはPandocのドキュメントの`--top-level-division`を参照してください。

これを、LaTeXファイルのディレクトリにある`.config`ファイルを書き換えることで変更できます。
例えば、下記のようにすると、`#`が`\chapter`に対応するようになります。

```
$ cat .config
build_dir = _build
top-level-division = chapter
```

書き方の書式は`top-level-division = (part, chapter or section)`です。

下記の表は一般的に良く用いられるtop-level-divisionです。

|documentclass|top level division|
|:-----|:-----|
|book|chapter or part|
|report|chapter|
|article|section|
|beamer|section|


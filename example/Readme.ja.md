# lbとlb.confの例

## example1

コンパイルの仕方

-端末を起動して、カレントディレクトリを example1 に移動する。
-lb とタイプする

コンパイルの条件はlb.confに書かれている。

    # configuration file for lb
    rootfile=example.tex
    builddir=_build
    engine=latex
    latex_option=-halt-on-error
    dvipdf=dvipdf
    preview=

この条件によって、コンパイルは次のように行われる。

    $ latexmk -dvi -latex="latex -halt-on-error %S %O" _build example.tex
    $ dvipdf _build/example.dvi _build/example.pdf

条件を変えた場合のコンパイル結果についていくつか例をあげる。

-rootfile=の右辺に空文字列を指定。
`lb example`または`lb example.tex`とすればコンパイルできる。
`lb`とだけ打った場合は、lbにrootfileの指定がなされないことになり、lbはデフォルトとして`main.tex`を採用する。
しかし、`main.tex`が存在しないからエラーになる。
-builddif=の右辺に空文字列を指定。
この場合はexample1ディレクトリの中でコンパイルが行われる。
-engine=pdflatexとすると、pdflatexでコンパイルされる。
直接pdfが生成されるので、dviファイルは生成されない。
-engine=の右辺に空文字列を指定。
エンジンが指定されていないので、texソースファイルを分析して適当なエンジンを起動する。
example1の場合は、ソースファイルの1行目でドキュメントクラスに`article`が指定されている。
これに対応するデフォルトとしてlb（実際はその下位スクリプトのltxengine）は`pdflatex`を選択する。
-dvipdf=dvipdfmxとすると、dviからpdfを生成するコマンドがdvipdfmxとして実行される。

## example2

example2ディレクトリには、lb.confが無いときのlbの振る舞いについて確認するためのいくつかの例が収められている。

    $ lb

デフォルトのファイルである`main.tex`がコンパイルされる。
ドキュメントクラスがjsarticleなので、`platex`でdviを生成後`dvipdfmx`でpdfに変換される。

    $ lb ex1

`ex1.tex`のドキュメントクラスがltjsarticleなので、`lualatex`でコンパイルされ、pdfを直接生成する。

    $ lb ex2

`ex2.tex`のドキュメントクラスがarticleなので、`pdflatex`でコンパイルされ、pdfを直接生成する。

## example3

このディレクトリ内では、ルートファイルである`main.tex`がサブファイル`sub.tex`をinputコマンドで取り込んでいる。

    $ lb

この場合は、デフォルトのファイルが`main.tex`であるので、それをコンパイルして`main.pdf`を生成する。

    $ lb sub

この場合は、サブファイル`sub.tex`のみのコンパイルで、`test_sub.pdf`が生成され、`lb.conf`で指定されたプリビューワである`evince`によって表示される。
また、synctexを有効にしてコンパイルしているので、エディタがそれをサポートしていれば、pdfファイルから、CTRL+左クリックでソースへの後方参照ができる。
ただし、仮のルートファイルである`_build/test_sub.tex`もエディタで開かないとsynctexの効果は現れない。

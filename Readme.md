# BuildTools

## BuildTools作成の背景

#### LatexToolsとBuildtoolsの関係

大きな文書、例えば100ページを越える本などをLaTeXで作る場合は、小さい文書の作成と異なる様々な問題を考える必要がある。

- ソースファイルの分割
- 分割コンパイル
- 文書の一括置換
- 前処理（LaTeXコンパイル前に処理する作業）

これらを支援するツール群がLatexToolsであり、いくつかのグループに別れている。

- BuildTools。ソースファイルの新規作成、ビルド、分割コンパイルを支援するツール群
- SubsTolls。ソースファイルに対する一括置換をするツール群

このように、BuildToolsはLatexToolsを構成する一部であるが、同時に、BuildToolsはLatexToolsの中核をなすツール群である。
このドキュメントではBuildToolsを解説する。

#### ソースファイルの分割

LaTeXソースファイルを単にここではソースファイルと呼ぶ。
大きな文書を1つのソースファイルに記述するのは適切でない。
なぜなら、ファイルが大きくなると、エディタで編集するのが極めて困難になるからである。
そこで、文書を分割することになる。
通常は\\begin{document}と\\end{document}を含む1つのファイルと、そのファイルから\\includeまたは\\inputで呼び出される複数のファイルに分割する。
前者をルート・ファイル、後者をサブ・ファイルという。
\\includeと\\inputはどちらもサブ・ファイルの取り込みのコマンドだが、違いがある。

- \\includeは多段階の取り込みはできない。\\includeonlyで一部のみを取り込む指定ができる。取り込む前に\\clearpageをする。
- \\inputは単にファイルを取り込むだけで\\clearpageなどはしない。多段階の取り込みができる

文書をコンパイルによって作成することをビルドと呼ぶ。
ビルドはLaTeXのコンパイルだけでなく、前処理（例えばgnuplotによる画像生成だったり、データからtikzのグラフを生成したりなど）も含める。
ビルドは最終的にルートファイルをコンパイルすることによって完了する。
LaTeXソースファイルをコンパイルするプログラムにはいくつかあり、それをエンジンと呼んでいる。
エンジンには、lualatex、pdflatexなどがある。
コンパイルは文書が大きくなればなるほど時間がかかるようになる。
1箇所だけを変更する場合も同じだけ時間がかかる。
文書の編集の途中で出来栄えをチェックするためにコンパイルすること（これをテストするなどということがある）は多々あるが、そのたびに長い時間がかかる。
文書が大きくなればなるほどこの問題は深刻になる。
そこで、サブファイルのみをコンパイルできるようにする方法がいろいろ考えられた。

- \\includeonlyコマンドの引数（サブファイル群）からコンパイルしたくないファイルをコメントアウトする
- subfilesパッケージを用いる

とくにsubfilesパッケージはよくできており、推薦する方も多い。
ただ、パッケージを取り込み、そのコマンドを適切に使うことが必要である。
もちろん、上記のコンパイル時間の問題からすれば、それくらいは何ともないことであるが。

これ以外の方法としては、サブファイルのコンパイル用にに何らかの方法でプリアンブル部などを付け加える方法がある。
具体的には、サブファイルを「\\documentclassから\\begin{document}まで」と「\\end{document}」でサンドイッチにする。
そのときにサブファイル自体を変更するのではなく、プリアンブルなどを記述したファイルからサブファイルを\\inputで取り込むようにする。
そのサブファイルを取り込むファイルを「仮のルートファイル」と呼んだりする。
それに対して元々のルートファイルを「オリジナルのルートファイル」と呼ぶこともある。
仮のルートファイルのプリアンブル部は、オリジナルのルートファイルのコピーである。
この方法の良い点は

- ソースファイルにパッケージの取り込みや特別な命令を書き込む必要がない。
- したがって、ソースファイルを配布するにあたって、非配布者に特定のパッケージをインストールさせる必要がない。

つまり、ソースファイルをなんら変更することなく、サブファイルのみのコンパイルが可能だというのが長所である。
ただ、そのためには仮のルートファイルを生成するプログラムが必要である。
本ツール群（以後、BuildToolsと呼ぶ）では、ttexというシェルスクリプトでそれを行っている。

#### コンパイルのリピート（繰り返し）

最終的に文書をコンパイルするときには、相互参照などを実現するためにコンパイルを複数回行わなければならない。
その回数は2回であったり、3回であったりするらしいが、筆者はその事情をよく知らない。
が、ここに優れたプログラムがあり、必要回数を判断し、必要なだけコンパイルしてくれる。
latexmkというプログラムである。
latexmkを用いることによって、ビルドは非常に楽になる。
BuildToolsではlatexmkを使用する。

#### 作業用ディレクトリの設置

LaTeXでコンパイルすると、様々な補助ファイルやログファイルが生成されるので、きれい好きの人はそれについて不満を感じることがあると思う。
それで、作業用ディレクトリを設置して、そういうファイルの一切合財を入れてしまうとソースディレクトリをきれいに保つことができる。
そういうソフトにcluttexがあり、きれい好きな人にはお勧めである。
BuildToolsでは作業用ディレクトリ\_build（名前は変更も可能）を設置し、補助ファイルなどを格納する。
このことにより、ソースディレクトリを汚さずに済む。
また、コンパイルのログや補助ファイルを見たいときは\_buildの中を見れば良い。
非常に単純なのである。
蛇足になるが、単純であることはソフトウェアにとってとても大切なことだ。

BuildToolsでは、生成された最終文書（pdfファイル）も作業用ディレクトリにできあがる。
それをソースファイルディレクトリに置きたいというのは自然は発想だが、それにはmakeを使うと良い。
つまり、Makefileに最終文書を作業用ディレクトリからコピーするコマンドを書いておくのである。
また、makeを使うことの利点は、前処理を記述できることである。
前処理はその文書ごとに異なるので、その記述はユーザに任せる以外にない。

BuildToolsでは、makeを併用することを推奨している。
特に、前処理からpdf文書のコンパイルまでをバッチ処理として行うにはmakeが必要である。
（サブファイルのテストはこの限りではない。）

makeは「前提条件によってレシピを実行する」のが原則である。
ところが、latexmkは常に呼び出されるようにしなければならない。
それにはFORCEというターゲットを用いる。
詳しくは、makeのマニュアルに解説がある。
また、Makefileのサンプルも本ツールで提供されるので、参照されたい。

#### Texworksとの連携

BuildToolsでは、lbというコマンドでルートファイルのビルドもサブファイルのテストコンパイルも行うことができる。
それをTexworksのタイプセッティングに登録すると、Texworksから起動できて大変便利である。
「設定」ー＞「タイプセッティング」タブで設定する。
+をクリックして新たなコマンドを設定する。名前=>lb、コマンドlb、引数=>\$fullnameで良い。
設定後はルートファイルで全体のコンパイル、サブファイルは単独のテスト・コンパイルがワンクリックでできるようになる。
他の統合開発環境でもできるかもしれないが、筆者は今のところTexworksしか使ったことがない。

## BuildToolsの構成

BuildToolsは大きく分けて次のような部分から構成されている。

- 「newtex」 make New laTex folder。新規ソースファイルの作成を支援するツール。 
- 「lb」 Latex Build。ルートファイルをコンパイル、またはttexを使ってサブファイルのテストコンパイルをする。
- 「ttex」 Test laTex。サブファイルのテストコンパイルをする。通常は、lbから呼び出されて使う。
- アーカイブ作成を支援するツール。
- インストーラ
- ユーティリティ群。上記のプログラムを下支えする。

文書作成の手順は次のようなフローを仮定している。

1. 文書全体の構成を決める。章立てを決める。
2. newtexを使ってフォルダとソースファイルの雛形を作成する。
3. Makefile、表紙（cover.tex）、プリアンブル部（helper.tex）の作成。
4. 本文の作成と、テストコンパイル。
5. 前処理の作成。
6. 最終ビルド。

上記の3から5は行ったり来たりすることになり、必ずしもこの順に作業が進むわけではない。

## 主要なツールについて

#### newtex

    $ newtex

シェル・スクリプト。
新規にLaTeXの文書を作るときに骨組みを作るスクリプト。
newtexを使う前に全体の構成と章立てを決めておくと良い。

このプログラムは2回に分けて使う。

1. newtex bookname で新規にフォルダを作成し、その中にskeleton.txtというファイルを作る。
2. skeleton.txtを編集する。このファイルは章（ダブルクォートで囲む）と章ごとに取り込むファイルの名前（ファイル名に空白は使えない）を指定する。
3. 作られたフォルダで端末を起動し、newtexを引数なしで起動すると、ルートファイル、サブファイル、その他のファイルが作られる。

#### lb

    $ lb [LaTeXfile]

シェル・スクリプト。
引数省略の場合はmain.texが引数で与えられた場合と同じ動作をする。
引数のLaTeXファイルをビルドするスクリプトであり、これだけで足りることが多い。

- 引数がルートファイルの場合はそれをlatexmkを使ってビルドする。サブファイルの場合はttexでビルドする。
- 引数がルートファイルの場合は、synctexを使わない。
- 引数がサブファイルの場合は、synctexを使い、コンパイル後にプリビューワを起動する。
- カレント・ディレクトリ（通常はルートファイルのあるディレクトリになる）にlb.confがあれば、それを読み込んで変数の初期化をする
- エンジン指定を省略するとスクリプトが自分で予測する。

lb.confというファイルで多少の設定ができる。

    rootfile=main.tex
    builddir=_build
    engine=
    latex_option=-halt-on-error
    preview=texworks

- rootfileはルートファイルの名前
- builddirはビルドディレクトリで、補助ファイルや出力ファイルを書き込むフォルダ。対象がサブファイルの場合は仮のルートファイルもそこに書き出す
- engineはLaTeXエンジン
- latex_optionはエンジンに与えるオプション。-output-directoryはlbが自動的に与えるので、ここに書いてはいけない
- previewはできあがったpdfを見るためのプリビューワ。ただし、サブファイルのときのみ動作する。

#### ttex

    $ ttex subfile

シェル・スクリプト。
サブファイルに仮ルートファイルをつけてコンパイルする。
コンパイルは1回だけ。
そのため相互参照は反映されない。
（これはテストのためのスクリプトであって、最終仕上げではないから相互参照はさほど重要ではない、という考えに基いている）。
また、該当のサブファイル以外のファイルにあるラベルを参照することはできない。
単独で使うことも可能だがlbを通して呼び出すのが普通の使い方。

#### arl

   $ arl

シェル・スクリプト。
arlは、ARchive LaTeX filesから。
ルートファイルを指定すると関連ファイルを検索してアーカイブを作る。

- 前処理プログラムがある場合、そのプログラムを実行してからarlを起動する必要がある。
- arlのアーカイブするのは、LaTeXソースファイルと、includegraphicsされる画像ファイルのみ。
- したがってMakefileや、前処理のソースファイル（例えばgnuplotのソース）などはアーカイブされない。

Makefileにターゲットを作り（例えばarという名前のターゲット）、arlで作ったアーカイブにtarでMakefileや前処理ソースファイルを追加するスクリプトを書いておくと便利である。

アーカイブを圧縮するオプション -g、-b、-zで、それぞれ、tar.gz, tar.bz2, zipをサポート。

#### ユーティリティ群

この項はスクリプトをメンテナンスするのでなければ読む必要はない。

    $ srf subfile

シェル・スクリプト。
subfileからルートファイルを探し、その結果（ファイル名）を出力する。
srfは「Search Root File」の意味。

    $ tfiles [-p| -a| -i] rootfile

シェル・スクリプト。
rootfileのサブファイルの一覧を取得する

- オプション無し => ルートファイルが取り込むサブファイル（\\begin{document}から\\end{document}までのinclude/inputコマンドで指定されたファイル）のリストを標準出力に出力する
- -p  プリアンブルで取り込まれるサブファイルのリストを標準出力に出力する
- -a  オプション無しのリストにルートファイルを加えて標準出力に出力する
- -i  includeコマンドで取り込まれるファイルのみを標準出力に出力する

注意：出力されるファイルのリストは改行で区切られている。

    $ tftype [-r|-s|-q] files ...

シェル・スクリプト。
LaTeXのソースファイルの種類を調べるスクリプト。

- -r （デフォルト）引数のファイルの中からルートファイルのみを抽出して出力する
- -s 引数のファイルの中からサブファイルのみを抽出して出力する
- -q （quiet）上記の出力を抑制する。引数は1つのファイルのみで、そのファイルタイプをexitステータスで返す。
exitステータスが0はルートファイル、1はサブファイル。

-qオプションを使うことが最も多い。

    $ gfiles files ...

シェル・スクリプト。
引数のLaTeXファイルの中で\\includegraphicsによって取り込まれる画像ファイルの一覧を返す。

    $ ltxengine ルートファイル

シェル・スクリプト。
コンパイルを行うLaTeXエンジンを予想する（本来ユーザが明示すべきだが・・・）
例えば、

    \usepackage[luatex]{graphicx}

というコマンドがプリアンブルにあれば、エンジンはlualatexと予想がつく。


    $ p2t textfile

テキストを、LaTeXソースに変換する。
LaTeXで使えない文字がいくつかある。
例えば、\_（アンダースコア）。
これらの文字はLaTeXコマンドで表現する。
例えば、\_（アンダースコア）は\\_(バックスラッシュ+アンダースコア）というコマンドで表現する。

このスクリプトはttexで使うことができるが、そのためには、ttexでp2tを含む1行をコメントアウトすることが必要である。
デフォルトではp2tは使われていない。

### インストールとアンインストール

インストール用のスクリプト install.sh を使う。

    $ bash install.sh

この場合、シェルスクリプトなどの実行ファイルは\$HOME/binに、テンプレートは\$HOME/share/ltxtoolsに保存される。
debianやubuntuでは、ログイン時に\$HOME/binがあれば、bashの実行ディレクトリのパス\$PATHに追加される。
インストール時に新規に \$HOME/bin を作成した場合には、再ログインしないと、それが実行ディレクトリに追加されないので注意が必要。
rootになってインストールすると/usr/local/bin、/usr/local/share/ltxtoolsにそれぞれ実行ファイル、テンプレートをインストール。
debianの場合は、

    $ su -
    # bash install.sh

ubuntuの場合は

    $ sudo bash install.sh

オプションで個人レベルのインストールか、システムレベルのインストールかを指定することも可能。

- -s システムレベルのインストール。システムへの書き込み権限が必要。
- -u ユーザレベルのインストール。かならず一般ユーザで行うこと。仮にrootでインストールすると/root/bin、/root/share/ltxtoolsにインストールされる、つまりrootの個人用としてインストールされる。

アンインストールは uninstall.shで行う。
一般ユーザで実行すれば、\$HOME以下のインストールファイルが削除される。

    $ bash uninstall.sh

rootで実行すれば、/usr/local以下のインストールファイルが削除される。
debianの場合は、

    $ su -
    # bash uninstall.sh

ubuntuの場合は、

    $ sudo bash uninstall.sh

オプション -s, -u で、システムレベルか、個人レベルかを明示することも可能。


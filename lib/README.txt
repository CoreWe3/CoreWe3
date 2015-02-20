コンパイル手順

SOURCE: ファイル名(拡張子なし)
REPO_ROOT: リポジトリルート
SOURCE_DIR: mincamlソースのあるディレクトリ
WORK_DIR: 実行ファイルを作るディレクトリ

1.ソースコードとlibmincaml.mlを結合。
cat ${SOURCE_DIR}/${SOURCE}.ml ${LIB_ML} > ${WORK_DIR}/${SOURCE}.ml
LIB_ML: 特別なことをするのでなければ${REPO_ROOT}/lib/mincaml/libmincaml.ml

2.コンパイル
${REPO_ROOT}/mincaml_compiler/min-caml ${WORK_DIR}/${SOURCE}

3.リンク
cat ${REPO_ROOT}/lib/asm/${BOOT_S} ${REPO_ROOT}/lib/asm/${LIB_S} ${WORK_DIR}/${SOURCE}.s
BOOT_S: レイトレーサー用外部変数を使うときrt_boot.sをそれ以外の時はboot.sを指定。
LIB_S: 全部ソフトウェア実装の時はlibmincaml.Sを、全部ネイティブの時はlibmincaml_native.Sを指定。それ以外の時は後述。

4.アセンブル
${REPO_ROOT}/simulator/bin/assembler ${WORK_DIR}/${SOURCE} < ${WORK_DIR}/${SOURCE}.s

5.実行
${REPO_ROOT}/simulator/bin/simulator ${WORK_DIR}/${SOURCE} -s ${REPO_ROOT}/lib/init.bit　[OPTIONS]

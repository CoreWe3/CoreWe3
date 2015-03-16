#!/bin/bash

usage() {
    echo "Usage: $0 FILE [OPTIONS] "
    echo
    echo "FILE:"
    echo "コンパイルしたいmincamlソース"
    echo
    echo "Options:"
    echo " --help         ヘルプ"
    echo " --work-dir     実行ファイル及び作業用ファイルが生成されるディレクトリ(デフォルトでsimulator/bin)"
    echo " --inline       コンパイラのインライン展開の深さ(デフォルトで0)"
    echo " --lib-ml       mincamlのライブラリ(デフォルトでlib/mincaml/libmincaml.ml)"
    echo " --lib-asm      アセンブリのライブラリ(デフォルトでlib/asm/libmincaml.S)"
    echo " --boot         ブートローダー(デフォルトでlib/asm/boot.s)"
    echo " --iconst       定数汎用レジスタ(負の数は --iconst \" -1\" みたいな感じで)"
    echo " --fconst       定数浮動小数点レジスタ"
    echo " --fconst-hex   定数浮動小数点レジスタ(32bit16進数表現)"
    echo
    echo "--work-dirに以下のファイルが生成されます。"
    echo '$FILE.ml        mincamlのライブラリと結合されたmincamlソース'
    echo '$FILE.s         ${FILE}.mlをコンパイルしたアセンブリソース'
    echo '$FILE.log       コンパイラのログ'
    echo '$FILE.err       コンパイラのエラーログ'
    echo '_$FILE.s        アセンブリのライブラリとリンクしたアセンブリソース'
    echo '$FILE           アセンブラによって生成されたバイナリファイル'
    echo '$FILE.label     アセンブラによって出力されたラベルのリスト'
    echo 
    echo 'CAUTION:'
    echo '--work-dirに$FILEと同じディレクトリを指定するとエラーで落ちます。'
    exit 1
}

set -e

if [[ $1 = "--help" ]]; then
    usage
fi

if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]] && [[ -f "$1" ]]; then
    param="$1"
    shift 1
else
    echo "$0: mincaml source '$1' not found" 1>&2
    echo
    usage
fi

REPO_ROOT=`git rev-parse --show-toplevel`
SOURCE_ML=${param##*/}
SOURCE=${SOURCE_ML%.*}
WORK_DIR=${REPO_ROOT}/simulator/bin

LIB_ML=${REPO_ROOT}/lib/mincaml/libmincaml.ml

INLINE=88
ICONST="-iconst 1 -iconst -1 -iconst 2 -iconst 3 -iconst 5"
FCONST="-fconst 1 -fconst 2 -fconst 0.5"

LIB_S=${REPO_ROOT}/lib/asm/libmincaml.S
BOOT_S=${REPO_ROOT}/lib/asm/boot.s

for OPT in "$@"
do
    case "$OPT" in
        '--work-dir' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
                exit 1
            fi
            if [[ ! -d "$2" ]]; then
                echo "$0: '$2' is not directory" 1>&2
                exit 1
            fi
            WORK_DIR=`echo $2 | sed 's/\/$//'`
            shift 2
            ;;
        '--inline' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
                exit 1
            fi
            if ! expr "$2" : '[0-9]*' > /dev/null; then
                echo "$0: '$2' is not number" 1>&2
                exit 1
            fi
            INLINE="$2"
            shift 2
            ;;
        '--iconst' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
                exit 1
            fi
            if ! expr "$2" : '[0-9]*' > /dev/null; then
                echo "$0: '$2' is not number" 1>&2
                exit 1
            fi
            ICONST=${ICONST}"-iconst $2 "
            shift 2
            ;;
        '--fconst' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
                exit 1
            fi
            FCONST=${FCONST}"-fconst $2 "
            shift 2
            ;;
        '--fconst-hex' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
                exit 1
            fi
            FCONST=${FCONST}"-fconst-hex $2 "
            shift 2
            ;;
        '--lib-ml' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
                exit 1
            fi
            if [[ ! -f "$2" ]]; then
                echo "$0: '$2' not found" 1>&2
                exit 1
            fi
            LIB_ML="$2"
           shift 2
            ;;
        '--lib-asm' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
		echo
		usage
            fi
            if [[ ! -f "$2" ]]; then
                echo "$0: '$2' not found" 1>&2
                exit 1
            fi
            LIB_S="$2"
           shift 2
            ;;
        '--boot' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$0: option requires an argument" 1>&2
		echo
		usage
            fi
            if [[ ! -f "$2" ]]; then
                echo "$0: '$2' not found" 1>&2
                exit 1
            fi
            BOOT_S="$2"
            shift 2
            ;;
        -*)
            echo "$0: illegal option '$(echo $1 | sed 's/^-*//')'" 1>&2
	    echo
	    usage
            ;;
    esac
done

echo "cat ${LIB_ML} ${param} > ${WORK_DIR}/${SOURCE}.ml"
cat ${LIB_ML} ${param} > ${WORK_DIR}/${SOURCE}.ml

echo "${REPO_ROOT}/mincaml_compiler/min-caml ${WORK_DIR}/${SOURCE} -inline ${INLINE}  ${ICONST} ${FCONST}"
${REPO_ROOT}/mincaml_compiler/min-caml ${WORK_DIR}/${SOURCE} -inline ${INLINE} ${ICONST} ${FCONST}

echo "cat ${BOOT_S} ${LIB_S} ${WORK_DIR}/${SOURCE}.s > ${WORK_DIR}/_${SOURCE}.s"
cat ${BOOT_S} ${LIB_S} ${WORK_DIR}/${SOURCE}.s > ${WORK_DIR}/_${SOURCE}.s

echo "${REPO_ROOT}/simulator/bin/assembler -f ${WORK_DIR}/${SOURCE} -i ${WORK_DIR}/_${SOURCE}.s -f"
${REPO_ROOT}/simulator/bin/assembler -f ${WORK_DIR}/${SOURCE} -i ${WORK_DIR}/_${SOURCE}.s -l

FSIZE=`wc -c ${WORK_DIR}/${SOURCE} | cut -d ' ' -f1 -`
if [ $FSIZE -lt 131000 ]; then
	echo -e "The size of binary : ${FSIZE}"
else
	echo -e "\e[31mThe size of binary is too large : ${FSIZE}\e[m"
fi

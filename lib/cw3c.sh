#!/bin/bash

usage() {
    echo "Usage: $0 FILE [OPTIONS] "
    echo
    echo "FILE:"
    echo "コンパイルしたいmincamlソース"
    echo
    echo "Options:"
    echo " --help     ヘルプ"
    echo " --work-dir 実行ファイル及び作業用ファイルが生成されるディレクトリ(デフォルトでsimulator/bin)"
    echo " --inline   コンパイラのインライン展開の深さ(デフォルトで0)"
    echo " --lib-ml   mincamlのライブラリ(デフォルトでlib/mincaml/libmincaml.ml)"
    echo " --lib-asm  アセンブリのライブラリ(デフォルトでlib/asm/libmincaml.S)"
    echo " --boot     ブートローダー(デフォルトでlib/asm/boot.s)"
    echo
    echo "--work-dirに以下のファイルが生成されます。"
    echo '$FILE.ml    mincamlのライブラリと結合されたmincamlソース'
    echo '$FILE.s     ${FILE}.mlをコンパイルしたアセンブリソース'
    echo '$FILE.log   コンパイラのログ'
    echo '$FILE.err   コンパイラのエラーログ'
    echo '_$FILE.s    アセンブリのライブラリとリンクしたアセンブリソース'
    echo '$FILE       アセンブラによって生成されたバイナリファイル'
    echo '$FILE.label アセンブラによって出力されたラベルのリスト'
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

INLINE=0

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

echo "${REPO_ROOT}/mincaml_compiler/min-caml ${WORK_DIR}/${SOURCE} -inline ${INLINE} 1> ${WORK_DIR}/${SOURCE}.log 2> ${WORK_DIR}/${SOURCE}.err"
${REPO_ROOT}/mincaml_compiler/min-caml ${WORK_DIR}/${SOURCE} -inline ${INLINE} 1> ${WORK_DIR}/${SOURCE}.log 2> ${WORK_DIR}/${SOURCE}.err

echo "cat ${BOOT_S} ${LIB_S} ${WORK_DIR}/${SOURCE}.s > ${WORK_DIR}/_${SOURCE}.s"
cat ${BOOT_S} ${LIB_S} ${WORK_DIR}/${SOURCE}.s > ${WORK_DIR}/_${SOURCE}.s

echo "${REPO_ROOT}/simulator/bin/assembler -f ${WORK_DIR}/${SOURCE} -i ${WORK_DIR}/_${SOURCE}.s"
${REPO_ROOT}/simulator/bin/assembler -f ${WORK_DIR}/${SOURCE} -i ${WORK_DIR}/_${SOURCE}.s 

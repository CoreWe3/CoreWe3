#!/bin/bash

# FPGAにSSH経由で書き込み、その後の入出力を行うためのスクリプトです。
# $ ./fpga.sh [-h] [-i input_file] [-l log_file] bit_file
# bit_file には、ISEなどで生成した*.bitを指定してください。
# FPGAにbit_fileを書き込んだ後、input_fileをRS232Cを通して送ります。
# 入出力は標準入出力で行うことができます。
# -i オプションがある場合、まず最初にそのファイルを送ります。
# -i オプションを用いて複数の入力ファイルを指定できますが、
# 各入力ファイルの前に"-i "をつけてください。指定した順番に入力を行います。
# -l オプションが指定された場合、log_fileに出力を記録します。
# -h オプションがある場合、標準出力へ16進数で表示されます。

SERVER=fpga

CMD=`basename $0`
HELP="
Usage: $CMD [-bl] [-i input_filename] [-l log_filename] bit_file\n
\t -h                \t\t\t output in hexadecimal.\n
\t -i input_filename \t  input to device.\n
\t -l log_filename   \t  log to log_filename."

while getopts hi:l: OPT
do
    case $OPT in
	"h" ) FLAG_H="-h";;
	"i" ) FLAG_I="-i"; INPUT="$OPTARG";;
	"l" ) FLAG_L="-l"; LOG="$OPTARG";;
	*   ) echo -e $HELP; exit 1 ;;
    esac
done

ARGS=$@

shift `expr $OPTIND - 1`
BIT=$1

if [ -z $BIT ]
then
    echo -e $HELP; exit 1
fi

if ! scp $BIT $SERVER:~/top.bit
then
    echo "$CMD: The device may be in use. Please try lator."; exit 1
fi

if [ $FLAG_I ]
then
    scp $INPUT $SERVER:~/ || exit 1
fi

ssh $SERVER ./config_run.sh $FLAG_H $FLAG_I `basename $INPUT` $FLAG_L $LOG

if [ $FLAG_L ]
then
    scp $SERVER:~/$LOG .
fi

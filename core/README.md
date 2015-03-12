# CoreWe3 コア

## 実装（現在）

パイプラインは7段

| Stages                                              |
|-----------------------------------------------------|
| Fetch instruction                                   |
| Decode and read register                            |
| Execute integer and floating point arithmetic       |
| Memory Access and execute floating point arithmetic |
| Memory Read and execute floating point arithmetic   |
| Floating point arithmetic                           |
| Write register                                      |

毎クロック一つの命令を実行する。同時実行フラグ(@)が立つのは以下に示したMultiOpのみ。
同時実行フラグが立った命令があり、リソースが余っている場合、同時に実行される(予定)。
latencyは各命令が実行されてからその結果を読み出せるまでの時間
(0 -> 次の命令, 1 -> 次の次の命令、…)。
現在はデータハザードが検出されストールする。
(latency のあるうちに読みだそうとすると、NOPが挿入される。)
各命令のlatency と同時実行できるかどうかは以下の通り。

| Instruction | Latency | MultiOp |
|-------------|---------|---------|
| LD          | 1 ( *1) | N       |
| ST          | - ( *1) | N       |
| FLD         | 1 ( *1) | N       |
| FST         | - ( *1) | N       |
| ITOF        | 3       | Y       |
| FTOI        | 3       | Y       |
| ADD         | 0       | Y       |
| SUB         | 0       | Y       |
| ADDI        | 0       | Y       |
| SHL         | 0       | Y       |
| SHR         | 0       | Y       |
| SHLI        | 0       | Y       |
| SHRI        | 0       | Y       |
| LDIH        | 0       | Y       |
| FADD        | 3       | Y       |
| FSUB        | 3       | Y       |
| FMUL        | 3       | Y       |
| FINV        | 3       | Y       |
| FSQRT       | 3       | Y       |
| FABS        | 0       | Y       |
| FCMP        | 1       | Y       |
| FLDI        | 0       | Y       |
| J           | - ( *2) | N       |
| JEQ         | - ( *2) | N       |
| JLE         | - ( *2) | N       |
| JLT         | - ( *2) | N       |
| JSUB        | 0 ( *2) | N       |
| RET         | - ( *2) | N       |

(*1)メモリアクセスによるストールは後述
(*2)ジャンプによるストールは後述

* メモリー

ブロックRAM(0xfe000 ~ 0xffffe) をコード領域として利用することで、
ノイマン型っぽくなっている。pcの実際に指すアドレスはpc+0xff000となる。
現在、0xff000~0xff013はブートローダが使用し、
0xff014以降に実行コードが書き込まれたあとそこにジャンプする。

キャッシュはダイレクトマップ方式で1ライン4byteで256ライン存在する。

メモリアクセスでストールする場合、パイプライン全体が停止する。
メモリアクセスのオーバーヘッドは以下。

| Load                  |     |
|-----------------------|-----|
| BRAM(cache hit)       | 0   |
| SRAM(cache miss)      | 3   |
| IO                    | 1~  |

| Store                 |     |
|-----------------------|-----|
| BRAM(cache hit)       | 0   |
| SRAM(cache miss)      | 0   |
| IO                    | 1~  |


* 分岐予測

分岐フラグを用いた静的分岐予測を実装。
分岐命令とジャンプ命令によるストールは以下の通り。

分岐命令

| JEQ/JLE/JLT            | Stall Clock(s) |
|------------------------|----------------|
| Predicate as Taken     | 1              |
| Predicate as Not Taken | 0              |
| Fail predication       | 3              |


ジャンプ命令

| Instruction | Stall clock(s) |
|-------------|----------------|
| J           | 1              |
| JSUB        | 1              |
| RET         | 3              |

* IO

LD STを用いて入出力をすると、下位8bitのみを入出力する。
FLD FSTを用いると、4バイト分リトルエンディアンで入出力する。

* 実装済み命令

LD ST FLD FST ITOF FTOI ADD SUB ADDI SHR SHL SHLI SHRI LDIH
FADD FSUB FMUL FABS FINV FSQRT FCMP FLDI J JEQ JLE JLT JSUB RET


## TODO

* 周波数向上

* キャッシュのラインサイズ増加

* 2way-set associative キャッシュ

* 動的分岐予測 or 並列化 or EPIC化

* パイプライン深化

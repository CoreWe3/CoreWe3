# CoreWe3 コア

## 実装（現在）

パイプラインは7段
並列化はまだ

| stages                                              |
|-----------------------------------------------------|
| fetch instruction                                   |
| decode and read register                            |
| execute integer and floating point arithmetic       |
| memory access and execute floating point arithmetic |
| memory wait and execute floating point arithmetic   |
| memory read and floating point arithmetic           |
| write register                                      |

毎クロック一つの命令を実行する。同時実行フラグ(@)が立つのはMultiOpのみ。
同時実行フラグが立った命令があり、リソースが余っている場合、同時に実行される。
latencyは各命令が実行されてからその結果を読み出せるまでの時間
(0 -> 次の命令, 1 -> 次の次の命令、…)。
現在はデータハザードが検出されストールする。
各命令のlatency と同時実行できるかどうかは以下。

| Instruction | Latency | MultiOp |
|-------------|---------|---------|
| LD          | 2       | N       |
| ST          | -       | N       |
| FLD         | 2       | N       |
| FST         | -       | N       |
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
| FCMP        | 0       | Y       |
| FLDI        | 0       | Y       |
| J           | -       | N       |
| JEQ         | -       | N       |
| JLE         | -       | N       |
| JLT         | -       | N       |
| JSUB        | 0       | N       |
| RET         | -       | N       |


メモリアクセスでストールする場合、パイプライン全体が停止する。
メモリアクセスのオーバーヘッドは以下。

| Load                  |     |
|-----------------------|-----|
| BRAM(キャッシュヒット) | 0   |
| SRAM(キャッシュミス)   | 3   |
| IO                    | 1~  |

| Store                 |     |
|-----------------------|-----|
| BRAM(キャッシュヒット) | 0   |
| SRAM(キャッシュミス)   | 0   |
| IO                    | 1~  |


Not taken(常に分岐しない方向）に投機的実行。
分岐した直後、3clkの間バブルが入る。

* メモリー

ブロックRAM(0xfe000 ~ 0xffffe) をコード領域として利用することで、
ノイマン型っぽくなっている。pcの実際に指すアドレスはpc+0xff000となる。
現在、0xff000~0xff013はブートローダが使用し、
0xff014以降に実行コードが書き込まれたあとそこにジャンプする。

* IO

LD STを用いて入出力をすると、下位8bitのみを入出力する。
FLD FSTを用いると、4バイト分リトルエンディアンで入出力する。

* 実装済み命令

LD ST FLD FST (ITOF) (FTOI) ADD SUB ADDI SHR SHL SHLI SHRI LDIH
FADD FSUB FMUL FABS FINV FCMP FLDI J JEQ JLE JLT JSUB RET

* 未実装命令

FSQRT

## TODO

* リファクタリング

* FPU組み込み

* フォワーディング整理

* 分岐ロス減少（decodeで分岐を確定）

* 静的分岐予測

* 動的分岐予測 or 並列化 or EPIC化

* パイプライン深化

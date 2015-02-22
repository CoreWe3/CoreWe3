# CoreWe3 コア

## 実装（現在）

パイプラインは6段

| stages                                              |
|-----------------------------------------------------|
| fetch instruction                                   |
| decode and read register                            |
| execute integer and floating point arithmetic       |
| memory access and execute floating point arithmetic |
| memory wait and execute floating point arithmetic   |
| write register                                      |

* ストール

メモリアクセスのある場合、パイプライン全体が停止する。
データハザードが検出された場合、executeまでに値がわかるものについてはフォワーディングし、
そうでなければ、値が確定するまでバブルが入る。分岐が実行された直後、3段分のバブルが入る。

* メモリー

ブロックRAM(0xff000 ~ 0xffffe) をコード領域として利用することで、ノイマン型っぽく
なっている。pcの実際に指すアドレスはpc+0xff000となる。
現在、0xff000~0xff013はブートローダが使用し、0xff014以降に実行コードが書き込まれたあと
そこにジャンプする。

* IO

LD STを用いて入出力をすると、下位8bitのみを入出力する。

* 実装済み命令

LD ST ADD SUB ADDI SHR SHL SHLI SHRI LDIH FADD FMUL FLDI J JEQ JLE JLT JSUB RET

## TODO

* float IO

* FPU組み込み

* FPUストール

* 動的分岐予測

* フォワーディングをexecuteステージで？

* パイプライン深化

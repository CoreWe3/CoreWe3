# CoreWe3 コア

## 実装（現在）

パイプラインは7段

| stages                                              |
|-----------------------------------------------------|
| fetch instruction                                   |
| decode and read register                            |
| execute integer and floating point arithmetic       |
| memory access and execute floating point arithmetic |
| memory wait and execute floating point arithmetic   |
| memory read and floating point arithmetic           |
| write register                                      |

* ストール

メモリアクセスでストールする場合、パイプライン全体が停止する。
データハザードが検出された場合、executeまでに値がわかるものについてはフォワーディングし、
そうでなければ、値が確定するまでバブルが入る。また、分岐した直後、3clkの間バブルが入る。

* メモリー

ブロックRAM(0xfe000 ~ 0xffffe) をコード領域として利用することで、
ノイマン型っぽくなっている。pcの実際に指すアドレスはpc+0xff000となる。
現在、0xff000~0xff013はブートローダが使用し、
0xff014以降に実行コードが書き込まれたあとそこにジャンプする。
キャッシュはダイレクトマップ方式で256ワード分キャッシュされている。
キャッシュミスは読み込み時に2clkのオーバーヘッドがある。

* IO

LD STを用いて入出力をすると、下位8bitのみを入出力する。
FLD FSTを用いると、4バイト分リトルエンディアンで入出力する。

* 実装済み命令

LD ST FLD FST (FTOI) ADD SUB ADDI SHR SHL SHLI SHRI LDIH
FADD FSUB FMUL FABS FINV FCMP FLDI J JEQ JLE JLT JSUB RET

* 未実装命令

ITOF FSQRT

## TODO

* リファクタリング

* FPU組み込み

* フォワーディング整理

* 分岐ロス減少（decodeで分岐を確定）

* 静的分岐予測

* 動的分岐予測 or 並列化

* パイプライン深化

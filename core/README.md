# CoreWe3 コア

## 実装（現在）

パイプラインは五段
	fetch instruction ->
	decode and read register ->
	execute ->
	memory access and execute floating point arithmetic ->
	write register

メモリアクセスはストールする。executeで結果がわかるものについてはフォワーディングする。
分岐する場合、3clkの遅延、STは1clkの遅延が生じる。
ブロックRAM(0xff000 ~ 0xffffe) をコード領域として利用。
pcの実際に指すアドレスはpc+0xff000。

* 実装済み命令
LD ST ADD SUB ADDI SHLI SHRI LDIH J JEQ JLE JLT JSUB RET

## TODO

* float IO

* FPU組み込み

* キャッシュ

* 動的分岐予測

* パイプライン深化

* FPUストール

* フォワーディングをexecuteステージで？
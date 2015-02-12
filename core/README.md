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

* 実装済み命令
LD ST ADD SUB ADDI LDIH J JEQ JLE JLT JSUB RET

## TODO

* bootloader

* float IO

* FPU組み込み

* 動的分岐予測

* キャッシュ

* パイプライン深化

FPUストール

* フォワーディングをexecuteステージで？
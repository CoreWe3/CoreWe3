# CoreWe3 コア

## 実装（現在）

パイプラインは五段
	fetch instruction ->
	decode and read register ->
	execute ->
	memory access and execute floating point arithmetic ->
	write register

メモリアクセスはストールする。executeで結果がわかるものについてはフォワーディングする。

* 実装済み命令
ST ADD SUB ADDI

## TODO

* 分岐命令（静的分岐予測）

* FPU組み込み

* 動的分岐予測

* キャッシュ

* パイプライン深化

FPUストール

* フォワーディングをexecuteステージで？
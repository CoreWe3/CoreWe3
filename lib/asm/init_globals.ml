(* sed -i -e "s/^print_global.*/(\* & *\)/" asm/init_globals.ml  *)
(* sed -e "s/^(\\* \(print_global.*\\) \*\)$/\1/" asm/init_globals.ml *)


(* オブジェクトの個数 *)
let n_objects = create_array 1 0
in
print_global0 n_objects;

(* オブジェクトのデータを入れるベクトル（最大60個）*)
let objects = 
  let dummy = create_array 0 0.0 in
  create_array 60 (0, 0, 0, 0, dummy, dummy, false, dummy, dummy, dummy, dummy)
in
print_global1 objects;

(* Screen の中心座標 *)
let screen = create_array 3 0.0
in
print_global2 screen;

(* 視点の座標 *)
let viewpoint = create_array 3 0.0
in
print_global3 viewpoint;

(* 光源方向ベクトル (単位ベクトル) *)
let light = create_array 3 0.0
in
print_global4 light;

(* 鏡面ハイライト強度 (標準=255) *)
let beam = create_array 1 255.0
in
print_global5 beam;

(* AND ネットワークを保持 *)
let and_net = create_array 50 (create_array 1 (-1))
in
print_global6 and_net;
(* OR ネットワークを保持 *)
let or_net = create_array 1 (create_array 1 (and_net.(0)))
in
print_global7 or_net;

(* 以下、交差判定ルーチンの返り値格納用 *)
(* solver の交点 の t の値 *)
let solver_dist = create_array 1 0.0
in
print_global8 solver_dist;
(* 交点の直方体表面での方向 *)
let intsec_rectside = create_array 1 0
in
print_global9 intsec_rectside;
(* 発見した交点の最小の t *)
let tmin = create_array 1 (1000000000.0)
in
print_global10 tmin;
(* 交点の座標 *)
let intersection_point = create_array 3 0.0
in
print_global11 intersection_point;
(* 衝突したオブジェクト番号 *)
let intersected_object_id = create_array 1 0
in
print_global12 intersected_object_id;
(* 法線ベクトル *)
let nvector = create_array 3 0.0
in
print_global13 nvector;
(* 交点の色 *)
let texture_color = create_array 3 0.0
in
print_global14 texture_color;

(* 計算中の間接受光強度を保持 *)
let diffuse_ray = create_array 3 0.0
in
print_global15 diffuse_ray;
(* スクリーン上の点の明るさ *)
let rgb = create_array 3 0.0
in
print_global16 rgb;

(* 画像サイズ *)
let image_size = create_array 2 0
in
print_global17 image_size;
(* 画像の中心 = 画像サイズの半分 *)
let image_center = create_array 2 0
in
print_global18 image_center;
(* 3次元上のピクセル間隔 *)
let scan_pitch = create_array 1 0.0
in
print_global19 scan_pitch;

(* judge_intersectionに与える光線始点 *)
let startp = create_array 3 0.0
in
print_global20 startp;
(* judge_intersection_fastに与える光線始点 *)
let startp_fast = create_array 3 0.0
in
print_global21 startp_fast;

(* 画面上のx,y,z軸の3次元空間上の方向 *)
let screenx_dir = create_array 3 0.0
in
print_global22 screenx_dir;
let screeny_dir = create_array 3 0.0
in
print_global23 screeny_dir;
let screenz_dir = create_array 3 0.0
in
print_global24 screenz_dir;

(* 直接光追跡で使う光方向ベクトル *)
let ptrace_dirvec  = create_array 3 0.0
in
print_global25 ptrace_dirvec;

(* 間接光サンプリングに使う方向ベクトル *)
let dirvecs = 
  let dummyf = create_array 0 0.0 in
  let dummyff = create_array 0 dummyf in
  let dummy_vs = create_array 0 (dummyf, dummyff) in
  create_array 5 dummy_vs
in
print_global26 dirvecs;

(* 光源光の前処理済み方向ベクトル *)
let light_dirvec =
  let dummyf2 = create_array 0 0.0 in
  let v3 = create_array 3 0.0 in
  let consts = create_array 60 dummyf2 in
  (v3, consts)
in
print_global27 light_dirvec;

(* 鏡平面の反射情報 *)
let reflections =
  let dummyf3 = create_array 0 0.0 in
  let dummyff3 = create_array 0 dummyf3 in
  let dummydv = (dummyf3, dummyff3) in
  create_array 180 (0, dummydv, 0.0)
in
print_global28 reflections;

(* reflectionsの有効な要素数 *) 
let n_reflections = create_array 1 0
in
print_global29 n_reflections;
()

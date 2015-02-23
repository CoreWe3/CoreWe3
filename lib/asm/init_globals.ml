let globals = create_array 30 0 
in

(* ���֥������ȤθĿ� *)
let n_objects = create_array 1 0
in
save_global0 globals 0 n_objects;

(* ���֥������ȤΥǡ����������٥��ȥ�ʺ���60�ġ�*)
let objects = 
  let dummy = create_array 0 0.0 in
  create_array 60 (0, 0, 0, 0, dummy, dummy, false, dummy, dummy, dummy, dummy)
in
save_global1 globals 1 objects;

(* Screen ���濴��ɸ *)
let screen = create_array 3 0.0
in
save_global2 globals 2 screen;

(* �����κ�ɸ *)
let viewpoint = create_array 3 0.0
in
save_global3 globals 3 viewpoint;

(* ���������٥��ȥ� (ñ�̥٥��ȥ�) *)
let light = create_array 3 0.0
in
save_global4 globals 4 light;

(* ���̥ϥ��饤�ȶ��� (ɸ��=255) *)
let beam = create_array 1 255.0
in
save_global5 globals 5 beam;

(* AND �ͥåȥ�����ݻ� *)
let and_net = create_array 50 (create_array 1 (-1))
in
save_global6 globals 6 and_net;
(* OR �ͥåȥ�����ݻ� *)
let or_net = create_array 1 (create_array 1 (and_net.(0)))
in
save_global7 globals 7 or_net;

(* �ʲ�����Ƚ��롼������֤��ͳ�Ǽ�� *)
(* solver �θ��� �� t ���� *)
let solver_dist = create_array 1 0.0
in
save_global8 globals 8 solver_dist;
(* ������ľ����ɽ�̤Ǥ����� *)
let intsec_rectside = create_array 1 0
in
save_global9 globals 9 intsec_rectside;
(* ȯ�����������κǾ��� t *)
let tmin = create_array 1 (1000000000.0)
in
save_global10 globals 10 tmin;
(* �����κ�ɸ *)
let intersection_point = create_array 3 0.0
in
save_global11 globals 11 intersection_point;
(* ���ͤ������֥��������ֹ� *)
let intersected_object_id = create_array 1 0
in
save_global12 globals 12 intersected_object_id;
(* ˡ���٥��ȥ� *)
let nvector = create_array 3 0.0
in
save_global13 globals 13 nvector;
(* �����ο� *)
let texture_color = create_array 3 0.0
in
save_global14 globals 14 texture_color;

(* �׻���δ��ܼ������٤��ݻ� *)
let diffuse_ray = create_array 3 0.0
in
save_global15 globals 15 diffuse_ray;
(* �����꡼�����������뤵 *)
let rgb = create_array 3 0.0
in
save_global16 globals 16 rgb;

(* ���������� *)
let image_size = create_array 2 0
in
save_global17 globals 17 image_size;
(* �������濴 = ������������Ⱦʬ *)
let image_center = create_array 2 0
in
save_global18 globals 18 image_center;
(* 3������Υԥ�����ֳ� *)
let scan_pitch = create_array 1 0.0
in
save_global19 globals 19 scan_pitch;

(* judge_intersection��Ϳ����������� *)
let startp = create_array 3 0.0
in
save_global20 globals 20 startp;
(* judge_intersection_fast��Ϳ����������� *)
let startp_fast = create_array 3 0.0
in
save_global21 globals 21 startp_fast;

(* ���̾��x,y,z����3�������־������ *)
let screenx_dir = create_array 3 0.0
in
save_global22 globals 22 screenx_dir;
let screeny_dir = create_array 3 0.0
in
save_global23 globals 23 screeny_dir;
let screenz_dir = create_array 3 0.0
in
save_global24 globals 24 screenz_dir;

(* ľ�ܸ����פǻȤ��������٥��ȥ� *)
let ptrace_dirvec  = create_array 3 0.0
in
save_global25 globals 25 ptrace_dirvec;

(* ���ܸ�����ץ�󥰤˻Ȥ������٥��ȥ� *)
let dirvecs = 
  let dummyf = create_array 0 0.0 in
  let dummyff = create_array 0 dummyf in
  let dummy_vs = create_array 0 (dummyf, dummyff) in
  create_array 5 dummy_vs
in
save_global26 globals 26 dirvecs;

(* ���������������Ѥ������٥��ȥ� *)
let light_dirvec =
  let dummyf2 = create_array 0 0.0 in
  let v3 = create_array 3 0.0 in
  let consts = create_array 60 dummyf2 in
  (v3, consts)
in
save_global27 globals 27 light_dirvec;

(* ��ʿ�̤�ȿ�;��� *)
let reflections =
  let dummyf3 = create_array 0 0.0 in
  let dummyff3 = create_array 0 dummyf3 in
  let dummydv = (dummyf3, dummyff3) in
  create_array 180 (0, dummydv, 0.0)
in
save_global28 globals 28 reflections;

(* reflections��ͭ�������ǿ� *) 
let n_reflections = create_array 1 0
in
save_global29 globals 29 n_reflections

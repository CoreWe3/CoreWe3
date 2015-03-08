#include <vector>
#include <string>
#include <iostream>
#include <fstream>
using namespace std;

string globals[] = {
    "n_objects",
    "objects",
    "screen",
    "viewpoint",
    "light",
    "beam",
    "and_net",
    "or_net",
    "solver_dist",
    "intsec_rectside",
    "tmin",
    "intersection_point",
    "intersected_object_id",
    "nvector",
    "texture_color",
    "diffuse_ray",
    "rgb",
    "image_size",
    "image_center",
    "scan_pitch",
    "startp",
    "startp_fast",
    "screenx_dir",
    "screeny_dir",
    "screenz_dir",
    "ptrace_dirvec",
    "dirvecs",
    "light_dirvec",
    "reflections",
    "n_reflections"};

int main(){
    ifstream dump;
    dump.open("init_globals.dump");
    if(dump.fail()){
	cerr << "Can't open file" << endl;
	return 1;
    }
    
    int tmp;
    int i = 0;
    while(dump.read(reinterpret_cast<char*>(&tmp), sizeof(tmp))){
	cout << ".min_caml_" << globals[i] << " " << tmp << endl;
	i++;
    }
    return 0;
}

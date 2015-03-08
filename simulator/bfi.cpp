#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
using namespace std;

#include <getopt.h>
#include "isa_class.h"
#include "isa.h"

int main(int argc, char* argv[]){

	//Option Handler
	char result;
	char *filename = nullptr, *outputfilename = nullptr, *profilefilename = nullptr;
	while((result=getopt(argc,argv,"f:o:p:"))!=-1){
		switch(result){
			case 'f': // Input Binary File
				filename = optarg;
				break;
			case 'o':
				outputfilename = optarg;
				break;
			case 'p': // IO-Output
				profilefilename = optarg;
				break;
			case ':':
				cerr << result << " needs value" << endl;
				return 1;
			case '?':
				cerr << "unknown option" << endl;
				return 1;
		}
	}

	//Read Binary File
	ifstream fin;
	if(filename != nullptr){
		fin.open(filename, ios::in|ios::binary);
		if(fin.fail()){
			cerr << "Can't open file : " << filename << endl;
			return 1;
		}
	}else{
		cerr << "No input file." << endl;
	}
	vector<uint32_t> instructions;
	uint32_t tmp;
	while(fin.read(reinterpret_cast<char*>(&tmp),sizeof(tmp))){
		instructions.push_back(tmp);
	}

	//Read Profile File
	ifstream fin2;
	if(profilefilename != nullptr){
		fin2.open(profilefilename, ios::in|ios::binary);
		if(fin2.fail()){
			cerr << "Can't open file : " << profilefilename << endl;
			return 1;
		}
	}else{
		cerr << "No input file." << endl;
	}
	vector<float> branchprofile;
	float ftmp;
	while(fin2.read(reinterpret_cast<char*>(&ftmp),sizeof(ftmp))){
		branchprofile.push_back(ftmp);
	}

	//Error Detection
	if(instructions.size()!=branchprofile.size()){
		cerr << "Invalid Profile File" << endl;
		return 1;
	}

	//Main
	unsigned long pc = 0;
	while(pc < instructions.size()){
		FORMAT fm;
		fm.data = instructions[pc];
		switch(fm.J.op){
			case JEQ:
			case JLE:
			case JLT:
				if(branchprofile[pc]>0){
					fm.J.br = 1;
					instructions[pc] = fm.data;
				}
				break;
			default:
				break;
		}
		pc++;
	}

	//Output New Assembly
	ofstream fout;
	if(outputfilename!=nullptr){
		fout.open(outputfilename, ios::binary);
		if(fout.fail()){
			cerr << "Can't open file : " << outputfilename << endl;
			return 1;
		}
		for(auto x : instructions){
			fout.write((char *)&x,sizeof(x));
		}
	}else{
		cerr << "No Output File" << endl;
		return 1;
	}

	return 0;
}

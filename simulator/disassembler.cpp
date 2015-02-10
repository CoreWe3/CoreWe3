#include <iostream>
#include <fstream>
#include <sstream>
#include <list>
#include <string>
using namespace std;

#include <getopt.h>
#include "isa_class.h"

string int2hexstring(unsigned int i){
	stringstream stream;
	stream << hex << "0x" << i;
	return stream.str();
}

int main(int argc, char* argv[]){

	//Option Handler
	char result;
	char *filename = nullptr, *outputfilename = nullptr;
	while((result=getopt(argc,argv,"f:o:"))!=-1){
		switch(result){
			case 'o':
				outputfilename = optarg;
				break;
			case 'f':
				filename = optarg;
				break;
			case ':':
				cerr << result << " needs value" << endl;
				return 1;
			case '?':
				cerr << "unknown option" << endl;
				return 1;
		}
	}

	//Initilaize
	ifstream fin;
	if(filename != nullptr){
		fin.open(filename, ios::in|ios::binary);
		if(fin.fail()){
			cerr << "Can't open file" << endl;
			return 1;
		}
	}else{
		cerr << "No input file." << endl;
	}

	//Read Data
	list<uint32_t> instructions;
	uint32_t ins;
	while(fin.read(reinterpret_cast<char*>(&ins),sizeof(ins))){
		instructions.push_back(ins);
	}

	//Disassembling
	list<string> results;
	for(auto el : instructions){
		FORMAT fm;
		fm.data = el;
		string str = "";
		switch(fm.J.op){
			// no regs and imm
			case RET:
				str += ISA::isa2name(fm.J.op);
				break;

				// 1 imm
			case J:
			case JEQ:
			case JLE:
			case JLT:
			case JSUB:
				str += ISA::isa2name(fm.J.op);
				str += "\t";
				str += int2hexstring(fm.J.cx);
				break;

				// 1 greg, 1 imm
			case LDIH:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::greg2name(fm.L.ra);
				str += "\t";
				str += int2hexstring(fm.L.cx);
				break;

				// 1 freg, 1 imm
			case FLDIL:
			case FLDIH:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::freg2name(fm.L.ra);
				str += "\t";
				str += int2hexstring(fm.L.cx);
				break;

				// 1 freg, 1 greg
			case ITOF:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::freg2name(fm.L.ra);
				str += "\t";
				str += ISA::greg2name(fm.L.rb);
				break;

				// 1 greg, 1 freg
			case FTOI:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::greg2name(fm.L.ra);
				str += "\t";
				str += ISA::freg2name(fm.L.rb);
				break;

				// 2 freg
			case FSQRT:
			case FABS:
			case FCMP:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::freg2name(fm.L.ra);
				str += "\t";
				str += ISA::freg2name(fm.L.rb);
				break;

				// 2 gregs, 1 imm
			case LD:
			case ST:
			case ADDI:
			case SHLI:
			case SHRI:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::greg2name(fm.L.ra);
				str += "\t";
				str += ISA::greg2name(fm.L.rb);
				str += "\t";
				str += int2hexstring(fm.L.cx);
				break;

				// 1 freg, 1greg, 1 imm
			case FLD:
			case FST:
				str += ISA::isa2name(fm.L.op);
				str += "\t";
				str += ISA::freg2name(fm.L.ra);
				str += "\t";
				str += ISA::greg2name(fm.L.rb);
				str += "\t";
				str += int2hexstring(fm.L.cx);
				break;

				// 3 gregs
			case ADD:
			case SUB:
			case SHL:
			case SHR:
				str += ISA::isa2name(fm.A.op);
				str += "\t";
				str += ISA::greg2name(fm.A.ra);
				str += "\t";
				str += ISA::greg2name(fm.A.rb);
				str += "\t";
				str += ISA::greg2name(fm.A.rc);
				break;

				// 3 fregs
			case FADD:
			case FSUB:
			case FMUL:
			case FDIV:
				str += ISA::isa2name(fm.A.op);
				str += "\t";
				str += ISA::freg2name(fm.A.ra);
				str += "\t";
				str += ISA::freg2name(fm.A.rb);
				str += "\t";
				str += ISA::freg2name(fm.A.rc);
				break;

			default:
				cerr << "This disassembler has bug!" << endl;
				exit(1);
		}
		results.push_back(str);
	}
	
	//Output Assembly File
	ostream *dout = &cout;
	ofstream fout;
	if(outputfilename != nullptr){
		fout.open(outputfilename);
		if(fout.fail()){
			cerr << "Can't open file : " << outputfilename << endl;
			return 1;
		}
		dout = &fout;
	}
	for(auto x : results){
		(*dout) << x << endl;
	}

	return 0;
}


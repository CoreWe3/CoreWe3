#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
using namespace std;

#include <getopt.h>
#include "isa_class.h"
#include "isa.h"
#include "fpu.h"

string int2hexstring(unsigned int i){
	stringstream stream;
	stream << hex << i;
	return stream.str();
}

int main(int argc, char* argv[]){

	//Option Handler
	char result;
	long long int breakpoint = -1;
	long long int limit = -1;
	char *filename = nullptr, *io_outputfilename = nullptr, *io_inputfilename = nullptr, *ramfilename = nullptr, *outputramfilename = nullptr;
	bool branchprofile_flag = false;
	while((result=getopt(argc,argv,"f:i:o:r:d:l:b:p"))!=-1){
		switch(result){
			case 'f': // Input Binary File
				filename = optarg;
				break;
			case 'o': // IO-Output
				io_outputfilename = optarg;
				break;
			case 'i': // IO-Input
				io_inputfilename = optarg;
				break;
			case 'r': // RAM input
				ramfilename = optarg;
				break;
			case 'd': // RAM dump
				outputramfilename = optarg;
				break;
			case 'l': // Instruction Limit
				limit = stoul(optarg, nullptr, 0);
				break;
			case 'b': // Break Point
				breakpoint = stoul(optarg, nullptr, 0);
				break;
			case 'p': // Make Profile
				branchprofile_flag = true;
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
			cerr << "Can't open file" << endl;
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

	//Initilaize Branch Profile
	vector<int> branchprofile(instructions.size());

	//Initilaize RAM
	vector<uint32_t> ram(RAMSIZE);
	if(ramfilename != nullptr){
		fin.open(filename, ios::in|ios::binary);
		if(fin.fail()){
			cerr << "Can't open file" << endl;
			return 1;
		}
		int c = 0;
		while(fin.read(reinterpret_cast<char*>(&tmp),sizeof(tmp)) && c < RAMSIZE){
			ram[c] = tmp;
			c++;
		}
	}else{
		cerr << "RAM is initilaized with zero." << endl;
	}

	//Initilaize IO
	istream *input;
	ifstream fileinput;
	if(io_inputfilename != nullptr){
		fileinput.open(io_inputfilename, ios::binary);
		if(fileinput.fail()){
			cerr << "Can't open file : " << io_inputfilename << endl;
			return 1;
		}
		input = &fileinput;
	}else{
		cerr << "IO input from stdin." << endl;
		input = &cin;
	}

	ostream *output;
	ofstream fileoutput;
	if(io_outputfilename != nullptr){
		fileoutput.open(io_outputfilename, ios::binary);
		if(fileoutput.fail()){
			cerr << "Can't open file : " << io_outputfilename << endl;
			return 1;
		}
		output = &fileoutput;
	}else{
		cerr << "IO output to stdout." << endl;
		output = &cout;
	}

	//Initilaize REG and PC
	vector<REG> greg(GREGNAMES.size());
	vector<REG> freg(FREGNAMES.size());
	unsigned int pc=0;


	//Main
	unsigned long counter = 0;
	map<string,unsigned long> profile;
	for(auto el : INAMES){
		profile[el.first] = 0;
	}

	while(pc < instructions.size()){
		if(pc == breakpoint){
			//Print Reg
			cerr << "== counter : " << counter << endl;
			for(int i=0;i<greg.size();i++){
				cerr << ISA::greg2name(i) << ":" << hex << "0x" << greg[i].r << dec << "(" << greg[i].d  << ")" << " ";
			}
			cerr << endl;
			for(int i=0;i<freg.size();i++){
				cerr << ISA::freg2name(i) << ":" << hex << "0x" << freg[i].r << dec << "(" << freg[i].f << ")" <<  " ";
			}
			cerr << endl;
		}
		if(counter == limit){
			cerr << "Stop by Instruction Limit." << endl;
			goto END_MAIN;
		}

		FORMAT fm;
		fm.data = instructions[pc];
		profile[ISA::isa2name(fm.J.op)]++;
		switch(fm.J.op){
			// no regs and imm
			case RET:
				pc = greg[31].u;
				break;

				// 1 imm
			case J:
				if(fm.J.cx==0){
					cerr << "Detect Halt." << endl;
					goto END_MAIN;
				}
				pc += fm.J.cx;
				break;

			case JEQ:
				if(greg[30].d == 0){
					branchprofile[pc]+=1;
					pc += fm.J.cx;
				}else{
					branchprofile[pc]-=1;
					pc += 1;
				}
				break;

			case JLE:
				if(greg[30].d <= 0){
					branchprofile[pc]+=1;
					pc += fm.J.cx;
				}else{
					branchprofile[pc]-=1;
					pc += 1;
				}
				break;

			case JLT:
				if(greg[30].d < 0){
					branchprofile[pc]+=1;
					pc += fm.J.cx;
				}else{
					branchprofile[pc]-=1;
					pc += 1;
				}
				break;

			case JSUB:
				greg[31].u = pc + 1;
				pc += fm.J.cx;
				break;

				// 1 greg, 1 imm
			case LDIH:
				greg[fm.L.ra].u = (fm.L.cx << 16) + (greg[fm.L.ra].u & 0xffff);
				pc+=1;
				break;

				// 1 freg, 1 greg
			case ITOF:
				freg[fm.L.ra].r = FPU::itof(greg[fm.L.rb].r);
				pc+=1;
				break;

				// 1 greg, 1 freg
			case FTOI:
				greg[fm.L.ra].r = FPU::ftoi(freg[fm.L.rb].r);
				pc+=1;
				break;

				// 2 freg
			case FINV:
				freg[fm.A.ra].r = FPU::finv(freg[fm.A.rb].r);
				pc+=1;
				break;

			case FSQRT:
				freg[fm.A.ra].r = FPU::fsqrt(freg[fm.A.rb].r);
				pc+=1;
				break;

			case FABS:
				freg[fm.A.ra].r = FPU::fabs(freg[fm.A.rb].r);
				pc+=1;
				break;

			case FCMP:
				greg[30].d = FPU::fcmp(freg[fm.A.rb].r, freg[fm.A.rc].r);
				pc+=1;
				break;

				// 2 gregs, 1 imm
			case LD:
				{
					unsigned int address = (greg[fm.L.rb].d + fm.L.cx) & IOADDR;
					if (address >= RAMSIZE)
					{
						cerr << "Invalid Address : 0x" << hex << address << endl;
						goto END_MAIN;
					}
					if (address == IOADDR)
					{
						if (input->eof())
						{
							cerr << "No input any longer" << endl;
							goto END_MAIN;
						}
						else
							input->read((char*)&(greg[fm.L.ra].r), sizeof(char));
					}
					else greg[fm.L.ra].r = ram[address];
				}
				pc+=1;
				break;

			case ST:
				{
					unsigned int address = (greg[fm.L.rb].d + fm.L.cx) & IOADDR;
					if (address>=RAMSIZE)
					{
						cerr << "Invalid Address : 0x" << hex << address << endl;
						goto END_MAIN;
					}
					if (address == IOADDR){
						output->write((char*)&(greg[fm.L.ra].r), sizeof(char));
					}else{
						ram[address] = greg[fm.L.ra].r;
					}
				}
				pc+=1;
				break;

			case ADDI:
				greg[fm.L.ra].u = greg[fm.L.rb].u + fm.L.cx;
				pc+=1;
				break;

			case SHLI:
				greg[fm.L.ra].u = greg[fm.L.rb].u << fm.L.cx;
				pc+=1;
				break;

			case SHRI:
				greg[fm.L.ra].u = greg[fm.L.rb].u >> fm.L.cx;
				pc+=1;
				break;

				// 1 freg, 1greg, 1 imm
			case FLD:
				{
					unsigned int address = (greg[fm.L.rb].d + fm.L.cx) & IOADDR;
					if (address>=RAMSIZE)
					{
						cerr << "Invalid Address : 0x" << hex << address << endl;
						goto END_MAIN;
					}
					if (address == IOADDR)
					{
						if (input->eof())
						{
							cerr << "No input any longer" << endl;
							goto END_MAIN;
						}
						else
							input->read((char*)&(freg[fm.L.ra].r), sizeof(uint32_t));
					}
					else freg[fm.L.ra].r = ram[address];
				}
				pc+=1;
				break;

			case FST:
				{
					unsigned int address = (greg[fm.L.rb].d + fm.L.cx) & IOADDR;
					if (address>=RAMSIZE)
					{
						cerr << "Invalid Address : 0x" << hex << address << endl;
						goto END_MAIN;
					}
					if (address == IOADDR){
						output->write((char*)&(freg[fm.L.ra].r), sizeof(uint32_t));
					}else{
						ram[address] = freg[fm.L.ra].r;
					}
				}
				pc+=1;
				break;

				// 2 freg, 1 imm
			case FLDI:
				freg[fm.L.ra].u = (fm.L.cx << 16) + (freg[fm.L.rb].u >> 16);
				pc+=1;
				break;

				// 3 gregs
			case ADD:
				greg[fm.A.ra].u = greg[fm.A.rb].u + greg[fm.A.rc].u;
				pc+=1;
				break;

			case SUB:
				greg[fm.A.ra].u = greg[fm.A.rb].u - greg[fm.A.rc].u;
				pc+=1;
				break;

			case SHL:
				greg[fm.A.ra].u = greg[fm.A.rb].u << greg[fm.A.rc].u;
				pc+=1;
				break;

			case SHR:
				greg[fm.A.ra].u = greg[fm.A.rb].u >> greg[fm.A.rc].u;
				pc+=1;
				break;

				// 3 fregs
			case FADD:
				freg[fm.A.ra].r = FPU::fadd(freg[fm.A.rb].r, freg[fm.A.rc].r);
				pc+=1;
				break;

			case FSUB:
				freg[fm.A.ra].r = FPU::fsub(freg[fm.A.rb].r, freg[fm.A.rc].r);
				pc+=1;
				break;

			case FMUL:
				freg[fm.A.ra].r = FPU::fmul(freg[fm.A.rb].r, freg[fm.A.rc].r);
				pc+=1;
				break;

			default:
				cerr << "Error!" << endl;
				exit(1);
		}
		greg[0].r = 0;
		freg[0].f = 0;
		counter++;
	}

END_MAIN:


	//Dump RAM
	ofstream fout;
	if(outputramfilename != nullptr){
		fout.open(outputramfilename, ios::binary);
		if(fout.fail()){
			cerr << "Can't open file : " << outputramfilename << endl;
			return 1;
		}
		for(auto x : ram){
			fout.write((char *)&x,sizeof(x));
		}
	}

	ofstream fout2;
	if(branchprofile_flag){
		fout2.open("branch.profile", ios::binary);
		if(fout2.fail()){
			cerr << "Can't open file : " << "branch.profile" << endl;
			return 1;
		}
		for(auto x : branchprofile){
			fout2.write((char *)&x,sizeof(x));
		}
	}


	cerr << "Program Counter = " << pc << endl;
	cerr << "Instructions = " << counter << endl;

	//Print Reg
	for(int i=0;i<greg.size();i++){
		cerr << ISA::greg2name(i) << ":" << hex << "0x" << greg[i].r << dec << "(" << greg[i].d  << ")" << " ";
	}
	cerr << endl;
	for(int i=0;i<freg.size();i++){
		cerr << ISA::freg2name(i) << ":" << hex << "0x" << freg[i].r << dec << "(" << freg[i].f << ")" <<  " ";
	}
	cerr << endl;
	for(auto el : profile){
		cerr << el.first << ":" << el.second << " ";
	}
	cerr << endl;
	return 0;
}

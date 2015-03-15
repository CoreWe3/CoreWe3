#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <list>
#include <vector>
#include <map>
#include <algorithm>
using namespace std;

#include <getopt.h>
#include "isa_class.h"

map<string, unsigned int> labels;
unsigned int getlabelvalue(string str, unsigned int line = 0){
	if(str[0]=='.'){
		if(labels.count(str)==0){
			cerr << "WARN : Static label \"" << str << "\" is not detected" << endl;
		}
		return (unsigned int)labels[str];
	}else if(str[0]==':'){
		if(labels.count(str)==0){
			cerr << "WARN : Dinamic label \"" << str << "\" is not detected" << endl;
		}
		return (unsigned int)(labels[str] - (int)line);
	}else{
		union{
			unsigned int u;
			float f;
		} x;

		try{
			if(str.find(".") == string::npos)
				x.u = (unsigned int)stoul(str,nullptr,0);
			else{
				istringstream strm(str);
				strm >> x.f;
			}
		}
		catch(...){
			cerr << "ERROR : Invalid Argument :" << str << endl;
			exit(1);
		}
		return x.u;
	}
}

void print_instruction(vector<string> ins, ostream &out = cout){
	for(auto &el : ins){
		out << el << " ";
	}
	out << endl;
}

void print_all(list<vector<string>> ls, ostream &out = cout){
	for(auto &it : ls){
		print_instruction(it, out);
	}
}

int main(int argc, char* argv[]){

	//Option Handler
	char result;
	char *filename = nullptr, *outputfilename = nullptr;
	bool showlabel = false;
	while((result=getopt(argc,argv,"f:i:l"))!=-1){
		switch(result){
			case 'f': // Output File
				outputfilename = optarg;
				break;
			case 'i': // Input File
				filename = optarg;
				break;
			case 'l':
				showlabel = true;
				break;
			case ':':
				cerr << "ERROR : "<<result << " needs value" << endl;
				return 1;
			case '?':
				cerr << "ERROR : unknown option" << endl;
				return 1;
		}
	}

	//Initilaize
	istream *din = &cin;
	ifstream fin;
	if(filename != nullptr){
		fin.open(filename);
		if(fin.fail()){
			cerr << "ERROR : Can't open file" << endl;
			return 1;
		}
		din = &fin;
	}

	//Read Data
	list<vector<string>> instructions;
	string str;
	while(*din && getline(*din, str)){
		string tmp;
		replace(str.begin(),str.end(),'\t',' ');
		istringstream stream( str );
		vector<string> ins;
		while(getline(stream,tmp,' ')){
			if(tmp.length() > 0){
				ins.push_back(tmp);
			}
		}
		if(ins.size()<=0) continue;
		if(ins[0][0]=='#') continue;
		instructions.push_back(ins);
	}

	//Detect Static Label
	for(auto it = instructions.begin(); it != instructions.end();){
		if((*it)[0][0] == '.')
		{
			labels[(*it)[0]] = (unsigned int) stoul((*it)[1], nullptr, 0);
			it = instructions.erase(it);
		}else{
			it++;
		}
	}

	//Optimize LDI and VFLDI
	//Detect Immidiate Emergence Rate
	map<unsigned int, unsigned int> gimm_counter, fimm_counter;
	for(auto it = instructions.begin(); it != instructions.end();){
		if((*it)[0][0]==':'){
			it++;
			continue;
		}
		switch(ISA::name2isa((*it)[0])){
			case VLDI:
				{
					if((*it)[2][0]!=':'){
						unsigned int v = getlabelvalue((*it)[2]);
						gimm_counter[v]++;
						if (v > 0x7fff){
							if((*it)[0][0]!='@'){
								vector<string> itmp1 {"ADDI", (*it)[1], "r0", to_string(v & 0xffff)};
								vector<string> itmp2 {"LDIH", (*it)[1], to_string(v >> 16)};
								instructions.insert(it,itmp1);
								instructions.insert(it,itmp2);
							}else{
								vector<string> itmp1 {"@ADDI", (*it)[1], "r0", to_string(v & 0xffff)};
								vector<string> itmp2 {"@LDIH", (*it)[1], to_string(v >> 16)};
								instructions.insert(it,itmp1);
								instructions.insert(it,itmp2);
							}
						}else{
							if((*it)[0][0]!='@'){
								vector<string> itmp1 {"ADDI", (*it)[1], "r0", (*it)[2]};
								instructions.insert(it,itmp1);
							}else{
								vector<string> itmp1 {"@ADDI", (*it)[1], "r0", (*it)[2]};
								instructions.insert(it,itmp1);
							}
						}
						it = instructions.erase(it);
					}else{
						it++;
					}
				}
				break;
			case VFLDI:
				{
					if((*it)[2][0]!=':'){
						unsigned int v = getlabelvalue((*it)[2]);
						fimm_counter[v]++;
						if ((v & 0xffff)!=0){
							if((*it)[0][0]!='@'){
								vector<string> itmp1 {"FLDI", (*it)[1], "f0", to_string(v & 0xffff)};
								vector<string> itmp2 {"FLDI", (*it)[1], (*it)[1], to_string(v >> 16)};
								instructions.insert(it,itmp1);
								instructions.insert(it,itmp2);
							}else{
								vector<string> itmp1 {"@FLDI", (*it)[1], "f0", to_string(v & 0xffff)};
								vector<string> itmp2 {"@FLDI", (*it)[1], (*it)[1], to_string(v >> 16)};
								instructions.insert(it,itmp1);
								instructions.insert(it,itmp2);
							}
						}else{
							if((*it)[0][0]!='@'){
								vector<string> itmp1 {"FLDI", (*it)[1], "f0", to_string(v >> 16)};
								instructions.insert(it,itmp1);
							}else{
								vector<string> itmp1 {"@FLDI", (*it)[1], "f0", to_string(v >> 16)};
								instructions.insert(it,itmp1);
							}
						}
						it = instructions.erase(it);
					}else{
						it++;
					}
				}
				break;
			default:
				it++;
				break;
		}
	}

	cerr << "========================" << endl;
	cerr << "Immediate Emergence Rate" << endl;
	list<tuple<unsigned int, unsigned int>> gimm;
	for(auto x : gimm_counter){
		gimm.push_back(tuple<unsigned int, unsigned int>(x.first, x.second));
	}

	gimm.sort([](tuple<unsigned int, unsigned int> a, tuple<unsigned int, unsigned int> b)->bool { return get<1>(a) > get<1>(b); } );
	int tempcounter = 0;
	cerr << "General Register" << endl;
	for(auto y : gimm){
		cerr << " " << get<0>(y) << " : " << get<1>(y) << endl;
		tempcounter++;
		if(tempcounter > 10) break;
	}
	list<tuple<unsigned int, unsigned int>> fimm;
	for(auto x : fimm_counter){
		fimm.push_back(tuple<unsigned int, unsigned int>(x.first, x.second));
	}
	fimm.sort([](tuple<unsigned int, unsigned int> a, tuple<unsigned int, unsigned int> b)->bool { return get<1>(a) > get<1>(b); } );
	tempcounter = 0;
	cerr << "Float Register" << endl;

	union{
		unsigned int d;
		float f;
	} fu;
	for(auto y : fimm){
		fu.d = get<0>(y);
		cerr << " " << get<0>(y) << "(" << fu.f << ")" << " : " << get<1>(y) << endl;
		tempcounter++;
		if(tempcounter > 10) break;
	}
	cerr << "========================" << endl;

	//Optimize NOP
	for(auto it = instructions.begin(); it != instructions.end();){
		if((*it)[0][0]==':'){
			it++;
			continue;
		}
		switch(ISA::name2isa((*it)[0])){
			// XXXI rx rx 0
			case ADDI:
			case SHRI:
			case SHLI:
				if((*it)[3][0]!=':' && ISA::name2reg((*it)[1]) == ISA::name2reg((*it)[2]) && getlabelvalue((*it)[3]) == 0){
					it = instructions.erase(it);
					break;
				}
			// XXXX x0 rx
			case ADD:
			case SUB:
			case SHR:
			case SHL:
			case FTOI:
			case ITOF:
			case LD:
			case LDIH:
			case FLDI:
			case VLDI:
			case VFLDI:
				if (ISA::name2reg((*it)[1]) == 0){
					it = instructions.erase(it);
					break;
				}
			default:
				it++;
				break;
		}
	}

	//Detect Dynamic Label
	int line = 0;
	for(auto it = instructions.begin(); it != instructions.end();){
		if((*it)[0][0] == ':'){
			labels[(*it)[0]] = line;
			it = instructions.erase(it);
		}else{
			switch(ISA::name2isa((*it)[0])){
				case VLDI:
				case VFLDI:
					line+=2;
					break;
				default:
					line+=1;
					break;
			}
			it++;
		}
	}


	//Make Assembly
	list<uint32_t> results;
	line = 0;
	for(auto i = instructions.begin(); i != instructions.end(); i++){
		auto el = *i;
		FORMAT fm;
		fm.data = 0;
		if(el[0][0]=='@'){
			fm.J.fg = 1;
		}
		switch(ISA::name2isa(el[0])){
			// no regs and imm
			case RET:
				fm.J.op = ISA::name2isa(el[0]);
				results.push_back(fm.data);
				line++;
				break;

				// 1 imm
			case J:
			case JEQ:
			case JLE:
			case JLT:
			case JSUB:
				{
					fm.J.op = ISA::name2isa(el[0]);
					unsigned int v = getlabelvalue(el[1], line);
					if(v>0xFFFFFF&&v<0xFF000000){
						cerr << "WARN : overflow immidiate : around " << line << endl;
					}
					fm.J.cx = v;
				}
				results.push_back(fm.data);
				line++;
				break;

				// 1 reg, 1 imm
			case LDIH:
				{
					fm.L.op = ISA::name2isa(el[0]);
					fm.L.ra = ISA::name2reg(el[1]);
					unsigned int v = getlabelvalue(el[2], line);
					if(v>0xFFFF){
						cerr << "WARN : overflow immidiate : around " << line << endl;
					}
					fm.L.cx = v;
				}
				results.push_back(fm.data);
				line++;
				break;

				// 2 regs
			case ITOF:
			case FTOI:
			case FINV:
			case FSQRT:
			case FABS:
				fm.A.op = ISA::name2isa(el[0]);
				fm.A.ra = ISA::name2reg(el[1]);
				fm.A.rb = ISA::name2reg(el[2]);
				results.push_back(fm.data);
				line++;
				break;

			case FCMP:
				fm.A.op = ISA::name2isa(el[0]);
				fm.A.rb = ISA::name2reg(el[1]);
				fm.A.rc = ISA::name2reg(el[2]);
				results.push_back(fm.data);
				line++;
				break;

				// 2 regs, 1 imm
			case LD:
			case ST:
			case FLD:
			case FST:
			case SHLI:
			case SHRI:
				{
					fm.L.op = ISA::name2isa(el[0]);
					fm.L.ra = ISA::name2reg(el[1]);
					fm.L.rb = ISA::name2reg(el[2]);
					unsigned int v = getlabelvalue(el[3], line);

					if(v>0x7FFF&&v<0xFFFF8000){
						cerr << "WARN : overflow immidiate : around " << line << endl;
					}
					fm.L.cx = v;
				}
				results.push_back(fm.data);
				line++;
				break;
			
			case ADDI:
				{
					fm.L.op = ISA::name2isa(el[0]);
					fm.L.ra = ISA::name2reg(el[1]);
					fm.L.rb = ISA::name2reg(el[2]);
					unsigned int v = getlabelvalue(el[3], line);

					if( (v>0xFFFF&&v<0xFFFF0000) || (v>0x7FFF&&v<0xFFFF8000&& !(next(i)!=instructions.end()&&ISA::name2isa((*next(i))[0])==LDIH&& ISA::name2reg(el[1]) == ISA::name2reg((*next(i))[1]) ))){
						cerr << "WARN : overflow immidiate : around " << line << endl;
					}
					fm.L.cx = v;
				}
				results.push_back(fm.data);
				line++;
				break;

			case FLDI:
				{
					fm.L.op = ISA::name2isa(el[0]);
					fm.L.ra = ISA::name2reg(el[1]);
					fm.L.rb = ISA::name2reg(el[2]);
					unsigned int v = getlabelvalue(el[3], line);
					if(v>0xFFFF){
						cerr << "WARN : overflow immidiate : around " << line << endl;
					}
					fm.L.cx = v;
				}
				results.push_back(fm.data);
				line++;
				break;

				// 3 regs
			case ADD:
			case SUB:
			case SHL:
			case SHR:
			case FADD:
			case FSUB:
			case FMUL:
				fm.A.op = ISA::name2isa(el[0]);
				fm.A.ra = ISA::name2reg(el[1]);
				fm.A.rb = ISA::name2reg(el[2]);
				fm.A.rc = ISA::name2reg(el[3]);
				results.push_back(fm.data);
				line++;
				break;

				//Virtual Instructions
			case VLDI:
				fm.L.op = ISA::name2isa("ADDI");
				fm.L.ra = ISA::name2reg(el[1]);
				fm.L.rb = ISA::name2reg("r0");
				fm.L.cx = getlabelvalue(el[2], line) & 0xffff;
				results.push_back(fm.data);
				line++;
				fm.data = 0;
				fm.L.op = ISA::name2isa("LDIH");
				fm.L.ra = ISA::name2reg(el[1]);
				fm.L.cx = getlabelvalue(el[2], line) >> 16;
				results.push_back(fm.data);
				line++;
				break;

			case VFLDI:
				fm.L.op = ISA::name2isa("FLDI");
				fm.L.ra = ISA::name2reg(el[1]);
				fm.L.rb = ISA::name2reg("f0");
				fm.L.cx = getlabelvalue(el[2], line) & 0xffff;
				results.push_back(fm.data);
				line++;
				fm.data = 0;
				fm.L.op = ISA::name2isa("FLDI");
				fm.L.ra = ISA::name2reg(el[1]);
				fm.L.rb = ISA::name2reg(el[1]);
				fm.L.cx = getlabelvalue(el[2], line) >> 16;
				results.push_back(fm.data);
				line++;
				break;

			case VCMP:
				fm.A.op = ISA::name2isa("SUB");
				fm.A.ra = ISA::name2reg("r30");
				fm.A.rb = ISA::name2reg(el[1]);
				fm.A.rc = ISA::name2reg(el[2]);
				results.push_back(fm.data);
				line++;
				break;

			case VCMPI:
				{
					fm.L.op = ISA::name2isa("ADDI");
					fm.L.ra = ISA::name2reg("r30");
					fm.L.rb = ISA::name2reg(el[1]);
					unsigned int v = getlabelvalue(el[2], line)*-1;
					if(v>0x7FFF&&v<0xFFFF8000){
						cerr << "WARN : overflow immidiate : around " << line << endl;
					}
					fm.L.cx = v;
				}
				results.push_back(fm.data);
				line++;
				break;

			default:
				cerr << "ERROR : This assembler has bug!" << endl;
				exit(1);
		}
	}

	//Output Assembly File
	ofstream fout;
	if(outputfilename != nullptr){
		fout.open(outputfilename, ios::binary);
		if(fout.fail()){
			cerr << "ERROR : Can't open file" << endl;
			return 1;
		}
	}else{
		cerr << "ERROR : No output file" << endl;
		return 1;
	}

	for(auto x : results){
		fout.write((char *)&x,sizeof(x));
	}

	if(showlabel){
		list<tuple<string, unsigned int>> tl;
		for(auto x : labels){
			if (x.first[0] == '.'){
				cerr << x.first << " : " << x.second << endl;
			}else{
				tl.push_back(tuple<string, unsigned int>(x.first, x.second));
			}
		}
		tl.sort([](tuple<string, unsigned int> a, tuple<string, unsigned int> b)->bool { return get<1>(a) < get<1>(b); } );
		for(auto y : tl){
			cerr << get<0>(y) << " : " << get<1>(y) << endl;
		}
	}

	return 0;
}

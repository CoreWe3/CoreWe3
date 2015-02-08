#include <iostream>
#include <algorithm>
#include "isa.h"
#include "isa_class.h"

std::map<unsigned int, std::string> ISA::isa2name_map;
std::map<std::string, int> ISA::name2reg_map;

ISA::ISA(){
	for (auto &el : INAMES){
		isa2name_map[el.second] = el.first;
	}
	uint8_t c = 0;
	for (auto el : GREGNAMES){
		name2reg_map[el] = c++;

	}
	c = 0;
	for (auto el : FREGNAMES){
		name2reg_map[el] = c++;
	}
}

unsigned int ISA::name2isa(std::string str){
	std::transform(str.begin(),str.end(),str.begin(),toupper);
	if(INAMES.count(str)==0){
		std::cerr << "No such kind of instruction : " << str << std::endl;
		exit(1);
	}
	return INAMES.at(str);
}

unsigned int ISA::name2reg(std::string str){
	std::transform(str.begin(),str.end(),str.begin(),tolower);
	return name2reg_map.at(str);
}

std::string ISA::isa2name(unsigned int i){ return isa2name_map[i]; }
std::string ISA::greg2name(unsigned int i){ return GREGNAMES[i]; }
std::string ISA::freg2name(unsigned int i){ return FREGNAMES[i]; }

ISA isa;

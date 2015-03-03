#pragma once

#include <map>
#include <string>
#include "isa.h"

class ISA {
	//private:
	public:
		static std::map<unsigned int, std::string> isa2name_map;
		static std::map<std::string, int> name2reg_map;
	public:
		ISA();
		static unsigned int name2isa(std::string);
		static unsigned int name2reg(std::string);
		static std::string isa2name(unsigned int);
		static std::string greg2name(unsigned int);
		static std::string freg2name(unsigned int);
};

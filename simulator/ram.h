#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <stdint.h>
#include "isa.h"

using namespace std;

#define LINESIZE3 4
#define CACHEWIDTH3 256
#define WAYSIZE1 2

class RAM {
	private:
		vector<uint32_t> ram;
		vector<vector<uint32_t>> tags1, age1;
		unsigned long long counter, hitcounter, swap;
	public:
		RAM(char*);
		vector<uint32_t>::const_iterator begin() const;
		vector<uint32_t>::const_iterator end() const;
		int read(uint32_t, uint32_t&);
		void write(uint32_t, uint32_t);
		void printramstatus();
};


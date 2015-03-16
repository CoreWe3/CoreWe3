#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <stdint.h>
#include "isa.h"

using namespace std;

#define LINESIZE3 8
#define CACHEWIDTH3 64
#define WAYSIZE1 2

class RAM {
	private:
		vector<uint32_t> ram;
		vector<vector<uint32_t>> tags1, age1;
		int wait;
		unsigned long long counter, hitcounter, swap;
	public:
		RAM(char*);
		vector<uint32_t>::const_iterator begin() const;
		vector<uint32_t>::const_iterator end() const;
		int read(uint32_t, uint32_t&);
		int write(uint32_t, uint32_t);
		void printramstatus();
		void update(int i);
};


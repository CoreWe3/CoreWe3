#!/usr/bin/python
import re
import sys

if __name__ == "__main__":
    f = open(sys.argv[1])
    text = f.read()
    f.close()
    text = re.compile(r'\(\*NOMINCAML.*\*\)').sub('', text)
    text = re.compile(r'\(\*MINCAML\*\).*').sub('', text)
    text = re.compile(r' \* 4 ').sub(' lsl 2 ', text)
    text = re.compile(r' size_x \/ 2').sub(' 64', text)
    text = re.compile(r' size_y \/ 2').sub(' 64', text)
    text = re.compile(r'create_array').sub(' Array.create', text)
    text = re.compile(r';\n[\s\t]*\)', re.M).sub(')', text)    
    text = re.compile(r'in 0$').sub('in ()', text)
    print(text)

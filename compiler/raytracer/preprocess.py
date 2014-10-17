#!/usr/bin/python
import re
import sys

globals = """\
let light_dirvec =
  let dummyf2 = create_array 0 0.0 in
  let v3 = create_array 3 0.0 in
  let consts = create_array 60 dummyf2 in
  (v3, consts) 
in
"""

if __name__ == "__main__":
    f = open(sys.argv[1])
    text = f.read()
    f.close()
    text = globals + text 
    text = re.compile(r'\(\*NOMINCAML.*\*\)').sub('', text)
    text = re.compile(r'\(\*MINCAML\*\).*').sub('', text)
    text = re.compile(r' \* 4 ').sub(' lsl 2 ', text)
    text = re.compile(r' \/ 2').sub(' lsr 1', text)
    text = re.compile(r'create_array').sub(' Array.create', text)
    text = re.compile(r';\n[\s\t]*\)', re.M).sub(')', text)    
    text = re.compile(r'in 0$').sub('in ()', text)
    print(text)

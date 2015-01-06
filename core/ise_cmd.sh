#!/bin/bash
LANGUAGE=
XILINX_DIR=/opt/Xilinx/
. ${XILINX_DIR}14.4/ISE_DS/settings64.sh > /dev/null && \
xst -intstyle silent -ifn core.xst && \
ngdbuild -intstyle silent -dd _ngo -nt timestamp -uc core.ucf -p xc5vlx50t-ff1136-1 core.ngc core.ngd && \
map -intstyle silent -p xc5vlx50t-ff1136-1 -w -logic_opt off -ol high -t 1 -register_duplication off -global_opt off -mt off -cm area -ir off -pr off -lc off -power off -o core_map.ncd core.ngd core.pcf && \
par -w -intstyle silent -ol high -mt off core_map.ncd core.ncd core.pcf && \
trce -intstyle silent -v 3 -s 1 -n 3 -fastpaths -xml core.twx core.ncd -o core.twr core.pcf && \
bitgen -intstyle silent -f core.ut core.ncd

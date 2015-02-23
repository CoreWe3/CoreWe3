#!/bin/bash
LANGUAGE=
XILINX_DIR=/opt/Xilinx/
export XILINXD_LICENSE_FILE=2100@idylls.jp
. ${XILINX_DIR}14.4/ISE_DS/settings64.sh > /dev/null && \
xst -intstyle ise -ifn core.xst && \
ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc core.ucf -p xc5vlx50t-ff1136-1 core.ngc core.ngd && \
map -intstyle ise -p xc5vlx50t-ff1136-1 -w -logic_opt off -ol high -t 1 -register_duplication off -global_opt off -mt off -cm area -ir off -pr off -lc off -power off -o core_map.ncd core.ngd core.pcf && \
par -w -intstyle ise -ol high -mt off core_map.ncd core.ncd core.pcf && \
trce -intstyle ise -v 3 -s 1 -n 3 -fastpaths -xml core.twx core.ncd -o core.twr core.pcf && \
bitgen -intstyle ise -f core.ut core.ncd

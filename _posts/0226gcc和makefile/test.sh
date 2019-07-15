#!/bin/sh
myprj=$1
mkdir ${myprj} ${myprj}/include ${myprj}/src ${myprj}/temp ${myprj}/lib ${myprj}/bin
cat>${myprj}/Makefile<<EOF
#cc=g++
#CFLAGS=-g -Wall
CUR_DIR=\$(shell pwd)
#vpath %.o \$(CUR_DIR)/temp
#vpath %.a \$(CUR_DIR)/lib
VPATH = \$(CUR_DIR)/bin:\$(CUR_DIR)/src

.PHONY: all obj_o tar_bin
all : obj_o tar_bin
obj_o : 
	\$(MAKE) -C \$(CUR_DIR)/src||exit 1
tar_bin :
	\$(MAKE) -C \$(CUR_DIR)/bin||exit 1

EOF
cat>${myprj}/src/Makefile<<EOF
cc=g++
CFLAGS=-g -Wall
CUR_DIR=\$(shell pwd)
INCLUDE_DIR=\$(CUR_DIR)/../include
ADD_INCLUDE=-I ./ $2#须设置
TEMP_DIR=\$(CUR_DIR)/../temp
#vpath %.o \$(CUR_DIR)/temp
#vpath %.a \$(CUR_DIR)/lib
vpath %.h \$(CUR_DIR)/../include
#VPATH = \$(CUR_DIR):\$(CUR_DIR)/src
cfiles=\$(wildcard *.c)
cppfiles=\$(wildcard *.cpp)
cppobjects=\$(patsubst %.cpp,%.o,\$(cppfiles))

cobjects=\$(patsubst %.c,%.o,\$(cfiles))
all : \$(cppobjects) \$(cobjects)
\$(cppobjects) : %.o:%.cpp
	\$(cc) -c -I \$(INCLUDE_DIR) \$(ADD_INCLUDE) \$(CFLAGS) \$< -o \$(TEMP_DIR)/\$@
\$(cobjects) : %.o:%.c
	\$(cc) -c -I \$(INCLUDE_DIR) \$(ADD_INCLUDE) \$(CFLAGS) \$< -o \$(TEMP_DIR)/\$@

#\$(objects): t1.cpp t2.cpp
#echo \$^&& echo \$@
#\$(objects) : \$(wildcard *.cpp)
#\$(cc) -c -I \$(INCLUDE_DIR) \$(CFLAGS) \$< -o \$(patsubst %.cpp,%.o,\$<)&&echo \$^&&echo \$(objects)
EOF
cat>${myprj}/bin/Makefile<<EOF
cc=g++
CFLAGS=-g -Wall
CUR_DIR=\$(shell pwd)
vpath %.o \$(CUR_DIR)/../temp
vpath %.a \$(CUR_DIR)/../lib
VPATH = \$(CUR_DIR):\$(CUR_DIR)/../src
LIB_DIR = -L \$(CUR_DIR)/../lib $3#须设置库目录
LIB_NAME=-lm $4#须设置连接的库
target=${myprj}
\$(target): \$(wildcard ../temp/*.o)
	\$(cc) \$^ \$(LIB_DIR) \$(LIB_NAME) -o \$@
#.PHONY: all
#all : obj_o tar_bin
#obj_o :
#\${str#*I}
EOF
str=${2}&&str1=${str//-I/}
cat >${myprj}/cscope.sh<<EOF

find ./ ${str1} -name '*.h' -o -name '*.c' -o -name '*.cpp' > ./cscope.files&&cscope -Rbq -P ${myprj}
EOF

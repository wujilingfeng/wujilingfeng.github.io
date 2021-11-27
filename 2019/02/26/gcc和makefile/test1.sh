#!/bin/sh
myprj=$1
mkdir ${myprj} ${myprj}/include ${myprj}/src ${myprj}/temp_libs ${myprj}/lib ${myprj}/bin ${myprj}/build ${myprj}/Demo ${myprj}/thirdpart

cat>${myprj}/.conf<<EOF
name:$1
includedir: $2
libdir: $3
lib: $4
EOF
cat>${myprj}/README.md<<EOF
#### ${myprj}

EOF
cat>${myprj}/SConstruct<<EOF
import os
env=Environment(ENV=os.environ)
print(env["PLATFORM"])
env["prjpath"]=os.getcwd()
Export("env")
if env["PLATFORM"]=="posix":
    env.Append(CCFLAGS="-g -Wall")


#SConscript("./src/SConscript",variant_dir="build/src",duplicate=0)
src=Glob(pattern="./Demo/*.cpp",strings=True)
cpppath=[os.path.join(env["prjpath"],"include")]+"$2".split()
libpath=[os.path.join(env[prjpath],"lib"),os.path.join(env["prjpath"],"temp_libs")]+"$3".split()

libs="$4".split()

env.Program(target=os.path.join(env["prjpath"],"src",main),source=src,CPPPATH=cpppath,LIBPATH=libpath,LIBS=libs)

EOF
cat>${myprj}/CMakeLists.txt<<EOF
PROJECT(${myprj})
cmake_minimum_required(VERSION 2.8)
add_compile_options(-Wall -g -O)
#set(CMAKE_EXE_LINKER_FLAGS \${CMAKE_EXE_LINKER_FLAGS} -no-pie)
#生成可执行程序
set(CMAKE_CXX_FLAGS \${CMAKE_CXX_FLAGS} -std=c++11)
set(CMAKE_C_FLAGS \${CMAKE_C_FLAGS} -std=c99)
#add_subdirectory(./src/Math)

if(CMAKE_SYSTEM_NAME MATCHES "Linux")
add_compile_options(-lstdc++)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
add_compile_options(-static-libstdc++ -static-libgcc)

endif(CMAKE_SYSTEM_NAME MATCHES "Linux")
include_directories(\${PROJECT_SOURCE_DIR}/include $2)
link_directories(\${PROJECT_SOURCE_DIR}/lib \${PROJECT_SOURCE_DIR}/temp_libs $3)
aux_source_directory(\${PROJECT_SOURCE_DIR}/Demo mysrc)
set(EXECUTABLE_OUTPUT_PATH \${PROJECT_SOURCE_DIR}/bin)
set(LIBRARY_OUTPUT_PATH \${PROJECT_SOURCE_DIR}/temp_libs)
link_libraries(m  $4)
#add_subdirectory(./src)
add_executable(main \${mysrc})
#target_link_libraries(main  -Wl,--start-group  m -Wl,--end-group)
EOF

cat >${myprj}/cscope.sh<<EOF
find ./ $2 -name '*.h' -o -name '*.c' -o -name '*.cpp' > ./cscope.files&&cscope -Rbq -P \`pwd\`
EOF
cat >${myprj}/Demo/main.cpp<<EOF
#include<stdio.h>
int main(int argc,char**argv)
{

return 0;
}
EOF

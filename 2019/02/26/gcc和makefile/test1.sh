#!/bin/sh
myprj=$1
mkdir ${myprj} ${myprj}/include ${myprj}/src ${myprj}/temp_libs ${myprj}/lib ${myprj}/bin ${myprj}/build ${myprj}/Demo ${myprj}/thirdpart

cat>${myprj}/.conf<<EOF
name:$1
includedir: $2
libdir: $3
lib: $4
EOF
cat>${myprj}/CMakeLists.txt<<EOF
cmake_minimum_required(VERSION 2.8)
add_compile_options(-Wall -g -lstdc++)
set(CMAKE_CXX_FLAGS \${CMAKE_CXX_FLAGS} -std=c++11)
set(CMAKE_C_FLAGS \${CMAKE_C_FLAGS} -std=c99)
include_directories(\${PROJECT_SOURCE_DIR}/include $2)
link_directories(\${PROJECT_SOURCE_DIR}/lib $3)
aux_source_directory(\${PROJECT_SOURCE_DIR}/Demo mysrc)
set(EXECUTABLE_OUTPUT_PATH \${PROJECT_SOURCE_DIR}/bin)
set(LIBRARY_OUTPUT_PATH \${PROJECT_SOURCE_DIR}/temp_libs)
#add_subdirectory(${PROJECT_SOURCE_DIR}/src)
add_executable(main \${mysrc})
#target_link_libraries(main )
EOF

cat >${myprj}/cscope.sh<<EOF
find ./ $2 -name '*.h' -o -name '*.c' -o -name '*.cpp' > ./cscope.files&&cscope -Rbq -P \`pwd\`
EOF
cat >${myprj}/Demo/main.cpp<<EOF
#include<stdio.h>
int main()
{

return 0;
}
EOF

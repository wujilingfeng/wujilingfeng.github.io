#!/bin/sh
myprj=$1
mkdir ${myprj} ${myprj}/include ${myprj}/src ${myprj}/temp ${myprj}/lib ${myprj}/bin

cat>${myprj}/.conf<<EOF
name:$1
includedir: $2
libdir: $3
lib: $4
EOF
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
str2="'$str',"&&str3=${str2// /"','"}
cat>${myprj}/.ycm_extra_conf.py<<EOF
from distutils.sysconfig import get_python_inc
import platform
import os.path as p
import subprocess
import ycm_core

DIR_OF_THIS_SCRIPT = p.abspath( p.dirname( __file__ ) )
DIR_OF_THIRD_PARTY = p.join( DIR_OF_THIS_SCRIPT, 'third_party' )
SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

# These are the compilation flags that will be used in case there's no
# compilation database set (by default, one is not set).
# CHANGE THIS LIST OF FLAGS. YES, THIS IS THE DROID YOU HAVE BEEN LOOKING FOR.
flags = [
'-isystem',
'./include',
'-isystem',
'./src',
'-isystem',
'/usr/include',
'-isystem',
'/usr/local/include'
'-isystem',
'-isystem',
'/usr/include/c++/7',
${str3}
]

# Clang automatically sets the '-std=' flag to 'c++14' for MSVC 2015 or later,
# which is required for compiling the standard library, and to 'c++11' for older
# versions.
if platform.system() != 'Windows':
  flags.append( '-std=c++11' )


# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# You can get CMake to generate this file for you by adding:
#   set( CMAKE_EXPORT_COMPILE_COMMANDS 1 )
# to your CMakeLists.txt file.
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if p.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None


def IsHeaderFile( filename ):
  extension = p.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh', '' ]


def FindCorrespondingSourceFile( filename ):
  if IsHeaderFile( filename ):
    basename = p.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if p.exists( replacement_file ):
        return replacement_file
  return filename


def PathToPythonUsedDuringBuild():
  try:
    filepath = p.join( DIR_OF_THIS_SCRIPT, 'PYTHON_USED_DURING_BUILDING' )
    with open( filepath ) as f:
      return f.read().strip()
  # We need to check for IOError for Python 2 and OSError for Python 3.
  except ( IOError, OSError ):
    return None


def Settings( **kwargs ):
  language = kwargs[ 'language' ]

  if language == 'cfamily':
    # If the file is a header, try to find the corresponding source file and
    # retrieve its flags from the compilation database if using one. This is
    # necessary since compilation databases don't have entries for header files.
    # In addition, use this source file as the translation unit. This makes it
    # possible to jump from a declaration in the header file to its definition
    # in the corresponding source file.
    filename = FindCorrespondingSourceFile( kwargs[ 'filename' ] )

    if not database:
      return {
        'flags': flags,
        'include_paths_relative_to_dir': DIR_OF_THIS_SCRIPT,
        'override_filename': filename
      }

    compilation_info = database.GetCompilationInfoForFile( filename )
    if not compilation_info.compiler_flags_:
      return {}

    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object.
    final_flags = list( compilation_info.compiler_flags_ )

    # NOTE: This is just for YouCompleteMe; it's highly likely that your project
    # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
    # ycm_extra_conf IF YOU'RE NOT 100% SURE YOU NEED IT.
    try:
      final_flags.remove( '-stdlib=libc++' )
    except ValueError:
      pass

    return {
      'flags': final_flags,
      'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
      'override_filename': filename
    }

  if language == 'python':
    return {
      'interpreter_path': PathToPythonUsedDuringBuild()
    }

  return {}


def GetStandardLibraryIndexInSysPath( sys_path ):
  for index, path in enumerate( sys_path ):
    if p.isfile( p.join( path, 'os.py' ) ):
      return index
  raise RuntimeError( 'Could not find standard library path in Python path.' )


def PythonSysPath( **kwargs ):
  sys_path = kwargs[ 'sys_path' ]

  interpreter_path = kwargs[ 'interpreter_path' ]
  major_version = subprocess.check_output( [
    interpreter_path, '-c', 'import sys; print( sys.version_info[ 0 ] )' ]
  ).rstrip().decode( 'utf8' )

  sys_path.insert( GetStandardLibraryIndexInSysPath( sys_path ) + 1,
                   p.join( DIR_OF_THIRD_PARTY, 'python-future', 'src' ) )
  sys_path[ 0:0 ] = [ p.join( DIR_OF_THIS_SCRIPT ),
                      p.join( DIR_OF_THIRD_PARTY, 'bottle' ),
                      p.join( DIR_OF_THIRD_PARTY, 'cregex',
                              'regex_{}'.format( major_version ) ),
                      p.join( DIR_OF_THIRD_PARTY, 'frozendict' ),
                      p.join( DIR_OF_THIRD_PARTY, 'jedi_deps', 'jedi' ),
                      p.join( DIR_OF_THIRD_PARTY, 'jedi_deps', 'numpydoc' ),
                      p.join( DIR_OF_THIRD_PARTY, 'jedi_deps', 'parso' ),
                      p.join( DIR_OF_THIRD_PARTY, 'requests_deps', 'requests' ),
                      p.join( DIR_OF_THIRD_PARTY, 'requests_deps',
                                                  'urllib3',
                                                  'src' ),
                      p.join( DIR_OF_THIRD_PARTY, 'requests_deps',
                                                  'chardet' ),
                      p.join( DIR_OF_THIRD_PARTY, 'requests_deps',
                                                  'certifi' ),
                      p.join( DIR_OF_THIRD_PARTY, 'requests_deps',
                                                  'idna' ),
                      p.join( DIR_OF_THIRD_PARTY, 'waitress' ) ]

  return sys_path
EOF

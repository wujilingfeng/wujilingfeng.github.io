from distutils.core import setup,Extension
MOD="py_test1"
source=["py_test1.c","py_test1wrapper.c"]
setup(name=MOD,ext_modules=[Extension(MOD,sources=source,include_dirs=["/usr/include/python3.6"])])

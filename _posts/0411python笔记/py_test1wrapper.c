#define PY_SSIZE_T_CLEAN
#include "Python.h"
#include "py_test1.h"
static PyObject *py_test1_fac(PyObject *self,PyObject* args)
{

int n;
if(!PyArg_ParseTuple(args,"i",&n))
{
return NULL;
}
return (PyObject*)Py_BuildValue("i",fac(n));
}
static PyMethodDef py_test1Methods[]=
{
    {"fac",py_test1_fac,METH_VARARGS},
        {NULL,NULL},


};

static  PyModuleDef exmodule={
PyModuleDef_HEAD_INIT,
"py_test1",
NULL,
-1,
py_test1Methods
};

PyMODINIT_FUNC PyInit_py_test1(void)
{
return PyModule_Create(&exmodule);
}
/*void initpy_test1(void)
{
Py_InitModule("py_test1",py_test1Methods);

}*/

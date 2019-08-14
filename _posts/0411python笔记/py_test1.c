#include "py_test1.h"
int fac(int n)
{
if(n<2)
{
return 1;
}
return n*fac(n-1);

}

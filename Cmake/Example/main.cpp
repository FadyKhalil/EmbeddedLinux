#include <iostream>
#include "ClassObject.hpp"
#include "dio.hpp"
#include "port.hpp"

int main(void)
{
    object myObject;
    lamp mylamp;
    myObject.printvalue();

    lamp mylamp2(mylamp);

    mylamp.printvalue();

    getDioPin(3);
    setDioPin(4);

    getPortValue();
    setPortValue();

    return 0;
}
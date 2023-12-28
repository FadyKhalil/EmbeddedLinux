#include "dio.hpp"

int getDioPin(char pin)
{
    dio mydio;
    mydio.dio_getPin(pin);
}

void setDioPin(char pin)
{
    dio mydio;
    mydio.dio_setPin(pin);
}
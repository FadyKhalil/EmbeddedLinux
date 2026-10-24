class dio
{
    private:
        char* STATUS_REGISTER;
        char* PIN_REGISTER;

    public:
        dio()
        {
            STATUS_REGISTER = new char[1];
            PIN_REGISTER = new char[1];
            *STATUS_REGISTER = 1;
            *PIN_REGISTER = 2;
        }

        void dio_setPin(char pin)
        {
            *PIN_REGISTER = 1 << pin;
        }

        int dio_getPin(char pin)
        {
           return (*PIN_REGISTER | 1 << pin); 
        }
};


int getDioPin(char pin);
void setDioPin(char pin);
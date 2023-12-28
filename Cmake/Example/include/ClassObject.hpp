

class object {

    protected:
        int privateValue;
        char* prPtr;
    
    public:
        object()
        {
            privateValue = 0;
            prPtr = new char[2]{1,2};
        }

        virtual void printvalue()
        {
            std::cout << "my value " << privateValue << std::endl;
            std::cout << "my ptr value " << prPtr[0] << std::endl; 
        }

};

class lamp : object {
    private:
        int lampvalue = 1;
    
    public:
        lamp()
        {
            std::cout << "call constructor" << std::endl;
            lampvalue = 2;
        };
    
        lamp(lamp& mySecondObject)
        {
            std::cout << "call copy constructor" <<std::endl;
            mySecondObject.lampvalue = this->lampvalue;
        }

        void printvalue(void) override
        {
            std::cout << "call from child" << std::endl;
        }

        ~lamp() = default;

};
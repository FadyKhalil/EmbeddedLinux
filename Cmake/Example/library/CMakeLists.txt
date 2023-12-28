
# to make library shared put SHARED key word for static STATIC
add_library(mcalLib STATIC
            dio.cpp
            port.cpp)

target_include_directories(mcalLib PUBLIC ${CMAKE_HOME_DIRECTORY}/include)
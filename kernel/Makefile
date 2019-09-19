#
# compiler
#
CC        		= g++
CXXFLAGS 		= -Wall -Wextra -std=c++11 -O3 -DNDEBUG -Wno-deprecated -Wno-ignored-attributes


#
# pfaces-sdk
# 
PFACES_SDK_INC = -I$(PFACES_SDK_ROOT)/include
EXTRA_LNK=-L/usr/local/opt/openssl/lib -lcpprest -lssl -lcrypto -lboost_system -ldl -lpthread

OS := $(shell uname)
ifeq ($(OS),Darwin)
PFACES_SDK_LNK = -L$(PFACES_SDK_ROOT)/lib -Wl,-all_load -lpfaces-sdk -Wl,-noall_load -framework OpenCL -L/usr/local/opt/openssl/lib -lcpprest -lssl -lcrypto -lboost_system -ldl -lpthread
EXTRA_LNK += -lboost_thread-mt -lboost_chrono-mt
CXXFLAGS += -Wno-ignored-attributes
else
PFACES_SDK_LNK = -L$(PFACES_SDK_ROOT)/lib -Wl,--whole-archive -lpfaces-sdk -Wl,--no-whole-archive
EXTRA_LNK += -lstdc++fs
endif

#
# amytiss
#
KERNEL_NAME = pirk
KERNEL_SRC  = $(KERNEL_NAME).cpp


.PHONY: kernel

TARGET = kernel

all: $(TARGET)

kernel: 
	$(CC) -c -o pirk_io.o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) pirk_io.cpp
	$(CC) -c -o pirk_utils.o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) pirk_utils.cpp
	$(CC) -c -o pirk_ctmm.o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) pirk_ctmm.cpp
	$(CC) -c -o pirk_growthbound.o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) pirk_growthbound.cpp
	$(CC) -c -o pirk_montecarlo.o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) pirk_montecarlo.cpp
	
	$(CC) -c -o $(KERNEL_NAME).o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) $(KERNEL_SRC)
	$(CC) -shared -o kernel.so $(PFACES_SDK_LNK) $(EXTRA_LNK) *.o
	cp kernel.so ../kernel-pack/$(KERNEL_NAME).driver

clean:
	rm -f -r Debug
	rm -f -r Release
	rm -f -r x64
	rm -f -r .vs
	rm -f *.o
	rm -f *.so

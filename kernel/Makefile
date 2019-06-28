#
# compiler
#
CC        		= g++
#CXXFLAGS 		= -Wall -Wextra -std=c++11 -O3 -DNDEBUG -Wno-ignored-attributes -Wno-deprecated  # no debug
CXXFLAGS 		= -Wall -g -Wextra -std=c++11 -O0 -Wno-ignored-attributes -Wno-deprecated  # yes debug

#
# pfaces-sdk
# 
PFACES_SDK_ROOT	= ../../../pfaces-sdk
PFACES_SDK_INC = -I$(PFACES_SDK_ROOT)/include
PFACES_SDK_LNK = -L$(PFACES_SDK_ROOT)/lib -lpfaces-sdk

#
# amytiss
#
KERNEL_NAME = pirk
KERNEL_SRC  = $(KERNEL_NAME).cpp


.PHONY: kernel

TARGET = kernel

all: $(TARGET)

kernel: 
	$(CC) -c -o kernel.o -fPIC $(CXXFLAGS) $(PFACES_SDK_INC) $(KERNEL_SRC)
	$(CC) -shared -o kernel.so -Wl,--whole-archive $(PFACES_SDK_LNK) -Wl,--no-whole-archive kernel.o
	cp kernel.so ../kernel-pack/driver.so

clean:
	rm -f -r Debug
	rm -f -r Release
	rm -f -r x64
	rm -f -r .vs
	rm *.o *.so

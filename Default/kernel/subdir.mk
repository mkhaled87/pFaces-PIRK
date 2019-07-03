################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../kernel/pirk.cpp \
../kernel/pirk_growthbound.cpp \
../kernel/pirk_utils.cpp 

O_SRCS += \
../kernel/kernel.o 

OBJS += \
./kernel/pirk.o \
./kernel/pirk_growthbound.o \
./kernel/pirk_utils.o 

CPP_DEPS += \
./kernel/pirk.d \
./kernel/pirk_growthbound.d \
./kernel/pirk_utils.d 


# Each subdirectory must supply rules for building sources it contributes
kernel/%.o: ../kernel/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross G++ Compiler'
	g++ -std=c++11 -I../../../pfaces-sdk/include -O0 -g -Wall -Wextra -c -o kernel.o -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

kernel/pirk_growthbound.o: ../kernel/pirk_growthbound.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross G++ Compiler'
	g++ -std=c++11 -I../../../pfaces-sdk/include -O0 -g -Wall -Wextra -Wno-ignored-attributes -Wno-deprecated -MMD -MP -MF"$(@:%.o=%.d)" -MT"kernel/pirk_growthbound.d" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



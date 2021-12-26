# iamge
FROM ubuntu:20.04

# update image
RUN apt-get update
RUN apt-get install -y tzdata
RUN apt-get -y upgrade

# install required libs/tools
RUN apt-get install -y cmake wget git unzip build-essential cmake libcpprest-dev opencl-c-headers opencl-clhpp-headers ocl-icd-opencl-dev clinfo oclgrind

# install pFaces 1.2.1d
RUN mkdir pfaces; cd pfaces; wget https://github.com/parallall/pFaces/releases/download/Release_1.2.1d/pFaces-1.2.1-Ubuntu20.04.zip; unzip pFaces-1.2.1-Ubuntu20.04.zip; sh ./install.sh

# install PIRK
RUN git clone --depth=1 https://github.com/mkhaled87/pFaces-PIRK
RUN cd pFaces-PIRK; export PFACES_SDK_ROOT=$PWD/../pfaces/pfaces-sdk/; sh build.sh

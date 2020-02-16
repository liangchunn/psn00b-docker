#!/bin/bash
set -e

# runtime
INSTALL_RUNTIME_DIR=/install-runtime
MAKE_THREADS=4

# versions
GCC_VERSION=7.4.0
BINUTILS_VERSION=2.31.1

# paths
ROOT_DIR=/
GCC_DIR=/gcc
GCC_BUILD_DIR=/gcc/gcc-build
BINUTILS_BUILD_DIR=/gcc/binutils-build
PS_NOOB_SDK_DIR=/psn00bsdk

cd $ROOT_DIR


##########
# system #
##########

# update and upgrade system packages
apt-get update
apt-get -y upgrade


################################
# psn00bsdk dependencies setup #
################################

# install dependencies of psn00bsdk
apt-get -y install build-essential git pkg-config cmake texinfo libmpfr-dev libisl-dev libgmp-dev libmpc-dev libtinyxml2-dev wget

# create folders
mkdir -p $GCC_DIR $GCC_BUILD_DIR $BINUTILS_BUILD_DIR

# download + extract `binutils` and `gcc`
cd $GCC_DIR
wget ftp://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz
wget ftp://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar -xvzf binutils-${BINUTILS_VERSION}.tar.gz
tar -xvzf gcc-${GCC_VERSION}.tar.gz

# build binutils
cd $BINUTILS_BUILD_DIR
../binutils-${BINUTILS_VERSION}/configure --prefix=/usr/local/mipsel-unknown-elf \
--target=mipsel-unknown-elf --with-float=soft
make -j ${MAKE_THREADS}
make install-strip

# build gcc
cd $GCC_BUILD_DIR
../gcc-${GCC_VERSION}/configure --disable-nls --disable-libada --disable-libssp \
--disable-libquadmath --disable-libstdc++-v3 --target=mipsel-unknown-elf \
--prefix=/usr/local/mipsel-unknown-elf --with-float=soft \
--enable-languages=c,c++ --with-gnu-as --with-gnu-ld
make -j ${MAKE_THREADS}
make install-strip

export PATH="/usr/local/mipsel-unknown-elf/bin:$PATH"


###########
# patches #
###########

# patch linker
patch -d /usr/local/mipsel-unknown-elf/mipsel-unknown-elf/lib/ldscripts/ < ${INSTALL_RUNTIME_DIR}/elf32elmip.patch


###################
# psn00bsdk setup #
###################

# set up psn00bsdk/tools
cd $ROOT_DIR
git clone https://github.com/Lameguy64/PSn00bSDK.git psn00bsdk
cd ${PS_NOOB_SDK_DIR}/tools
make all install
export PATH="/psn00bsdk/tools/bin:$PATH"

# set up psn00bsdk/libpsn00b
cd ${PS_NOOB_SDK_DIR}/libpsn00b
make

# try compiling example `n00bdemo`
cd ${PS_NOOB_SDK_DIR}/examples/n00bdemo
make


##########
# extras #
##########

# install mkpsxiso
cd ${PS_NOOB_SDK_DIR}/tools
git clone https://github.com/Lameguy64/mkpsxiso.git
cd mkpsxiso
cmake .
make 
export PATH="/psn00bsdk/tools/mkpsxiso/bin_nix:$PATH"


#########################
# use environemnt setup #
#########################

# set up path
echo 'export PATH="/psn00bsdk/tools/mkpsxiso/bin_nix:/psn00bsdk/tools/bin:/usr/local/mipsel-unknown-elf/bin:$PATH"' >> ~/.bashrc

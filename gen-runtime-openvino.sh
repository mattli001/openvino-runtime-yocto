#!/bin/sh

# this script will generate openvino runtime from l_openvino_toolkit_p_2018.2.300.tgz, i.e. openvino r2.

# export BN=intel-cv-sdk-base-l-ipu-firmware-yocto-300-2018.0-300.noarch

# extract rpm files
echo -n extract tpm files ...
# tar zxf l_openvino_toolkit_p_2018.2.300.tgz l_openvino_toolkit_p_2018.2.300/rpm --strip-components 1
echo OK

# define rootfs structure
export USRBIN=rootfs/usr/bin
export USRLIB=rootfs/usr/lib
export LIB64=rootfs/lib64
export SYSCONF=rootfs/etc
export UDEVRULESD=${SYSCONF}/udev/rules.d
export LDCONFD=${SYSCONF}/ld.so.conf.d
export OPENVINO_CONF=${SYSCONF}/ld.so.conf.d/openvino.conf
export OPENCLCONFD=${SYSCONF}/OpenCL/vendors
export OPENVINO_LIB=rootfs/usr/lib/openvino/lib
export OPENVINO_EXT=rootfs/usr/lib/openvino/external
export OPENCV=rootfs/usr/lib/opencv
export OPENCL=rootfs/usr/lib/opencl
export OPENVX=rootfs/usr/lib/openvx
export OPENVINO_RUNTIME_TGZ=openvino-runtime.tgz

# set up rootfs structure
echo -n set up rootfs structure ...
mkdir -p ${OPENVINO_LIB} ${OPENVINO_EXT} ${OPENCV} ${OPENCL} ${OPENVX} ${USRBIN} ${SYSCONF} ${UDEVRULESD} ${LDCONFD} ${OPENCLCONFD} ${LIB64}
echo OK

# openvino IE
echo -n install openvino IE libs ...
rpm2cpio rpm/intel-cv-sdk-base-l-inference-engine-300-2018.0-300.noarch.rpm | cpio -id ./opt/intel/computer_vision_sdk_2018.2.300/deployment_tools/inference_engine/lib/ubuntu_16.04/intel64/* ./opt/intel/computer_vision_sdk_2018.2.300/deployment_tools/inference_engine/external/*
mv ./opt/intel/computer_vision_sdk_2018.2.300/deployment_tools/inference_engine/lib/ubuntu_16.04/intel64/* ${OPENVINO_LIB}
mv ./opt/intel/computer_vision_sdk_2018.2.300/deployment_tools/inference_engine/external/97-usbboot.rules ${UDEVRULESD}
mv ./opt/intel/computer_vision_sdk_2018.2.300/deployment_tools/inference_engine/external/* ${OPENVINO_EXT}
echo OK

# opencv
echo -n install opencv libs ...
rpm2cpio rpm/intel-cv-sdk-base-l-ocv-yocto-300-2018.0-300.noarch.rpm | cpio -id ./opt/intel/computer_vision_sdk_2018.2.300/opencv/lib/*
mv ./opt/intel/computer_vision_sdk_2018.2.300/opencv/lib/* ${OPENCV}
echo OK

# openvx
echo -n install openvx libs ...
rpm2cpio rpm/intel-cv-sdk-base-l-ovx-rt-yocto-300-2018.0-300.noarch.rpm | cpio -id ./opt/intel/computer_vision_sdk_2018.2.300/openvx/lib/*
mv ./opt/intel/computer_vision_sdk_2018.2.300/openvx/lib/* ${OPENVX}
echo OK

# ipu firmware
echo -n install ipu firmware for yocto ...
rpm2cpio rpm/intel-cv-sdk-base-l-ipu-firmware-yocto-300-2018.0-300.noarch.rpm | cpio -id
cd rootfs
rpm2cpio ../opt/intel/computer_vision_sdk_2018.2.300/l_ipu_firmware_yocto/ipu4fw-cvsdk-r12018-20170225.rpm | cpio -id
rpm2cpio ../opt/intel/computer_vision_sdk_2018.2.300/l_ipu_firmware_yocto/ipucompute-1.0.3-2018r1.x86_64.rpm | cpio -id
cd ..
echo OK

# opencl
echo -n install opencl libs (Please prepare proper opencl, here use a built-in-house version) ...
cp ./opencl/* ${OPENCL}
echo OK

# config files
echo -n install configuration files ...
echo "/usr/lib/openvino/lib" > ${OPENVINO_CONF}
echo "/usr/lib/openvino/external/mkltiny_lnx/lib" >> ${OPENVINO_CONF}
echo "/usr/lib/openvino/external/cldnn/lib" >> ${OPENVINO_CONF}
echo "/usr/lib/openvino/external/gna/lib" >> ${OPENVINO_CONF}
echo "/usr/lib/opencv" >> ${OPENVINO_CONF}
echo "/usr/lib/opencl" >> ${OPENVINO_CONF}
echo "/usr/lib/openvx" >> ${OPENVINO_CONF}
echo "include ld.so.conf.d/openvino.conf" > ${SYSCONF}/ld.so.conf

echo "/usr/lib/opencl/libigdrcl.so" > ${OPENCLCONFD}/intel.icd
echo OK

# misc dependency
echo -n copy misc dependency files ...
cp -a depend/libcpu_extension.so depend/libformat_reader.so ${USRLIB}
echo OK

# add missing lib64/ld-linux-x86-64.so.2
#echo -n add missing lib64/ld-linux-x86-64.so.2 ...
#ln -s /lib/ld-linux-x86-64.so.2 ${LIB64}/ld-linux-x86-64.so.2
#echo OK

# generate tarball for yocto
echo -n packaing ...
cd rootfs
tar zcf ${OPENVINO_RUNTIME_TGZ} *
echo OK

echo The generated file is ${OPENVINO_RUNTIME_TGZ}
echo finished

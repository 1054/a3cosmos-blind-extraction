#!/bin/bash
# 

# 
# About PyBDSF
# 
# PyBDSF (or PyBDSM) is an astronomical image blob detection tool. 
# See [http://www.astron.nl/citt/pybdsf](http://www.astron.nl/citt/pybdsf).
# 


# cd
cd $(dirname "${BASH_SOURCE[0]}")


# Python

os_system=linux
py_version=3.7
py_prefix="$(pwd)/${os_system}_python${py_version}"


set -e

if [[ ! -d "${py_prefix}/lib" ]]; then
    
    mkdir -p "${py_prefix}/lib"
    
    
    # 
    # boost-python3
    # 
    conda create -n condapy37 python=3.7 gxx_linux-64=7.2.0 gfortran_linux-64=7.2.0 boost=1.67.0 libboost=1.67.0
    conda activate condapy37
    python3.7 -m pip install numpy scipy astropy matplotlib backports.shutil_get_terminal_size
    cp "$CONDA_PREFIX/lib/libboost_python.so"           "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libboost_python37.so"         "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libboost_python37.so.1.67.0"  "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libboost_numpy.so"            "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libboost_numpy37.so"          "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libboost_numpy37.so.1.67.0"   "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libgfortran.so.4"             "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libquadmath.so.0"             "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libgcc_s.so.1"                "${py_prefix}/lib/"
    cp "$CONDA_PREFIX/lib/libstdc++.so.6"               "${py_prefix}/lib/"
    #cp "/usr/lib64/libgfortran.so.3"                    "${py_prefix}/lib/"
    
    cp -i $GXX $CONDA_PREFIX/$HOST/bin/g++ # see reason below
    cp -i $GFORTRAN $CONDA_PREFIX/$HOST/bin/gfortran # current PyBDSF (v1.9.0) setup.py calls gfortran, but some system gfortran is not new enough, so we use conda gfortran_linux-64=7.2.0
    
    python3.7 -m pip install --ignore-installed --prefix="${py_prefix}" numpy scipy astropy backports.shutil_get_terminal_size
    
    #conda deactivate
    #conda env remove -n condapy37
    
    
    # 
    # git
    # 
    git clone https://github.com/lofar-astron/PyBDSF.git
    # 
    cd PyBDSF
    export PATH="$CONDA_PREFIX/$HOST/bin:$CONDA_PREFIX/bin:/usr/local/bin:/usr/bin:/bin:."
    export PYTHONPATH="${py_prefix}/lib/python3.7/site-packages"
    # 
    perl -i.bak -p -e "s/libraries=libraries/libraries=['minpack', 'port3', 'gfortran', 'boost_numpy37', 'boost_python37', 'python3.7m']/g" setup.py
    # 
    ls $CONDA_PREFIX/include/boost
    type gfortran
    # 
    rm -rf build/
    rm bdsf/_cbdsm*.so
    #GCC=x86_64-conda_cos6-linux-gnu-gcc \
    #GXX=$CONDA_PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran \
    python3.7 setup.py build_ext --inplace \
                                 --include-dirs="$CONDA_PREFIX/include" \
                                 --library-dirs="../${os_system}_python${py_version}/lib" \
                                 --library-dirs="$CONDA_PREFIX/$HOST/lib" \
                                 --library-dirs="$CONDA_PREFIX/lib" \
                                 --libraries="boost_numpy37" \
                                 --libraries="boost_python37" \
                                 --libraries="gfortran" \
                                 --libraries="python3.7m" \
                                 --rpath "${py_prefix}/lib" \
                         install --prefix="${py_prefix}"
    # 
    py_outdir=$(ls -1d "${py_prefix}/lib/python3.7/site-packages/bdsf-"*".egg" | head -n 1)
    echo $py_outdir
    # 
    cp "bdsf/_cbdsm.cpython-37m-x86_64-linux-gnu.so"            "${py_outdir}/bdsf/"
    cp "bdsf/_pytesselate.cpython-37m-x86_64-linux-gnu.so"      "${py_outdir}/bdsf/"
    cp "bdsf/nat/natgridmodule.cpython-37m-x86_64-linux-gnu.so" "${py_outdir}/bdsf/nat/"
    # 
    conda install patchelf
    # 
    ldd "${py_outdir}/bdsf/_cbdsm.cpython-37m-x86_64-linux-gnu.so"
    objdump -x "${py_outdir}/bdsf/_cbdsm.cpython-37m-x86_64-linux-gnu.so" | grep -i RPATH
    patchelf --set-rpath "${py_prefix}/lib:$CONDA_PREFIX/lib" "${py_outdir}/bdsf/_cbdsm.cpython-37m-x86_64-linux-gnu.so"
    # 
    ldd "${py_outdir}/bdsf/_pytesselate.cpython-37m-x86_64-linux-gnu.so"
    objdump -x "${py_outdir}/bdsf/_pytesselate.cpython-37m-x86_64-linux-gnu.so" | grep -i RPATH
    patchelf --set-rpath "${py_prefix}/lib:$CONDA_PREFIX/lib" "${py_outdir}/bdsf/_pytesselate.cpython-37m-x86_64-linux-gnu.so"
    # 
    ldd "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-x86_64-linux-gnu.so"
    objdump -x "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-x86_64-linux-gnu.so" | grep -i RPATH
    patchelf --set-rpath "${py_prefix}/lib:$CONDA_PREFIX/lib" "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-x86_64-linux-gnu.so"
    
else
    
    py_outdir=$(ls -1d "${py_prefix}/lib/python3.7/site-packages/bdsf-"*".egg" | head -n 1)
    echo $py_outdir
    
    # conda install patchelf
    patchelf --set-rpath "${py_prefix}/lib:$CONDA_PREFIX/lib" "${py_outdir}/bdsf/_cbdsm.cpython-37m-x86_64-linux-gnu.so"
    patchelf --set-rpath "${py_prefix}/lib:$CONDA_PREFIX/lib" "${py_outdir}/bdsf/_pytesselate.cpython-37m-x86_64-linux-gnu.so"
    patchelf --set-rpath "${py_prefix}/lib:$CONDA_PREFIX/lib" "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-x86_64-linux-gnu.so"
    
    ldd "${py_outdir}/bdsf/_cbdsm.cpython-37m-x86_64-linux-gnu.so"
    ldd "${py_outdir}/bdsf/_pytesselate.cpython-37m-x86_64-linux-gnu.so"
    ldd "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-x86_64-linux-gnu.so"

fi





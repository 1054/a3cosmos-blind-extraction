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

os_system=mac
py_version=3.7
py_prefix="$(pwd)/${os_system}_python${py_version}"


set -e

if [[ ! -d "${py_prefix}/lib" ]]; then
    
    mkdir -p "${py_prefix}/lib"
    
    pip-3.7 install --ignore-installed --prefix="${py_prefix}" numpy scipy astropy backports.shutil_get_terminal_size
    
    
    # 
    # boost-python3
    # 
    # brew install boost-python3
    # ls /usr/local/Cellar/boost-python3/1.71.0/lib/
    # 
    # or I forgot where I installed these
    cp "/usr/local/opt/boost-python3/lib/libboost_python37-mt.dylib" "${py_prefix}/lib/"
    cp "/usr/local/opt/boost-python3/lib/libboost_python37-mt.dylib" "${py_prefix}/lib/libboost_python3-mt.dylib"

    cp "/usr/local/opt/boost-python3/lib/libboost_numpy37-mt.dylib" "${py_prefix}/lib/"
    cp "/usr/local/opt/boost-python3/lib/libboost_numpy37-mt.dylib" "${py_prefix}/lib/libboost_numpy3-mt.dylib"

    cp "/opt/local/lib/libgcc/libgcc_s.1.dylib"     "${py_prefix}/lib/"
    cp "/opt/local/lib/libgcc/libgfortran.3.dylib"  "${py_prefix}/lib/"
    cp "/opt/local/lib/libgcc/libgfortran.5.dylib"  "${py_prefix}/lib/"
    cp "/opt/local/lib/libgcc/libquadmath.0.dylib"  "${py_prefix}/lib/"
    
    
    # 
    # git
    # 
    git clone https://github.com/lofar-astron/PyBDSF.git
    # 
    cd PyBDSF
    export PATH=".:/opt/local/bin:/usr/local/bin:/usr/bin:/bin"
    export PYTHONPATH="${py_prefix}/lib/python3.7/site-packages"
    # 
    perl -i.bak -p -e "s/libraries=libraries/libraries=['minpack', 'port3', 'gfortran.3', 'boost_numpy3-mt', 'boost_python3-mt']/g" setup.py
    # 
    ls /usr/local/opt/boost/include/boost/python
    # 
    rm -rf build/
    rm bdsf/_cbdsm*.so
    python3.7 setup.py build_ext --inplace \
                                 --include-dirs="/usr/local/opt/boost/include" \
                                 --library-dirs="../${os_system}_python${py_version}/lib" \
                                 --libraries="boost_numpy3-mt" \
                                 --libraries="boost_python3-mt" \
                                 --libraries="gfortran.3" \
                                 --rpath "${py_prefix}/lib" \
                         install --prefix="${py_prefix}"
    # 
    py_outdir=$(ls -1d "${py_prefix}/lib/python3.7/site-packages/bdsf-"*".egg" | head -n 1)
    echo $py_outdir
    # 
    cp "bdsf/_cbdsm.cpython-37m-darwin.so"            "${py_outdir}/bdsf/"
    cp "bdsf/_pytesselate.cpython-37m-darwin.so"      "${py_outdir}/bdsf/"
    cp "bdsf/nat/natgridmodule.cpython-37m-darwin.so" "${py_outdir}/bdsf/nat/"
    # 
    otool -L "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    install_name_tool -change @rpath/libgfortran.3.dylib                                    @rpath/libgfortran.3.dylib        "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    install_name_tool -change /usr/local/opt/boost-python3/lib/libboost_numpy37-mt.dylib    @rpath/libboost_numpy37-mt.dylib  "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    install_name_tool -change /usr/local/opt/boost-python3/lib/libboost_python37-mt.dylib   @rpath/libboost_python37-mt.dylib "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    install_name_tool -add_rpath "${py_prefix}/lib" "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    otool -L "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    # 
    otool -L "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    install_name_tool -change @rpath/libgfortran.3.dylib                                    @rpath/libgfortran.3.dylib        "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    install_name_tool -change /opt/local/lib/libgcc/libgfortran.5.dylib                     @rpath/libgfortran.5.dylib        "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    install_name_tool -change /opt/local/lib/libgcc/libgcc_s.1.dylib                        @rpath/libgcc_s.1.dylib           "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    install_name_tool -change /opt/local/lib/libgcc/libquadmath.0.dylib                     @rpath/libquadmath.0.dylib        "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    install_name_tool -add_rpath "${py_prefix}/lib" "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    otool -L "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    # 
    otool -L "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-darwin.so"
    install_name_tool -change /usr/local/opt/boost-python3/lib/libboost_python37-mt.dylib   @rpath/libboost_python37-mt.dylib "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-darwin.so"
    install_name_tool -add_rpath "${py_prefix}/lib" "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-darwin.so"
    otool -L "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-darwin.so"

else
    
    py_outdir=$(ls -1d "${py_prefix}/lib/python3.7/site-packages/bdsf-"*".egg" | head -n 1)
    echo $py_outdir
    install_name_tool -add_rpath "${py_prefix}/lib" "${py_outdir}/bdsf/_cbdsm.cpython-37m-darwin.so"
    install_name_tool -add_rpath "${py_prefix}/lib" "${py_outdir}/bdsf/_pytesselate.cpython-37m-darwin.so"
    install_name_tool -add_rpath "${py_prefix}/lib" "${py_outdir}/bdsf/nat/natgridmodule.cpython-37m-darwin.so"

fi





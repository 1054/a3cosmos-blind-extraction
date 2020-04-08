#!/bin/bash
# 
# About PyBDSF
# 
# PyBDSF (or PyBDSM) is an astronomical image blob detection tool. 
# See [http://www.astron.nl/citt/pybdsf](http://www.astron.nl/citt/pybdsf).
# 
# 20191128
# 


# cd
cd $(dirname "${BASH_SOURCE[0]}")


if [[ $(type conda 2>/dev/null | wc -l) -eq 0 ]]; then
    echo "Error! Please install CONDA!"
    exit 255
fi


if [[ $(conda env list | grep "^condapy37" | wc -l) -eq 0 ]]; then
    
    # 
    # conda create environment
    # 
    conda create -n condapy37 python=3.7 gxx_linux-64=7.2.0 gfortran_linux-64=7.2.0 boost=1.67.0 libboost=1.67.0
    conda activate condapy37
    python3.7 -m pip install numpy scipy astropy matplotlib backports.shutil_get_terminal_size
    
    # adapt to PyBDSF setup.py naming
    ln -s libboost_python.so $CONDA_PREFIX/lib/libboost_python-py37.so
    ln -s libboost_numpy.so $CONDA_PREFIX/lib/libboost_numpy3-py37.so # otherwise PyBDSF setup.py can not find this.

    # use newer gfortran
    cp -i $GXX $CONDA_PREFIX/$HOST/bin/g++ # see reason below
    cp -i $GFORTRAN $CONDA_PREFIX/$HOST/bin/gfortran # current PyBDSF (v1.9.1) setup.py calls gfortran, but some system gfortran is not new enough, so we use conda gfortran_linux-64=7.2.0

    # prepare a clean PATH etc for compiling
    export PATH=$CONDA_PREFIX/$HOST/bin:$CONDA_PREFIX/bin:$(dirname $(dirname $CONDA_EXE))/condabin:/usr/local/bin:/usr/bin:/bin.
    export LD_LIBRARY_PATH=
    export PYTHONPATH=

    # compile
    LDFLAGS="$LDFLAGS -shared -fPIC" \
    python3.7 -m pip \
    install \
    --global-option="build_ext" \
    --global-option="-I$CONDA_PREFIX/include" \
    --global-option="-L$CONDA_PREFIX/lib" \
    --global-option="-lpython3.7m" \
    --global-option="-R$CONDA_PREFIX/lib" \
    https://github.com/lofar-astron/PyBDSF/archive/v1.9.1.tar.gz

    # run bdsf
    python -c 'import bdsf'
    
    #conda deactivate
    #conda env remove -n condapy37
    
else
    
    conda activate condapy37
    
    python -c 'import bdsf'
    
fi





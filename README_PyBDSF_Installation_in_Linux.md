### Installation of PyBDSM/PyBDSF under conda environment in Linux
```
#1. Before installing PyBDSF, we need conda installed and activated (https://docs.conda.io/en/latest/)

conta install python=3.7


#2. Installing the boost_python stuff with conda:

conda install gxx_linux-64=7.2.0 gfortran_linux-64=7.2.0 boost=1.67.0 libboost=1.67.0 numpy scipy astropy matplotlib backports.shutil_get_terminal_size


#3. This step is optional. List the files to make sure we have them.

echo $CONDA_PREFIX # make sure it is not empty
ls $CONDA_PREFIX/lib/libboost_python*
ls $CONDA_PREFIX/lib/libboost_numpy*
ls $CONDA_PREFIX/lib/libgfortran*


#4. This step is for Linux only. Make some fixes so that we can use conda g++/gfortran instead of the system g++/gfortran (I tested that we have to do these steps even for the latest PyBDSF):

cp -i $GXX $CONDA_PREFIX/$HOST/bin/g++ # for Linux only
cp -i $GFORTRAN $CONDA_PREFIX/$HOST/bin/gfortran # for Linux only

# for PyBDSF version <= 1.9.0
#cp -i $CONDA_PREFIX/lib/libboost_python37.dylib $CONDA_PREFIX/lib/libboost_python3-mt.dylib
#cp -i $CONDA_PREFIX/lib/libboost_numpy37.dylib $CONDA_PREFIX/lib/libboost_numpy3-mt.dylib


#5. Clear PATH so that we will use conda g++/gfortran to compile

# for Linux only
export PATH=$CONDA_PREFIX/$HOST/bin:$CONDA_PREFIX/bin:$(dirname $(dirname $CONDA_EXE))/condabin:/usr/local/bin:/usr/bin:/bin:. 
export LD_LIBRARY_PATH=
export PYTHONPATH=
#export LDFLAGS="$LDFLAGS -shared -fPIC"


#6. Compile the latest PyBDSF v1.9.2 as of today (April. 7, 2020). Note that under conda environment LDFLAGS exists and seems should be used.

pip \
install \
--global-option="build_ext" \
--global-option="-I$CONDA_PREFIX/include" \
--global-option="-L$CONDA_PREFIX/lib" \
--global-option="-lpython3.7m" \
--global-option="-R$CONDA_PREFIX/lib" \
https://github.com/lofar-astron/PyBDSF/archive/v1.9.2.tar.gz


#7. Finished! If we run import bdsf in python it should report no error now (as far as I tested under Linux with conda python3.7)

python -c "import bdsf; print(bdsf.__path__)"
```


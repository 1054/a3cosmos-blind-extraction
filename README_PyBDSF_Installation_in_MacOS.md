### Installation of PyBDSM/PyBDSF under conda environment in MacOS
```
#1. Before installing PyBDSF, we need conda installed and activated (https://docs.conda.io/en/latest/)

conta install python=3.7


#2. Installing the boost_python stuff with conda:

conda install gfortran_osx-64 clangxx_osx-64 boost=1.67.0 libboost=1.67.0 numpy scipy astropy matplotlib backports.shutil_get_terminal_size


#3. This step is optional. List the files to make sure we have them.

echo $CONDA_PREFIX # make sure it is not empty
ls $CONDA_PREFIX/lib/libboost_python*
ls $CONDA_PREFIX/lib/libboost_numpy*
ls $CONDA_PREFIX/lib/libgfortran*

#4. Make some fixes (for older version of PyBDSF):

# for PyBDSF version <= 1.9.0
#cp -i $CONDA_PREFIX/lib/libboost_python37.dylib $CONDA_PREFIX/lib/libboost_python3-mt.dylib
#cp -i $CONDA_PREFIX/lib/libboost_numpy37.dylib $CONDA_PREFIX/lib/libboost_numpy3-mt.dylib

#5. Clear PATH for compiling

# for MacOS only (10.14)
export PATH=$CONDA_PREFIX/bin:$(dirname $(dirname $CONDA_EXE))/condabin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:.
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:/usr/local/lib:/usr/lib:/lib:.
export PYTHONPATH=$CONDA_PREFIX/lib/python3.7/site-packages

#6. Compile the latest PyBDSF v1.9.2 as of today (April. 7, 2020). Note that under conda environment LDFLAGS exists and seems should be used.

wget https://github.com/lofar-astron/PyBDSF/archive/v1.9.2.tar.gz

# If using conda Python and gcc/gfortran
export PATH=$CONDA_PREFIX/bin:/usr/local/bin:/usr/bin:/bin:.
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib
export PYTHONPATH=$CONDA_PREFIX/lib/python3.7/site-packages
$CONDA_PREFIX/bin/pip \
install \
--global-option="build_ext" \
--global-option="--include-dirs=$CONDA_PREFIX/include" \
--global-option="--library-dirs=$CONDA_PREFIX/lib" \
--global-option="--libraries=python3.7m" \
--global-option="--libraries=boost_python37" \
--global-option="--libraries=boost_numpy37" \
--log pip.log \
v1.9.2.tar.gz

# If using system Python and gcc/gfortran
bash
tar -xzf v1.9.2.tar.gz
cd PyBDSF-1.9.2
mkdir inc
mkdir lib
export TEMP_CONDA_PREFIX=/anaconda3/envs/condapy37
export TEMP_PYTHON_PREFIX=/opt/local/Library/Frameworks/Python.framework/Versions/3.7/lib
export TEMP_LIBGCC_PREFIX=/opt/local/lib/libgcc
export PATH=/opt/local/bin:/usr/local/bin:/usr/bin:/bin:.
export LD_LIBRARY_PATH=$(pwd)/lib:/opt/local/lib
export PYTHONPATH=$PYTHON_PREFIX_TEMP/python3.7/site-packages
cp -r $TEMP_CONDA_PREFIX/include/boost inc/boost
cp $TEMP_CONDA_PREFIX/lib/libboost_python37.dylib lib/
cp $TEMP_CONDA_PREFIX/lib/libboost_numpy37.dylib lib/
cp $TEMP_PYTHON_PREFIX/lib/libpython3.7m.dylib lib/
cp $TEMP_LIBGCC_PREFIX/libgfortran.dylib lib/
cp $TEMP_LIBGCC_PREFIX/libgfortran.3.dylib lib/
cp $TEMP_LIBGCC_PREFIX/libquadmath.0.dylib lib/
python3.7 setup.py build_ext --inplace \
--include-dirs="$(pwd)/inc" \
--library-dirs="$(pwd)/lib" \
--libraries="boost_python37" \
--libraries="boost_numpy37" \
--libraries="python3.7m" \
2>&1 | tee pip.log

python3.7 -c "from ctypes import CDLL; print(CDLL('bdsf/_cbdsm.cpython-37m-darwin.so'))"

#then rerun with install --user, but the dylib are not copied somehow....
#cp lib/* bdsf/
#otool -L "bdsf/_cbdsm.cpython-37m-darwin.so"
#install_name_tool -add_rpath "$(pwd)/lib" "bdsf/_cbdsm.cpython-37m-darwin.so"

#8. Finished! If we run import bdsf in python it should report no error now (as far as I tested under Linux with conda python3.7)

PYTHONPATH= \
python -c "import bdsf; print(bdsf.__path__)"

# We can also edit $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh and $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh for the $PYTHONPATH 
```


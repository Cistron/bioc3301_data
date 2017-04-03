module unload compilers
module load compilers/gnu/4.9.2
virtualenv qiime191
source qiime191/bin/activate
pip install --no-cache-dir numpy
export BLAS=/shared/ucl/apps/openblas/0.2.14/gnu-4.9.2/lib/libblas.so
export LAPACK=/shared/ucl/apps/openblas/0.2.14/gnu-4.9.2/lib/liblapack.so
pip install --no-cache-dir scipy
pip install https://github.com/biocore/qiime/archive/1.9.1.tar.gz --no-cache-dir
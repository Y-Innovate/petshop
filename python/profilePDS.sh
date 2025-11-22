#!/bin/sh

PYZ=/usr/lpp/IBM/cyp/v3r13/pyz

export PATH=$PYZ/bin:$PATH
export LIBPATH=$PYZ/lib:$LIBPATH

export _BPXK_AUTOCVT='ON'
export _CEE_RUNOPTS='FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)'
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt

thisdir=$(dirname $0)

cd $thisdir
cd ..
 

python python/profilePDS.py $1 $2 $3 $4

exit 0

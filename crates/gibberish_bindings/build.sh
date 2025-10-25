#!/bin/bash
# QBE IR -> target assembly
qbe -o slice.s slice.qbe             
# Assemble to position-independent object (PIC is fine for both static/shared)
cc -c -fPIC slice.s -o slice.o

# Archive into a static library
ar rcs libqbeslice.a slice.o

mv ./libqbeslice.a ./qbe/libqbeslice.a 

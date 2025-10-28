#!/bin/bash

cargo run --bin gibberish -- build examples/simple.gib --output crates/gibberish_bindings/slice.qbe

# QBE IR -> target assembly
qbe -o crates/gibberish_bindings/slice.s crates/gibberish_bindings/slice.qbe             
# Assemble to position-independent object (PIC is fine for both static/shared)
cc -c -fPIC crates/gibberish_bindings/slice.s -o crates/gibberish_bindings/slice.o

# Archive into a static library
ar rcs crates/gibberish_bindings/libqbeslice.a crates/gibberish_bindings/slice.o

mv crates/gibberish_bindings/libqbeslice.a crates/gibberish_bindings/qbe/libqbeslice.a 

cargo run --bin gibberish_bindings

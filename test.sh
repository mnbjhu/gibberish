#!/bin/bash

cargo run --bin gibberish -- build --kind=dynamic --output=test-parser.so ./examples/self.gib
cargo run --bin gibberish -- build --kind=qbe --output=test-parser.qbe ./examples/self.gib
cargo run --bin gibberish_dyn_lib -- parse /home/james/projects/gibberish/test-parser.so test.txt
 

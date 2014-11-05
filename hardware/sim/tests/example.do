start exampleTestBench
file copy -force ../../../software/example/example.mif imem_blk_ram.mif
file copy -force ../../../software/example/example.mif dmem_blk_ram.mif
add wave exampleTestBench/*
add wave exampleTestBench/CPU/*
run 10000us

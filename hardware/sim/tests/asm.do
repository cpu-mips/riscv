start AsmTestbench
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
file copy -force ../../../software/asmtest/asmtest.mif bios_mem.mif
file copy -force ../../../software/asmtest/asmtest.mif dmem_blk_ram.mif
add wave AsmTestbench/*
add wave AsmTestbench/uart/*
add wave AsmTestbench/CPU/*
add wave AsmTestbench/CPU/io/*
add wave AsmTestbench/CPU/io/uart/*
add wave AsmTestbench/CPU/io/uart/uatransmit/*
add wave AsmTestbench/CPU/io/uart/uareceive/*
add wave AsmTestbench/CPU/memoryproc/*
add wave AsmTestbench/CPU/regfile/*
run 10000us

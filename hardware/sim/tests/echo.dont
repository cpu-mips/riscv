start EchoTestbench
file copy -force ../../../software/asmtest/asmtest.mif imem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif bios_mem.mif
file copy -force ../../../software/echo/echo.mif dmem_blk_ram.mif
add wave EchoTestbench/*
add wave EchoTestbench/uart/*
add wave EchoTestbench/CPU/*
add wave EchoTestbench/CPU/io/*
add wave EchoTestbench/CPU/io/uart/*
add wave EchoTestbench/CPU/io/uart/uatransmit/*
add wave EchoTestbench/CPU/io/uart/uareceive/*
add wave EchoTestbench/CPU/memoryproc/*
run 10000us

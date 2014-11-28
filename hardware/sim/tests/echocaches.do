start EchoTestbenchCaches
file copy -force ../../../software/echo/echo.mif bios_mem.mif
file copy -force ../../../software/asmtest/asmtest.mif imem_blk_ram.mif
add wave EchoTestbenchCaches/*
add wave EchoTestbenchCaches/mem_arch/*
add wave EchoTestbenchCaches/mem_arch/dcache/*
add wave EchoTestbenchCaches/mem_arch/icache/*
add wave EchoTestbenchCaches/mem_arch/cache_bypass/*
add wave EchoTestbenchCaches/mem_arch/req_con/*
add wave EchoTestbenchCaches/DUT/*
add wave EchoTestbenchCaches/DUT/dpath/*
add wave EchoTestbenchCaches/DUT/ctrl/*
add wave EchoTestbenchCaches/DUT/dpath/ua/*
add wave EchoTestbenchCaches/DUT/dpath/regfile/*
run 10000us

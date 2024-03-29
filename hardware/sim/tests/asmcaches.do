start AsmTestbenchCaches
file copy -force ../../../software/asmtest/asmtest.mif bios_mem.mif
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
add wave AsmTestbenchCaches/*
add wave AsmTestbenchCaches/mem_arch/*
add wave AsmTestbenchCaches/mem_arch/dcache/*
add wave AsmTestbenchCaches/mem_arch/icache/*
add wave AsmTestbenchCaches/mem_arch/req_con/*
add wave AsmTestbenchCaches/DUT/*
add wave AsmTestbenchCaches/DUT/regfile/*
run 10000us

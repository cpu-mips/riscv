.section    .start
.global     _start

_start:
    li      sp, 0x10040000
    jal     main

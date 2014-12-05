.section    .start
.global     _start

_start:

# Counter to keep track of how many tests pass
addi x7, x0, 0x1

# Load some test values into registers
lui x1, 0x10000
addi x1, x1, 0x020
lui x2, 0x1eadb
addi x2, x2, 0x0ef

# Set up the base address for loads/stores
# Base address will be 0x10000000
lui x10, 0x10000

# Store the values, and then load them back
sw x1, 0(x10)
sw x2, 4(x10)
lw x11, 0(x10)
lw x12, 4(x10)

# Test 1
bne x1, x11, Error

# Test 2
addi x7, x7, 0x1
bne x2, x12, Error

# Add more tests here!
# Test 3: AIUPC
addi x7, x7, 0x1
# auipc x8, 0x00001
# addi x9, x0, 0x38
# addi x10, x0, 0x00001
# slli x10, x10, 0xc
# add x10, x10, x9
# bne x8, x10, Error

#Test 4: SLT
addi x7, x7, 0x1
addi x8, x0, 0x8
add x9, x8, x7
slt x11, x9, x8
bne x11, x0, Error
slt x11, x8, x9
beq x11, x0, Error
slti x11, x9, 0x8
bne x11, x0, Error
lui x8, 0xfffff
addi x8, x8, 0x1
lui x2, 0x00000
addi x2, x2, 0x1
sltu x11, x2, x8 
beq x11, x0, Error
sltiu x11, x8, 0x0
bne x11, x0, Error

#Test 5: shifts
addi x7, x7, 0x1
addi x8, x0, 0x8 
srli x9, x8, 0x3
addi x11, x0, 0x1
bne x9, x11, Error
sll x9, x9, x11
addi x12, x0, 0x2
bne x12, x9, Error

#Test 6: logic operations
addi x7, x7, 0x1
addi x9,x0,0xf
or x11, x9, x0
bne x9, x11, Error
xor x11, x9, x0
bne x11, x9, Error
and x11, x9, x0
bne x11, x0, Error

#Test 7: Mother-of-all Hazards
addi x7, x7, 0x1
lw x11, 0(x10)
add x9, x11, x10
addi x11, x11, 0x8
sw x9, 0(x11)
lw x12, 0(x11)
bne x9, x12, Error
nop

#Test 8: Jumping and writing to x0
Test9:
addi x7, x7, 0x1
addi x9, x0, 0x0
j Test

Test:
addi x8, x0, 0x0
bne x8, x9, Error
add x0, x7, x8
bne x0, x8, Error

#Test 9: Branches Galore
addi x11, x7, 0x0
addi x7, x7, 0x1
beq x11, x7, Error
blt x7, x11, Error
blt x7, x7, Error
bge x11, x7, Error
bne x7, x7, Error
lui x8, 0xfffff
addi x8, x8, 0x1
lui x2, 0x00000
addi x2, x2, 0x1
bltu x8, x2, Error
bltu x8, x8, Error
bgeu x2, x8, Error

#Test 10: Stores, Stores, Stores
addi x7, x7, 0x1
lui x8, 0xdeadb
addi x8, x8, 0xef
addi x1, x0, 0xef
lui x2, 0x0000b
addi x2, x2, 0xef
lui x3, 0xfffff
addi x5, x0, 0xf
slli x5, x5, 0x8
add x3, x5, x3
addi x3, x3, 0xef
lui x4, 0xffffb
addi x4, x4, 0xef
#addi x3, x0, 0xffffffef
#addi x4, x0, 0xffffb0ef
sb x8, 32(x10)
sh x8, 64(x10)
lbu x9, 32(x10)
lhu x11, 64(x10)
lb x5, 32(x10)
lh x6, 64(x10)
bne x9, x1, Error
bne x11, x2, Error
bne x5, x3, Error
bne x6, x4, Error
j Pass

Error:
# Perhaps write the test number over serial
addi x4, x0, 'F'
jal x1, WriteUART
addi x4, x0, 'a'
jal x1, WriteUART
addi x4, x0, 'i'
jal x1, WriteUART
addi x4, x0, 'l'
jal x1, WriteUART
addi x4, x0, ':'
jal x1, WriteUART
addi x4, x0, ' '
jal x1, WriteUART
addi x4, x7, '0'
jal x1, WriteUART
addi x4, x0, '\n'
jal x1, WriteUART
j Done

Pass:
# Write success over serial
addi x4, x0, 'P'
jal x1, WriteUART
addi x4, x0, 'a'
jal x1, WriteUART
addi x4, x0, 's'
jal x1, WriteUART
addi x4, x0, 's'
jal x1, WriteUART
addi x4, x0, '\n'
jal x1, WriteUART
j Done

Done:
j Done

WriteUART:
# Return address is in x1
# Byte to write is in x4
# UART addressing:
# 0x80000000: bit1=dout_valid, bit0=din_ready
# 0x80000004: read data from UART
# 0x80000008: write data to UART

lui x2, 0x80000    # actually loads 0x80000000 into x2
lw x3, 0(x2)
andi x3, x3, 0x1
beq x3, x0, WriteUART
sw x4, 8(x2)
jalr x0, x1, 0

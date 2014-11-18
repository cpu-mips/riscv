.section    .start
.global     _start

_start:

# Counter to keep track of how many tests pass
addi x7, x0, 0x0

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
auipc x8, 0x00001
addi x9, x0, 0x34
addi x10, x0, 0x00001
slli x10, x10, 0xc
add x10, x10, x9
bne x8, x10, Error

#Test 4: SLT
addi x8, x0, 0x8
add x9, x8, x7
slt x10, x9, x8
bne x10, x0, Error
slt x10, x8, x9
beq x10, x0, Error
slti x10, x9, 0x8
bne x10, x0, Error

#Test 5: shifts
srli x9, x8, 0x3
addi x10, x0, 0x1
bne x9, x10, Error
sll x9, x9, x10
addi x11, x0, 0x2
bne x11, x9, Error

#Test 6: logic operations
addi x9,x0,0xf
or x10, x9, x0
bne x9, x10, Error
xor x10, x9, x0
bne x10, x9, Error
and x10, x9, x0
bne x10, x0, Error

#Test 7: Stores, loads
sw x9, 0(x12)
lw x10, 0(x12)
bne x9, x10, Error

#Test 8: Mother-of-all Hazards
#lw x11, 0(x12)
#add x9, x11, x10

#Test 9: Writing to x0
add x9, x0, x0
j Test

Test:
bne x0, x9, Error

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

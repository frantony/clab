#set remote target-features-packet on
#show remote target-features-packet
#set remote-mips64-transfers-32bit-regs off
#show remote-mips64-transfers-32bit-regs

set architecture mips:isa64r2
set mips abi n64
set disassemble-next-line on
target remote :1234

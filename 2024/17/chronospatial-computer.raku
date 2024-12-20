#!raku

# 3-bit computer (0 - 7)
#
# 3 registers: A, B, C
#   not limited to 3-bits
#
# 2 operand types
#   literal (identity)
#     literal operand 7 = 7
#   combo
#     0 - 3: literal values 0 - 3
#         4: the value of register A
#         5: the value of register B
#         6: the value of register C
#         7: reserved
#
# 8 instruction types
#   instructions specify their operand type
#
#   opcodes:
#     0: adv (division); A = A // 2^<combo>
#     1: bxl (xor); B = B xor <literal>
#     2: bst (mod); B = <combo> mod 8
#     3: jnz (jump); IF A = 0 THEN noop ELSE IP = <literal>
#     4: bxc (xor); B = B xor C; (ignore operand)
#     5: out (print): print(<combo> mod 8)
#     6: bdv (division); B = A // 2^<combo>
#     7: cdv (division); C = A // 2^<combo>


constant $ADV_OPCODE = 0;
constant $BXL_OPCODE = 1;
constant $BST_OPCODE = 2;
constant $JNZ_OPCODE = 3;
constant $BXC_OPCODE = 4;
constant $OUT_OPCODE = 5;
constant $BDV_OPCODE = 6;
constant $CDV_OPCODE = 7;

# input.txt
# Register A: 61156655
# Register B: 0
# Register C: 0

# Program: 2,4,1,5,7,5,4,3,1,6,0,3,5,5,3,0

# input.test
# Register A: 2024
# Register B: 0
# Register C: 0
# Program: 0,3,5,4,3,0
#
# A = A div 2^3
# print(A mod 8)
# IF A != 0 THEN IP = 0
#
# translates to:
#
# while (A != 0) {
#     A = A div 8;
#     print(A mod 8)
# }
#
# input.txt
# Register A: 61156655
# Register B: 0
# Register C: 0
# Program: 2,4,1,5,7,5,4,3,1,6,0,3,5,5,3,0
#
# B = A mod 8
# B = B xor 5
# C = A // 2^B
# B = B xor C
# B = B xor 6
# A = A // 2^3
# print(B mod 8)
# IF A != 0 THEN IP = 0
# 
# translates to:
# 
# while (A != 0) {
#   B = A mod 8
#   B = B xor 5
#   C = A div 2^B
#   B = B xor C
#   B = B xor 6
#   A = A div 8
#   print(B mod 8)
# }
# 
# Observations:
# - A is the only value carried over across iterations
# - B and C are directly based on A except their value is discarded each iteration
# - the lowest 3 bits of A are removed each iteration and are used to produce the output
# - if the program has N outputs then A must be in the range [8^N, 8^N+1] 
#   - 8 comes from the fact that the program inputs are 3-bit numbers there are 2^3 (8) possible 3-bit numbers
# - to reverse this process we can "add" 3 bits back to A and search all 8 3-bit number possibilities until we find a matching output for
#   the current instruction
# 
# sA = [0]
# for each instruction in reverse -> I
#   nA = []
#   for each a in sA -> SA
#     for each d in (0, 7) -> D
#       O = program(SA*8+D, 0, 0)
#       if O[0] == I 
#         nA <- SA*8+D
#   sA = nA
#
# min(sA)

my ($A, $B, $C, @program) = $*IN.slurp.comb(/\d+/)>>.Int;

sub computer(@program, $A is copy, $B is copy, $C is copy) {
    sub combo($operand) {
        return $operand
            if 0 <= $operand <= 3;
        return $A
            if $operand == 4;
        return $B
            if $operand == 5;
        return $C
            if $operand == 6;
    }

    my @outputs;
    my $IP = 0;
    while $IP < @program.elems {
        my $instruction = @program[$IP];
        my $operand = @program[$IP + 1];

        # dd [$instruction, $operand];
        given $instruction {
            when $ADV_OPCODE {
                $A +>= combo($operand);
            }
            when $BXL_OPCODE {
                $B +^= $operand;
            }
            when $BST_OPCODE {
                $B = combo($operand) +& 0b111;
            }
            when $JNZ_OPCODE {
                if $A != 0 {
                    $IP = $operand;
                    next;
                }
            }
            when $BXC_OPCODE {
                $B +^= $C;
            }
            when $OUT_OPCODE {
                @outputs.push: combo($operand) +& 0b111;
            }
            when $BDV_OPCODE {
                $B = $A +> combo($operand);
            }
            when $CDV_OPCODE {
                $C = $A +> combo($operand);
            }
        }


        $IP += 2;
    }

    @outputs
}

sub find(@program) {
    my $valid-a = SetHash.new: 0;

    for @program.reverse -> $instruction {
        my $next-a = SetHash.new;

        # iterate through all starting a values to determine valid As for this instruction
        for $valid-a.keys -> $sA {
            # we do not know which combination of 3 bits generates the correct instruction in this place
            # try all 8 possibilities
            # multiplying by 8 ensures we are looking at the correct set of 3-bit values in the A register
            # if the program has 5 ouputs, A will have 15 bits and each segment of 3 bits will map to an output
            # A  = 000 000 000 000 000
            # O# =  4   3   2   1   0
            for ^8 -> $offset {
                my $possible-a = $sA * 8 + $offset;
                if computer(@program, $possible-a, 0, 0)[0] == $instruction {
                    $next-a.set: $possible-a
                }
            }
        }

        $valid-a = $next-a;
    }

    min $valid-a.keys;
}

# part 1
say computer(@program, $A, $B, $C);
say find(@program);
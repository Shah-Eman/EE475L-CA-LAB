# =====================================================================
# Lab 11 - Insertion Sort on the 3-stage pipelined RISC-V processor
# ---------------------------------------------------------------------
# Reference C code (provided in the lab manual):
#
#   void insertion_sort(int arr[], int n) {
#       for (int i = 1; i < n; i++) {
#           int key = arr[i];
#           int j   = i - 1;
#           while (j >= 0 && arr[j] > key) {
#               arr[j + 1] = arr[j];
#               j = j - 1;
#           }
#           arr[j + 1] = key;
#       }
#   }
#
# ---------------------------------------------------------------------
# Memory map (data_mem is indexed by the byte address, so word k lives
# at byte address 4*k):
#       arr[0] @ 0x0   arr[1] @ 0x4   arr[2] @ 0x8   arr[3] @ 0xC
#
# Unsorted array : [9, 3, 7, 5]   ->   Sorted : [3, 5, 7, 9]
#
# Register usage:
#   x1  - temporary (comparison result / scratch)
#   x5  - i
#   x6  - key
#   x7  - j
#   x8  - arr[j]
#   x10 - base address of the array (= 0)
#   x11 - n (= 4)
#   x12 - &arr[i]
#   x13 - &arr[j]
#   x14 - &arr[j+1]
#
# NOTE on the ISA subset implemented by this processor:
#   * Branch unit resolves BEQ / BNE only, so every ">=", "<", ">"
#     comparison is built from SLT / SLTI followed by BEQ / BNE.
#   * Unconditional jumps use JAL x0, <label> (link discarded).
#   * There is no JALR; loops are closed with JAL.
# =====================================================================

            addi  x10, x0, 0          # base = 0
            addi  x11, x0, 4          # n    = 4
            addi  x5,  x0, 1          # i    = 1

outer_loop:                            # for (i = 1; i < n; i++)
            slt   x1,  x5,  x11       # x1 = (i < n)
            beq   x1,  x0,  end_outer #   exit loop when i >= n
            slli  x12, x5,  2         # x12 = i * 4
            add   x12, x12, x10       # x12 = &arr[i]
            lw    x6,  0(x12)         # key = arr[i]
            addi  x7,  x5,  -1        # j   = i - 1

inner_loop:                            # while (j >= 0 && arr[j] > key)
            slti  x1,  x7,  0         # x1 = (j < 0)
            bne   x1,  x0,  end_inner #   exit when j < 0
            slli  x13, x7,  2         # x13 = j * 4
            add   x13, x13, x10       # x13 = &arr[j]
            lw    x8,  0(x13)         # x8  = arr[j]
            slt   x1,  x6,  x8        # x1 = (key < arr[j]) = (arr[j] > key)
            beq   x1,  x0,  end_inner #   exit when arr[j] <= key
            sw    x8,  4(x13)         # arr[j+1] = arr[j]
            addi  x7,  x7,  -1        # j = j - 1
            jal   x0,  inner_loop     # repeat inner loop

end_inner:
            addi  x14, x7,  1         # x14 = j + 1
            slli  x14, x14, 2         # x14 = (j+1) * 4
            add   x14, x14, x10       # x14 = &arr[j+1]
            sw    x6,  0(x14)         # arr[j+1] = key
            addi  x5,  x5,  1         # i = i + 1
            jal   x0,  outer_loop     # repeat outer loop

end_outer:
            jal   x0,  end_outer      # halt: spin forever (program done)

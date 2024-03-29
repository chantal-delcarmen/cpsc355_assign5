// File: a5a.asm
// CPSC 355 Assignment 5
// Chantal del Carmen
// Student #: 30129615

QUEUESIZE   = 8
MODMASK     = 0x7
FALSE       = 0
TRUE        = 1

define(head_r, w19)
define(tail_r, w20)
define(value_r, w21)
define(count_r, w22)
define(i_r, w23)
define(j_r, w24)
define(base_r, x25)

            .data
            .global head_m                              // global int head = -1
head_m:     .word   -1
            .global tail_m                              // global int tail = -1
tail_m:     .word   -1

            .bss
            .global queue_m                             // global int[QUEUESIZE], not initialized
queue_m:    .skip   QUEUESIZE * 4            

            .text
            .balign 4
fmt_qo:     .string "\nQueue overflow! Cannot enqueue into a full queue.\n"    
fmt_qu:     .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
fmt_qe:     .string "\nEmpty queue\n"
fmt_qc:     .string "\nCurrent queue contents:\n"
fmt_val:    .string "  %d"
fmt_head:   .string " <-- head of queue"
fmt_tail:   .string " <-- tail of queue"
fmt_nl:     .string "\n"

// -------------------------------------------------------------------------------------------

            .global enqueue
enqueue:    stp     x29, x30, [sp, -16]!
            mov     x29, sp

            mov     value_r, w0                         // Set passed in arg (in w0) to value

enq_if_qf:  bl      queueFull                           // Jump to queueFull

            cmp     w0, TRUE                            // Compare queueFull return value to TRUE
            b.ne    enq_if_qe                           // If equal to false, jump to enq_if_qe
                                                        // Otherwise, fall through
            ldr     x0, =fmt_qo                         // Reach here if queueFull is true
            bl      printf                              // Print queue overflow message
            b       enq_ret                             // Return out of subroutine
            
enq_if_qe:  bl      queueEmpty

            cmp     w0, TRUE                            // Compare queueEmpty return value to TRUE
            b.ne    enq_else_qe                         // If equal to false, jump to enq_else_qe
                                                        // Otherwise, fall through

            adrp    x26, head_m                         // Get base address of head         
            add     x26, x26, :lo12:head_m              // Add lower 12 bits of head's address
            ldr     head_r, [x26]                       // By using x26 as a pointer, load value of head
            mov     head_r, 0                           // head = 0
            str     head_r, [x26]                       // Update head value at its address
            
            adrp    x26, tail_m                         // Get base address of tail         
            add     x26, x26, :lo12:tail_m              // Add lower 12 bits of tail's address
            ldr     tail_r, [x26]                       // By using x26 as a pointer, load value of tail
            mov     tail_r, 0                           // tail = 0
            str     tail_r, [x26]                       // Update tail value at its address
                        
            b       enq_next

enq_else_qe:adrp    x26, tail_m                         // Get base address of tail         
            add     x26, x26, :lo12:tail_m              // Add lower 12 bits of tail's address
            ldr     tail_r, [x26]                       // By using x26 as a pointer, load value of tail
            add     tail_r, tail_r, 1                   // tail = ++tail
            and     tail_r, tail_r, MODMASK             // tail = ++tail & MODMASK 
            str     tail_r, [x26]                       // Update tail value at its address
                
enq_next:   adrp    x26, tail_m                         // Get base address of tail         
            add     x26, x26, :lo12:tail_m              // Add lower 12 bits of tail's address
            ldr     tail_r, [x26]                       

            adrp    base_r, queue_m                     // Get base address of queue         
            add     base_r, base_r, :lo12:queue_m       // Add lower 12 bits of tail's address
            str     value_r, [base_r, tail_r, SXTW 2]     

enq_ret:    ldp     x29, x30, [sp], 16
            ret  


// -------------------------------------------------------------------------------------------

            .global dequeue
dequeue:    stp     x29, x30, [sp, -16]!
            mov     x29, sp

deq_if_qe:  bl      queueEmpty
            cmp     w0, TRUE                            // Compare queueEmpty return value to TRUE
            b.ne    deq_next                            // If equal to false, jump to return
                                                        // Otherwise, fall through
            ldr     x0, =fmt_qu                         // Reach here if queueEmpty is true
            bl      printf                              // Print queue underflow message

            mov     w0, -1                              // Set return value to -1
            b       deq_ret                             // Return out of subroutine

deq_next:   ldr     value_r, [base_r, head_r, SXTW 2]   // Load value from address to dequeue

deq_if:     cmp     head_r, tail_r                      // Compare head and tail
            b.ne    deq_else                            // If not equal, jump to deq_else

            mov     head_r, -1                          // Otherwise head and tail are equal
            mov     tail_r, -1                          // Set both head and tail to -1

            b       deq_next2                           // Jump to deq_next2

deq_else:   add     head_r, head_r, 1                   // head = ++head
            and     head_r, head_r, MODMASK             // head = ++head & MODMASK

deq_next2:  mov     w0, value_r                         // Move value into w0 to be returned by function

deq_ret:    ldp     x29, x30, [sp], 16                  // Exit dequeue
            ret       

// -------------------------------------------------------------------------------------------
            .global queueFull
queueFull:  stp     x29, x30, [sp, -16]!
            mov     x29, sp

            adrp    x26, tail_m                         // Get address for tail
            add     x26, x26, :lo12:tail_m
            ldr     tail_r, [x26]                       
            add     w27, tail_r, 1                      // w27 = tail + 1
            and     w27, w27, MODMASK                   // w27 = (tail + 1) & MODMASK

            adrp    x26, head_m                         // Get address for head
            add     x26, x26, :lo12:head_m
            ldr     head_r, [x26]                       

            cmp     w27, head_r                         // Compare [w27 = (tail + 1) & MODMASK] and head
            b.ne    qf_else                             // If not equal, then jump to qf_else
            mov     w0, TRUE                            // If we get here, then they are equal,
            b       qf_return                           //      so return TRUE    

qf_else:    mov     w0, FALSE                           // Jumps here if w20 and w21 and !=, so return FALSE

qf_return:  ldp     x29, x30, [sp], 16                  // Return and exit subroutine
            ret    


// -------------------------------------------------------------------------------------------

            .global queueEmpty
queueEmpty: stp     x29, x30, [sp, -16]!
            mov     x29, sp

            adrp    x26, head_m                         // Get address for tail
            add     x26, x26, :lo12:head_m
            ldr     head_r, [x26]                          

            cmp     head_r, -1                          // Compare head and -1
            b.ne    qe_else                             // If w20 and w21 are !=, then jump to qe_else
            mov     w0, TRUE                            // If we get here, then w20 and w21 are equal,
            b       qe_return                           //      so return TRUE

qe_else:    mov     w0, FALSE                           // Jumps here if w20 and w21 are !=, so return FALSE

qe_return:  ldp     x29, x30, [sp], 16                  // Return and exit subroutine
            ret                               


// -------------------------------------------------------------------------------------------

            .global display    
display:    stp     x29, x30, [sp, -16]!
            mov     x29, sp                   

disp_if_qe: bl      queueEmpty
            cmp     w0, TRUE                            // Compare queueEmpty return value to TRUE
            b.ne    disp_next                           // If equal to false, jump to return
                                                        // Otherwise, fall through
            ldr     x0, =fmt_qe                         // Reach here if queueFull is true
            bl      printf                              // Print queue overflow message
            b       disp_ret                            // Return out of subroutine

disp_next:  mov     count_r, tail_r                     // count = tail
            sub     count_r, count_r, head_r            // count = tail - head
            add     count_r, count_r, 1                 // count = tail - head + 1

            cmp     count_r, 0
            b.gt    disp_print
                                                        // if (count <= 0)
            add     count_r, count_r, QUEUESIZE         //    count += QUEUESIZE   

disp_print: ldr     x0, =fmt_qc                         // printf("\nCurrent queue contents:\n");
            bl      printf

            mov     i_r, head_r                         // i = head
            mov     j_r, 0                              // j = 0 

            b       disp_test                           // Jump to disp_test

disp_top:   ldr     x0, =fmt_val                        // printf("  %d", queue[i]);
            ldr     w1, [base_r, i_r, SXTW 2]
            bl      printf

            cmp     i_r, head_r                         // if (i == head) 
            b.ne    disp_next2                          //    printf(" <-- head of queue")
            ldr     x0, =fmt_head
            bl      printf

            cmp     i_r, tail_r                         // if (i == tail) 
            b.ne    disp_next2                          //    printf(" <-- tail of queue");
            ldr     x0, =fmt_tail
            bl      printf

disp_next2:  ldr     x0, =fmt_nl                         // printf("\n");
            bl      printf

            add     i_r, i_r, 1                         // ++i
            and     i_r, i_r, MODMASK                   // i = ++i & MODMASK

            add     j_r, j_r, 1                         // j++

disp_test:  cmp     j_r, count_r                        // Compare j and count
            b.lt    disp_top                            // If j < count, jump to disp_top

disp_ret:   ldp     x29, x30, [sp], 16                  // Exit from display function
            ret  

        
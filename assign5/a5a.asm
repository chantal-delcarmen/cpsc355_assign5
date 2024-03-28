define(QUEUESIZE, 8)
define(MODMASK, 0x7)
define(FALSE, 0)
define(TRUE, 1)
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

/* ------------------------------------------------------------------------------------
void enqueue(int value)
{
  if (queueFull()) {
    printf("\nQueue overflow! Cannot enqueue into a full queue.\n");
    return;
  }
  
  if (queueEmpty()) {
    head = tail = 0;
  } else {
    tail = ++tail & MODMASK;
  }
  queue[tail] = value;
}
*/

/*
head_size = 4
tail_size = 4
value_size = 4

alloc = -(16 + head_size + tail_size + value_size) & -16
dealloc = -alloc

head_s = 16
tail_s = head_s + head_size
value_s = tail_s + tail_size
 */

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
            b.ne    enq_qe_else                         // If equal to false, jump to enq_qe_else
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
enq_qe_else:
//   } else {
//    tail = ++tail & MODMASK;

enq_next:
//   queue[tail] = value;


enq_ret:    ldp     x29, x30, [sp], 16
            ret  


/* ------------------------------------------------------------------------------------
int dequeue()
{
  register int value;
    
  if (queueEmpty()) {
    printf("\nQueue underflow! Cannot dequeue from an empty queue.\n");
    return (-1);
  }
  
  value = queue[head];
  if (head == tail) {
    head = tail = -1;
  } else {
    head = ++head & MODMASK;
  }
  return value;
}
*/
            .global dequeue
dequeue:    stp     x29, x30, [sp, -16]!
            mov     x29, sp

            ldp     x29, x30, [sp], 16
            ret       

/* ------------------------------------------------------------------------------------
int queueFull()
{
  if (((tail + 1) & MODMASK) == head)
    return TRUE;
  else
    return FALSE;
}
*/
            .global queueFull
queueFull:  stp     x29, x30, [sp, -16]!
            mov     x29, sp

            adrp    x19, tail_m
            add     x19, x19, :lo12:tail_m
            ldr     w20, [x19]                          // w20 = tail
            add     w20, w20, 1                         // w20 = tail + 1
            and     w20, w20, MODMASK                   // w20 = (tail + 1) & MODMASK

            adrp    x19, head_m
            add     x19, x19, :lo12:head_m
            ldr     w21, [x19]                          // w21 = head

            cmp     w20, w21                            // Compare [w20 = (tail + 1) & MODMASK] and [w21 = head]
            b.ne    qf_else                             // If w20 and w21 are !=, then jump to qf_else
            mov     w0, TRUE                            // If we get here, then w20 and w21 are equal,
            b       qf_return                           //      so return TRUE    

qf_else:    mov     w0, FALSE                           // Jumps here if w20 and w21 and !=, so return FALSE

qf_return:  ldp     x29, x30, [sp], 16                  // Return and exit subroutine
            ret    


/* ------------------------------------------------------------------------------------
int queueEmpty()
{
  if (head == -1)
    return TRUE;
  else
    return FALSE;
}
*/

            .global queueEmpty
queueEmpty: stp     x29, x30, [sp, -16]!
            mov     x29, sp

            adrp    x19, head_m
            add     x19, x19, :lo12:head_m
            ldr     w20, [x19]                          // w20 = head

            mov     w21, -1                             // w21 = -1

            cmp     w20, w21                            // Compare [w20 = head] and [w21 = -1]
            b.ne    qe_else                             // If w20 and w21 are !=, then jump to qe_else
            mov     w0, TRUE                            // If we get here, then w20 and w21 are equal,
            b       qe_return                           //      so return TRUE

qe_else:    mov     w0, FALSE                           // Jumps here if w20 and w21 are !=, so return FALSE

qe_return:  ldp     x29, x30, [sp], 16                  // Return and exit subroutine
            ret                               


/* ------------------------------------------------------------------------------------
void display()
{
  register int i, j, count;
    
  if (queueEmpty()) {
    printf("\nEmpty queue\n");
    return;
  }

  count = tail - head + 1;
  if (count <= 0)
    count += QUEUESIZE;
  
  printf("\nCurrent queue contents:\n");
  i = head;
  for (j = 0; j < count; j++) {
    printf("  %d", queue[i]);
    if (i == head) {
      printf(" <-- head of queue");
    }
    if (i == tail) {
      printf(" <-- tail of queue");
    }
    printf("\n");
    i = ++i & MODMASK;
  }   
}
*/

            .global display    
display:    stp     x29, x30, [sp, -16]!
            mov     x29, sp

            ldp     x29, x30, [sp], 16
            ret  


/* ------------------------------------------------------------------------------------
            stp     x29, x30, [sp, -16]!
            mov     x29, sp

            adrp    x19, head_m
            add     x19, x19, :lo12:head_m
            ldr     w20, [x19]                          // w20 = head

            adrp    x19, tail_m
            add     x19, x19, :lo12:tail_m
            ldr     w21, [x19]                          // w21 = tail

            ldp     x29, x30, [sp], 16
            ret
*/







                
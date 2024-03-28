define(QUEUESIZE, 8)
define(MODMASK, 0x7)
define(FALSE, 0)
define(TRUE, 1)

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
//fmt:        .string     

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

            .global enqueue
enqueue:    stp     x29, x30, [sp, -16]!
            mov     x29, sp

            ldp     x29, x30, [sp], 16
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







                
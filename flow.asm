  section .data
floatzero: dd 0.0,
  
  SECTION .bss

width:      resb 4
height:     resb 4
T:          resb 8
weight:     resb 4
oldleft:    resb 8 ; array of old values from the column one to the left of current one
oldmiddle:  resb 8 ; array of old values from the current column

  SECTION .text

  extern memcpy

  global start
  global step

start:
	mov   [width], rdi
  mov   [height], rsi
  mov   [T], rdx
	vmovd  [weight], xmm0
  mov   rcx, rdi
  imul  rcx, rsi  ; width * height
  imul  rcx, 4
  add   rdx, rcx  ; T + width * height 
  mov   [oldleft], rdx
  imul  rsi, 4
  add   rdx, rsi  ; width * height + height
  mov   [oldmiddle], rdx
  ret



step:
	push rbp
	mov	rbp, rsp
  sub rsp, 128 ; local memory for inserting 4 floats from 128 mem to xmm register

  mov rsi, rdi   ; initial array as argument to memcpy
  mov rdi, [oldleft]
  xor rdx, rdx
  mov edx, [height]
  imul edx, 4
  call memcpy
  
  mov rdi, [oldmiddle]
  mov rsi, [T]  ; intial value for oldmiddle is first column of array
  xor rdx, rdx
  mov edx, [height]
  imul edx, 4
  call memcpy

  mov rcx, 0

start_step_loop:
  ; we assume that height & width > 0
  ; we will exit after the interations

  mov rdx, 0

.calculate_values:
  ; we are starting processing the values
  ; at this point oldleft and oldmiddle should be
  ; set with proper values
  ; ecx - current column, edx - current height

  movss xmm0, [weight]
  shufps xmm0, xmm0, 0x00 ; weight moved to each float of xmm0

  xor r9, r9
  mov r9d, [height]
  imul r9d, ecx
  add r9d, edx
  mov r8, [T]

  movss xmm1, [r8 + r9 * 4]
  shufps xmm1, xmm1, 0x00 ; value of current cell

  cmp edx, 0 
  je .top

  ; we are not in the top row, we can proceed with adding the values

  xor rax, rax
  mov eax, edx
  dec eax

  mov r8, [oldleft]
  movss xmm5, [r8 + 4 * rax] 
  movss [rbp - 4], xmm5 ; save value of upper-left cell

  mov r8, [oldmiddle]
  movss xmm5, [r8 + 4 * rax]
  movss [rbp - 8], xmm5 ; save value of upper cell

  jmp .after_top

.top:
  ; we are in the top row, we save values of current cell, so the difference is 0
  movss [rbp - 4], xmm1
  movss  [rbp - 8], xmm1

.after_top:

  xor rax, rax
  mov eax, edx
  inc eax 

  cmp eax, [height]

  je .bottom

  ; we are not in the lowest row

  mov r8, [oldleft]
  movss xmm5, [r8 + 4 * rax]
  movss [rbp - 12], xmm5 ; save value of lower-left cell

  mov r8, [oldmiddle]
  movss xmm5, [r8 + 4 * rax]
  movss [rbp - 16], xmm5; save value of lower cell

  jmp .after_bottom

.bottom:
  ; we are in the bottom row, we save values of current cell, so the difference is 0
  movss [rbp - 12], xmm1
  movss [rbp - 16], xmm1

.after_bottom:

  movaps xmm2, [rbp - 16] ; values of {lower,upper}-{left, middle} cells
  subps xmm2, xmm1 ; deltas
  dpps xmm2, xmm0, 11110001b ; sum of deltas multiplied by weight

  mov r8, [oldleft]
  movss xmm4, [r8 + 4 * rdx] ; value of left neighbour - it always exists - no corner cases
  subss xmm4, xmm1 ; delta
  mulss xmm4, xmm0 ; delta * weight
  
  addss xmm2, xmm4 ; final sum of deltas with weight

  mov r9d, ecx
  imul r9d, [height]
  add r9d, edx ; offset of current cell in array

  mov r8, [T]

  movss xmm4, [r8 + 4 * r9]
  addss xmm2, xmm4 ; result = deltas * weight + old value

  lea r10, [r8 + 4 * r9]

  movss [r10], xmm2

  inc edx
  cmp edx, [height]
  jne .calculate_values

  ; we already processed the whole column

  xor rax, rax
  mov eax, ecx
  inc eax

  cmp eax, [width]
  je exit_step ; we processed the whole array

  push rdx
  push rcx

  mov rdi, [oldleft] 
  mov rsi, [oldmiddle]
  xor rdx, rdx
  mov edx, [height]
  imul edx, 4
  call memcpy ; copy [height] bytes from oldmiddle to oldleft

  xor rdx, rdx
  mov edx, [height]
  imul edx, 4 

  pop rcx
  push rcx
  
  inc ecx
  imul ecx, [height]
  imul ecx, 4
  mov rsi, [T]
  add rsi, rcx
  mov rdi, [oldmiddle] 
  call memcpy ; copy [height] bytes from next column to oldmiddle

  pop rcx
  pop rdx

  inc ecx
  jmp start_step_loop

exit_step:
  leave
  ret


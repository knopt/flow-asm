  SECTION .bss

width:      resb 4
height:     resb 4
T:          resb 8
weight:     resb 4
oldleft:    resb 8 ; trzymanie starych wartosci na lewo od komorki docelowej
oldmiddle:  resb 8 ; trzymanie starych wartosci w kolumnie komorki docelowej

  SECTION .text

  extern memcpy

  global start
  global step

start:
	mov   [width], rdi
  mov   [height], rsi
  mov   [T], rdx
	movd  [weight], xmm0
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
  ; w rdi wskaznik do poczatkowej tablicy wartosci
  mov rsi, rdi   ; tablica argument do rsi
  push rdi ; zapamietac w rdx argument
  mov rdi, [oldleft]
  xor rdx, rdx
  mov edx, [height]
  imul edx, 4
  call memcpy

  mov rdi, [oldmiddle]
  mov rsi, [T]
  xor rdx, rdx
  mov edx, [height]
  imul edx, 4
  call memcpy

  pop rdi
  mov rcx, 0

start_step_loop:
  cmp ecx, [width]
  je exit_step
  inc ecx

step_flow:
  ; oldleft i oldmiddle ustawione
  ; ecx wskazuje na to ktora kolumne aktualnie ustawiamy
  mov edx, 0

single_cell_step_flow:

  cmp edx, [height]
  je start_step_loop

  movd xmm0, [weight]
  shufps xmm0, xmm0, 0x00 ; xmm0 rozszerzone, waga na kazdej z 4 pozycji

  mov eax, edx
  dec eax
  imul eax, 4

  mov r8, [oldleft]
  mov r8d, [r8 + eax]
  movd xmm1, r8d  ; left upper

  mov r8, [oldmiddle]
  mov r8d, [r8 + eax]
  movd xmm1, r8d


  mov eax, ecx
  mul eax, edx
  mul eax, 4 ; eax = indeks aktualnej przetwarzanej komorki

  movd xmm1, 

  inc edx
  jmp single_cell_step_flow

  ; byc moze trzeba tutaj ustawic oldleft oldmiddle

  ; pamietac zeby nowe wartosci przesunac na koncu do rdi


exit_step:
	mov	rsp, rbp
	pop	rbp
  ret


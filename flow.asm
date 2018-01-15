  section .data
floatzero: dd 0.0,
  
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
  sub rsp, 128

  push rdi
  mov rsi, rdi   ; tablica argument do rsi
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

  ; oldleft i oldmiddle ustawione
  ; ecx wskazuje na to ktora kolumne aktualnie ustawiamy

  mov rdx, 0 ; uzywamy jedynie edx, ale wyzerujemy calosc

.calculate_values:

  movss xmm0, [weight]
  shufps xmm0, xmm0, 0x00 ; xmm0 rozszerzone, waga na kazdej z 4 pozycji

  xor r9, r9
  mov r9d, [height]
  imul r9d, ecx
  add r9d, edx
  imul r9d, 4 ; index aktualnego elementu
  mov r8, [T]

  movss xmm1, [r8 + r9]
  shufps xmm1, xmm1, 0x00 ; xmm1 aktualna wartosc komorki rozwazanej

  cmp edx, 0 
  je .top

  ; we are not in the top row, we can proceed with adding the values

  xor rax, rax
  mov eax, edx
  dec eax
  imul eax, 4

  mov r8, [oldleft]
  mov r8d, [r8 + rax]
  mov [rbp - 4], r8d
  ; push r8d  ; left upper

  mov r8, [oldmiddle]
  mov r8d, [r8 + rax]
  mov [rbp - 8], r8d
  jmp .after_top

.top:
  movss [rbp - 4], xmm1
  movss  [rbp - 8], xmm1

.after_top:

  xor rax, rax
  mov eax, edx
  inc eax 

  cmp eax, [height]

  je .bottom

  imul eax, 4
  xor r9, r9

  mov r8, [oldleft]
  movss xmm5, [r8 + rax] ; lewa dolna komorka
  movss [rbp - 12], xmm5

  mov r8, [oldmiddle]
  movss xmm5, [r8 + rax]
  movss [rbp - 16], xmm5

  jmp .after_bottom

.bottom:
  movss [rbp - 12], xmm1
  movss [rbp - 16], xmm1

.after_bottom:

  ; pxor xmm2, xmm2
  movaps xmm2, [rbp - 16]
  subps xmm2, xmm1 ; delta * weight
  dpps xmm2, xmm0, 11110001b ; wartosc koncowa bez policzonego srodkowego lewega sasiada


  pxor xmm4, xmm4
  mov r8, [oldleft]
  movss xmm4, [r8 + 4 * rdx] ; 4 * rdx to obecna wysokosc
  subss xmm4, xmm1 ; delta
  mulss xmm4, xmm0 ; delta * weight
  
  addss xmm2, xmm4 ; result

  xor r9d, r9d
  mov r9d, ecx
  imul r9d, [height]
  add r9d, edx
  imul r9d, 4

  mov r8, [T]

  movss xmm4, [r8 + r9]
  addss xmm2, xmm4

  lea r10, [r8 + r9]

  movss [r10], xmm2

  inc edx
  cmp edx, [height]
  jne .calculate_values

  ; we already processed the whole column

  push rdx
  push rcx

  mov rdi, [oldleft]
  mov rsi, [oldmiddle]
  xor rdx, rdx
  mov edx, [height]
  imul edx, 4
  call memcpy

  xor rdx, rdx
  mov edx, [height]
  imul edx, 4 ; ostatni argument mem cpy, rozmiar

  pop rcx
  push rcx

  imul ecx, [height]
  imul ecx, 4
  mov rsi, [T] ; 2 argument memcpy zrodlo
  add rsi, rcx

  mov rdi, [oldmiddle] ; pierwszy agrument mem cpy - destynacja
  call memcpy

  pop rcx
  pop rdx

  inc ecx

  jmp start_step_loop

exit_step:
  leave
  ret


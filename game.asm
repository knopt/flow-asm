  SECTION .bss

width:  resb 4
height: resb 4
T:      resb 8

  SECTION .text

  global start
  global run

start:
	mov   [width], rdi
  mov   [height], rsi
  mov   [T], rdx
	ret

count_single_cell_neighbours: ; set result in rax, esi - row index, edx - col index
  xor eax, eax
  xor r8, r8
  mov r8d, -2 ; outer loop counter
.outer_neighbours_loop:
  inc r8d
  cmp r8d, 2
  je run_single_step.single_step_body
  xor r9, r9
  mov r9d, -2 ; inner loop counter
.inner_neighbours_loop:
  inc r9d,
  cmp r9d, 2
  je .outer_neighbours_loop

  xor r10, r10
  mov r10d, r8d
  add r10d, esi ; neighbour row index
  cmp r10d, 0
  jl .inner_neighbours_loop ; r < 0
  cmp r10d, [height]
  jge .inner_neighbours_loop ; r >= height

  mov r10d, r9d
  add r10d, edx ; neighbour col index

  cmp r10d, 0
  jl .inner_neighbours_loop ; w < 0
  cmp r10d, [width]
  jge .inner_neighbours_loop ; w >= width

  mov r10d, r8d
  or r10d, r9d ; r10 = w != 0 || r != 0
  cmp r10d, 0
  je .inner_neighbours_loop ; both loop counters are 0, we dont count cell itself

  mov r10d, r8d
  add r10d, esi
  imul r10d, [width]
  add r10d, r9d
  add r10d, edx ; r10 = current index in T
  mov r11, [T]
  mov r10b, [r11 + r10]
  shr r10b, 1   ; move last state of cell to right bit of r10
  and r10b, 1   ; get value of last bit
  add al, r10b  ; add value of last bit to result
  
  jmp .inner_neighbours_loop


run_single_step:
  mov esi, [height]
.move_board_left_row:
  dec esi         ; current row
  cmp esi, 0      ; check if we went through the whole array
  jl .board_moved
  mov edx, [width]
.move_board_left_col:
  dec edx         ; current column
  cmp edx, 0      ; check if we have to jump to a new row
  jl .move_board_left_row
  xor r9, r9
  mov r9d, esi       ; r9 = row number
  imul r9d, [width]  ; r9 = start index of cell row
  add r9d, edx       ; r9 = index of current cell
  mov r8, [T]
  lea r10, [r8 + r9]
  mov r8b, [r8 + r9]
  shl r8b, 1 
  mov byte [r10], r8b ; save shifted left value
  jmp .move_board_left_col  ; continue with next cell

.board_moved:
  mov esi, [height]
.for_each_row:
  dec esi           ; current row
  cmp esi, 0
  jl after_single_step
  mov edx, [width]
.for_each_cell_in_row:
  dec edx           ; current col
  cmp edx, 0
  jl .for_each_row
  jmp count_single_cell_neighbours
.single_step_body:
  ; returned from count_single_cell_neighbours
  ; set new value for cell
  ; neighbours count in rax
  xor r8, r8
  xor r11, r11
  xor r9, r9
  mov r8d, esi
  imul r8d, [width]
  add r8d, edx ; index of current cell
  mov r9, [T]
  mov r11b, [r9 + r8]
  mov r10b, r11b ; current whole cell value
  shr r11b, 1
  and r11b, 1   ; r9 = cell was alive

  cmp r11b, 1
  je .set_value_was_alive
  ; cell was previously dead:
  cmp al, 3 ; should reincarnate?
  je .set_value_alive
  jmp .set_value_dead

.set_value_was_alive:
  cmp al, 2
  jl .set_value_dead
  cmp al, 3
  jg .set_value_dead
.set_value_alive:
  or r10b, 1
  mov r11, [T]
  lea r11, [r11 + r8]
  mov byte [r11], r10b ; save 1 to right bit
.set_value_dead: ; we dont have to change anything as the right bit is 0 after left shift
  jmp .for_each_cell_in_row

after_single_step:
  jmp run

run:
  dec   edi ; steps counter
  cmp   edi, 0
  jl    .exit_run
  jmp run_single_step

.exit_run:
  ret


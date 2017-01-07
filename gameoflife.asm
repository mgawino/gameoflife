        section .text
        global start, run

DEAD       equ ' '          ; dead cell
ALIVE      equ '*'          ; alive cell
SET_DEAD   equ '-'          ; cell will die in the next time unit
SET_ALIVE  equ '+'          ; cell will revive in the next time unit

; -----------------------------------------------------------------------------

start:                      ; rdi - width, rsi - height, rdx - board
        mov [columns],rdi
        mov [rows],rsi
        mov [board],rdx

; -----------------------------------------------------------------------------

run:                        ; rdi - step count
        push rbp
        mov rbp,rsp
        push rbx            ; remember rbx
        mov rcx,rdi
run_loop:
        call run_once
        loop run_loop
        pop rbx             ; restore rbx
        pop rbp
        ret

; -----------------------------------------------------------------------------

run_once:
        push rbp
        mov rbp,rsp
        push rcx            ; remember rcx
        mov rcx,0           ; row index
        mov rbx,[board]     ; first cell address
row_loop:
        cmp rcx,[rows]      ; while row index < rows count
        je row_done
        mov rdx,0           ; column index
col_loop:
        cmp rdx,[columns]   ; while column index < columns count
        je col_done
        mov rdi,rcx         ; row index
        mov rsi,rdx         ; column index
        call count_neigh    ; alive neighbours, result in rax
        cmp byte [rbx],ALIVE    ; is cell alive 
        je cell_alive
        cmp rax,3               ; if dead cell has 3 alive neighbours
        jne no_set
        mov byte [rbx],SET_ALIVE    ; it becomes alive
cell_alive:
        cmp rax,4           ; if alive cell has >= 4 or < 2 alive neighbours
        jge set_dead
        cmp rax,2
        jl set_dead
        jmp no_set
set_dead:
        mov byte [rbx],SET_DEAD ; it becomes dead
no_set:
        inc rdx             ; increase column index
        inc rbx             ; go to the next cell on the board
        jmp col_loop
col_done:
        inc rcx             ; increase row index
        jmp row_loop
row_done:
        call transform      ;
        pop rcx
        pop rbp
        ret

; -----------------------------------------------------------------------------

count_neigh:                ; rdi - row index, rsi - column index
        push rbp            ; count number of alive neighbours for given cell
        mov rbp,rsp
        push rbx            ; remember registers rbx, rcx, rdx
        push rcx
        push rdx
        mov rax,rdi
        imul rax,[columns]
        add rax,rsi
        add rax,[board]     ; given cell address
        cmp byte [rax],ALIVE    ; if it is alive then we initialize
        je minus_init           ; number of alive neighbours to -1
        mov rbx,0           ; wpp na 0
        jmp next
minus_init:
        mov rbx,-1
next:          
        sub rdi,1           ; row index - 1          
        sub rsi,1           ; column index - 1
        mov r8,rsi          ; remember index of top left neighbour
        mov rcx,3
c_row_loop:   
        mov rdx,3
        mov rsi,r8          ; restore remembered column index
c_col_loop:
        cmp rdi,0           ; check if row index is in <0,[rows]-1>
        jl check_end
        cmp rdi,[rows]
        jge check_end
        cmp rsi,0           ; check if column index is in <0,[columns]-1>
        jl check_end
        cmp rsi,[columns]
        jge check_end
        mov rax,rdi         ; get cell address
        imul rax,[columns]
        add rax,rsi
        add rax,[board]
        cmp byte [rax],DEAD ; if it is dead
        je check_end
        cmp byte [rax],SET_ALIVE    ; or in next round will be alive
        je check_end                ; then it is not alive neighbour
        inc rbx             ; otherwise increase number of alive neighbours
check_end:
        dec rdx
        cmp rdx,0
        je c_col_done
        add rsi,1           ; go to next cell in row
        jmp c_col_loop
c_col_done:
        dec rcx
        cmp rcx,0
        je c_row_done    
        add rdi,1           ; go to next row
        jmp c_row_loop
c_row_done:
        mov rax,rbx         ; save result
        pop rdx             ; restore rbx, rcx, rdx
        pop rcx
        pop rbx
        pop rbp
        ret

;------------------------------------------------------------------------------

transform:                  ; transform board to next round
        push rbp
        mov rbp,rsp
        push rcx
        mov rcx,[rows]
        imul rcx,[columns]  ; cells count
        mov rdi,[board]     ; first cell address
transform_loop:
        cmp byte [rdi],SET_ALIVE    ; if cell should be alive
        jne transform_dead
        mov byte [rdi],ALIVE        ; then make it alive
transform_dead:
        cmp byte [rdi],SET_DEAD     ; if cell should die
        jne end_transform
        mov byte [rdi],DEAD         ; then make it dead
end_transform:
        inc rdi             ; go to next cell
        loop transform_loop
        pop rcx
        pop rbp
        ret

;------------------------------------------------------------------------------

        section .bss
rows:       resb 8
columns:    resb 8
board:      resb 8

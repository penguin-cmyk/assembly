format ELF64 executable 3
entry main

; ===== Data Section ======
segment readable writeable
   buffer  rd 1  ; 4-byte buffer for random number
   numstr  db 20 dup(0)  ; String buffer for number conversion
   str_start dq 0 ; Pointer to start of number string
   str_len   dq 0 ; Length of number string

; ==== Code Section ====
segment readable executable

main:
  call get_random  ; Get random bytes
  call convert_to_str ; Convert to string
  call print_result ; Print the number
  call exit ; Exit

; ==== Random Number ====
get_random:
  mov eax, 318          ; sys_getrandom (Linux specific!)
  lea rdi, [buffer]     ; Buffer adress
  mov rsi, 4            ; Buffer size (4 bytes = 32-bit number)
  xor rdx, rdx          ; Flags (0 = blocking mode)
  syscall
  ret
; ==== Convert to string ====
convert_to_str:
  mov eax, [buffer]       ; Load 4-byte random number into EAX
  lea rdi, [numstr+19]    ; Start at the end of the string buffer
  mov byte [rdi], 0       ; Null terminator for string
  mov ebx, 10             ; Base 10 for conversion

  .convert_loop:
  dec rdi                ; Move left in the buffer
  xor edx, edx           ; Clear upper dividend
  div ebx                ; Divide EDX:EAX 10
                         ; EAX = quotient, EDX = remainder
  add dl, '0'            ; convert remainder to ASCII
  mov [rdi], dl          ; Store ASCII character
  test eax, eax          ; Check if quotient is zero
  jnz .convert_loop      ; Continue if not zero

  ; Calculate string length and starting position
  mov [str_start], rdi   ; Save starting of string
  mov rax, numstr+19     ; End of buffer
  sub rax, rdi           ; Calculate length
  mov [str_len], rax         ; Save string length
  ret

; ==== print_result ====
print_result:
  mov eax, 1                ; sys_write
  mov edi, 1                ; stdout
  mov rsi, [str_start]      ; String starting adress
  mov rdx, [str_len]        ; String length
  syscall

  ; Print newline
  mov eax, 1
  mov edi,1
  lea rsi, [newline]
  mov rdx, 1
  syscall
  ret

; ==== Exit ====
exit:
  mov eax, 60   ; sys_exit
  xor edi, edi  ; Exit code 0
  syscall

; ==== Constants ====
segment readable
  newline db 0xA   ; Newline character

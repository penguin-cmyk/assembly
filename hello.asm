format ELF64 executable 3
entry _start

segment readable executable

_start:
  ; Write system call (1)
  mov    eax, 1     ; syscall number (sys_write)
  mov    edi, 1;    ; file descriptor (stdout)
  lea    rsi, [msg] ; message adress
  mov    edx, len   ; message length
  syscall

  ; Exit system call (60)
  mov   eax, 60  ; syscall number (sys_exit)
  xor   edi, edi   ; exist status 0
  syscall

segment readable writeable

msg db 'Hello World!',0xA,0 ; Message + newline
len = $ - msg             ; Calculate length

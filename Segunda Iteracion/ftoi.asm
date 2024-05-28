section .data                   ;initialized data
    numftoi dd 0                ;dword initialized as 0

global ftoi                     ;declared as global to use ot outside of this file
section .text                   ;code section

ftoi:                           ;function
    push ebp                    ;push base pointer to save it (equivalent to "enter" instruction)
    mov ebp, esp                ;move stack pointer to base pointer
    fld dword [esp + 8]         ;load float into numeric coprocessor stack
    fistp dword[numftoi]        ;pops the numeric stack, converts to integer and stores in ftoi
    mov eax, [numftoi]          ;move ftoi to general register eax
    add eax, 1                  ;add 1 to eax
    mov [numftoi], eax          ;move eax to ftoi, not needed cos i only need to return it and it's already in eax
    mov esp, ebp                ;restores stack pointer
    pop ebp                     ;restores base pointer
    ret                         ;return from function

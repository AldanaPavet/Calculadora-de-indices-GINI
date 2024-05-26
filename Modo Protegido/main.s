.equ CODE_SEG, gdt_code - gdt_start
.equ CODE_SEG_32, gdt_code_32 - gdt_start
.equ DATA_SEG_RW, gdt_data_rw - gdt_start
.equ DATA_SEG_RO, gdt_data_ro - gdt_start

.code16

protected_mode_start:
   cli
   lgdt gdt_descriptor

   /* Configurar el manejador de interrupciones para la excepción GPF */
   lidt idt_descriptor

   mov %cr0, %eax
   orl $0x1, %eax
   mov %eax, %cr0 

   ljmp $CODE_SEG, $protected_mode

gdt_start:
    gdt_null:
        .long 0x0
        .long 0x0
    gdt_code:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10011010
        .byte 0b11001111
        .byte 0x0
    gdt_code_32:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10011010
        .byte 0b11001111
        .byte 0x0
    gdt_data_rw:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10010010 /* lectura/escritura */
        .byte 0b11001111
        .byte 0x0 
    gdt_data_ro:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10010010 /* solo lectura */
        .byte 0b11001111
        .byte 0x0 
gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start
    .long gdt_start

/* Tabla de Descriptores de Interrupción (IDT) */
idt_start:
    /* Rellenar las primeras 12 entradas con un manejador de interrupciones genérico o vacío */
    .rept 0x0D
        .quad 0
    .endr

    /* Entrada para la excepción GPF (interrupción 13) */
    .word gpf_handler
    .word CODE_SEG_32
    .byte 0
    .byte 0b10001110
    .word 0
idt_end:

idt_descriptor:
    .word idt_end - idt_start
    .long idt_start


.code32
protected_mode:
    call clear_vga
    mov $DATA_SEG_RW, %ax /*cargamos en ax el valor de DATA_SEG y se lo cargamos a todos los registros de segmentos */
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    
    call print_message
    /* Intentar escribir en el segmento de solo lectura */
    mov $DATA_SEG_RO, %ax
    mov %ax, %ds
    mov %ax, %ss
    call print_message_after


looop:
    jmp looop

/* Manejador de interrupciones para la excepción GPF */
gpf_handler:
    pusha
    mov $gpf_message, %ecx
    call print_message_gpf
    popa
    jmp looop
    

print_message:
    mov $message, %ecx                  /* Load the address of the message into ECX */
    mov $0xb8000, %edi                  /* Load the address of the VGA buffer into EDI */
    add $160, %edi                      /* Move to the third line */
    mov $0x0f, %ah                         /* Set the attribute byte to white on black */
lup2:
    movb (%ecx), %al                    /* Load the character from the message into AL */
    test %al, %al                       /* Check for the end of the message */
    jz thiistheend
    stosw                               /* Write the character to the VGA buffer and increment EDI */
    inc %ecx                            /* Move to the next character in the message */
    jmp lup2
thiistheend:
    ret

print_message_gpf:
    mov $gpf_message, %ecx              /* Load the address of the message into ECX */
    mov $0xb8000, %edi                  /* Load the address of the VGA buffer into EDI */
    add $640, %edi                      /* Move to the third line */
    mov $0x0f, %ah                      /* Set the attribute byte to white on black */
loop:
    movb (%ecx), %al                    /* Load the character from the message into AL */
    test %al, %al                       /* Check for the end of the message */
    jz end
    stosw                               /* Write the character to the VGA buffer and increment EDI */
    inc %ecx                            /* Move to the next character in the message */
    jmp loop
end:
    ret

print_message_after:
    mov $message_after, %ecx            /* Load the address of the message into ECX */
    mov $0xb8000, %edi                  /* Load the address of the VGA buffer into EDI */
    add $320, %edi                      /* Move to the second line */
    mov $0x0f, %ah                      /* Set the attribute byte to white on black */
lup:
    movb (%ecx), %al                    /* Load the character from the message into AL */
    test %al, %al                       /* Check for the end of the message */
    jz thiistheendmyonlyfriendtheend
    stosw                               /* Write the character to the VGA buffer and increment EDI */
    inc %ecx                            /* Move to the next character in the message */
    jmp lup
thiistheendmyonlyfriendtheend:
    ret


/* Clear VGA memory */
clear_vga:
    mov $0xb8000, %edi /* Start of VGA memory */
    mov $0x0f20, %ax   /* Attribute byte (0x0f) followed by space character (0x20) */
    mov $4000, %ecx    /* VGA memory is 4000 words long */
    rep stosw          /* Repeat STOSW ECX times */
    ret


/* Message to be printed on VGA */
message:
    .asciz "P-mode"

/* Mensaje a imprimir cuando se produce una excepción GPF */
gpf_message:
    .asciz "GPF"
    
message_after:
    .asciz "After P-mode"    
/* VGA buffer address */
vga:
    .long 10
    
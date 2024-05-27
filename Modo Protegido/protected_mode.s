.code16
    cli             /* Deshabilita las interrupciones, necesario para evitar interrupciones mientras se inicicaliza el sistema */          
    ljmp $0, $1f
1:
    /* Pone en 0 todos los registros en 0 */
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %bp
    mov %ax, %ss
    mov %bp, %sp

.equ CODE_SEG, 8
.equ DATA_SEG, gdt_data - gdt_start

    lgdt gdt_descriptor

    /* Setea en 1 el bit 0 de registro CR0, es decir habilita el protected_mode */
    mov %cr0, %eax
    orl $0x1, %eax
    mov %eax, %cr0
    ljmp $CODE_SEG, $protected_mode

 /* Define la Global Descriptor Table (GDT) para el modo protegido */
gdt_start: 
gdt_null:
    .long 0x0
    .long 0x0
gdt_code:
    .word 0xffff        /* Segment Limit 0:15 */
    .word 0x0           /* Base Address 16:31 */
    .byte 0x0           /* Base 16:23 */
    .byte 0b10011010    /* Type = Code 010 (Execute/Read) - S = 1 (Descriptor Type Code or Data Segment) - SPL = 0 - P = 1 */
    .byte 0b11001111    /* Segment Limit = 1111 - AVL = 0 - L = 0 - D/B = 1 - G = 1 */
    .byte 0x0           /* Base 24:31 */
gdt_data:
    .word 0xffff        /* Segment Limit 0:15 */
    .word 0x0           /* Base Address 16:31 */
    .byte 0x0           /* Base 16:23 */
    .byte 0b10010010    /* Type = Data 010 (Execute/Read) - S = 1 (Descriptor Type Code or Data Segment) - SPL = 0 - P = 1 */
    .byte 0b11001111    /* Segment Limit = 1111 - AVL = 0 - L = 0 - D/B = 1 - G = 1 */
    .byte 0x0           /* Base 24:31 */
gdt_end:
gdt_descriptor:
    .word gdt_end - gdt_start 
    .long gdt_start

.code32
protected_mode:
    mov $DATA_SEG, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0X7000, %ebp
    mov %ebp, %esp
    sgdt 0x7000
    
vga_print:
    mov $message, %ecx                
    mov $1280, %eax
    /** 
    * Cada linea tiene 2 * 80 caracteres ===> 80 * 2 = 160. Como se quiere imprimir en pantalla en la linea 9
    * (9-1) * 160 = 1280 es la posicion en que deberia comenzar a imprimir 
    */
    lea 0xb8000(%eax), %edx
    /* Color de fondo y letra */
    mov $0x2F, %ah
loop:
    /** 
    * Al princpio carga el primer caracter (h) para imprimir en pantalla, y luego incrementa 1 el registro ecx 
    * para apuntar al siguente caracter y incrementa 2 el registro edx para apuntar a la siguente posicion en la pantalla vga
    */
    mov (%ecx), %al            
    cmp $0, %al
    jz end
    mov %eax, (%edx)
    add $1, %ecx
    add $2, %edx
    jmp loop
end:
    jmp .
message:
    .asciz "hello world"   
    
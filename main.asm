section .text
    global asmFloatToInt

asmFloatToInt:
    ; Crea espacio para la variable local i_gini
    sub esp, 4

    ; Carga el valor de punto flotante en la pila de la FPU
    fld dword [esp + 8] ; el argumento f_gini está en esp + 8

    ; Convierte a entero y almacena en i_gini
    fistp dword [esp] ; i_gini está en esp

    ; Incrementa i_gini
    inc dword [esp]

    ; Carga i_gini en eax para retornar
    mov eax, [esp]

    ; Limpia la pila
    add esp, 4

    ; Retorna
    ret
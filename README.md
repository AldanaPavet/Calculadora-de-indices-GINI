**TP3 modo protegido**

Los procesadores x86 mantienen compatibilidad con sus antecesores y para agregar nuevas funcionalidades deben ir “evolucionando” en el tiempo durante el proceso de arranque. Todos los CPUs x86 comienzan en modo real en el momento de carga (boot time) para asegurar compatibilidad hacia atrás,  en cuanto se los energiza se comportan  de manera muy primitiva, luego mediante comandos se los hace evolucionar hasta poder obtener la máxima cantidad de prestaciones posibles.
El modo protegido es un modo operacional de los CPUs compatibles x86 de la serie 80286 y posteriores. Este modo es el primer salto evolutivo de los x86. El modo protegido tiene un número de nuevas características diseñadas para mejorar la multitarea y la estabilidad del sistema, tales como la protección de memoria, y soporte de hardware para memoria virtual como también la conmutación de tareas.

En este TP ejecutaremos un trozo de código que configura nuestro procesador para llevarlo desde el modo real al modo protegido.

Clonen este repositorio e inicializan los submódulos (ver README).
https://gitlab.com/sistemas-de-computacion-2021/protected-mode-sdc

Se adjunta el manual del desarrollador para procesadores x86 de Intel.

Y un repositorio de código muy interesante para el práctico que ya está incluido en el repositorio clonado.
https://github.com/cirosantilli/x86-bare-metal-examples

Para este trabajo deberán realizar un informe que responda a las consignas que se encuentran en la presentación. Mostrar la ejecución del ejemplo en una máquina virtual explicando lo que sucede.

# Introducción
Miguel Ángel Solinas 12 may 2022
Javier Alejandro Jorge 29 may 2023 

Bueno, ya conoce algo de C, ha escrito algunos programas normales para que se ejecuten como procesos, y quiere ir donde está la acción real, donde un solo puntero salvaje puede borrar su sistema de archivos y un volcado del núcleo significa un reinicio.

¿Qué es exactamente un módulo del núcleo? Los módulos son fragmentos de código que se pueden cargar y descargar en el kernel según se requiera. Extienden la funcionalidad del kernel sin necesidad de reiniciar el sistema. Por ejemplo, un tipo de módulo es el controlador de dispositivo, que permite que el núcleo acceda al hardware conectado al sistema. Sin módulos, tendríamos que construir kernels monolíticos y agregar nuevas funciones directamente en la imagen del kernel. Además de tener kernels más grandes, esto tiene la desventaja de requerir que reconstruyamos y reiniciemos el kernel cada vez que queramos una nueva funcionalidad.

## Preparación
Vamos a necesitar un SO Linux instalado con sus fuentes o al menos los headers. La descarga puede demorar algunos minutos, dependiendo del BW de descarga de su conexión a internet.
Por otro lado, en esta primera parte vamos a trabajar con los siguientes programas fuentes y make files.

```
fork https://gitlab.com/sistemas-de-computacion-unc/kenel-modules.git 
git clone (su propia url… empieza con SU nombre de usuario)
sudo apt-get install build-essential checkinstall kernel-package linux-source
```

## Condiciones de aprobación 
En el transcurso de la clase se le plantearán dos desafíos que serán evaluados en coloquios grupales con la entrega de la segunda parte del TP#4. Concretamente serán:

# Desafío #1 
¿Qué es checkinstall y para qué sirve?
¿Se animan a usarlo para empaquetar un hello world ? 
Revisar la bibliografía para impulsar acciones que permitan mejorar la seguridad del kernel, concretamente: evitando cargar módulos que no estén firmados.

# Desafío #2
Debe tener respuestas precisas a las siguientes preguntas y sentencias:
¿ Qué funciones tiene disponible un programa y un módulo ?
Espacio de usuario o espacio del kernel.
Espacio de datos.
Drivers. Investigar contenido de /dev.
Bibliografía
https://access.redhat.com/documentation/es-es/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/signing-kernel-modules-for-secure-boot_managing-kernel-modules

https://sysprog21.github.io/lkmpg/#what-is-a-kernel-module 

https://opensource.com/article/19/10/strace 

https://docs.google.com/presentation/d/1BYES6Zkfx5K85REWyXsFeW-VngBLOzlDzaYCsTVoc0Y/edit#slide=id.g724a4c87a0_0_5 

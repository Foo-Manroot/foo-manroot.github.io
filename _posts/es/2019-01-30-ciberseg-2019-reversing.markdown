---
layout: post
title:  "Ciberseg 2019: ingeniería inversa"
date:	2019-01-30 13:41:04 +0100
author: foo
categories: es ctf ciberseg write-up reversing
lang: es
ref: ciberseg-2019-reversing
---


En este post voy a explicar mis soluciones a los retos del Ciberseg de 2019. En concreto,
este artículo se corresponde con los de la categoría de **ingeniería inversa**.

El [Ciberseg](https://ciberseg.uah.es/) es un congreso que tiene lugar todos los años por
estas fechas en la Universidad de Alcalá de Henares. La verdad es que los años anteriores
siempre ha sido divertido, y este año no ha sido menos :) Además, el podio ha estado muy
reñido y hubo sorpresas de última hora :D (al final gané en la última hora,
literalmente, por apenas unos pocos puntitos).

En fin, estos son los retos y sus soluciones. Para los que haga falta, dejaré también los
recursos necesarios que nos aportaron para intentar el reto por vuestra cuenta.

-----------------------------------------------------------------------------------------

# 1.- Doom 5 Alpha (25 puntos)

La descripción de este reto dice:
> Se ha filtrado el último Doom, pero no tengo la clave :(

También se aportaba el binario del que hay que conseguir la _flag_:
[doom5_alpha](/assets/posts/2019-01-30-ciberseg-2019-reversing/doom5_alpha).

Si lo ejecutamos, nos muestra un mensaje que dice
_Para jugar este juego necesitas una licencia_.

Lo primero que hacemos es ver un poco por encima el código para hacernos una idea de lo
que se está haciendo:
```asm
$ objdump -M intel -d doom5_alpha
(...)
00000000000011be <main>:
    11be:	55                      push   %rbp
    11bf:	48 89 e5                mov    %rsp,%rbp
    11c2:	48 83 ec 30             sub    $0x30,%rsp
    11c6:	48 8b 05 d3 2e 00 00    mov    0x2ed3(%rip),%rax        # 40a0 <stdout@@GLIBC_2.2.5>
    11cd:	48 89 c1                mov    %rax,%rcx
    11d0:	ba 2d 00 00 00          mov    $0x2d,%edx
    11d5:	be 01 00 00 00          mov    $0x1,%esi
    11da:	48 8d 3d 27 0e 00 00    lea    0xe27(%rip),%rdi        # 2008 <_IO_stdin_used+0x8>
    11e1:	e8 8a fe ff ff          callq  1070 <fwrite@plt>
    11e6:	48 8b 15 c3 2e 00 00    mov    0x2ec3(%rip),%rdx        # 40b0 <stdin@@GLIBC_2.2.5>
    11ed:	48 8d 45 d0             lea    -0x30(%rbp),%rax
    11f1:	be 21 00 00 00          mov    $0x21,%esi
    11f6:	48 89 c7                mov    %rax,%rdi
    11f9:	e8 52 fe ff ff          callq  1050 <fgets@plt>
    11fe:	48 8d 45 d0             lea    -0x30(%rbp),%rax
    1202:	48 89 c6                mov    %rax,%rsi
    1205:	48 8d 3d 54 2e 00 00    lea    0x2e54(%rip),%rdi        # 4060 <pass>
    120c:	e8 4f fe ff ff          callq  1060 <strcmp@plt>
    1211:	85 c0                   test   %eax,%eax
    1213:	75 43                   jne    1258 <main+0x9a>
    1215:	48 8d 3d 1c 0e 00 00    lea    0xe1c(%rip),%rdi        # 2038 <_IO_stdin_used+0x38>
    121c:	b8 00 00 00 00          mov    $0x0,%eax
    1221:	e8 1a fe ff ff          callq  1040 <printf@plt>
    1226:	48 8d 3d ab 14 00 00    lea    0x14ab(%rip),%rdi        # 26d8 <_IO_stdin_used+0x6d8>
    122d:	e8 fe fd ff ff          callq  1030 <puts@plt>
    1232:	48 8d 3d 4f 2e 00 00    lea    0x2e4f(%rip),%rdi        # 4088 <flag>
    1239:	e8 37 ff ff ff          callq  1175 <xor>
    123e:	48 8d 35 43 2e 00 00    lea    0x2e43(%rip),%rsi        # 4088 <flag>
    1245:	48 8d 3d ab 14 00 00    lea    0x14ab(%rip),%rdi        # 26f7 <_IO_stdin_used+0x6f7>
    124c:	b8 00 00 00 00          mov    $0x0,%eax
    1251:	e8 ea fd ff ff          callq  1040 <printf@plt>
    1256:	eb 0c                   jmp    1264 <main+0xa6>
    1258:	48 8d 3d a9 14 00 00    lea    0x14a9(%rip),%rdi        # 2708 <_IO_stdin_used+0x708>
    125f:	e8 cc fd ff ff          callq  1030 <puts@plt>
    1264:	b8 00 00 00 00          mov    $0x0,%eax
    1269:	c9                      leaveq
    126a:	c3                      retq
    126b:	0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
(...)
```

Vemos que primero realiza una llamada a _fwrite_ (en la línea **:11e1**) para mostrar el
mensaje que pide el código. Luego llama a _fgets_ para pedir la clave de acceso y la
compara con `<pass>`, que es lo que sea que haya en **0x4060**. Si coinciden, (línea
**:1213**), continúa a calcular la _flag_ y la muestra por pantalla.


Hay varias formas de resolver este reto: depurar con _gdb_ y modificar _$eip_ para que se
salte la comparación, saltar directamente a la función que calcula la _flag_ (`<xor>`,
que se llama en la línea **:1239**)... O podemos ver qué es lo que hay en **0x4060** para
introducir el valor correcto y dejar que el programa se ejecute normalmente.

Para ver la cadena que se usa para comparar (la clave del juego), podemos usar de nuevo
_objdump_ y buscar en la sección `.data`:
```hexdump
$ objdump -s -j .data doom5_alpha

doom5_alpha:     file format elf64-x86-64

Contents of section .data:
 4040 00000000 00000000 48400000 00000000  ........H@......
 4050 00000000 00000000 00000000 00000000  ................
 4060 38383931 34353332 64667238 34373334  88914532dfr84734
 4070 6865666f 346b3564 32333835 37333435  hefo4k5d23857345
 4080 00000000 00000000 2818190b 3d071d11  ........(...=...
 4090 05130000                             ....
```

Si probamos a introducir este valor (desde **0x4060** hasta **0x4080**, donde está el
indicador de fin de cadena), vemos que la clave es correcta y nos devuelve la _flag_:
```
$ ./doom5_alpha
Para jugar este juego necesitas una licencia 88914532dfr84734hefo4k5d23857345

+-----------------------------------------------------------------------------+
| |       |\                                           -~ /     \  /          |
|~~__     | \                                         | \/       /\          /|
|    --   |  \                                        | / \    /    \     /   |
|      |~_|   \                                   \___|/    \/         /      |
|--__  |   -- |\________________________________/~~\~~|    /  \     /     \   |
|   |~~--__  |~_|____|____|____|____|____|____|/ /  \/|\ /      \/          \/|
|   |      |~--_|__|____|____|____|____|____|_/ /|    |/ \    /   \       /   |
|___|______|__|_||____|____|____|____|____|__[]/_|----|    \/       \  /      |
|  \mmmm :   | _|___|____|____|____|____|____|___|  /\|   /  \      /  \      |
|      B :_--~~ |_|____|____|____|____|____|____|  |  |\/      \ /        \   |
|  __--P :  |  /                                /  /  | \     /  \          /\|
|~~  |   :  | /                                 ~~~   |  \  /      \      /   |
|    |      |/                        .-.             |  /\          \  /     |
|    |      /                        |   |            |/   \          /\      |
|    |     /                        |     |            -_   \       /    \    |
+-----------------------------------------------------------------------------+
|          |  /|  |   |  2  3  4  | /~~~~~\ |       /|    |_| ....  ......... |
|          |  ~|~ | % |           | | ~J~ | |       ~|~ % |_| ....  ......... |
|   AMMO   |  HEALTH  |  5  6  7  |  \===/  |    ARMOR    |#| ....  ......... |
+-----------------------------------------------------------------------------+

Correcto.. Esta es tu Flag!!!!
flag{ArrgPirata}
```

_Easy peasy_ :D

La _flag_ es: `flag{ArrgPirata}`.

-----------------------------------------------------------------------------------------

# 2.- Negativo (200 puntos)

La descripción de este reto dice así:
> Desde la UAH hemos creado un app altamente segura cuyo código es inaccesible.

También se adjunta [este archivo](/assets/posts/2019-01-30-ciberseg-2019-reversing/app.7z).



Una vez hemos extraído su contenido obtenemos un binario llamado `ciberseg-ctf-19`
absurdamente pesada (110 MB para mostrar tres pantallitas...) y que tarda media vida en
iniciar, además de otros 150 MB para los recursos varios con nombre como
_chrome\_100\_percent.pak_ o _LICENSES.chromium.html_ que dan una idea de con qué se ha
hecho la aplicación. Además, en el directorio `resources/` hay un archivo que no deja
lugar a dudas de qué tecnología usa: `electron.asar`.

¡Oh, no! El infame _Electron_. No me voy a desviar del tema para despotricar de Electron.
Sólo quiero que quede claro que lo odio con todo mi alma :(
Quizá algún día haga algún articulillo explicando mi punto de vista, ¿quién sabe?


En fin, el caso es que hay que intentar conseguir el código. Por lo visto esta aplicación
está archivada usando [asar](https://github.com/electron/asar) y, del mismo modo, se
puede extraer el código original simplemente ejecutando
`asar extract resources/app.asar ../extracted`.

Dentro del directorio donde lo hemos extraído tendremos un archivo llamado `main.js`, que
contiene el código principal de la aplicación. En este caso, como es tan sencilla, se
ve rápidamente dónde se comprueba la contraseña:
```javascript
// (...)
  ipcMain.on('password', (event, arg) => {
    console.error(arg) // prints "ping"
    if(arg == Buffer.from("MTI2NWVmNmJjY2RhYzc5OTg1MzhiOTBjOGYxMjVjZjk4M2RiN2ZmZjE3OGUzNWRlMDY4MWQzNDQzM2QxMWM2YQ==", 'base64').toString('ascii')){
      let flag = cipher.decrypt('c93ae864e1b525ab1c64a02e7996ea52', arg);
      dialog.showMessageBox({title: "Congratulations", message: "The flag is", detail: flag});
    } else {
      mainWindow.setSize(800, 800)
      mainWindow.loadFile('logo.svg')
    }
  })
// (...)
```

El valor de la contraseña, decodificado en Base64, es
**1265ef6bccdac7998538b90c8f125cf983db7fff178e35de0681d34433d11c6a**. Si introducimos ese
valor en el diálogo que nos pide la contraseña, nos devuelve la _flag_:

{% include image.html
	src="/assets/posts/2019-01-30-ciberseg-2019-reversing/flag-electron.jpg"
	title="Solución del reto"
	alt="Ventana emergente con la solución del reto"
%}

La _flag_ es: `flag{show_the_code}`.


-----------------------------------------------------------------------------------------

# 3.- Argumenta (250 puntos)

La descripción de este reto dice:
> Porque hablando se entiende la gente.

También se adjunta [el binario](/assets/posts/2019-01-30-ciberseg-2019-reversing/a43b59111fef20ed7f8e2e53482076b99acea606.bin)
con el que hay que trabajar.


Como sugiere el nombre del reto, esto tiene algo que ver con los argumentos que se le
pasan al ejecutable.

He de reconocer que me pasé bastante tiempo estudiando el código; pero al final todo se
reduce a buscar las instrucciones `cmp` para ver con qué valor se compara en cada momento
e ir reconstruyendo la cadena carácter a carácter.

Las primeras comprobaciones se hacen sobre el número de argumentos. Los requisitos son:

  - <img src="https://latex.codecogs.com/svg.latex?\fn_cm%20\left(%20argc%20\gg%201%20\right)%20\mathrel{\&}%201%20\neq%200" class="inline-math" alt="\left( argc \gg 1 \right) \mathrel{\&} 1 \neq 0"> Es decir, que el número de argumentos (contando con `argc [0]`, que es el nombre del programa) **dividido entre dos** debe ser **impar**.

  - <img src="https://latex.codecogs.com/svg.latex?\fn_cm%20\left\{\begin{matrix}%20%26%20(5%20\mod%20argc)%20\neq%200%20%26%20\\%20%26%20(7%20\mod%20argc)%20\neq%200%20%26%20\\%20%26%20(10%20\mod%20argc)%20\neq%200%20%26%20\end{matrix}%20\right." class="inline-math" alt="\left\{ \begin{matrix} & (5 \mod argc) \neq 0 & \\ & (7 \mod argc) \neq 0 & \\ & (10 \mod argc) \neq 0 & \end{matrix} \right.">

Un número válido de argumentos, por ejemplo, es **2** (<img src="https://latex.codecogs.com/svg.latex?\fn_cm%20argc%20=%203" class="inline-math" alt="argc = 3">, contando con el nombre del programa).


Después de averiguar el número apropiado de argumentos toca pasar a saber cuál es su
valor. Normalmente usaría IDA, pero la versión de demo no funciona con binarios de 64
bits; así que usaré la demo de
[Hopper](https://latex.codecogs.com/svg.latex?\fn_cm%20argc%20=%203), que también
funciona genial.

El grafo de llamadas que nos devuelve Hopper es el siguiente:
{% include image.html
	src="/assets/posts/2019-01-30-ciberseg-2019-reversing/call-graph.jpg"
	title="Grafo de llamadas"
	alt="Cajas representando un fragmento de código, con flechas uniendo distintas cajas para representar el flujo de ejecución"
%}

La parte de la izquierda, marcada en rojo, se corresponde con la comprobación, carácter a
carácter, del primer argumento con la cadena `flag:`. Cada una de las cajitas de abajo se
corresponde con cada uno de los caracteres, que se van comprobando según el valor actual
del índice que itera por `argv [1]`.


Luego tenemos la parte de la derecha, marcada en verde. Esta parte es un poco más
enrevesada; pero básicamente va comparando `argv [2]` también carácter a carácter; pero
esta vez lo hace contra una cadena que hay en memoria y que es rellenada justo en la
cajita que hay antes de entrar a la zona verde. Su código es:
```nasm
mov        qword [rbp+var_35], 0x0
mov        dword [rbp+var_2D], 0x0
mov        byte [rbp+var_29], 0x0
mov        byte [rbp+var_35], 0x6c
mov        byte [rbp+var_34], 0x61
mov        byte [rbp+var_33], 0x63
mov        byte [rbp+var_32], 0x64
mov        byte [rbp+var_31], 0x72
mov        byte [rbp+var_30], 0x69
mov        byte [rbp+var_2F], 0x65
mov        byte [rbp+var_2E], 0x74
mov        byte [rbp+var_2D], 0x6f
mov        byte [rbp+var_2C], 0x67
mov        byte [rbp+var_2B], 0x66
mov        qword [rbp+var_28], 0x8
mov        dword [rbp+var_1C], 0x0
mov        dword [rbp+var_18], 0x0
```

Esto introduce el valor `lacdrietogf` en la variable. Pero ¡cuidado! Este no es el valor
del segundo argumento. Las comparaciones se realizan con un índice que va cambiando y
seleccionando el valor adecuado. Esta cadena es más bien una tabla de consulta.

El caso es que, después de todas las comparaciones, tenemos que el valor de este segundo
argumento es `retorcido`. Sin duda, este reto es bastante retorcido XD
```sh
$ ./a43b59111fef20ed7f8e2e53482076b99acea606.bin flag: retorcido
¡Bien hecho!
```

Nuestra _flag_ es `flag{retorcido}`.


-----------------------------------------------------------------------------------------

# 4.- Pon tu Nintendo PowerGlove™ y empieza a jugar (300 puntos)

La descripción del reto dice:
> Todos me dicen que este nivel de Super Mario es imposible pero yo llego al final sin
> problema. Si no pasas esto no eres digno de ser un Gamer.

Se adjunta también [este archivo](/assets/posts/2019-01-30-ciberseg-2019-reversing/smb3.nes')

Si se abre (yo usé el emulador [nestopia](http://nestopia.sourceforge.net/) y funciona
sin problemas en mi Arch Linux), vemos que se trata del _Super Mario Bros 3_. Al intentar
pasar el primer nivel, vemos que hay algo raro, y es que nos encontramos con un
precipicio con un hueco enorme, imposible de saltar.

Lo que hice fue buscar en las internetes algún programita que me permitiera editar los
niveles del _Super Mario Bros 3_ para poder hacer más pequeño ese hueco, o algo que me
fuera de utilidad. Después de probar varios, encontré
[SMB3 workshop](https://www.romhacking.net/utilities/298/) que resulta que es una
maravilla. Con este programa no necesito ni editar el nivel para pasármelo; porque, al
editar el siguiente nivel, se puede ver la solución directamente:
{% include image.html
	src="/assets/posts/2019-01-30-ciberseg-2019-reversing/flag-smb3.jpg"
	title="Nivel con la solución"
	alt="Nivel siguiente, en el que se ven unas monedas de las del juego formando la palabra 'GOOMBA', que es la solución del reto."
%}


Aunque los organizadores tenían pensada otra solución XD

Este es el _write-up_ que pasaron una vez terminó la competición, viendo que casi todo el
mundo había llegado a la solución usando herramientas ya existentes (aunque hubo quien lo
hizo editando la memoria):
{% include embed_pdf.html
	path="/assets/posts/2019-01-30-ciberseg-2019-reversing/sol_propuesta.pdf"
%}


Sea cual sea el método usado, la _flag_ es: `flag{goomba}`.


-----------------------------------------------------------------------------------------

# 5.- Cuisine revolution (300 puntos)

La descripción de este reto dice así:
>  El software incorporado en este cacharro de cocina es altamente complejo.

También se adjunta el binario al que aplicarle la ingeniería inversa:
[crackme2](/assets/posts/2019-01-30-ciberseg-2019-reversing/crackme2).


Igual que en el [tercer reto](#3--argumenta-250-puntos), empezamos por echarle un vistazo
al código del binario para hacernos una idea un poco de cómo va:
```asm
$ objdump -d crackme2
(...)
0000000000001212 <main>:
    1212:	55                      push   %rbp
    1213:	48 89 e5                mov    %rsp,%rbp
    1216:	48 83 ec 10             sub    $0x10,%rsp
    121a:	b9 00 00 00 00          mov    $0x0,%ecx
    121f:	ba 01 00 00 00          mov    $0x1,%edx
    1224:	be 00 00 00 00          mov    $0x0,%esi
    1229:	bf 00 00 00 00          mov    $0x0,%edi
    122e:	b8 00 00 00 00          mov    $0x0,%eax
    1233:	e8 18 fe ff ff          callq  1050 <ptrace@plt>
    1238:	48 85 c0                test   %rax,%rax
    123b:	79 16                   jns    1253 <main+0x41>
    123d:	48 8d 3d c4 0d 00 00    lea    0xdc4(%rip),%rdi        # 2008 <_IO_stdin_used+0x8>
    1244:	e8 e7 fd ff ff          callq  1030 <puts@plt>
    1249:	b8 00 00 00 00          mov    $0x0,%eax
    124e:	e9 a2 00 00 00          jmpq   12f5 <main+0xe3>
    1253:	48 8b 05 06 2e 00 00    mov    0x2e06(%rip),%rax        # 4060 <stdout@@GLIBC_2.2.5>
    125a:	48 89 c1                mov    %rax,%rcx
    125d:	ba 2d 00 00 00          mov    $0x2d,%edx
    1262:	be 01 00 00 00          mov    $0x1,%esi
    1267:	48 8d 3d d2 0d 00 00    lea    0xdd2(%rip),%rdi        # 2040 <_IO_stdin_used+0x40>
    126e:	e8 ed fd ff ff          callq  1060 <fwrite@plt>
    1273:	48 8b 15 f6 2d 00 00    mov    0x2df6(%rip),%rdx        # 4070 <stdin@@GLIBC_2.2.5>
    127a:	48 8d 45 f5             lea    -0xb(%rbp),%rax
    127e:	be 0a 00 00 00          mov    $0xa,%esi
    1283:	48 89 c7                mov    %rax,%rdi
    1286:	e8 b5 fd ff ff          callq  1040 <fgets@plt>
    128b:	48 8d 45 f5             lea    -0xb(%rbp),%rax
    128f:	48 89 c7                mov    %rax,%rdi
    1292:	e8 ce fe ff ff          callq  1165 <xor>
    1297:	48 8d 45 f5             lea    -0xb(%rbp),%rax
    129b:	48 8d 35 a6 2d 00 00    lea    0x2da6(%rip),%rsi        # 4048 <pass>
    12a2:	48 89 c7                mov    %rax,%rdi
    12a5:	e8 04 ff ff ff          callq  11ae <compare>
    12aa:	85 c0                   test   %eax,%eax
    12ac:	75 22                   jne    12d0 <main+0xbe>
    12ae:	48 8b 05 ab 2d 00 00    mov    0x2dab(%rip),%rax        # 4060 <stdout@@GLIBC_2.2.5>
    12b5:	48 89 c1                mov    %rax,%rcx
    12b8:	ba 33 00 00 00          mov    $0x33,%edx
    12bd:	be 01 00 00 00          mov    $0x1,%esi
    12c2:	48 8d 3d a7 0d 00 00    lea    0xda7(%rip),%rdi        # 2070 <_IO_stdin_used+0x70>
    12c9:	e8 92 fd ff ff          callq  1060 <fwrite@plt>
    12ce:	eb 20                   jmp    12f0 <main+0xde>
    12d0:	48 8b 05 89 2d 00 00    mov    0x2d89(%rip),%rax        # 4060 <stdout@@GLIBC_2.2.5>
    12d7:	48 89 c1                mov    %rax,%rcx
    12da:	ba 0a 00 00 00          mov    $0xa,%edx
    12df:	be 01 00 00 00          mov    $0x1,%esi
    12e4:	48 8d 3d b9 0d 00 00    lea    0xdb9(%rip),%rdi        # 20a4 <_IO_stdin_used+0xa4>
    12eb:	e8 70 fd ff ff          callq  1060 <fwrite@plt>
    12f0:	b8 00 00 00 00          mov    $0x0,%eax
    12f5:	c9                      leaveq
    12f6:	c3                      retq
    12f7:	66 0f 1f 84 00 00 00    nopw   0x0(%rax,%rax,1)
    12fe:	00 00
(...)
```

Lo más interesante de este reto es que empieza llamando a `ptrace` en **:1233** para
detectar si hay un depurador enganchado. Si es así, directamente termina la ejecución.
Tampoco es un problema, claro, porque podemos sencillamente modificar _$eip_ o _$eflags_
y hacemos que siga como si nada. Simplemente es algo a tener en cuenta, sin más.


Después de comprobar si se está ejecutando directamente o con un depurador, imprime una
cadena y espera la entrada del usuario (en **:1286**). Luego hace una llamada a la
función `xor` con nuestra cadena y compara el resultado con algo que hay en memoria.


Parece que es tan sencillo como coger `gdb`, saltarse la restricción del `ptrace` y mirar
lo que devuelve la función `xor`.

A grandes rasgos, lo que hace esta función es, así a ojo:
```c
void xor (char * str_in)
{
	int i;
	char a, b;

	for (i = 0; i <= 8; i++)
	{
		a = str_in [i]
		b = i + 0x69	// i + 105 Supongo que algún valor habría que darle... XD

		str_in [i] = a ^ b
	}
}
```

La respuesta, entonces, es ver el contenido de la cadena que se está comparando luego con
el contador (que sabemos que tiene los valores 0x69, 0x6a, 0x6b...). La cadena ofuscada
está en la memoria, así que la podemos consultar:
```
$ objdump -s -j .data crackme2

crackme2:     file format elf64-x86-64

Contents of section .data:
 4038 00000000 00000000 40400000 00000000  ........@@......
 4048 3a060a1c 0e060000 500000             :.......P..
```

Y ahora es tan simple como calcular la _XOR_ con el contador. Por ejemplo, en Python se
puede hacer en un par de líneas:
```python
# Python 3.7.2 (...)
# [...] on linux
# Type "help", "copyright", "credits" or "license" for more information.
>>> a = '\x3a\x06\x0a\x1c\x0e\x06\x00\x00\x50'
>>> b = [ chr (i) for i in range (0x69, 0x69 + 9, 1) ]
>>> b
['i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q']
>>> "".join ([ chr ( ord (a [i]) ^ ord (b [i])  ) for i in range (8) ])
'Slapchop'
>>> "".join ([ chr ( ord (a [i]) ^ ord (b [i])  ) for i in range (9) ])
'Slapchop!'
>>>
```

Ahora sólo queda comprobar que es el valor correcto y ver qué devuelve el programa:
```
$ ./crackme2
Esto te va a Fascinar!! Dame la contraseña: Slapchop!
Es Correcto.. La Contraseña es tu Flag Campeon!!!
```

Chachi pistachi :D

La _flag_ es: `flag{Slapchop!}`.

-----------------------------------------------------------------------------------------

Pues hasta aquí los retos de ingeniería inversa. A ver si saco tiempo y termino ya con
los de web, que es la única categoría que me queda :)

Siempre me lo paso bien con los retos del Ciberseg, y este año no ha sido menos. Espero
poder competir el año que viene, que seguro que se superan otra vez.

También quiero dar mi enhorabuena a los organizadores por todo su esfuerzo y su
creatividad para crear retos fuera de lo común :D

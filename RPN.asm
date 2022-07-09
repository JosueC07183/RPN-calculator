#Estudiante: Josue Salmeron Cordoba, C07183.
#Tarea 3_4 de IE0321.
#Este programa ejecuta operaciones basicas de la aritmetica (+,-,*,/ y raiz cuadrada). La calculadora solamente recibe numeros enteros.
#Nota o bug al escribir 3 valores solo se consideran los dos ultimos elementos, el que se escribe de primero se le hace un pop.

.data					#Aqui se cargan todas las etiquetas del programa.
prompt: .asciiz "\n\n Reverse Polish Notation. \n"
RPN: .asciiz  "\n Digite un numero entero o la operacion a realizar. \n"
input: .space 64
error_1: .asciiz "\n El valor digitado no es valido.\n"
resultado: .asciiz "\n El resultado es: \n"
clear: .asciiz "\n La pila se ha borrado exitosamente. \n"
ultimo: .asciiz "\n El ultimo elemento en la pila es: \n"
ind: .asciiz "\n Error, no se puede dividir entre cero. \n"
comp: .asciiz "\n La calculadora RPN no realiza operaciones en variable compleja. \n"
ten: .float 10.0			#Se toma ten como un float.
zero: .float 0.0			#Se toma a zero como un float.
menos: .float -1.0			#Se toma menos como un float.
.text
main:					#Inicio del main.
	addiu $v0, $0, 4		#Se le indica al OS que se trata de un string.
	la $a0, prompt			#Se carga el contenido en la etiqueta prompt.
	syscall				#Syscall ejecuta la accion anterior.
	jal Loop1			#Salto al Loop1, fin del main.
	
Loop1:				 	#Aqui se muestra el inicio de la calculadora por consola.
	addiu $v0, $0, 4	 	#Se le indica al OS que se trata de un string.
	la $a0, RPN		 	#Se carga el contenido en la etiqueta RPN.
	syscall				#Syscall ejecuta la accion anterior.
	addiu $v0, $0, 8		#Aqui se carga un 8 en $v0.
	la $a0, input			#Se carga el contenido en la etiqueta input.
	addiu $a1, $0, 40	 	#Se define $a0 = 40, esto es la capacidad de numeros a leer.
	syscall			 	#Syscall ejecuta la accion anterior.
	addu $t0, $0, $a0	 	#$t0=$a0, es decir, el registro $t0 almacena el inicio del string.
	addiu $t2, $0, 0	 	#$t2=0, esto es como el contador del string.

Array:				 	#Esta etiqueta sirve para determinar el tamano del string.
	lbu $t1, 0($t0)		 	#Con la instruccion lbu se carga en $t1 el tamano del string a 10.
	beq $t1, 10, string_size 	#Si $t1 es igual a 10, se pasa a la etiqueta string_size.
	addiu $t0, $t0, 1	 	#Con $t0 = 1, se van agregando o contando elementos en el string.
	addiu $t2, $t2, 1	 	#$t2++, se suma uno al contador para seguir con la iteracion.
	j Array			 	#Salto a la etiqueta Array.

string_size:			  	#Aqui se determina el tamano del string, note que puede ser un numero o un operador.
	bne $t2, 1, size	  	#La de este branch es comparar lo que escribe el usuario por consola.
	lbu $t3, 0($a0)		  	#Se carga en $t3 el tamano del string ya que pueden ser dos numeros o un operador.
	addi $t5, $0, '9'	  	#Se carga en $t5 la dimension de 9.
	
	beq $t3, '+', suma	  	#Si $t3 = '+', se pasa a la etiqueta suma. 
	beq $t3, '-', resta	  	#Si $t3 = '-', se pasa a la etiqueta resta.
	beq $t3, '*', producto    	#Si $t3 = '*', se pasa a la etiqueta producto.
	beq $t3, '/', division	  	#Si $t3 = '/', se pasa a la etiqueta division.
	beq $t3, 's', raiz	  	#Si $t3 = 's', se pasa a la etiqueta raiz.
	beq $t3, 'S', raiz        	#Si $t3 = 'S', se pasa a la etiqueta raiz.
	beq $t3, 'c', clear_stack 	#Si $t3 = 'c', se pasa a la etiqueta clear_stack.
	beq $t3, 'C', clear_stack 	#Si $t3 = 'C', se pasa a la etiqueta clear_stack.
	beq $t3, 32, show         	#Si $t3 = '32', se pasa a la etiqueta show. 
	beq $t3, 'o', off	  	#Si $t3 = 'o', se apaga la calculadora.
	beq $t3, 'O', off	  	#Si $t3 = 'O', se apaga la calculadora.

	sltiu $t6, $t3, '0'	 	#Si $t6=1 implica que $t3<'0'.
	beq $t6, $1, error	 	#Si $t6=1 entonces se pasa a la etiqueta error.
	sltu $t6, $t5, $t3	 	#$t6=1 si $t5<$t3.
	beq $t6, $1, error	 	#De cumplirse lo anterior, se pasa a la etiqueta error.
	
	addi $t6, $t3, -48	 	#$t6 = $t3 -48, la idea de restar 48 es para hacer la conversion de entero a flotante.
	mtc1 $t6, $f0		 	#Se toma el valor de $f0 y se mueve al registro $t6.
	cvt.s.w $f0, $f0 	 	#Se completa la conversion de entero a flotante.
	
	addi $sp, $sp, -4		#Se reserva un espacio en la memoria.
	s.s $f0, 0($sp)			#Se guarda en $f0 el espacio de memoria.
	addi $s7, $s7, 4		#Se regresa el espacio de memoria que se tomo anteriormente.
	j Loop1				#Se salta al Loop1.

size:					#La idea de esta etiqueta es apilar el string.
	lbu $t8, 0($a0)			#Se carga en el registro $t8 la dimension del string.
	beq $t8, '-', minus		#La idea de este branch es revisar si el string inicia con un signo negativo.
	addu $t0, $0, $a0		#El registro $t0 toma la direccion del string.
	addiu $t9, $t2, 0		#Ahora $t9 toma el valor del registro $t2.
	addi $t9, $t9, -1		#Aqui se decrementa el valor del registro $t9.
	l.s $f3,ten			#Aqui $f3=10.
	l.s $f1,zero			#Aqui $f1=0.
	addi $t5, $zero, '9'		#La idea de cargar el 9 es para que la calculadora interprete que se trata de un numero.
	
conversion:				#La idea de esta etiqueta es analizar el string.
	lbu $t1, 0($t0)			#Se carga en $t1 el string.
	beq $t1, 10, push		#Este branch sirve para hacer un push.

	sltiu $t6, $t1, '0'		#Si $t6=1 implica que $t1<'0'.
	beq $t6, $1, error		#Si $t6=1 entonces se pasa a la etiqueta error.
	sltu $t6, $t5, $t1		#$t6=1 si $t5<$t1.
	beq $t6, $1, error		#De cumplirse lo anterior, se pasa a la etiqueta error.

	addi $t1, $t1, -48		#Se le resta 48 a $t1 para realizar la conversion de entero a flotante.
	jal exp				#Salto a la etiqueta exp.
	mov.s $f2, $f12			#Una vez que se hizo el salto a la etiqueta exp se mueve el valor de $f12 a $f2. 
					#La idea de la funcion exp es que al realizar el producto de un numero por uno negativo-
					#muestre un resultado consistente.
	
	addi $t9, $t9, -1		#Se decrementa el registro $t9.
	addi $t0, $t0, 1		#$t0++.
	mtc1 $t1, $f0			#Se mueve el valor de $f0 al registro $t1.
	cvt.s.w $f0, $f0		#Se completa la conversion.
	mul.s $f0, $f0, $f2		#Se realiza el producto de $f0 y $f2.
	add.s $f1, $f1, $f0		#Se ejecuta la suma de $f1 y $f2.
	j conversion			#Salto a la etiqueta conversion.
	
push:					#La idea de esta funcion es apilar elementos en las primeras posiciones de memoria.
	addi $sp, $sp, -4		#Se reserva un espacio en memoria.
	s.s $f1, 0($sp)			#Se hace uso de ese espacio de memoria.
	addi $s7, $s7, 4		#Se regresa el valor de la pila.
	j Loop1				#Salto a la etiquera Loop1.
	
minus:
	addu $t0, $zero, $a0		#Ahora $t0 tiene la nueva direccion del string.
	addiu $t9, $t2, 0		#Se iguala el registro $t9 a $t2, la idea es convocar a la funcion que se encuentra en la etiqueta exp.
	addi $t9, $t9, -2		#Se decrementa la dimension en 2.
	l.s $f3,ten			#Aqui #f3=10.
	l.s $f1,zero			#Aqui $f1=0.
	addi $t5, $0, '9'		#La idea de cargar un 9 sirve para saber si se trata de un numero o no.
	addi $t0, $t0, 1		#Se va incrementando los registros para ir haciendo un pop en el string.
	
conversion_2:				#La principal idea de esta funcion es realizar la conversion de un entero negativo a punto flotante.
	lbu $t1, 0($t0)			#Se carga en $t1 el string.
	beq $t1, 10, push_2		#La idea de este branch es comprobar que se trata de un numero, sino saltar a la funcion con la etiqueta push_2.
	
	sltiu $t6, $t1, '0'		#Si $t6=1 implica que $t1<'0'.
	beq $t6, $1, error		#Si $t6=1 entonces se pasa a la etiqueta error.
	sltu $t6, $t5, $t1		#$t6=1 si $t5<$t1.
	beq $t6, $1, error		#De cumplirse lo anterior, se pasa a la etiqueta error.
	addi $t1, $t1, -48		#La idea de restar 48 al registro $t1 es para hacer la conversion de entero a flotante.
	jal exp				#Salto a la funcion exp.
	mov.s $f2, $f12			#Se mueve el resultado de $f12 a $f2.
	addi $t9, $t9, -1		#Se decrementa el registro $t9.
	addi $t0, $t0, 1		#$t0++
	mtc1 $t1, $f0			#Se mueve la conversion hecha anteriormente a $f0.
	cvt.s.w $f0, $f0		#Se completa la conversion.
	mul.s $f0, $f0, $f2		#$f0 = $f2*$f0.
	add.s $f1, $f1, $f0		#Se ejecuta la suma de $f1 y $f0.
	j conversion_2			#Este salto se hace para volver a realizar la iteracion.

push_2:					#En esta funcion se van apilando los valores negativos.
	l.s $f7, menos			#Aqui $f7=-1.
	mul.s $f1, $f1, $f7		#Ahora $f7=-$f7.
	addi $sp, $sp, -4		#Se reserva un espacio en la memoria.
	s.s $f1, 0($sp)			#Se guarda el espacio de memoria en $f1.
	addi $s7, $s7, 4		#Se regresa el espacio de memoria tomado anteriormente.
	j Loop1				#Salta al Loop1.

error:					#Aqui se imprime un mensaje de error.
	addiu $v0, $0, 4		#Se le indica al OS que se trata de un string
	la $a0, error_1			#Se carga el contenido de la etiqueta error_1.
	syscall				#La funcion syscall se encarga de ejecutar la accion. 
	j Loop1				#Salta al Loop1.

exp:					#En esta etiqueta se realiza una funcion muy similar a la que se hizo en la tarea 2.
	addi $sp, $sp, -16		#Se ajusta la pila para 16 items.
	s.s $f1, 12($sp)		#Reserva para $f1.
	s.s $f2, 8($sp)			#Reserva para $f2.
	s.s $f3, 4($sp)			#Reserva para $f3.
	sw $t9, 0($sp)			#Se guarda el registro $t9.
	l.s $f0,zero			#Aqui $f0=0.
	add.s $f2, $f3,$f0		#Aqui $f2=$f3.
	bne $t9,$0, else 		#Si $t9 =1 entonces se pasa a la etiqueta.
	addi $t9, $0, 1			#Aqui $t9=1.
	mtc1 $t9, $f12 			#Se mueve el registro $t9 a $f12.
	cvt.s.w $f12, $f12		#Se completa la conversion
	lw $t9, 0($sp)			#Reserva para el registro $t9.
	l.s $f3, 4($sp)			#Reserva para $f3.
	l.s $f2, 8($sp)			#Reserva para $f3.
	l.s $f1, 12($sp)		#Reserva para $f3.
	addi $sp, $sp, 16		#pop 16 items off stack.
	jr $ra
	
else:
	addi $t9,$t9,-1			#Se decrementa el registro $t9.
	j iter_pow			#Salto a iter_pow
	
iter_pow:
	beq $t9, $0,ret_pow 		#Si $t9=0 se salta ret_pow.
	mul.s $f1,$f2,$f3		#$f1 = $f2*$f3
	mov.s $f2, $f1			#Se mueve el valor anterior de $f1 a $f2.
	addi $t9, $t9, -1		#Se decremento el contador $t9
	j iter_pow			#Se salta al loop iter_pow
				
ret_pow:				
	mov.s $f12, $f2			#Se mueve el valor de $f2 a $f12.
	lw $t9, 0($sp)			#Reserva para $t9.
	l.s $f3, 4($sp)			#Reserva para $f3.
	l.s $f2, 8($sp)			#Reserva para $f2.		
	l.s $f1, 12($sp)		#Reserva para $f1.
	addi $sp, $sp, 16		#pop 16 items off stack.
	jr $ra
	
suma:					#Aqui se inicia el proceso de las operaciones.
	addi $s7, $s7, -4		#Reserva de 4 items.
	l.s $f0, 4($sp)			#Se toma de memoria en $f0.
	l.s $f1, 0($sp)			#Se toma otra espacio de memoria en $f1.
	add.s $f12, $f0, $f1		#Se ejecuta la suma de $f0 y $f1.
	addiu $v0, $0, 4		#cargamos un 4 en el registro $v0
	la $a0, resultado		#Se carga el contenido de la etiqueta resultado
	syscall				#Aqui syscall muestra el contenido.
	addiu $v0,$0, 2			#Se muestra el resultado final.
	syscall				#Se ejecuta la expresion anterior.
	s.s $f12, 4($sp)		#Se guarda en $f12 un espacio de memoria.
	sw $0, 0($sp)			#Reserva para el registro 0.
	addi $sp, $sp, 4 		#pop 4 items off stack.
	j Loop1				#Salto al Loop1.
	
resta:			       		#Aqui se realiza la resta de los numeros.
	addi $s7, $s7, -4      		#Reserva de 4 items.
	l.s $f0, 4($sp)	       		#Se carga un espacio en $f0.
	l.s $f1, 0($sp)	       		#Se carga un espacio en $f1.
	sub.s $f12, $f0, $f1   		#Aqui se ejecuta la resta.
	addiu $v0, $zero, 4    		#Se le indica al OS que se trata de un string.
	la $a0, resultado     		#Se carga el contenido de la etiqueta resultado.
	syscall		       		#Syscall ejecuta la accion.
	addiu $v0,$0, 2	      		#Aqui se muestra el valor de la resta.
	syscall		       		#Syscall ejecuta la accion.
	s.s $f12, 4($sp)       		#Reserva para $f12.
	sw $0, 0($sp)          		#Reserva para $0.
	addi $sp, $sp, 4       		#pop 4 items off stack.
	j Loop1		      		#Salto al Loop1.

producto:		       		#Aqui se hace el producto de los numeros escritos en la RPN.
	addi $s7, $s7, -4      		#Se reservan 4 items del stack.
	l.s $f0, 4($sp)	       		#Reserva para el penultimo elemento.
	l.s $f1, 0($sp)	       		#Reserva para el ultimo elemento.
	mul.s $f12, $f0, $f1   		#Aqui se ejecuta el producto de los numeros.
	addiu $v0, $0, 4       		#Se le indica al OS que se trata de un string.
	la $a0, resultado      		#Se carga el contenido de la etiqueta resultado.
	syscall		       		#Syscall ejecuta la accion.
	addiu $v0,$0, 2	      		#Esto sirve para mostrar el resultado de la multiplicacion.
	syscall		      		#Se ejecuta la accion.
	s.s $f12, 4($sp)       		#Reserva para $f12.
	sw $0, 0($sp)          		#Reserva para $0.
	addi $sp, $sp, 4       		#pop 4 items off stack. 
	j Loop1		       		#Salto al Loop1.
	
division:
	addi $s7, $s7, -4		#Reserva para 4 items del stack.
	l.s $f0, 4($sp)			#Reserva para el penultimo elemento.
	l.s $f1, 0($sp)			#Reserva para el ultimo elemento.
	l.s $f3, zero			#Se carga un 0 en $f3 para evitar o restringir que la calculadora intente hacer la division entre 0.
	c.eq.s $f1, $f3			#Se compara el ultimo elemento de la pila con cero.
	bc1t restric			#Si ese ultimo elemento de la pila es cero, entonces salta a la etiqueta restric.
	div.s $f12, $f0, $f1		#De lo contrario, aqui se ejecuta la division que queda almacenado en $f12.
	addiu $v0, $zero, 4		#cargamos un 4 en el registro $v0
	la $a0, resultado		#Se carga el contenido de la etiqueta resultado.
	syscall				#Se ejecuta la accion.
	addiu $v0,$0, 2			#Esto sirve para mostrar el resultado de la division.
	syscall				#Se ejecuta la accion.
	s.s $f12, 4($sp)		#Reserva para $f12.
	sw $zero, 0($sp)		#Reserva para $0.
	addi $sp, $sp, 4 		#pop 4 items off stack. 
	j Loop1				#Salto al Loop1.

restric:				#Esta funcion evita que la calculadora divida entre cero.
	addiu $v0, $zero, 4		#Se le indica al OS que se trata de un string.
	la $a0, ind			#Se carga el contenido de la etiqueta ind.
	syscall				#Se ejecuta la accion.
	j Loop1				#Salto al Loop1.

raiz:					#Esta es la misma funcion que se realizo en clase.
	l.s $f0, 0($sp)			#Aqui se toma a $f0 como el ultimo elemento de la pila.
	l.s $f5,zero			#Aqui $f5=0.
	c.lt.s $f0, $f5			#Se compara el ultimo elemento con 0, si este es menor se procede a usar un branch.
	bc1t raiz_comp			#Si el ultimo resultado en la pila es negativo entonces se salta a la etiqueta raiz_comp.
	addi $t0, $0, 2			#$t2=0.
	mtc1 $t0, $f1 			#Aqui se transfiere un valor de un registro entero a uno flotante.
	cvt.s.w $f1, $f1  		#f1=2 Convierte un valor entero en un registro punto flotante en un valor en punto flotante.
	div.s $f2, $f0, $f1 		#$f2=x=N/2 valor inicial de la semilla.
	addi $t0, $0, 20 		#Cantidad de iteraciones.

iterRaiz:
	div.s $f3, $f0, $f2 		#$f3=N/x
	add.s $f3, $f2, $f3 		#$f3=x+N/x
	div.s $f2, $f3, $f1 		#$f2=(x+N/x)/2
	beq $t0, $0, retRaiz	
	addi $t0, $t0, -1		#Se van reduciendo las iteraciones.
	j iterRaiz			#Salto a iterRaiz.

retRaiz:	
	mov.s $f12, $f2			#Se mueve el contenido de $f2 a $f12.
	addiu $v0, $zero, 4		#cargamos un 4 en el registro $v0
	la $a0, resultado		#Se carga el contenido de la etiqueta resultado.
	syscall				#Se ejecuta la accion
	addiu $v0,$0, 2			#Esto sirve para mostrar el resultado de la raiz.
	syscall				#Se ejecuta la accion.
	s.s $f12, 0($sp)		#Reserva para $f12.
	j Loop1				#Salto a Loop1.
	
raiz_comp:				#La funcion que ejecuta esta etiqueta es mostrar un mensaje de advertencia.
	addiu $v0, $zero, 4		#cargamos un 4 en el registro $v0
	la $a0, comp			#Se carga el contenido de la etiqueta comp.
	syscall				#Se ejecuta la accion.
	j Loop1				#Salto a Loop1.

clear_stack:				#La funcion en esta etiqueta borra los registros que tiene la pila.
	addi $sp,$sp,28			#Se le suma 28 para que llegue a la direccion 0x7fffeffc por defecto que tiene $sp.
	beq $sp,0x7fffeffc,clean	#Si $sp es igual a su valor por default, entonces se pasa a la etiqueta clean.

clean:
	addiu $v0, $zero, 4		#Se le indica al OS que se trata de un string.
	la $a0, clear			#Se carga el contenido de la etiqueta clear.
	syscall				#Se ejecuta la accion.
	j Loop1				#Salto a Loop1.
	
show:					#La funcion almacenada en esta etiqueta muestra el ultimo elemento de la pila.
	l.s $f12, 0($sp)		#Reserva para $f12.
	addiu $v0, $zero, 4		#Se le indica al OS que se trata de un string.
	la $a0, ultimo			#Se carga el contenido de la etiqueta ultimo.
	syscall				#Se ejecuta la accion.
	addiu $v0,$0, 2			#Aqui se muestra el resultado, es decir, el ultimo elemento.
	syscall				#Se ejecuta la accion.
	j Loop1				#Salto al Loop1.
	
off:					#Aqui se apaga la calculadora.
	addiu $v0,$0, 10
	syscall

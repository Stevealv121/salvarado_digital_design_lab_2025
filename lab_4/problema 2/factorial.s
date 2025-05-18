			;		C�digo para calcular el factorial de un n�mero X en VisUAL
			;		Constantes:
			;		Ubicamos el valor de entrada en memoria en la direcci�n 0x100
			;		Ubicamos el resultado en memoria en la direcci�n 0x104
			
			;		Inicializaci�n
			MOV		R0, #0x100        ; Direcci�n para el valor de entrada X 
			MOV		R1, #5            ; Valor de X para factorial
			STR		R1, [R0]          ; Almacenar X en memoria
			
			;		Usar un valor inmediato v�lido para la direcci�n del resultado
			MOV		R2, #0x104        ; Direcci�n para almacenar el resultado
			
			;		Cargar X
			LDR		R4, [R0]          ; R4 = valor de X
			
			;		Caso especial: X = 0. El factorial de 0 es 1.
			CMP		R4, #0
			BNE		init_factorial    ; Si X no es 0, continuar con el c�lculo normal
			MOV		R5, #1            ; Si X = 0, factorial = 1
			STR		R5, [R2]          ; Guardar resultado en memoria
			B		halt                ; Saltar al final
			
init_factorial
			;		Inicializaci�n para X > 0
			MOV		R5, #1            ; R5 = resultado del factorial, comenzando en 1
			MOV		R6, R4            ; R6 = contador, comenzando en X
			
factorial_loop
			;		Multiplicaci�n: R5 = R5 * R6
			MOV		R7, #0            ; R7 = acumulador para suma (multiplicaci�n)
			MOV		R8, R5            ; Guardar valor de R5 en R8
			MOV		R9, R6            ; Contador para el bucle de multiplicaci�n
			
mult_loop
			CMP		R9, #0            ; Verificar si el contador de multiplicaci�n lleg� a 0
			BEQ		mult_done         ; Si es 0, terminar la multiplicaci�n
			ADD		R7, R7, R8        ; R7 += R8 (acumular la suma)
			SUB		R9, R9, #1        ; Decrementar contador
			B		mult_loop           ; Repetir el bucle de multiplicaci�n
			
mult_done
			MOV		R5, R7            ; R5 = resultado de la multiplicaci�n
			
			;		Decrementar contador y verificar si terminamos
			SUB		R6, R6, #1        ; Decrementar contador del factorial
			CMP		R6, #1            ; Verificar si llegamos a 1
			BGT		factorial_loop    ; Si R6 > 1, continuar el bucle
			
			;		Almacenar resultado
			STR		R5, [R2]          ; Guardar resultado en memoria
			
halt
			END
			;		Fin del programa

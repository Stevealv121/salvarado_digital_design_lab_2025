				
				LDR		R0, =array_data  ; R0 apunta al inicio del arreglo 'array'
				LDR		R1, =y_const     ; R1 carga la direcci�n de la constante 'y'
				LDR		R1, [R1]         ; R1 ahora contiene el valor de 'y' (ej: 5)
				MOV		R2, #0           ; R2 es el contador del bucle (i), inicializado a 0
				MOV		R3, #10          ; R3 es el l�mite del bucle (n�mero de elementos)
				
loop_start
				CMP		R2, R3           ; Compara i con 10 (i < 10?)
				BGE		loop_end         ; Si i >= 10, termina el bucle
				
				;		Cargar el elemento actual del arreglo: array[i]
				;		Cada entero ocupa 4 bytes (asumiendo enteros de 32 bits)
				;		R4 = array[i] usando R0 (base) + R2 (�ndice) * 4 (LSL #2 es shift left por 2 bits, o sea * 4)
				LDR		R4, [R0, R2, LSL #2]
				
				;		Comparar array[i] con y
				CMP		R4, R1           ; Compara array[i] (R4) con y (R1)
				BGE		if_greater_equal ; Si array[i] >= y, salta a la secci�n 'if'
				
else_less
				;		array[i] < y, entonces array[i] = array[i] + y
				ADD		R4, R4, R1       ; R4 = R4 + R1 (array[i] = array[i] + y)
				STR		R4, [R0, R2, LSL #2] ; Guarda el nuevo valor en array[i]
				B		end_if             ; Salta al final de la estructura if-else
				
if_greater_equal
				;		array[i] >= y, entonces array[i] = array[i] * y
				;		Como MUL no est� soportado, implementamos la multiplicaci�n.
				;		R4 = R4 * R1. Asumimos que R1 (y) es no negativo.
				;		R5 guardar� el valor original de array[i] (el multiplicando).
				;		R6 guardar� el multiplicador y (copia de R1).
				;		R7 acumular� el resultado.
				
				MOV		R5, R4      ; R5 = array[i] (multiplicando)
				MOV		R6, R1      ; R6 = y (multiplicador)
				MOV		R7, #0      ; R7 = 0 (resultado inicial)
				
				CMP		R6, #0      ; Si y == 0, el resultado es 0
				BEQ		mult_done   ; Salta si y es cero
				
mult_loop
				ADD		R7, R7, R5  ; resultado = resultado + array[i]
				SUBS		R6, R6, #1 ; Decrementa y, afecta flags
				BNE		mult_loop   ; Si y no es cero despu�s de decrementar, sigue sumando
mult_done
				MOV		R4, R7      ; Mueve el resultado (R7) a R4
				
				STR		R4, [R0, R2, LSL #2] ; Guarda el nuevo valor (resultado de la multiplicaci�n) en array[i]
				
end_if
				ADD		R2, R2, #1       ; Incrementa el contador i (R2 = i + 1)
				B		loop_start         ; Vuelve al inicio del bucle
				
loop_end
				;		El programa termina aqu�. END detendr� la emulaci�n seg�n tu lista.
				B		stop_execution     ; Bucle para detener, o directo a END si es manejado as�.
				
stop_execution
				END		; Directiva para finalizar la simulaci�n en VisUAL
				
				
array_data		DCD		1, 6, 3, 8, 5, 10, 2, 7, 4, 9 ; Valores iniciales del arreglo (10 enteros de 32 bits)
				
y_const			DCD		5                            ; Definicion constente 'y'


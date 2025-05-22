			;		C�digo para control de sprite con teclado en ARMv4
			;		Direcciones de memoria:
			;		0x1000: Valor de la tecla presionada (simulada en 0x300)
			;		0x2000: Contador de posici�n del sprite (simulada en 0x304)
			
			;		Constantes para las teclas
			;		Flecha de arriba: 0xE048
			;		Flecha de abajo:  0xE050
			
			;		Inicializaci�n
			MOV		R0, #0x300        ; Direcci�n base (para simulaci�n)
			
			;		Para cargar 0xE048 (57416 decimal)
			MOV		R1, #0xE0         ; Parte alta (224 decimal)
			LSL		R1, R1, #8        ; Desplazar a la izquierda 8 bits
			ADD		R1, R1, #0x48     ; A�adir parte baja (72 decimal)
			STR		R1, [R0]          ; Guardar en memoria como si fuera la direcci�n 0x1000
			
			ADD		R2, R0, #4        ; R2 = R0 + 4 (para simular posici�n inicial del contador)
			MOV		R3, #5            ; Valor inicial del contador (posici�n del sprite)
			STR		R3, [R2]          ; Guardarlo en memoria (simula la direcci�n 0x2000)
			
			;		Configurar constantes para comparaci�n (flecha arriba)
			MOV		R4, #0xE0         ; Parte alta de 0xE048
			LSL		R4, R4, #8        ; Desplazar a la izquierda 8 bits
			ADD		R4, R4, #0x48     ; A�adir parte baja
			
			;		Configurar constantes para comparaci�n (flecha abajo)
			MOV		R5, #0xE0         ; Parte alta de 0xE050
			LSL		R5, R5, #8        ; Desplazar a la izquierda 8 bits
			ADD		R5, R5, #0x50     ; A�adir parte baja
			
			;		Ciclo principal
main_loop
			;		Leer valor de la tecla (desde la direcci�n simulada)
			LDR		R6, [R0]              ; Cargar tecla presionada
			
			;		Leer contador actual
			LDR		R7, [R2]              ; Cargar posici�n actual del sprite
			
			;		Comparar si es flecha arriba
			CMP		R6, R4                ; Comparar con c�digo de flecha arriba
			BNE		check_down            ; Si no es arriba, verificar si es abajo
			
			;		Es flecha arriba, incrementar contador
			ADD		R7, R7, #1            ; Incrementar posici�n del sprite
			B		update_counter          ; Guardar nuevo valor
			
check_down
			;		Comparar si es flecha abajo
			CMP		R6, R5                ; Comparar con c�digo de flecha abajo
			BNE		continue              ; Si no es abajo, no hacer nada
			
			;		Es flecha abajo, decrementar contador
			SUB		R7, R7, #1            ; Decrementar posici�n del sprite
			
update_counter
			;		Guardar nuevo valor del contador
			STR		R7, [R2]              ; Actualizar posici�n del sprite
			
continue
			;		--- SIMULACI�N ---
			;		Esta secci�n es solo para simular diferentes entradas
			;		de teclado en m�ltiples iteraciones del bucle
			
			;		Modificamos la tecla para la siguiente iteraci�n (para simular)
			ADD		R8, R0, #20           ; R8 = direcci�n base + 20 (para almacenar �ndice de prueba)
			LDR		R9, [R8]              ; Cargar �ndice actual
			ADD		R9, R9, #1            ; Incrementar �ndice
			STR		R9, [R8]              ; Guardar �ndice actualizado
			
			;		Decidir qu� tecla simular a continuaci�n seg�n el �ndice
			AND		R9, R9, #7            ; �ndice mod 8 para ciclar entre casos de prueba
			
			;		Caso 0: Flecha arriba
			CMP		R9, #0
			BNE		next_case1
			MOV		R1, R4                ; Cargar c�digo de flecha arriba
			B		case_end
			
next_case1
			;		Caso 1 y 2: Flecha abajo
			CMP		R9, #1
			BNE		next_case2
			MOV		R1, R5                ; Cargar c�digo de flecha abajo
			B		case_end
			
next_case2
			CMP		R9, #2
			BNE		next_case3
			MOV		R1, R5                ; Cargar c�digo de flecha abajo
			B		case_end
			
next_case3
			;		Caso 3: Flecha arriba
			CMP		R9, #3
			BNE		next_case4
			MOV		R1, R4                ; Cargar c�digo de flecha arriba
			B		case_end
			
next_case4
			;		Caso 4: Tecla inv�lida
			CMP		R9, #4
			BNE		next_case5
			MOV		R1, #0x34             ; Parte baja de una tecla inv�lida
			ADD		R1, R1, #0x1200       ; A�adir parte alta (valor inmediato v�lido)
			B		case_end
			
next_case5
			;		Caso 5: Flecha arriba
			CMP		R9, #5
			BNE		next_case6
			MOV		R1, R4                ; Cargar c�digo de flecha arriba
			B		case_end
			
next_case6
			;		Caso 6: Otra tecla inv�lida
			CMP		R9, #6
			BNE		next_case7
			MOV		R1, #0x78             ; Parte baja de otra tecla inv�lida
			ADD		R1, R1, #0x5600       ; A�adir parte alta (valor inmediato v�lido)
			B		case_end
			
next_case7
			;		Caso 7: Flecha abajo
			MOV		R1, R5                ; Cargar c�digo de flecha abajo
			
case_end
			STR		R1, [R0]              ; Almacenar nueva tecla simulada para la pr�xima iteraci�n
			
			;		Verificar si hemos completado 5 iteraciones
			CMP		R9, #5
			BLE		main_loop             ; Si no hemos hecho 5 iteraciones, continuar el bucle
			
			;		Fin del programa

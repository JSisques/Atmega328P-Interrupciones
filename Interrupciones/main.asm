.EQU clock = 16000000															;Frecuencia del reloj
.EQU baud = 9600																;Numero de bits por segundo
.EQU UBRRvalue = clock/(baud * 16) - 1											;Calculamos el valor de UBRR

.ORG 0x0000																		;Posicion de memoria inicial
	JMP main_routine															
		
.ORG 0X0032																		;Posicion de memoria donde se encuentran las interrupciones serial
	JMP USART0_reception_completed												;Saltamos a la funcion cuando se genere la interrupcion
	JMP USART0_transmit_buffer_empty											;Saltamos a la funcion cuando se genere la interrupcion
	JMP USART0_byte_transmitted													;Saltamos a la funcion cuando se genere la interrupcion

.ORG 0x0072
main:
	LDI R16, HIGH(RAMEND)														;Inicializamos la pila OBLIGATORIO si usamos interrupciones
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16

	RCALL init_USART0															;Llamamos a la funcion para configurar USART
	SEI																			;Activamos el uso de interrupciones

	loop:
		NOP																		;No hacemos nada
		RJMP loop																;Saltamos a la etiqueta loop


init_USART0:																	;Funcion para cargar el valor de UBRR
	LDI R16, LOW(UBRRvalue)														;Cogemos el valor bajo de la variable UBRRvalue
	STS UBRR0L, R16																;Cargamos el valor del byte bajo
	LDI R16, HIGH(UBRRvalue)													;Cogemos el valor alto de la variable UBRRvalue
	STS UBRR0H, R16																;Cargamos el valor del byte alto

	//Activamos la recepcion y transmision de datos
	LDI R16, (1 << RXEN0)|(1 << TXEN0)|(1 << UDRIE0)|(1 << TXCIE0)|(1 << RXCIE0)
	STS UCSR0B, R16																;Asignamos al registro UCSR0B los bits establecidos
	LDI R16, (0 << UMSEL00)|(1 << UCSZ01)|(1 << UCSZ00)|(0 << USBS0)|(0 << UPM01)|(0 << UPM00)
	STS UCSR0C, R16																;Asignamos al registro UCSR0C los bits establecidos				
	
	RET

//Función de atención a la interrupcion
USART0_reception_completed:
	PUSH R16
	IN R16, SREG																;Hacemos una copia del registro SREG OBLIGATORIO si se usan interrupciones
	PUSH R16
	
	LDS R16, UDR0																;Cogemos el byte recivido y hacemos algo con el

	//Procesamos el dato

	//Finalizamos la interrupcion
	POP R16
	OUT SREG, R16																;Restablecemos el registro SREG
	POP R16
	RETI																		;RETI equivale a RET pero utilizado en interrupciones
											
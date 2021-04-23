/**************************************************************************
	Autor: Javier Plaza Sisqués
***************************************************************************/

.EQU clock = 16000000															;Frecuencia del reloj
.EQU baud = 9600																;Numero de bits por segundo
.EQU UBRRvalue = clock/(baud * 16) - 1											;Calculamos el valor de UBRR

.ORG 0x0000																		;Posicion de memoria inicial
	JMP main															
		
.ORG 0X0032																		;Posicion de memoria donde se encuentran las interrupciones serial
	JMP USART0_reception_completed												;Saltamos a la funcion cuando se genere la interrupcion
//	JMP USART0_transmit_buffer_empty											;Saltamos a la funcion cuando se genere la interrupcion
//	JMP USART0_byte_transmitted													;Saltamos a la funcion cuando se genere la interrupcion

.ORG 0x0072

main:
	SER R16
	OUT DDRB, R16

	LDI R16, HIGH(RAMEND)														;Inicializamos la pila OBLIGATORIO si usamos interrupciones
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16

	RCALL init_USART0															;Llamamos a la funcion para configurar USART
	SEI																			;Activamos el uso de interrupciones

	loop:
		//Mantenemos el micro ocupado encendiendo y apagando un LED

		SBI PORTB, 5															;Encendemos solo el LED de la posicion 5
		CALL delay																;Llamamos a la función delay
		CBI PORTB, 5															;Apagamos el LED que hemos encendido antes
		CALL delay																;Llamamos a la función delay
		
		RJMP loop																;Saltamos a la etiqueta loop

/**************************************************************************

	Fin del programa principal

***************************************************************************/

/**************************************************************************

	Función de inicialización serial

***************************************************************************/

init_USART0:
	PUSH R16
	LDI R16, LOW(UBRRvalue)														;Cogemos el valor bajo de la variable UBRRvalue
	STS UBRR0L, R16																;Cargamos el valor del byte bajo
	LDI R16, HIGH(UBRRvalue)													;Cogemos el valor alto de la variable UBRRvalue
	STS UBRR0H, R16																;Cargamos el valor del byte alto

	//Activamos la recepcion y transmision de datos
	LDI R16, (1 << RXEN0)|(0 << TXEN0)|(0 << UDRIE0)|(0 << TXCIE0)|(1 << RXCIE0)
	STS UCSR0B, R16																;Asignamos al registro UCSR0B los bits establecidos
	LDI R16, (0 << UMSEL00)|(1 << UCSZ01)|(1 << UCSZ00)|(0 << USBS0)|(0 << UPM01)|(0 << UPM00)
	STS UCSR0C, R16																;Asignamos al registro UCSR0C los bits establecidos				
	POP R16

	RET

/**************************************************************************

	Función de atención a la interrupcion

***************************************************************************/
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

/**************************************************************************

	Función Delay 250ms

***************************************************************************/
delay:

	PUSH R18
	PUSH R19
	PUSH R20

; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 4 000 000 cycles
; 250ms at 16 MHz

    ldi  r18, 21
    ldi  r19, 75
    ldi  r20, 191
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    nop



	POP R20
	POP R19
	POP R18
	RET
									
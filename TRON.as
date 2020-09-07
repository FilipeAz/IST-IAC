; 82433 Ana Nogueira
; 82468 Filipe Azevedo
; 82517 Martim Zanatti
; -------------------------------------------------------------;
;							
;			T R O N 					
;							 
; -------------------------------------------------------------;


				ORIG	8000h

; ----------------------- ZONA DE STRINGS ---------------------

Linha1			STR 	'Bem-vindo ao TRON'
Linha2			STR     'Prima o interruptor I1 para comecar'
Linha3          	STR    	'Fim de jogo'
Linha4          	STR     'Prima o interruptor I1 para recomecar'
String1LCD		STR 	'TEMPO MAX: 0000s'
String2LCD		STR 	'J1: 00    J2: 00'


TempMax1		STR 	'0'
TempMax2		STR 	'0'
TempMax3		STR 	'0'
TempMax4		STR 	'0'




; ---------------------- ZONA DE CONSTANTES --------------------


	; --- CONSTANTES JANELA TEXTO ---


IO_CURSOR		EQU		FFFCh
IO_WRITE		EQU		FFFEh
StartCursor		EQU		FFFFh 



	; --- CONSTANTES STRINGS ---


PosicaoInicial1 	EQU	0C1Fh	; Local de inicio da escrita da Linha1.
PosicaoInicial2		EQU	0D16h	; Local de inicio da escrita da Linha2.
PosicaoInicial3 	EQU     0B22h	; Local de inicio da escrita da Linha3.
PosicaoInicial4 	EQU     0C16h	; Local de inicio da escrita da Linha4.

Len1			EQU	17	; Comprimento de Linha1.
Len2			EQU	35	; Comprimento de Linha2.
Len3            	EQU     11 	; Comprimento de Linha3.
Len4            	EQU     37	; Comprimento de Linha4.



	; --- CONSTANTES GERAIS ---


Mais            	EQU    	002Bh	; Caracteres ASCII que irao
Hifen           	EQU    	002Dh	; ser escritos na janela de 
Barra           	EQU    	007Ch	; texto.

Ex	            	EQU    	0058h
Cardinal        	EQU    	0023h

Space			EQU     0020h

Xinicial		EQU     3 	; Xinicial e Cinicial indicam
Cinicial		EQU     1 	; em que direccao a particula
					; comeca a andar.



	; --- CONSTANTES LEDS ---


LED_WRITE		EQU	FFF8h	; Porto de activacao dos LEDS.

NIVEL_1			EQU	000Fh	; LEDs a activar em cada nivel.
NIVEL_2			EQU	00FFh
NIVEL_3			EQU	0FFFh
NIVEL_4			EQU	FFFFH



	; --- CONSTANTES INTERRUPCOES ---


INT_MASK		EQU	1000101010000011b  ; Mascara de Interrupcoes.
INT_PORT		EQU    	FFFAh	; Endereco onde se coloca a INT_MASK.



	; --- CONSTANTES LCD ---


LCD_WRITE		EQU	FFF5h	; Porto de escrita no LCD.
LCD_CURSOR		EQU	FFF4h	; Cursor de escrita para o LCD.

COUNTERLCD		EQU	0010h 	; Num de caracteres a imprimir no LCD

POSSTR1			EQU	8000h	; Hexadecimal correspondente ao local 
POSSTR2			EQU 	8010h	; onde posicionar os caracteres no LCD.
POSSTR3			EQU 	8014h
POSSTR4			EQU 	8015h
POSSTR5			EQU   	801Eh
POSSTR6			EQU 	801Fh



; ----------------------- ZONA DE VARIAVEIS ---------------------


TimerFlag		WORD    0000h
LoopJogo        	WORD    0000h		
					; decorrer de um jogo e o valor 0 

; Variaveis utilizadas para contar o numero de vitorias de cada jogador
; Os seus valores correspondem ao caracter ASCII do numero.

; Sao iniciadas com o caracter '1' uma vez que apenas sao chamadas
; quando ocorre o incremento do numero de vitorias de um dos jogadores.


VITJ1D1			WORD 	0031h	; Digito 1 das vitorias do J1.
VITJ1D2			WORD 	0031h	; Digito 2 das vitorias do J1.

VITJ2D1			WORD 	0031h	; Digito 1 das vitorias do J2.
VITJ2D2			WORD 	0031h	; Digito 2 das vitorias do J2.




; ------------------------- ZONA DE TABELAS ----------------------

; Tabela que guarda as posicoes da janela
; ocupadas pelos rastos das particulas

Tabela         		TAB     960

; Tabelas que guardam as posicoes na janela de texto dos contornos do
; espaco de jogo. Correspondem aos contornos superior, inferior,
; direito e esquerdo, respectivamente.

TabelaContS		TAB 	50							
TabelaContI		TAB 	50
TabelaContD		TAB 	21	
TabelaContE		TAB 	21



; --------------------- TABELA DE INTERRUPCOES --------------------

; Colocacao das rotinas de servico a interrupcao na tabela de vectores
; de interrupcao.

			ORIG    FE00h
INT0			WORD    Xesquerda


			ORIG    FE01h
INT1        		WORD	Ecra


			ORIG    FE07h
INT7			WORD    Cesquerda


			ORIG    FE09h
INT9			WORD    Cdireita


			ORIG	FE0Bh
INT11			WORD    Xdireita
				
				
			ORIG 	FE0Fh
INT15 			WORD 	Timer
			




; -----------------------------------------------------------------
; ----------------------- INICIO DO PROGRAMA ----------------------
; -----------------------------------------------------------------


			ORIG	0000h
			JMP     Inicio3



; ----------------- ROTINAS DE SERVICO A INTERRUPCAO ---------------


Ecra:			PUSH    R1
			MOV	R1, 1						
			MOV     M[LoopJogo], R1
			POP     R1
			RTI


Xdireita:		INC     R5	
			RTI
				

Xesquerda:		DEC	R5
			RTI
				

Cesquerda:		DEC     R6
			RTI
				

Cdireita:		INC	R6
			RTI
				
				
Timer:			PUSH    R1
			MOV     R1, 1
			MOV     M[TimerFlag], R1
			MOV     R1, 1
			MOV     M[FFF6h], R1
			MOV     R1, 1
			MOV     M[FFF7h], R1
			POP     R1
			RTI


; ------------------------------------------------------------------





; ----------------------- ROTINAS DO PROGRAMA ----------------------


; --------------------------------------------------------------------------
; AndaC:	Rotina que direcciona a particula do jogador 2,
;		de acordo com as interrupcoes I7 e I9.
; --------------------------------------------------------------------------

AndaC:			CMP    R6, R0
			BR.NZ  Max1
			ADD    R6, 4
Max1:			CMP    R6, 5
			BR.NZ  Cima1
			SUB    R6, 4
Cima1:			CMP    R6, 1
			BR.NZ  Direita1
			SUB    R2, 0100h
			BR     AumentaC
Direita1:		CMP    R6, 2
			BR.NZ  Baixo1
			INC    R2
			BR     AumentaC
Baixo1:			CMP    R6, 3
			BR.NZ  Esquerda1
			ADD    R2, 0100h
			BR     AumentaC
Esquerda1:		DEC    R2
AumentaC:		RET



; --------------------------------------------------------------------------
; AndaX:	Rotina que direcciona a particula do jogador 1,
;		de acordo com as interrupcoes I0 e IB.
; --------------------------------------------------------------------------

AndaX:			CMP    R5, R0
			BR.NZ  Max
			ADD    R5, 4
Max:			CMP    R5, 5
			BR.NZ  Cima
			SUB    R5, 4
Cima:			CMP    R5, 1
			BR.NZ  Direita
			SUB    R1, 0100h
			BR     AumentaX
Direita:		CMP    R5, 2
			BR.NZ  Baixo
			INC    R1
			BR     AumentaX
Baixo:			CMP    R5, 3
			BR.NZ  Esquerda
			ADD    R1, 0100h
			BR     AumentaX
Esquerda:		DEC    R1
AumentaX:		RET



; --------------------------------------------------------------------------
; Apaga:	Limpa o espaco de jogo quando se inicia um jogo
;					novo.
; --------------------------------------------------------------------------

Apaga:			PUSH   R1
			PUSH   R2
			PUSH   R3
			MOV    R1, 020Fh
			MOV    R2, Space
Posiciona:		MOV    M[IO_CURSOR], R1
			MOV    M[IO_WRITE], R2
			INC    R1
			MVBL   R3, R1
			CMP    R3, 0040h
			BR.Z   Next
			BR     Posiciona
Next:			SUB    R1, 0031h
			ADD    R1, 0100h
			CMP    R1, 160Fh
			BR.Z   Apaga2
			BR     Posiciona
Apaga2:			POP    R3
			POP    R2
			POP    R1
			RET



; --------------------------------------------------------------------------
; ApagaTab:	Rotina que limpa a tabela guardada em memoria,
;	        colocando todas as suas posicoes com o valor
;		0000h.
; --------------------------------------------------------------------------

ApagaTab:    	PUSH   R4
		PUSH   R5
		MOV    R5, Tabela 
		ADD    R5, 960
		MOV    R4, Tabela
PercorreCiclo1:	MOV    M[R4], R0
		INC    R4
		CMP    R4, R5
		JMP.NZ PercorreCiclo1
		POP    R5
		POP    R4
		RET



; --------------------------------------------------------------------------
; Bot:		Rotina que posiciona o limite inferior do jogo na
;		janela de texto.
; --------------------------------------------------------------------------

Bot:            PUSH   R1
		PUSH   R2
		PUSH   R3
                MOV    R1, 160Eh			
                MOV    M[IO_CURSOR], R1	
		MOV    R2, Mais
		MOV    M[IO_WRITE], R2	
Ciclo6:		INC    R1
                MOV    M[IO_CURSOR], R1	
		MOV    R3, Hifen
		MOV    M[IO_WRITE], R3	
		CMP    R1, 163Fh
		BR.Z   Fim4				
		BR     Ciclo6
Fim4:		MOV    M[IO_WRITE], R2	
                POP    R3
		POP    R2
		POP    R1
		RET 



; --------------------------------------------------------------------------
; ComecaLCD:	Rotina que chama as rotinas que efectuam a escrita
;		das strings iniciais no LCD. E chamada apenas no
;		inicio do jogo.
; --------------------------------------------------------------------------

ComecaLCD:	CALL	String1
		CALL	String2
		RET



; --------------------------------------------------------------------------
; ContornoFimD:	Verifica se existiu colisao contra o contorno direito
;	        da zona de jogo.
; --------------------------------------------------------------------------

ContornoFimD:   PUSH   R4
		PUSH   R5
		MOV    R5, TabelaContD 
		ADD    R5, 0015h
		MOV    R4, Tabela
ContFimDCiclo:	CMP    R1, M[R4]
		JMP.Z  FimJ1
		CMP    R2, M[R4]
		JMP.Z  FimJ2  				
		INC    R4
		CMP    R4, R5
		JMP.NZ  ContFimDCiclo
		POP    R5
		POP    R4
		RET



; --------------------------------------------------------------------------
; ContornoFimE:	Verifica se existiu colisao contra o contorno esquerdo
;	        da zona de jogo.
; --------------------------------------------------------------------------

ContornoFimE:   PUSH   R4
		PUSH   R5
		MOV    R5, TabelaContE
		ADD    R5, 0015h
		MOV    R4, Tabela
ContFimECiclo:	CMP    R1, M[R4]
		JMP.Z  FimJ1
		CMP    R2, M[R4]
		JMP.Z  FimJ2  				
		INC    R4
		CMP    R4, R5
		JMP.NZ  ContFimECiclo
		POP    R5
		POP    R4
		RET



; --------------------------------------------------------------------------
; ContornoFimI:   Verifica se existiu colisao contra o contorno inferior
;		  da zona de jogo.
; --------------------------------------------------------------------------

ContornoFimI:   PUSH   R4
		PUSH   R5
		MOV    R5, TabelaContI 
		ADD    R5, 50
		MOV    R4, Tabela
ContFimICiclo:	CMP    R1, M[R4]
		JMP.Z  FimJ1
		CMP    R2, M[R4]
		JMP.Z  FimJ2  				
		INC    R4
		CMP    R4, R5
		JMP.NZ  ContFimICiclo
		POP    R5
		POP    R4
		RET



; --------------------------------------------------------------------------
; ContornoFimS:	Verifica se existiu colisao contra o contorno superior
;		da zona de jogo.
; --------------------------------------------------------------------------

ContornoFimS:   PUSH   R4
		PUSH   R5
		MOV    R5, TabelaContS 
		ADD    R5, 50
		MOV    R4, Tabela
ContFimSCiclo:	CMP    R1, M[R4]
		JMP.Z  FimJ1
		CMP    R2, M[R4]
		JMP.Z  FimJ2  				
		INC    R4
		CMP    R4, R5
		JMP.NZ  ContFimSCiclo
		POP    R5
		POP    R4
		RET



; --------------------------------------------------------------------------
; Delay:	Causa um atraso ate receber as interrupcoes causadas
;		pelo temporizador.
; --------------------------------------------------------------------------

Delay:		MOV     M[TimerFlag], R0                
Delay_L1:       CMP     M[TimerFlag], R0
		BR.Z    Delay_L1
		RET	



; --------------------------------------------------------------------------
; Displays:	Activa os displays de sete segmentos, mostrando a
;		contagem do tempo.
; --------------------------------------------------------------------------

Displays:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R7
		PUSH    R4
		MOV     R1, 10d
		MOV     R2, 10d
		MOV     R3, 10d
		MOV     R4, 10d
		DIV     R7, R4
		CMP     R4, R0
		BR.NZ	Retorna
		DIV     R7, R3
		DIV     R7, R2
		DIV     R7, R1
		MOV     M[FFF3h], R7
		MOV     M[FFF2h], R1
		MOV     M[FFF1h], R2
		MOV     M[FFF0h], R3
Retorna:	POP     R4
		POP     R7
		POP     R3
		POP     R2
		POP     R1
		RET



; --------------------------------------------------------------------------
; EscreveLED:	Activa os leds, quatro a quatro, consoante o nivel
;		de jogo.
; --------------------------------------------------------------------------

EscreveLED:	PUSH   R7
		MOV    R7, NIVEL_1
		MOV    M[LED_WRITE], R7	
		POP    R7
		RET
				
EscreveLED1:	PUSH   R7
		MOV    R7, NIVEL_2
		MOV    M[LED_WRITE], R7
		POP    R7
		RET

EscreveLED2:	PUSH   R7
		MOV    R7, NIVEL_3
		MOV    M[LED_WRITE], R7
		POP    R7
		RET
				
EscreveLED3:	PUSH   R7
		MOV    R7, NIVEL_4
		MOV    M[LED_WRITE], R7
		POP    R7
		RET



; --------------------------------------------------------------------------
; EscreveStr:	Rotina que e chamada para efectuar a escrita das strings
;		iniciais do jogo.
; --------------------------------------------------------------------------

EscreveStr:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		MOV	R1, Linha1			
		MOV     R2, PosicaoInicial1	
		MOV	R3, StartCursor	
		MOV	R4, R0			
		MOV	M[IO_CURSOR], R3	
CicloES1:	MOV	R5, M[R1]	
		MOV	M[IO_CURSOR], R2	
		MOV	M[IO_WRITE], R5		
		INC     R4
		CMP 	R4, Len1				
		BR.Z	EscreveStr2			
		INC 	R1
		INC 	R2			
		BR	CicloES1
EscreveStr2:	MOV	R1, Linha2		
		MOV     R2, PosicaoInicial2	
		MOV	R4, R0			
CicloES2:	MOV	R5, M[R1]			
		MOV	M[IO_CURSOR], R2
		MOV	M[IO_WRITE], R5	
		INC     R4
		CMP 	R4, Len2	
		BR.Z	Repor
		INC 	R1
		INC 	R2				
		BR	CicloES2	
Repor:		ENI
		POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1	
		RET



; --------------------------------------------------------------------------
; FimdeJogo:	Rotina que e chamada para efectuar a escrita das strings
;		finais do jogo.
; --------------------------------------------------------------------------

FimdeJogo: 	PUSH    R1
		PUSH 	R2
		PUSH  	R3
		PUSH    R4
		PUSH    R5
		PUSH    R7
		PUSH    R6
     		MOV     R1, Linha3
		MOV     R2, IO_WRITE
		MOV     R3, IO_CURSOR
		MOV     R4, PosicaoInicial3
		MOV     R5, StartCursor
		MOV     R7, R0
FimdeJogo1:	MOV     R6, M[R1]
		MOV     M[R3], R4
		MOV     M[R2], R6
		INC     R7
		CMP    	R7, Len3
		BR.Z    FimdeJogo2
		INC     R1
		INC     R4
		BR	FimdeJogo1
FimdeJogo2:	MOV	R1, Linha4		
		MOV     R4, PosicaoInicial4 
		MOV	R7, R0	
Fimdejogo3:	MOV	R6, M[R1]
		MOV	M[R3], R4
		MOV	M[R2], R6
		INC     R7
		CMP 	R7, Len4
		BR.Z	Repor1
		INC 	R1
		INC 	R4
		BR	Fimdejogo3		
Repor1:		POP     R6
		POP	R7
		POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET



; --------------------------------------------------------------------------
; FimJ1: 	Rotina que e chamada quando o jogador 1 colide com uma
;	 	particula.
; --------------------------------------------------------------------------

FimJ1:		MOV     M[LoopJogo], R0
		CALL	LCDJ2
		CALL	TempMax
		CALL    FimdeJogo
		JMP	Recomeca



; --------------------------------------------------------------------------
; FimJ2: 	 Rotina que e chamada quando o jogador 2 colide com uma
;		 particula.
; --------------------------------------------------------------------------

FimJ2:		MOV     M[LoopJogo], R0
		CALL	LCDJ1
		CALL	TempMax
		CALL    FimdeJogo
		JMP	Recomeca



; --------------------------------------------------------------------------
; GuardaPos:	 Rotina que guarda em memoria a posicao na janela de texto onde 
;		 foi escrito um caracter.
;		 O registo R1 corresponde ao local da particula do jogador 1.
;		O registo R2 corresponde ao local da particula do jogador 2.
; --------------------------------------------------------------------------

GuardaPos:	PUSH   R4
		MOV    R4, Tabela
GuaPosCiclo:	CMP    M[R4], R0
		BR.Z   EscreveMem
		INC    R4
		BR     GuaPosCiclo
EscreveMem:	MOV   M[R4], R1
		INC    R4
		MOV	   M[R4], R2
		POP	   R4
		RET



; --------------------------------------------------------------------------
; JogoPausado:	Rotina que  pausa o jogo
;					
; --------------------------------------------------------------------------

JogoPausado:	PUSH   R1
		PUSH   R2
		PUSH   R3
		MOV    R2, R5
		MOV    R3, R6
		MOV    R1, 0000000010000000b
Pausa:		CMP    M[FFF9h], R1
		BR.Z   Pausa
		MOV    R5, R2
		MOV    R6, R3
		POP    R3
		POP    R2
		POP    R1
		RET



; -------------------------------------------------------------------------
; LimEsquerda:	Rotina que posiciona o limite esquerdo do jogo na
;		janela de texto.
; --------------------------------------------------------------------------
				
LimEsquerda:	PUSH   R1
		PUSH   R2
		MOV    R1, 020Eh		
Ciclo4:		MOV    M[IO_CURSOR], R1
		MOV    R2, Barra
		MOV    M[IO_WRITE], R2
		ADD    R1, 0100h
		CMP    R1, 160Eh
		BR.Z   Fim2
		BR     Ciclo4
Fim2:           POP    R2
		POP    R1
		RET



; --------------------------------------------------------------------------
; LimDireita:	Rotina que posiciona o limite direito do jogo na
;		janela de texto.
; --------------------------------------------------------------------------

LimDireita:     PUSH   R1
		PUSH   R2
		MOV    R1, 0240h
Ciclo5:		MOV    M[IO_CURSOR], R1
		MOV    R2, Barra
		MOV    M[IO_WRITE], R2
		ADD    R1, 0100h
		CMP    R1, 1640h
		BR.Z   Fim3
		BR     Ciclo5
Fim3:           POP    R2
		POP    R1
		RET



; --------------------------------------------------------------------------
; LCDJ1: 	 Rotina que incrementa o numero de vitorias do jogador 1 no
;		 LCD.
; --------------------------------------------------------------------------

LCDJ1:		PUSH   R1						
                PUSH   R2
                PUSH   R3
                PUSH   R4
                PUSH   R5
                PUSH   R6
                MOV    R1, M[VITJ1D1]
                CMP    R1, 003Ah
                BR.Z   SegundoDigJ1
                MOV    R2, POSSTR4
                MOV    M[LCD_CURSOR], R2
                MOV    M[LCD_WRITE], R1
                INC    M[VITJ1D1]
                POP    R6
                POP    R5
                POP    R4
                POP    R3
                POP    R2
                POP    R1
                RET
SegundoDigJ1:   MOV    R5, 0030h
		MOV    R6, 0031h
		MOV    M[VITJ1D1], R5
		MOV    R2, POSSTR4
		MOV    M[LCD_CURSOR], R2
		MOV    M[LCD_WRITE], R5
		MOV    R3, M[VITJ1D2]
		MOV    R4, POSSTR3
		MOV    M[LCD_CURSOR], R4
		MOV    M[LCD_WRITE], R3
		INC    M[VITJ1D2]
		MOV    M[VITJ1D1], R6
		POP    R6
		POP    R5
		POP    R4
		POP    R3
		POP    R2
		POP    R1
		RET



; --------------------------------------------------------------------------
; LCDJ2: 	 Rotina que incrementa o numero de vitorias do jogador 2 no
;		LCD.
; --------------------------------------------------------------------------

LCDJ2:		PUSH   R1						
                PUSH   R2
                PUSH   R3
                PUSH   R4
                PUSH   R5
                PUSH   R6
                MOV    R1, M[VITJ2D1]
                CMP    R1, 003Ah
                BR.Z   SegundoDigJ2
                MOV    R2, POSSTR6
                MOV    M[LCD_CURSOR], R2
                MOV    M[LCD_WRITE], R1
                INC    M[VITJ2D1]
                POP    R6
                POP    R5
                POP    R4
                POP    R3
                POP    R2
                POP    R1
                RET
SegundoDigJ2:   MOV    R5, 0030h
		MOV    R6, 0031h
		MOV    M[VITJ2D1], R5
		MOV    R2, POSSTR6
		MOV    M[LCD_CURSOR], R2
		MOV    M[LCD_WRITE], R5
		MOV    R3, M[VITJ2D2]
		MOV    R4, POSSTR5
		MOV    M[LCD_CURSOR], R4
		MOV    M[LCD_WRITE], R3
		INC    M[VITJ2D2]
		MOV    M[VITJ2D1], R6
		POP    R6
		POP    R5
		POP    R4
		POP    R3
		POP    R2
		POP    R1
		RET



; --------------------------------------------------------------------------
; MemContEsq: 	 Escreve numa tabela em memoria as posicoes na janela
;	         de texto onde esta escrito o limite esquerdo da janela
;		 de jogo.
; --------------------------------------------------------------------------

MemContEsq:	PUSH	R1
		PUSH	R2
		MOV	R1, 010Eh
		MOV	R2, TabelaContE
MemContECiclo:	MOV	M[R2], R1
		ADD	R1, 0100h
		INC     R2
		CMP     R1, 170Eh
		BR.NZ	MemContECiclo
		POP	R2
		POP	R1
		RET



; --------------------------------------------------------------------------
; MemContDir: 	 Escreve numa tabela em memoria as posicoes na janela
;		 de texto onde esta escrito o limite direito da janela
;		 de jogo.
; --------------------------------------------------------------------------

MemContDir:	PUSH	R1
		PUSH	R2
		MOV	R1, 0140h
		MOV	R2, TabelaContD
MemContDCiclo:	MOV	M[R2], R1
		ADD	R1, 0100h
		INC     R2
		CMP     R1, 1640h
		BR.NZ	MemContDCiclo
		POP	R2
		POP	R1
		RET



; --------------------------------------------------------------------------
; MemContInf: 	 Escreve numa tabela em memoria as posicoes na janela
;		de texto onde esta escrito o limite inferior da janela
;		de jogo.
; --------------------------------------------------------------------------

MemContInf:	PUSH	R1
		PUSH	R2
		MOV	R1, 160Eh
		MOV	R2, TabelaContI
MemContICiclo:	MOV	M[R2], R1
		INC 	R1
		INC     R2
		CMP     R1, 163Fh
		BR.NZ	MemContICiclo
		POP	R2
		POP	R1
		RET



; --------------------------------------------------------------------------
; MemContSup: 	 Escreve numa tabela em memoria as posicoes na janela
;		de texto onde esta escrito o limite superior da janela
;		de jogo.
; --------------------------------------------------------------------------

MemContSup:	PUSH	R1
		PUSH	R2
		MOV	R1, 010Eh
		MOV	R2, TabelaContS
MemContSCiclo:	MOV	M[R2], R1
		INC 	R1
		INC     R2
		CMP     R1, 0140h
		BR.NZ	MemContSCiclo
		POP	R2
		POP	R1
		RET



; --------------------------------------------------------------------------
; Moldura: 	Rotina que coloca os contornos da janela de jogo na
;		janela de texto.
; --------------------------------------------------------------------------

Moldura:	CALL   Top
		CALL   LimEsquerda
		CALL   LimDireita
		CALL   Bot
		RET



; --------------------------------------------------------------------------
; PercorreTab:		Rotina que verifica se houve colisao entre particulas
;					dos jogadores.
; --------------------------------------------------------------------------

PercorreTab:    PUSH   R4
		PUSH   R5
		MOV    R5, Tabela 
		ADD    R5, 960
		MOV    R4, Tabela
PercorreCiclo:	CMP    R1, M[R4]
		JMP.Z  FimJ1
		CMP    R2, M[R4]
		JMP.Z  FimJ2  				
		INC    R4
		CMP    R4, R5
		JMP.NZ  PercorreCiclo
		POP    R5
		POP    R4
		RET



; --------------------------------------------------------------------------
; PoeC:		Rotina que coloca o caracter #, correspondente ao jogador 2,
;			no porto de escrita da janela de texto.
; --------------------------------------------------------------------------
			
PoeC:		PUSH   R1						
                MOV    R1, Cardinal
                MOV    M[IO_WRITE], R1			
		POP    R1
		RET



; --------------------------------------------------------------------------
; PoeX:		Rotina que coloca o caracter X, correspondente ao jogador 1
;			no porto de escrita da janela de texto.
; --------------------------------------------------------------------------

PoeX:		PUSH   R1						
                MOV    R1, Ex
                MOV    M[IO_WRITE], R1			
		POP    R1
		RET



; --------------------------------------------------------------------------
; String1:	Rotina que efectua a escrita da primeira string na primeira
;			 		linha do LCD.
; --------------------------------------------------------------------------

String1:	MOV	R4, String1LCD
		MOV	R2, POSSTR1
		MOV	R3, COUNTERLCD
Str1Ciclo:	MOV	R1, M[R4]
		MOV	M[LCD_CURSOR], R2
		MOV	M[LCD_WRITE], R1
		INC 	R2
		INC 	R4
		DEC	R3
		BR.NZ	Str1Ciclo
		RET



; --------------------------------------------------------------------------
; String2:	 Rotina que efectua a escrita da segunda string na segunda
;			 	linha do LCD.
; --------------------------------------------------------------------------

String2:	MOV	R4, String2LCD
		MOV	R2, POSSTR2
		MOV	R3, COUNTERLCD
Str2Ciclo:	MOV	R1, M[R4]
		MOV	M[LCD_CURSOR], R2
		MOV	M[LCD_WRITE], R1
		INC 	R2
		INC 	R4
		DEC	R3
		BR.NZ	Str2Ciclo
		RET



; --------------------------------------------------------------------------
; TempMax: 	 Rotina que incrementa o tempo maximo no LCD.
; --------------------------------------------------------------------------

TempMax:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH    R5
		MOV     R1, ' '
		MOV     R2, ' '
		MOV     R3, ' '
		MOV     R4, ' '
		MOV     R1, M[FFF3h]
		MOV     R2, M[FFF2h]
		MOV     R3, M[FFF1h]
		MOV     R4, M[FFF0h]
		ADD  	 R1, '0'
		ADD  	 R2, '0'
		ADD 	 R3, '0'
		ADD  	 R4, '0'
		CMP     R1, M[TempMax1]
		BR.Z	NextCar
		CMP     R1, M[TempMax1]
		JMP.N	TempMin
		MOV     M[TempMax1], R1
		MOV     M[TempMax2], R2
		MOV     M[TempMax3], R3
		MOV     M[TempMax4], R4
		BR		TempMin
NextCar:	CMP     R2, M[TempMax2]
		BR.Z	NextCar1
		CMP     R2, M[TempMax2]
		BR.N	TempMin
		MOV     M[TempMax2], R2
		MOV     M[TempMax3], R3
		MOV     M[TempMax4], R4
		BR      TempMin
NextCar1:	CMP     R3, M[TempMax3]
		BR.Z	NextCar2
		CMP     R3, M[TempMax3]
		BR.N	TempMin
		MOV     M[TempMax3], R3
		MOV     M[TempMax4], R4
		BR      TempMin
NextCar2:	CMP     R4, M[TempMax4]
		BR.NP	TempMin
		MOV     M[TempMax4], R4
TempMin:	MOV     R1, 800Bh
		MOV     M[LCD_CURSOR], R1
		MOV     R1, M[TempMax1]
		MOV     M[LCD_WRITE], R1
		MOV     R2, 800Ch
		MOV     M[LCD_CURSOR], R2
		MOV     R2, M[TempMax2]
		MOV     M[LCD_WRITE], R2
		MOV     R3, 800Dh
		MOV     M[LCD_CURSOR], R3
		MOV     R3, M[TempMax3]
		MOV     M[LCD_WRITE], R3
		MOV     R4, 800Eh
		MOV     M[LCD_CURSOR], R4
		MOV     R4, M[TempMax4]
		MOV     M[LCD_WRITE], R4
		POP     R5
		POP     R4
		POP     R3
		POP     R2
		POP     R1
		RET



; --------------------------------------------------------------------------
; Top:		Rotina que posiciona o limite superior do jogo na
;		janela de texto.
; --------------------------------------------------------------------------

Top:            PUSH   R1
		PUSH   R2
		PUSH   R3
                MOV    R1, 010Eh			
                MOV    M[IO_CURSOR], R1			
		MOV    R2, Mais
		MOV    M[IO_WRITE], R2			
Ciclo3:		INC    R1					
                MOV    M[IO_CURSOR], R1		
		MOV    R3, Hifen			
		MOV    M[IO_WRITE], R3	
		CMP    R1, 013Fh			
		BR.Z   Fim1						
		BR     Ciclo3			
Fim1:		MOV    M[IO_WRITE], R2	
                POP    R3
		POP    R2
		POP    R1
		RET



; ------------------------------------------------------------------


				
Inicio3:	MOV    R1, FDFFh		; Inicializacao do SP
		MOV    SP, R1
		MOV    R1, INT_MASK
		MOV    M[INT_PORT], R1
                MOV    R1, 1
		MOV    M[FFF6h], R1
		MOV    R1, 1
		MOV    M[FFF7h], R1 
		CALL   EscreveStr
		CALL   ComecaLCD
Recomeca:	MOV    M[LoopJogo], R0 
waitjogo:	CMP    M[LoopJogo], R0
		BR.Z   waitjogo
		CALL   Apaga
		CALL   ApagaTab
		CALL   Moldura
		MOV    R5, Xinicial
		MOV    R6, Cinicial
		MOV    M[FFF8h], R0
		MOV    M[FFF0h], R0 
		MOV    M[FFF1h], R0
		MOV    M[FFF2h], R0
		MOV    M[FFF3h], R0
		CALL   MemContSup
		CALL   MemContInf
		CALL   MemContDir
		CALL   MemContEsq
		MOV    R7, 0d
		MOV    R1, 0C19h
		MOV    R2, 0C37h
		MOV    R4, R0
Ciclo7:		CALL   JogoPausado
		MOV    R3, R0
		ENI
N5:		CMP    R4, 600
		JMP.NN Nivel5
N4:		CMP    R4, 400
		JMP.NN  Nivel4
N3:		CMP    R4, 200
		BR.NN  Nivel3
N2:		CMP    R4, 100
		BR.NN  Nivel2
Nivel1:		CALL   Delay
		INC    R4
		INC    R7
		CALL   Displays
		INC    R3
		CMP    R3, 7
		BR.NZ  Nivel1
		JMP    escreve
Nivel2:		CALL   EscreveLED
		CALL   Delay
		INC    R4
		INC    R7
		CALL   Displays
		INC    R3
		CMP    R3, 5
		BR.NZ  Nivel2
		JMP    escreve
Nivel3:		CALL   EscreveLED1
		CALL   Delay
		INC    R4
		INC    R7
		CALL   Displays
		INC    R3
		CMP    R3, 3
		BR.NZ  Nivel3
		BR     escreve
Nivel4:         CALL   EscreveLED2
		CALL   Delay
		INC    R4
		INC    R7
		CALL   Displays
		INC    R3
		CMP    R3, 2
		BR.NZ  Nivel4
		BR     escreve
Nivel5:		CALL   EscreveLED3
		CALL   Delay
		INC    R7
		CALL   Displays				
escreve:	CALL   AndaX
		CALL   AndaC
		CALL   ContornoFimS
		CALL   ContornoFimI
		CALL   ContornoFimD
		CALL   ContornoFimE
		CALL   PercorreTab
		MOV    M[IO_CURSOR], R1
		CALL   PoeX
		MOV    M[IO_CURSOR], R2
		CALL   PoeC
		CALL   GuardaPos
		JMP    Ciclo7

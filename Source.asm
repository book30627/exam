INCLUDE Irvine32.inc

.data
	map WORD 1920 DUP (0) ;�a�Ϥj�p(24*80)
	row byte 1920 DUP (0) ;�D��row(24*80)
	col byte 1920 DUP (0) ;�D��col(24*80)
	snakelength WORD 2;�D�ثe����
	temporarylength WORD 2;�D�ثe�Ȯɪ���
	dir byte 'w'
	newdir    BYTE    'w'
	addTail   BYTE    0d
	Gameover   BYTE    0d 
	msg BYTE "�w��Ө�g���D�C��",0dh,0ah,
			 "���C���HAssembly Language��@����",0dh,0ah,
			 "���C���ާ@�D�`²��A�u�ݥH��L�W��",0dh,0ah,
			 "W�BS�BA�BD����A�Y�i�C���C",0dh,0ah,
			 "P�䬰�Ȱ��C��",0dh,0ah,
			 "�w���U�쪱���r��~!",0dh,0ah,
			 "�п�ܥH�U�ﶵ:",0dh,0ah,
			 "1.�}�l�C��",0dh,0ah,
			 "2.�վ�t��",0dh,0ah,
	         "3.���}�C��",0dh,0ah,0

	speed_msg BYTE "�п�J���ƭ�(�w�]100ms,���@��):",0
	delay_T DWORD 100 ;�]�w�C������100ms�A���M�D�|�]�ӧ�
	gameovermsg BYTE "gameover",0
.code
main PROC
	mov eax,13 + ( 11 * 16)  ;13:�r��L�v����B11:�I���L�C���
	call SetTextColor		 ;�]�w�r��B�I���C��
	call Clrscr				 ;�M���ù�
L1:
	mov edx,OFFSET msg ;�Nmsg�����e���edx��
	call WriteString   ;�N���e��X�ܿù��W
	
wait1:
	call ReadChar ;���ݫ����J

	CMP AL,'1'
	JE start		;����}�l�C��

	CMP AL,'2'		;�վ�t��
	JE speed

	CMP AL,'3'		;���}�C��
	JNE wait1		;�p�G�����O�H�W�ﶵ�A�h���Ƶ��ݿ�J

	EXIT

	speed:
	call Clrscr		;�M�ſù�
	mov edx,OFFSET speed_msg	;�Nspeed_msg���e���edx
	call WriteString ;��Xedx���e
	call ReadDec	 ;Ū���@�ӵL�����
	mov delay_T,EAX	 ;�N���ƭȦs��delay_T
	call Clrscr      ;�M�ſù�
	jmp L1			 ;���ܿ��

start:
	mov eax,0	;��l�ƼȦs��
	mov edx,0   ;��l�ƼȦs��
	call Clrscr ;�M���ù�

	CALL InitialSnake              ;�w���]�w�D����m
	call CreateMap				   ;�إ����
	CALL draw				 	   ;ø�X�ϧ�
	call producefood			   ;���ͭ���
	call playgame				   ;�}�l�i��C��

	mov dh, 12				; �N��в��ʨ�s��m
    MOV dl, 36d				; �H�b�ù�������X
    call GotoXY				; Game over �T��
	mov eax,13 + ( 11 * 16) ;13:�r��L�v����B11:�I���L�C���
	call SetTextColor		;�]�w�C��
   mov edx,OFFSET gameovermsg ;�Ngameovermsg�����e���edx��
	call WriteString		  ;�N���e��X�ܿù��W

	mov dh,24               ;�H�U�N�r�������~
	mov dl,0				;
	call gotoxy				;���ʨ�Ӧ�m
	mov eax,11 + ( 11 * 16)	;�N�r��P�I���˦��@�˪��C��
	call SetTextColor		;�]�w�C��
	INVOKE ExitProcess,0	;�I�s�����{��
main ENDP
;-----------------------------------------------------------------
playgame PROC Uses EAX
L1:
	call readkey			;Ū���O�_����L��J
	jz pass                 ;��ZF=0�ɥN��ϥΪ̵L������L

	cmp al,'p'				;�P�_�O�_�n�Ȱ��C��
	jne L2					;���������L2
pause_game:
	call waitMsg
	jmp pass

L2:
	mov newdir,al			;�N�s��J���ȥ��newdir
	cmp dir,'w'				;�����e��V
	je updown				;����w�A�h����updown
	cmp dir,'s'				;�����e��V
	je updown				;����s�A�h����updown
	jmp leftright			;��������A�h����leftright

updown:					
	cmp newdir,'a'			;����s��J����V
	je asgn					;����a�A�h����asgn
	cmp newdir,'d'			;����s��J����V
	je asgn					;����d�A�h����asgn
	jmp pass				;��������A�h����pass

leftright:
	cmp newdir,'w'			;����s��J����V
	je asgn					;����w�A�h����asgn
	cmp newdir,'s'			;����s��J����V
	je asgn					;����s�A�h����asgn
	jmp pass				;��������A�h����pass

asgn:
	mov dir,al				;�N��e��V���ȳ]�w���s��J����V��

pass:
	call snakeaction		;�I�ssnakeaction
	cmp gameover,1			;���gameover�O�_��1
	je quit					;�O�A�����C��
	mov eax, delay_T		;���O�A�Ndelay_T�h��eax�A�ηN������C���A�קK�D�]�ӧ�
    call delay				;�I�sdelay
    jmp L1					;����L1

quit:	
	ret
playgame ENDP
;-----------------------------------------------------------------
Snakeaction PROC Uses EDX ECX EAX EBX
	cmp addtail,1				  ;���addtail�A�T�{�O�_�ݭn�W�[�D��
	jne noadd					  ;������1�A�h���μW�[�A����noadd
	mov eax,0                     ;�o�U���O�W�[����
	mov ax,snakelength			  ;�N�D�ثe���ש��AX
	mov dh,row[eax]				  ;�N�쥻�����ڪ�row col�s��dh,dl
	mov dl,col[eax]				  ;�N�쥻�����ڪ�row col�s��dh,dl
	inc ax						  ;�W�[���ڪ���
	mov snakelength ,ax			  ;�s�Jsnakelength
	mov row[eax],dh				  ;�N�쥻�����ڪ�row col�s��s������
	mov col[eax],dl				  ;�N�쥻�����ڪ�row col�s��s������
	mov  ax,temporarylength		  ;�N�Ȯɪ��ש��AX

noadd:
	mov eax,0                     ;�M��EAX
	mov ax,snakelength		      ;�N�D�����AX
	cmp ax,temporarylength        ;��Ȯɪ��פ�����쥻���׮ɪ�ܳD���W�[�A
	jne nocleartail				  ;���ɤ����M�����ڵe��
	mov dh,row[eax]				  ;�N�D����row col�s��dh,dl
	mov dl,col[eax]				  ;�N�D����row col�s��dh,dl
	mov bx, 0                     ;�N0�h��BX�A����s�ȶi�a��
    call storevalue				  ;�I�sstorevalue�A�s��BX

    call gotoxy                    ;�N���ڪ��e������
    mov eax,11 + ( 11 * 16)        ;�N�r��P�I���˦��@�˪��C��
	call SetTextColor
    mov al, ' '
    call writechar				  ;��J' ' �ܿù��W

	mov dh,25                       ;�H�U�N�r�������~
	mov dl,0
	call gotoxy
	mov eax,11 + ( 11 * 16)			;�N�r��P�I���˦��@�˪��C��
	call SetTextColor

nocleartail:
	mov ecx,0  
	mov cx,temporarylength
	mov eax,0  
	mov ax,temporarylength
	dec ax

exchangeback:
	mov dh,row[eax]
	mov dl,col[eax]
	mov row[ecx],dh
	mov col[ecx],dl
	dec cx
	dec ax
	cmp cx,1
	ja exchangeback              ;�`�N!!!!!!!!!!!!!!!!
	cmp dir,'w'                  ;�V�W��
	jne otherdir1
	mov dh,row[1]
	dec dh                        ;�V�W���Arow-1
	mov row[1],dh
	jmp others

otherdir1:
	cmp dir,'s'                  ;�V�U��
	jne otherdir2
	mov dh,row[1]
	inc dh                       ;�V�U���Arow+1
	mov row[1],dh
	jmp others

otherdir2:
	cmp dir,'d'                  ;�V�k��
	jne otherdir3
	mov dl,col[1]
	inc dl                       ;�V�k���Acol+1
	mov col[1],dl
	jmp others

otherdir3:
	cmp dir,'a'                  ;�V����
	mov dl,col[1]
	dec dl                       ;�V�����Acol-1
	mov col[1],dl

others:
	mov dh,row[1]
	mov dl,col[1]
	call getvalue
	cmp bx,0
	je path
	cmp bx,2
	je eatfood
	mov gameover,1
	ret

path:
	mov addtail,0
	jmp drawhead

eatfood:
	mov addtail,1
	call ProduceFood

drawhead:
	mov dh,row[1]
	mov dl,col[1]
	mov bx,1
	call storevalue
	call gotoxy
	mov eax,0 + ( 0 * 16)  ;�¦�
	call SetTextColor
	mov AL,' '
	call writechar                  ;�H�W�O�e�Y��

	mov dh,24                      ;�H�U�N�r�������~
	mov dl,0
	call gotoxy
	mov eax,11 + ( 11 * 16)			;�N�r��P�I���˦��@�˪��C��
	call SetTextColor
	
	mov eax,0                     
	mov ax,snakelength  
	mov temporarylength,ax
ret
Snakeaction ENDP
;-----------------------------------------------------------------
ProduceFood PROC USES EAX EBX EDX
	food:
	mov eax,79	;����0~78���N�Ʀr�A�]��79������A�G�ٲ�
	call RandomRange
	mov dl,al

	mov eax,23	;����0~22���N�Ʀr�A�]��22������A�G�ٲ�
	call RandomRange
	mov dh,al

	call GetValue ;�T�w�Ӧ�m�O�_������B�D����
	cmp bx,0	  ;�p�G�O�q�D�A�h��m����
	jne food	  ;�p�G���O�A�h���s�ͦ�������m
	
	push ebx	  ;�NEBX push�ܰ��|
	mov bx,02h    ;�N�������ȳ]��2
	call StoreValue ;�I�sStoreValue�A�s��
	pop ebx		  ;���X���|
	
	mov eax,0 + (15 * 16)
	call SetTextColor
	call Gotoxy
	mov al,'F'
	call WriteChar

	ret
ProduceFood ENDP
;-----------------------------------------------------------------
InitialSnake PROC Uses esi EDX EBX	;���{�Ǭ��w���إ߳D������
	mov esi ,1			;�N1�s��esi
	mov row[esi],18		;�Nrow���Ĥ@��]���Y����m
	mov col[esi],50		;�Ncol���Ĥ@��]���Y����m
	mov dh,18			;�N18�s�JDH
	mov dl,50			;�N50�s�JDL
	mov bx,1			;�ڭ̳]�w1���D������A��JBX
	call storevalue		;�N18�B50���Ӧ�m������Ȧs�Jmap��
	mov esi,2			;�N1�s��esi
	mov row[esi],19		;�Nrow���ĤG��]���D������m
	mov col[esi],50		;�Ncol���ĤG��]���D������m
	mov dh,19			;�N19�s�JDH
	mov dl,50			;�N50�s�JDL
	mov bx,1			;�ڭ̳]�w1���D������A��JBX
	call storevalue		;�N19�B50���Ӧ�m������Ȧs�Jmap��
	ret					;��^
InitialSnake ENDP
;-----------------------------------------------------------------
draw PROC Uses eax edx esi ebx
	mov DH,0	;�N0��JDH�A�q��0�C�}�l
outerloop:
	cmp DH,24	 ;�P�_�O�_��F�U���
	JGE drawsnake;�j�󪺸ܸ���drwasnake

	mov DL,0	 ;�N0��JDL
	innerloop:
	cmp DL,80	 ;�P�_�O�_��F�k���
	JGE incdh	 ;�j�󪺸ܸ���incdh
	call gotoxy	 ;���ʨ�DH�BDL��m

	call GetValue;���o�Ӧ�m����
	cmp bx,0	 ;�p�G�O0�A�h���q�D�A����ø�e
	je notdraw	 ;��0����notdraw

	cmp bx,1	 ;�p�G��1�A�h���D������
	je notdraw	 ;�]����ø�e
						   ;���O0�]���O1�A�Y�����-1�A�]��ø�X���
	mov eax,15 + ( 4 * 16) ;15:�r��զ�B4:�I������
	call SetTextColor	   ;�]�w�C��
	mov AL,'\'			   ;����ϧ�
	call writechar		   ;��X�ܿù��W
notdraw:
	INC DL				   ;�滼�W
		jmp innerloop      ;���ư��椺���j��
INCDH:						
	inc DH				   ;�C���W
jmp outerloop			   ;���ư���~���j��

drawsnake:				   ;��LABEL �� ø�X�D������
	mov dh,row[1]          ;�D�Y��m
	mov dl,col[1]		   ;
	call gotoxy			   ;���ʨ�D�Y��m
	mov eax,14 + ( 0 * 16) ;�r�����A�I���¦�
	call SetTextColor	   ;�]�w�D���¦�
	mov AL,' '             ;�D��
	call writechar		   ;�N�ϧο�X�ܿù��W
	mov dh,row[2]		   ;�D����m
	mov dl,col[2]          ;
	call gotoxy            ;���ʨ�D����m
	mov AL,' '             ;�D��
	call writechar         ;�N�ϧο�X�ܿù��W
	mov dh,24              ;�N��в��ʨ���~
	mov dl,0			   ;
	call gotoxy            ;
	mov eax,11 + ( 11 * 16)  ;�N�r��P�I���˦��@�˪��C��
	call SetTextColor      ;
ret						   ;��^
draw ENDP
;-----------------------------------------------------------------
GetValue PROC USES EAX ESI EDX	;���{�ǻPstorevalue����
								;���L�@�ӬO��Ȧs�i�h
								;�@�ӬO���X�ӡA���{�Ǭ����X��

	mov bl,dh	;��row�s��bl
	mov al,80	;�N�@���}�C��row�ഫ���G���}�C����m
	mul bl		;��0~79 �A 1���H80 ��n����ĤG�C�A�H������...
	push dx		;�NDX��J���|
	mov dh,0	;�Nrow���ȲM�šA�����p��column
	add ax,dx	;���]AX �{�b�O80�A�Y�ĤG�C�Ĥ@��A�[�WDX�A�]��DH=0
				;�ҥH�u���p���column�A�N�Y�ҥ[���Ʀr����ĤG�C��dx��
				;�̦�����

	pop dx		;�NDX���X���|
	mov esi,0	;�M��ESI�Ȧs��
	mov si,ax	;�N�ഫ�����G���}�C��m���si�Ȧs��

	push eax	;�NEAX��J���|
	mov ax,2	;�s�J2��AX
	mul si		;��SI����m*2�A�]��map�����A�OWORD
	mov si,ax	;�N*2���ȦA��JSI
	pop eax		;�NEAX���X���|
	mov bx,map[si] ;���omap[si]��m���ȡA�P�_�O�_������B�q�D�B����
				   
	ret			;��^

GetValue ENDP
;-----------------------------------------------------------------
StoreValue PROC USES EAX ESI EDX
	push ebx	;�NEBX ��J���|
	mov bl,dh	;��row�s��bl
	mov al,80	;�N�@���}�C��row�ഫ���G���}�C����m
	mul bl		;��0~79 �A 1���H80 ��n����ĤG�C�A�H������...
	push dx		;�NDX��J���|
	mov dh,0	;�Nrow���ȲM�šA�����p��column
	add ax,dx	;���]AX �{�b�O80�A�Y�ĤG�C�Ĥ@��A�[�WDX�A�]��DH=0
				;�ҥH�u���p���column�A�N�Y�ҥ[���Ʀr����ĤG�C��dx��
				;�̦�����

	pop dx		;�NDX���X���|
	mov esi,0	;�M��ESI�Ȧs��
	mov si,ax	;�N�ഫ�����G���}�C��m���si�Ȧs��
	pop ebx		;���XEBX���|

	push eax	;�NEAX��J���|
	mov ax,2	;�s�J2��AX
	mul si		;��SI����m*2�A�]��map�����A�OWORD
	mov si,ax	;�N*2���ȦA��JSI
	pop eax		;�NEAX���X���|
	mov map[si],bx ;�N�ഫ���G���}�C��SI��m���V�@���}�C��map
				   ;�åB���]�����
	ret			;��^
StoreValue ENDP
;-----------------------------------------------------------------
CreateMap PROC	;�إ����
	pushad				;�N�Ȧs�����J���|
	mov bx,0FFFFh		;�N����ȳ]�w��-1
	
	mov dl,0			;�N0�s�JDL
	mov ecx,80			;�N79�s�JECX�A���j�鬰�إߤW�U��ɤ����
	row_wall:		
		mov dh,0		;�W������
		call StoreValue	;�x�s�Ӧ�m����� 
		mov dh,23		;�U������
		call StoreValue	;�x�s�Ӧ�m�����
		inc dl			;�滼�W
		loop row_wall

	mov dh,0			;�N0�s�JDH
	mov ecx,24   		;�N24�s�JECX�A���j�鬰�إߤW�U��ɤ����
	column_wall:
		mov dl,0		;��������
		call StoreValue	;�x�s�Ӧ�m�����
		mov dl,79		;�k������
		call StoreValue	;�x�s�Ӧ�m�����
		inc dh			;�C���W
		loop column_wall
	popad				;���X�Ȧs��
    RET					;��^
CreateMap ENDP
;-----------------------------------------------------------------
END main


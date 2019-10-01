INCLUDE Irvine32.inc

.data
	map WORD 1920 DUP (0) ;地圖大小(24*80)
	row byte 1920 DUP (0) ;蛇的row(24*80)
	col byte 1920 DUP (0) ;蛇的col(24*80)
	snakelength WORD 2;蛇目前長度
	temporarylength WORD 2;蛇目前暫時長度
	dir byte 'w'
	newdir    BYTE    'w'
	addTail   BYTE    0d
	Gameover   BYTE    0d 
	msg BYTE "歡迎來到貪食蛇遊戲",0dh,0ah,
			 "本遊戲以Assembly Language實作完成",0dh,0ah,
			 "此遊戲操作非常簡單，只需以鍵盤上的",0dh,0ah,
			 "W、S、A、D按鍵，即可遊玩。",0dh,0ah,
			 "P鍵為暫停遊戲",0dh,0ah,
			 "預祝各位玩的愉快~!",0dh,0ah,
			 "請選擇以下選項:",0dh,0ah,
			 "1.開始遊戲",0dh,0ah,
			 "2.調整速度",0dh,0ah,
	         "3.離開遊戲",0dh,0ah,0

	speed_msg BYTE "請輸入更改數值(預設100ms,單位毫秒):",0
	delay_T DWORD 100 ;設定遊戲延遲100ms，不然蛇會跑太快
	gameovermsg BYTE "gameover",0
.code
main PROC
	mov eax,13 + ( 11 * 16)  ;13:字體淺洋紅色、11:背景淺青綠色
	call SetTextColor		 ;設定字體、背景顏色
	call Clrscr				 ;清除螢幕
L1:
	mov edx,OFFSET msg ;將msg的內容放到edx中
	call WriteString   ;將內容輸出至螢幕上
	
wait1:
	call ReadChar ;等待按鍵輸入

	CMP AL,'1'
	JE start		;跳到開始遊戲

	CMP AL,'2'		;調整速度
	JE speed

	CMP AL,'3'		;離開遊戲
	JNE wait1		;如果都不是以上選項，則重複等待輸入

	EXIT

	speed:
	call Clrscr		;清空螢幕
	mov edx,OFFSET speed_msg	;將speed_msg內容放至edx
	call WriteString ;輸出edx內容
	call ReadDec	 ;讀取一個無號整數
	mov delay_T,EAX	 ;將此數值存至delay_T
	call Clrscr      ;清空螢幕
	jmp L1			 ;跳至選單

start:
	mov eax,0	;初始化暫存器
	mov edx,0   ;初始化暫存器
	call Clrscr ;清除螢幕

	CALL InitialSnake              ;預先設定蛇的位置
	call CreateMap				   ;建立牆壁
	CALL draw				 	   ;繪出圖形
	call producefood			   ;產生食物
	call playgame				   ;開始進行遊玩

	mov dh, 12				; 將游標移動到新位置
    MOV dl, 36d				; 以在螢幕中間輸出
    call GotoXY				; Game over 訊息
	mov eax,13 + ( 11 * 16) ;13:字體淺洋紅色、11:背景淺青綠色
	call SetTextColor		;設定顏色
   mov edx,OFFSET gameovermsg ;將gameovermsg的內容放到edx中
	call WriteString		  ;將內容輸出至螢幕上

	mov dh,24               ;以下將字體拋離牆外
	mov dl,0				;
	call gotoxy				;移動到該位置
	mov eax,11 + ( 11 * 16)	;將字體與背景弄成一樣的顏色
	call SetTextColor		;設定顏色
	INVOKE ExitProcess,0	;呼叫結束程序
main ENDP
;-----------------------------------------------------------------
playgame PROC Uses EAX
L1:
	call readkey			;讀取是否有鍵盤輸入
	jz pass                 ;當ZF=0時代表使用者無按壓鍵盤

	cmp al,'p'				;判斷是否要暫停遊戲
	jne L2					;不等於跳至L2
pause_game:
	call waitMsg
	jmp pass

L2:
	mov newdir,al			;將新輸入的值丟至newdir
	cmp dir,'w'				;比較當前方向
	je updown				;等於w，則跳至updown
	cmp dir,'s'				;比較當前方向
	je updown				;等於s，則跳至updown
	jmp leftright			;都不等於，則跳至leftright

updown:					
	cmp newdir,'a'			;比較新輸入的方向
	je asgn					;等於a，則跳至asgn
	cmp newdir,'d'			;比較新輸入的方向
	je asgn					;等於d，則跳至asgn
	jmp pass				;都不等於，則跳至pass

leftright:
	cmp newdir,'w'			;比較新輸入的方向
	je asgn					;等於w，則跳至asgn
	cmp newdir,'s'			;比較新輸入的方向
	je asgn					;等於s，則跳至asgn
	jmp pass				;都不等於，則跳至pass

asgn:
	mov dir,al				;將當前方向的值設定為新輸入的方向值

pass:
	call snakeaction		;呼叫snakeaction
	cmp gameover,1			;比較gameover是否為1
	je quit					;是，結束遊戲
	mov eax, delay_T		;不是，將delay_T搬至eax，用意為延遲遊戲，避免蛇跑太快
    call delay				;呼叫delay
    jmp L1					;跳至L1

quit:	
	ret
playgame ENDP
;-----------------------------------------------------------------
Snakeaction PROC Uses EDX ECX EAX EBX
	cmp addtail,1				  ;比較addtail，確認是否需要增加蛇長
	jne noadd					  ;不等於1，則不用增加，跳至noadd
	mov eax,0                     ;這下面是增加尾巴
	mov ax,snakelength			  ;將蛇目前長度放至AX
	mov dh,row[eax]				  ;將原本的尾巴的row col存到dh,dl
	mov dl,col[eax]				  ;將原本的尾巴的row col存到dh,dl
	inc ax						  ;增加尾巴長度
	mov snakelength ,ax			  ;存入snakelength
	mov row[eax],dh				  ;將原本的尾巴的row col存到新的尾巴
	mov col[eax],dl				  ;將原本的尾巴的row col存到新的尾巴
	mov  ax,temporarylength		  ;將暫時長度放至AX

noadd:
	mov eax,0                     ;清空EAX
	mov ax,snakelength		      ;將蛇長放至AX
	cmp ax,temporarylength        ;當暫時長度不等於原本長度時表示蛇長增加，
	jne nocleartail				  ;此時不須清除尾巴畫素
	mov dh,row[eax]				  ;將蛇尾的row col存到dh,dl
	mov dl,col[eax]				  ;將蛇尾的row col存到dh,dl
	mov bx, 0                     ;將0搬至BX，之後存值進地圖
    call storevalue				  ;呼叫storevalue，存放BX

    call gotoxy                    ;將尾巴的畫素移除
    mov eax,11 + ( 11 * 16)        ;將字體與背景弄成一樣的顏色
	call SetTextColor
    mov al, ' '
    call writechar				  ;輸入' ' 至螢幕上

	mov dh,25                       ;以下將字體拋離牆外
	mov dl,0
	call gotoxy
	mov eax,11 + ( 11 * 16)			;將字體與背景弄成一樣的顏色
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
	ja exchangeback              ;注意!!!!!!!!!!!!!!!!
	cmp dir,'w'                  ;向上走
	jne otherdir1
	mov dh,row[1]
	dec dh                        ;向上走，row-1
	mov row[1],dh
	jmp others

otherdir1:
	cmp dir,'s'                  ;向下走
	jne otherdir2
	mov dh,row[1]
	inc dh                       ;向下走，row+1
	mov row[1],dh
	jmp others

otherdir2:
	cmp dir,'d'                  ;向右走
	jne otherdir3
	mov dl,col[1]
	inc dl                       ;向右走，col+1
	mov col[1],dl
	jmp others

otherdir3:
	cmp dir,'a'                  ;向左走
	mov dl,col[1]
	dec dl                       ;向左走，col-1
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
	mov eax,0 + ( 0 * 16)  ;黑色
	call SetTextColor
	mov AL,' '
	call writechar                  ;以上是畫頭部

	mov dh,24                      ;以下將字體拋離牆外
	mov dl,0
	call gotoxy
	mov eax,11 + ( 11 * 16)			;將字體與背景弄成一樣的顏色
	call SetTextColor
	
	mov eax,0                     
	mov ax,snakelength  
	mov temporarylength,ax
ret
Snakeaction ENDP
;-----------------------------------------------------------------
ProduceFood PROC USES EAX EBX EDX
	food:
	mov eax,79	;產生0~78任意數字，因為79為牆壁，故省略
	call RandomRange
	mov dl,al

	mov eax,23	;產生0~22任意數字，因為22為牆壁，故省略
	call RandomRange
	mov dh,al

	call GetValue ;確定該位置是否為牆壁、蛇本身
	cmp bx,0	  ;如果是通道，則放置食物
	jne food	  ;如果不是，則重新生成食物位置
	
	push ebx	  ;將EBX push至堆疊
	mov bx,02h    ;將食物的值設為2
	call StoreValue ;呼叫StoreValue，存值
	pop ebx		  ;取出堆疊
	
	mov eax,0 + (15 * 16)
	call SetTextColor
	call Gotoxy
	mov al,'F'
	call WriteChar

	ret
ProduceFood ENDP
;-----------------------------------------------------------------
InitialSnake PROC Uses esi EDX EBX	;此程序為預先建立蛇的身體
	mov esi ,1			;將1存到esi
	mov row[esi],18		;將row的第一位設為頭的位置
	mov col[esi],50		;將col的第一位設為頭的位置
	mov dh,18			;將18存入DH
	mov dl,50			;將50存入DL
	mov bx,1			;我們設定1為蛇的身體，放入BX
	call storevalue		;將18、50的該位置的身體值存入map中
	mov esi,2			;將1存到esi
	mov row[esi],19		;將row的第二位設為蛇尾的位置
	mov col[esi],50		;將col的第二位設為蛇尾的位置
	mov dh,19			;將19存入DH
	mov dl,50			;將50存入DL
	mov bx,1			;我們設定1為蛇的身體，放入BX
	call storevalue		;將19、50的該位置的身體值存入map中
	ret					;返回
InitialSnake ENDP
;-----------------------------------------------------------------
draw PROC Uses eax edx esi ebx
	mov DH,0	;將0放入DH，從第0列開始
outerloop:
	cmp DH,24	 ;判斷是否到達下邊界
	JGE drawsnake;大於的話跳至drwasnake

	mov DL,0	 ;將0放入DL
	innerloop:
	cmp DL,80	 ;判斷是否到達右邊界
	JGE incdh	 ;大於的話跳至incdh
	call gotoxy	 ;移動到DH、DL位置

	call GetValue;取得該位置的值
	cmp bx,0	 ;如果是0，則為通道，不須繪畫
	je notdraw	 ;為0跳至notdraw

	cmp bx,1	 ;如果為1，則為蛇的身體
	je notdraw	 ;也不須繪畫
						   ;不是0也不是1，即為牆壁-1，因此繪出牆壁
	mov eax,15 + ( 4 * 16) ;15:字體白色、4:背景紅色
	call SetTextColor	   ;設定顏色
	mov AL,'\'			   ;牆壁圖形
	call writechar		   ;輸出至螢幕上
notdraw:
	INC DL				   ;行遞增
		jmp innerloop      ;重複執行內部迴圈
INCDH:						
	inc DH				   ;列遞增
jmp outerloop			   ;重複執行外部迴圈

drawsnake:				   ;此LABEL 為 繪出蛇的身體
	mov dh,row[1]          ;蛇頭位置
	mov dl,col[1]		   ;
	call gotoxy			   ;移動到蛇頭位置
	mov eax,14 + ( 0 * 16) ;字體黃色，背景黑色
	call SetTextColor	   ;設定蛇為黑色
	mov AL,' '             ;蛇圖
	call writechar		   ;將圖形輸出至螢幕上
	mov dh,row[2]		   ;蛇尾位置
	mov dl,col[2]          ;
	call gotoxy            ;移動到蛇尾位置
	mov AL,' '             ;蛇圖
	call writechar         ;將圖形輸出至螢幕上
	mov dh,24              ;將游標移動到牆外
	mov dl,0			   ;
	call gotoxy            ;
	mov eax,11 + ( 11 * 16)  ;將字體與背景弄成一樣的顏色
	call SetTextColor      ;
ret						   ;返回
draw ENDP
;-----------------------------------------------------------------
GetValue PROC USES EAX ESI EDX	;此程序與storevalue類似
								;不過一個是把值存進去
								;一個是取出來，此程序為取出來

	mov bl,dh	;把row存到bl
	mov al,80	;將一維陣列的row轉換成二維陣列的位置
	mul bl		;行0~79 ， 1乘以80 剛好換到第二列，以此類推...
	push dx		;將DX放入堆疊
	mov dh,0	;將row的值清空，換成計算column
	add ax,dx	;假設AX 現在是80，即第二列第一行，加上DX，因為DH=0
				;所以只有計算到column，意即所加的數字等於第二列的dx行
				;依此類推

	pop dx		;將DX取出堆疊
	mov esi,0	;清空ESI暫存器
	mov si,ax	;將轉換成的二維陣列位置放到si暫存器

	push eax	;將EAX放入堆疊
	mov ax,2	;存入2到AX
	mul si		;把SI的位置*2，因為map的型態是WORD
	mov si,ax	;將*2的值再放入SI
	pop eax		;將EAX取出堆疊
	mov bx,map[si] ;取得map[si]位置的值，判斷是否為牆壁、通道、食物
				   
	ret			;返回

GetValue ENDP
;-----------------------------------------------------------------
StoreValue PROC USES EAX ESI EDX
	push ebx	;將EBX 放入堆疊
	mov bl,dh	;把row存到bl
	mov al,80	;將一維陣列的row轉換成二維陣列的位置
	mul bl		;行0~79 ， 1乘以80 剛好換到第二列，以此類推...
	push dx		;將DX放入堆疊
	mov dh,0	;將row的值清空，換成計算column
	add ax,dx	;假設AX 現在是80，即第二列第一行，加上DX，因為DH=0
				;所以只有計算到column，意即所加的數字等於第二列的dx行
				;依此類推

	pop dx		;將DX取出堆疊
	mov esi,0	;清空ESI暫存器
	mov si,ax	;將轉換成的二維陣列位置放到si暫存器
	pop ebx		;取出EBX堆疊

	push eax	;將EAX放入堆疊
	mov ax,2	;存入2到AX
	mul si		;把SI的位置*2，因為map的型態是WORD
	mov si,ax	;將*2的值再放入SI
	pop eax		;將EAX取出堆疊
	mov map[si],bx ;將轉換為二維陣列的SI位置指向一維陣列的map
				   ;並且把其設為牆壁
	ret			;返回
StoreValue ENDP
;-----------------------------------------------------------------
CreateMap PROC	;建立牆壁
	pushad				;將暫存器壓入堆疊
	mov bx,0FFFFh		;將牆壁值設定為-1
	
	mov dl,0			;將0存入DL
	mov ecx,80			;將79存入ECX，此迴圈為建立上下邊界之牆壁
	row_wall:		
		mov dh,0		;上邊界牆壁
		call StoreValue	;儲存該位置為牆壁 
		mov dh,23		;下邊界牆壁
		call StoreValue	;儲存該位置為牆壁
		inc dl			;行遞增
		loop row_wall

	mov dh,0			;將0存入DH
	mov ecx,24   		;將24存入ECX，此迴圈為建立上下邊界之牆壁
	column_wall:
		mov dl,0		;左邊界牆壁
		call StoreValue	;儲存該位置為牆壁
		mov dl,79		;右邊界牆壁
		call StoreValue	;儲存該位置為牆壁
		inc dh			;列遞增
		loop column_wall
	popad				;取出暫存器
    RET					;返回
CreateMap ENDP
;-----------------------------------------------------------------
END main


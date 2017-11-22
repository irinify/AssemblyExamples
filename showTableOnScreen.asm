;注：函数中的标号为防止冲突，都加了本函数名为前缀
;在Debug中输入“-g 90”,直接运行到结束
assume cs:code
data segment
db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
db '1993','1994','1995'
;以上是表示21年的21个字符串
dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
;以上是表示21年公司总收的21个dword型数据
dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
dw 11542,14430,45257,17800
;以上是表示21年公司雇员人数的21个word型数据
data ends
agency segment
db 8 dup(0)
agency ends

code segment
start:
mov ax,0b800h
mov es,ax
mov di,0
mov cx,80*24	;屏幕尺寸80列24行
x:
mov byte ptr es:[di],' ' ;将屏幕清空
mov byte ptr es:[di+1],0
inc di
inc di
loop x

mov ax,data
mov es,ax
mov di,0
mov bx,0
mov ax,agency
mov ds,ax
mov si,0
mov dh,4
mov cx,21
x1:
push cx
mov ax,es:[di]
mov ds:[si],ax
mov ax,es:[di+2]
mov ds:[si+2],ax
mov byte ptr ds:[si+4],0 ;显示年份
mov dl,0
mov cl,2
call show_str

mov ax,es:[84+di]
push dx
mov dx,es:[84+di+2]
call dtoc_dword ;显示收入
pop dx
mov dl,20
mov cl,2
call show_str

mov ax,es:[84+84+bx]
call dtoc_word
mov dl,40 ;显示雇员数
mov cl,2
call show_str

mov ax,es:[84+di]
push dx
mov dx,es:[84+di+2]
div word ptr es:[84+84+bx] ;计算人均收入并显示
call dtoc_word
pop dx
mov dl,60
mov cl,2
call show_str

add di,4
add bx,2
add dh,1
pop cx
loop x1
mov ax,4c00h
int 21h

;名称：show_str
;功能：在屏幕的指定位置，用指定颜色，显示一个用0结尾的字符串
;参数：（dh）=行号，（dl）=列号（取值范围0～80），（cl）=颜色，ds：si：该字符串的首地址
;返回：显示在屏幕上
show_str:
push ax
push cx
push dx
push es
push si
push di
mov ax,0b800h
mov es,ax
mov al,160
mul dh	;结果放在ax里面
add dl,dl
mov dh,0
add ax,dx	;dx是每行显示的偏移数，ax是显示在第几行
mov di,ax	;di存屏幕缓存地址
mov ah,cl	;cl存了字符的颜色
show_str_x:
mov cl,ds:[si]
mov ch,0
jcxz show_str_f
mov al,cl
mov es:[di],ax
inc si
inc di
inc di
jmp show_str_x
show_str_f:
pop di
pop si
pop es
pop dx
pop cx
pop ax
ret
;名称：dtoc_word
;功能：将一个word型数转化为字符串
;参数：（ax）=word型的数据，ds:si指向字符串的首地址
;返回：ds:[si]放此字符串，以0结尾
dtoc_word:
push ax
push bx
push cx
push dx
push si
mov bx,0
dtoc_word_x:
mov dx,0
mov cx,10
div cx
mov cx,ax
add dx,'0'
push dx
inc bx
jcxz dtoc_word_f
jmp dtoc_word_x
dtoc_word_f:
mov cx,bx
dtoc_word_x1:
pop ds:[si]
inc si
loop dtoc_word_x1
pop si
pop dx
pop cx
pop bx
pop ax
ret
;名称：dtoc_dword
;功能：将一个double word型数转化为字符串
;参数：(dx)=数的高八位，（ax）=数的低八位
;返回：ds:[si]放此字符串，以0结尾
;备注：会用到divdw函数
dtoc_dword:
push ax
push bx
push cx
push dx
push si
mov bx,0
dtoc_dword_x:
mov cx,10
call divdw
push cx		;cx装了除法运算的余数，即被除数最低位的数值，入栈
inc bx
;bx记入栈的数字数量，以便出栈，且低数位数字先入后出，正好是顺序的十进制数
cmp ax,0
jne dtoc_dword_x
cmp dx,0
jne dtoc_dword_x
;两个cmp判断各位是否除10完成，若ax为0，dx不为0，只是低位除完了，高位还有；当ax dx都为0，完全除完
mov cx,bx  ;将bx记的入栈数字数量传给cx，准备出栈
dtoc_dword_x1:
pop ds:[si]
add byte ptr ds:[si],'0' ;0字符代表30H，将数字转换成ASCII码值
inc si
loop dtoc_dword_x1
pop si
pop dx
pop cx
pop bx
pop ax
ret
;名称：divdw
;功能：除法，被除数32位，除数16位，商32位，余数16位，不会溢出
;参数：（dx）=被除数高16位，（ax）=被除数低16位，（cx）=除数
;返回：（dx）=商高16位，（ax）=商低16位，（cx）=余数
divdw:
push bx
push ax
mov ax,dx
mov dx,0
div cx
mov bx,ax
pop ax
div cx
mov cx,dx
mov dx,bx
pop bx
ret

code ends
end start
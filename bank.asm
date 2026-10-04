BITS 16
ORG 0x100

Main:
    jmp mainloop_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          MACROS (must come first)                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%macro printString 1
    mov ah,9
    mov dx,%1
    int 21h
%endmacro

%macro ISop11 1
    mov si,%1
  %%input:
        mov ah,1
        int 21h
        cmp al,13
        je labelop1_1
        mov [si],al
        inc si
        jmp %%input
%endmacro

%macro ISop12 1
    mov si,%1
  %%input2:
        mov ah,1
        int 21h
        cmp al,13
        je labelop1_2
        inc word [accountPINcount]
        mov [si],al
        inc si
        jmp %%input2
%endmacro

%macro ISop6 1
    mov si,%1
  %%input:
        mov ah,1
        int 21h
        cmp al,13
        je labelop6_1
        mov [si],al
        inc si
        jmp %%input
%endmacro

%macro ISop6_2 1
    mov si,%1
    mov word [accountPINcount],0
  %%input2:
        mov ah,1
        int 21h
        cmp al,13
        je labelop6_2
        inc word [accountPINcount]
        mov [si],al
        inc si
        jmp %%input2
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             U T I L S                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

etc:
  .in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp .in
    ret

checkAccountCreated:
  cmp word [accountPINcount],0
  je .notCreated
  ret
  .notCreated:
    call clearScreen
    printString pinop_msg2
    call etc
    ret

printNumber:
    mov cx,0
    mov dx,0
  .label1:
        cmp ax,0
        je .print1
        mov bx,10
        div bx
        push dx
        inc cx
        xor dx,dx
        jmp .label1
  .print1:
        cmp cx,0
        je .exitprint
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp .print1
  .exitprint:
    ret

clearScreen:
    call newLine
    call newLine
    ret

newLine:
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    ret

getPinInput:
  call clearScreen
  printString pinop_msg1
  mov si,accountPIN
  mov cx,[accountPINcount]
  .getinput:
    mov ah,7
    int 21h
    cmp al,[si]
    mov dl,'*'
    mov ah,2
    int 21h
    jne mainloop
    inc si
  loop .getinput
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        M E N U   SYSTEM                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayMenu:
    printString dmsg1
    call newLine
    printString dmsg2
    call newLine
    printString dmsg3
    call newLine
    printString dmsg4
    call newLine
    printString dmsg5
    call newLine
    printString dmsg6
    call newLine

    call newLine
    printString opmsg1
    call newLine
    printString opmsg2
    call newLine
    printString opmsg3
    call newLine
    printString opmsg4
    call newLine
    printString opmsg5
    call newLine
    printString opmsg6
    call newLine
    ret

GetInputMenuSystem:
    call newLine
    printString imsg
    mov ah,1
    int 21h
    mov [inputCode],al
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               O P T I O N  1   => CREATE ACCOUNT                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

etcop1:
  .in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp .in
    ret

op1:
    call clearScreen

    printString op1mmsg1
    call newLine
    printString op1mmsg2
    call newLine
    printString op1mmsg3
    call newLine
    printString op1mmsg4
    call newLine
    printString op1mmsg5
    call newLine
    call newLine
    call newLine

    printString op1msg1
    ISop11 accountName

labelop1_1:
      call newLine
      printString op1msg2
      ISop12 accountPIN

labelop1_2:
        call newLine
        call newLine
        printString op1msg3
        call etcop1
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               O P T I O N  2   => PRINT DETAILS                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

etcop2:
   call newLine
   printString opmsg8
  .in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp .in
    ret

op2:
  call checkAccountCreated
  call getPinInput
  call clearScreen

  printString op2mmsg1
  call newLine
  printString op2mmsg2
  call newLine
  printString op2mmsg3
  call newLine
  printString op2mmsg4
  call newLine
  printString op2mmsg5
  call newLine
  call newLine
  call newLine

  printString op2msg1
  printString accountName
  call newLine

  printString op2msg2
  printString accountPIN
  call newLine

  printString op2msg4
  mov ax,[totalAmount]
  cmp ax,0
  je noMoneyError
  call printNumber
  call newLine

  call etcop2

noMoneyError:
    printString op2msg5
    call newLine
    call etcop2
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               O P T I O N  3   => WITHDRAW MONEY                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

op3:
  call checkAccountCreated
  call getPinInput
  call clearScreen

  printString op3mmsg1
  call newLine
  printString op3mmsg2
  call newLine
  printString op3mmsg3
  call newLine
  printString op3mmsg4
  call newLine
  printString op3mmsg5
  call newLine
  call newLine
  call newLine

  printString op4msg1
  call newLine
  printString op4msg2
  call newLine
  printString op4msg3
  call newLine
  printString op4msg4
  call newLine

  call inputAmountCode

  cmp byte [inputAmountOption],'1'
  je wcop1
  cmp byte [inputAmountOption],'2'
  je wcop2
  cmp byte [inputAmountOption],'3'
  je wcop3
  cmp byte [inputAmountOption],'4'
  je wcop4

wcop1:
    mov bx,[totalAmount]
    cmp bx,1000
    jl nowaybro
    sub word [totalAmount],1000
    jmp mainloop
wcop2:
    mov bx,[totalAmount]
    cmp bx,2000
    jl nowaybro
    sub word [totalAmount],2000
    jmp mainloop
wcop3:
    mov bx,[totalAmount]
    cmp bx,5000
    jl nowaybro
    sub word [totalAmount],5000
    jmp mainloop
wcop4:
    mov bx,[totalAmount]
    cmp bx,10000
    jl nowaybro
    sub word [totalAmount],10000
    jmp mainloop

nowaybro:
    call newLine
    call newLine
    printString op4msg6
    call etcop4
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               O P T I O N  4   => DEPOSIT MONEY                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

etcop4:
   call newLine
  .in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp .in
    ret

inputAmountCode:
  call newLine
  printString op4msg5
  mov ah,1
  int 21h
  mov [inputAmountOption],al
  ret

op4:
  call checkAccountCreated
  call getPinInput
  call clearScreen

  printString op4mmsg1
  call newLine
  printString op4mmsg2
  call newLine
  printString op4mmsg3
  call newLine
  printString op4mmsg4
  call newLine
  printString op4mmsg5
  call newLine
  printString op4mmsg6
  call newLine
  call newLine
  call newLine

  printString op4msg1
  call newLine
  printString op4msg2
  call newLine
  printString op4msg3
  call newLine
  printString op4msg4
  call newLine

  call inputAmountCode

  cmp byte [inputAmountOption],'1'
  je dcop1
  cmp byte [inputAmountOption],'2'
  je dcop2
  cmp byte [inputAmountOption],'3'
  je dcop3
  cmp byte [inputAmountOption],'4'
  je dcop4

dcop1:
    add word [totalAmount],1000
    jmp mainloop
dcop2:
    add word [totalAmount],2000
    jmp mainloop
dcop3:
    add word [totalAmount],5000
    jmp mainloop
dcop4:
    add word [totalAmount],10000
    jmp mainloop
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               O P T I O N  5   => RESET ACCOUNT                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

etcop5:
   call newLine
  .in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp .in
    ret

op5:
  call checkAccountCreated
  call getPinInput

  call clearScreen

  mov si,accountName
  mov cx,30
  .l1:
    mov byte [si],' '
    inc si
  loop .l1

  mov cx,30
  mov si,accountPIN
  .l2:
    mov byte [si],' '
    inc si
  loop .l2

  mov word [totalAmount],0
  mov word [accountPINcount],0

  printString op5msg1
  call etcop5
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               O P T I O N  6   => MODIFY ACCOUNT DETAILS          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

etcop6:
   call newLine
  .in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp .in
    ret

op6:
  call checkAccountCreated
  call getPinInput
  call clearScreen

  printString op5mmsg1
  call newLine
  printString op5mmsg2
  call newLine
  printString op5mmsg3
  call newLine
  printString op5mmsg4
  call newLine
  printString op5mmsg5
  call newLine
  printString op5mmsg6
  call newLine
  call newLine
  call newLine

  printString op6msg1_1
  printString accountName
  printString op6msg1_2

  ISop6 accountName

labelop6_1:
    call newLine
    printString op6msg2_1
    printString accountPIN
    printString op6msg2_2
    ISop6_2 accountPIN

labelop6_2:
    call newLine
    call newLine
    printString op6msg0
    call etcop6
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     E N T R Y    P O I N T                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mainloop_init:
mainloop:
        call clearScreen
        call DisplayMenu
        call GetInputMenuSystem

        cmp byte [inputCode],'0'
        je exitprog
        cmp byte [inputCode],'2'
        je op2
        cmp byte [inputCode],'4'
        je op4
        cmp byte [inputCode],'3'
        je op3
        cmp byte [inputCode],'6'
        je op6
        cmp byte [inputCode],'1'
        je op1
        cmp byte [inputCode],'5'
        je op5
        jmp mainloop

exitprog:
      call newLine
      call newLine

      printString op0mmsg1
      call newLine
      printString op0mmsg2
      call newLine
      printString op0mmsg3
      call newLine
      printString op0mmsg4
      call newLine
      printString op0mmsg5
      call newLine
      printString op0mmsg6
      call newLine
      printString op0mmsg7
      call newLine

      call newLine

      mov ah,4ch
      int 21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             D A T A                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dmsg1 db '    ____                 __      _____               __$'
dmsg2 db '   / __ ) ____ _ ____   / /__   / ___/ __  __ _____ / /_ ___   ____ ___$'
dmsg3 db '  / __  |/ __ `// __ \ / //_/   \__ \ / / / // ___// __// _ \ / __ `__ \$'
dmsg4 db ' / /_/ // /_/ // / / // ,<     ___/ // /_/ /(__  )/ /_ /  __// / / / / /$'
dmsg5 db '/_____/ \__,_//_/ /_//_/|_|   /____/ \__, //____/ \__/ \___//_/ /_/ /_/$'
dmsg6 db '                                    /____/$'

op1mmsg1 db '   ______                    __$'
op1mmsg2 db '  / ____/_____ ___   ____ _ / /_ ___$'
op1mmsg3 db ' / /    / ___// _ \ / __ `// __// _ \$'
op1mmsg4 db '/ /___ / /   /  __// /_/ // /_ /  __/$'
op1mmsg5 db '\____//_/    \___/ \__,_/ \__/ \___/$'

op2mmsg1 db '  ____         __          _  __$'
op2mmsg2 db '  / __ \ ___   / /_ ____ _ (_)/ /_____$'
op2mmsg3 db ' / / / // _ \ / __// __ `// // // ___/$'
op2mmsg4 db '/ /_/ //  __// /_ / /_/ // // /(__  )$'
op2mmsg5 db '/_____/ \___/ \__/ \__,_//_//_//____/$'

op3mmsg1 db ' _       __ _  __   __         __$'
op3mmsg2 db '| |     / /(_)/ /_ / /_   ____/ /_____ ____ _ _      __$'
op3mmsg3 db '| | /| / // // __// __ \ / __  // ___// __ `/| | /| / /$'
op3mmsg4 db '| |/ |/ // // /_ / / / // /_/ // /   / /_/ / | |/ |/ /$'
op3mmsg5 db '|__/|__//_/ \__//_/ /_/ \__,_//_/    \__,_/  |__/|__/$'

op4mmsg1 db '    ____                             _  __ $'
op4mmsg2 db '   / __ \ ___   ____   ____   _____ (_)/ /_$'
op4mmsg3 db '  / / / // _ \ / __ \ / __ \ / ___// // __/$'
op4mmsg4 db ' / /_/ //  __// /_/ // /_/ /(__  )/ // /_$'
op4mmsg5 db '/_____/ \___// .___/ \____//____//_/ \__/$'
op4mmsg6 db '            /_/$'

op5mmsg1 db '    __  ___            __ _  ____$'
op5mmsg2 db '   /  |/  /____   ____/ /(_)/ __/__  __$'
op5mmsg3 db '  / /|_/ // __ \ / __  // // /_ / / / /$'
op5mmsg4 db ' / /  / // /_/ // /_/ // // __// /_/ /$'
op5mmsg5 db '/_/  /_/ \____/ \__,_//_//_/   \__, /$'
op5mmsg6 db '                              /____/$'

op0mmsg1 db '   ____   __   __U _____ u$'
op0mmsg2 db 'U | __")u \ \ / /\| ___"|/$'
op0mmsg3 db ' \|  _ \/  \ V /  |  _|"$'
op0mmsg4 db '  | |_) | U_|"|_u | |___$'
op0mmsg5 db '  |____/    |_|   |_____|$'
op0mmsg6 db ' _|| \\_.-,//|(_  <<   >>$'
op0mmsg7 db '(__) (__)\_) (__)(__) (__)$'

opmsg1 db '1. Create new Account$'
opmsg2 db '2. Print Account Details$'
opmsg3 db '3. Withdraw Money $'
opmsg4 db '4. Deposit Money $'
opmsg5 db '5. Reset Account $'
opmsg6 db '6. Modify Account Details$'

opmsg8 db 'Press Enter To Return to Main Menu $'

imsg db 'What Do You Want To Do ? : $'
inputCode db 0

accountName db 100 dup('$')
accountPIN db 100 dup('$')
accountPINcount dw 0
totalAmount dw 0
inputAmountOption db 0

op1msg1 db '1. Enter Account Name: $'
op1msg2 db '2. Enter Account Pin: $'
op1msg3 db 'Successfully Created New Account ! $'

op2msg1 db 'Account Name: $'
op2msg2 db 'Currently Saved Account PIN: $'
op2msg3 db 'No Accounts Currently Saved !$'
op2msg4 db 'Total Money Left: $'
op2msg5 db 'You Have No Money $'

op4msg1 db '1. Php 1000$'
op4msg2 db '2. Php 2000$'
op4msg3 db '3. Php 5000$'
op4msg4 db '4. Php 10000$'
op4msg5 db 'Enter Code: $'
op4msg6 db 'You Are Withdrawing Too MUCH !$'

op5msg1 db 'Account Has been reset successfully$'

op6msg0   db 'Account Details Successfully Changed !$'
op6msg1_1 db '1. New Account Name ( old: $'
op6msg1_2 db ' ) : $'
op6msg2_1 db '2. New Account Pin ( old: $'
op6msg2_2 db ' ) : $'

pinop_msg1 db 'Enter PIN: $'
pinop_msg2 db 'Account NOT created ... $'

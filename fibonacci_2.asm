; fibbonacci
; R0: loop i
; R1, R2, R3: fib(n) calculation

.ORIG x3000

;MARK: main

; setup
LD  R0  N       ; R0 = N

AND R1  R1  #0  ; R1 = 0 (fib(0))
ADD R2  R1  #1  ; R2 = 1 (fib(1))

AND R3  R0  #-1     ; if negative
BRzp NOT_NEGATIVE
    NOT R3  R3      ; make positive
    ADD R0  R3  #1

NOT_NEGATIVE

; MARK: fib

ADD R0  R0  #-1 ; i-- (already handled fib(1))
BRz DONE        ; N was 1, R2 is 1
BRn OVERFLOW    ; N was 0, R1 is 0

LOOP            ; while i > 0
    ADD R3  R1  R2  ; R3 = R1 + R2 (fib(n) = fib(n - 1) + fib(n - 2))
    BRn OVERFLOW    ; break on overflow
    ADD R1  R2  #0  ; R1 = old fib(n - 1)
    ADD R2  R3  #0  ; R2 = fib(n)

    ADD R0  R0  #-1 ; i--
    BRp LOOP        ; until R0 == 0

BR DONE

; cleanup
OVERFLOW            ; used for overflow AND 0 base case
    ADD R2  R1  #0  ; return R1 (the last non overflow fib)

DONE ; R2 holds fib(N)

ST  R2  RESULT  ; Store result

REG

HALT

; MARK: labels

N       .FILL   #24
RESULT  .FILL   #-1

.END

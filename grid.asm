; generate a ~16x16 grid of every block id 0 - 252
; adds a layer of barriers to hold falling blocks

.ORIG x3000

; MARK: main
GETP                   ; R0, R1, R2 = X, Y, Z
ADD R1, R1, #-2        ; Y - 2
ADD R0, R0, #-8        ; center grid x 
ADD R2, R2, #-8        ; center grid z

LD R3, MAX_ID          ; max block id
LD R4, START           ; track offset for grid rows
X_LOOP

    SETB               ; place the block

    ADD R1, R1, #-1    ; move down 1 for barrier

    ADD R6, R3, #0     ; save block id in R6

    LD R3, BARRIER     ; load barrier id
    SETB               ; place the barrier

    ADD R3, R6, #0     ; copy id back into R3

    ADD R1, R1, #1     ; move back up 1

    ADD R5, R4, #-16   ; check if row 16
    BRnp SKIP_POS      ; if not, skip

    ADD R2, R2, #1     ; move Z to next col
    ADD R0, R0, #-16   ; reset X back to start (-16)
    ADD R4, R4, #-16   ; reset offset X back to start

    SKIP_POS

    ADD R4, R4, #1     ; add 1 to offset
    ADD R0, R0, #1     ; add 1 to X
    ADD R3, R3, #-1    ; sub 1 from id 

BRp X_LOOP             ; loop while positive

HALT

; MARK: labels
MAX_ID  .FILL #252     ; max block id
START   .FILL #0       ; for counting
BARRIER .FILL #166     ; barrier block id

.END
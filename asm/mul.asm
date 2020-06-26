                section         .text

                global          _start

_start:

                sub             rsp, 6 * 256 * 8

                lea             r8, [rsp + 3 * 256 * 8]
                lea             r9, [rsp + 4 * 256 * 8]
                lea             r12, [rsp + 5 * 256 * 8]
                lea             rdi, [rsp + 2 * 256 * 8]
                mov             rcx, 256
                call            read_long
                lea             rdi, [rsp + 256 * 8]
                call            read_long
                lea             rsi, [rsp + 2 * 256 * 8]
                call            mul_long_long

                call            write_long

                mov             al, 0x0a
                call            write_char

                jmp             exit


; adds two long number
;    rdi -- address of summand #1 (long number)
;    rsi -- address of summand #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    sum is written to rdi
add_long_long:
                push            rdi
                push            rsi
                push            rcx

                clc
.loop:
                mov             rax, [rsi]
                lea             rsi, [rsi + 8]
                adc             [rdi], rax
                lea             rdi, [rdi + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rsi
                pop             rdi
                ret


; multiplies two long number
;    rdi -- address of multiplier #1 (long number)
;    rsi -- address of multiplier #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    product is written to rdi
mul_long_long:
                push            rax
                push            rdi
                push            rsi
                push            rcx
                mov             r10, rcx
                call            copy_rdi_to_r8
                call            copy_rsi_to_r9
                xor             r13, r13

                clc

.loop:
                mov             rbx, [r9]
                lea             r9, [r9 + 8]
                call            copy_r8_to_rdi
                call            mul_long_short
                call            copy_r12_to_rsi
                call            shift
                call            add_long_long
                call            copy_rdi_to_r12
                lea             r13, [r13 + 1]
                dec             r10
                jnz             .loop

                call            copy_r12_to_rdi
                pop             rcx
                pop             rsi
                pop             rdi
                pop             rax
                ret

; shifts rdi to left
;    rdi -- address of original long number
;    r13 -- number of shifts
; result:
;    result is writen to rdi
shift:
                push            rdi
                push            rcx
                push            r13
                lea             rcx, [r13]
                mov             rbx, 4294967296
                cmp             rcx, 0
                je              end_shift
.loop:
                lea             r13, [rcx]
                mov             rcx, 256
                call            mul_long_short
                call            mul_long_short
                lea             rcx, [r13]
                dec             rcx

                jnz             .loop

end_shift:
                pop             r13
                pop             rcx
                pop             rdi
                ret


; copies a long number
;    rdi -- address of long number to copy
;    r8 -- address of long number to copy to
copy_rdi_to_r8:
                push            rdi
                push            r8
                push            rcx
.loop:
                mov             rax, [rdi]
                lea             rdi, [rdi + 8]
                mov             [r8], rax
                lea             r8, [r8 + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             r8
                pop             rdi
                ret

; copies a long number
;    rsi -- address of long number to copy
;    r9 -- address of long number to copy to
copy_rsi_to_r9:
                push            rsi
                push            r9
                push            rcx
.loop:
                mov             rax, [rsi]
                lea             rsi, [rsi + 8]
                mov             [r9], rax
                lea             r9, [r9 + 8]
                dec             rcx
                jnz             .loop


                pop             rcx
                pop             r9
                pop             rsi
                ret

; copies a long number
;    r8 -- address of long number to copy
;    rdi -- address of long number to copy to
copy_r8_to_rdi:
                push            r8
                push            rdi
                push            rcx
.loop:
                mov             rax, [r8]
                lea             r8, [r8 + 8]
                mov             [rdi], rax
                lea             rdi, [rdi + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rdi
                pop             r8
                ret

; copies a long number
;    r12 -- address of long number to copy
;    rsi -- address of long number to copy to
copy_r12_to_rsi:
                push            r12
                push            rsi
                push            rcx
.loop:
                mov             rax, [r12]
                lea             r12, [r12 + 8]
                mov             [rsi], rax
                lea             rsi, [rsi + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rsi
                pop             r12
                ret

; copies a long number
;    rdi -- address of long number to copy
;    r12 -- address of long number to copy to
copy_rdi_to_r12:
                push            rdi
                push            r12
                push            rcx
.loop:
                mov             rax, [rdi]
                lea             rdi, [rdi + 8]
                mov             [r12], rax
                lea             r12, [r12 + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             r12
                pop             rdi
                ret

; copies a long number
;    r12 -- address of long number to copy
;    rdi -- address of long number to copy to
copy_r12_to_rdi:
                push            r12
                push            rdi
                push            rcx
.loop:
                mov             rax, [rdi]
                lea             rdi, [rdi + 8]
                mov             [r12], rax
                lea             r12, [r12 + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rdi
                pop             r12
                ret


; adds 64-bit number to long number
;    rdi -- address of summand #1 (long number)
;    rax -- summand #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    sum is written to rdi
add_long_short:
                push            rdi
                push            rcx
                push            rdx

                xor             rdx,rdx
.loop:
                add             [rdi], rax
                adc             rdx, 0
                mov             rax, rdx
                xor             rdx, rdx
                add             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rdx
                pop             rcx
                pop             rdi
                ret

; multiplies long number by a short
;    rdi -- address of multiplier #1 (long number)
;    rbx -- multiplier #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
mul_long_short:
                push            rax
                push            rdi
                push            rcx
                push            rsi

                xor             rsi, rsi
.loop:
                mov             rax, [rdi]
                mul             rbx
                add             rax, rsi
                adc             rdx, 0
                mov             [rdi], rax
                add             rdi, 8
                mov             rsi, rdx
                dec             rcx
                jnz             .loop

                pop             rsi
                pop             rcx
                pop             rdi
                pop             rax
                ret

; divides long number by a short
;    rdi -- address of dividend (long number)
;    rbx -- divisor (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    quotient is written to rdi
;    rdx -- remainder
div_long_short:
                push            rdi
                push            rax
                push            rcx

                lea             rdi, [rdi + 8 * rcx - 8]
                xor             rdx, rdx

.loop:
                mov             rax, [rdi]
                div             rbx
                mov             [rdi], rax
                sub             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rax
                pop             rdi
                ret

; assigns a zero to long number
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
set_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep stosq

                pop             rcx
                pop             rdi
                pop             rax
                ret

; checks if a long number is a zero
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
; result:
;    ZF=1 if zero
is_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep scasq

                pop             rcx
                pop             rdi
                pop             rax
                ret

; read long number from stdin
;    rdi -- location for output (long number)
;    rcx -- length of long number in qwords
read_long:
                push            rcx
                push            rdi

                call            set_zero
.loop:
                call            read_char
                or              rax, rax
                js              exit
                cmp             rax, 0x0a
                je              .done
                cmp             rax, '0'
                jb              .invalid_char
                cmp             rax, '9'
                ja              .invalid_char

                sub             rax, '0'
                mov             rbx, 10
                call            mul_long_short
                call            add_long_short
                jmp             .loop

.done:
                pop             rdi
                pop             rcx
                ret

.invalid_char:
                mov             rsi, invalid_char_msg
                mov             rdx, invalid_char_msg_size
                call            print_string
                call            write_char
                mov             al, 0x0a
                call            write_char

.skip_loop:
                call            read_char
                or              rax, rax
                js              exit
                cmp             rax, 0x0a
                je              exit
                jmp             .skip_loop

; write long number to stdout
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
write_long:
                push            rax
                push            rcx

                mov             rax, 20
                mul             rcx
                mov             rbp, rsp
                sub             rsp, rax

                mov             rsi, rbp

.loop:
                mov             rbx, 10
                call            div_long_short
                add             rdx, '0'
                dec             rsi
                mov             [rsi], dl
                call            is_zero
                jnz             .loop

                mov             rdx, rbp
                sub             rdx, rsi
                call            print_string

                mov             rsp, rbp
                pop             rcx
                pop             rax
                ret

; read one char from stdin
; result:
;    rax == -1 if error occurs
;    rax \in [0; 255] if OK
read_char:
                push            rcx
                push            rdi

                sub             rsp, 1
                xor             rax, rax
                xor             rdi, rdi
                mov             rsi, rsp
                mov             rdx, 1
                syscall

                cmp             rax, 1
                jne             .error
                xor             rax, rax
                mov             al, [rsp]
                add             rsp, 1

                pop             rdi
                pop             rcx
                ret
.error:
                mov             rax, -1
                add             rsp, 1
                pop             rdi
                pop             rcx
                ret

; write one char to stdout, errors are ignored
;    al -- char
write_char:
                sub             rsp, 1
                mov             [rsp], al

                mov             rax, 1
                mov             rdi, 1
                mov             rsi, rsp
                mov             rdx, 1
                syscall
                add             rsp, 1
                ret

exit:
                mov             rax, 60
                xor             rdi, rdi
                syscall

; print string to stdout
;    rsi -- string
;    rdx -- size
print_string:
                push            rax

                mov             rax, 1
                mov             rdi, 1
                syscall

                pop             rax
                ret


                section         .rodata
invalid_char_msg:
                db              "Invalid character: "
invalid_char_msg_size: equ             $ - invalid_char_msg


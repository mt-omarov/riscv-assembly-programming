.section .text
.global main

main:
    # Пролог функции
    addi sp, sp, -40    # Выделение места для канарейки (4 байта) и буфера (8 байт)
    sw ra, 36(sp)       # Сохранение адреса возврата
    sw s0, 32(sp)       # Сохранение s0

    # Установка канарейки
    li t0, 0xDEADBEEF   # Фиксированное значение канарейки
    sw t0, 32(sp)       # Сохранение канарейки сразу после s0

    # Выделить буфер на стеке (8 байт)
    mv s0, sp           # s0 указывает на начало буфера (смещение 0 от текущего sp)

    # Вывести приглашение для ввода
    la a0, prompt
    call puts

    # Читать ввод в буфер с помощью read (ограничим длину до 8 байт)
    li a7, 63           # Системный вызов read
    li a0, 0            # Файловый дескриптор stdin
    mv a1, s0           # Адрес буфера
    li a2, 8            # Максимальная длина, равная размеру буфера
    ecall

    # Вывести введённые данные
    mv a0, s0
    call puts

    # Проверка канарейки
    lw t0, 32(sp)       # Загрузка сохраненной канарейки
    li t1, 0xDEADBEEF   # Ожидаемое значение канарейки
    bne t0, t1, error   # Если канарейки не совпадают, переход к ошибке

    # Эпилог функции
    lw s0, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40
    # Выход из программы
    li a7, 93           # Системный вызов exit
    li a0, 0            # Код возврата 0
    ecall

error:
    # Завершение с ошибкой при обнаружении атаки
    la a0, error_msg
    call puts
    # Явное прерывание для сброса ввода (используем бесконечный цикл)
    infinite_loop:
        j infinite_loop

.section .rodata
prompt: .string "Enter input: "
error_msg: .string "Buffer overflow detected!"

# Внешние функции из libc
.global puts

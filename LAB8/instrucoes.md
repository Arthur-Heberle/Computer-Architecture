# Instruções do Processador

## Formato da Instrução (15 bits)

```
[14:11] opcode   
[10:8]  Rd       
[7:5]   Rs1      
[4:2]   Rs2      
[4:0]   cte5     (constante de 5 bits, complemento de 2)
[6:0]   addr7    (endereço absoluto 7 bits — BLE, BCC, DJNZ)
[6:0]   offset7  (offset relativo 7 bits — JMP)
```

## Tabela de Opcodes

| Opcode | Nome      | Operandos          | Operação                              | 
|--------|-----------|--------------------|---------------------------------------| 
| 0000   | NOP       | —                  | nenhuma                               | 
| 0001   | LD        | Rd, cte5           | Rd = zero_ext(cte5)                   |
| 0010   | ADD       | Rd, Rs1, Rs2       | Rd = Rs1 + Rs2                        |
| 0011   | SUBI      | Rd, Rs1, cte5      | Rd = Rs1 − sign_ext(cte5)             |
| 0100   | MOV       | Rd, Rs1            | Rd = Rs1                              | 
| 0101   | BLE       | addr7              | se BLE=1: PC = addr7                  |
| 0110   | BCC       | addr7              | se BCC=1: PC = addr7                  |
| 0111   | SW        | Rs_addr, Rs_data   | RAM[Rs_addr] = Rs_data                |
| 1000   | LW        | Rd, Rs_addr        | Rd = RAM[Rs_addr]                     |
| 1001   | DJNZ      | Rd, addr7          | Rd = Rd − 1; se Rd !=0: PC = addr7      |
| 1111   | JMP       | offset7            | PC = PC_atual + offset7               |

## Programa em C (inspiração)

```c
//parte 1
for (i = 1; i < 33; i++) primos[i] = i;

//parte 2
for (i = 2; i < 33; i++)
    for (j = i; j + i < 33; j += i)
        primos[i + j] = 0;
//parte 3
for (i = 2; i < 33; i++)
    if (primos[i] != 0) print primos[i];
```

## Assembly do Crivo

```
 - setup

LD R0, 1
LD R7, 0
LD R4, 0
SUBI R4,R4,15 
SUBI R4,R4,15  
SUBI R4,R4,2   -> R4 = -32 pq a cte tem no max 4 bits 

parte 1 - preenche RAM[1..32] = 1..32
LD R6, 1
LD R5, 31  
SUBI R5,R5,-1    -- contador = 32

preenche:
 SW R6, R6        -- RAM[R6] = R6
 ADD R6, R6, R0   -- R6++
DJNZ R5, preenche

 - parte 2 - crivo
LD R2, 2           -- i = 2
LD R5, 31          -- i vai de 2 a 32

loop_fora:
  ADD R6, R2, R2   -- k = i+i (primeiro multiplo)
loop_dentro:
  ADD R3, R6, R4     -- R3 = k - 32 (atualiza flag BLE)
  BLE nao_primos     -- se k <= 32 entra no corpo
  JMP saida_loop_dentro     -- senão sai do laço interno
nao_primos: -- (vai zerando os multiplos de i)
  SW R6, R7          -- RAM[k] = 0
  ADD R6, R6, R2     -- k += i
  JMP loop_dentro
saida_loop_dentro:
  ADD R2, R2, R0   -- i++
  DJNZ R5, loop_fora -- se não chegou em 32, repete

 - parte 3 - lê e mostra RAM[2..32] (zero = não-primo)
LD R6, 2
LD R5, 31
loop_read:
  LW R1, R6          -- R1 = RAM[R6]
  ADD R1, R1, R7   -- manda R1 para a saida da ULA
  ADD R6, R6, R0   -- R6++
  DJNZ R5, loop_read
JMP -1             -- trava aqui (loop infinito)
```

- Se colocar pra ver q_r1 vai conseguir ver os primos
- Perdão pelo atraso de entrega professor
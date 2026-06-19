# Instruções do Processador — Arquitetura 15 bits

## Formato da Instrução (15 bits)

```
[14:11] opcode   (4 bits)
[10:8]  Rd       (registrador destino)
[7:5]   Rs1      (registrador fonte 1)
[4:2]   Rs2      (registrador fonte 2)
[4:0]   cte5     (constante de 5 bits, complemento de 2)
[6:0]   addr7    (endereço absoluto 7 bits — BLE, BCC, DJNZ)
[6:0]   offset7  (offset relativo 7 bits — JMP)
```

## Registradores

| Código | Nome |
|--------|------|
| 000    | R0   |
| 001    | R1   |
| 010    | R2   |
| 011    | R3   |
| 100    | R4   |
| 101    | R5   |
| 110    | R6   |
| 111    | R7   |

## Tabela de Opcodes

| Opcode | Mnemônico | Operandos          | Operação                              | Atualiza flags |
|--------|-----------|--------------------|---------------------------------------|----------------|
| 0000   | NOP       | —                  | nenhuma                               | não            |
| 0001   | LD        | Rd, cte5           | Rd ← zero_ext(cte5)                   | não            |
| 0010   | ADD       | Rd, Rs1, Rs2       | Rd ← Rs1 + Rs2                        | sim            |
| 0011   | SUBI      | Rd, Rs1, cte5      | Rd ← Rs1 − sign_ext(cte5)             | sim            |
| 0100   | MOV       | Rd, Rs1            | Rd ← Rs1                              | não            |
| 0101   | BLE       | addr7              | se BLE=1: PC ← addr7                  | não            |
| 0110   | BCC       | addr7              | se BCC=1: PC ← addr7                  | não            |
| 0111   | SW        | Rs_addr, Rs_data   | RAM[Rs_addr] ← Rs_data                | não            |
| 1000   | LW        | Rd, Rs_addr        | Rd ← RAM[Rs_addr]                     | não            |
| 1001   | DJNZ      | Rd, addr7          | Rd ← Rd − 1; se Rd≠0: PC ← addr7      | sim            |
| 1111   | JMP       | offset7            | PC ← PC_atual + offset7               | não            |
 
## Flags

| Flag | Condição de ativação (BLE=1 / BCC=1)          | Usada por |
|------|-----------------------------------------------|-----------|
| BLE  | Z=1 **ou** N≠V  (resultado ≤ 0 com sinal)    | BLE       |
| BCC  | C=0  (sem carry/borrow não sinalizado)         | BCC       |

Flags são atualizadas apenas por **ADD**, **SUBI** e **DJNZ**.

## Codificação por Instrução

### LD Rd, cte5
```
[14:11]=0001  [10:8]=Rd  [7:5]=000  [4:0]=cte5
```
Exemplo — `LD R1, 15`:  `0001 001 000 01111`

### ADD Rd, Rs1, Rs2
```
[14:11]=0010  [10:8]=Rd  [7:5]=Rs1  [4:2]=Rs2  [1:0]=00
```
Exemplo — `ADD R4, R1, R3`:  `0010 100 001 011 00`

### SUBI Rd, Rs1, cte5
```
[14:11]=0011  [10:8]=Rd  [7:5]=Rs1  [4:0]=cte5
```
Exemplo — `SUBI R5, R4, 5`:  `0011 101 100 00101`  
Exemplo — `SUBI R6, R6, -1`: `0011 110 110 11111`

### MOV Rd, Rs1
```
[14:11]=0100  [10:8]=Rd  [7:5]=Rs1  [4:0]=00000
```
Exemplo — `MOV R7, R5`:  `0100 111 101 00000`

### BLE addr7 / BCC addr7
```
[14:11]=0101/0110  [10:7]=0000  [6:0]=addr7
```
Exemplo — `BLE 11`:  `0101 0000 0001011`  
Exemplo — `BCC 6`:   `0110 0000 0000110`

### SW Rs_addr, Rs_data
```
[14:11]=0111  [10:8]=Rs_addr  [7:5]=Rs_data  [4:0]=00000
```
Exemplo — `SW R3, R4`:  `0111 011 100 00000`

### LW Rd, Rs_addr
```
[14:11]=1000  [10:8]=Rd  [7:5]=Rs_addr  [4:0]=00000
```
Exemplo — `LW R5, R3`:  `1000 101 011 00000`

### DJNZ Rd, addr7
```
[14:11]=1001  [10:8]=Rd  [7]=0  [6:0]=addr7
```
Exemplo — `DJNZ R3, 19`:  `1001 011 0 0010011`

### JMP offset7
```
[14:11]=1111  [10:7]=1111  [6:0]=offset7
```
`target = JMP_addr + offset7`  (offset em complemento de 2)

Exemplo — `JMP +2`:   `1111 1111 0000010`  (salta 2 à frente)  
Exemplo — `JMP -1`:   `1111 1111 1111111`  (loop infinito)

## Exceção de Endereço Inválido

Dispara quando PC = 127 e o processador tenta incrementar para 128.  
Efeito: `wr_en_pc` bloqueado → PC trava em 127 → `exception_o = '1'` permanentemente.

## Notas de Pipeline

- 3 estados por instrução: **00** fetch → **01** decode/PC+1 → **10** execute
- Desvios tomados (BLE, BCC, JMP, DJNZ) inserem 1 NOP automático via flush
- Endereços absolutos em BLE/BCC/DJNZ requerem `addr-1` internamente (compensado pelo hardware)

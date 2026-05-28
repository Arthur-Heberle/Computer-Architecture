make          # compila e simula tudo de uma vez
make wave     # abre o GTKWave com o resultado
make clean    # remove arquivos gerados

## Teste Branch

end  0: LD   R3, 5
end  1: LD   R4, 8
end  2: ADD  R5, R3, R4   (passo C, alvo do loop)
end  3: SUBI R5, R5, 1    (passo D)
end  4: JMP  +15          (passo E, salta para end 20)
end  5: LD   R5, 0        (passo F, NUNCA executado)
end 20: MOV  R3, R5       (passo G)
end 21: JMP  -20          (passo H, volta para end 2)
end 22: LD   R3, 0        (passo I, NUNCA executado)


## O que inserir no ghw gerado

Para visualizar o teste branch, de append nos seguintes sinais:

rst
clk
estado_o     <- deve ciclar 0,1,2,0,1,2,...
pc_o         <- muda no estado 1
instr_o      <- estabiliza no estado 0
ula_out_o    <- resultado da ULA
q_r3         <- deve ser 5, depois 12, 19, 26,...
q_r4         <- deve ser sempre 8
q_r5         <- deve ser 12, 19, 26, 33, 40,...

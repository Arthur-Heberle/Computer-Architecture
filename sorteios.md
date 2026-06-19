# SORTEIOS PARA OS LABORATÓRIOS DE ARQUITETURA DE COMPUTADORES

**A instrução do professor foi:** 
"ADICIONALMENTE, vou querer um outro programa assembly que testa todas as instruções sorteadas para a equipe durante o semestre -- pode ser apenas uma lista de instruções para verificarmos a execução correta."

## LAB 2
- {'Saltos condicionais': ['BLE', 'BCC']}

## LAB 3
- {'Número de registradores no banco': [8],
 'Acumulador ou não': 'ULA com instruções ortogonais'}

- {'ADD ctes': 'ADD apenas entre registradores, nunca com constantes',
 'Subtração': 'Subtração com SUB sem usar borrow',
 'SUB ops': 'Subtração com dois operandos apenas',
 'ADD ops': 'ADD com dois operandos apenas',
 'Carga de constantes': 'Carrega diretamente com LD sem somar',
 'SUB ctes': 'Há instrução que subtrai uma constante',
 'Comparações': 'Não há instruções exclusivas de comparação'} 

## LAB 4
- {'Largura da ROM / tamanho da instrução em bits': [15],
 'Incremento do PC': ['PC+1 gravado entre o primeiro e segundo estado E jmp '
                      'executado no último estado'],
 'Saltos': 'Incondicional é relativo e condicional é absoluto',
 'Leitura da ROM': ['síncrona'],
 'Registrador de Instruções': ['wr_en no primeiro estado']}

## LAB 5
- {'ADD ctes': 'ADD apenas entre registradores, nunca com constantes',
 'Comparações': 'Não há instruções exclusivas de comparação',
 'Largura da ROM / tamanho da instrução em bits': [15],
 'SUB ops': 'Subtração com dois operandos apenas',
 'Acumulador ou não': 'ULA com instruções ortogonais',
 'Registrador de Instruções': ['wr_en no primeiro estado'],
 'ADD ops': 'ADD com dois operandos apenas',
 'SUB ctes': 'Há instrução que subtrai uma constante',
 'Carga de constantes': 'Carrega diretamente com LD sem somar',
 'Subtração': 'Subtração com SUB sem usar borrow',
 'Incremento do PC': ['PC+1 gravado entre o primeiro e segundo estado E jmp '
                      'executado no último estado']}

## LAB 6
- {'Saltos': 'Incondicional é relativo e condicional é absoluto',
 'Saltos condicionais': ['BLE', 'BCC']}

## LAB 7 
- Customização da validação (final do loop e/ou complicação):
['Exceção endereço inválido ROM',
 'Colocar no bus debug um divisor de 983',
 'Loop com DJNZ']

## LAB 8
- Customização da validação (final do loop e/ou complicação):
['Exceção endereço inválido ROM',
 'Colocar no bus debug um divisor de 983',
 'Loop com DJNZ']
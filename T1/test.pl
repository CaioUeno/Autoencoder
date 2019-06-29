:- dynamic objeto/2.

% Fatos: Objetos em cada posicao.
objeto([10,5], limite).
objeto([3,4], sujeira).
objeto([7,2], sujeira).
objeto([7,5], sujeira).
objeto([10,5], sujeira).
objeto([1,1], sujeira).
objeto([5,5], lixeira).
objeto([4,1], dockstation).
objeto([2,1], elevador).
objeto([2,2], elevador).
objeto([2,3], elevador).
objeto([2,4], elevador).
objeto([2,5], elevador).
objeto([9,1], elevador).
objeto([9,2], elevador).
objeto([9,3], elevador).
objeto([9,4], elevador).
objeto([9,5], elevador).
objeto([6,5], parede).
objeto([5,3], parede).
objeto([5,1], parede).
objeto([8,2], parede).
% Carga suportada pelo robô
capacidade(0).
capacidade(1).

% Regras
% Verificar se um elemento pertence a uma lista (retirado do material de apoio)
pertence(Elem, [Elem|_]).
pertence(Elem, [_|Cauda]) :- pertence(Elem, Cauda).

% Concatenar listas (retirado do material de apoio)
concatena([ ], L, L).
concatena([Cabeca|Cauda], L2, [Cabeca|Resultado]) :- concatena(Cauda, L2, Resultado).

% Inverter uma listas (retirado do material de apoio -A Cartilha Prolog-)
inverter(X, Y) :- reverso([], X, Y).
reverso(L, [], L).
reverso(L, [X|Y], Z) :- reverso([X|L], Y, Z).

% Verificar se ou qual é o objeto
verifica([PosX, PosY], Objeto) :-
  bagof(PosObjeto, objeto(PosObjeto, Objeto), ListaObjetos),
  pertence([PosX,PosY], ListaObjetos).

% Obter as casas adjacentes à casa atual
adjacente([X, Y], [NextX, NextY]) :-
  % Válido para todos
  ((NextX is X - 1;
  NextX is X + 1),
  NextY is Y);
  % Apenas para elevadores
  ((NextY is Y - 1;
  NextY is Y + 1),
  NextX is X,
  verifica([X, Y], elevador),
  verifica([NextX, NextY], elevador)).

% Verificar se uma casa é inválida
invalida([X, Y], [MaxX, MaxY]) :-
  X is 0;
  Y is 0;
  X is MaxX + 1;
  Y is MaxY + 1;
  verifica([X, Y], parede).

incrementa(Qtde, Qtde_novo) :- Qtde_novo is Qtde + 1.

% Movimento do robô
movimento([X, Y], [NextX, NextY], [MaxX, MaxY]) :-
  adjacente([X, Y], [NextX, NextY]),
  not(invalida([NextX, NextY], [MaxX, MaxY])).

% Busca em profundidade (retirado do material de apoio -adaptado-)
buscaProfundidade(Estado, EstadoAux, Rota, [EstadoAux|Rota], Objeto) :- meta(Estado, Objeto).
buscaProfundidade(Estado, EstadoAux, Rota, Solucao, Objeto) :-
  objeto(Limite, limite),
  movimento(Estado, Sucessor, Limite),
  not(pertence(Sucessor, [EstadoAux|Rota])),
  buscaProfundidade(Sucessor, Sucessor, [EstadoAux|Rota], Solucao, Objeto).

% Meta: se a posição passada é a posição do objeto buscado
meta(Estado, Objeto) :- verifica(Estado, Objeto).

% Função para encontrar o lixo
encontraObjeto(EstadoInicio, EstadoFim, [EstadoFim|Rota], Objeto) :-
  buscaProfundidade(EstadoInicio, EstadoInicio, [], [EstadoFim|Rota], Objeto).

% Função para procurar até 2 sujeiras (Caso base)
procuraLixo(EstadoInicio, EstadoFim, Rota, Objeto, Qtde) :-
  not(capacidade(Qtde));
  (not(encontraObjeto(EstadoInicio, EstadoFim, Aux, sujeira)),
  Rota = []).

% Função para procurar até 2 sujeiras (Caso recursivo)
procuraLixo(EstadoInicio, EstadoFim, Rota, Objeto, Qtde) :-
  incrementa(Qtde, Qtde_novo),
  encontraObjeto(EstadoInicio, EstadoMedio, RotaLixo, Objeto),
  retract(objeto(EstadoMedio, sujeira)),
  procuraLixo(EstadoMedio, EstadoFim, RotaOutra, Objeto, Qtde_novo),
  concatena(RotaOutra, RotaLixo, Rota),
  pertence(EstadoFim, Rota). % Força unificação de EstadoFim com a cabeça de Rota

% Função para procurar até 2 sujeiras e ir à lixeira (Caso base)
limpaPredio(EstadoInicio, EstadoFim, Rota) :- not(encontraObjeto(EstadoInicio, EstadoFim, Rota, sujeira)).

% Função para procurar até 2 sujeiras e ir à lixeira (Caso recursivo)
limpaPredio(EstadoInicio, EstadoFim, Rota) :-
  procuraLixo(EstadoInicio, EstadoMedio, RotaSujeira, sujeira, 0),
  encontraObjeto(EstadoMedio, EstadoFim, RotaLixeira, lixeira),
  concatena(RotaLixeira, RotaSujeira, Rota1),
  limpaPredio(EstadoFim, EstadoFinal, Rota2),
  concatena(Rota2, Rota1, Rota).

% Função para procurar todos as sujeiras possíveis, ir à lixeira e ir à Dock Station
resolvePredio(EstadoInicio, EstadoFim, Rota) :-
  limpaPredio(EstadoInicio, EstadoMedio, RotaPredio),
  encontraObjeto(EstadoMedio, EstadoFim, RotaDS, dockstation),
  concatena(RotaDS, RotaPredio, RotaAux),
  inverter(RotaAux, Rota),
  nl,
  write('Caminho: '),
  write(Rota),
  !.

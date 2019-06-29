pertence(E,[E|_]).
pertence(E,[_|Cauda]) :- pertence(E,Cauda).

insere_primeiro(E,L,[E|L]).

insere_ultimo(E,[],[E]).
insere_ultimo(E,[H|T],[H|TR]) :- insere_ultimo(E,T,TR).

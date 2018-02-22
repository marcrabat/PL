
%Ex 1.

initial(1).
final(4).
arc(1,2,j).
arc(2,3,a).
arc(3,4,!).
arc(2,1,a).

recognize(I,[State|Path]):- initial(State), r1(State,I,Path).
r1(State,[Caracter|R],[Caracter,Next|Path]):- arc(State,Next,Caracter), r1(Next,R,Path).
r1(State,[],[]):- final(State).
generate(X):-recognize(X).

%Test:
%recognize([j,a,j,a,!],Path), write(Path).


%Ex 2.

rule( n(e) , [n(g),n(e1)],1).
rule( n(e1) , [t(+),n(g),n(e1)],2).
rule( n(e1) , [ ],3).
rule( n(g) , [n(f),n(g1)],4 ).
rule( n(g1) , [t(*),n(f),n(g1)],5 ).
rule( n(g1) , [],6 ).
rule( n(f) , [t('('),n(e),t(')')],7 ).
rule( n(f) , [t(a)],8 ).
rule( n(f) , [t(b)],9 ).
rule( n(f) , [t(c)],10 ).
rule( n(f) , [t(d)],11 ).  

parse([],[],[]).

parse(I,[n(X)|R],[Node|Path]):- rule(n(X),B,Node), append(B,R,R1), parse(I,R1,Path).


parse([t(X)|R1],[t(X)|R2],Path):- parse(R1,R2,Path).

%Test:

%parse([t(a),t(+),t(b)],[n(e)],Path).


%Ex 3.

dict(dic(sal,sel,

    dic(mostaza,moutard,

        void,

        dic(pebre,poivre,void,void)),

    dic(vinagre,vinaigre,void,void))).

   

dic(Name,Value,DicL,DicR).

   

lookup(Name,dic(Name,Value,L,R),Value).


lookup(Name,dic(NameD,ValueD,L,R),Value):- Name @< NameD, lookup(Name,L,Value).


lookup(Name,dic(NameD,ValueD,L,R),Value):- NameD @< Name, lookup(Name,R,Value).


look(Name,Value):-

    dict(D),

    lookup(Name,D,Value).


%Test

%look(mostaza,V).

%look(pebre,V).

%look(vinagre,V).
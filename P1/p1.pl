%%% Per carregar el programa, entres a prolog per terminal amb swipl.
%Amb prolog obert: ['/pathfinselprograma/nomFitxer.pl']


/**
*Ferran Cantariño i Iglesias - 173705
*Marc Rabat Pla - 172808
*/

/**
*Ex 1. A simple parser (output: yes/no)
*1a) What is the language generated by the following grammar?
*/

%Answer: The language generated by this grammar is one which can generate arithmetic operations (with its terms between parentheses if desired) with plus(+) %and product(*) operators with the terminals characters a, b, c & d. (Whereas not very relevant, it is also possible to generate uniquely the terminal %characters)

% Examples of the descripted language: 
% ( a + b * c ) * ( c * a ) + b + d
% ( c * b ) + a*c 
% a
% b

/**
*1b) Top-Down Parser
*/

%Facts of the grammar

rule( n(e) , [n(g),n(e1)]).
rule( n(e1) , [t(+),n(g),n(e1)]).
rule( n(e1) , [ ]).
rule( n(g) , [n(f),n(g1)] ).
rule( n(g1) , [t(*),n(f),n(g1)] ).
rule( n(g1) , [ ] ).
rule( n(f) , [t('('),n(e),t(')')] ).
rule( n(f) , [t(a)] ).
rule( n(f) , [t(b)] ).
rule( n(f) , [t(c)] ).
rule( n(f) , [t(d)] ).

%Parser
parse([],[]).
parse(Input,[n(X)|Stack]):- rule(n(X),R), append(R,Stack,NStack), parse(Input,NStack).
parse([t(W)|NStack],[t(W)|R2]):- parse(NStack,R2).


%%Per provar-ho, prova els exemples de sota.

%Functioning tests:
%parse([t(+),t(a),t(b)],[n(e)]). Outputs: False
%parse([t(a),t(+),t(b)],[n(e)]). Outputs: True
%parse([t('('),t(a),t(+),t(b),t(')'),t(*),t(c)],[n(e)]). Outputs: True
%For the Examples:
%( a + b * c ) * ( c * a ) + b + d
%parse([t('('),t(a),t(+),t(b),t(*), t(c), t(')'),t(*),t('('),t(c), t(*),t(a),t(')'), t(+),t(b), t(+),t(d)],[n(e)]). Outputs: True
% ( c * b ) + a*c
%parse([t('('), t(c),t(*),t(b), t(')'), t(+),t(a),t(*),t(c)],[n(e)]). Outputs: True
%a
%parse([t(a)],[n(e)]). Outputs: True


/**
*Ex 2. A simple automata.
*/

/**Represent the following finite automata in Prolog. Use predicates initial/1, final/1 y arc/3. For
*instance arc(1,2,j) represents the first arc. Write predicates for recognizing strings (for instance
*Prolog must respond ‘yes’ to recognize([j,a,j,a,!]) ) and generating the accepted strings by the
*automata (for intance generate(X) must return in X one at a time the strings generated by the
*automata by pressing ‘;’).
*/

initial(1).
final(4).
arc(1,2,j).
arc(2,3,a).
arc(3,4,!).
arc(2,1,a).

%%%%% A partir d'aqui, arreglar noms variables
%Prova: recognize([j,a,j,a,!]).
%En teoria dps de pitjar ; t'hauria de dir els passos que ha seguit, no ho fa.
recognize(I):-
    initial(N),
    r1(N,I).


r1(N,[X|R]):-
    arc(N,I,X),
    r1(I,R).

r1(N,[]):-
    final(N).



generate(X):-
    recognize(X).
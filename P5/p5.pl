/**
*Ferran Cantariño i Iglesias - 173705
*Marc Rabat Pla - 172808
*/

%First of all, we take advantage of the tree declared in P2 and P3, as with it we could look up for the memory adresses where the variables will be mapped.

lookup(Name,dic(Name,Value,L,R),Value).

lookup(Name,dic(X,D,L,R),Value):- Name @< X, lookup(Name,L,Value).

lookup(Name,dic(X,D,L,R),Value):- X @< Name, lookup(Name,R,Value).

%Here is the declaration of the instructions operation with constant and operation in order that the compiler can map them.

opc(+,addc).
opc(-,subc).
opc(*,mulc).
opc(/,divc).

opx(+,add).
opx(-,sub).
opx(*,mul).
opx(/,div).

%We add here the operations of control transfer.

opj(=,jumpne).
opj(<, jumpge).
opj(>, jumplt).


%encodeexpr loads the const or the var. 

%When loading a const, what is done is take its value and map it to the instruction loadc.
encodeexpr(const(X),_,instr(loadc,X)). 

%When loading a var, what is done is search within the dictionary D at what position the var is located. 
encodeexpr(name(X),D,instr(load,Addr)):- lookup(X,D,Addr).

%encodeexpr maps the operations and its symbols
encodeexpr(expr(Op,Expr,const(Y)),D,(Ins;instr(Type,Y))):-encodeexpr(Expr,D,Ins),opc(Op,Type).
encodeexpr(expr(Op,Expr,name(Y)),D,(Ins;instr(Type,Addr))):-encodeexpr(Expr,D,Ins),opx(Op,Type),lookup(Y,D,Addr).

%Converting "if" expression into assembly language using Ecode. Ecode allow us to return its codification
%to assembly code. The substraction operation between Arg1 and Arg2 is it done in order to compare the result
%with 0, >0 and <0.
encodetest( test(OpJ,Arg1,Arg2),D,JumpLabel, (Ecode; instr(Type,JumpLabel)) ) :- encodeexpr(expr(-,Arg1,Arg2),D, Ecode), opj(OpJ, Type).

%The following function receives as input an expression like "name = name + a"
%It will outputs the memory @ in the dictionary and its translation to assembly language
encodestatement(assign(name(X),Expr),D,(E_code;instr(store,Addr ))):-lookup(X,D,Addr),encodeexpr(Expr,D,E_code).

%% if encoding
encodestatement(if(Test,Then,Else),D,(Testcode;Thencode;instr(jump,L2);label(L1);Elsecode;label(L2))):-
		encodetest(Test,D,L1,Testcode),
		encodestatement(Then,D,Thencode),
		encodestatement(Else,D,Elsecode).

%% while encoding

encodestatement(while(Test,Then),D,(label(L2);Testcode;Thencode;instr(jump,L2);label(L1))):-
		encodetest(Test,D,L1,Testcode),
		encodestatement(Then,D,Thencode).

%%input encoding

encodestatement( read(name(X)),D, instr(read,Addr) ) :- lookup(X,D,Addr).

%%output encoding

encodestatement( write(Expr),D, (Ecode; instr(write,0)) ) :- encodeexpr(Expr,D,Ecode).

%%sequence statement encoding

encodestatement((S1;S2),D,(Code1;Code2)) :-	encodestatement(S1,D,Code1), encodestatement(S2,D,Code2).

%translation of the source program

compile(Source, (Code; instr(halt,0); block(L)) ) :-
	encodestatement(Source,D,Code),
	assemble(Code,1,N0),
	N1 is N0+1,
	allocate(D,N1,N),
	print_instr(Code),
	L is N-N1.
	%write('halt'), write(' '), write('0'), nl,
	%write('block'), write(' '), write('1'), nl.

%Assembling a sequence of things

assemble((Code1;Code2),N0,N):- assemble(Code1,N0,N1), assemble(Code2,N1,N).

%Assembling a single instruction

assemble(instr(_,_),N0,N):- N is N0+1.

%Assembling a label

assemble(label(N),N,N).

%Code to allocate
allocate(void,N,N):- !.
allocate(dic(Name,N1,Before,After),N0,N):-
	allocate(Before,N0,N1),
	N2 is N1+1,
	allocate(After,N2,N).


%Printing in a friendly way

print_instr(label(N)):- write('       label:'), write(N), nl. 
print_instr(instr(I,N)) :- write('instr. '), write(I), write(' '), write(N), nl . 
print_instr((Code1;Code2)) :- print_instr(Code1), print_instr(Code2).

%%%%%%%%%%
%TESTING:%
%%%%%%%%%%

%compile(if(test(=,name(x),const(5)),assign(name(x),const(1)), assign(name(x),const(2))),C).
%%Outputs:
%	const(2))),C).
%	instr.: load 10
%	instr.: subc 5
%	instr.: jumpne 7
%	instr.: loadc 1
%	instr.: store 10
%	instr.: jump 9
%	label:7
%	instr.: loadc 2
%	instr.: store 10
%	label:9
%	C = ((((instr(load, 10);instr(subc, 5));instr(jumpne, 7)); (instr(loadc, 1);instr(store, 10));instr(jump, 9);label(7); (instr(loadc, 2);instr(store, 10));label(9));instr(halt, 0);block(1)) .

%compile(while(test(=,name(x),const(5)),assign(name(x),expr(+,name(x),const(1)))),C).
%%Outputs:
%	label:1
%	instr.: load 9
%	instr.: subc 5
%	instr.: jumpne 8
%	instr.: load 9
%	instr.: addc 1
%	instr.: store 9
%	instr.: jump 1
%	label:8
%	C = ((label(1); ((instr(load, 9);instr(subc, 5));instr(jumpne, 8)); ((instr(load, 9);instr(addc, 1));instr(store, 9));instr(jump, 1);label(8));instr(halt, 0);block(1)) .


%compile((read(name(v));assign(name(c),const(1));assign(name(r),const(1));while(test(<,name(c),name(v)),
%assign( name(c),expr(+,name(c),const(1)));assign(name(r),expr(*,name(r),name(c))));write(name(r))),C).
%%Outputs: (we print only the pretty printed output, too large)
%	instr.: read 21
%	instr.: loadc 1
%	instr.: store 19
%	instr.: loadc 1
%	instr.: store 20
%	label:6
%	instr.: load 19
%	instr.: sub 21
%	instr.: jumpge 16
%	instr.: load 19
%	instr.: addc 1
%	instr.: store 19
%	instr.: load 20
%	instr.: mul 19
%	instr.: store 20
%	instr.: jump 6
%	label:16
%	instr.: load 20
%	instr.: write 0





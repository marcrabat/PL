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


%%%%%%%%%%
%TESTING:%
%%%%%%%%%%

%encodestatement(if(test(=,name(x),const(5)), assign(name(x),const(1)), assign(name(x),const(2))),D,X).
%%Outputs:
%D = dic(x, _G1368, _G1372, _G1373),
%X = (((instr(load, _G1368);instr(subc, 5));instr(jumpne, _G1344)); (instr(loadc, 1);instr(store, _G1368));instr(jump, _G1339);label(_G1344); (instr(loadc, 2);instr(store, _G1368));label(_G1339)) .

%encodestatement(while(test(=,name(x),const(5)),assign(name(x),expr(+,name(x),const(1)))),D,X).
%%Outputs:
%D = dic(x, _G1361, _G1365, _G1366),
%X = (label(_G1328); ((instr(load, _G1361);instr(subc, 5));instr(jumpne, _G1342)); ((instr(load, _G1361);instr(addc, 1));instr(store, _G1361));instr(jump, _G1328);label(_G1342)) .

%encodestatement((read(name(x));write(expr(+,name(x),const(1)))),D,X.
%%Outputs:
%D = dic(x, _G1315, _G1319, _G1320),
%X = (instr(read, _G1315); (instr(load, _G1315);instr(addc, 1));instr(write, 0)) .
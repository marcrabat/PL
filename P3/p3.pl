/**
*Ferran Cantariño i Iglesias - 173705
*Marc Rabat Pla - 172808
*/

%First of all, we take advantage of the tree declared in P2, as with it we could look up for the memory adresses where the variables will be mapped.

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


%encodeexpr loads the const or the var. 

%When loading a const, what is done is take its value and map it to the instruction loadc.
encodeexpr(const(X),_,instr(loadc,X)). 

%When loading a var, what is done is search within the dictionary D at what position the var is located. 
encodeexpr(name(X),D,instr(load,Addr)):- lookup(X,D,Addr).

%encodeexpr maps the operations and its symbols
encodeexpr(expr(Op,Expr,const(Y)),D,(Ins;instr(Type,Y))):-encodeexpr(Expr,D,Ins),opc(Op,Type).
encodeexpr(expr(Op,Expr,name(Y)),D,(Ins;instr(Type,Addr))):-encodeexpr(Expr,D,Ins),opx(Op,Type),lookup(Y,D,Addr).


%The following function receives as input an expression like "name = name + a"
%It will outputs the memory @ in the dictionary and its translation to assembly language
encodestatement(assign(name(X),Expr),D,(E_code;instr(store,Addr ))):-lookup(X,D,Addr),encodeexpr(Expr,D,E_code).

%%%%%%%%%%
%TESTING:%
%%%%%%%%%%

%encodestatement(assign(name(x),const(a)),D,X).
%%Outputs:
%D = dic(x, _G913, _G917, _G918),
%X = (instr(loadc, a);instr(store, _G913))


%encodestatement(assign(name(x),name(y)),D,X).
%%Outputs:
%D = dic(x, _G913, _G917, dic(y, _G921, _G925, _G926)),
%X = (instr(load, _G921);instr(store, _G913))

%encodestatement(assign(name(x),expr(+,name(x),const(a))),D,X).
%%Outputs:
%D = dic(x, _G1068, _G1072, _G1073),
%X = ((instr(load, _G1068);instr(addc, a));instr(store, _G1068))

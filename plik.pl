rank(0). rank(1). rank(2). rank(3). rank(4). rank(5).
rank(_) :- !, fail. %ranks are 0-5 only
file(0). file(1). file(2). file(3). file(4). file(5). file(6). file(7).
file(8). file(9). file(10). file(11). file(12). file(13). file(14). file(15).
file(16). file(17). file(18). file(19). file(20). file(21). file(22). file(23).
file(_) :- !, fail. %files are 0-23 only
pos(Rank,File) :- rank(Rank), file(File).
pos([Rank,File]) :- pos(Rank,File).

figtype(pawn). figtype(rook). figtype(knight). figtype(bishop). figtype(king). figtype(queen).
color(white). color(gray). color(black).
is_fig(fig(X,Y)) :- figtype(Y), color(X).
is_fig(fig(X,pawn,crossed)) :- color(X).
empty_square(none).
square(none).
square(X) :- is_fig(X).

is_four(four(A,B,C,D)) :- square(A), square(B), square(C), square(D).
empty_four(four(none,none,none,none)).
is_a_segm(a_segm(L,R)) :- is_four(L), is_four(R).
empty_segm(a_segm(X,X)) :- empty_four(X).
is_a_rank(a_rank(W,G,B)) :- is_a_segm(W), is_a_segm(G), is_a_segm(B).
empty_rank(a_rank(X,X,X)) :- empty_segm(X).
is_board(board(Outer,Second,Third,Fourth,Fifth,Inner)) :-
    is_a_rank(Outer), is_a_rank(Second), is_a_rank(Third), is_a_rank(Fourth), is_a_rank(Fifth), is_a_rank(Inner).
empty_board(board(X,X,X,X,X,X)) :- empty_rank(X).
give_rank(board(X,_,_,_,_,_),0,X).
give_rank(board(_,X,_,_,_,_),1,X).
give_rank(board(_,_,X,_,_,_),2,X).
give_rank(board(_,_,_,X,_,_),3,X).
give_rank(board(_,_,_,_,X,_),4,X).
give_rank(board(_,_,_,_,_,X),5,X).
give_segm(a_rank(X,_,_),0,X).
give_segm(a_rank(_,X,_),1,X).
give_segm(a_rank(_,_,X),2,X).
give_four(a_segm(X,_),0,X).
give_four(a_segm(_,X),1,X).
give_from_four(four(X,_,_,_),0,X).
give_from_four(four(_,X,_,_),1,X).
give_from_four(four(_,_,X,_),2,X).
give_from_four(four(_,_,_,X),3,X).
give_from_segm(F,N,X) :- is_a_segm(F), I is N/4, give_four(F,I,O), R is mod(N,4), give_from_four(O,R,X).
give_from_rank(F,N,X) :- is_a_rank(F), I is N/2, give_segm(F,I,O), R is mod(N,2), give_from_segm(O,R,X).
get_from_board(B,[R,F],X) :- is_board(B), give_rank(B,R,O), give_from_rank(O,F,X).
getb(B,P,X) :- pos(P), get_from_board(B,P,X).

replace_rank_in_board(board(_,B,C,D,E,F),0,W, board(W,B,C,D,E,F)).
replace_rank_in_board(board(A,_,C,D,E,F),1,W, board(A,W,C,D,E,F)).
replace_rank_in_board(board(A,B,_,D,E,F),2,W, board(A,B,W,D,E,F)).
replace_rank_in_board(board(A,B,C,_,E,F),3,W, board(A,B,C,W,E,F)).
replace_rank_in_board(board(A,B,C,D,_,F),4,W, board(A,B,C,D,W,F)).
replace_rank_in_board(board(A,B,C,D,E,_),5,W, board(A,B,C,D,E,W)).
replace_segm_in_rank(a_rank(_,B,C),0,W,a_rank(W,B,C)).
replace_segm_in_rank(a_rank(A,_,C),1,W,a_rank(A,W,C)).
replace_segm_in_rank(a_rank(A,B,_),2,W,a_rank(A,B,W)).
replace_four_in_segm(segm(_,X),0,W,segm(W,X)).
replace_four_in_segm(segm(X,_),1,W,segm(X,W)).
replace_one_in_four(four(_,B,C,D),0,W,four(W,B,C,D)).
replace_one_in_four(four(A,_,C,D),1,W,four(A,W,C,D)).
replace_one_in_four(four(A,B,_,D),2,W,four(A,B,W,D)).
replace_one_in_four(four(A,B,C,_),3,W,four(A,B,C,W)).
replace_one_in_segm(X,N,W,Y) :- I is N/4, give_four(X,I,O), R is mod(N,4),
                                replace_one_in_four(O,R,W,S), replace_four_in_segm(X,I,S,Y).
replace_one_in_rank(X,N,W,Y) :- I is N/2, give_segm(X,I,O), R is mod(N,2),
                                replace_one_in_segm(O,R,W,S), replace_segm_in_rank(X,I,S,Y).
replace_one_on_board(X,[R,F],W,Y) :- give_rank(X,R,O), replace_one_in_rank(O,F,W,S), replace_rank_in_board(X,R,S,Y).
replaceb(X,P,W,Y) :- is_board(X), pos(P), replace_one_on_board(X,P,W,Y).
swapb(X,[F,T],Y) :- getb(X,F,O), getb(X,T,A), replaceb(X,F,A,I), replaceb(I,T,O,Y).

cansimply(straight,inwards,[5,X],[5,Y],1) :- Y is mod(X+12,24).
cansimply(straight,outwards,[F,X],[T,X],L) :- L is F-T.
cansimply(straight,inwards,X,Y,L) :- cansimply(straight,outwards,Y,X,L).
cansimply(straight,pluswise,[X,F],[X,T],L) :- L is mod(T-F,24).
cansimply(straight,minuswise,F,T,L) :- cansimply(straight,pluswise,T,F,L).


offig(X,X) :- is_fig(X).
offig(fig(X,pawn), fig(X,pawn,crossed)) :- color(X).
%offig(fig(X,pawn), fig(X,pawn,didntcross)) :- color(X).
%offig(fig(X,pawn,didntcross), fig(X,pawn)) :- color(X).
offig(_,_) :- !, fail.
pawnCrossed(fig(_, pawn, crossed)).
pawnCrossed(_) :- !, fail.
ofcolor(Color,X) :- offig(fig(Color,_),X).
oftype(Type,X) :- offig(fig(_,Type),X).

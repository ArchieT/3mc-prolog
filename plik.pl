nth([],_,_) :- !, fail.
nth([X],0,X).
nth([_],0,_) :- !, fail.
nth([X|_],0,X).
nth([_|_],0,_) :- !, fail.
nth([_|Rest],Index,X) :- NewIndex is Index-1, nth(Rest,NewIndex,X), !.
onpos(Board,[Rank, File],X) :- nth(Board,Rank,Squares), !, % if we have the nth rank already, there is no other nth rank in Board
                               nth(Squares, File, X), !.
rank(0). rank(1). rank(2). rank(3). rank(4). rank(5).
rank(_) :- !, fail. %ranks are 0-5 only
file(0). file(1). file(2). file(3). file(4). file(5). file(6). file(7).
file(8). file(9). file(10). file(11). file(12). file(13). file(14). file(15).
file(16). file(17). file(18). file(19). file(20). file(21). file(22). file(23).
file(_) :- !, fail. %files are 0-23 only
pos(Rank,File) :- rank(Rank), file(File).
pos([Rank,File]) :- pos(Rank,File).
onerank(X) :- length(X,24).
board(X) :- length(X,6), forall((rank(N),nth(X,N,Y)),onerank(Y)).
boardsequalat(Where,One,Another) :- onpos(One,Where,X), !, % if we have X on Where on One, there can be no other X
                                    onpos(Another, Where, X).
boardsequal(One,Another) :- board(One), board(Another),
                            One = Another, !, % i am not sure if using boardsequal ever makes sense
                            forall(pos(X),boardsequalat(X,One,Another)).
boardsequalexcept(One,Another,Except) :- pos(Except), board(One), board(Another),
                                         forall((pos(X), X \= Except), boardsequalat(X,One,Another)).
replaced(Before,Where,What,After) :- pos(Where), board(Before), board(After),
                                     %onpos(Before,Where,Discarded),
                                     onpos(After,Where,What),
                                     boardsequalexcept(Before,After,Where), !.
                                     %replaced(After,Where,Discarded,Before), !.
swapped(Before,[From,To],After) :-
    pos(From), pos(To),
    board(Before), board(After),
    onpos(Before,From,Our), onpos(Before,To,Another),
    replaced(Before,From,Another,After), replaced(Before,To,Our,After), !.

offig(X,X).
offig(fig(X,pawn), fig(X,pawn,_)).
offig(_,_) :- !, fail.
pawnCrossed(fig(_, pawn, crossed)).
pawnCrossed(_) :- !, fail.
ofcolor(Color,X) :- offig(fig(Color,_),X).

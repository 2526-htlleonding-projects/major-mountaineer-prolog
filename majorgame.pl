/* Major Mountaineer, by Arthur and the big iranian man */

:- dynamic i_am_at/1, at/2, holding/1, apple_juice/1, zero_juice_turns/1, honor/1.
:- retractall(at(_, _)),
   retractall(i_am_at(_)),
   retractall(holding(_)),
   retractall(apple_juice(_)),
   retractall(zero_juice_turns(_)),
   retractall(honor(_)).

i_am_at(mud_huzz).
apple_juice(100).
zero_juice_turns(0).
honor(25).

/* Starting Area */

path(mud_huzz, n, train_station).
path(train_station, s, mud_huzz).

path(mud_huzz, e, storage_building).
path(storage_building, w, mud_huzz).

path(mud_huzz, w, arm_chair).
path(arm_chair, e, mud_huzz).

/* This is a one way ticket. */

path(train_station, e, hohe_dirn).
path(train_station, n, traunstein).
path(train_station, w, grosser_priel).

path(traunstein, e, hohe_dirn).
path(grosser_priel, e, hohe_dirn).

/* HOHE DIRN */

/* All things around the map. */

at(apple_juice, storage_building).


/* Meter step rules. */

next_lower_juice(100, 75).
next_lower_juice(75, 60).
next_lower_juice(60, 40).
next_lower_juice(40, 25).
next_lower_juice(25, 0).
next_lower_juice(0, 0).

next_higher_juice(0, 25).
next_higher_juice(25, 40).
next_higher_juice(40, 60).
next_higher_juice(60, 75).
next_higher_juice(75, 100).
next_higher_juice(100, 100).

next_lower_honor(100, 75).
next_lower_honor(75, 60).
next_lower_honor(60, 40).
next_lower_honor(40, 25).
next_lower_honor(25, 0).
next_lower_honor(0, 0).

next_higher_honor(0, 25).
next_higher_honor(25, 40).
next_higher_honor(40, 60).
next_higher_honor(60, 75).
next_higher_honor(75, 100).
next_higher_honor(100, 100).

set_zero_juice_turns(Value) :-
        retractall(zero_juice_turns(_)),
        assert(zero_juice_turns(Value)).

lower_apple_juice :-
        apple_juice(Current),
        next_lower_juice(Current, Next),
        retractall(apple_juice(_)),
        assert(apple_juice(Next)).

raise_apple_juice :-
        apple_juice(Current),
        next_higher_juice(Current, Next),
        retractall(apple_juice(_)),
        assert(apple_juice(Next)).

print_low_juice_update :-
        apple_juice(Value),
        Value =< 60,
        write('[Meter] Apple juice is at '), write(Value), write('.'),
        nl,
        !.
print_low_juice_update.

print_apple_death_warning :-
        apple_juice(0),
        zero_juice_turns(Spent),
        Remaining is 2 - Spent,
        Remaining > 0,
        write('[Warning] You got no apple juice left. This is bad ... very bad. '),
        write(Remaining),
        write(' command(s) left before you die a painful death.'),
        nl,
        !.
print_apple_death_warning.

begin_turn(true) :-
        apple_juice(0),
        !.
begin_turn(false).

end_turn(WasZeroBefore) :-
        apple_juice(Current),
        ( Current =:= 0 ->
                ( WasZeroBefore ->
                        zero_juice_turns(Spent),
                        NewSpent is Spent + 1,
                        set_zero_juice_turns(NewSpent),
                        ( NewSpent >= 2 ->
                                apple_death
                        ;
                                print_apple_death_warning
                        )
                ;
                        set_zero_juice_turns(0),
                        print_apple_death_warning
                )
        ;
                set_zero_juice_turns(0)
        ).

apple_death :-
        nl,
        write('Major screams: "AHHHH, IT HURTS, AHHHHHH."'),
        nl,
        write('You died of death. Two commands passed at zero juice.'),
        nl,
        finish.

apple_juice_after_fight :-
        lower_apple_juice,
        print_low_juice_update.

honor_up :-
        honor(Current),
        next_higher_honor(Current, Next),
        retractall(honor(_)),
        assert(honor(Next)).

honor_down :-
        honor(Current),
        next_lower_honor(Current, Next),
        retractall(honor(_)),
        assert(honor(Next)).

high_honor :-
        honor(100).

low_honor :-
        honor(Value),
        Value < 100.


/* These rules describe how to pick up an object. */

take(X) :-
        begin_turn(WasZeroBefore),
        ( holding(X) ->
                write('You''re already holding it!'),
                nl
        ; i_am_at(Place),
          at(X, Place) ->
                retract(at(X, Place)),
                assert(holding(X)),
                write('OK.'),
                nl
        ;
                write('I don''t see it here.'),
                nl
        ),
        end_turn(WasZeroBefore).


/* These rules describe how to put down an object. */

drop(X) :-
        begin_turn(WasZeroBefore),
        ( holding(X) ->
                i_am_at(Place),
                retract(holding(X)),
                assert(at(X, Place)),
                write('OK.'),
                nl
        ;
                write('You aren''t holding it!'),
                nl
        ),
        end_turn(WasZeroBefore).


/* These rules define the direction letters as calls to go/1. */

n :- go(n).
s :- go(s).
e :- go(e).
w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        begin_turn(WasZeroBefore),
        ( i_am_at(Here),
          path(Here, Direction, There) ->
                retract(i_am_at(Here)),
                assert(i_am_at(There)),
                lower_apple_juice,
                render_current_location,
                print_low_juice_update
        ;
                write('You can''t go that way.'),
                nl
        ),
        end_turn(WasZeroBefore).

route(Moves) :-
        is_list(Moves),
        execute_route_moves(Moves),
        render_current_location.

route(_) :-
        fail.

execute_route_moves([]).

execute_route_moves([Direction|Rest]) :-
        i_am_at(Here),
        ( path(Here, Direction, There) ->
                retract(i_am_at(Here)),
                assert(i_am_at(There)),
                execute_route_moves(Rest)
        ;
                true
        ).


/* This rule tells how to look about you. */

look :-
        begin_turn(WasZeroBefore),
        render_current_location,
        end_turn(WasZeroBefore).

render_current_location :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over.'),
        nl,
        halt.


/* This rule just writes out game instructions. */

instructions :-
        begin_turn(WasZeroBefore),
        write_instructions,
        end_turn(WasZeroBefore).

write_instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('route([..]).       -- run a silent batch of moves without juice use.'), nl,
        write('drink.             -- to drink one apple_juice from inventory.'), nl,
        write('juicy.             -- to check apple juice meter.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


drink :-
        begin_turn(WasZeroBefore),
        ( holding(apple_juice) ->
                retract(holding(apple_juice)),
                raise_apple_juice,
                write('You drink an apple juice.'),
                nl,
                print_low_juice_update
        ;
                write('Major growls: "No apple juice? Um gods wün!"'),
                nl
        ),
        end_turn(WasZeroBefore).

juicy :-
        begin_turn(WasZeroBefore),
        apple_juice(Value),
        write('Apple juice meter: '), write(Value), write('.'),
        nl,
        end_turn(WasZeroBefore).


/* This rule prints out instructions and tells where you are. */

start :-
        begin_turn(WasZeroBefore),
        write_instructions,
        render_current_location,
        end_turn(WasZeroBefore).


/* These rules describe the various rooms. */

/* Template describe block */
describe(template) :-
        write('---- [room] ----'), nl,
        nl,
        write(''), nl,
        write(''), nl,
        write(''), nl.

describe(mud_huzz) :-
        write('---- Mud Huzz ----'), nl,
        nl,
        write('You are in your mud huzz, your home.'), nl,
        nl,
        write('EAST there is your storage building with your chest.'), nl,
        write('NORTH the train station from which you will start your adventures is located.'), nl.

describe(train_station) :-
        write('---- Train Station ----'), nl,
        nl,
        write('You are at the trusty ol train station. Here only one train leaves and arrives evrery day.'), nl,
        nl,
        write('EAST you can attempt the HOHE DIRN hike'), nl,
        write('NORTH you try your luck in at the TRAUNSTEIN.'), nl,
        write('WEST you can do the hardest tour, the GROSSE PRIEL.'), nl,
        write('SOUTH you can return to your mud huzz.'), nl.

describe(storage_building) :-
        write('---- Storage Building ----'), nl,
        nl,
        write('You are in your storage building where your supplies are kept.'), nl,
        nl,
        write('WEST you can return to your mud huzz.'), nl.

describe(arm_chair) :-
        write('---- The Living Room ----'), nl,
        nl,
        write('You look at the empty arm chair where your wife used to sit.'), nl,
        write('Its lonely ever since she died, you didnt dare touch the chair after the day of her funeral.'), nl,
        write('You hope that maybe some day youll find someone wholl be as perfect as she was.'), nl,
        nl,
        write('EAST to return to the Mudd Huzz.'), nl.

describe(hohe_dirn) :-
        write('---- HOHE DIRN ----'), nl,
        nl,
        write('Welcome the the HOHE DIRN hike.'), nl,
        write('This is the beginner hike, lets hope you are well stocked in apple juice.'), nl,
        nl,
        write('NORTH awaits the start of your journy. Be careful of the local population, they might be dangerous.'), nl.

describe(traunstein) :-
        write('Oops, seems like you fell asleep, you are now at ... HOHE DIRN?!'), nl,
        nl, route([e]).

describe(grosser_priel) :-
        write('zzzzZZZzzz ... what? .. where am I? ... HOHE DIRN?!'), nl,
        nl, route([e]).

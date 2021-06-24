# Reversible Actions

A Kanban board is built up from a sequence of reversible actions.

For example, the first action is typically "create a new, empty Kanban board" or "create a new Kanban from the template \<ID\>". This would be followed by more "create", "update" and "delete"-type actions for lists and cards, forming a linear sequence. Using this sequence, you can trace the evolution of the Kanban board, as well as revert actions from the end of the sequence to recreate the board as it was earlier in history.

## Rules
- IDs for Kanban objects are unique, immutable, and never reused.
- When dealing with collections of objects (for instance, a Kanban list contains a collection of cards), the collection should behave like special stack:
  - New elements can only be pushed onto the top of the stack.
  - Elements can only be popped from the top of the stack.
  - Elements within the stack can be reordered.

## Basic Actions

The history sequence of a Kanban board is made up of basic actions. Each action and its payload should be serializable, so that it can be translated into a corresponding command to persistant storage or archive, or some other interested service.

Basic actions are handled by `ActionReceiver`s.

### Create

```
create-board(_, board(B)).
create-list(_, list(L)).
create-card(_, card(C)).
create-label(_, label(T)).
create-milestone(_, milestone(M)).
```

### Update

```
update-board(board(B), board(B')).
update-list(list(L), list(L')).
update-card(card(C), card(C')).
update-label(label(T), label(T')).
update-milestone(milestone(M), milestone(M')).
```

### Delete

```
delete-board(board(B), _).
delete-list(list(L), _).
delete-card(card(C), _).
delete-label(label(T), _).
delete-milestone(milestone(M), _).
```

## Compound Actions

Compound actions are composed of basic actions and other compound actions. These actions are usually closer to the end user's intention and should be undo-able in a single step.

Compound actions are handled by `Controller`s.

For labels:

```
attach-label(label(L), card(C)) :-
  update-card(card(C), card(C': {L attached})).

detach-label(label(L), card(C)) :-
  update-card(card(C), card(C': {L detached})).

add-label(label(L)) :-
  create-label(_, label(L)).

remove-label(label(L)) :-
  for each card C
    if L is attached to C
      detach-label(label(L), card(C)),
  delete-label(label(L), _).
```

For milestones:

```
attach-milestone(milestone(M), card(C)) :-
  update-card(card(C), card(C': {M attached})).

detach-milestone(milestone(M), card(C)) :-
  update-card(card(c), card(C': {M detached})).

add-milestone(milestone(M)) :-
  create-milestone(_, milestone(M)).

remove-milestone(milestone(M)) :-
  for each card C
    if M is attached to C
      detach-milestone(milestone(M), card(C)),
  delete-milestone(milestone(M), _).
```

For cards:

```
push-card(card(C), list(L)) :-
  update-list(list(L), list(L': {C pushed})).

pop-card(list(L)) :-
  if L is not empty
    update-list(list(L), list(L': {top popped})).

move-card(list(L), position(P), position(P')) :-
  if L is longer than 1
    update-list(list(L), list(L': {P moved to P'})).

add-card(card(C), list(L)) :-
  create-card(_, card(C)),
  push-card(card(C), list(L)).

remove-card(card(C), list(L)) :-
  if L is longer than 1
    if C is not at the top of L
      move-card(list(L), position(card(C)), position(0)),
  pop-card(card(C)),
  delete-card(card(C), _).
```

For lists:

```
push-list(list(L), board(B)) :-
  update-board(board(B), board(B': {L pushed})).

pop-list(board(B)) :-
  if B is not empty
    update-board(board(B), board(B': {top popped})).

move-list(board(B), position(P), position(P')) :-
  if B is longer than 1
    update-board(board(B), board(B': {P moved to P'})).

add-list(list(L), board(B)) :-
  create-list(_, list(L)),
  push-list(list(L), board(B)).

remove-list(list(L), board(B)) :-
  for each card C in L
    remove-card(card(C), list(L)),
  if B is longer than 1
    if L is not at the top of B
      move-list(board(B), position(list(L)), position(0)),
  pop-list(list(L), board(B)),
  delete-list(list(L), _).
```

For boards:

```
add-board(board(B)) :-
  create-board(_, board(B)).

remove-board(board(B)) :-
  for each list L
    remove-list(list(L), board(B)),
  for each label T
    remove-label(label(T), board(B)),
  for each milestone M
    remove-milestone(milestone(T), board(B)),
  delete-board(board(B), _).
```

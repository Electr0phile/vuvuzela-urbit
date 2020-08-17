::  Entry server's responsibilities:
::  - announce a round
::  - gather requests from clients
::  - decrypt and shuffle forward-onions, remember
::    the permutation and pubkeys
::  - send list of requests to the next server in chain
::  - receive a list of responses from the next server in chain
::  - restore original permutation and decrypt backprop-onions
::
/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 round=@ basket=(list @) hens=(list @p)]
    ==
::
+$  card  card:agent:gall
::
++  next-server  ~zod
--
%-  agent:dbug
=|  state=versioned-state
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%vuvuzela-server-entry initialized successfully'
  =.  state  [%0 0 ~ ~]
  `this
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%vuvuzela-server-entry recompiled successfully'
  `this(state [%0 0 ~ ~])
:::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %announce-round
      :_  this(state state(round +(round.state), basket ~))
      [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]~
      ::
        [%egg @]
      ~&  >  "new egg in the basket"
      ::  TODO: add permutations
      `this(state state(basket (snoc basket.state (peel +.q.vase)), hens (snoc hens.state src.bowl)))
      ::
        %throw-basket
      :_  this
      [%pass /vuvuzela/chain/throw %agent [next-server %vuvuzela-server-end] %poke %noun !>([%basket basket.state])]~
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%vuvuzela %rounds ~]
    ~&  >  "got subscription from {<src.bowl>}"
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ~&  >>>  "on-agent received"
  `this
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
  ++  peel
    |=  [egg=@]
    egg
--

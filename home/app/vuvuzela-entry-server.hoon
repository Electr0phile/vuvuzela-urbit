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
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 round=@ forward-list=(list forward-onion) clients=(list @p)]
    ==
::
+$  card  card:agent:gall
+$  symkey  @uwsymmetrickey
+$  pubkey  @uwpublickey
+$  forward-onion  [pub=pubkey encrypted-payload=@]
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
        ::
        %announce-round
      ~&  >  "announcing round {<+(round.state)>}"
      :_  this(state state(round +(round.state), forward-list ~, clients ~))
      [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]~
        ::
        [%forward-onion @ @]
      ~&  >  "forwarding onion"
      ::  TODO:
      ::  - permutations
      ::  - onion decryption
      `this(state state(forward-list (snoc forward-list.state (decrypt-onion +.q.vase our.bowl)), clients (snoc clients.state src.bowl)))
        ::
        %pass-forward-list
      :_  this
      [%pass /vuvuzela/chain/forward %agent [next-server %vuvuzela-end-server] %poke %noun !>([%forward-list forward-list.state])]~
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
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ~&  >>>  "on-agent received"
  `this
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
  ++  decrypt-onion
    |=  [input-onion=forward-onion our=@p]
    =/  vane  (ames !>(..zuse))
    =.  crypto-core.ames-state.vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.vane
    =/  sym  (derive-symmetric-key:vane pub.input-onion our-sec)
    =/  dec=(unit @)  (de:crub:crypto sym encrypted-payload.input-onion)
    ?~  dec
      !!
    (forward-onion (cue u.dec))
--

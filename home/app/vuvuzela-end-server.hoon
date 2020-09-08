::  End server's responsibilities:
::  - collect list of fonions from second last server
::  - decrypt and process exchanges:
::    * try to pair together exchanges
::      if successful, swap their messages
::    * if there is no pair for a certain exchange,
::      send him a random string instead
::  - encrypt all meassages with own secret keys
::  - send them back as bonions
::
/-  *vuvuzela
/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 round=@ forward-list=(list fonion) num-groups=@]
    ==
::
+$  card  card:agent:gall
::
++  prev-server  ~wes
++  entry-server  ~nus
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
  ~&  >  '%vuvuzela-end-server initialized successfully'
  =.  state  [%0 0 ~ 0]
  `this
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%vuvuzela-end-server recompiled successfully'
  `this(state [%0 0 ~ 0])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::
        [%forward-package *]
      ~&  >  "received forward-package"
      =^  cards  state
      (handle-forward-package (@tas +<.q.vase) ((list fonion) +>.q.vase) our.bowl)
      [cards this]
        ::
        %subscribe-for-rounds
      :_  this
      :~
        :*  %pass  /vuvuzela/rounds/(scot %p our.bowl)
            %agent  [entry-server %vuvuzela-entry-server]
            [%watch /vuvuzela/rounds]
        ==
      ==
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%vuvuzela %dials @ ~]
    ~&  >  "got subscription from {<src.bowl>} on {<path>}"
    `this
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      ::
      [%vuvuzela %chain %backward ~]
    ~&  >>  "bonion-list delivered to prev server"
    `this
      ::
      [%vuvuzela %rounds @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    +.q.cage.sign  (on-agent:def wire sign)
          [%convo @]
        ::  don't have to do anything
        `this
          ::
          [%dial @ @]
        ~&  >  "dial round starts, {<+>+.q.cage.sign>} groups"
        `this(state state(num-groups +>+.q.cage.sign))
      ==
    ==
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-forward-package
  |=  [round-type=@tas fonion-list=(list fonion) our=@p]
  ^-  (quip card _state)
  ?:  =(round-type %dial)
    ~&  >>>  "a dial round, received {<(lent fonion-list)>} dials"
    (handle-dialling fonion-list our)
  =/  [* bonion-list=(list bonion) dead-drop-map=(map hash [@ crypt]) @]
    %:  spin
      fonion-list
      :*
        (reap (lent fonion-list) 1.337)
        `(map hash fonion)`~
        0
      ==
      ~(do handle-fonion our fonion-list)
    ==
  ~&  >>  dead-drop-map
  ~&  >>  bonion-list
  :_  state
    :_  ~
    :*
      %pass  /vuvuzela/chain/backward
      %agent  [prev-server %vuvuzela-middle-server]
      %poke  %noun  !>([%backward-package bonion-list])
    ==
::
++  handle-dialling
  |=  [fonion-list=(list fonion) our=@p]
  ^-  (quip card _state)
  =/  dead-drop-map=(map @ (list crypt))  ~
  =/  n  0
  =/  len  (lent fonion-list)
  |-
  ?:  =(n len)
    ~&  >>>  dead-drop-map
    =/  keys  ~(tap in ~(key by dead-drop-map))
    =/  len  (lent keys)
    =/  i  0
    =/  facts=(list card)  ~
    |-
    ?:  =(i len)
      [facts state]
    %=  $
      i  +(i)
      facts
        %+  snoc  facts
          [%give %fact ~[/vuvuzela/dials/(scot %ud (snag i keys))] %noun !>((~(got by dead-drop-map) (snag i keys)))]
    ==
  =/  =dead-drop  (decrypt-dead-drop (snag n fonion-list) our)
  =/  group-list  (~(get by dead-drop-map) -.dead-drop)
  =/  updated-group-list=(list crypt)
    ?~  group-list
      ~[crypt.dead-drop]
    (snoc u.group-list crypt.dead-drop)
  %=  $
    dead-drop-map  (~(put by dead-drop-map) hash.dead-drop updated-group-list)
    n  +(n)
  ==
::
++  handle-fonion
  |_  [our=@p fonion-list=(list fonion)]
  ++  do
    |=
      [=fonion bonion-list=(list bonion) dead-drop-map=(map hash [@ crypt]) count=@]
    ^-  [~ (list bonion) (map hash [@ crypt]) @]
    =/  =dead-drop
      (decrypt-dead-drop fonion our)
    =/  maybe-match
      (~(get by dead-drop-map) hash.dead-drop)
    ?~  maybe-match
      :*
        ~  bonion-list
        %+  ~(put by dead-drop-map)
          hash.dead-drop
          [count crypt.dead-drop]
        +(count)
      ==
    ~&  >  "found match!"
    =/  index  -.u.maybe-match
    =/  client1-pub=pubkey  pub:(snag index fonion-list)
    =/  client2-pub=pubkey  pub.fonion
    =/  reply-to-client1
      %^  encrypt-reply-text
        crypt.dead-drop  our  client1-pub
    =/  reply-to-client2
      %^  encrypt-reply-text
        +.u.maybe-match  our  client2-pub
    =/  updated-bonion-list
      %^  snap
        %^  snap
          bonion-list  count  reply-to-client2
        index
        reply-to-client1
    :*
      ~  updated-bonion-list
      (~(del by dead-drop-map) hash.dead-drop)
      +(count)
    ==
  --
::
++  encrypt-reply-text
  |=  [message=crypt our=@p their-pub=pubkey]
  =/  vane  (ames !>(..zuse))
  =.  crypto-core.ames-state.vane
    (pit:nu:crub:crypto 512 (shaz our))
  =/  our-sec  sec:ex:crypto-core.ames-state.vane
  =/  sym
    (derive-symmetric-key:vane their-pub our-sec)
  (en:crub:crypto sym message)
::
++  decrypt-dead-drop
  |=  [onion=fonion our=@p]
  =/  vane  (ames !>(..zuse))
  =.  crypto-core.ames-state.vane
    (pit:nu:crub:crypto 512 (shaz our))
  =/  our-sec  sec:ex:crypto-core.ames-state.vane
  =/  sym
    (derive-symmetric-key:vane pub.onion our-sec)
  =/  dec=(unit @)
    (de:crub:crypto sym payload.onion)
  ?~  dec
    !!
  (dead-drop (cue u.dec))
--

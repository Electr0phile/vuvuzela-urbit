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
/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 round=@ forward-list=(list fonion) clients=(list @p)]
    ==
::
+$  card  card:agent:gall
+$  symkey  @uwsymmetrickey
+$  pubkey  @uwpublickey
+$  crypt  @
+$  hash  @
+$  dead-drop   [=hash =crypt]
+$  fonion  [pub=pubkey payload=@]
+$  bonion  @
::
++  prev-server  ~nus
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
  ~&  >  '%vuvuzela-end-server recompiled successfully'
  `this(state [%0 0 ~ ~])
:::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::
        [%fonion-list *]
      ~&  >  "received fonion-list"
      =^  cards  state
      (handle-fonion-list ((list fonion) +.q.vase) our.bowl)
      [cards this]
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
  ++  handle-fonion-list
    |=  [fonion-list=(list fonion) our=@p]
    ^-  (quip card _state)
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
        %agent  [prev-server %vuvuzela-entry-server]
        %poke  %noun  !>([%bonion-list bonion-list])
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
  ++  sas
    |=  [onion=fonion our=@p]
    =/  vane  (ames !>(..zuse))
    =.  crypto-core.ames-state.vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.vane
    =/  sym  (derive-symmetric-key:vane pub.onion our-sec)
    =/  dec=(unit @)  (de:crub:crypto sym payload.onion)
    ?~  dec
      !!
    (fonion (cue u.dec))
--

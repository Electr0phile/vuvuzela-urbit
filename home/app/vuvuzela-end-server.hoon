::  End server's responsibilities:
::  - collect list of forward-onions from second last server
::  - decrypt and process requests:
::    * try to pair together requests
::      if successful, swap their messages
::    * if there is no pair for a certain request,
::      send him a random string instead
::  - encrypt all meassages with own secret keys
::  - send them back
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
+$  encrypted-text  @
+$  dead-drop  @
+$  exchange-request   [%exchange-request =dead-drop =encrypted-text]
+$  exchange-response  [%exchange-response =encrypted-text]
+$  forward-onion  [pub=pubkey encrypted-payload=@]
+$  backward-onion  @
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
        [%forward-list *]
      ~&  >  "received forward-list"
      ::  TODO:
      ::  - permutations
      ::  - onion decryption
      =^  cards  state
      (handle-forward-list ((list forward-onion) +.q.vase) our.bowl)
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
  ++  handle-forward-list
    |=  [forward-list=(list forward-onion) our=@p]
    =/  [* backward-list=(list backward-onion) drop-map=(map @ @)]
      (spin forward-list [(reap (lent forward-list) 1.337) ~] ~(do handle-forward-onion our))
    ~&  >>  drop-map
    ~&  >>>  backward-list
    `state
  ++  handle-forward-onion
    |_  [our=@p]
    ++  do
      |=  [=forward-onion backward-list=(list backward-onion) drop-map=(map dead-drop encrypted-text)]
      =/  =exchange-request
        (decrypt-exchange-request forward-onion our)
      =/  maybe-match  (~(get by drop-map) dead-drop.exchange-request)
      ?~  maybe-match
        [~ backward-list (~(put by drop-map) dead-drop.exchange-request encrypted-text.exchange-request)]
      ~&  >  "found match!"
      =/  client-pub=pubkey  -.forward-onion
      =/  reply  (encrypt-reply-text u.maybe-match our client-pub)
      [~ (snoc backward-list reply) (~(del by drop-map) dead-drop.exchange-request)]
    --
  ::
  ++  encrypt-reply-text
    |=  [message=encrypted-text our=@p their-pub=pubkey]
    =/  vane  (ames !>(..zuse))
    =.  crypto-core.ames-state.vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.vane
    =/  sym  (derive-symmetric-key:vane their-pub our-sec)
    (en:crub:crypto sym message)
  ::
  ++  decrypt-exchange-request
    |=  [input-onion=forward-onion our=@p]
    =/  vane  (ames !>(..zuse))
    =.  crypto-core.ames-state.vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.vane
    =/  sym  (derive-symmetric-key:vane pub.input-onion our-sec)
    =/  dec=(unit @)  (de:crub:crypto sym encrypted-payload.input-onion)
    ?~  dec
      !!
    (exchange-request (cue u.dec))
  ++  sas
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

::  Middle server responsibilities:
::  * forwardprop:
::    - receive fonion-list from previous
::    server in chain
::    - decrypt every message in the list,
::    remember symkeys!
::    - shuffle messages, remember permutation
::    - send these to the next server
::  * backprop:
::    - receive bonion-list from next
::    server in chain
::    - restore forwardprop order of messages
::    using saved permutation
::    - encrypt every message with saved symkey
::    - send these to prev server in chain
::
/-  *vuvuzela
/+  default-agent, dbug
/=  ames  /sys/vane/ames
/=  permute  /gen/random-permute-list
/=  unpermute  /gen/unpermute-list
|%
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero  [%0 round=@ fonion-list=(list fonion) symkey-list=(list symkey) permutation=(list @)]
::
+$  card  card:agent:gall
::
++  next-server  ~zod
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
  ~&  >  '%vuvuzela-server-entry initialized successfully'
  =.  state  [%0 0 ~ ~ ~]
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
  `this(state [%0 0 ~ ~ ~])
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
      (handle-fonion-list ((list fonion) +.q.vase) our.bowl eny.bowl)
      [cards this]
        ::
        [%bonion-list *]
      ~&  >  "received bonion-list"
      =^  cards  state
      (handle-bonion-list ((list bonion) +.q.vase) our.bowl)
      [cards this]
    ==
  ==
::
++  on-watch  on-watch:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%vuvuzela %chain %backward ~]
    ~&  >>  "bonion-list delivered to prev server"
    `this
      [%vuvuzela %chain %forward ~]
    ~&  >>  "fonion-list delivered to next server"
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-fonion-list
  |=  [in-list=(list fonion) our=@p eny=@]
  ^-  (quip card _state)
  =/  [out-list=(list fonion) symkey-list=(list symkey)]
    %^  spin
      in-list
      `(list symkey)`~
      ~(do handle-fonion our)
  =/  [shuffled-out-list=(list fonion) permutation=(list @)]
    (permute out-list eny)
  :_  state(symkey-list symkey-list, permutation permutation)
    :_  ~
      :*
        %pass  /vuvuzela/chain/forward
        %agent  [next-server %vuvuzela-end-server]
        %poke  %noun  !>([%fonion-list shuffled-out-list])
      ==
::
++  handle-fonion
  |_  [our=@p]
  ++  do
    |=  [enc=fonion symkey-list=(list symkey)]
    =/  [dec=fonion sym=symkey]
      (decrypt-fonion enc our)
    [dec (snoc symkey-list sym)]
  --
::
++  decrypt-fonion
  |=  [onion=fonion our=@p]
  ^-  [fonion symkey]
  =/  vane  (ames !>(..zuse))
  =.  crypto-core.ames-state.vane
    (pit:nu:crub:crypto 512 (shaz our))
  =/  our-sec  sec:ex:crypto-core.ames-state.vane
  =/  sym
    (derive-symmetric-key:vane pub.onion our-sec)
  =/  dec=(unit @)
    (de:crub:crypto sym payload.onion)
  ?~  dec
    ~&  >>>  "decryption error!"
    !!
  [(fonion (cue u.dec)) sym]
::
++  handle-bonion-list
  |=  [permuted-in-list=(list bonion) our=@p]
  ^-  (quip card _state)
  =/  in-list  (unpermute permuted-in-list permutation.state)
  ?.  =((lent in-list) (lent symkey-list.state))
    ~&  >>>  "bonion-list and symkey-list have different lengths!"
    `state
  =/  [out-list=(list bonion)]
    =/  out-list=(list bonion)  ~
    =/  symkey-list  symkey-list.state
    |-
    ?~  in-list
      out-list
    ?~  symkey-list
      out-list
    %=  $
      in-list  t.in-list
      symkey-list  t.symkey-list
      out-list
        %+  snoc
          out-list
        %-  bonion
        (en:crub:crypto i.symkey-list i.in-list)
    ==
  :_  state(symkey-list ~)
    :_  ~
      :*
        %pass  /vuvuzela/chain/backward
        %agent  [prev-server %vuvuzela-entry-server]
        %poke  %noun  !>([%bonion-list out-list])
      ==
--

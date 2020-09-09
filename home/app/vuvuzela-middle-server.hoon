::    Middle server
::
::  Talks to:
::    - previous server in the chain
::    - next server in the chain
::
::  Responsibilities:
::    - forwardprop
::    Receive a fonion list. For each fonion,
::  decrypt it with a temporary public key.
::  Shuffle resulting list and save symkeys.
::  Send it forward.
::    - backprop
::    Receive a bonion list. Restore permutation.
::  For each bonion, encrypt it with corresponding
::  symkey. Send it backward.
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
+$  state-zero  [%0 symkey-list=(list symkey) permutation=(list @)]
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
  =.  state  [%0 ~ ~]
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
  `this(state [%0 ~ ~])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::
        [%forward *]
      ~&  >  "received forward-package of type {<+<.q.vase>}"
      =^  cards  state
      (handle-forward (@tas +<.q.vase) ((list fonion) +>.q.vase) our.bowl eny.bowl)
      [cards this]
        ::
        [%backward *]
      ~&  >  "received backward-package"
      =^  cards  state
      (handle-backward ((list bonion) +.q.vase) our.bowl)
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
++  handle-forward
  |=  [round-type=@tas in-list=(list fonion) our=@p eny=@]
  ^-  (quip card _state)
  ::  apply handle-fonion to each fonion in a list and
  ::  save symkeys. then permute the list.
  =/  [out-list=(list fonion) symkey-list=(list symkey)]
    %^  spin
      in-list
      `(list symkey)`~
      ~(do handle-fonion our)
  =/  [shuffled-out-list=(list fonion) permutation=(list @)]
    (permute out-list eny)
  ::  only save permutation and symkeys in %convo rounds
  ::
  =/  updated-state
    ?:  =(round-type %dial)
      state
    state(symkey-list symkey-list, permutation permutation)
  :_  updated-state
    :_  ~
      :*
        %pass  /vuvuzela/chain/forward
        %agent  [next-server %vuvuzela-end-server]
        %poke  %noun  !>([%forward [round-type shuffled-out-list]])
      ==
::
++  handle-backward
  |=  [permuted-in-list=(list bonion) our=@p]
  ^-  (quip card _state)
  =/  in-list  (unpermute permuted-in-list permutation.state)
  ?.  =((lent in-list) (lent symkey-list.state))
    ~&  >>>  "bonion-list and symkey-list have different lengths!"
    `state
  =;  [out-list=(list bonion)]
    :_  state(symkey-list ~)
    :_  ~
    :*
      %pass  /vuvuzela/chain/backward
      %agent  [prev-server %vuvuzela-entry-server]
      %poke  %noun  !>([%backward out-list])
    ==
  ::  simply encrypt each bonion with a symkey saved from
  ::  forwardprop.
  ::
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
--

::    End server
::
::  Talks to:
::    - entry server
::    Entry server calculates number of dialling groups
::  each dialling round. End server needs to know it
::  in order to protect itself from possible attacks from
::  malicious clients.
::    - clients
::    Clients subscribe to the end server according to
::  their public keys to receive dialling dead drops.
::    - last middle server
::    Receives fonions and either returns bonions or sends
::  out dialling dead drops.
::
::  Responsibilities:
::    - dialling
::    When dialling forward-package is received all dialling
::  crypts are sorted into a map according to the group they
::  are intended for. Then each group receives their dead
::  drops according through pubsub, which is updated each dialling
::  round.
::    - conversation
::    During a conversation round each fonion is decrypted and
::  its crypt is put into a hash table. Paired crypts are swapped
::  and sent back, unpaired crypts receive a dummy response.
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
    $:  [%0 num-groups=@ prev-server=(unit @p) entry-server=(unit @p)]
    ==
::
+$  card  card:agent:gall
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
::  Across the /vuvuzela/rounds wire end server receives
::  the update to the number of groups in the dial round.
::
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
          ::  don't have to do anything for convo round
          [%convo @]
        `this
          ::
          [%dial @ @]
        ~&  >  "dial round starts, {<+>+.q.cage.sign>} groups"
        `this(state state(num-groups +>+.q.cage.sign))
      ==
    ==
  ==
::  Each client subscribes to the corresponding group path
::  to get its dial dead drop.
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%vuvuzela %dials @ ~]
    ~&  >  "got subscription from {<src.bowl>} to group {<+>.path>}"
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::  Set up prev and entry servers
        ::
        [%chain @ @]
      `this(state state(prev-server (some +<.q.vase), entry-server (some +>.q.vase)))
        ::
        [%forward *]
      ~&  >  "received forward-package"
      ?+    (@tas +<.q.vase)  (on-poke:def mark vase)
          ::
          %convo
        :_  this
        (respond-convo ((list fonion) +>.q.vase) our.bowl)
          ::
          %dial
        :_  this
        (respond-dial ((list fonion) +>.q.vase) our.bowl)
      ==
        ::  Development-only function for now:
        ::  Subscribe to the entry server for round updates.
        ::
        %subscribe-for-rounds
      ?~  entry-server.state
        ~&  >>>  "prev-server is not specified"
        `this
      =/  entry-server  u.entry-server.state
      :_  this
      :~
        :*  %pass  /vuvuzela/rounds/(scot %p our.bowl)
            %agent  [entry-server %vuvuzela-entry-server]
            [%watch /vuvuzela/rounds]
        ==
      ==
    ==
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  respond-convo
  |=  [fonion-list=(list fonion) our=@p]
  ^-  (list card)
  ?~  prev-server.state
    ~&  >>>  "prev-server is not specified"
    ~
  =/  prev-server  u.prev-server.state
  =/  dead-drop-map=(map hash [@ crypt])  ~
  =/  bonion-list=(list bonion)
    (reap (lent fonion-list) 1.337)
  =/  count  0
  =/  len  (lent fonion-list)
  ::  Main loop: step through fonion-list.
  ::  Decrypt each fonion. In case the hash is
  ::  encountered for the first time - store crypt
  ::  in a map. Otherwise - swap crypts, encrypt and
  ::  send back.
  ::
  |-
  ?:  =(count len)
    :_  ~
    :*
      %pass  /vuvuzela/chain/backward
      %agent  [prev-server %vuvuzela-middle-server]
      %poke  %noun  !>([%backward bonion-list])
    ==
  =/  fonion  (snag count fonion-list)
  =/  =dead-drop
    (decrypt-dead-drop fonion our)
  =/  maybe-match
    (~(get by dead-drop-map) hash.dead-drop)
  ?~  maybe-match
    %=  $
      dead-drop-map
        %+  ~(put by dead-drop-map)
           hash.dead-drop
        [count crypt.dead-drop]
      count  +(count)
    ==
  ::  Process match logic
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
  %=  $
    bonion-list  updated-bonion-list
    dead-drop-map
      (~(del by dead-drop-map) hash.dead-drop)
    count  +(count)
  ==
::
++  respond-dial
  |=  [fonion-list=(list fonion) our=@p]
  ^-  (list card)
  ?~  entry-server.state
    ~&  >>>  "prev-server is not specified"
    ~
  =/  entry-server  u.entry-server.state
  =/  dead-drop-map=(map @ (list crypt))  ~
  =/  n  0
  =/  len  (lent fonion-list)
  ::  Main loop: step through fonion-list. For each dead
  ::  drop put its crypt into a list according to hash
  ::  (group number).
  ::
  ::  After that send out a pubsub update to each group with
  ::  their dead-drops.
  ::
  |-
  ?.  =(n len)
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
  ~&  >>>  dead-drop-map
  =/  keys  ~(tap in ~(key by dead-drop-map))
  =/  len  (lent keys)
  =/  i  0
  =/  facts=(list card)  ~
  |-
  ?:  =(i len)
    facts
  %=  $
    i  +(i)
    facts
      %+  snoc  facts
        [%give %fact ~[/vuvuzela/dials/(scot %ud (snag i keys))] %noun !>((~(got by dead-drop-map) (snag i keys)))]
  ==
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

::  Entry server's responsibilities:
::  - announce a round
::  - gather requests from clients
::  - decrypt and shuffle fonions, remember
::    the permutation and pubkeys
::  - send list of fonions to the next server in chain
::  - receive a list of bonion from the
::    next server in chain
::  - restore original permutation and decrypt
::    bonions
::
/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero  [%0 round=@ fonion-list=(list fonion) clients=(list [@p symkey])]
::
+$  card  card:agent:gall
+$  symkey  @uwsymmetrickey
+$  pubkey  @uwpublickey
+$  fonion  [pub=pubkey payload=@]
+$  bonion  @
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
        %start-round
      ~&  >  "starting round {<+(round.state)>}"
      :-  :~
            :*  %give  %fact  ~[/vuvuzela/rounds]
                %atom  !>(+(round.state))
            ==
          ==
      %=  this
        state
          %=  state
            round  +(round.state)
            fonion-list  ~
            clients  ~
          ==
      ==
        ::  TODO:
        ::  - permutations
        ::
        [%fonion @ @]
      ~&  >  "fonion received"
      ^-  (quip card _this)
      =/  [=fonion sym=symkey]
        (decrypt-fonion +.q.vase our.bowl)
      :-  ~
        %=  this
          state
          %=  state
            fonion-list
          (snoc fonion-list.state fonion)
            clients
          (snoc clients.state [src.bowl sym])
          ==
        ==
        ::
        %end-round
      ^-  (quip card _this)
      :_  this
        :~
          :*
            %pass  /vuvuzela/chain/forward
            %agent  [next-server %vuvuzela-end-server]
            %poke  %noun
            !>([%fonion-list fonion-list.state])
          ==
        ==
        ::
        [%bonion-list *]
      ^-  (quip card _this)
      =/  bonion-list  ((list bonion) +.q.vase)
      =/  clients  clients.state
      ?.  =((lent bonion-list) (lent clients))
        ~&
          >>>  "sent and received lists are not same size"
        `this
      =/  cards=(list card)  ~
      |-
      ?~  clients
        [cards this]
      ?~  bonion-list
        [cards this]
      =/  sym  +.i.clients
      =/  client  -.i.clients
      =/  onion  i.bonion-list
      %=  $
        cards
          %+  snoc
            cards
          :*
            %pass  /vuvuzela/chain/backward
            %agent  [client %vuvuzela-client]
            %poke  %noun
            !>([%bonion (en:crub:crypto sym onion)])
          ==
        clients  t.clients
        bonion-list  t.bonion-list
      ==
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
      !!
    [(fonion (cue u.dec)) sym]
--

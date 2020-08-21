/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero  [%0 =chat round-partner=(unit @p) round=@]
::
+$  card  card:agent:gall
+$  symkey  @uwsymmetrickey
+$  pubkey  @uwpublickey
::  crypt is a client-to-client encrypted text
::  hash is a dead-drop hash, for two clients
::    willing to talk it is the same
::  dead-drop is a pair of two which is only
::    accessed on the end-server to pair up
::    clients
::
+$  crypt  @
+$  hash  @
+$  dead-drop  [=hash =crypt]
::  onion is a message with >1 layers of encryption
::  fonion = forward onion
::    Travels only in client -> end server direction.
::    Encrypted in nus->wes->zod order if chain is
::      (entry)->zod->wes->nus->(end).
::    Each server peels off a layer using own private
::      key and fonion's public key.
::    Each round client's public-private pair for each
::      server is generated anew.
::  bonion = backward onion
::    Travels only in end server -> client direction.
::    Each server encrypts it using own private key
::      and pubkey ontained from forward pass.
::
+$  fonion  [pub=pubkey payload=@]
+$  bonion  @
::  Client-side messaging history.
::
+$  message  [date=@da text=@t my=?(%.y %.n)]
+$  chat  (map ship=@p (list message))
::  Temporary hard-coded chain.
::
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
  ~&  >  '%vuvuzela-client initialized successfully'
  =.  state  [%0 ~ ~ 0]
  `this
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%vuvuzela-client recompiled successfully, cleaning history...'
  `this(state [%0 ~ ~ 0])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::  Request exchange of text with some ship
        ::
        [%exchange @ @]
      =^  cards  state
      (handle-exchange +<.q.vase +>.q.vase our.bowl now.bowl)
      [cards this]
        ::  Process response from entry-server
        ::
        [%bonion @]
      ~&  >  "got bonion"
      =^  cards  state
      (handle-bonion +.q.vase our.bowl now.bowl)
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
        ::
        [%show-chat @]
      =/  ship  `@p`+.q.vase
      ~&  >>>  :-(ship (~(get by chat.state) ship))
      `this
    ==
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%vuvuzela %message ~]
    ~&  >  "forward-onion received by {<src.bowl>}"
    `this
      [%vuvuzela %rounds @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ~&  >  "round {<+.q.cage.sign>} starts"
      `this(state state(round !<(@ q.cage.sign), round-partner ~))
    ==
  ==
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-bonion
  |=  [=bonion our=@p now=@da]
  ^-  (quip card _state)
  ?~  round-partner.state
    ~&  >>>  "mistakenly received message"
    `state
  =/  key  -:(generate-keys our ~nus)
  =/  dec=(unit @)  (de:crub:crypto key bonion)
  ?~  dec
    ~&  >>>  "error decrypting ~nec layer"
    `state
  ?:  =(1.337 u.dec)
    ~&  >>>  "partner did not receive message"
    `state
  =/  key  -:(generate-keys our ~zod)
  =/  dec=(unit @)  (de:crub:crypto key u.dec)
  ?~  dec
    ~&  >>>  "error decrypting ~zod layer"
    `state
  =/  key  -:(generate-keys our ?:(=(our ~bud) ~nec ~bud))
  =/  dec=(unit @)  (de:crub:crypto key u.dec)
  ?~  dec
    ~&  >>>  "error decrypting partner layer"
    `state
  =/  text=@t  u.dec
  ~&  >>  "received message {<text>}"
  :-  ~
  %=  state
    round-partner  ~
    chat  %^  update-chat
            chat.state
            +.round-partner.state
            [now text %.n]
  ==
::
++  handle-exchange
  |=  [text=@t ship=@p our=@p now=@da]
  =/  sym=symkey
    -:(generate-keys our ?:(=(our ~bud) ~nec ~bud))
  =/  =hash  (sham [round.state sym])
  ~&  >>  "sending message {<text>} to"
  ~&  >>  "{<ship>} through {<entry-server>}"
  ~&  >>  "dead-drop hash: {<hash>}"
  =/  =crypt  (en:crub:crypto sym text)
  =/  [sym=symkey pub=pubkey]  (generate-keys our ~zod)
  =/  =dead-drop  [hash crypt]
  =/  fonion-1=fonion
    [pub (en:crub:crypto sym (jam dead-drop))]
  =/  [sym=symkey pub=pubkey]  (generate-keys our ~nus)
  =/  fonion-2=fonion
    [pub (en:crub:crypto sym (jam fonion-1))]
  :_
    %=  state
      chat  %^  update-chat
              chat.state
              ship
              [now text %.y]
      round-partner  (some ship)
    ==
  :~
    :*  %pass  /vuvuzela/chain
        %agent  [entry-server %vuvuzela-entry-server]
        %poke  %noun
        !>([%fonion fonion-2])
    ==
  ==
  ::
  ++  update-chat
    |=  [=chat ship=@p =message]
    =/  messages  (fall (~(get by chat) ship) ~)
    =/  updated-messages  (snoc messages message)
    (~(put by chat) ship updated-messages)
  ::  Create fake keys for testing fake ships
  ::
  ++  generate-keys
    |=  [our=@p their=@p]
    ^-  [symkey pubkey]
    =/  vane  (ames !>(..zuse))
    =/  our-vane  vane
    =/  their-vane  vane
    =.  crypto-core.ames-state.our-vane
      (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.our-vane
    =/  our-pub  pub:ex:crypto-core.ames-state.our-vane
    =.  crypto-core.ames-state.their-vane
      (pit:nu:crub:crypto 512 (shaz their))
    =/  their-pub  pub:ex:crypto-core.ames-state.their-vane
    =/  sym  (derive-symmetric-key:vane their-pub our-sec)
    [sym our-pub]
--

/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 =chat round-partner=(unit @p) round=@]
    ==
::
+$  card  card:agent:gall
+$  symkey  @uwsymmetrickey
+$  pubkey  @uwpublickey
::
+$  encrypted-text  @
+$  dead-drop  @
+$  exchange-request   [%exchange-request =dead-drop =encrypted-text]
+$  exchange-response  [%exchange-response =encrypted-text]
+$  forward-onion  [pubkey encrypted-payload=@]
+$  backward-onion  @
::
+$  message  [date=@da text=@t my=?(%.y %.n)]
+$  chat  (map ship=@p (list message))
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
  ~&  >  "poke received"
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::
        [%request @ @]
      =^  cards  state
      (handle-exchange-request +<.q.vase +>.q.vase our.bowl now.bowl)
      [cards this]
        ::
        [%backward-onion @]
      =^  cards  state
      (handle-backward-onion +.q.vase our.bowl now.bowl)
      [cards this]
        ::
        %subscribe
      :_  this
      :~
        :*  %pass  /vuvuzela/rounds/(scot %p our.bowl)  %agent
            [entry-server %vuvuzela-entry-server]
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
++  handle-backward-onion
  |=  [=encrypted-text our=@p now=@da]
  ^-  (quip card _state)
  ~&  >  "handling backward onion..."
  ?~  round-partner.state
    ~&  >>>  "mistakenly received message"  `state
  ~&  >  "partner test passed..."
  =/  key  -:(generate-keys our ~nus)
  =/  dec=(unit @t)  (de:crub:crypto key encrypted-text)
  ?~  dec
    ~&  >>>  "error decrypting ~nec layer"  `state
  ~&  >  "first layer passed..."
  =/  key  -:(generate-keys our ~zod)
  ~&  >  "decrypting {<u.dec>} with {<key>}..."
  =/  decc  (de:crub:crypto key u.dec)
  ~&  >  "---{<decc>}---"
  =/  dec=(unit @t)  decc
  ~&  >  "decrypted!!!"
  ?~  dec
    ~&  >>>  "error decrypting ~zod layer"  `state
  ~&  >  "second layer passed..."
  =/  key  -:(generate-keys our ?:(=(our ~bud) ~nec ~bud))
  =/  dec=(unit @t)  (de:crub:crypto key u.dec)
  ?~  dec
    ~&  >>>  "error decrypting partner layer"  `state
  =/  text=@t  u.dec
  ~&  >>  "received message {<text>}"
  :-  ~
  %=  state
    round-partner  ~
    chat  %:  update-chat
            chat.state
            +.round-partner.state
            [now text %.n]
          ==
  ==
::
++  handle-exchange-request
  |=  [text=@t ship=@p our=@p now=@da]
  =/  sym=symkey  -:(generate-keys our ?:(=(our ~bud) ~nec ~bud))
  =/  =dead-drop  (sham [round.state sym])
  ~&  >>  "sending message {<text>} to"
  ~&  >>  "{<ship>} through {<entry-server>}"
  ~&  >>  "dead-drop: {<dead-drop>}"
  =/  =encrypted-text  (en:crub:crypto sym text)
  =/  [sym=symkey pub=pubkey]  (generate-keys our ~zod)
  =/  =exchange-request  [%exchange-request dead-drop encrypted-text]
  =/  forward-onion-1=forward-onion
    [pub (en:crub:crypto sym (jam exchange-request))]
  =/  [sym=symkey pub=pubkey]  (generate-keys our ~nus)
  =/  forward-onion-2=forward-onion
    [pub (en:crub:crypto sym (jam forward-onion-1))]
  :-  :~
        :*  %pass  /vuvuzela/chain  %agent
            [entry-server %vuvuzela-entry-server]
            %poke  %noun  !>([%forward-onion forward-onion-2])
        ==
      ==
  %=  state
    chat  %:  update-chat
            chat.state
            ship
            [now text %.y]
          ==
    round-partner  (some ship)
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
    =.  crypto-core.ames-state.our-vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.our-vane
    =/  our-pub  pub:ex:crypto-core.ames-state.our-vane
    =.  crypto-core.ames-state.their-vane  (pit:nu:crub:crypto 512 (shaz their))
    =/  their-pub  pub:ex:crypto-core.ames-state.their-vane
    =/  sym  (derive-symmetric-key:vane their-pub our-sec)
    [sym our-pub]
--

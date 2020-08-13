/-  vuvuzela
/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 =chat:vuvuzela]
    ==
::
+$  card  card:agent:gall
::
++  server  ~marzod
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
  =.  state  [%0 ~]
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
  `this(state [%0 ~])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    =/  payload  q.vase
    ?+    payload  (on-poke:def mark vase)
        action:vuvuzela
      =^  cards  state
      (handle-action !<(action:vuvuzela vase) bowl)
      [cards this]
        [%receive-message @ @]
      =^  cards  state
      (handle-received-message +.payload bowl)
      [cards this]
    ==
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ~&  >  "package received by {<src.bowl>}"
  `this
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-received-message
  |=  [[blob=@ sender=@p] =bowl:gall]
  ^-  (quip card _state)
  =/  key  (generate-key bowl)
  =/  decrypt  (de:crub:crypto key blob)
  ?~  decrypt  ~&(>>> "failed to decrypt" `state)
  =/  text=@t  +.decrypt
  ~&  >>  "received message {<text>} from {<sender>} through {<src.bowl>}"
  :-  ~
    %=  state
      chat  %:  update-chat
              chat.state
              sender
              [now.bowl text %.n]
            ==
    ==
++  handle-action
  |=  [=action:vuvuzela =bowl:gall]
  ^-  (quip card _state)
  ?-    -.action
      %send-message
    ~&  >>  "sending message {<text.action>} to {<ship.action>} through {<server>}"
    =/  key  (generate-key bowl)
    :-  :~
          :*  %pass  /vuvuzela-wire  %agent
              [server %vuvuzela-server]
              %poke  %noun
              !>([%forward-message (en:crub:crypto key text.action) ship.action])
          ==
        ==
    %=  state
      chat  %:  update-chat
              chat.state
              ship.action
              [now.bowl text.action %.y]
            ==
    ==
    ::
      %show-chat
    ~&  >>>  :-(ship.action (~(get by chat.state) ship.action))
    `state
  ==
  ::
  ++  update-chat
  |=  [=chat:vuvuzela ship=@p =message:vuvuzela]
  =/  messages  (fall (~(get by chat) ship) ~)
  =/  updated-messages  (snoc messages message)
  (~(put by chat) ship updated-messages)
  ::  Create fake keys for testing fake ships
  ::  ~milrys-soglec and ~dapnep-ronmyl
  ::
  ++  generate-key
    |=  =bowl:gall
    ^-  @uwsymmetrickey
    =/  vane  (ames !>(..zuse))
    =/  our  our.bowl
    =/  their  ?:(=(our ~milrys-soglec) ~dapnep-ronmyl ~milrys-soglec)
    =/  our-vane  vane
    =/  their-vane  vane
    =.  crypto-core.ames-state.our-vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.our-vane
    =.  crypto-core.ames-state.their-vane  (pit:nu:crub:crypto 512 (shaz their))
    =/  their-pub  pub:ex:crypto-core.ames-state.their-vane
    =/  sym  (derive-symmetric-key:vane their-pub our-sec)
    sym
--

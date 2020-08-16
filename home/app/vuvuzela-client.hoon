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
++  servers  (limo ~[~nus ~wes ~zod])
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
        [%receive-message @]
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
  |=  [blob=@ =bowl:gall]
  ^-  (quip card _state)
  =/  key  (generate-key bowl)
  =/  decrypt  (de:crub:crypto key blob)
  ?~  decrypt  ~&(>>> "failed to decrypt" `state)
  =/  text=@t  +.decrypt
  ~&  >>  "received message {<text>} through {<src.bowl>}"
  `state
++  handle-action
  |=  [=action:vuvuzela =bowl:gall]
  ^-  (quip card _state)
  ?-    -.action
      %leave-dead-drop
    =/  server  (snag 0 servers)
    =/  key  (generate-key bowl)
    =/  encrypted-message  (en:crub:crypto key text.action)
    =/  dead-drop  (sham [0 key])
    ~&  >>  "sending message {<text.action>} to {<ship.action>} through {<server>}"
    ~&  >>  "dead drop: {<dead-drop>}"
    :-  :~
          :*  %pass  /vuvuzela-wire  %agent
              [server %vuvuzela-server]
              %poke  %noun
              !>([%leave-dead-drop encrypted-message dead-drop])
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
      %check-dead-drop
    =/  server  (snag 0 servers)
    =/  key  (generate-key bowl)
    =/  dead-drop  (sham [0 key])
    :_  state
    :~
      :*  %pass  /vuvuzela-wire  %agent
          [server %vuvuzela-server]
          %poke  %noun
          !>([%check-dead-drop dead-drop])
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
  ::
  ++  generate-key
    |=  =bowl:gall
    ^-  @uwsymmetrickey
    =/  vane  (ames !>(..zuse))
    =/  our  our.bowl
    =/  their  ?:(=(our ~bud) ~nec ~bud)
    =/  our-vane  vane
    =/  their-vane  vane
    =.  crypto-core.ames-state.our-vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.our-vane
    =.  crypto-core.ames-state.their-vane  (pit:nu:crub:crypto 512 (shaz their))
    =/  their-pub  pub:ex:crypto-core.ames-state.their-vane
    =/  sym  (derive-symmetric-key:vane their-pub our-sec)
    sym
--

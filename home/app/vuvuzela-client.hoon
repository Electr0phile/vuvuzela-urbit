/-  vuvuzela
/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 =chat:vuvuzela round-partner=(unit @p) round=@]
    ==
::
+$  card  card:agent:gall
::
++  servers  (limo ~[~nus ~wes ~zod])
++  entry-server  (snag 0 servers)
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
    =/  payload  q.vase
    ?+    payload  (on-poke:def mark vase)
        action:vuvuzela
      =^  cards  state
      (handle-action !<(action:vuvuzela vase) our.bowl now.bowl)
      [cards this]
        [%receive-message @]
      =^  cards  state
      (handle-receive-message +.payload our.bowl now.bowl)
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
  ?+    wire  (on-agent:def wire sign)
      [%vuvuzela %message ~]
    ~&  >  "package received by {<src.bowl>}"
    `this
      [%vuvuzela %rounds @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ~&  >  "round {<+.q.cage.sign>} starts"
      `this(state state(round !<(@ q.cage.sign), round-partner ~))
    ==
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-receive-message
  |=  [message=@ our=@p now=@da]
  ^-  (quip card _state)
  =/  key  (generate-key our ?:(=(our ~bud) ~nec ~bud))
  =/  decrypted  (de:crub:crypto key message)
  ?~  decrypted  ~&(>>> "failed to decrypt" `state)
  =/  text=@t  +.decrypted
  ?~  round-partner.state
    ~&  >>>  "mistakenly received message"
    `state
  ~&  >>  "received message {<text>}"
  :-  ~
  %=  state
    round-partner  ~
    chat  %:  update-chat
            chat.state
            +.round-partner.state
            [now text %.y]
          ==
  ==
++  handle-action
  |=  [=action:vuvuzela our=@p now=@da]
  ^-  (quip card _state)
  ?-    -.action
    ::
      %subscribe
    :_  state
    :~
      :*  %pass  /vuvuzela/rounds/(scot %p our)  %agent
          [entry-server %vuvuzela-server]
          [%watch /vuvuzela/rounds]
      ==
    ==
    ::
      %show-chat
    ~&  >>>  :-(ship.action (~(get by chat.state) ship.action))
    `state
    ::
      %check-dead-drop
    =/  key  (generate-key our ship.action)
    =/  dead-drop  (sham [round.state key])
    :_  state(round-partner (some ship.action))
    :~
      :*  %pass  /vuvuzela  %agent
          [entry-server %vuvuzela-server]
          %poke  %noun
          !>([%check-dead-drop dead-drop])
      ==
    ==
    ::
      %leave-dead-drop
    =/  key  (generate-key our ?:(=(our ~bud) ~nec ~bud))
    =/  message  (en:crub:crypto key text.action)
    =/  dead-drop  (sham [round.state key])
    ~&  >>  "sending message {<text.action>} to"
    ~&  >>  "{<ship.action>} through {<entry-server>}"
    ~&  >>  "dead drop: {<dead-drop>}"
    :-  :~
          :*  %pass  /vuvuzela  %agent
              [entry-server %vuvuzela-server]
              %poke  %noun
              !>([%leave-dead-drop message dead-drop])
          ==
        ==
    %=  state
      chat  %:  update-chat
              chat.state
              ship.action
              [now text.action %.y]
            ==
    ==
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
    |=  [our=@p their=@p]
    ^-  @uwsymmetrickey
    =/  vane  (ames !>(..zuse))
    =/  our-vane  vane
    =/  their-vane  vane
    =.  crypto-core.ames-state.our-vane  (pit:nu:crub:crypto 512 (shaz our))
    =/  our-sec  sec:ex:crypto-core.ames-state.our-vane
    =.  crypto-core.ames-state.their-vane  (pit:nu:crub:crypto 512 (shaz their))
    =/  their-pub  pub:ex:crypto-core.ames-state.their-vane
    =/  sym  (derive-symmetric-key:vane their-pub our-sec)
    sym
--

/-  vuvuzela
/+  default-agent
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
--
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
    ?+    q.vase
      =^  cards  state
      (handle-action !<(action:vuvuzela vase) bowl)
      [cards this]
        [%receive-message @]
      =^  cards  state
      (handle-received-message +.q.vase bowl)
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
  ~&  >  "message received by {<src.bowl>}"
  `this
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-received-message
  |=  [text=@t =bowl:gall]
  ~&  >>  "received message {<text>} from {<src.bowl>}"
  ^-  (quip card _state)
  :-  ~
    %=  state
      chat  %:  update-chat
              chat.state
              src.bowl
              [now.bowl text %.n]
            ==
    ==
++  handle-action
  |=  [=action:vuvuzela =bowl:gall]
  ^-  (quip card _state)
  ?-    -.action
      %send-message
    ~&  >>  "sending message {<text.action>} to {<ship.action>}"
    :_  %=  state
          chat  %:  update-chat
                  chat.state
                  ship.action
                  [now.bowl text.action %.y]
                ==
        ==
    :~
      :*  %pass  /vuvuzela-wire  %agent
          [ship.action %vuvuzela-client]
          %poke  %noun  !>([%receive-message text.action])
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
--

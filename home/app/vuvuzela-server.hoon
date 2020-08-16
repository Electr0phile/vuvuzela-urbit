/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 drops=(map dead-drop encrypted-message) round=@]
    ==
::
+$  dead-drop  @uvH
+$  encrypted-message  @
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
  ~&  >  '%vuvuzela-server initialized successfully'
  =.  state  [%0 ~ 0]
  `this
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%vuvuzela-server recompiled successfully'
  `this(state [%0 ~ 0])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    =/  payload  q.vase
    ?+    payload  (on-poke:def mark vase)
        [%leave-dead-drop @ @]
      =^  cards  state
      (handle-leave-dead-drop +.payload)
      [cards this]
        [%check-dead-drop @]
      =^  cards  state
      (handle-check-dead-drop +.payload src.bowl)
      [cards this]
        %start-new-round
      :_  this(state state(round +(round.state)))
      ~[[%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]]
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
++  handle-leave-dead-drop
  |=  [message=@ dead-drop=@]
  ~&  >>  "received dead drop {<dead-drop>}"
  ^-  (quip card _state)
  `state(drops (~(put by drops.state) dead-drop message))
++  handle-check-dead-drop
  |=  [dead-drop=@ src=@p]
  ^-  (quip card _state)
  ~&  >>>  "requested dead drop {<dead-drop>} by {<src>}"
  =/  message  (~(get by drops.state) dead-drop)
  ?~  message
    `state
  :_  state
  :~
    :*  %pass  /vuvuzela  %agent
        [src %vuvuzela-client]
        %poke  %noun
        !>([%receive-message +.message])
    ==
  ==
--

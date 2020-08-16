/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 drops=(map dead-drop encrypted-message) round=@ wake-time=@da manual-rounds=?]
    ==
::
+$  dead-drop  @uvH
+$  encrypted-message  @
::
+$  card  card:agent:gall
::
++  servers  (limo ~[~nus ~wes ~zod])
++  round-duration  ~s1
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
  =.  state  [%0 ~ 0 now.bowl %.y]
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
  `this(state [%0 ~ 0 now.bowl %.y])
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
      (leave-dead-drop +.payload)
      [cards this]
        [%check-dead-drop @]
      =^  cards  state
      (check-dead-drop +.payload src.bowl)
      [cards this]
        %rest
      ~&  >  "resting..."
      :_  this(state state(manual-rounds %.y))
      [%pass /vuvuzela/timer %arvo %b %rest wake-time.state]~
        %wait
      ~&  >  "waiting again..."
      =/  wake-time  (add now.bowl round-duration)
      :_  this(state state(round +(round.state), wake-time wake-time, manual-rounds %.n, drops ~))
      :~  [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]
          [%pass /vuvuzela/timer %arvo %b %wait wake-time]
      ==
        %reset-round
      ?.  manual-rounds.state
        ~&  >>  "not in manual mode! use %rest to switch to manual rounds"
        `this
      :_  this(state state(round +(round.state), drops ~))
      [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]~
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
  ~&  >>>  "on-agent received"
  `this
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%vuvuzela %timer ~]
    ~&  >>>  "resetting round"
    =/  wake-time  (add now.bowl round-duration)
    :_  this(state state(round +(round.state), wake-time wake-time, drops ~))
    :~  [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]
        [%pass /vuvuzela/timer %arvo %b %wait wake-time]
    ==
  ==
++  on-fail   on-fail:def
--
|%
++  leave-dead-drop
  |=  [message=@ dead-drop=@]
  ~&  >>  "received dead drop {<dead-drop>}"
  ^-  (quip card _state)
  `state(drops (~(put by drops.state) dead-drop message))
++  check-dead-drop
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

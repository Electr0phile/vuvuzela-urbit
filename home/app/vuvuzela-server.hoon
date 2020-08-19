/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 drops=(map dead-drop message) round=@ wake-time=@da manual-rounds=? requests=(list request)]
    ==
::
+$  leave-request  [%leave-dead-drop =message =dead-drop]
+$  check-request  [%check-dead-drop =dead-drop]
+$  request
    $%
      leave-request
      check-request
    ==
+$  dead-drop  @uvH
+$  message  @
::
+$  card  card:agent:gall
::
++  servers  (limo ~[~nus ~nus])
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
  =.  state  [%0 ~ 0 now.bowl %.y ~]
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
  `this(state [%0 ~ 0 now.bowl %.y ~])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    =/  payload  q.vase
    ?+    payload  (on-poke:def mark vase)
      ::
        request
      ~&  >  "request queued"
      `this(state state(requests (snoc requests.state payload)))
      ::
        [%process-requests *]
      =/  requests  ((list request) +.payload)
      ~&  >  "processing requests..."
      =^  cards  state
      (process-requests requests)
      [cards this]
      ::
        %rest
      ~&  >  "resting..."
      :_  this(state state(manual-rounds %.y))
      [%pass /vuvuzela/timer %arvo %b %rest wake-time.state]~
      ::
        %wait
      ~&  >  "waiting again..."
      =/  wake-time  (add now.bowl round-duration)
      :_  this(state state(round +(round.state), wake-time wake-time, manual-rounds %.n, drops ~))
      :~  [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]
          [%pass /vuvuzela/timer %arvo %b %wait wake-time]
      ==
      ::
        %send-out-requests
      :_  this
      [%pass /vuvuzela/chain/forward %agent [~nus %vuvuzela-server] %poke %noun !>([%process-requests requests.state])]~
      ::
        %reset-round
      ?.  manual-rounds.state
        ~&  >>  "not in manual mode! use %rest to switch to manual rounds"
        `this
      :_  this(state state(round +(round.state), drops ~, requests ~))
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
    :_  this(state state(round +(round.state), wake-time wake-time, drops ~, requests ~))
    :~  [%give %fact ~[/vuvuzela/rounds] %atom !>(+(round.state))]
        [%pass /vuvuzela/timer %arvo %b %wait wake-time]
    ==
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-fail   on-fail:def
--
|%
++  process-requests
  |=  [requests=(list request)]
  ^-  (quip card _state)
  =/  leave-requests
    (murn requests |=(a=request ^-((unit request) ?:(=(-.a %leave-dead-drop) [~ a] ~))))
  =/  check-requests
    (murn requests |=(a=request ^-((unit request) ?:(=(-.a %check-dead-drop) [~ a] ~))))
  =/  new-drops  +:(spin ((list leave-request) leave-requests) drops.state leave-dead-drop)
  =/  unit-cards=(list (unit))  -:(spin ((list check-request) check-requests) ~nus check-dead-drop)
  =/  cards=(list card)  (murn unit-cards |=(a=(unit card) a))
  [cards state(drops new-drops)]
++  leave-dead-drop
  |=  [[@tas =message =dead-drop] drops=(map dead-drop message)]
  ~&  >>  "received dead drop {<dead-drop>}"
  ^-  [~ _drops]
  [~ (~(put by drops) dead-drop message)]
++  check-dead-drop
  |=  [=check-request src=@p]
  =/  dead-drop  dead-drop.check-request
  ^-  [(unit card) _src]
  ~&  >>>  "requested dead drop {<dead-drop>} by {<src>}"
  =/  message  (~(get by drops.state) dead-drop)
  ?~  message
    [~ src]
  :-
    :-  ~
    :*  %pass  /vuvuzela  %agent
        [src %vuvuzela-client]
        %poke  %noun
        !>([%receive-message +.message])
    ==
  src
--

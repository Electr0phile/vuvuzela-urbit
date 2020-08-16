/-  vuvuzela
/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 drops=(map dead-drop encrypted-message)]
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
  ~&  >  '%vuvuzela-server recompiled successfully'
  `this(state [%0 ~])
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
++  handle-leave-dead-drop
  |=  [encrypted-message=@ dead-drop=@]
  ~&  >>  "received dead drop {<dead-drop>}"
  ^-  (quip card _state)
  `state(drops (~(put by drops.state) dead-drop encrypted-message))
++  handle-check-dead-drop
  |=  [dead-drop=@ src=@p]
  ^-  (quip card _state)
  ~&  >>>  "requested dead drop {<dead-drop>} by {<src>}"
  =/  encrypted-message  (~(get by drops.state) dead-drop)
  ?~  encrypted-message
    `state
  :_  state
  :~
    :*  %pass  /vuvuzela-wire  %agent
        [src %vuvuzela-client]
        %poke  %noun
        !>([%receive-message +.encrypted-message])
    ==
  ==
--

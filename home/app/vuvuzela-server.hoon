/-  vuvuzela
/+  default-agent, dbug
|%
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state=~
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%vuvuzela-server initialized successfully'
  =.  state  ~
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
  `this(state ~)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    =/  payload  q.vase
    ?+    payload  (on-poke:def mark vase)
        [%forward-message @ @]
      =^  cards  state
      (handle-forward-message +.payload bowl)
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
++  handle-forward-message
  |=  [[text=@t recipient=@p] =bowl:gall]
  ~&  >>  "forwarding message {<text>} from {<src.bowl>} to {<recipient>}"
  ^-  (quip card _state)
  :_  state
  :~
    :*  %pass  /vuvuzela-wire  %agent
        [recipient %vuvuzela-client]
        %poke  %noun  !>([%receive-message text src.bowl])
    ==
  ==
--

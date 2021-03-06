::    Vuvuzela clien
::
::  Talks to:
::    - entry server
::    - end server
::
::  Responsibilities:
::    - dialling
::    Put self-identifying information into a crypt
::  and onion-encrypt it with temporary keys. Then
::  receive all group dead drops from end
::  server and try to decrypt all of the dials.
::  Successfully decrypted dials are added to active
::  conversations.
::    - conversation
::    Put message into a crypt, onion-encrypt it.
::  Then receive response from entry server and decrypt
::  all layers for each server in the chain.
::    - abstraction
::    Timed-round logic of server interaction has to
::  be isolated from user. Implementation: when user
::  starts a conversation with a new client, push this
::  client into a dialling queue. Same with a message -
::  to a message queue.
::
/-  *vuvuzela
/+  default-agent, dbug
/=  ames  /sys/vane/ames
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
  [%0 =chat round-partner=(unit @p) round-number=@ num-groups=@ out-message-queue=(list out-message) entry-server=(unit @p) end-server=(unit @p)]
::
+$  card  card:agent:gall
::  Client-side messaging history.
::
+$  message  [date=@da text=@t my=?(%.y %.n)]
+$  out-message  [receiver=@p text=@t]
+$  chat  (map ship=@p (list message))
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
  =.  state  [%0 ~ ~ 0 0 ~ ~ ~]
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
  `this(state [%0 ~ ~ 0 0 ~ (some ~nus) (some ~zod)])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        ::  Set up entry and end servers
        ::
        [%chain @ @]
      `this(state state(entry-server (some +<.q.vase), end-server (some +>.q.vase)))
        ::  Dial another client, initiating an exchange
        ::
        [%dial @]
      =^  cards  state
      (handle-dial +.q.vase our.bowl)
      [cards this]
        ::  Request exchange of text with some ship
        ::
        ::
        [%send-message @ @]
      ?~  entry-server.state
        ~&  >>>  "entry-server is not specified"
        `this
      =.  out-message-queue.state
        (snoc out-message-queue.state [+>.q.vase +<.q.vase])
      `this
        ::  Process response from entry-server
        ::
        [%convo-bonion @]
      =^  cards  state
      (handle-bonion +.q.vase our.bowl now.bowl)
      [cards this]
        ::
        %subscribe-for-rounds
      ?~  entry-server.state
        ~&  >>>  "entry-server is not specified"
        `this
      =/  entry-server  u.entry-server.state
      :_  this
      :~
        :*  %pass  /vuvuzela/rounds/(scot %p our.bowl)
            %agent  [entry-server %vuvuzela-entry-server]
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
      [%vuvuzela %chain ~]
    ~&  >  "fonion received by {<src.bowl>}"
    `this
      ::
      [%vuvuzela %dials @ @ ~]
    ~&  >  "group wire {wire} used"
    ::  TODO: process dialling requests
    ::
    `this
      ::
      [%vuvuzela %rounds @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    +.q.cage.sign  (on-agent:def wire sign)
          [%convo @]
        ~&  >  "{<+<.q.cage.sign>} round {<+>.q.cage.sign>} starts"
        ::  TODO: automatically send away conversation requests
        ::
        =.  state  state(round-number +>.q.cage.sign, round-partner ~)
        =^  cards  state
        (handle-exchange our.bowl now.bowl)
        [cards this]
          ::
          [%dial @ @]
        ~&  >  "{<+<.q.cage.sign>} round {<+>-.q.cage.sign>} starts, {<+>+.q.cage.sign>} groups"
        ::  TODO: automatically send away dialling requests
        ::
        ?~  end-server.state
          ~&  >>>  "end-server is not specified"
          `this
        =/  end-server  u.end-server.state
        =/  num-groups  +>+.q.cage.sign
        =/  our-pub  +<:(generate-keys our.bowl end-server)
        ~&  >  "subscribing to the end-server group {<(mod our-pub num-groups)>}"
        :_  this(state state(round-number +>-.q.cage.sign, round-partner ~, num-groups num-groups))
        :~
          :*  %pass  /vuvuzela/dials/(scot %ud (mod our-pub num-groups))/(scot %p our.bowl)
              %agent  [end-server %vuvuzela-end-server]
              [%watch /vuvuzela/dials/(scot %ud (mod our-pub num-groups))]
          ==
        ==
      ==
    ==
  ==
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|%
++  handle-dial
  |=  [ship=@p our=@p]
  ^-  (quip card _state)
  ?~  entry-server.state
    ~&  >>>  "entry-server is not specified"
    `state
  =/  entry-server  u.entry-server.state
  ~&  >  "dialing {<ship>}"
  =/  [sym=symkey our-pub=pubkey their-pub=pubkey]
    (generate-keys our ?:(=(our ~bud) ~nec ~bud))
  =/  =crypt  (en:crub:crypto sym our)
  =/  =dead-drop  [(mod their-pub num-groups.state) crypt]
  =/  =fonion  (onion-encrypt dead-drop our)
  :_  state
    :~
      :*  %pass  /vuvuzela/client
          %agent  [entry-server %vuvuzela-entry-server]
          %poke  %noun
          !>([%dial-fonion fonion])
      ==
    ==
++  handle-exchange
  |=  [our=@p now=@da]
  ?~  entry-server.state
    ~&  >>>  "entry-server is not specified"
    `state
  =/  entry-server  u.entry-server.state
  ?~  out-message-queue.state
    `state
  =/  [ship=@p text=@tas]  (snag 0 `(list out-message)`out-message-queue.state)
  =/  sym=symkey
    -:(generate-keys our ?:(=(our ~bud) ~nec ~bud))
  =/  =hash  (sham [round-number.state sym])
  ~&  >  "sending message {<text>} to"
  ~&  >  "{<ship>} through {<entry-server>}"
  ~&  >>  "dead-drop hash: {<hash>}"
  =/  =crypt  (en:crub:crypto sym text)
  ~&  >  "{<+:(cue crypt)>}"
  =/  =dead-drop  [hash crypt]
  =/  =fonion  (onion-encrypt dead-drop our)
  :_
    %=  state
      chat  %^  update-chat
              chat.state
              ship
              [now text %.y]
      round-partner  (some ship)
      out-message-queue
        (oust [0 1] `(list out-message)`out-message-queue.state)
    ==
  :~
    :*  %pass  /vuvuzela/client
        %agent  [entry-server %vuvuzela-entry-server]
        %poke  %noun
        !>([%convo-fonion fonion])
    ==
  ==
::
++  onion-encrypt
  |=  [=dead-drop our=@p]
  ^-  fonion
  =/  fonion-1=fonion  (create-fonion dead-drop our ~zod)
  =/  fonion-2=fonion  (create-fonion fonion-1 our ~wes)
  =/  fonion-3=fonion  (create-fonion fonion-2 our ~nus)
  fonion-3
::
++  create-fonion
  |=  [in=?(dead-drop fonion) our=@p their=@p]
  ^-  fonion
  =/  [sym=symkey pub=pubkey *]  (generate-keys our their)
  [pub (en:crub:crypto sym (jam in))]
::
++  handle-bonion
  |=  [in=bonion our=@p now=@da]
  ^-  (quip card _state)
  ?~  round-partner.state
    ~&  >>>  "mistakenly received message"
    `state
  =/  text=@t  (onion-decrypt in our)
  ~&  >>  "received message {<text>} from {<u.round-partner.state>}"
  :-  ~
  %=  state
    round-partner  ~
    chat  %^  update-chat
            chat.state
            +.round-partner.state
            [now text %.n]
  ==
::
++  onion-decrypt
  |=  [in=bonion our=@p]
  ^-  @t
  =/  bonion-1  (bonion (decrypt-bonion in our ~nus))
  =/  bonion-2  (bonion (decrypt-bonion bonion-1 our ~wes))
  ?:  =(1.337 bonion-2)
    ~&  >>>  "partner did not receive message"
    !!
  =/  bonion-3  (bonion (decrypt-bonion bonion-2 our ~zod))
  (@t (decrypt-bonion bonion-3 our ?:(=(our ~bud) ~nec ~bud)))
::
++  decrypt-bonion
  |=  [in=bonion our=@p their=@p]
  ^-  ?(bonion @t)
  =/  key  -:(generate-keys our their)
  =/  dec=(unit @)  (de:crub:crypto key in)
  ?~  dec
    ~&  >>>  "error decrypting {<their>} layer"
    !!
  u.dec
::  Create fake keys for testing fake ships
::
++  generate-keys
  |=  [our=@p their=@p]
  ^-  [symkey pubkey pubkey]
  =/  vane  (ames !>(..zuse))
  =/  our-vane  vane
  =/  their-vane  vane
  =.  crypto-core.ames-state.our-vane
    (pit:nu:crub:crypto 512 (shaz our))
  =/  our-sec  sec:ex:crypto-core.ames-state.our-vane
  =/  our-pub  pub:ex:crypto-core.ames-state.our-vane
  =.  crypto-core.ames-state.their-vane
    (pit:nu:crub:crypto 512 (shaz their))
  =/  their-pub  pub:ex:crypto-core.ames-state.their-vane
  =/  sym  (derive-symmetric-key:vane their-pub our-sec)
  [sym our-pub their-pub]
::
++  update-chat
  |=  [=chat ship=@p =message]
  =/  messages  (fall (~(get by chat) ship) ~)
  =/  updated-messages  (snoc messages message)
  (~(put by chat) ship updated-messages)
--

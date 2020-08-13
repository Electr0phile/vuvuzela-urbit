/=  ames  /sys/vane/ames
|=  message=@
::
=/  vane  (ames !>(..zuse))
~&  >  "Current public key: {<pub:ex:crypto-core.ames-state.vane>}"
~&  >  "Our: {<our.vane>}"
::
=/  nec  vane
=/  bud  vane
::
=.  our.nec        ~nec
=.  now.nec        ~1111.1.1
=.  eny.nec        0xdead.beef
=.  scry-gate.nec  |=(* ``[%noun !>(*(list turf))])
::
=.  our.bud          ~bud
=.  now.bud          ~1111.1.1
=.  eny.bud          0xbeef.dead
=.  scry-gate.bud    |=(* ``[%noun !>(*(list turf))])
::
=.  crypto-core.ames-state.nec  (pit:nu:crub:crypto 512 (shaz 'nec'))
=.  crypto-core.ames-state.bud  (pit:nu:crub:crypto 512 (shaz 'bud'))
::
=/  nec-pub  pub:ex:crypto-core.ames-state.nec
=/  nec-sec  sec:ex:crypto-core.ames-state.nec
=/  bud-pub  pub:ex:crypto-core.ames-state.bud
=/  bud-sec  sec:ex:crypto-core.ames-state.bud
::
=/  nec-sym  (derive-symmetric-key:vane bud-pub nec-sec)
=/  bud-sym  (derive-symmetric-key:vane nec-pub bud-sec)
::
?>  =(nec-sym bud-sym)
=/  sym  nec-sym
::
=/  encrypted  (en:crub:crypto sym message)
~&  >  "encrypted message: {<encrypted>}"
=/  decrypted  (de:crub:crypto sym encrypted)
~&  >  "decrypted message: {<decrypted>}"
~

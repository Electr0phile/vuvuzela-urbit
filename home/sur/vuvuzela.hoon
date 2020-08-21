::  crypt is a client-to-client encrypted text
::  hash is a dead-drop hash, for two clients
::    willing to talk it is the same
::  dead-drop is a pair of two which is only
::    accessed on the end-server to pair up
::    clients
::  onion is a message with >1 layers of encryption
::  fonion = forward onion
::    Travels only in client -> end server direction.
::    Encrypted in nus->wes->zod order if chain is
::      (entry)->zod->wes->nus->(end).
::    Each server peels off a layer using own private
::      key and fonion's public key.
::    Each round client's public-private pair for each
::      server is generated anew.
::  bonion = backward onion
::    Travels only in end server -> client direction.
::    Each server encrypts it using own private key
::      and pubkey obtained from forward pass.
::
|%
  +$  symkey  @uwsymmetrickey
  +$  pubkey  @uwpublickey
  +$  crypt  @
  +$  hash  @
  +$  dead-drop  [=hash =crypt]
  +$  fonion  [pub=pubkey payload=@]
  +$  bonion  @
--

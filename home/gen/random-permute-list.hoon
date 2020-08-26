::  Accept a list and return
::  randomly shuffled list and corresponding
::  permutation.
::
=<
|=  [in=(list [@ @]) eny=@]
^-  [(list [@ @]) (list @)]
=/  permutation=(list @)
  (generate-permutation (lent in) eny)
=/  out=(list [@ @])  ~
=/  i  0
=/  in-length  (lent in)
|-
?:  =(i in-length)  [out permutation]
%=  $
  out  (snoc `(list [@ @])`out (snag (snag i permutation) in))
  i  +(i)
==
|%
++  generate-permutation
  |=  [length=@ eny=@]
  ^-  (list @)
  ?:  =(length 0)
    ~
  =/  indices=(list @)  (gulf 0 (dec length))
  =|  permutation=(list @)
  =/  random  ~(. og eny)
  |-
  ?~  indices
    permutation
  =/  [i=@ next-random=_random]  (rads.random (lent indices))
  %=  $
    permutation
      [(snag i `(list @)`indices) permutation]
    indices  (oust [i 1] `(list @)`indices)
    random  next-random
  ==
--

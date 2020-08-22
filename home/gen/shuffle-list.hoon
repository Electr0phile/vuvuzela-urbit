::  simple shuffling function
::
|%
++  generate-permutation
  |=  [length=@ eny=@]
  ^-  (list @)
  =/  indices=(list @)  (gulf 0 (dec length))
  =|  permutation=(list @)
  =/  random  ~(. og eny)
  |-
  ?~  indices
    permutation
  =/  [i=@ r=_random]  (rads.random (lent indices))
  %=  $
    permutation
      [(snag i `(list @)`indices) permutation]
    indices  (oust [i 1] `(list @)`indices)
    random  r
  ==
--
|=  [n=@ eny=@]
=/  frequency-table=(list (list @))
  :~
    ~[0 0 0 0 0]
    ~[0 0 0 0 0]
    ~[0 0 0 0 0]
    ~[0 0 0 0 0]
    ~[0 0 0 0 0]
  ==
^-  _frequency-table
|-
?:  =(n 0)
  frequency-table
=/  sample=(list @)  (generate-permutation 5 eny)
=/  r0  (snag 0 frequency-table)
=/  r1  (snag 1 frequency-table)
=/  r2  (snag 2 frequency-table)
=/  r3  (snag 3 frequency-table)
=/  r4  (snag 4 frequency-table)
%=  $
  n  (dec n)
  eny  +(eny)
  frequency-table
    :~
      (snap r0 (snag 0 sample) +((snag (snag 0 sample) r0)))
      (snap r1 (snag 1 sample) +((snag (snag 1 sample) r1)))
      (snap r2 (snag 2 sample) +((snag (snag 2 sample) r2)))
      (snap r3 (snag 3 sample) +((snag (snag 3 sample) r3)))
      (snap r4 (snag 4 sample) +((snag (snag 4 sample) r4)))
    ==
==
::

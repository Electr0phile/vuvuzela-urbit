::  simple shuffling function
::
|=  [l=(list) eny=@]
=|  out=(list)
|-
^-  (list)
?~  l
  out
=/  i=@  (~(rad og eny) (lent l))
$(out (snoc out (snag i `(list)`l)), l (oust [i 1] `(list)`l))

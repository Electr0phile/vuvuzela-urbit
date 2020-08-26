|=  [in=(list @) permutation=(list @)]
^-  (list @)
=/  in-length  (lent in)
=/  out=(list @)  (reap in-length 0)
=/  i  0
|-
?:  =(i in-length)
  out
%=  $
  out  (snap out (snag i permutation) (snag i in))
  i  +(i)
==

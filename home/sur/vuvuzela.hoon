|%
+$  message  [date=@da text=@t my=?(%.y %.n)]
:::
+$  chat  (map ship=@p (list message))
::
+$  action
  $%  [%send-message text=@t ship=@p]
      [%show-chat ship=@p]
  ==
--

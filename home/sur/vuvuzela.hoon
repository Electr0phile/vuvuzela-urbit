|%
+$  message  [date=@da text=@t my=?(%.y %.n)]
::
+$  chat  (map ship=@p (list message))
:::
+$  action
  $%  [%leave-dead-drop text=@t ship=@p]
      [%check-dead-drop ship=@p]
      [%show-chat ship=@p]
  ==
--

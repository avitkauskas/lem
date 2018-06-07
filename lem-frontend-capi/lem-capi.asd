(defsystem "lem-capi"
  :depends-on ("lem")
  :serial t
  :components ((:file "package")
               (:file "util")
               (:file "input")
               (:file "lem-pane")
               (:file "main")
               (:file "popup-menu")))

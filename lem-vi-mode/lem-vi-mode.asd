(defsystem "lem-vi-mode"
  :depends-on (:lem-core)
  :serial t
  :components ((:file "word")
               (:file "commands")
               (:file "vi-mode")))

(in-package :lem)

(let ((garg (gensym "ARG")))
  (defun defcommand-gen-args (name arg-descripters)
    (cond
     ((string= "p" (car arg-descripters))
      `(list (or ,garg 1)))
     ((string= "P" (car arg-descripters))
      `(list ,garg))
     ((string= "r" (car arg-descripters))
      `(if (buffer-check-marked (window-buffer))
         (list (region-beginning) (region-end))
         (return-from ,name nil)))
     (t
      (cons 'list
        (mapcar (lambda (arg-descripter)
                  (cond
                   ((char= #\s (aref arg-descripter 0))
                    `(read-string ,(subseq arg-descripter 1)))
                   ((char= #\b (aref arg-descripter 0))
                    `(read-buffer ,(subseq arg-descripter 1)
                       (buffer-name (window-buffer))
                       t))
                   ((char= #\B (aref arg-descripter 0))
                    `(read-buffer ,(subseq arg-descripter 1)
                       (buffer-name *prev-buffer*)
                       nil))
                   ((char= #\f (aref arg-descripter 0))
                    `(read-file-name
                      ,(subseq arg-descripter 1)
                      (current-directory)
                      nil
                      t))
                   ((char= #\F (aref arg-descripter 0))
                    `(read-file-name
                      ,(subseq arg-descripter 1)
                      (current-directory)
                      nil
                      nil))
                   (t
                    (error "Illegal arg-descripter: ~a" arg-descripter))))
          arg-descripters)))))
  (defun defcommand-gen-cmd (name parms arg-descripters body)
    `(defun ,name (,garg)
       (declare (ignorable ,garg))
       ,(if (null arg-descripters)
          (progn (assert (null parms))
            `(progn ,@body))
          `(destructuring-bind ,parms
             ,(if (stringp (car arg-descripters))
                (defcommand-gen-args name arg-descripters)
                (car arg-descripters))
             ,@body)))))

(defmacro defcommand (name parms (&rest arg-descripters) &body body)
  (let ((gcmd (gensym (symbol-name name))))
    `(progn
      (setf (get ',name 'command) ',gcmd)
      (defun ,name ,parms ,@body)
      ,(defcommand-gen-cmd gcmd parms arg-descripters body))))

(defun cmd-call (cmd arg)
  (funcall (get cmd 'command) arg))

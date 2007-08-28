;;
;; testing gauche.fileutil and file.* modules
;;

(use gauche.test)
(test-start "file utilities")
(use srfi-1)
(use srfi-13)

;;------------------------------------------------------------------
(test-section "built-in gauche.fileutil")

(define (md p) (sys-mkdir p #o777))
(define (mf p) (with-output-to-file p (cut display "z")))
(define (rmrf p) (sys-system #`"rm -rf ,p"))

(and file-exists? (test-module 'gauche.fileutil)) ;; trigger autoload

(rmrf "tmp1.o")

(define (file-pred-tests path expected)
  (test* #`"file-exists? (,path)" (car expected) (file-exists? path))
  (test* #`"file-is-regular? (,path)" (cadr expected) (file-is-regular? path))
  (test* #`"file-is-directory? (,path)" (caddr expected) (file-is-directory? path)))

(file-pred-tests "tmp1.o" '(#f #f #f))

(with-output-to-file "tmp1.o" (cut display "Z"))

(file-pred-tests "tmp1.o" '(#t #t #f))

(sys-unlink "tmp1.o")
(sys-mkdir "tmp1.o" #o777)

(file-pred-tests "tmp1.o" '(#t #f #t))

(rmrf "tmp1.o")

;;
;; glob test.
;;
(let ()
  (md "tmp1.o")
  (md "tmp1.o/a")
  (mf "tmp1.o/a/b")
  (mf "tmp1.o/a/cc")
  (mf "tmp1.o/a/.d")
  (md "tmp1.o/.a")
  (md "tmp1.o/.a/.d")
  (md "tmp1.o/a.")
  (mf "tmp1.o/a./b")
  (mf "tmp1.o/a./.d")
  (mf "tmp1.o/a.a")
  (mf "tmp1.o/a.b")
  (mf "tmp1.o/a.a.a")

  ;; literal
  (test* "glob a.a" '("tmp1.o/a.a")
         (glob "tmp1.o/a.a")
         (pa$ lset= equal?))

  ;; nomatch
  (test* "glob z" '()
         (glob "tmp1.o/z")
         (pa$ lset= equal?))

  ;; wildcard
  (test* "glob *" '("tmp1.o/a" "tmp1.o/a." "tmp1.o/a.a"
                    "tmp1.o/a.b" "tmp1.o/a.a.a")
         (glob "tmp1.o/*")
         (pa$ lset= equal?))

  (test* "glob a.*" '("tmp1.o/a." "tmp1.o/a.a" "tmp1.o/a.b" "tmp1.o/a.a.a")
         (glob "tmp1.o/a.*")
         (pa$ lset= equal?))

  (test* "glob .*" '("tmp1.o/.a" "tmp1.o/." "tmp1.o/..")
         (glob "tmp1.o/.*")
         (pa$ lset= equal?))

  (test* "glob ?" '("tmp1.o/a")
         (glob "tmp1.o/?")
         (pa$ lset= equal?))

  (test* "glob *?" '("tmp1.o/a" "tmp1.o/a." "tmp1.o/a.a"
                     "tmp1.o/a.b" "tmp1.o/a.a.a")
         (glob "tmp1.o/*?")
         (pa$ lset= equal?))

  (test* "glob *." '("tmp1.o/a.")
         (glob "tmp1.o/*.")
         (pa$ lset= equal?))

  (test* "glob ??" '("tmp1.o/a.")
         (glob "tmp1.o/??")
         (pa$ lset= equal?))

  (test* "glob *.*" '("tmp1.o/a." "tmp1.o/a.a" "tmp1.o/a.b" "tmp1.o/a.a.a")
         (glob "tmp1.o/*.*")
         (pa$ lset= equal?))

  (test* "glob */*" '("tmp1.o/a/b" "tmp1.o/a/cc" "tmp1.o/a./b")
         (glob "tmp1.o/*/*")
         (pa$ lset= equal?))

  (test* "glob */?" '("tmp1.o/a/b" "tmp1.o/a./b")
         (glob "tmp1.o/*/?")
         (pa$ lset= equal?))

  (test* "glob *  (chdir)" '("a" "a." "a.a" "a.b" "a.a.a")
         (begin (sys-chdir "tmp1.o") (begin0 (glob "*") (sys-chdir "..")))
         (pa$ lset= equal?))

  (test* "glob */" '("tmp1.o/a/" "tmp1.o/a./")
         (glob "tmp1.o/*/")
         (pa$ lset= equal?))

  ;; multi
  (test* "glob * .* (multi)" '("tmp1.o/." "tmp1.o/.." "tmp1.o/.a" "tmp1.o/a"
                               "tmp1.o/a." "tmp1.o/a.a" "tmp1.o/a.b"
                               "tmp1.o/a.a.a")
         (glob '("tmp1.o/*" "tmp1.o/.*"))
         (pa$ lset= equal?))

  ;; charset
  (test* "glob a.[ab]" '("tmp1.o/a.a" "tmp1.o/a.b")
         (glob "tmp1.o/a.[ab]")
         (pa$ lset= equal?))
  (test* "glob a.[[:alpha:]]" '("tmp1.o/a.a" "tmp1.o/a.b")
         (glob "tmp1.o/a.[[:alpha:]]")
         (pa$ lset= equal?))
  (test* "glob *.[[:alpha:]]" '("tmp1.o/a.a" "tmp1.o/a.b" "tmp1.o/a.a.a")
         (glob "tmp1.o/*.[[:alpha:]]")
         (pa$ lset= equal?))
  (test* "glob *.[![:alpha:]]" '()
         (glob "tmp1.o/*.[![:alpha:]]")
         (pa$ lset= equal?))
  (test* "glob *.[^[:alpha:]]" '()
         (glob "tmp1.o/*.[^[:alpha:]]")
         (pa$ lset= equal?))
  (test* "glob *.[^A-Z]" '("tmp1.o/a.a" "tmp1.o/a.b" "tmp1.o/a.a.a")
         (glob "tmp1.o/*.[^A-Z]")
         (pa$ lset= equal?))

  (rmrf "tmp1.o")
  )

;;------------------------------------------------------------------
(test-section "file.filter")
(use file.filter)
(test-module 'file.filter)

(sys-unlink "tmp1.o")
(sys-unlink "tmp2.o")
(with-output-to-file "tmp1.o"
  (lambda () (display "aaa bbb ccc ddd\neee fff ggg hhh\n")))

(test* "file.filter tmp1.o -> string"
       "AAA BBB CCC DDDEEE FFF GGG HHH"
       (with-output-to-string
         (lambda ()
           (file-filter (lambda (in out)
                          (port-for-each (lambda (line)
                                           (display (string-upcase line) out))
                                         (lambda () (read-line in))))
                        :input "tmp1.o"))))

(test* "file.filter string -> tmp2.o"
       "AAA BBB CCC DDDEEE FFF GGG HHH"
       (begin
         (with-input-from-string "aaa bbb ccc ddd\neee fff ggg hhh\n"
           (lambda ()
             (file-filter (lambda (in out)
                            (port-for-each (lambda (line)
                                             (display (string-upcase line) out))
                                           (lambda () (read-line in))))
                          :output "tmp2.o")))
         (call-with-input-file "tmp2.o" port->string)))

(sys-unlink "tmp2.o")

(test* "file.filter cleanup" #f
       (with-error-handler
           (lambda (e) (file-exists? "tmp2.o"))
         (lambda ()
           (with-input-from-string "zzz"
             (lambda ()
               (file-filter (lambda (in out) (error "yyy"))
                            :output "tmp2.o"))))))

(sys-unlink "tmp2.o")

(test* "file.filter cleanup" #t
       (with-error-handler
           (lambda (e) (file-exists? "tmp2.o"))
         (lambda ()
           (with-input-from-string "zzz"
             (lambda ()
               (file-filter (lambda (in out) (error "yyy"))
                            :output "tmp2.o"
                            :keep-output? #t))))))

(sys-unlink "tmp2.o")

(test* "file.filter temporary"
       '(#f "AAA BBB CCC DDDEEE FFF GGG HHH")
       (let* ((r1
               (with-input-from-string "aaa bbb ccc ddd\neee fff ggg hhh\n"
                 (lambda ()
                   (file-filter
                    (lambda (in out)
                      (port-for-each (lambda (line)
                                       (display (string-upcase line) out))
                                     (lambda () (read-line in)))
                      (file-exists? "tmp2.o"))
                    :output "tmp2.o"
                    :temporary-file "foo"))))
              (r2
               (call-with-input-file "tmp2.o" port->string)))
         (list r1 r2)))

(sys-unlink "tmp1.o")
(sys-unlink "tmp2.o")

(test-end)

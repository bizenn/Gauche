;;
;; Test gauche.version
;;

;; $Id: version.scm,v 1.2 2003-01-08 03:19:46 shirok Exp $

(use gauche.test)
(test-start "gauche.version")

(use gauche.version)

(test* "relnum-compare" '(-1 0 1)
       (list (relnum-compare "1" "3")
             (relnum-compare "1" "1")
             (relnum-compare "3" "1")))

(test* "relnum-compare" '(-1 0 1)
       (list (relnum-compare "1b" "2a")
             (relnum-compare "1b" "1b")
             (relnum-compare "3a" "1b")))

(test* "relnum-compare" '(-1 0 1)
       (list (relnum-compare "b" "1")
             (relnum-compare "b" "b")
             (relnum-compare "1" "b")))

(define (vercmp x y r)
  (test (format #f "version-compare ~a ~a" x y)
        (list r (- r))
        (lambda ()
          (list (version-compare x y)
                (version-compare y x)))))

(vercmp "1" "1" 0)
(vercmp "2.3" "2.3" 0)
(vercmp "2.34.5b-patch3" "2.34.5b-patch3" 0)
(vercmp "20020202-1" "20020202-1" 0)

(vercmp "1" "1.0" -1)
(vercmp "1.0" "1.1" -1)
(vercmp "1.1" "1.1.1" -1)
(vercmp "1.1" "1.1.1.1" -1)
(vercmp "1.0.1" "1.1" -1)
(vercmp "1.1.1" "1.1.2" -1)
(vercmp "1.1.2" "1.2" -1)
(vercmp "1.2" "1.11" -1)

(vercmp "1.2.3" "1.2.3-1" -1)
(vercmp "1.2.3-1" "1.2.3-10" -1)
(vercmp "1.2.3-1" "1.2.4" -1)
(vercmp "1.2.3" "1.2.3a" -1)
(vercmp "1.2.3a" "1.2.3b" -1)
(vercmp "1.2.3a" "1.2.12" -1)

(vercmp "1.2_rc0" "1.2_rc1" -1)
(vercmp "1.2_rc1" "1.2" -1)
(vercmp "1.2" "1.2-patch1" -1)
(vercmp "1.2-patch1" "1.2-patch2" -1)
(vercmp "1.2_pre0" "1.2-patch1" -1)
(vercmp "1.1-patch112" "1.2_alpha" -1)

(vercmp "19990312" "20000801" -1)
(vercmp "20010101-4" "20010101-13" -1)
(vercmp "20011125-2.1" "20011213-2.1" -1)
(vercmp "20011213-1.4" "20011213-1.12" -1)
(vercmp "20011213-1.12" "20011213-3.1" -1)
(vercmp "20011213-1.12_alpha0" "20011213-1.12" -1)
(vercmp "20011213-1.12_alpha0" "20011213-1.12.1" -1)

(test* "version=?"  #t (version=? "1.1.12" "1.1.12"))
(test* "version=?"  #f (version=? "1.1.12" "1.1.21"))
(test* "version<?"  #t (version<? "1.1.12" "1.2"))
(test* "version<?"  #f (version<? "1.1.12" "1.1.12"))
(test* "version<?"  #f (version<? "1.1.2" "1.1.1"))
(test* "version<=?" #t (version<=? "1.1.12" "1.2"))
(test* "version<=?" #t (version<=? "1.1.12" "1.1.12"))
(test* "version<=?" #f (version<=? "1.1.2" "1.1.1"))
(test* "version>?"  #f (version>? "1.1.12" "1.2"))
(test* "version>?"  #f (version>? "1.1.12" "1.1.12"))
(test* "version>?"  #t (version>? "1.1.2" "1.1.1"))
(test* "version>=?" #f (version>=? "1.1.12" "1.2"))
(test* "version>=?" #t (version>=? "1.1.12" "1.1.12"))
(test* "version>=?" #t (version>=? "1.1.2" "1.1.1"))

(test-end)





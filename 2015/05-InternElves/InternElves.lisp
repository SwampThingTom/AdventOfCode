;; InternElves
;; https://adventofcode.com/2015/day/5

(defun read-file (filename)
    "Read the file named FILENAME and return a list of lines."
    (with-open-file (stream filename)
        (loop for line = (read-line stream nil)
              while line
              collect line)))

(defun str-to-list (s)
    "Converts a string, S, into a list of characters."
    (coerce s 'list))

(defun vowel-p (c &optional (vowels "aeiou"))
    "Determine whether the character C is a vowel."
    (and (characterp c) (characterp (find c vowels :test #'char-equal))))

(defun count-vowels (c count)
    "If C is a vowel, return COUNT + 1. Otherwise return COUNT."
    (cond ((vowel-p c) (1+ count))
          (t count)))

(defun forbidden-p (c1 c2 &optional (forbid (list "ab" "cd" "pq" "xy")))
    "Determine whether C1 and C2 represent a forbidden character pair."
    (when c1 (stringp (find (format nil "~c~c" c1 c2) forbid :test #'equal))))

(defun nice-p (cl &optional prev-c (vowel-count 0) has-double has-forbidden)
    "Determine whether CL, a list of characters, is nice."
    (cond
        ((null cl) (and (> vowel-count 2) has-double (not has-forbidden)))
        (t (let ((c (car cl)))
                (let ((has-d (or has-double (equal c prev-c)))
                      (has-f (or has-forbidden (forbidden-p prev-c c))))
                     (nice-p (cdr cl) c (count-vowels c vowel-count) has-d has-f))))))

(defun count-nice (l)
    "Return the count of nice strings in the list L."
    (count-if #'nice-p (mapcar #'str-to-list l)))

;; Run tests
(when nil
    (defun test-nice (s e)
        (cond 
            ((equal (nice-p (str-to-list s)) e) (format t "'~A' passed~%" s))
            (t (format t "'~A' failed~%" s))))
    (format t "Test Cases~%")
    (test-nice "" nil)
    (test-nice "a" nil)
    (test-nice "z" nil)
    (test-nice "aa" nil)
    (test-nice "zz" nil)
    (test-nice "aaa" t)
    (test-nice "abc" nil)
    (test-nice "ugknbfddgicrmopn" t)
    (test-nice "jchzalrnumimnmhp" nil)
    (test-nice "haegwjzuvuyypxyu" nil)
    (test-nice "dvszwmarrgswjxmb" nil)
    (format t "~%"))

(format t "Part 1: ~d~%" (count-nice (read-file "input.txt")))

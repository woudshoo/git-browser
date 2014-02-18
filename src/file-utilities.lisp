(in-package :git-browser)


(defun make-tmp-name (base-name type)
  "Creates a tmp file with name taken from base-name and the type from `type'.
Its main use is to create a set of related files based upon a given name, e.g.
name.dot name.png name.svg, ..."
  (merge-pathnames (make-pathname :host "tmp" :type type) base-name))

(defun tmp-name-exists (base-name type)
  "I added here translate-logical-pathname because
this function fails with a complaint about a _ when
sbcl is started in a directory containing a _"
  (directory (translate-logical-pathname (make-tmp-name base-name type))))


(defun pathname-to-string (pathname)
  "Converts a CL pathname to a string representation that
can be used an argument to an external process."
  (format nil "~A" (translate-logical-pathname pathname)))

(defun make-tmp-pathname (base-name type)
  (pathname-to-string (make-tmp-name base-name type)))

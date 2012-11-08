
(in-package :git-browser)

;;; Multiple stores may be defined. The last defined store will be the
;;; default.
(defstore *git-browser-store* :prevalence
  (merge-pathnames (make-pathname :directory '(:relative "data"))
		   (asdf-system-directory :git-browser)))


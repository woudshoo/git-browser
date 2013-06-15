;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(defpackage #:git-browser-asd
  (:use :cl :asdf))

(in-package :git-browser-asd)

(defsystem git-browser
    :name "git-browser"
    :version "0.0.1"
    :maintainer ""
    :author ""
    :licence ""
    :description "git-browser"
    :depends-on (:weblocks :alexandria :wo-git :fset)
    :components ((:file "package")
		 (:file "git-browser" :depends-on ("package"))
		 (:module conf
		  :components ((:file "stores"))
		  :depends-on ("package" "git-browser"))
		 (:module src
		  :components ((:file "file-utilities")
			       (:file "init-session")
			       (:file "svg-container")
			       (:file "dot-utilities")
			       (:file "unmerged-view")
			       (:file "master-view")
			       (:file "neighborhood-view")
			       (:file "simple-list")
			       (:file "git-revision")
			       (:file "git-revision-store")
			       (:file "git-interactions")
			       (:file "master-view-widget"))
		  :depends-on ("package" "git-browser" conf))))


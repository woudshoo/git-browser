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
    :depends-on (:weblocks)
    :components ((:file "git-browser")
		 (:module conf
		  :components ((:file "stores"))
		  :depends-on ("git-browser"))
		 (:module src
		  :components ((:file "init-session")
			       (:file "unmerged-view")
			       (:file "master-view")
			       (:file "neighborhood-view"))
		  :depends-on ("git-browser" conf))))


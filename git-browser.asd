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
    :depends-on (:weblocks :alexandria :wo-git :fset :metatilities :split-sequence)
    :components ((:file "package")
		 (:file "git-browser" :depends-on ("package"))
		 (:module conf
		  :components ((:file "stores"))
		  :depends-on ("package" "git-browser"))
		 (:module src
		  :components ((:file "file-utilities")
			       (:file "init-session")
			       (:file "widgets/simple-list")
			       (:file "widgets/revision-list-widget")
			       (:file "widgets/svg-container")
			       (:file "dot-utilities")
			       (:file "revisions-view/revisions-view")
			       (:file "unmerged-view/unmerged-view")
			       (:file "master-view/master-view")
			       (:file "neighborhood-view/neighborhood-view")
			       (:file "git-revision")
			       (:file "git-revision-store")
			       (:file "git-interactions")
			       (:file "master-view/master-view-widget"))
		  :depends-on ("package" "git-browser" conf))))


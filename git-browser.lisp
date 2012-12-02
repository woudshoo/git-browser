
(defpackage #:git-browser
  (:use :cl :weblocks
        :f-underscore :anaphora :wo-git :wo-graph :wo-graph-functions)
  (:import-from :hunchentoot #:header-in
		#:set-cookie #:set-cookie* #:cookie-in
		#:user-agent #:referer)
  (:documentation
   "A web application based on Weblocks."))

(in-package :git-browser)

(export '(start-git-browser stop-git-browser))

;; A macro that generates a class or this webapp

(defwebapp git-browser
    :prefix "/"
    :description "git-browser: A new application"
    :init-user-session 'git-browser::init-user-session
    :autostart nil                   ;; have to start the app manually
    :ignore-default-dependencies nil ;; accept the defaults
    :debug t
    )

;; Top level start & stop scripts

(defun start-git-browser (&rest args)
  "Starts the application by calling 'start-weblocks' with appropriate
arguments."
  (apply #'start-weblocks args)
  (start-webapp 'git-browser))

(defun stop-git-browser ()
  "Stops the application by calling 'stop-weblocks'."
  (stop-webapp 'git-browser)
  (stop-weblocks))


(in-package :git-browser)

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

(defun start-git-browser-server (&rest args)
  "Starts the application by calling 'start-weblocks' with appropriate
arguments."
  (apply #'start-weblocks args)
  (start-webapp 'git-browser))

(defun stop-git-browser-server ()
  "Stops the application by calling 'stop-weblocks'."
  (stop-webapp 'git-browser)
  (stop-weblocks))


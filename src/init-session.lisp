
(in-package :git-browser)

(defparameter *test-counter* 0)
(defparameter *test-result* "[NOTHING]")

	 ;; (make-navigation "ROOT" 
	 ;; 		  "A" (make-navigation "A"
	 ;; 				       "A-a" (make-widget "A-a")
	 ;; 				       "A-b" (make-widget "A-b"))
	 ;; 		  "B" (make-widget "B"))
;; Define callback function to initialize new sessions
(defun init-user-session (root)
  (setf (widget-children root) 
	(list 
	 (make-widget (lambda (&rest args)
			(with-html 
			  (:p "Last-request-uri: " (str (format nil " ~A " (webapp-session-value 'last-request-uri))))
			  (:p "Uri tokens: " (str (all-tokens *uri-tokens*)))
			  (:p "Time: " (str (format nil "~A"  (get-universal-time))))
			  (:p "Counter: " (str (format nil "~D" *test-counter*)))
			  (:p "Result: " (str (format nil "~A" *test-result*)))
			  (:p "Arguments: " (str (format nil "~A" args)))
			  (:p "Get Parameters " (str (format nil "~A" (hunchentoot:get-parameters* )))))))
	 (make-navigation "xxxxNavigation"  :navigation-class 'horizontal-navigation 
;; :extra-args '(:dom-class "horizontal-navigation") 
			       "Master View" (make-master-view-widget) 
			       "Neighborhood" (make-neighborhood-view-widget)
			       "Unmerged View" (make-unmerged-view-widget)))))

(defwidget horizontal-navigation (weblocks:navigation) ())

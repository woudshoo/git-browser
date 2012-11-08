(in-package :git-browser)

(defun make-neighborhood-view-widget ()
  (let ((neighborhood-widget (make-instance 'widget)))
    (setf (widget-children neighborhood-widget)
	  (list
	   (make-widget "This will contain the neighborhood view")
	   (make-instance 'wrapped-login-widget 
			  :login-widget
			  (make-instance 'login :on-login (lambda (w d)
							    (if (string= "wim" (slot-value d 'email))
								"SESSION-WIM"
								(values nil "Hm, you are not wim!"))))
			  :success-widget
			  (make-widget (lambda (&rest rest)
					 (let ((text (format nil "Got authentication code: ~A" (webapp-session-value *authentication-key*))))
					   (with-html (:h1  "Hallo" )
						      (:p (str text)))))))))
    neighborhood-widget))



(defwidget wrapped-login-widget ()
  ((login :type widget
	  :reader login-widget
	  :initarg :login-widget)
   (success-widget :type widget
		   :accessor success-widget
		   :initarg :success-widget)
   (test-uri :initform "[NOT SET, INITIAL VALUE]"
	     :accessor test-uri
	     :uri-parameter aaa)
   (last-update-value :initform "[NOT CALLED]"
		      :accessor last-update-value)))


(defmethod initialize-instance :after ((obj wrapped-login-widget) &rest initargs &key &allow-other-keys)
  (declare (ignore initargs))
  (setf (weblocks::login-on-success (login-widget obj))
	(lambda (w d) (declare (ignore w d)) (mark-dirty obj))))


(defmethod render-widget-body ((widget wrapped-login-widget) &rest args)
;;  (weblocks::update-widget-parameters widget :get (hunchentoot:get-parameters*))
  (with-html 
    (:h2 "A first Widget!")
    "Testing the conditional login widget, but also now the uri mixin."
    (:p "The parameter 'uri' is bound to the test-uri slot and we will see if it works.
The value of the test-uri slot is: ")
    (str (format nil "~A" (test-uri widget)))
    " And the slot map: "
    (str (format nil "~A" (uri-parameters-slotmap widget)))
    " The slot map values: "
    (str (format nil "~A" (weblocks::uri-parameter-values widget)))
    " And the last update value: "
    (str (format nil "~A" (last-update-value widget))))
  (if (webapp-session-value *authentication-key*)
      (apply #'render-widget-body (success-widget widget) args)
      (apply #'render-widget-body (login-widget widget) args)))

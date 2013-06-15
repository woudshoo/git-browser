(in-package :git-browser)

(defun make-neighborhood-view-widget ()
  (let ((neighborhood-widget (make-instance 'widget)))
    (setf (widget-children neighborhood-widget)
	  (list
	   (make-widget "This will contain the neighborhood view")))
    neighborhood-widget))




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

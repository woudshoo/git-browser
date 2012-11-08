(in-package :git-browser)

(defun make-master-view-widget ()
  (let ((master-widget (make-instance 'widget)))
    (setf (widget-children master-widget)
	  (list
	   (make-widget  "This will contain the master view")
	   (make-widget (lambda (&rest args) 
			  (with-html 
			    (:h3 "Testing internal navigation")
			    (:ol
			     (:li
			      "This is a link containing a location of a navigatin widget"
			      (:br)
			      (:a :href "/neighborhood"
				  "This will switch to the neighborhood graph"))
			     (:li
			      "And now we want an action to behave the same"
			      (:br)
			      (render-link
			       (lambda (&rest args)
				 (redirect "/neighborhood"))
			       "An Action Link (doing nothing right now)"))))))

	   (make-widget "And some other text bla die bla")))
    master-widget))

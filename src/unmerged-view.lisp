(in-package :git-browser)

(defparameter *test-result* "[NOTHING]")

(defun make-unmerged-view-widget ()
  (let* ((widget (make-instance 'widget))
	 (store (webapp-session-value *revision-store-key*))
	 (starters-widget (make-instance 
			   'simple-list :data-store store
			   :select-tag :starters 
			   :item-ops `(("Back" ,(lambda (w d)
							(setf (classification d) :normal)
							(mark-dirty w)) 
					       :render-fn ,(lambda (label) 
								   (declare (ignore label))
								   (with-html 
									     (:svg :width "10pt" :height "10pt" 
										   (:circle :cx "5pt" :cy "5pt" 
											    :r "4pt" 
											    :stroke "black"))))))
			   :data-item-render (lambda (o) (with-html (str (label o))))
			   :caption "Start Revisions"))
	 (enders-widget (make-instance 
			   'simple-list :data-store store
			   :select-tag :enders 
			   :item-ops `(("Back" ,(lambda (w d)
							(setf (classification d) :normal)
							(mark-dirty w)) 
					       :render-fn ,(lambda (label) 
								   (declare (ignore label))
								   (with-html 
									     (:svg :width "10pt" :height "10pt" 
										   (:circle :cx "5pt" :cy "5pt" 
											    :r "4pt" 
											    :stroke "black"))))))
			   :data-item-render (lambda (o) (with-html (str (label o))))
			   :caption "End Revisions"))
	 (dead-widget (make-instance 
			   'simple-list :data-store store
			   :select-tag :dead
			   :item-ops `(("Back" ,(lambda (w d)
							(setf (classification d) :normal)
							(mark-dirty w)) 
					       :render-fn ,(lambda (label)   (declare (ignore label))
								   (with-html 
								     (:svg :width "10pt" :height "10pt" 
										   (:circle :cx "5pt" :cy "5pt" 
											    :r "4pt" 
											    :stroke "black"))))))
			   :data-item-render (lambda (o) (with-html (str (label o))))
			   :caption "Dead Revisions")))

    (setf (widget-children widget :test) 
	  `(,(weblocks:make-widget  "This will contain the unmerged view")
	     ,(lambda (&rest args)
		      (declare (ignore args))
		      (with-html
			(:p "Lets test: "
			    (render-link 
			     (lambda (&rest args)
			       (declare (ignore args))
			       (with-call/cc (setf *test-result*
						   (do-choice "Hello this is your friendly helper, what can I do?" '(:alpha :beta)))))
			     "Test Login with lambda/cc"))))

	     ,(make-widget "And some more text to follow!!")

	     
	     ,(make-instance 'simple-list 
			     :data-store store
			     :item-ops `(("D" ,(lambda (a b)
						       (declare (ignore a))
							   (setf (classification b) :dead)
							   (mark-dirty starters-widget)
							   (mark-dirty dead-widget) nil)
						:render-fn
						,(lambda (label) (with-html (str label))))
					 ("S" ,(lambda (a b)
							   (declare (ignore a))
							   (setf (classification b) :starters)
							   (mark-dirty starters-widget)))
					 ("E" ,(lambda (a b)
							   (declare (ignore a))
							   (setf (classification b) :enders)
							   (mark-dirty enders-widget))))
			     :data-item-render (lambda (o)
						 (with-html
						   (str (label o))))
			     :select-tag :all
			     :caption "All Revisions")
	     ,starters-widget
	     ,enders-widget
	     ,dead-widget))
    
    widget))



(defwidget scrolleable-list ()
  ())


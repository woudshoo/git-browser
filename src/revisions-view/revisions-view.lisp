(in-package :git-browser)


(defun make-revisions-view-widget ()
  "Creates widget having 5 children:
- All revisions
- Start Revisions
- End Revisions
- Selected Revisions
- Dead Revision."
  (let* ((widget (make-instance 'widget))
	 (store (webapp-session-value *revision-store-key*))
	 
	 (starters-widget (make-revision-list-widget "Start Revisions" :starters store))
	 (enders-widget (make-revision-list-widget "End Revisions" :enders store))
	 (dead-widget (make-revision-list-widget "Dead Revisions" :dead store))
	 (selected-widget (make-revision-list-widget "Selected Revisions" :selected store)))
    (flet ((make-item-op (label classification mark-as-dirty)
	     (list label (lambda (a b)
			   (declare (ignore a))
			   (setf (classification b) classification)
			   (mapc #'mark-dirty (alexandria:ensure-list mark-as-dirty)))
		   :render-fn (lambda (label) (with-html (str label))))))
      
      (setf (widget-children widget :test) 
	    `(
	      ,(make-revision-list-widget "All Revisions" nil store 
					  `(,(make-item-op "*" :selected selected-widget)
					    ,(make-item-op "D" :dead `(,starters-widget ,dead-widget))
					    ,(make-item-op "S" :starters starters-widget)
					    ,(make-item-op "E" :enders enders-widget)))
	       ,starters-widget
	       ,enders-widget
	       ,dead-widget
	       ,selected-widget)))
    widget))

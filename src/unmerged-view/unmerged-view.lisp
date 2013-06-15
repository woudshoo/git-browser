(in-package :git-browser)

(defparameter *test-result* "[NOTHING]")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Unmerged
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun create-unmerged-svg ()
  (create-svg-graph "unmerged"
		    (lambda (s)
		      (unmerged-graph (selected-shas* :select :starters)
				      (selected-shas* :select :enders)
				      *default-graph*
				      s
				      :dead-revisions (selected-shas* :select :dead)))))


(defwidget unmerged-view-widget ()
  ((action :accessor action)
   (svg-content :accessor svg-content
		:initform
		(make-instance 'svg-container :svg-file-name (make-tmp-name "unmerged" "svg")))))


(defmethod initialize-instance :after ((widget unmerged-view-widget) &key &allow-other-keys)
  (setf (action widget)
	(make-instance 'action-widget
		       :function (lambda (&rest args)
				   (declare (ignore args))
				   (clear-cache "unmerged")
				   (create-unmerged-svg)
				   (mark-dirty widget))
		       :label "Regenerate"))
  (create-unmerged-svg)
  (setf (widget-children widget)
	(list (action widget)
	      (svg-content widget))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun make-unmerged-view-widget ()
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
	      ,(make-instance 'simple-list 
			      :data-store store
			      :order-by '(label :asc)
			      :item-ops `(,(make-item-op "*" :selected selected-widget)
					   ,(make-item-op "D" :dead `(,starters-widget ,dead-widget))
					   ,(make-item-op "S" :starters starters-widget)
					   ,(make-item-op "E" :enders enders-widget))
			      :data-item-render (lambda (o)
						  (with-html
						    (str (label o))))
			      :select-tag :all
			      :caption "All Revisions")
	       ,starters-widget
	       ,enders-widget
	       ,dead-widget
	       ,selected-widget
	       ,(make-instance 'unmerged-view-widget))))
    
    widget))



(defwidget scrolleable-list ()
  ())




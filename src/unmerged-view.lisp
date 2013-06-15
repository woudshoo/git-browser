(in-package :git-browser)

(defparameter *test-result* "[NOTHING]")




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Neighborhood
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun create-neighborhood-svg ()
  (create-svg-graph "neighborhood"
		    (lambda (s)
		      (neighborhood-graph *default-graph* s
					  :start-vertices (selected-shas* :select :starters)
					  :end-vertices (selected-shas* :select :enders)
					  :dead-revisions (selected-shas* :select :dead)
					  :selected-vertices (selected-shas* :select :selected)))))

(defwidget neighborhood-view-widget ()
  ((action :accessor action)
   (svg-content :accessor svg-content
		:initform
		(make-instance 'svg-container :svg-file-name (make-tmp-name "neighborhood" "svg")))))

(defmethod initialize-instance :after ((widget neighborhood-view-widget) &key &allow-other-keys)
  (setf (action widget)
	(make-instance 'action-widget
		       :function (lambda (&rest args)
				   (declare (ignore args))
				   (clear-cache "neighborhood")
				   (create-neighborhood-svg)
				   (mark-dirty widget))
		       :label "Regenerate"))
  (create-neighborhood-svg)
  (setf (widget-children widget)
	(list (action widget)
	      (svg-content widget))))


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
			   :caption "Dead Revisions"))
	 (selected-widget (make-instance 
			   'simple-list :data-store store
			   :select-tag :selected
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
			   :caption "Selected Revisions")))

    (setf (widget-children widget :test) 
	  `(
	     ,(make-instance 'simple-list 
			     :data-store store
			     :order-by '(label :asc)
			     :item-ops `(("*" ,(lambda (a b)
						       (declare (ignore a))
							   (setf (classification b) :selected)
							   (mark-dirty selected-widget) nil)
						:render-fn
						,(lambda (label) (with-html (str label))))
					 ("D" ,(lambda (a b)
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
	     ,dead-widget
	     ,selected-widget
	     ,(make-instance 'unmerged-view-widget)))
    
    widget))



(defwidget scrolleable-list ()
  ())




(in-package :git-browser)

(defun make-neighborhood-view-widget ()
  (let ((neighborhood-widget (make-instance 'widget)))
    (setf (widget-children neighborhood-widget)
	  (list
	   (make-widget "This will contain the neighborhood view")
	   (make-instance 'neighborhood-view-widget)))
    neighborhood-widget))



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
		:initform (make-instance 'svg-container 
					 :svg-file-name (make-tmp-name "neighborhood" "svg")))))

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


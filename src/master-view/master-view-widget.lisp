(in-package :git-browser)


;;; what a mess.


(defun quote-string (string)
  (format nil "~S" string))

(defun make-url-for-mark-as-dead (v)
  (quote-string (format nil 
			"javascript:~A" (ps:ps* `(mad this  ,(vertex-or-name-to-string v))))))



(defun create-master-svg ()
  (create-svg-graph "master"
		    (lambda (s)
		      (classified-by-edge-graph *default-graph* s
						:node-attributes
						(make-default-node-attribute
						 :url-fn #'make-url-for-mark-as-dead
						 :id-fn #'(lambda (v) (quote-string (vertex-or-name-to-string v))))
						:dead-revisions (selected-shas* :select :dead)))
		    nil))

(defwidget master-view-widget ()
  ((potential-dead-widget :accessor potential-dead-widget)
   (action :accessor action)
   (svg-content :accessor svg-content
		:initform
		(make-instance 'svg-container :svg-file-name (make-tmp-pathname "master" "svg")))))



(defmethod initialize-instance :after ((widget master-view-widget) &key &allow-other-keys)

  (setf (potential-dead-widget widget) (make-instance 'simple-list 
						      :select-tag :candidate-dead
						      :data-store (webapp-session-value *revision-store-key*)
						      :caption "Revisions to be Marked Dead"))

  (setf (action widget) 
	(make-instance 'action-widget
		       :function    (lambda (&rest args) 
				      (declare (ignore args))
				      (loop :for revision :in 
					 (find-persistent-objects (webapp-session-value *revision-store-key*) nil 
								  :select :candidate-dead)
					 :do
					 (setf (classification revision) :dead))
				      (clear-cache "master")
				      (create-master-svg)
				      (mark-dirty widget))
		       :label "Mark as Dead, Regenerate Master"))


  (create-master-svg)
  (setf (widget-children widget) 
	(list (potential-dead-widget widget)
	      (action widget)
	      (svg-content widget)))
  (make-action (lambda (&key (id nil) &allow-other-keys)
		 (let* ((store (webapp-session-value *revision-store-key*))
			(rev (find-persistent-object-by-id store nil (parse-integer id :radix 16))))
		   (setf (classification rev) :candidate-dead)
		   (mark-dirty (potential-dead-widget widget)))) "mark-as-dead"))




(defwidget action-widget ()
  ((function :accessor action-function :initarg :function :initform nil)
   (label :accessor label :initarg :label :initform "")))

(defmethod render-widget-body ((widget action-widget) &rest args)
  (declare (ignore args))
  (format t "Hey rendering ~%")
  (render-link
   (action-function widget)
   (label widget)))

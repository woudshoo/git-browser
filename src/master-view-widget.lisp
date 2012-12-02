(in-package :git-browser)


;;; what a mess.

;;;

;; (defwidget svg-content-widget ()
;;    ((svg-content :accessor svg-content :initform nil)))


(defun quote-string (string)
  (format nil "~S" string))

(defun make-url-for-mark-as-dead (v)
  (quote-string (format nil 
			"javascript:~A" (ps:ps* `(mad this  ,(vertex-or-name-to-string v))))))


(defun dead-revisions ()
  (let ((store (webapp-session-value *revision-store-key*)))
    (loop :for rev :in (find-persistent-objects store nil :select :dead)
       :collect (sha rev))))


;; ;;  onclick=\"initiateAction(\"mark-as-dead\",\"\"); return false;\"
;; (defmethod ensure-svg-content-is-filled ((widget svg-content-widget))
;;   (unless (svg-content widget)
;;     (create-svg-graph "master"
;; 		      (lambda (s)
;; 			(classified-by-edge-graph *default-graph* s
;; 						  :node-attributes
;; 						  (make-default-node-attribute
;; 						   :url-fn #'make-url-for-mark-as-dead
;; 						   :id-fn #'(lambda (v) (quote-string (vertex-or-name-to-string v))))
;; 						  :dead-revisions (dead-revisions)))
;; 		      nil)
;;     (setf (svg-content widget)
;; 	  (alexandria:read-file-into-string (make-tmp-name "master" "svg")))))


;; function listProperties(obj) {
;;    var propList = "";
;;    for(var propName in obj) {
;;       if(typeof(obj[propName]) != "undefined") {
;;          propList += (propName + ", ");
;;       }
;;    }
;;    alert(propList);
;; }

;; (defmethod render-widget-body ((widget svg-content-widget) &rest args)
;;   (declare (ignore args))
;;   (ensure-svg-content-is-filled widget)
;;   (send-script "
;; function listProperties(obj) {
;;    var propList = '';
;;    for(var propName in obj) {
;;       if(typeof(obj[propName]) != 'undefined') {
;;          propList += (propName + ': ' + obj[propName] + ', ');
;;       }
;;    }
;;    alert(propList);
;; }"

;; )

;;   (send-script (ps:ps* `(defun mad (node id) 
;; 			  (let* ((element  (document.get-element-by-id id))
;; 				 (child (elt (element.get-elements-by-tag-name "polygon") 0)))
;; ;			    (alert (element.get-attribute-n-s nil "visibility"))
;; ;			    (element.set-attribute "visibility" "hidden")
;; 			    (child.set-attribute "fill" "gray")
;; ;			    (list-properties child)
;; ;			    (child.set-attribute "style" "background-color: red;")
;; ;			    (setf element.style.background-color "green")
;; 			    )
;; 			  (alert node)
;; ;			  (setf node.style.background-color "green")
;; 			  (initiate-action-with-args "mark-as-dead" "" (ps:create :id id))
;; 			  (return "hallo"))))
;;   (with-html
;;     (:div :class "master-view"
;; 	  (render-widget (svg-content widget))
;; #+nil	  (format *weblocks-output-stream* (svg-content widget)))))

(defun create-master-svg ()
  (create-svg-graph "master"
		    (lambda (s)
		      (classified-by-edge-graph *default-graph* s
						:node-attributes
						(make-default-node-attribute
						 :url-fn #'make-url-for-mark-as-dead
						 :id-fn #'(lambda (v) (quote-string (vertex-or-name-to-string v))))
						:dead-revisions (dead-revisions)))
		    nil))

(defwidget master-view-widget ()
  ((potential-dead-widget :accessor potential-dead-widget)
   (action :accessor action)
   (svg-content :accessor svg-content
		:initform
		(make-instance 'svg-container :svg-file-name (make-tmp-name "master" "svg")))))



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
				      (clear-cache)
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

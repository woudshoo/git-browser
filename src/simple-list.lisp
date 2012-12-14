(in-package :git-browser)

(defwidget simple-list ()
  ((data-store :initarg :data-store
	       :accessor data-store
	       :initform nil)
   (item-ops :accessor item-ops
	     :initform nil
	     :initarg :item-ops
	     :documentation "A list of actions.  Each action 
is a list starting with (label action).
The action should be a function taking two arguments, the widget and a list item.
The is normally a string, but can be any object if it is specifed as
\(label action :render-fn render-fn\) where the render-fn will be called 
with exactly one argument, the label, and it should render to something appropriate.

Note, I am not sure if anything besides a string is allowed for label. ")
   (data-item-renderer :accessor data-item-renderer
		       :initform (lambda (o)
				   (with-html
				     (str (label o))))
		       :initarg :data-item-render)
   (select-tag :accessor select-tag
	       :initform nil
	       :initarg :select-tag)
   (caption  :accessor caption
	     :initform nil
	     :initarg :caption))
  (:documentation "Provides a simpler list than datalist.
It will not do any fancy things, except rendering in a list the items
of the data store, which are filtered with the select tag.
Each item will have the item ops rendered next them them."))



(defmethod render-header ((obj simple-list))
  (when (caption obj)
      (with-html
	(:h3 (cl-who:esc (caption obj))))))

(defmethod render-footer ((obj simple-list))
  (or nil
      (with-html
	(:h4 (str (format nil "Total ~D" (count-persistent-objects (data-store obj) nil :select (select-tag obj))))))))



(defmethod render-action ((obj simple-list) item name function rest)
  (apply #'render-link
	 (lambda (&rest args)
	   (declare (ignore args))
	   (funcall function obj item))
	 name rest))

(defmethod actions-renderer ((obj simple-list) item)
  (loop :for (name function . rest) :in (item-ops obj)
     :do
     (render-action obj item name function rest)))

(defmethod render-items ((obj simple-list))
  (render-list (find-persistent-objects (data-store obj) nil :select (select-tag obj))
	       :orderedp nil
	       :render-fn (lambda (item)
			    (with-html
			      (:div :class "entry"
				    (:div :class "label"
					  (funcall (data-item-renderer obj) item))
				    (:div :class "actions"
					  (actions-renderer obj item)))))))


(defmethod render-widget-body ((obj simple-list) &rest args)
  (with-html
    (:div :class "simple-list"
	  (render-header obj)
	  (render-items obj)
	  (render-footer obj))))

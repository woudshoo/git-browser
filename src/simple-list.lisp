(in-package :git-browser)

(defwidget simple-list ()
  ((data-store :initarg :data-store
	       :accessor data-store
	       :initform nil)
   (item-ops :accessor item-ops
	     :initform nil
	     :initarg :item-ops)
   (data-item-renderer :accessor data-item-renderer
		       :initform nil
		       :initarg :data-item-render))
  (:documentation "Provides a simpler list than datalist.
It will not "))



(defmethod render-header ((obj simple-list))
  (with-html
    (:h3 "Title")))

(defmethod render-footer ((obj simple-list))
  (with-html
    (:h4 "Footer")))


(defmethod render-items ((obj simple-list))

  (render-list (find-persistent-objects (data-store obj) nil)
	       :orderedp t
	       :render-fn (lambda (item)
			    (funcall (data-item-renderer obj) item)
			    (loop :for (name . function) :in  (item-ops obj)
			       :do
			       (render-link 
				(lambda (&rest args) (funcall function obj item)
					(mark-dirty obj)) name)))))


(defmethod render-widget-body ((obj simple-list) &rest args)
  (with-html
    (:div :class "simple-list"
	  (render-header obj)
	  (render-items obj)
	  (render-footer obj))))

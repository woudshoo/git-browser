(in-package :git-browser)


(defwidget revision-list ()
  ((store :accessor store 
	  :initarg :store
	  :initform nil
	  :documentation "Contains the store that underlies this list")))


(defun make-revision-list-widget (caption select-tag data-store)
  (make-instance 'simple-list
		 :data-store data-store
		 :select-tag select-tag
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
		 :caption caption))

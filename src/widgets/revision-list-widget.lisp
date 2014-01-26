(in-package :git-browser)


(defwidget revision-list ()
  ((store :accessor store 
	  :initarg :store
	  :initform nil
	  :documentation "Contains the store that underlies this list")))


(defun git-revision-type-name (name)
  (let ((sequence (split-sequence:split-sequence #\/ name)))
    (if (< 1 (length sequence))
      (nth 1 (reverse sequence))
      "unknown")))

(defun git-revision-simplified-name (name)
  (let ((sequence (split-sequence:split-sequence #\/ name)))
    (if (< 0 (length sequence))
      (nth 0 (reverse sequence))
      "unknown")))

(defun render-git-revision (revision)
  "Renders a git REVISION as being part of a list."
  (with-html
    (:div :class "git-revision-line"
	  (loop :for name :in (names revision)
	     :do
	     (cl-who:htm (:div :class (git-revision-type-name name) (str (git-revision-simplified-name name))))))))


(defun make-revision-list-widget (caption select-tag data-store &optional actions)
  "Make a list whith name CAPTION which shows revisions matching SELECT-TAG from DATA-STORE.
If SELECT-TAG is nil, this means all revisions should be shown.
The optional argument defaults to the 'Back' action.
The 'Back' action will mark the revision as :normal."
  (make-instance 'simple-list
		 :data-store data-store
		 :select-tag select-tag
		 :item-ops (or actions
			       `(("Back" ,(lambda (w d)
						  (setf (classification d) :normal)
						  (mark-dirty w)) 
					 :render-fn 
					 ,(lambda (label) 
						  (declare (ignore label))
						  (with-html 
						    (:svg :width "10pt" :height "10pt" 
							  (:circle :cx "5pt" :cy "5pt" 
								   :r "4pt" 
								   :stroke "black")))))))
		 :data-item-render #'render-git-revision
		 :caption caption))

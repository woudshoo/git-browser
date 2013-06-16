
(in-package :git-browser)

(defparameter *revision-store-key* 'revision-store)


(defun new-default-revision-store ()
  (let ((result (make-instance 'git-revision-store)))
    (format t "Initializing new store!~%")
    (when *default-graph*
      (loop :for name :in (all-names *default-graph*) :do 
	 (persist-object result (make-instance 'git-revision 
					       :label (simplify-node-name name)
					       :sha (name-to-vertex name *default-graph*))))
      (loop :for rev :in *dead-revisions* 
	 :for revision = (find-persistent-object-by-id result nil (parse-integer rev :radix 16))
	 :do
	 (when revision
	   (setf (classification revision) :dead))))
    result))

;; Define callback function to initialize new sessions
(defun init-user-session (root)
  (setf (webapp-session-value *revision-store-key*) 
	(new-default-revision-store))
  (setf (widget-children root) 
	(list 
	 (make-navigation "Navigation"  :navigation-class 'horizontal-navigation 
			  "Revisions" (make-revisions-view-widget)
			  "Master View" (make-master-view-widget) 
			  `("Neighborhood" ,(make-neighborhood-view-widget))
			  "Unmerged View" (make-unmerged-view-widget)
			  #+nil `("Test Nested Navigation" ,(make-nested-navigation-test) nil)))))

(defwidget horizontal-navigation (weblocks:navigation) ())



(defun make-nested-navigation-test ()
  (make-navigation "A"
		   "A" (make-navigation "AB"
					"AB1" "Contains AB"
					"AB2" "Contains AB2")
		   "B" (make-navigation "BC"
					"BC1" "Contains BC"
					"BC2" "Contains BC2"
					"BC3" (make-navigation "D"
							       "D1" "Has D1"
							       "D2" "Has D2"))
		   "C" (make-navigation "CE"
					"CE1" (make-navigation "E"
							       "E1" "Yeah E1"
							       "E2" "Yeah E2")
					"CE2" "Finally CE2")))

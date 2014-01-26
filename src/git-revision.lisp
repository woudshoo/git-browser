(in-package :git-browser)

(defclass git-revision ()
  ((names :type list :reader names :initarg :names 
	  :documentation "Tag or label of a revision")
   (sha   :type integer :reader sha :initarg :sha 
	  :documentation "The SHA1 of of the revision")
   (classification :accessor classification :initarg :class :initform :normal
		   :documentation "The classification is one of 
:normal, :starter, :ender, or :dead.  Of course new values can be invented if needed,
it also probably should be a list later on.")))


(defmethod label ((revision git-revision))
  (format nil "~{~A~^: ~}" (names revision)))

(defmethod compare-for-key ((key symbol) (first git-revision) (second git-revision))
  "Methot for comparing git-revisions.  
key is the slot to compare and the first and second git-revisions are compared"
  (ecase key
    (sha (< (sha first) (sha second)))
    (label (string< (label first) (label second)))
    (classification (string< (classification first) (classification second)))))

(in-package :git-browser)

(import 'metatilities::curry)

(defclass git-revision-store ()
  ((data :accessor data :initarg :data :initform (make-hash-table)))
  (:documentation "Represents a list of git revisions."))


(defmethod persist-object ((store git-revision-store) (revision git-revision) &key)
  "Add rivisions to the store."
  (setf (gethash (sha revision) (data store)) revision))

(defmethod objects-for-classification ((store git-revision-store) classification)
  "Returns a list containing all revisions which satisfy the classification parameter.
The classification parameter is a keyword and is matched against the classification slot
of the git revisions.   A classification of :all returns all elements.
Also there are special classifications such as :boundary"
  (case classification
    (:all  (alexandria:hash-table-values (data store)))
    (t (loop :for revision :being :the :hash-value :in (data store)
	    :when (eql (classification revision) classification) :collect revision))))


(defmethod clean-store ((store git-revision-store))
  (setf (data store) (make-hash-table)))

(defmethod find-persistent-object-by-id ((store git-revision-store) class-name (id integer))
  (gethash id (data store)))

(defmethod find-persistent-objects ((store git-revision-store) class-name
				    &rest args &key order-by range select &allow-other-keys)
  (declare (ignore args))
  (let ((objects (objects-for-classification store (or select :normal))))
    (when order-by
      (setf objects (sort objects (curry #'compare-for-key (car order-by))))
      (when (eql (cdr order-by) :desc)
	(setf objects (nreverse objects))))
    (if range
	(subseq objects (car range) (cdr range))
	objects)))

(defmethod count-persistent-objects ((store git-revision-store) class-name
				     &rest args &key select &allow-other-keys)
  (declare (ignore args))
  (length (objects-for-classification store (or select :normal))))


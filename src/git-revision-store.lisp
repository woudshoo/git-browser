(in-package :git-browser)

(import 'metatilities::curry)

(defclass git-revision-store ()
  ((data :accessor data :initarg :data :initform (make-hash-table)))
  (:documentation "Represents a list of git revisions."))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Default store API implementation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Extension
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmethod selected-SHAs ((store git-revision-store) &key select)
  "Returns from the store all SHAs that are marked with SELECT.
This is similar to FIND-PERSISTENT-OBJECTS ... :select select, but 
instead of returning git-revision objects, it will return the SHAs"
  (mapcar #'sha (find-persistent-objects store nil :select select)))

(defun selected-SHAs* (&key select)
  "Same as the version without the '*', but will return the standard store for the version."
  (selected-shas (webapp-session-value *revision-store-key*) :select select))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; NOT USED YET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defclass git-revision-store-view ()
  ((store :accessor store 
	  :initarg :store
	  :documentation "Underlying git revision store, will be filtered by the select ivar")
   (select :accessor select
	   :initarg :select
	   :documentation "Selects a subset from the underlying store")))


(defmethod persist-object ((store git-revision-store-view) (revision git-revision) &key)
  "Add a revision to the store.  Will not check or change the select tag"
  (persist-object (store store) revision))

(defmethod clean-store ((store git-revision-store-view))
  (error "Operation clean-store not permitted on the view"))

(defmethod find-persistent-object-by-id ((store git-revision-store-view) class-name (id integer))
  (find-persistent-object-by-id (store store) class-name id))

(defmethod find-persistent-objects ((store git-revision-store-view) class-name
				    &rest args)
  (apply #'find-persistent-objects (store store) class-name 
	 :select (select store) args))

(defmethod count-persistent-objects ((store git-revision-store-view) class-name
				     &rest args)
  (apply #'count-persistent-objects (store store) class-name
	 :select (select store) args))

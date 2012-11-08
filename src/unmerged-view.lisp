(in-package :git-browser)

(defun make-unmerged-view-widget ()
  (let ((widget (make-instance 'widget))
	(store (make-instance 'hash-store)))
    (fill-store-with-dummy-data store)
    (setf (widget-children widget :test) 
	  `(,(weblocks:make-widget  "This will contain the unmerged view")
	     ,(lambda (&rest args)
		      (with-html
			(:p "Lets test: "
			    (render-link 
			     (lambda (&rest args)
			       (incf *test-counter*)
			       (with-call/cc (setf *test-result*
						   (do-choice "Hello this is your friendly helper, what can I do?" '(:alpha :beta)))))
			     "Test Login with lambda/cc"))))
	     ,(make-instance 'svg-widget 
;			     :svg-file #P"/tmp/master.svg"
			     :svg-test "
<?xml version=\"1.0\" standalone=\"no\"?>
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" 
\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">

<svg width=\"150pt\" height=\"100pt\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">
  <circle cx=\"100\" cy=\"50\" r=\"40\" stroke=\"black\"
  stroke-width=\"2\" fill=\"red\" />
</svg>
")
	     ,(make-widget "And some more text to follow!!")

	     
	     ,(make-instance 'simple-list 
			     :data-store store
			     :item-ops (list (cons "XYZ" (lambda (a b) 
							   (delete-persistent-object store b) 
							   (mark-dirty a) nil)))
			     :data-item-render (lambda (o)
						 (with-html
						   (str (label o)))))

	     ,(make-instance 'datagrid :data-class 'git-revision 
			     :class-store store
			     :allow-pagination-p nil
			     :item-ops (list (cons "XYZ" (lambda (a b) nil))))))
    
    widget))



(defwidget scrolleable-list ()
  ())

(defclass git-revision ()
  ((label :type (or string nil) :reader label :initarg :label :documentation "Tag or label of a revision")
   (sha   :type integer :reader sha :initarg :sha :documentation "The SHA1 of of the revision")))


(defmethod object-id ((obj git-revision))
  (sha obj))

(defun fill-store-with-dummy-data (store)
  (flet ((add-entry (sha label)
	   (persist-object store (make-instance 'git-revision :sha sha :label label))))
    
#+nil    (mapcar #'add-entry 
	    (loop :repeat 1000 :for i :from 2000 :collect i)
	    (loop :repeat 1000 :for i :from 200 :collect (format nil "Label ~D" i))))

  (persist-object store (make-instance 'git-revision :sha 1000 :label "Hallo"))
  (persist-object store (make-instance 'git-revision :sha 1001 :label "Daar"))
  (persist-object store (make-instance 'git-revision :sha 1002 :label "Wie"))
  (persist-object store (make-instance 'git-revision :sha 1003 :label "gaat"))
  (persist-object store (make-instance 'git-revision :sha 1004 :label "Jaay!")))

(defun make-empty-store-hash ()
  (make-hash-table))

(defclass hash-store ()
  ((data :accessor data :initarg :data :initform (make-empty-store-hash))
   (last-key :initform 0)))

(defmethod close-store ((store hash-store))
  "Do nothing")

(defmethod clean-store ((store hash-store))
  (setf (data store) (make-empty-store-hash )))

(defmethod begin-transaction ((store hash-store))
  nil)

(defmethod commit-transaction ((store hash-store))
  nil)

(defmethod rollback-transaction ((store hash-store))
  nil)


(defmethod persist-object ((store hash-store) object &key)
  (setf (gethash (sha object) (data store)) object))

(defmethod delete-persistent-object ((store hash-store) object)
  (delete-persistent-object-by-id store 'git-revision (sha object)))

(defmethod delete-persistent-object-by-id ((store hash-store) class-name object-id)
  (remhash object-id (data store))
  (format t "Delete called!  (with: ~A) Store count: ~D~%" object-id (hash-table-count (data store)))
  (decf *test-counter*))

(defmethod find-persistent-object-by-id ((store hash-store) class-name object-id)
  (gethash object-id (data store)))


(defmethod find-persistent-objects ((store hash-store) class-name 
				    &key order-by range &allow-other-keys)
  (let ((objects (alexandria:hash-table-values (data store))))
    (when order-by
      (setf objects (sort objects (if (eql (car order-by) 'sha) #'< #'string<)
			  :key (lambda (o) (slot-value o (car order-by)))))
      (when (eql (cdr order-by) :desc)
	(setf objects (nreverse objects))))
    (if range
      (subseq objects (car range) (cdr range))
      objects)))


(defmethod count-persistent-objects ((store hash-store) class-name &key &allow-other-keys)
  (hash-table-count (data store)))

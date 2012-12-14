(in-package :git-browser)


(defwidget revision-list ()
  ((store :accessor store 
	  :initarg :store
	  :initform nil
	  :documentation "Contains the store that underlies this list")))


()

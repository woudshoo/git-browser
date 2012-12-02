(in-package :git-browser)



(defwidget svg-widget ()
  ((svg-test :type string
	     :reader svg-test
	     :initarg :svg-test)))

(defmethod render-widget-body ((widget svg-widget) &rest args)
  (format *weblocks-output-stream* "~A" (svg-test widget)))

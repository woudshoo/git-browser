(in-package :git-browser)


(defparameter *dot-cmd*
  #+linux "/usr/bin/dot"
  #+darwin "/usr/local/bin/dot"
  #+win32 "d:/Programs/graphviz/bin/dot.exe")

(defun run-dot (dot-file image-file &optional &key cmap-file node-href)
  "Run dot on the `dot-file' and the resulting image will be written
to `image-file'.  If the optional `cmap-file' is given, the cmapx file is written to
that file.

The dot commad is taken from the *dot-cmd* variable and the command line for dot is

 dot <dot-file>  -Nhref=\\N r-T <type of image-file> -o <image-file>

or

 dot <dot-file> -Nhref=\\N -T <type of image-file> -o <image-file> -Tcmapx -o <cmap-file>
"
  (sb-ext:run-program *dot-cmd*
		      #-sbcl :arguments (remove nil (if cmap-file
							(list
							 (pathname-to-string dot-file)
							 (when node-href (format nil "-Nhref=~A" node-href))
							 "-T"
							 (string-downcase (pathname-type image-file))
							 "-o"
							 (pathname-to-string image-file)
							 "-Tcmapx" "-o"
							 (pathname-to-string cmap-file))
							(list
							 (pathname-to-string dot-file)
							 (when node-href (format nil "-Nhref=~A" node-href))
							 "-T"
							 (string-downcase (pathname-type image-file))
							 "-o"
							 (pathname-to-string image-file))))))



(defun create-svg-graph (base-name graph-to-dot-writer &optional node-ref-string)
  "Creates dot file if needed and runs dot if needed."
    (unless (tmp-name-exists base-name "dot")
      (with-open-file (s (make-tmp-name base-name "dot") :direction :output :if-exists :supersede)
	(funcall graph-to-dot-writer s)))
    (unless (tmp-name-exists base-name "svg")
      (run-dot (make-tmp-name base-name "dot")
	       (make-tmp-name base-name "svg")
	       :node-href node-ref-string )))


(defun make-default-edge-attributes (selector-p)
  "Returns a edge attribute function which will color
the edge gray if one of the nodes is not interesting."
  (lambda (e g)
    (if (and (funcall selector-p (wo-graph:source-vertex e g) g)
	     (funcall selector-p (wo-graph:target-vertex e g) g))
	'(:color "black")
	'(:color "gray"))))


(defun make-default-node-attribute (&optional &key (color) (url-fn) (id-fn))
  "Returns a node attribute function which will show either
a dot if the vertex does not have any names or a box
with all names if the vertex does have names.

If a color function is supplied it will be used to add a color attribute with
the result of the `color' function called on the vertex."
  (lambda (v g)
    (concatenate 'list
		 (alexandria:if-let ((names (mapcar #'simplify-node-name (wo-git:vertex-names v g))))
		   `(:shape :box :label ,(format nil "\"~{~A~^\\n~}\"" names))
		   (list :shape :point))
		 (when color
		   `(:color ,(funcall color v)))
		 (when url-fn
		   `("URL" ,(funcall url-fn v)))
		 (when id-fn
		   `(:id ,(funcall id-fn v))))))

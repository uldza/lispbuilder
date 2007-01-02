
(in-package #:lispbuilder-sdl)


(defun load-image (filename path &key
		   key-color alpha-value)
  (let ((surf (surface (sdl-base::load-image filename path))))
    (if surf
	(progn
	  (when key-color (set-color-key key-color :surface surf))
	  (when alpha-value (set-alpha alpha-value :surface surf))
	  surf)
	(error "ERROR, LOAD-IMAGE: file ~A, ~A not found" filename path))))

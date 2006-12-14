;; SDL (Simple Media Layer) library using CFFI for foreign function interfacing...
;; (C)2006 Justin Heyes-Jones <justinhj@gmail.com> and Luke Crook <luke@balooga.com>
;; Thanks to Frank Buss and Surendra Singh
;; see COPYING for license
;; This file contains some useful functions for using SDL from Common lisp
;; using sdl.lisp (the CFFI wrapper)

(in-package #:lispbuilder-sdl-base)



;;; w
(defmacro with-init (init-flags &body body)
  "Attempts to initialize the SDL subsystems using SDL-Init.
   Automatically shuts down the SDL subsystems using SDL-Quit upon normal application termination or
   if any fatal error occurs within &body.
   init-flags can be any combination of SDL-INIT-TIMER, SDL-INIT-AUDIO, SDL-INIT-VIDEO, SDL-INIT-CDROM,
   SDL-INIT-JOYSTICK, SDL-INIT-NOPARACHUTE, SDL-INIT-EVENTTHREAD or SDL-INIT-EVERYTHING."
  `(block nil
    (unwind-protect
	 (when (init-sdl :flags (list ,@init-flags))
	   ,@body)
      (sdl-cffi::SDL-Quit))))

(defun init-sdl (&key (flags sdl-cffi::SDL-INIT-VIDEO))
  (if (equal 0 (sdl-cffi::SDL-Init (set-flags flags)))
      t
      nil))

(defun was-init? (&key (flags sdl-cffi::SDL-INIT-VIDEO))
  (if (equal (set-flags flags)
	     (sdl-cffi::sdl-was-init (set-flags flags)))
      t
      nil))

(defun key= (key1 key2)
  (eq key1 key2))

(defun modifier= (mod key)
  "Returns t if the keypress modifier 'mod' is equal to the specified 'key'.
   (cffi:foreign-enum-value 'SDLMod key)."
  (equal mod (cffi:foreign-enum-value 'sdl-cffi::SDL-Mod key)))

(defun set-flags (&rest keyword-args)
  (if (listp (first keyword-args))
      (let ((keywords 
	     (mapcar #'(lambda (x)
			 (eval x))
		     (first keyword-args))))
	(apply #'logior keywords))
      (apply #'logior keyword-args)))

(defun load-bmp (filename)
  "load in the supplied filename, must be a bmp file"
  (if (and (stringp filename) (probe-file filename)) ; LJC: Make sure filename is a string and the filename exists.
      (sdl-cffi::SDL-Load-BMP-RW (sdl-cffi::sdl-RW-From-File filename "rb") 1)
      nil))

(defun load-image (filename path &key key-color alpha-value)
  (with-surface (surf (load-bmp (namestring (merge-pathnames filename path))) t)
    (convert-surface-to-display-format surf :key-color key-color :alpha-value alpha-value :free-p nil)))
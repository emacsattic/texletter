;;; texletter.el --- LaTeX letter templates
;; $Id: texletter.el,v 1.2 2003/01/13 18:39:12 ska Exp $
;; Copyright (C) 2002-2003 by Stefan Kamphausen
;; Author: Stefan Kamphausen <mail@skamphausen.de>
;; Keywords: tex, wp

;; This file is not part of XEmacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING. If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.


;;; Commentary:

;; TEXLetter on the Web:
;; Main page:
;; http://www.skamphausen.de/software/skamacs/texletter.html
;; German intro:
;; http://www.skamphausen.de/xemacs/lisp/texletter.html

;; This package let's you create your LaTeX letters from a collection
;; of simple template files. All those are the real LaTeX files
;; without any dynamic capabilities.

;; Installation:
;; (autoload 'texletter-create-letter
;;           "texletter"
;;           "Create LaTeX letters from templates."
;;           t)
;;
;; And if you want to:
;; (autoload 'texletter-install-templates-as-menu
;;           "texletter"
;;           "Adding menu items for all templates."
;;           t)
;; (texletter-install-templates-as-menu)
;;
;; Actually this is a quite primitve module - well it was my first
;; which kind of deserved the name "module"...

;;; Code:

;;; User options ---------------------------------------------------------
(defgroup texletter nil
  "Write LaTeX letters starting from different templates."
  :tag "TeX Letter"
  :link '(url-link :tag "Home Page" 
                   "http://www.skamphausen.de/software/skamacs/")
  :link '(emacs-commentary-link :tag "Commentary in texletter.el" "texletter.el")
  :prefix "texletter-"
  :group 'tex)

(defcustom texletter-template-directory "~/.texletter"
  "*The directory your templates reside in."
  :type 'string
  :group 'texletter)

(defcustom texletter-letter-directory "~/tex/letters"
  "*The directory you usually save your letters in."
  :type 'string
  :group 'texletter)

(defcustom texletter-max-menu-entries 10
  "*Limit the number of allowed entries in the menu."
  :type 'integer
  :group 'texletter)

;;;###autoload
(defun texletter-create-letter (&optional tmpl)
  "Create a new letter from a template.
Your templates live in `texletter-template-directory' and
your letters are by default stored to
`texletter-letter-directory'."
  (interactive)
  (let* ((template (or
					tmpl
					(expand-file-name
					 (completing-read "Choose a template: "
									  ;; build alist from directory list
									  (mapcar #'(lambda (x) (cons x t))
											  (directory-files
											   texletter-template-directory))
									  ;; predicate: no dotfiles
									  #'(lambda (x)
										  (not (string-match
												"^\\." (car x)))))
					 texletter-template-directory)))
         (default-file-name (concat texletter-letter-directory
                                    (format-time-string
                                     "/%Y-%m-%d-%H-%M.tex")))
         (file-name (expand-file-name
					 (read-file-name "Filename for letter: "
									 (file-name-directory default-file-name)
									 default-file-name nil
									 (file-name-nondirectory default-file-name))))
		 )
	(if (not (file-readable-p template))
		(message "Can not load the template file \"%s\"." template)
	  (progn
		(find-file template)
		(set-visited-file-name file-name)))
    ))

;;;###autoload
(defun texletter-install-templates-as-menu ()
  "Create a menu with all your templates as menu entries."
  nil
  (delete-menu-item '("Tools" "TeX Letter"))
  (if (not (paths-file-readable-directory-p
			texletter-template-directory))
	  (warn
	   "Warning: texletter template directory\n%s\n does not exist"
	   texletter-template-directory)
	(let ((list (directory-files
				 texletter-template-directory nil
				 "^[^\\.]"))
		  entry
		  (count 0))
	  (while (and (< count texletter-max-menu-entries)
				  list)
		(setq entry (car list))
		(setq count (1+ count))
		(setq menu-string
			  (progn (string-match "\\.tex" entry)
					 (substring entry 0 (match-beginning 0))))
		(add-menu-button
		 '("Tools" "TeX Letter")
		 (vector
		  (concat (format "%d. " count) menu-string)
		  (list 'texletter-create-letter
				(concat texletter-template-directory "/" entry))))
		(setq list (cdr list)))
	  )))

;;(delete-menu-item '("Tools" "TeX Letter"))
;;(texletter-install-templates-as-menu)
(provide 'texletter)

;;; texletter.el ends here
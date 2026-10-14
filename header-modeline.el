;;; header-modeline.el --- Move the modeline to the header line -*- lexical-binding: t; -*-

;; Author: Brad Stewart
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: convenience, mode-line
;; URL: https://github.com/bradmont/header-modeline

;;; Commentary:

;; A minor mode that moves the mode-line to the header line (top of the window).
;;
;; Enable globally with:
;;
;;   (header-modeline-mode 1)
;;
;; Originally inspired by:
;; https://emacs.stackexchange.com/questions/2418/moving-the-mode-line-and-minibuffer-to-the-top

;;; Code:

(defun header-modeline--sync-faces (&rest _)
  "Copy mode-line face attributes to header-line."
  (custom-set-faces
   `(header-line ((t ,(face-attr-construct 'mode-line))))))

(defun header-modeline--copy-to-header ()
  "For buffers that set `mode-line-format' locally, move it to header-line."
  (when mode-line-format
    (setq header-line-format
          (cl-subst '(:eval mode-name) 'mode-line-modes mode-line-format))
    (setq mode-line-format nil)))

(define-minor-mode header-modeline-mode
  "Display the modeline in the header line instead of at the bottom."
  :global t
  (if header-modeline-mode
      (progn
        (when (default-value 'mode-line-format)
          (setq-default header-line-format
                        (cl-subst '(:eval mode-name) 'mode-line-modes
                                  (default-value 'mode-line-format)))
          (setq-default mode-line-format nil))
        (add-hook 'window-configuration-change-hook #'header-modeline--copy-to-header)
        (add-hook 'enable-theme-functions #'header-modeline--sync-faces)
        (add-hook 'emacs-startup-hook #'header-modeline--sync-faces))
    (remove-hook 'window-configuration-change-hook #'header-modeline--copy-to-header)
    (remove-hook 'enable-theme-functions #'header-modeline--sync-faces)
    (remove-hook 'emacs-startup-hook #'header-modeline--sync-faces)
    (let ((saved (default-value 'header-line-format)))
      (setq-default mode-line-format saved)
      (setq-default header-line-format nil)
      (dolist (buf (buffer-list))
        (with-current-buffer buf
          (kill-local-variable 'mode-line-format)
          (kill-local-variable 'header-line-format))))))

(provide 'header-modeline)
;;; header-modeline.el ends here

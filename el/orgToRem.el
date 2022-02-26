;;; orgToRem --- custom functions to get a yearly CSV or daily TXT agenda.

;;; Commentary:

;;; Code:

(setq org-agenda-custom-commands
      '(("d" "day" agenda ""
         ((org-agenda-span 'day)
          (org-agenda-remove-tags t)
          (org-agenda-overriding-header "")))
        ("y" "Year" agenda ""
         ((org-agenda-start-day "2022-01-01")
          (org-agenda-show-future-repeats 'next)
          (org-deadline-warning-days 0)
          (org-agenda-archives-mode t)
          (org-agenda-entry-types
           '(:deadline :scheduled :timestamp :sexp))
          (org-agenda-span 'year)))))

(defun my-generate-day-txt ()
  (org-batch-agenda "d"))

(defun my-generate-year-csv ()
  (org-batch-agenda-csv "y"))

(provide 'orgToRem)
;;; orgToRem.el ends here

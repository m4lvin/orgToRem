;;; orgToRem --- custom functions to get a yearly CSV or daily TXT agenda.

;;; Commentary:

;;; Code:

(setq org-agenda-custom-commands
      '(("d" "day" agenda ""
         ((org-agenda-span 'day)
          (org-agenda-remove-tags t)
          (org-agenda-overriding-header "")))
        ("y" "Year" agenda ""
         ((org-agenda-start-day (concat (format-time-string "%Y-") "01-01"))
          (org-agenda-show-future-repeats 'next)
          (org-deadline-warning-days 0)
          (org-agenda-archives-mode t)
          (org-agenda-entry-types
           '(:deadline :scheduled :timestamp :sexp))
          (org-agenda-span 'year)))))

(provide 'orgToRem)
;;; orgToRem.el ends here

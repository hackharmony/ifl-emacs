;;; ifl.el --- Make I'm Feeling Lucky web searches directly from Emacs

;; Author: Zelly Snyder <zelly@outlook.com>
;; Version: 0.0.1
;; Package-Requires: ((request "0.3.0") (deferred "0.5.1") (request-deferred "0.2.0"))

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;;; This package allows you to invoke web search engine results from Emacs in a new web browser window (or using EWW if you're in non-graphical mode or set a configuration variable to do this). As the name implies, this package features the ability to immediately redirect to the first search result on either Google or DuckDuckGo. This is generally useful when you need to quickly look up something like a compiler error code that almost certainly will have the best Stack Overflow result as the first search result, saving you some precious milliseconds.

(require 'cl)
(require 'request)
(require 'request-deferred)
(require 'eww)
(require 'browse-url)

(defcustom ifl-default-search-engine 'google
"Choose which search engine to use for ``I'm Feeling Lucky'' type requests where you want to just jump to the first result. Currently only Google and DuckDuckGo are supported, since they are the only ones that offer this feature."
:options '(google duckduckgo))

(defcustom ifl-search-engine-urls-alist
  '((google . "https://www.google.com/search?q=%s")
    (wikipedia . "https://wikipedia.org/w/index.php?title=Special:Search&search=%s")
    (wikitionary . "https://wiktionary.org/w/index.php?title=Special:Search&search=%s")
    (duckduckgo "https://duckduckgo.com/?q=%s"))
  "Alist that maps names of available search engines with the format string for the URL of their result pages")

(defvar ifl--query-history nil "Previous search queries")
(defvar ifl--search-engines-history nil "Previous search engines used")

(defun ifl--open-url (URL)
  ;; FIXME put this in a side window the same way *Help* buffers are
  (browse-url URL)
  )

(defun ifl--google (query)
  "I'm Feeling Lucky. Tries to get the URL to go to directly."
  (deferred:$
    (request-deferred
     ;; (concat
     ;;  "https://www.google.com/search?hl=en&source=hp&biw=&bih=&btnI=I%27m+Feeling+Lucky&gbv=1&q="
     ;;  query)
     "https://www.google.com/search"
     :params `(("q" . ,query)
               ("hl" . "en")
               ("source" . "hp")
               ("biw" . "")
               ("bih" . "")
               ("btnI" . "I'm Feeling Lucky")
               ("gbv" . "1"))
     ;;:parser 'buffer-string
     :type "GET"
     :headers '(("accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8")
                ("user-agent" . "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/71.0.3578.98 Chrome/71.0.3578.98 Safari/537.36")
                ("referer" . "https://www.google.com/")))
    (deferred:nextc it
      (lambda (response)
        (let* ((history (request-response-history response))
               (target-url (or
                            ;; prefer to extract the target URL directly from the 302 redirect if it exists; no need to redo the HTTP request again to make the same hop
                            (request-response-header
                             (first history)
                             "location")
                            ;; if that fails, just navigate to the address directly
                            (request-response-url
                             (last history)))))
          (ifl--open-url target-url))))))

(defun ifl--duckduckgo (query)
  "I'm Feeling Ducky"
  (let ((target-url
         (concat "https://duckduckgo.com/?q=\\" query)))
    (ifl--open-url target-url)))

(defun ifl (query)
  "Loads the first result on a search engine for QUERY in a similar manner to ``I'm Feeling Lucky''.

If you are running a graphical Emacs process, the first result will open in your default web browser.

Customize IFL-DEFAULT-SEARCH-ENGINE to choose either Google (default) or DuckDuckGo as the backend."
  (interactive
   (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
       (list (buffer-substring-no-properties (region-beginning)
                                             (region-end)))
     (list (read-string "Query: " nil 'ifl--query-history)))
   )
  (funcall
   (cond ((eq ifl-default-search-engine 'google) #'ifl--google)
         ((eq ifl-default-search-engine 'duckduckgo) #'ifl--duckduckgo))
   query))


(defun ifl-search (query search-engine)
  "Searches for QUERY on SEARCH-ENGINE using the URL format string specified in IFL-SEARCH-ENGINE-URLS-ALIST (customizable)."
  (interactive
   (list
    (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
        (buffer-substring-no-properties (region-beginning)
                                        (region-end))
      (read-string "Query: " nil 'ifl--query-history))
    (intern
     (completing-read
     "Search engine: "
     (mapcar #'car ifl-search-engine-urls-alist)
     ;; :predicate
     nil
     ;; :require-match
     t
     ;; :initial-input
     nil
     ;; :history
     ifl--search-engines-history
     ;; :def
     (or (symbol-name (first ifl--search-engines-history))
         (symbol-name (caar ifl-search-engine-urls-alist)))))))
  (let ((target-url (format
                     (alist-get search-engine ifl-search-engine-urls-alist)
                     ;; FIXME properly url encode with percent signs
                     query)))
    (ifl--open-url target-url)))

(provide 'ifl)

;;; ifl.el ends here

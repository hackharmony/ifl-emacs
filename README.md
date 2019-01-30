# ifl.el --- I'm Feeling Lucky searches from Emacs

- Ever wanted to quickly look up a compiler error message in Emacs?
- Or you wanted to check if the spelling of a word was correct?
- Or you wanted to quickly pull up some Stack Overflow page using some text from your Emacs buffer?
- Too lazy to spend the extra 800ms that it would take to switch over to your web browser to do this? 😪

With this package, you can directly load the first search engine result of your query (either in a separate web browser or a EWW buffer) in the spirit of "I'm Feeling Lucky" from google or "I'm Feeling Ducky" from DuckDuckGo.

With `ifl-search` you can get the full search results page. Quickly search for something on Wikipedia, look up a word on Wikitionary, or search anything that you can provide a URL format string to search with. You can set a customization variable `ifl-shell-open-command` to `nil` to have the web page open in an EWW buffer so you truly don't have to leave Emacs.

# Usage

Download ifl.el
`(add-to-list 'load-path <directory with ifl.el>)`
`(require 'ifl)`

Now anywhere in Emacs you can pull up instant results for your searches by doing `M-x ifl`. If you have a region selected, the text in your region will be the input to your search, eliding input at the minibuffer.

`M-x ifl-search` searches search engines as defined in a customization variable. You can add as many search engines as you want.

# See also

My IFL repo which employs the same I'm Feeling Lucky behavior but as a Chrome/Firefox userscript.

# TODO

Put this on MELPA

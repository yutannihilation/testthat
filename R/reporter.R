#' Stub object for managing a reporter of tests.
#'
#' Do not clone directly from this object - children should implement all
#' methods.
#'
#' @keywords internal
#' @export
#' @export Reporter
#' @aliases Reporter
#' @importFrom R6 R6Class
Reporter <- R6::R6Class("Reporter",
  public = list(
    start_reporter = function() {},
    start_context =  function(context) {},
    start_test =     function(context, test) {},
    add_result =     function(context, test, result) {},
    end_test =       function(context, test) {},
    end_context =    function(context) {},
    end_reporter =   function() {},
    is_full =        function() FALSE,

    out = NULL,

    initialize = function(file = getOption("testthat.output_file", stdout())) {
      self$out <- file
      if (is.character(self$out) && file.exists(self$out)) {
        # If writing to a file, overwrite it if it exists
        file.remove(self$out)
      }
    },

    cat_tight = function(...) {
      cat(..., sep = "", file = self$out, append = TRUE)
    },

    cat_line = function(...) {
      cli::cat_line(..., file = self$out)
    },

    rule = function(...) {
      cli::cat_rule(..., file = self$out)
    },

    # The hierarchy of contexts are implied - a context starts with a
    # call to context(), and ends either with the end of the file, or
    # with the next call to context() in the same file. These private
    # methods paper over the details so that context appear to work
    # in the same way as tests and expectations.
    .context = NULL,
    .start_context = function(context) {
      if (!is.null(self$.context)) {
        self$end_context(self$.context)
      }
      self$.context <- context
      self$start_context(context)

      invisible()
    },
    .end_context = function(context) {
      if (!is.null(self$.context)) {
        self$end_context(self$.context)
        self$.context <- NULL
      }
      invisible()
    }
  )
)

fancy_line <- function(x) {
  if (!l10n_info()$`UTF-8`) {
    return(x)
  }

  switch(x,
    "-" = "\u2500",
    "=" = "\u2550",
    x
  )
}

#' Retrieve the default reporter.
#'
#' The defaults are:
#' * [SummaryReporter] for interactive; override with `testthat.default_reporter`
#' * [CheckReporter] for R CMD check; override with `testthat.default_check_reporter`
#'
#' @export
#' @keywords internal
default_reporter <- function() {
  getOption("testthat.default_reporter", "progress")
}

#' @export
#' @rdname default_reporter
check_repoter <- function() {
  getOption("testthat.default_check_reporter", "check")
}

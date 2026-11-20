#' Simplified Linear Model
#'
#' @param formula an object of class formula representing the model to be fitted.
#' @param data an optional data frame, list or environment containing the variables in the model. Not required if the variables to be used can be found in the environment attached to the formula.
#' @param model,x,y logical switches. If TRUE the corresponding components of the fit are added to the default return list.
#' @param method default method is QR decomposition using EigenCPP may implement another method to compare to
#'
#' @returns Returns a list of the following model components:
#' * `coefficients`
#' * `residuals`
#' * `fitted.values`
#' * `rank`
#' * `df.residual`
#' * `terms`
#' * `xlevels`
#' * `y`
#' * `x`
#' * `model`
#' @export
#'
#' @examples
#' # Basic Usage
#' # lm(y~x)
#' # placeholder
#' a <- 2+2
lm <- function(formula, data, model = TRUE, x, y, method = "qr") {
  # TODO: add in a method = "qr" default so I can potentially compare to a worse
  # matrix math version of solving for the OLS
  # TODO: consider if we need qrDecomp to return the rank or if we can just calculate it here

  # the main idea is figure out if we have data, if not check parent frame of the
  # formula. Somehow lm coerces valid string inputs of formulas into type formula

  # we need a to use the stats generics with a formula to construct a model matrix
  # which we can do with model terms and model frame that can be derived with generics
  # from formula

  x <- model.matrix()
  if (method == "qr") {
    fit <- qrDecomp(x, y)
  }

  class(z) <- c(if (mlm) "mlm", "lm")

  # construct list to return to user, checking on logical switches whether they
  # want the model, x, and/or y
  return(fit)
}

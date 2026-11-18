#' Simplified Linear Model
#'
#' @param formula an object of class formula representing the model to be fitted.
#' @param data an optional data frame, list or environment containing the variables in the model. Not required if the variables to be used can be found in the environment attached to the formula.
#' @param model,x,y logical switches. If TRUE the corresponding components of the fit are added to the default return list.
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
lm <- function(formula, data, model = TRUE, x, y) {
  # need to handle formula validation

  # need to handle existence of the terms of the formula within the given data
  # and then within the formula parent.frame()

  # I am not going to be doing any special weights, contrasts, or dealing with na.actions
  # so we just na.rm() and then do the matrix math through a function call to my
  # eigen cpp function

  # construct list to return to user, checking on logical switches whether they
  # want the model, x, and/or y
  return(fit)
}

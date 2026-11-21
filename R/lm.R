#' Simplified Linear Model
#'
#' @param formula an object of class formula representing the model to be fitted or something coercible into class formula.
#' @param data an optional data frame, list or environment containing the variables in the model. Not required if the variables to be used can be found in the environment attached to the formula.
#' @param model,x,y logical switches. If TRUE the corresponding components of the fit are added to the default return list.
#'
#' @returns Returns a list of the following model components:
#' * `coefficients` the beta matrix for the linear model.
#' * `residuals` the residuals, y_i - y_hat.
#' * `fitted.values` the fitted mean values, y_hat.
#' * `rank` the rank of the fitted linear model.
#' * `df.residual` the residual degrees of freedom.
#' * `terms` the stats model.frame attribute terms object used.
#' * `y` if requested, the response used.
#' * `x` if requested, the covariate matrix used.
#' * `R` the R matrix of the QR decomposition for calculating SE.
#' * `pivot` the pivot matrix used in QR decomposition.
#' * `model` if requested the model frame used.
#' @export
#'
#' @examples
#' # Basic Usage: model of outcome y using all covariates
#' set.seed(123)
#' n <- 1000
#' x1 <- rnorm(n, 3, 1)
#' x2 <- rnorm(n, 10, 3)
#' eps <- rnorm(n, 0, 1)
#' y <- 2 + 0.7 * x1 + 0.35 * x2 + eps
#' sim_df <- data.frame(y = y, var1 = x1, var2 = x2)
#' mod <- lm(y ~ ., sim_df)
lm <- function(formula, data, model = TRUE, x = FALSE, y = FALSE) {
  # the main idea is figure out if we have data, if not check parent frame of the
  # formula. Somehow lm coerces valid string inputs of formulas into type formula
  if (is.character(formula)) {
    formula <- stats::as.formula(formula, env = parent.frame())
  }
  if (!inherits(formula, "formula")) {
    # as.formula() didn't produce a valid formula
    stop(
      "formula must be a formula or a string such as \"y ~ x\"."
    )
  }

  # we need a to use the stats generics with a formula to construct a model matrix
  # which we can do with model terms and model frame that can be derived with generics
  # from formula
  model_frame <- model.frame(formula, data = data, na.action = na.omit)
  terms <- attr(model_frame, "terms")
  mr <- model.response(model_frame, "numeric")
  mm <- model.matrix(terms, model_frame)

  fit <- qrDecomp(mm, mr)

  n <- nrow(mm)
  p <- ncol(mm)
  r <- fit$rank

  # rank deficiency warning
  if (r < p) {
    warning(
      "X is rank deficient, duplicate coefficient set to NA"
    )
  }

  # this is why we needed to keep pivot, to know which coefficients match what
  # there was probably a way to do all of this in cpp...
  keep <- fit$pivot[seq_len(r)]

  fitted <- drop(mm[, keep, drop = FALSE] %*% fit$coefficients[keep])
  resid <- mr - fitted
  df <- n - r

  # this is the model matrix so works for the expansion of factors and interaction terms
  names(fit$coefficients) <- colnames(mm)
  names(fitted) <- rownames(mm)

  lm_625 <- Filter(
    Negate(is.null),
    list(
      coefficients = fit$coefficients,
      residuals = resid,
      fitted.values = fitted,
      rank = r,
      df.residual = df,
      terms = terms,
      y = if (y) mr,
      x = if (x) mm,
      R = fit$R,
      pivot = fit$pivot,
      model = model_frame
    )
  )

  return(lm_625)
}

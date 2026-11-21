# missing names for the coefficients
test_that("simple lm works, matches stats::lm() and returns all of the pieces expected out", {
  f <- mpg ~ wt + hp + qsec
  mod_625 <- lm(f, data = mtcars, x = TRUE, y = TRUE)
  mod_stats <- stats::lm(f, data = mtcars, x = TRUE, y = TRUE)

  # check all common outputs are the same
  expect_equal(mod_stats$coeff, mod_625$coefficients)
  expect_equal(mod_stats$residuals, mod_625$residuals)
  expect_equal(mod_stats$fitted.values, mod_625$fitted.values)
  expect_equal(mod_stats$rank, mod_625$rank)
  expect_equal(mod_stats$df.residual, mod_625$df.residual)
  expect_equal(mod_stats$terms, mod_625$terms)
  expect_equal(mod_stats$y, mod_625$y)
  expect_equal(mod_stats$x, mod_625$x)
  expect_equal(mod_stats$model, mod_625$model)

  # stats::lm() returns some aspects of the qr that I don't understand fully
  # I know you need the R to calculate SE later, so I return that, just need
  # to check that it is returning R and pivot. I'm also not expecting an exact match
  # between the decompositions I think
  expect_false(is.null(mod_625$R))
  expect_false(is.null(mod_625$pivot))
})

## there is something about .call matching that I might need, try providing inputs
# out of order like data first and compare to lm()'s implementation

test_that("formula structure is converted for the three useable cases", {
  set.seed(123)
  n <- 1000
  x1 <- rnorm(n, 3, 1)
  x2 <- rnorm(n, 10, 3)
  eps <- rnorm(n, 0, 1)
  y <- 2 + 0.7 * x1 + 0.35 * x2 + eps
  sim_df <- data.frame(y = y, var1 = x1, var2 = x2)

  form <- lm(y ~ ., sim_df)
  str <- lm("y ~ .", sim_df)
  # this one inherits data from the parent.frame() environment through formula construction
  env <- lm(sim_df$y ~ sim_df$var1 + sim_df$var2)

  expect_equal(str$model, form$model)
  # that also means it's variable names do not match the others so needs to be stripped for comparison
  expect_true(all(unname(env$model) == unname(form$model)))
})

# rank deficiency, expect warning but same fitted values as stats::lm()
test_that("warns on rank-deficient X but still gives stats::lm()'s fitted values", {
  X <- model.matrix(mpg ~ wt + hp, mtcars)
  X <- unname(cbind(X, dup = 2 * X[, "wt"]))
  y <- mtcars$mpg

  dup <- mtcars$hp
  df <- cbind(mtcars, dup)
  f <- mpg ~ wt + hp + dup
  expect_warning(lm(f, df), "rank deficient")
  # the fitted values should still match stats::lm()
  mod_625 <- suppressWarnings(lm(f, df))
  expect_equal(stats::lm(f, df)$fitted.values, mod_625$fitted.values)
})

# test case I would work on in the future
# test_that("works with categorical covariates, check the return x.level to make sure it retains user factor_level choices", {})

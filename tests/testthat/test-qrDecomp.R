# stats::lm uses QR decomposition integrated through a Fortran function, so we can see
# if my use of Eigen qrDecomposition matches

test_that("matches stats::lm() on a standard regression", {
  X <- model.matrix(mpg ~ wt + hp + qsec, data = mtcars)
  y <- mtcars$mpg
  expect_equal(
    qrDecomp(X, y)$coefficients,
    unname(coef(stats::lm(mpg ~ wt + hp + qsec, mtcars)))
  )
})

test_that("matches stats::lm() with factors and interactions", {
  f <- mpg ~ wt * factor(cyl) + log(hp)
  X <- model.matrix(f, data = mtcars)
  expect_equal(
    qrDecomp(X, mtcars$mpg)$coefficients,
    unname(coef(stats::lm(f, mtcars)))
  )
})

test_that("intercept-only model returns the mean", {
  y <- c(3, 7, 1, 9, 5)
  expect_equal(qrDecomp(matrix(1, length(y), 1), y)$coefficients, mean(y))
})

# we can also make these all just matrices and check the expectation of OLS
# estimates being orthogonal to the residuals

test_that("residuals are orthogonal to the columns of X (normal equations)", {
  X <- unname(model.matrix(mpg ~ wt + hp, mtcars))
  y <- mtcars$mpg
  r <- unname(y - X %*% qrDecomp(X, y)$coefficients)
  expect_equal(drop(crossprod(X, r)), rep(0, ncol(X)), tolerance = 1e-8)
})


# rank returns the right value
test_that("Returns a reduced rank for duplicated columns", {
  X <- model.matrix(mpg ~ wt + hp, mtcars)
  X <- unname(cbind(X, dup = 2 * X[, "wt"]))
  y <- mtcars$mpg
  # 3 because we have B_0 the intercept in this model as well
  expect_equal(qrDecomp(X, y)$rank, 3)
})

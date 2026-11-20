# stats::lm uses QR decomposition integrated through a Fortran function, so we can see
# if my use of Eigen qrDecomposition matches

test_that("matches stats::lm() on a standard regression", {
  X <- model.matrix(mpg ~ wt + hp + qsec, data = mtcars)
  y <- mtcars$mpg
  expect_equal(
    qrDecomp(X, y),
    unname(coef(stats::lm(mpg ~ wt + hp + qsec, mtcars)))
  )
})

test_that("matches stats::lm() with factors and interactions", {
  f <- mpg ~ wt * factor(cyl) + log(hp)
  X <- model.matrix(f, data = mtcars)
  expect_equal(qrDecomp(X, mtcars$mpg), unname(coef(stats::lm(f, mtcars))))
})

test_that("intercept-only model returns the mean", {
  y <- c(3, 7, 1, 9, 5)
  expect_equal(qrDecomp(matrix(1, length(y), 1), y), mean(y))
})

# we can also make these all just matrices and check the expectation of OLS
# estimates being orthogonal to the residuals

test_that("residuals are orthogonal to the columns of X (normal equations)", {
  X <- unname(model.matrix(mpg ~ wt + hp, mtcars))
  y <- mtcars$mpg
  r <- unname(y - X %*% qrDecomp(X, y))
  expect_equal(drop(crossprod(X, r)), rep(0, ncol(X)), tolerance = 1e-8)
})

# I additionally added a test for rank deficiency, so we can see if that works
# I'm not sure how stats::lm() deals with non-full rank X so I should check that
# as well
# looks like it handles it similarly but returns the rank with in the model object
# so we could consider changing qrDecomp to return the rank as well.

test_that("warns on rank-deficient X but still gives stats::lm()'s fitted values", {
  X <- model.matrix(mpg ~ wt + hp, mtcars)
  X <- unname(cbind(X, dup = 2 * X[, "wt"]))
  y <- mtcars$mpg
  expect_warning(b <- qrDecomp(X, y), "rank deficient")
  # the fitted values should still match stats::lm() run without the duplicate
  expect_equal(drop(X %*% b), unname(fitted(stats::lm(mpg ~ wt + hp, mtcars))))
})

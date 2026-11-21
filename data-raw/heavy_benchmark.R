devtools::load_all()

sim_data <- function(n, p, seed) {
  set.seed(seed)
  X <- matrix(
    rnorm(n * p),
    n,
    p,
    dimnames = list(NULL, paste0("x", seq_len(p)))
  )
  data.frame(y = drop(X %*% rnorm(p)) + rnorm(n), X)
}

# we can also show that they return the same estimates for all of this data
same_coef <- function(a, b) isTRUE(all.equal(unname(coef(a)), unname(coef(b))))

# bench::press() allows us to aggregate the data across runs with different parameters
# of bench::mark()
# here we check across a factorial design of 3 sample sizes and a set of 5 or 20
# random covariates
results <- bench::press(
  n = c(1e2, 1e3, 1e4),
  p = c(5, 20),
  seed = 123:128,
  {
    df <- sim_data(n, p, seed)

    # generate the random data sets and then time them
    bench::mark(
      lm_625 = lm(y ~ ., data = df),
      stats = stats::lm(y ~ ., data = df),
      check = same_coef,
      min_iterations = 10
    )
  }
)

# drop the actual outputs and memory from bench::press we just want the information
# for generating the table in the vignette
results$result <- NULL
results$memory <- NULL

saveRDS(results, "vignettes/benchmark_results.rds")

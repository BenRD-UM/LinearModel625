
<!-- README.md is generated from README.Rmd. Please edit that file -->

# LinearModel625

<!-- badges: start -->

[![R-CMD-check](https://github.com/BenRD-UM/LinearModel625/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/BenRD-UM/LinearModel625/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/BenRD-UM/LinearModel625/graph/badge.svg)](https://app.codecov.io/gh/BenRD-UM/LinearModel625)
<!-- badges: end -->

The goal of LinearModel625 is to replicate the basic working of the base
linear model function in R, stats::lm(). I wanted to learn about QR
decomposition and try and implement it with R C++ integration. I had
heard about the Eigen library for C++ while looking at other packages
and wanted to see if I could use it for this homework.

## Installation

You can install the development version of LinearModel625 like so:

``` r
remotes::install_github("BenRD-UM/LinearModel625")

# To view vignettes
remotes::install_github("BenRD-UM/LinearModel625", build_vignettes)
browse_vignettes("LinearModel625")
```

## Example

You can run LinearModel625::lm() exactly the same way as stats::lm() for
basic use cases

``` r
library(LinearModel625)
#> 
#> Attaching package: 'LinearModel625'
#> The following object is masked from 'package:stats':
#> 
#>     lm
## basic example code
set.seed(123)
n <- 1000
x1 <- rnorm(n, 3, 1)
x2 <- rnorm(n, 10, 3)
eps <- rnorm(n, 0, 1)
y <- 2 + 0.7 * x1 + 0.35 * x2 + eps
sim_df <- data.frame(y = y, var1 = x1, var2 = x2)

# If we have some data that is generated with a clear relationship how does the
# linear model look

mod_625 <- lm(y~.,sim_df)

coef(mod_625)
#> (Intercept)        var1        var2 
#>   1.9518512   0.6785085   0.3591689
```

As we can see it correctly identifies the mean and positive relationship
of the two covariates. Additionally we can see that it gives the same
beta estimates to stats::lm().

``` r
all.equal(coef(mod_625), coef(stats::lm(y~., data = sim_df)))
#> [1] TRUE
coef(stats::lm(y~., data = sim_df))
#> (Intercept)        var1        var2 
#>   1.9518512   0.6785085   0.3591689
```

I did not match the lm class directly, so integration with summary() and
anova() is not implemented. See the [benchmark
vignette](vignettes/benchmarks.Rmd) for more details.

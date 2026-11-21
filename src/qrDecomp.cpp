#include <RcppEigen.h>

//' QR decomposition calculator with RcppEigen
//'
//' A method for implementing qr decomposition for solving OLS estimates for linear models.
//'
//' @param X the covariate matrix
//' @param y the observation of the given outcome variable
//' @return returns the beta vector of the OLS estimate for the given model, the
//' rank of the covariate matrix, the pivoted covariate column order, and the R triangular
//' matrix from the decomposition.
//' @examples
//' # Basic usage for lm QR decomposition
//' X <- model.matrix(mpg ~ wt + hp + qsec, data = mtcars)
//' y <- mtcars$mpg
//' qr <- qrDecomp(X,y)
//' @export
// [[Rcpp::export]]
Rcpp::List qrDecomp(const Eigen::Map<Eigen::MatrixXd>& X, const Eigen::Map<Eigen::VectorXd>& y) {

  const Eigen::Index n = X.rows();
  const Eigen::Index p = X.cols();

   // Basic size check
  if (n != y.size()) {
    Rcpp::stop("X and y must have the same number of rows");
  }

  // XP = QR the namesake of QR decomposition
  Eigen::ColPivHouseholderQR<Eigen::MatrixXd> qr(X);
  qr.setThreshold(1e-7); // same threshold to the default of stats::lm()

  // need to return rank
  const Eigen::Index r = qr.rank();

  // Using triangularView as a memory efficient way to tell the object to just look
  // at the upper triangle of the matrix which is the whole point of R
  Eigen::MatrixXd R = qr.matrixR().topLeftCorner(r, r).triangularView<Eigen::Upper>();

  // Coefficients: back-solve Rz = (Q'y)[1:r], this is some known math
  // additionally we have to use a pivot of the columns because we are catching
  // colinear terms here and then unpivot to match them back to the right terms
  Eigen::VectorXd effects = qr.householderQ().adjoint() * y;
  Eigen::VectorXd coefPiv = Eigen::VectorXd::Constant(p, NA_REAL);
  coefPiv.head(r) = R.triangularView<Eigen::Upper>().solve(effects.head(r));
  const Eigen::VectorXd coef = qr.colsPermutation() * coefPiv;

  Rcpp::IntegerVector pivot(p);
  for (Eigen::Index k = 0; k < p; ++k) {
    pivot[k] = static_cast<int>(qr.colsPermutation().indices()(k)) + 1;
  }

  // realized that we need R directly for calculating SE
  return Rcpp::List::create(
    Rcpp::Named("coefficients") = coef,
    Rcpp::Named("R")            = R,
    Rcpp::Named("rank")         = static_cast<int>(r),
    Rcpp::Named("pivot")        = pivot
  );

}

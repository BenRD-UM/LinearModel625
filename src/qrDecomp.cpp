#include <RcppEigen.h>

//' QR decomposition calculator with RcppEigen
//'
//' A method for implementing qr decomposition for solving OLS estimates for linear models.
//'
//' @param X the covariate matrix
//' @param y the observation of the given outcome variable
//' @return returns the beta vector of the OLS estimate for the given model
//' @export
// [[Rcpp::export]]
Eigen::VectorXd qrDecomp(const Eigen::Map<Eigen::MatrixXd>& X, const Eigen::Map<Eigen::VectorXd>& y) {

  // Basic size check
  if (X.rows() != y.size()) {
    Rcpp::stop("X and y must have the same number of rows");
  }

  // QR decomposition is really optimized in eigen, so there
  // is already a function available for our needs
  Eigen::ColPivHouseholderQR<Eigen::MatrixXd> qr(X);

  // Check for rank deficiency in X
  if (qr.rank() < X.cols()) {
    Rcpp::warning("X is rank deficient (rank %d < %d columns)",
                  static_cast<int>(qr.rank()), static_cast<int>(X.cols()));
  }

  Eigen::VectorXd OLS = qr.solve(y);

  return OLS;
}

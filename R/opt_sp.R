# WARNING - Generated by {fusen} from /dev/auc.Rmd: do not edit by hand

#' Optimal Specificity
#' 
#' These functions estimate the optimal (maximal or minimal) sensitivity of a PRS.
#' 
#' @param thresh.vector (numeric) Vector of thresholds
#' @param k (numeric; range 0-1) Population prevalence of the disease of interest
#' @param pve (numeric; range 0-1) Proportion of variability explained by the PRS
#' @param se (numeric; range 0-1) Sensitivity
#' @param n.bins (integer) Number of bins for estimating the AUC (default = 100)
#' @param direction (character) `"max"` or `"min"`
#'
#' @return A numeric valuve for the optimal sensitivity
#' 
#' @export
#' 
#' @examples
#' opt_sp(k = 0.13, pve = 0.26, se = 0.99)
opt_sp <- function(k, pve, se, n.bins=1000, thresh.vector=seq(from=1,to=n.bins,by=10), direction="max"){
    checkmate::assert_numeric(k, lower = 0, upper = 1)
    checkmate::assert_numeric(pve, lower = 0, upper = 1)
    checkmate::assert_numeric(n.bins)
    checkmate::assert_numeric(se, lower = 0, upper = 1)
    checkmate::assert_choice(direction, choices = c("min", "max"))
    #vector of specificity at each threshold
    sp.tmp.v <- apply(X=as.matrix(thresh.vector), MARGIN=1, FUN=optSpGivenThresh, k=k, pve=pve, n.bins=n.bins,
    se=se, direction=direction)
    sp <- max(sp.tmp.v)
    return(sp)
}

#' @noRd
optSpGivenThresh <- function(thresh, k, pve, se, n.bins, direction="max"){
    obj <- c(n.bins-0:(thresh-1), rep(0, n.bins-thresh+1))/(n.bins*(1-k))
    se.coeff <- c(rep(0, thresh), thresh:n.bins)/(n.bins*k)
    #constraints: avg risk=k, pve, sp, sum(p)=1, 0<=p, p<=1
    Amat <- rbind((0:n.bins)/n.bins, (0:n.bins)^2/(n.bins^2), se.coeff, rep(1,n.bins+1), diag(n.bins+1), -diag(n.bins+1))
    rhs <- c(k, k*(1-k)*pve+k^2, se, 1, numeric(n.bins+1), rep(-1,n.bins+1))
    lp.res <- lpSolve::lp(direction=direction, objective.in=obj, const.mat=Amat, const.dir=c(rep("=",4), 
    rep(">=", 2*n.bins+2)), const.rhs=rhs)
    return(lp.res$objval)
}

# WARNING - Generated by {fusen} from /dev/auc.Rmd: do not edit by hand

test_that("max_auc works", {
  res <- max_auc(k = 0.13, pve = 0.26)
  expect_true(inherits(max_auc, "function"))
  expect_type(res, "double")
})

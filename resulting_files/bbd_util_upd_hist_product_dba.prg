CREATE PROGRAM bbd_util_upd_hist_product:dba
 EXECUTE dm_dbimport "cer_install:bbd_upd_donor_cross_reference.csv", "bbd_import_donor_crossref",
 1000
END GO

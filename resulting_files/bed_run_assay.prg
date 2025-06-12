CREATE PROGRAM bed_run_assay
 SET filename = "CER_INSTALL:ps_assay.csv"
 SET scriptname = "bed_ens_assay_ps"
 DELETE  FROM br_auto_dta
  WHERE task_assay_cd > 0
  WITH nocounter
 ;end delete
 DELETE  FROM br_auto_oc_dta
  WHERE task_assay_cd > 0
  WITH nocounter
 ;end delete
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO

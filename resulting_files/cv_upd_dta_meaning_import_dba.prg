CREATE PROGRAM cv_upd_dta_meaning_import:dba
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET cv.cdf_meaning = requestin->list_0[d.seq].cdf_meaning
  PLAN (d)
   JOIN (cv
   WHERE cv.code_value=cnvtint(requestin->list_0[d.seq].task_assay_cd))
  WITH nocounter
 ;end update
 SET reqinfo->commit_ind = 1
END GO

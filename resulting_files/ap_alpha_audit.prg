CREATE PROGRAM ap_alpha_audit
 SET failed = "F"
 SET alpha_resp_princ_type = 0.0
 SET anat_path_source_vocab = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE 400=cv.code_set
   AND cv.cdf_meaning="ANATOMIC PAT"
  HEAD REPORT
   anat_path_source_vocab = 0
  DETAIL
   anat_path_source_vocab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE 401=cv.code_set
   AND cv.cdf_meaning="ALPHA RESPON"
  HEAD REPORT
   alpha_resp_princ_type = 0
  DETAIL
   alpha_resp_princ_type = cv.code_value
  WITH nocounter
 ;end select
 SELECT
  n.mnemonic, source_string = trim(n.source_string), n.updt_dt_tm,
  n_active_ind =
  IF (n.active_ind=1) "YES"
  ELSE "NO"
  ENDIF
  , n.active_ind, n.updt_id
  FROM nomenclature n
  PLAN (n
   WHERE alpha_resp_princ_type=n.principle_type_cd
    AND anat_path_source_vocab=n.source_vocabulary_cd)
  ORDER BY n.mnemonic
  HEAD REPORT
   line = fillstring(130,"-"), pg = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 100, "Page", pg,
   row + 1, col 1, "Alpha Responses",
   col 100, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2,
   col 5, "MNEMONIC", col 35,
   "SHORT STRING", col 95, "ACTIVE",
   row + 1, col 0, line,
   row + 1
  DETAIL
   col 5, n.mnemonic, col 35,
   source_string, col 97, n_active_ind,
   row + 1
  WITH nocounter, maxcol = 300
 ;end select
#exit_script
END GO

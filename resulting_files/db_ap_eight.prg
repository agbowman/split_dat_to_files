CREATE PROGRAM db_ap_eight
 SELECT
  dta.mnemonic, dta.description, n.source_identifier,
  n.source_string
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (dta)
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
  HEAD REPORT
   pg = 0, line = fillstring(105,"-"), x = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Alpha Responses",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2
   IF (x=1)
    row + 1, text = substring(1,50,dta.description), col 1,
    "TEST: ", dta.mnemonic, col 55,
    text, row + 1, col 5,
    "(continued)", row + 1, col 10,
    "ALPHA RESPONSE", col 65, "ALPHA TEXT",
    row + 1, col 10, line,
    row + 1
   ENDIF
  HEAD dta.mnemonic
   row + 1, x = 1, text = substring(1,50,dta.description),
   col 1, "TEST: ", dta.mnemonic,
   col 55, text, row + 2,
   col 10, "ALPHA RESPONSE", col 65,
   "ALPHA TEXT", row + 1, col 10,
   line, row + 1
  DETAIL
   text = substring(1,50,n.source_string), col 10, n.source_identifier,
   col 65., text, row + 1
  FOOT  dta.mnemonic
   x = 0, row + 1
 ;end select
END GO

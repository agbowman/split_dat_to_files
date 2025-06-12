CREATE PROGRAM db_ap_nine
 SELECT
  cv.display, cv.description, dta.mnemonic,
  agi.begin_section"###", agi.end_section"###", agi.begin_level"###",
  agi.end_level"###", agi.no_charge_ind
  FROM code_value cv,
   ap_processing_grp_r agi,
   discrete_task_assay dta
  PLAN (cv
   WHERE cv.code_set=1310)
   JOIN (agi
   WHERE cv.code_value=api.parent_entity_id
    AND api.parent_entity_name="CODE_VALUE")
   JOIN (dta
   WHERE agi.task_assay_cd=dta.task_assay_cd)
  HEAD REPORT
   line = fillstring(94,"-"), pg = 0, x = 0,
   r = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Group Procedures",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2
   IF (x=1)
    row + 1, col 1, "TEST: ",
    cv.display, col 45, cv.description,
    row + 1, col 10, "(continued)",
    col 75, "SECTION", col 90,
    "LEVEL", row + 1, col 20,
    "DETAIL", col 75, "BEG",
    col 80, "END", col 90,
    "BEG", col 95, "END",
    col 105, "CHARGE", row + 1,
    col 20, line, row + 1
   ENDIF
  HEAD cv.display
   x = 1, row + 1, col 1,
   "TEST: ", cv.display, col 45,
   cv.description, row + 1, col 75,
   "SECTION", col 90, "LEVEL",
   row + 1, col 20, "DETAIL",
   col 75, "BEG", col 80,
   "END", col 90, "BEG",
   col 95, "END", col 105,
   "CHARGE", row + 1, col 20,
   line, row + 1
  DETAIL
   col 20, dta.mnemonic, col 75,
   agi.begin_section, col 80, agi.end_section,
   col 90, agi.begin_level, col 95,
   agi.end_level
   IF (agi.no_charge_ind=1)
    col 105, "No Charge"
   ELSE
    col 105, "Charge"
   ENDIF
   row + 1
  FOOT  cv.display
   r = (row+ 4), x = 0
   IF (r > 56)
    BREAK
   ELSE
    row + 1
   ENDIF
 ;end select
END GO

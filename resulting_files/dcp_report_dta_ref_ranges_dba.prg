CREATE PROGRAM dcp_report_dta_ref_ranges:dba
 SET modify = predeclare
 DECLARE age_from = vc WITH noconstant("")
 DECLARE age_to = vc WITH noconstant("")
 DECLARE seconds_cd = f8 WITH noconstant(0.0)
 DECLARE minutes_cd = f8 WITH noconstant(0.0)
 DECLARE hours_cd = f8 WITH noconstant(0.0)
 DECLARE days_cd = f8 WITH noconstant(0.0)
 DECLARE weeks_cd = f8 WITH noconstant(0.0)
 DECLARE months_cd = f8 WITH noconstant(0.0)
 DECLARE years_cd = f8 WITH noconstant(0.0)
 EXECUTE cclseclogin
 SET seconds_cd = uar_get_code_by("MEANING",340,"SECONDS")
 SET minutes_cd = uar_get_code_by("MEANING",340,"MINUTES")
 SET hours_cd = uar_get_code_by("MEANING",340,"HOURS")
 SET days_cd = uar_get_code_by("MEANING",340,"DAYS")
 SET weeks_cd = uar_get_code_by("MEANING",340,"WEEKS")
 SET months_cd = uar_get_code_by("MEANING",340,"MONTHS")
 SET years_cd = uar_get_code_by("MEANING",340,"YEARS")
 SELECT
  age_from_units_disp = uar_get_code_display(rrf.age_from_units_cd), age_to_units_disp =
  uar_get_code_display(rrf.age_to_units_cd), date_updated = format(rrf.updt_dt_tm,"@SHORTDATETIME"),
  dta.mnemonic, dta.task_assay_cd
  FROM reference_range_factor rrf,
   discrete_task_assay dta
  PLAN (rrf
   WHERE rrf.active_ind=1
    AND ((rrf.age_from_units_cd=months_cd) OR (rrf.age_to_units_cd=months_cd))
    AND rrf.updt_dt_tm > cnvtdatetime("30-AUG-2004"))
   JOIN (dta
   WHERE rrf.task_assay_cd=dta.task_assay_cd)
  ORDER BY dta.task_assay_cd
  HEAD REPORT
   line = fillstring(81,"-"), today = format(curdate,"MM/DD/YYYY;;D"), now = format(curtime,
    "HH:MM:SS;;S"),
   row 1, col 10, "Potentially Wrong Reference Ranges to Review",
   row + 1, col 10, "Report Date: ",
   col + 1, today, row + 1,
   col 10, "Report Time: ", col + 1,
   now, row + 2, col 10,
   "This report identifies all reference range rows which have been updated", row + 1, col 10,
   "since August 30, 2004, AND which happen to use a unit of MONTHS. Due to", row + 1, col 10,
   "an inconsistency introduced at this date, these rows have the possibility", row + 1, col 10,
   "of being incorrect, and thus need to be reviewed for accuracy.", row + 2, col 1,
   "** => This marking on a row indicates a reference range which absolutely", row + 1, col 1,
   "      needs to be reviewed and fixed. Either age_from or age_to is calculating", row + 1, col 1,
   "      with a remainder, indicating a definite problem with the reference range.", row + 1, col 1,
   "      The DTA should be opened in the DTA Wizard tool, and after reviewing its", row + 1, col 1,
   "      ranges for correctness, the Apply button should be pressed, forcing a", row + 1, col 1,
   "      clean save of the reference ranges on that DTA.", row + 1, col 0,
   line, row + 1
  HEAD dta.task_assay_cd
   col 0, "DTA Mnemonic: ", col + 1,
   dta.mnemonic, row + 1, col 4,
   "Age From", col 16, "Age From Units",
   col 33, "Age To", col 45,
   "Age To Units", col 60, "Date Last Updated",
   row + 1
  DETAIL
   IF (rrf.age_from_units_cd=days_cd)
    age_from = format(((rrf.age_from_minutes/ 60)/ 24.0),"#######.##;L")
   ELSEIF (rrf.age_from_units_cd=hours_cd)
    age_from = format((rrf.age_from_minutes/ 60.0),"#######.##;L")
   ELSEIF (rrf.age_from_units_cd=minutes_cd)
    age_from = format(rrf.age_from_minutes,"#######.##;L")
   ELSEIF (rrf.age_from_units_cd=months_cd)
    age_from = format((((rrf.age_from_minutes/ 60)/ 24)/ 31.0),"#######.##;L")
   ELSEIF (rrf.age_from_units_cd=weeks_cd)
    age_from = format((((rrf.age_from_minutes/ 60)/ 24)/ 7.0),"#######.##;L")
   ELSEIF (rrf.age_from_units_cd=years_cd)
    age_from = format((((rrf.age_from_minutes/ 60)/ 24)/ 365.0),"#######.##;L")
   ELSEIF (rrf.age_from_units_cd=seconds_cd)
    age_from = format((rrf.age_from_minutes * 60.0),"#######.##;L")
   ENDIF
   IF (rrf.age_to_units_cd=days_cd)
    age_to = format(((rrf.age_to_minutes/ 60)/ 24.0),"#######.##;L")
   ELSEIF (rrf.age_to_units_cd=hours_cd)
    age_to = format((rrf.age_to_minutes/ 60.0),"#######.##;L")
   ELSEIF (rrf.age_to_units_cd=minutes_cd)
    age_to = format(rrf.age_to_minutes,"#######.##;L")
   ELSEIF (rrf.age_to_units_cd=months_cd)
    age_to = format((((rrf.age_to_minutes/ 60)/ 24)/ 31.0),"#######.##;L")
   ELSEIF (rrf.age_to_units_cd=weeks_cd)
    age_to = format((((rrf.age_to_minutes/ 60)/ 24)/ 7.0),"#######.##;L")
   ELSEIF (rrf.age_to_units_cd=years_cd)
    age_to = format((((rrf.age_to_minutes/ 60)/ 24)/ 365.0),"#######.##;L")
   ELSEIF (rrf.age_to_units_cd=seconds_cd)
    age_from = format((rrf.age_to_minutes * 60.0),"#######.##;L")
   ENDIF
   IF (rrf.age_from_units_cd=months_cd
    AND ((((rrf.age_from_minutes/ 60)/ 24)/ 31.0) != floor((((rrf.age_from_minutes/ 60)/ 24)/ 31.0)))
   )
    col 0, "**"
   ELSEIF (rrf.age_to_units_cd=months_cd
    AND ((((rrf.age_to_minutes/ 60)/ 24)/ 31.0) != floor((((rrf.age_to_minutes/ 60)/ 24)/ 31.0))))
    col 0, "**"
   ENDIF
   col 4, age_from, col 16,
   age_from_units_disp, col 33, age_to,
   col 45, age_to_units_disp, col 60,
   date_updated, row + 1
  FOOT REPORT
   row + 2, col 0, "###### END OF REPORT ######"
  WITH nullreport
 ;end select
END GO

CREATE PROGRAM ccl_rpt_compile_mode:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE compile_mode = vc
 SELECT INTO  $OUTDEV
  nvp.parent_entity_name, nvp.parent_entity_id, nvp.pvc_name,
  nvp.updt_dt_tm"@SHORTDATETIME", nvp.active_ind, nvp.pvc_value
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="DISCERN_APPS_COMPILEVERSION3"
  HEAD REPORT
   row 1, col 5, "COMPILEVERSION 3 mode status: "
   IF (substring(1,1,nvp.pvc_value)="1")
    compile_mode = "ENABLED"
   ELSE
    compile_mode = "DISABLED"
   ENDIF
   col + 5, compile_mode, row 1,
   col 93, "Date:", today = format(cnvtdatetime(sysdate),"@SHORTDATETIME"),
   row 1, col 105, today,
   row + 2
  HEAD nvp.pvc_name
   col 5, "Preference Name:", col 40,
   "Value:", col 55, "Last updated:",
   row + 1
  DETAIL
   pvc_value1 = substring(1,10,nvp.pvc_value), col 5, nvp.pvc_name,
   col 40, pvc_value1, col 55,
   nvp.updt_dt_tm, row + 2, col 5,
   "*** Applies to applications DiscernDev.exe, DiscernVisualDeveloper.exe and VisualExplorer.exe ***"
  WITH noheading, format = variable, nullreport
 ;end select
END GO

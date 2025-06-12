CREATE PROGRAM ct_get_default_exec_mode
 PROMPT
  "ExecMode Value" = 0
  WITH execmodevalue
 EXECUTE ccl_prompt_api_dataset "autoset", "advapi"
 DECLARE definevaluesforexecmode(dummy) = null WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE execmodewherestring = vc WITH protect, noconstant("")
 DECLARE last_mod = c3 WITH public, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH public, noconstant(fillstring(30," "))
 SUBROUTINE updatequeryforevaluationby(dummy)
   IF (( $EXECMODEVALUE=1))
    SET execmodewherestring = "c.cdf_meaning in ('PATIENTINQ', 'PRESCREEN', 'PRESCREENT')"
   ELSEIF (( $EXECMODEVALUE=2))
    SET execmodewherestring = "c.cdf_meaning in ('PATIENTINQ', 'PRESCREENT')"
   ENDIF
 END ;Subroutine
 CALL updatequeryforevaluationby(null)
 SELECT
  c.display, c.cdf_meaning
  FROM code_value c
  WHERE c.code_set=4520006
   AND c.active_ind=1
   AND parser(execmodewherestring)
  ORDER BY c.display
  HEAD REPORT
   stat = makedataset(3), stat = writerecord(0), stat = adddefaultkey(trim(c.display))
  DETAIL
   cnt += 1
   IF (cnt > 1)
    stat = writerecord(0)
   ENDIF
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, reporthelp
 ;end select
 SET last_mod = "000"
 SET mod_date = "Nov 30, 2017"
END GO

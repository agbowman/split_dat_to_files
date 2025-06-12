CREATE PROGRAM bhs_sys_remove_prsnl_prefs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel last Name:" = "",
  "Select Personnel:" = 0,
  "Select application:" = 0
  WITH outdev, name, prsnl,
  preftype
 CALL echo("DO")
 CALL echo( $PRSNL)
 CALL echo( $PREFTYPE)
 SELECT INTO "NL:"
  *
  FROM application_ini ai
  WHERE (ai.person_id= $PRSNL)
   AND ai.application_number IN ( $PREFTYPE)
  WITH nocounter, format, separator = " ",
   check
 ;end select
 IF (curqual > 0)
  DELETE  FROM application_ini ai
   WHERE (ai.person_id= $PRSNL)
    AND ai.person_id > 0
    AND ai.application_number IN ( $PREFTYPE)
    AND ai.application_number > 0
   WITH nocounter
  ;end delete
  SELECT INTO "NL:"
   FROM application_ini ai
   PLAN (ai
    WHERE (ai.person_id= $PRSNL)
     AND ai.person_id > 0
     AND ai.application_number IN ( $PREFTYPE)
     AND ai.application_number > 0)
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   COMMIT
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Rows have been successfully deleted", msg2 = "", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/12}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Rows failed to update", msg2 = "Please try again or manually delete on the back end",
     col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/12}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Script error", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_script
END GO

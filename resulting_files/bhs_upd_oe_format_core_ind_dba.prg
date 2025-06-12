CREATE PROGRAM bhs_upd_oe_format_core_ind:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Report or Update:" = "",
  "oe_format_id (0 for all): " = ""
  WITH outdev, reporttype, oeformatid
 SET modifyacttype = uar_get_code_by("MEANING",6003,"MODIFY")
 SET orderacttype = uar_get_code_by("MEANING",6003,"ORDER")
 SET type = cnvtupper( $REPORTTYPE)
 IF (isnumeric( $OEFORMATID))
  SET formatids = cnvtreal(value( $OEFORMATID))
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "There was an error with the entered oe_format_id", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 1, row + 1, "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ENDIF
 IF (type="UPDATE")
  CALL echo("Update")
  IF (formatids > 0)
   UPDATE  FROM oe_format_fields ofi
    SET ofi.core_ind = 1, ofi.updt_id = 99999999, ofi.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE ofi.oe_format_id=formatids
     AND ofi.action_type_cd IN (modifyacttype, orderacttype)
     AND ofi.core_ind != 1
   ;end update
   IF (curqual > 0)
    COMMIT
    SELECT INTO  $OUTDEV
     FROM dummyt
     HEAD REPORT
      msg1 = "Rows have been updated", col 0, "{PS/792 0 translate 90 rotate/}",
      y_pos = 1, row + 1, "{F/1}{CPI/9}",
      CALL print(calcpos(36,(y_pos+ 0))), msg1
     WITH dio = 08, mine, time = 5
    ;end select
    GO TO exit_program
   ELSE
    SELECT INTO  $OUTDEV
     FROM dummyt
     HEAD REPORT
      msg1 = "No rows found needing update", col 0, "{PS/792 0 translate 90 rotate/}",
      y_pos = 1, row + 1, "{F/1}{CPI/9}",
      CALL print(calcpos(36,(y_pos+ 0))), msg1
     WITH dio = 08, mine, time = 5
    ;end select
    GO TO exit_program
   ENDIF
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "You must enter an oe_format_id > 0 for an update", col 0,
     "{PS/792 0 translate 90 rotate/}",
     y_pos = 1, row + 1, "{F/1}{CPI/9}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_program
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   ofi.label_text, ofi.oe_format_id, ofi.core_ind,
   upd_dt_tm = format(ofi.updt_dt_tm,"MM/DD/YY HH:MM:SS;;d")
   FROM oe_format_fields ofi
   WHERE ((ofi.oe_format_id=formatids) OR (formatids=0
    AND ofi.oe_format_id > 0))
    AND ofi.action_type_cd IN (modifyacttype, orderacttype)
    AND ofi.core_ind != 1
   WITH nocounter, format
  ;end select
  IF (curqual=0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "No rows found", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 1, row + 1, "{F/1}{CPI/9}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
  GO TO exit_program
 ENDIF
#exit_program
END GO

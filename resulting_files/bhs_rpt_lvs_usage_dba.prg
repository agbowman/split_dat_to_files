CREATE PROGRAM bhs_rpt_lvs_usage:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "" = "no mail"
  WITH outdev, beg_dt, end_dt,
  email
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(3,0)))), public
 SET operations = 0
 SET send_mail =  $EMAIL
 IF (validate(request->batch_selection))
  IF (weekday(curdate)=0)
   SET rel_day = - (1)
  ELSEIF (weekday(curdate)=1)
   SET rel_day = - (2)
  ELSEIF (weekday(curdate)=2)
   SET rel_day = - (3)
  ELSEIF (weekday(curdate)=3)
   SET rel_day = - (4)
  ELSEIF (weekday(curdate)=4)
   SET rel_day = - (5)
  ELSEIF (weekday(curdate)=5)
   SET rel_day = - (6)
  ELSEIF (weekday(curdate)=6)
   SET rel_day = - (7)
  ENDIF
  SET start_event_date = datetimeadd(cnvtdatetime(value(curdate),0),(rel_day - 6))
  SET end_event_date = datetimeadd(cnvtdatetime(value(curdate),235959),rel_day)
  SET operations = 1
 ELSE
  SET start_event_date = cnvtdatetime( $BEG_DT)
  SET end_event_date = cnvtdatetime( $END_DT)
  CALL echo(build("Start Date:", $BEG_DT))
  CALL echo(build("Start Date:", $END_DT))
  IF (datetimediff(cnvtdatetime(cnvtdate( $END_DT),0),cnvtdatetime(cnvtdate( $BEG_DT),0)) > 7)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is larger than 7 days.", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_prg
  ELSEIF (datetimediff(cnvtdatetime(cnvtdate( $END_DT),0),cnvtdatetime(cnvtdate( $BEG_DT),0)) < 0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08
   ;end select
   GO TO exit_prg
  ENDIF
 ENDIF
 IF (((findstring("@",send_mail) > 0) OR (operations=1)) )
  SET email_ind = 1
  SET var_output = "bhs_lvs_usage"
  CALL echo(operations)
 ELSE
  CALL echo(operations)
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 SELECT INTO value(var_output)
  personel = substring(1,50,pr.name_full_formatted), procedure = uar_get_code_display(ce.event_cd),
  count = count(ce.event_id)
  FROM clinical_event ce,
   prsnl pr
  PLAN (ce
   WHERE ce.updt_dt_tm BETWEEN cnvtdatetime(start_event_date) AND cnvtdatetime(end_event_date)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND  EXISTS (
   (SELECT
    cb1.event_id
    FROM ce_blob_result cb1
    WHERE cb1.event_id=ce.event_id
     AND cb1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND cb1.storage_cd=value(uar_get_code_by("MEANING",25,"OTG")))))
   JOIN (pr
   WHERE ce.performed_prsnl_id=pr.person_id)
  GROUP BY pr.name_full_formatted, ce.event_cd
  WITH nocounter, format, pcformat('"',",")
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  IF (operations=1)
   SET email_address = trim( $OUTDEV)
  ELSE
   SET email_address = trim(send_mail)
  ENDIF
  SET filename_out = "bhs_lvs_usage.csv"
  SET subject = concat("Low Volume Scanning usage report"," from...",format(cnvtdate(start_event_date
     ),"mm/dd/yy;;d")," To...",format(cnvtdate(end_event_date),"mm/dd/yy;;d"))
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,subject,1)
 ENDIF
#exit_prg
END GO

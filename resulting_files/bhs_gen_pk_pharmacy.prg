CREATE PROGRAM bhs_gen_pk_pharmacy
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr_id" = 58651645
  WITH outdev, encntr_id
 SET beg_rtf = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}} \f0\fs20 "
 SET end_rtf = "} "
 SET beg_bold = "\b "
 SET end_bold = "\b0 "
 SET beg_uline = "\ul "
 SET end_uline = "\ulnone "
 SET beg_ital = "\i "
 SET end_ital = "\i0 "
 SET new_line = concat(char(10),char(13))
 SET end_line = " \par "
 FREE RECORD work
 RECORD work(
   1 person_id = f8
   1 encntr_id = f8
   1 serum_cr = vc
   1 wbc = vc
   1 oxy = vc
   1 temp = vc
   1 pulse = vc
   1 sbp = vc
   1 dbp = vc
   1 map = vc
 )
 IF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->encntr_id = request->visit[1].encntr_id
  SET output = "nl:"
 ELSEIF (( $ENCNTR_ID > 0.00))
  SET work->encntr_id =  $ENCNTR_ID
  SET ouput =  $OUTDEV
  RECORD reply(
    1 text = vc
  )
 ELSE
  CALL echo("No valid encntr_id given. Exiting Script")
  GO TO exit_script
 ENDIF
 CALL echo(build2(work->encntr_id))
 CALL echo("Select a clinical event to get results")
 SELECT INTO output
  ce.*
  FROM clinical_event ce
  WHERE (ce.encntr_id=work->encntr_id)
   AND ce.event_cd IN (709532, 710413, 680236, 736102, 680298,
  723256, 723266, 723253)
   AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=709532)
    work->serum_cr = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=710413)
    work->wbc = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=680236)
    work->oxy = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=736102)
    work->temp = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=680298)
    work->pulse = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=723256)
    work->sbp = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=723266)
    work->dbp = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=723253)
    work->map = trim(ce.event_tag,3)
   ENDIF
  WITH nocounter, format, separator = " "
 ;end select
 IF ((work->serum_cr=""))
  SET work->serum_cr = "NA"
 ENDIF
 IF ((work->wbc=""))
  SET work->wbc = "NA"
 ENDIF
 IF ((work->oxy=""))
  SET work->oxy = "NA"
 ENDIF
 IF ((work->temp=""))
  SET work->temp = "NA"
 ENDIF
 IF ((work->pulse=""))
  SET work->pulse = "NA"
 ENDIF
 IF ((work->sbp=""))
  SET work->sbp = "NA"
 ENDIF
 IF ((work->dbp=""))
  SET work->dbp = "NA"
 ENDIF
 IF ((work->map=""))
  SET work->map = "NA"
 ENDIF
 SET reply->text = build2(beg_rtf,new_line,beg_bold,beg_uline,"Patient Lab Values",
  end_bold,end_uline,end_line,new_line," Serum Creatinine: ",
  work->serum_cr,end_line,new_line," WBC: ",work->wbc,
  end_line,new_line," Oxygen Saturation: ",work->oxy,end_line,
  new_line,end_line,new_line,beg_bold,beg_uline,
  " Patient Vital Signs",end_bold,end_uline,end_line,new_line,
  " Temperature: ",work->temp,end_line,new_line," Pulse: ",
  work->pulse,end_line,new_line," Systolic Blood Pressure: ",work->sbp,
  end_line,new_line," Diastolic Blood Pressure: ",work->dbp,end_line,
  new_line," Mean Arterial Pressure: ",work->map,end_line)
 CALL echorecord(work)
 CALL echorecord(reply)
#exit_script
END GO

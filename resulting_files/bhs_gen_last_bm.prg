CREATE PROGRAM bhs_gen_last_bm
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr_id" = 0
  WITH outdev, encntr_id
 RECORD drec(
   1 encntr_id = f8
   1 last_bm = vc
 )
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
 DECLARE mf_lastbowelmovement_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LASTBOWELMOVEMENT"))
 IF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET drec->encntr_id = request->visit[1].encntr_id
  SET output = "nl:"
 ELSEIF (( $ENCNTR_ID > 0.00))
  SET drec->encntr_id =  $ENCNTR_ID
  SET ouput =  $OUTDEV
  RECORD reply(
    1 text = vc
  )
 ELSE
  CALL echo("No valid encntr_id given. Exiting Script")
  GO TO exit_script
 ENDIF
 CALL echo(build2(drec->encntr_id))
 DECLARE last_bm = vc
 SET last_bm = ""
 DECLARE cnt = i2
 SELECT INTO output
  FROM clinical_event ce,
   ce_date_result cdr
  PLAN (ce
   WHERE (ce.encntr_id=drec->encntr_id)
    AND ce.event_cd=mf_lastbowelmovement_cd
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (cdr
   WHERE cdr.event_id=ce.event_id
    AND cdr.valid_until_dt_tm > sysdate)
  ORDER BY ce.encntr_id, ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD ce.event_cd
   last_bm = format(cdr.result_dt_tm,"mm/dd/yyyy;;q"), cnt = 1,
   CALL echo(build("last_bm = ",last_bm))
  WITH nocounter
 ;end select
 SET drec->last_bm = last_bm
 IF (cnt=0)
  SET reply->text = build2(beg_rtf,new_line,"NO last BM information",end_line)
 ELSE
  SET reply->text = build2(beg_rtf,new_line,drec->last_bm,end_line)
 ENDIF
 CALL echorecord(drec)
 CALL echorecord(reply)
#exit_script
END GO

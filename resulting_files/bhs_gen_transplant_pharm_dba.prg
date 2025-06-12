CREATE PROGRAM bhs_gen_transplant_pharm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr_id" = 58915577
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
   1 urine_op = f8
   1 tacro_level = vc
   1 siro_level = vc
   1 cyclo_level = vc
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
   AND ce.event_cd IN (709532, 798356, 709537, 62374747, 709539)
   AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=709532)
    work->serum_cr = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=709537)
    work->tacro_level = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=62374747)
    work->siro_level = trim(ce.event_tag,3)
   ELSEIF (ce.event_cd=709539)
    work->cyclo_level = trim(ce.event_tag,3)
   ENDIF
  DETAIL
   IF (ce.event_cd=798356
    AND ce.event_start_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
    work->urine_op = (work->urine_op+ cnvtreal(ce.event_tag))
   ENDIF
  WITH nocounter, format, separator = " "
 ;end select
 IF ((work->serum_cr=""))
  SET work->serum_cr = "NA"
 ENDIF
 IF ((work->urine_op=0.00))
  SET work->urine_op = 0.00
 ENDIF
 IF ((work->tacro_level=""))
  SET work->tacro_level = "NA"
 ENDIF
 IF ((work->siro_level=""))
  SET work->siro_level = "NA"
 ENDIF
 IF ((work->cyclo_level=""))
  SET work->cyclo_level = "NA"
 ENDIF
 SET reply->text = build2(beg_rtf,new_line,beg_bold,beg_uline,"Patient Lab Values",
  end_bold,end_uline,end_line,new_line,new_line,
  " Serum Creatinine: ",work->serum_cr,end_line,new_line,new_line,
  " 24 Hour Urine Output:",work->urine_op,end_line,new_line,new_line,
  " Tacrolimus Level: ",work->tacro_level,end_line,new_line,new_line,
  " Sirolimus Level: ",work->siro_level,end_line,new_line,new_line,
  " Cyclosporine-A Level: ",work->cyclo_level,end_line)
 CALL echorecord(work)
 CALL echorecord(reply)
#exit_script
END GO

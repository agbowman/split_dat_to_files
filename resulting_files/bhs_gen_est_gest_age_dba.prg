CREATE PROGRAM bhs_gen_est_gest_age:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr_id" = 0
  WITH outdev, encntr_id
 DECLARE gest_age_days = i2 WITH protect, noconstant(0)
 DECLARE different_ega_days = i4 WITH protect, noconstant(0)
 DECLARE current_gest_age = i2 WITH protect, noconstant(0)
 SET gest_age_days = 0
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
   1 encntr_id = f8
   1 ega_weeks = i2
   1 ega_frac_days = i2
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
  p.name_full_formatted, e.encntr_id, pe.est_gest_age_days,
  pe.est_delivery_dt_tm
  FROM encounter e,
   person p,
   pregnancy_instance pi,
   pregnancy_estimate pe
  PLAN (e
   WHERE (e.encntr_id=work->encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pi
   WHERE p.person_id=pi.person_id
    AND pi.active_ind=1
    AND pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pe
   WHERE pi.pregnancy_id=pe.pregnancy_id
    AND pe.est_gest_age_days >= 0
    AND pe.active_ind=1)
  ORDER BY p.name_full_formatted, pe.status_flag DESC
  HEAD pe.pregnancy_id
   ms_today = trim(format(sysdate,"dd-mmm-yyyy;;d")), ms_entered = trim(format(pe.entered_dt_tm,
     "dd-mmm-yyyy;;d")), different_ega_days = datetimediff(cnvtdatetime(ms_today),cnvtdatetime(
     ms_entered),1),
   current_gest_age = (pe.est_gest_age_days+ different_ega_days)
  WITH nocounter
 ;end select
 IF (current_gest_age < 7)
  SET work->ega_weeks = 0
  SET work->ega_frac_days = current_gest_age
 ENDIF
 IF (current_gest_age >= 7)
  SET work->ega_weeks = (current_gest_age/ 7)
  SET work->ega_frac_days = (current_gest_age - (work->ega_weeks * 7))
 ENDIF
 SET reply->text = build2(beg_rtf,new_line,trim(cnvtstring(work->ega_weeks,3))," Weeks ",trim(
   cnvtstring(work->ega_frac_days,3)),
  " Days",end_line)
 CALL echorecord(work)
 CALL echorecord(reply)
#exit_script
END GO

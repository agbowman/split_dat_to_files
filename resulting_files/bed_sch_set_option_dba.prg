CREATE PROGRAM bed_sch_set_option:dba
 PROMPT
  "Enter the Option CDF Meaning from code set 16127:  " = "",
  "Enter Part of the Appt Mnemonic or ALL for all appt. types.:  " = "",
  "Enter Action Option On/Off (1=On,0=Off): " = - (1)
 SET call_echo_ind = 0
 DECLARE smnemonicparam = vc
 IF (cnvtupper(trim( $2))="ALL")
  SET smnemonicparam = "*"
 ELSE
  SET smnemonicparam = concat("*",trim( $2),"*")
 ENDIF
 FREE SET t_record
 RECORD t_record(
   1 active_status_cd = f8
   1 active_status_meaning = vc
   1 option_meaning = vc
   1 sch_option_cd = f8
   1 qual_cnt = i4
   1 qual[*]
     2 appt_type_cd = f8
     2 action = i2
     2 status = i2
 )
 SET t_record->qual_cnt = 0
 SET t_record->sch_option_cd = 0
 SET t_record->option_meaning = trim(cnvtupper( $1))
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=16127
   AND (a.cdf_meaning=t_record->option_meaning)
   AND a.active_ind=1
   AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   t_record->sch_option_cd = a.code_value
  WITH nocounter
 ;end select
 IF ((t_record->sch_option_cd=0))
  CALL echo(build("(",t_record->option_meaning,") is not a valid processing option..."))
  GO TO exit_script
 ENDIF
 SET t_record->active_status_cd = 0.0
 SET t_record->active_status_meaning = "ACTIVE"
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=48
   AND (a.cdf_meaning=t_record->active_status_meaning)
   AND a.active_ind=1
   AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   t_record->active_status_cd = a.code_value
  WITH nocounter
 ;end select
 IF ((t_record->sch_option_cd=0))
  CALL echo(build("Could not find CODE_VALUE in codeset(48), CDF_MEANING (",t_record->
    active_status_meaning,")"))
  GO TO exit_script
 ENDIF
#select_appt_type_cd
 SELECT INTO "nl:"
  a.appt_type_cd
  FROM sch_appt_type a
  PLAN (a
   WHERE a.description=patstring(smnemonicparam)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  HEAD REPORT
   t_record->qual_cnt = 0
  DETAIL
   t_record->qual_cnt = (t_record->qual_cnt+ 1)
   IF (mod(t_record->qual_cnt,10)=1)
    stat = alterlist(t_record->qual,(t_record->qual_cnt+ 9))
   ENDIF
   t_record->qual[t_record->qual_cnt].appt_type_cd = a.appt_type_cd, t_record->qual[t_record->
   qual_cnt].action = 1
  FOOT REPORT
   IF (mod(t_record->qual_cnt,10) != 0)
    stat = alterlist(t_record->qual,t_record->qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
#search_for_existing
 SELECT INTO "nl:"
  a.appt_type_cd
  FROM sch_appt_option a,
   (dummyt d  WITH seq = value(t_record->qual_cnt))
  PLAN (d)
   JOIN (a
   WHERE (a.appt_type_cd=t_record->qual[d.seq].appt_type_cd)
    AND (a.sch_option_cd=t_record->sch_option_cd)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   t_record->qual[d.seq].action = 0
  WITH nocounter
 ;end select
 IF (value( $3)=1)
  CALL echo("TURNING ON SETTINGS...")
  INSERT  FROM sch_appt_option a,
    (dummyt d  WITH seq = value(t_record->qual_cnt))
   SET a.appt_type_cd = t_record->qual[d.seq].appt_type_cd, a.sch_option_cd = t_record->sch_option_cd,
    a.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    a.option_meaning = trim(t_record->option_meaning), a.null_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), a.candidate_id = seq(sch_candidate_seq,nextval),
    a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), a.active_ind = 1,
    a.active_status_cd = t_record->active_status_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), a.active_status_prsnl_id = 0,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_applctx = 0, a.updt_id = 0,
    a.updt_cnt = 0, a.updt_task = 0
   PLAN (d
    WHERE (t_record->qual[d.seq].action=1))
    JOIN (a)
   WITH nocounter, status(t_record->qual[d.seq].status)
  ;end insert
  COMMIT
 ELSEIF (value( $3)=0)
  CALL echo("TURNING OFF SETTINGS...")
  DELETE  FROM sch_appt_option a,
    (dummyt d  WITH seq = value(t_record->qual_cnt))
   SET a.seq = 1
   PLAN (d
    WHERE (t_record->qual[d.seq].action=0))
    JOIN (a
    WHERE (a.appt_type_cd=t_record->qual[d.seq].appt_type_cd)
     AND (a.sch_option_cd=t_record->sch_option_cd)
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   WITH nocounter, status(t_record->qual[d.seq].status)
  ;end delete
  COMMIT
 ELSE
  CALL echo(build("Invalid Action Option...no action taken..."))
 ENDIF
#exit_script
 ROLLBACK
END GO

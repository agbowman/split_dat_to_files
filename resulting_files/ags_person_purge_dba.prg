CREATE PROGRAM ags_person_purge:dba
 PROMPT
  "Backout Type (J, I, P) = " = "J",
  "AGS_JOB_ID (0.0) = " = 0.0,
  "Purge Extended Data (Y / N) = " = "N"
  WITH cbackout_type, djob_id, cpurge_extended
 CALL echo("***")
 CALL echo("***   BEG :: AGS_PERSON_PURGE")
 CALL echo("***")
 IF ((validate(failed,- (1))=- (1)))
  CALL echo("***")
  CALL echo("***   Declare Common Variables")
  CALL echo("***")
  IF ((validate(false,- (1))=- (1)))
   DECLARE false = i2 WITH public, noconstant(0)
  ENDIF
  IF ((validate(true,- (1))=- (1)))
   DECLARE true = i2 WITH public, noconstant(1)
  ENDIF
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  DECLARE s_log_name = vc WITH public, noconstant("")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE define_logging_sub = i2 WITH private, noconstant(false)
 IF ( NOT (validate(log,0)))
  CALL echo("***")
  CALL echo("***   BEG LOGGING")
  CALL echo("***")
  SET define_logging_sub = true
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  DECLARE handle_logging(slog_file=vc,semail=vc,istatus_flag=i4) = null WITH protect
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_person_purge_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PERSON_PURGE"
 DECLARE the_type = c1 WITH protect, noconstant(" ")
 SET the_type =  $CBACKOUT_TYPE
 DECLARE the_job_id = f8 WITH protect, noconstant(0.0)
 SET the_job_id =  $DJOB_ID
 DECLARE testing_domain = i2 WITH public, noconstant(false)
 DECLARE purge_extended_data = c1 WITH protect, noconstant("N")
 SET purge_extended_data =  $CPURGE_EXTENDED
 IF (purge_extended_data="Y")
  SELECT INTO "nl:"
   FROM dm_info d
   PLAN (d
    WHERE d.info_domain="AGS"
     AND d.info_name="TEST_DOMAIN")
   DETAIL
    testing_domain = true
   WITH nocounter
  ;end select
  IF (testing_domain=false)
   SET purge_extended_data = "N"
   CALL echo("*** Not a Test Domain: Extended Data will be BACKOUT!")
  ENDIF
 ENDIF
 FREE RECORD purge_rec
 RECORD purge_rec(
   1 qual_knt = i4
   1 qual[*]
     2 delete_item_id = f8
     2 delete_person_id = f8
     2 is_a_prsnl = i2
     2 delete_run_nbr = i4
     2 bo_item_id = f8
     2 mil_item_id = f8
 )
 FREE RECORD sub_item_rec
 RECORD sub_item_rec(
   1 qual_knt = i4
   1 qual[*]
     2 data_id = f8
 )
 DECLARE bldap = i2 WITH protect, noconstant(false)
 DECLARE borg = i2 WITH protect, noconstant(false)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE prsnl_name_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE ssn_alias_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("PARAMETER >> BACKOUT_TYPE : ",trim(the_type))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("PARAMETER >> AGS_JOB_ID : ",trim(cnvtstring(the_job_id))
  )
 IF (prsnl_name_type_cd < 1)
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "INVALID PRSNL_NAME_TYPE_CD Value for CDF_MEANING PRSNL from Code Set 213"
  GO TO exit_script
 ENDIF
 IF (ssn_alias_type_cd < 1)
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "INVALID PRSNL_NAME_TYPE_CD Value for CDF_MEANING SSN from Code Set 4"
  GO TO exit_script
 ENDIF
 IF (the_type="P"
  AND the_job_id < 1)
  CALL echo("***")
  CALL echo("***   PERSON Type Run")
  CALL echo("***")
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "INVALID BACKOUT >> PERSON by Person File Not Allowed"
  GO TO exit_script
 ELSEIF (the_type="J"
  AND the_job_id > 0.0)
  CALL echo("***")
  CALL echo("***   JOB Type Run")
  CALL echo("***")
  SET stat = initrec(purge_rec)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_person_data a
   PLAN (a
    WHERE a.ags_job_id=the_job_id
     AND a.person_id > 0)
   HEAD REPORT
    sknt = 0, stat = alterlist(purge_rec->qual,10)
   DETAIL
    sknt = (sknt+ 1)
    IF (mod(sknt,10)=1
     AND sknt != 1)
     stat = alterlist(purge_rec->qual,(sknt+ 9))
    ENDIF
    purge_rec->qual[sknt].mil_item_id = a.person_id, purge_rec->qual[sknt].delete_item_id = a
    .ags_person_data_id, purge_rec->qual[sknt].delete_person_id = a.person_id,
    purge_rec->qual[sknt].delete_run_nbr = a.run_nbr
   FOOT REPORT
    purge_rec->qual_knt = sknt, stat = alterlist(purge_rec->qual,sknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = select_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PRSNL_DATA >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (the_type="I")
  CALL echo("***")
  CALL echo("***   ITEM Type Run")
  CALL echo("***")
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "INVALID PURGE >> PERSON by Item Not Allowed"
  GO TO exit_script
 ELSE
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "PARAMETER ERROR >> Invalid Parameter"
  GO TO exit_script
 ENDIF
 IF ((purge_rec->qual_knt < 1))
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No items found to purge"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_prsnl_data a
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].delete_person_id))
  ORDER BY d.seq
  HEAD d.seq
   purge_rec->qual[d.seq].is_a_prsnl = true
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PRSNL_DATA (PRSNL Check)>> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_person_data a
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].delete_person_id)
    AND (a.run_nbr < purge_rec->qual[d.seq].delete_run_nbr))
  ORDER BY d.seq, a.run_nbr DESC
  HEAD d.seq
   purge_rec->qual[d.seq].bo_item_id = a.ags_person_data_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PERSON_DATA (backout items)>> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_meds_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a2
   WHERE (a2.person_id=purge_rec->qual[d.seq].mil_item_id))
  ORDER BY a2.ags_meds_data_id
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10)
  HEAD a2.ags_meds_data_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(sub_item_rec->qual,(sknt+ 9))
   ENDIF
   sub_item_rec->qual[sknt].data_id = a2.ags_meds_data_id
  FOOT REPORT
   sub_item_rec->qual_knt = sknt, stat = alterlist(sub_item_rec->qual,sknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_MEDS_DATA >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  IF (purge_extended_data="Y")
   EXECUTE ags_meds_purge value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ELSE
   EXECUTE ags_meds_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ENDIF
  IF (failed != false)
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION ERROR>> AGS_MEDS_BACKOUT"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION SUCCESS>> AGS_MEDS_BACKOUT"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "NO ITEMS FOUND FOR AGS_MEDS_BACKOUT"
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET sub_item_rec->qual_knt = 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_result_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a2
   WHERE (a2.person_id=purge_rec->qual[d.seq].mil_item_id))
  ORDER BY a2.event_id
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10)
  HEAD a2.event_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(sub_item_rec->qual,(sknt+ 9))
   ENDIF
   sub_item_rec->qual[sknt].data_id = a2.event_id
  FOOT REPORT
   sub_item_rec->qual_knt = sknt, stat = alterlist(sub_item_rec->qual,sknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_RESULT_DATA >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  IF (purge_extended_data="Y")
   EXECUTE ags_result_purge value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ELSE
   EXECUTE ags_result_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ENDIF
  IF (failed != false)
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION ERROR>> AGS_RESULT_BACKOUT"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION SUCCESS>> AGS_RESULT_BACKOUT"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "NO ITEMS FOUND FOR AGS_RESULT_BACKOUT"
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET sub_item_rec->qual_knt = 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_claim_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a2
   WHERE (a2.person_id=purge_rec->qual[d.seq].mil_item_id))
  ORDER BY a2.ags_claim_data_id
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10)
  HEAD a2.ags_claim_data_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(sub_item_rec->qual,(sknt+ 9))
   ENDIF
   sub_item_rec->qual[sknt].data_id = a2.ags_claim_data_id
  FOOT REPORT
   sub_item_rec->qual_knt = sknt, stat = alterlist(sub_item_rec->qual,sknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_CLAIM_DATA By Billing >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  IF (purge_extended_data="Y")
   EXECUTE ags_claim_purge value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ELSE
   EXECUTE ags_claim_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ENDIF
  IF (failed != false)
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION ERROR>> AGS_CLAIM_BACKOUT"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION SUCCESS>> AGS_CLAIM_BACKOUT"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "NO ITEMS FOUND FOR AGS_CLAIM_BACKOUT"
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET sub_item_rec->qual_knt = 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_immun_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a2
   WHERE (a2.person_id=purge_rec->qual[d.seq].mil_item_id))
  ORDER BY a2.ags_immun_data_id
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10)
  HEAD a2.ags_immun_data_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(sub_item_rec->qual,(sknt+ 9))
   ENDIF
   sub_item_rec->qual[sknt].data_id = a2.ags_immun_data_id
  FOOT REPORT
   sub_item_rec->qual_knt = sknt, stat = alterlist(sub_item_rec->qual,sknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_IMMUN_DATA By Billing >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  IF (purge_extended_data="Y")
   EXECUTE ags_immun_purge value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ELSE
   EXECUTE ags_immun_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ENDIF
  IF (failed != false)
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION ERROR>> AGS_IMMUN_BACKOUT"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION SUCCESS>> AGS_IMMUN_BACKOUT"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "NO ITEMS FOUND FOR AGS_IMMUN_BACKOUT"
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET sub_item_rec->qual_knt = 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_benefit_level_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a2
   WHERE (a2.person_id=purge_rec->qual[d.seq].mil_item_id))
  ORDER BY a2.ags_benefit_level_data_id
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10)
  HEAD a2.ags_benefit_level_data_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(sub_item_rec->qual,(sknt+ 9))
   ENDIF
   sub_item_rec->qual[sknt].data_id = a2.ags_benefit_level_data_id
  FOOT REPORT
   sub_item_rec->qual_knt = sknt, stat = alterlist(sub_item_rec->qual,sknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_BENEFIT_LEVEL_DATA By Billing >> ",
   trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  IF (purge_extended_data="Y")
   EXECUTE ags_benefit_level_purge value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ELSE
   EXECUTE ags_benefit_level_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ENDIF
  IF (failed != false)
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION ERROR>> AGS_BENEFIT_LEVEL_BACKOUT"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION SUCCESS>> AGS_BENEFIT_LEVEL_BACKOUT"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "NO ITEMS FOUND FOR AGS_BENEFIT_LEVEL_BACKOUT"
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET sub_item_rec->qual_knt = 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_plan_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a2
   WHERE (a2.person_id=purge_rec->qual[d.seq].mil_item_id))
  ORDER BY a2.ags_plan_data_id
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10)
  HEAD a2.ags_plan_data_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(sub_item_rec->qual,(sknt+ 9))
   ENDIF
   sub_item_rec->qual[sknt].data_id = a2.ags_plan_data_id
  FOOT REPORT
   sub_item_rec->qual_knt = sknt, stat = alterlist(sub_item_rec->qual,sknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = select_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PLAN_DATA By Billing >> ",trim(serrmsg
    ))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  IF (purge_extended_data="Y")
   EXECUTE ags_plan_purge value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ELSE
   EXECUTE ags_plan_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
  ENDIF
  IF (failed != false)
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION ERROR>> AGS_PLAN_BACKOUT"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "EXECUTION SUCCESS>> AGS_PLAN_BACKOUT"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "NO ITEMS FOUND FOR AGS_PLAN_BACKOUT"
 ENDIF
 IF (purge_extended_data="Y")
  DELETE  FROM encounter e,
    (dummyt d  WITH seq = value(purge_rec->qual_knt))
   SET e.seq = 1
   PLAN (d
    WHERE d.seq > 0
     AND (purge_rec->qual[d.seq].mil_item_id > 0)
     AND (purge_rec->qual[d.seq].is_a_prsnl=false))
    JOIN (e
    WHERE (e.person_id=purge_rec->qual[d.seq].mil_item_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
  DELETE  FROM ppr_consent_status p,
    (dummyt d  WITH seq = value(purge_rec->qual_knt))
   SET p.seq = 1
   PLAN (d
    WHERE d.seq > 0
     AND (purge_rec->qual[d.seq].mil_item_id > 0)
     AND (purge_rec->qual[d.seq].is_a_prsnl=false))
    JOIN (p
    WHERE (p.person_id=purge_rec->qual[d.seq].mil_item_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
  DELETE  FROM allergy a,
    (dummyt d  WITH seq = value(purge_rec->qual_knt))
   SET a.seq = 1
   PLAN (d
    WHERE d.seq > 0
     AND (purge_rec->qual[d.seq].mil_item_id > 0)
     AND (purge_rec->qual[d.seq].is_a_prsnl=false))
    JOIN (a
    WHERE (a.person_id=purge_rec->qual[d.seq].mil_item_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
  DELETE  FROM long_blob l
   SET l.seq = 1
   WHERE l.long_blob_id IN (
   (SELECT
    e.long_blob_id
    FROM epsdt e,
     (dummyt d  WITH seq = value(purge_rec->qual_knt))
    PLAN (d
     WHERE d.seq > 0
      AND (purge_rec->qual[d.seq].mil_item_id > 0)
      AND (purge_rec->qual[d.seq].is_a_prsnl=false))
     JOIN (e
     WHERE (e.person_id=purge_rec->qual[d.seq].mil_item_id))
    WITH nocounter))
   WITH nocounter, maxcommit = 5000
  ;end delete
  DELETE  FROM epsdt e,
    (dummyt d  WITH seq = value(purge_rec->qual_knt))
   SET e.seq = 1
   PLAN (d
    WHERE d.seq > 0
     AND (purge_rec->qual[d.seq].mil_item_id > 0)
     AND (purge_rec->qual[d.seq].is_a_prsnl=false))
    JOIN (e
    WHERE (e.person_id=purge_rec->qual[d.seq].mil_item_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
  DELETE  FROM person_org_reltn p,
    (dummyt d  WITH seq = value(purge_rec->qual_knt))
   SET p.seq = 1
   PLAN (d
    WHERE d.seq > 0
     AND (purge_rec->qual[d.seq].mil_item_id > 0)
     AND (purge_rec->qual[d.seq].is_a_prsnl=false))
    JOIN (p
    WHERE (p.person_id=purge_rec->qual[d.seq].mil_item_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM address a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0)
    AND (purge_rec->qual[d.seq].is_a_prsnl=false))
   JOIN (a
   WHERE (a.parent_entity_id=purge_rec->qual[d.seq].mil_item_id)
    AND a.parent_entity_name="PERSON")
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR ADDRESS >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM phone a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0)
    AND (purge_rec->qual[d.seq].is_a_prsnl=false))
   JOIN (a
   WHERE (a.parent_entity_id=purge_rec->qual[d.seq].mil_item_id)
    AND a.parent_entity_name="PERSON")
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PHONE >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM person_matches m,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET m.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (m
   WHERE (((m.a_person_id=purge_rec->qual[d.seq].mil_item_id)) OR ((m.b_person_id=purge_rec->qual[d
   .seq].mil_item_id))) )
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PERSON_MATCHES >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM person_alias a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0)
    AND (purge_rec->qual[d.seq].is_a_prsnl=false))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].mil_item_id))
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PERSON_ALIAS (non-prsnl) >> ",trim(serrmsg
    ))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM person_alias a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0)
    AND (purge_rec->qual[d.seq].is_a_prsnl=true))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].mil_item_id)
    AND a.person_alias_type_cd != ssn_alias_type_cd)
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PERSON_ALIAS (is-prsnl) >> ",trim(serrmsg)
   )
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM person_prsnl_reltn a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].mil_item_id))
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PERSON_PRSNL_RELTN >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM person_name a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0)
    AND (purge_rec->qual[d.seq].is_a_prsnl=false))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].mil_item_id))
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PERSON_NAME >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM person a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0)
    AND (purge_rec->qual[d.seq].is_a_prsnl=false))
   JOIN (a
   WHERE (a.person_id=purge_rec->qual[d.seq].mil_item_id))
  WITH nocounter, maxcommit = 5000
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR PERSON >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_person_data a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.status = "BACK OUT", a.status_dt_tm = cnvtdatetime(curdate,curtime3), a.person_id = 0.0
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id > 0))
   JOIN (a
   WHERE (a.ags_person_data_id=purge_rec->qual[d.seq].bo_item_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE ERROR AGS_PERSON_DATA (backout items >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_person_data a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.status = "BACK OUT", a.status_dt_tm = cnvtdatetime(curdate,curtime3), a.person_id = 0.0
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id < 1)
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.ags_person_data_id=purge_rec->qual[d.seq].delete_item_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE ERROR AGS_PERSON_DATA (delete items) >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM ags_person_data a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id > 0)
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.ags_person_data_id=purge_rec->qual[d.seq].delete_item_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = delete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR AGS_PERSON_DATA >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF (define_logging_sub=true)
  SUBROUTINE handle_logging(slog_file,semail,istatus)
    CALL echo("***")
    CALL echo(build("***   sLog_file :",slog_file))
    CALL echo(build("***   sEmail    :",semail))
    CALL echo(build("***   iStatus   :",istatus))
    CALL echo("***")
    FREE SET output_log
    SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
    SELECT INTO output_log
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      out_line = fillstring(254," "), sstatus = fillstring(25," ")
     DETAIL
      FOR (idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[idx].smsgtype,"#######")," :: ",
           format(log->qual[idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[idx].
            smsg))))
        IF ((idx=log->qual_knt))
         IF (istatus=0)
          sstatus = "SUCCESS"
         ELSEIF (istatus=1)
          sstatus = "FAILURE"
         ELSE
          sstatus = "SUCCESS - With Warnings"
         ENDIF
         out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
        ENDIF
        col 0, out_line
        IF ((idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
  END ;Subroutine
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  ROLLBACK
  CALL echo("***")
  CALL echo("***   failed != FALSE")
  CALL echo("***")
  IF (the_job_id > 0)
   CALL echo("***")
   CALL echo("***   Update Job to Error")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_job j
    SET j.status = "ERROR-PURGE", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (j
     WHERE j.ags_job_id=the_job_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    ROLLBACK
    SET failed = update_error
    SET table_name = "AGS_JOB ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_JOB ERROR :: Update Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  CALL echo("***")
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  IF (the_job_id > 0)
   CALL echo("***")
   CALL echo("***   Update Job to Back Out")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_job j
    SET j.status = "PURGED", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (j
     WHERE j.ags_job_id=the_job_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    ROLLBACK
    SET failed = update_error
    SET table_name = "AGS_JOB ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_JOB ERROR :: Update Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
  ENDIF
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PERSON_PURGE"
 IF (define_logging_sub=true)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
  SET s_log_name = sstatus_file_name
  CALL echo("***")
  CALL echo(build("***   Log File: cer_log >",s_log_name))
  CALL echo("***")
 ENDIF
 CALL echo("***")
 CALL echo("***   END :: AGS_PERSON_PURGE")
 CALL echo("***")
 SET script_ver = "005 12/06/06"
END GO

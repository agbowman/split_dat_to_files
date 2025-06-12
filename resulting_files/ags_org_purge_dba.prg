CREATE PROGRAM ags_org_purge:dba
 PROMPT
  "Backout Type (J, I, P) =" = "J",
  "AGS_JOB_ID (0.0) = " = 0.0
  WITH cbackout_type, djob_id
 CALL echo("***")
 CALL echo("***   BEG :: AGS_ORG_PURGE")
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
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_org_purge_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_ORG_PURGE"
 DECLARE the_type = c1 WITH protect, noconstant(" ")
 SET the_type =  $CBACKOUT_TYPE
 DECLARE the_job_id = f8 WITH protect, noconstant(0.0)
 SET the_job_id =  $DJOB_ID
 FREE RECORD purge_rec
 RECORD purge_rec(
   1 qual_knt = i4
   1 qual[*]
     2 delete_item_id = f8
     2 delete_loc_cd = f8
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
 DECLARE disable_trigger = vc WITH public, constant(
  "RDB ALTER TABLE CODE_VALUE DISABLE ALL TRIGGERS GO")
 DECLARE enable_trigger = vc WITH public, constant(
  "RDB ALTER TABLE CODE_VALUE ENABLE ALL TRIGGERS GO")
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
 DECLARE create_fac_cd_index = vc WITH public, noconstant("")
 DECLARE drop_fac_cd_index = vc WITH public, noconstant("")
 DECLARE create_bill_org_id_index = vc WITH public, noconstant("")
 DECLARE drop_bill_org_index = vc WITH public, noconstant("")
 SET create_fac_cd_index = concat("RDB CREATE INDEX V500.T1_HEA_CLAIM_VISIT ON ",
  "V500.HEA_CLAIM_VISIT (BILLING_FACILITY_CD) TABLESPACE ",
  "I_AGS STORAGE(MAXEXTENTS UNLIMITED INITIAL 100k NEXT 100k)GO")
 SET drop_fac_cd_index = "RDB DROP INDEX V500.T1_HEA_CLAIM_VISIT GO"
 SET create_bill_org_id_index = concat("RDB CREATE INDEX V500.T2_HEA_CLAIM_VISIT ON ",
  "V500.HEA_CLAIM_VISIT (BILLING_ORG_ID) TABLESPACE ",
  "I_AGS STORAGE(MAXEXTENTS UNLIMITED INITIAL 100k NEXT 100k)GO")
 SET drop_bill_org_index = "RDB DROP INDEX V500.T2_HEA_CLAIM_VISIT GO"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 CALL parser(create_fac_cd_index)
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = lock_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat(
   "CREATE INDEX ERROR T1_HEA_CLAIM_VISIT (BILLING_FACILITY_CD) >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 CALL parser(create_bill_org_id_index)
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = lock_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat(
   "CREATE INDEX ERROR T2_HEA_CLAIM_VISIT (BILLING_ORG_ID) >> ",trim(serrmsg))
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
  SET log->qual[log->qual_knt].smsg = "INVALID BACKOUT >> ORG by Person File Not Allowed"
  GO TO exit_script
 ELSEIF (the_type="J"
  AND the_job_id > 0.0)
  CALL echo("***")
  CALL echo("***   JOB Type Run")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_org_data a
   PLAN (a
    WHERE a.ags_job_id=the_job_id)
   HEAD REPORT
    sknt = 0, stat = alterlist(purge_rec->qual,10)
   DETAIL
    sknt = (sknt+ 1)
    IF (mod(sknt,10)=1
     AND sknt != 1)
     stat = alterlist(purge_rec->qual,(sknt+ 9))
    ENDIF
    purge_rec->qual[sknt].mil_item_id = a.organization_id, purge_rec->qual[sknt].delete_item_id = a
    .ags_org_data_id, purge_rec->qual[sknt].delete_loc_cd = a.location_cd,
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
   SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_ORG_DATA (delete items) >> ",trim(
     serrmsg))
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
  SET log->qual[log->qual_knt].smsg = "INVALID PURGE >> ORG by Item Not Allowed"
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
   ags_org_data a
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.location_cd=purge_rec->qual[d.seq].delete_loc_cd)
    AND (a.run_nbr < purge_rec->qual[d.seq].delete_run_nbr))
  ORDER BY d.seq, a.run_nbr DESC
  HEAD d.seq
   purge_rec->qual[d.seq].bo_item_id = a.ags_org_data_id
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
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_ORG_DATA (backout items)>> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET stat = initrec(sub_item_rec)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   hea_claim_visit h,
   ags_claim_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_loc_cd > 0))
   JOIN (h
   WHERE (h.billing_facility_cd=purge_rec->qual[d.seq].delete_loc_cd))
   JOIN (a2
   WHERE a2.hea_claim_visit_id=h.hea_claim_visit_id)
  HEAD REPORT
   sknt = 0, stat = alterlist(sub_item_rec->qual,10), first_pass = true
  HEAD a2.ags_claim_data_id
   IF (first_pass=true)
    sknt = (sknt+ 1)
    IF (mod(sknt,10)=1
     AND sknt != 1)
     stat = alterlist(sub_item_rec->qual,(sknt+ 9))
    ENDIF
    sub_item_rec->qual[sknt].data_id = a2.ags_claim_data_id
   ELSE
    lpos = 0, num = 0, lpos = locateval(num,1,sknt,a2.ags_claim_data_id,sub_item_rec->qual[num].
     data_id)
    IF (lpos < 1)
     sknt = (sknt+ 1)
     IF (mod(sknt,10)=1
      AND sknt != 1)
      stat = alterlist(sub_item_rec->qual,(sknt+ 9))
     ENDIF
     sub_item_rec->qual[sknt].data_id = a2.ags_claim_data_id
    ENDIF
   ENDIF
   first_pass = false
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
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_CLAIM_DATA By Location >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   hea_claim_visit h,
   ags_claim_data a2
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (h
   WHERE (h.billing_org_id=purge_rec->qual[d.seq].mil_item_id))
   JOIN (a2
   WHERE a2.hea_claim_visit_id=h.hea_claim_visit_id)
  HEAD REPORT
   sknt = sub_item_rec->qual_knt, stat = alterlist(sub_item_rec->qual,(sub_item_rec->qual_knt+ 10))
   IF (sknt > 0)
    first_pass = false
   ELSE
    first_pass = true
   ENDIF
  HEAD a2.ags_claim_data_id
   IF (first_pass=true)
    sknt = (sknt+ 1)
    IF (mod(sknt,10)=1
     AND sknt != 1)
     stat = alterlist(sub_item_rec->qual,(sknt+ 9))
    ENDIF
    sub_item_rec->qual[sknt].data_id = a2.ags_claim_data_id
   ELSE
    lpos = 0, num = 0, lpos = locateval(num,1,sknt,a2.ags_claim_data_id,sub_item_rec->qual[num].
     data_id)
    IF (lpos < 1)
     sknt = (sknt+ 1)
     IF (mod(sknt,10)=1
      AND sknt != 1)
      stat = alterlist(sub_item_rec->qual,(sknt+ 9))
     ENDIF
     sub_item_rec->qual[sknt].data_id = a2.ags_claim_data_id
    ENDIF
   ENDIF
   first_pass = false
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
  SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_CLAIM_DATA By Organization>> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 IF ((sub_item_rec->qual_knt > 0))
  EXECUTE ags_claim_backout value("I"), value(0.0) WITH replace("ITEM_REC","SUB_ITEM_REC")
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
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM address a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.parent_entity_id=purge_rec->qual[d.seq].mil_item_id)
    AND a.parent_entity_name="ORGANIZATION")
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
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.parent_entity_id=purge_rec->qual[d.seq].mil_item_id)
    AND a.parent_entity_name="ORGANIZATION")
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
 DELETE  FROM location a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.organization_id=purge_rec->qual[d.seq].mil_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR LOCATION >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM org_type_reltn a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.organization_id=purge_rec->qual[d.seq].mil_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR ORG_TYPE_RELTN >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM organization_alias a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.organization_id=purge_rec->qual[d.seq].mil_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR ORGANIZATION_ALIAS >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM organization a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (a
   WHERE (a.organization_id=purge_rec->qual[d.seq].mil_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR ORGANIZATION >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM code_value_alias c,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET c.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_loc_cd > 0))
   JOIN (c
   WHERE (c.code_value=purge_rec->qual[d.seq].delete_loc_cd))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR CODE_VALUE_ALIAS >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 CALL parser(disable_trigger)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM code_value c,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET c.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_loc_cd > 0))
   JOIN (c
   WHERE (c.code_value=purge_rec->qual[d.seq].delete_loc_cd))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR CODE_VALUE >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 CALL parser(enable_trigger)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_org_data a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.status = "BACK OUT", a.status_dt_tm = cnvtdatetime(curdate,curtime3), a.organization_id = 0.0,
   a.location_cd = 0.0
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id > 0))
   JOIN (a
   WHERE (a.ags_org_data_id=purge_rec->qual[d.seq].bo_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("UPDATE ERROR AGS_ORG_DATA (backout items >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_org_data a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.status = "BACK OUT", a.status_dt_tm = cnvtdatetime(curdate,curtime3), a.organization_id = 0.0,
   a.location_cd = 0.0
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id < 1)
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.ags_org_data_id=purge_rec->qual[d.seq].delete_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("UPDATE ERROR AGS_ORG_DATA (delete items) >> ",trim(
    serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM ags_org_data a,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET a.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id > 0)
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a
   WHERE (a.ags_org_data_id=purge_rec->qual[d.seq].delete_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR AGS_ORG_DATA >> ",trim(serrmsg))
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
   CALL echo("***   Update Job to Purged")
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_ORG_PURGE"
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
 CALL parser(drop_fac_cd_index)
 CALL parser(drop_bill_org_index)
 CALL echo("***")
 CALL echo("***   END :: AGS_ORG_PURGE")
 CALL echo("***")
 SET script_ver = "001   09/08/06"
END GO

CREATE PROGRAM ct_chg_domain_info
 RECORD reply(
   1 ct_domain_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 DECLARE identifier_conflict = i2 WITH private, constant(1)
 DECLARE domain_name_validation = i2 WITH private, constant(2)
 DECLARE insert_error = i2 WITH private, constant(3)
 DECLARE update_error = i2 WITH private, constant(4)
 DECLARE lock_error = i2 WITH private, constant(5)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET new_id = nextsequence(0)
 IF ((request->ct_domain_id=0.0))
  SELECT INTO "nl:"
   FROM ct_domain_info cdi
   WHERE (cdi.domain_name_ident=request->domain_identifier)
    AND (cdi.logical_domain_id=domain_reply->logical_domain_id)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET fail_flag = identifier_conflict
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The domain identifier is not unique."
   GO TO check_error
  ELSE
   SELECT INTO "NL:"
    FROM ct_domain_info cdi
    WHERE (cdi.domain_name=request->domain_name)
     AND cdi.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (cdi.logical_domain_id=domain_reply->logical_domain_id)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET fail_flag = domain_name_validation
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "The domain name is not unique."
    GO TO check_error
   ELSE
    INSERT  FROM ct_domain_info cdi
     SET cdi.beg_effective_dt_tm = cnvtdatetime(sysdate), cdi.ct_domain_info_id = new_id, cdi
      .domain_name = request->domain_name,
      cdi.domain_name_ident = request->domain_identifier, cdi.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), cdi.prev_ct_domain_info_id = new_id,
      cdi.updt_applctx = reqinfo->updt_applctx, cdi.updt_cnt = 0, cdi.updt_dt_tm = cnvtdatetime(
       sysdate),
      cdi.updt_id = reqinfo->updt_id, cdi.updt_task = reqinfo->updt_task, cdi.url1_txt = request->
      url_one_text,
      cdi.url2_txt = request->url_two_text, cdi.logical_domain_id = domain_reply->logical_domain_id
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "The domain information could not be inserted into the database."
     GO TO check_error
    ELSE
     SET reply->ct_domain_id = new_id
    ENDIF
   ENDIF
  ENDIF
 ELSE
  IF ((request->delete_ind=1))
   SELECT INTO "NL:"
    FROM prot_amendment pa
    WHERE (pa.ct_domain_info_id=request->ct_domain_id)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET fail_flag = domain_name_validation
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "The domain information could not be deleted because it is in use."
    GO TO check_error
   ENDIF
  ENDIF
  INSERT  FROM ct_domain_info cdi
   (cdi.beg_effective_dt_tm, cdi.ct_domain_info_id, cdi.domain_name,
   cdi.domain_name_ident, cdi.end_effective_dt_tm, cdi.prev_ct_domain_info_id,
   cdi.updt_applctx, cdi.updt_cnt, cdi.updt_dt_tm,
   cdi.updt_id, cdi.updt_task, cdi.url1_txt,
   cdi.url2_txt, cdi.logical_domain_id)(SELECT
    cdi1.beg_effective_dt_tm, new_id, cdi1.domain_name,
    cdi1.domain_name_ident, cnvtdatetime(sysdate), cdi1.ct_domain_info_id,
    cdi1.updt_applctx, cdi1.updt_cnt, cdi1.updt_dt_tm,
    cdi1.updt_id, cdi1.updt_task, cdi1.url1_txt,
    cdi1.url2_txt, cdi1.logical_domain_id
    FROM ct_domain_info cdi1
    WHERE (cdi1.ct_domain_info_id=request->ct_domain_id)
     AND cdi1.end_effective_dt_tm > cnvtdatetime(sysdate))
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The domain information could not be updated."
   GO TO check_error
  ELSE
   SELECT INTO "nl:"
    cdi.ct_domain_info_id
    FROM ct_domain_info cdi
    WHERE (ct_domain_info_id=request->ct_domain_id)
    WITH nocounter, forupdate(cdi)
   ;end select
   IF (curqual != 1)
    SET fail_flag = lock_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "The domain information table could not be locked."
   ELSE
    UPDATE  FROM ct_domain_info cdi
     SET cdi.beg_effective_dt_tm = cnvtdatetime(sysdate), cdi.domain_name = request->domain_name, cdi
      .end_effective_dt_tm =
      IF ((request->delete_ind=1)) cnvtdatetime(sysdate)
      ELSE cdi.end_effective_dt_tm
      ENDIF
      ,
      cdi.updt_applctx = reqinfo->updt_applctx, cdi.updt_cnt = (cdi.updt_cnt+ 1), cdi.updt_dt_tm =
      cnvtdatetime(sysdate),
      cdi.updt_id = reqinfo->updt_id, cdi.updt_task = reqinfo->updt_task, cdi.url1_txt = request->
      url_one_text,
      cdi.url2_txt = request->url_two_text
     WHERE (cdi.ct_domain_info_id=request->ct_domain_id)
     WITH nocounter
    ;end update
    IF (curqual != 1)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "The domain information table could not be updated."
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CASE (fail_flag)
   OF identifier_conflict:
    SET reply->status_data.status = "U"
   OF domain_name_validation:
    SET reply->status_data.status = "V"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.status = "F"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.status = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.status = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.status = "F"
  ENDCASE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "001"
 SET mod_date = "February 25, 2019"
END GO

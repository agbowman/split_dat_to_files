CREATE PROGRAM ct_chg_prot_type_config:dba
 IF ( NOT (validate(reply,0)))
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
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE value_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET value_cnt = size(request->values,5)
 FOR (idx = 1 TO value_cnt)
   IF ((request->values[idx].ct_prot_type_config_id > 0.0))
    CALL echo("UPDATE")
    SET new_id = nextsequence(0)
    INSERT  FROM ct_prot_type_config conf
     (conf.ct_prot_type_config_id, conf.prev_ct_prot_type_config_id, conf.protocol_type_cd,
     conf.item_cd, conf.config_value_cd, conf.beg_effective_dt_tm,
     conf.end_effective_dt_tm, conf.updt_dt_tm, conf.updt_id,
     conf.updt_task, conf.updt_applctx, conf.updt_cnt,
     conf.logical_domain_id)(SELECT
      new_id, conf1.prev_ct_prot_type_config_id, conf1.protocol_type_cd,
      conf1.item_cd, conf1.config_value_cd, conf1.beg_effective_dt_tm,
      cnvtdatetime(script_date), conf1.updt_dt_tm, conf1.updt_id,
      conf1.updt_task, conf1.updt_applctx, conf1.updt_cnt,
      conf1.logical_domain_id
      FROM ct_prot_type_config conf1
      WHERE (conf1.ct_prot_type_config_id=request->values[idx].ct_prot_type_config_id))
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into ct_prot_type_config table."
     GO TO check_error
    ENDIF
    SELECT INTO "nl:"
     conf.ct_prot_type_config_id
     FROM ct_prot_type_config conf
     WHERE (conf.ct_prot_type_config_id=request->values[idx].ct_prot_type_config_id)
     WITH nocounter, forupdate(conf)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_prot_type_config table."
     GO TO check_error
    ENDIF
    UPDATE  FROM ct_prot_type_config conf
     SET conf.prev_ct_prot_type_config_id = conf.prev_ct_prot_type_config_id, conf.protocol_type_cd
       = request->values[idx].protocol_type_cd, conf.item_cd = request->values[idx].item_cd,
      conf.config_value_cd = request->values[idx].config_value_cd, conf.beg_effective_dt_tm =
      cnvtdatetime(script_date), conf.updt_dt_tm = cnvtdatetime(sysdate),
      conf.updt_id = reqinfo->updt_id, conf.updt_task = reqinfo->updt_task, conf.updt_applctx =
      reqinfo->updt_applctx,
      conf.updt_cnt = (conf.updt_cnt+ 1)
     WHERE (conf.ct_prot_type_config_id=request->values[idx].ct_prot_type_config_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_prot_type_config."
     GO TO check_error
    ENDIF
   ELSE
    SET new_id = nextsequence(0)
    INSERT  FROM ct_prot_type_config conf
     SET conf.ct_prot_type_config_id = new_id, conf.prev_ct_prot_type_config_id = new_id, conf
      .protocol_type_cd = request->values[idx].protocol_type_cd,
      conf.item_cd = request->values[idx].item_cd, conf.config_value_cd = request->values[idx].
      config_value_cd, conf.beg_effective_dt_tm = cnvtdatetime(script_date),
      conf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), conf.updt_dt_tm = cnvtdatetime
      (sysdate), conf.updt_id = reqinfo->updt_id,
      conf.updt_task = reqinfo->updt_task, conf.updt_applctx = reqinfo->updt_applctx, conf.updt_cnt
       = 0,
      conf.logical_domain_id = domain_reply->logical_domain_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Inserting new record into ct_prot_type_config table."
     GO TO check_error
    ENDIF
   ENDIF
 ENDFOR
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "001"
 SET mod_date = "May 30, 2019"
END GO

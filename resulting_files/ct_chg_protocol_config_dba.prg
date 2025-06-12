CREATE PROGRAM ct_chg_protocol_config:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 item_list[*]
      2 ct_prot_config_value_id = f8
      2 item_cd = f8
      2 item_disp = c40
      2 item_desc = c60
      2 item_mean = c12
      2 value_cd = f8
      2 value_disp = c40
      2 value_desc = c60
      2 value_mean = c12
    1 prot_type_list[*]
      2 item_cd = f8
      2 item_disp = c40
      2 item_desc = c60
      2 item_mean = c12
      2 value_cd = f8
      2 value_disp = c40
      2 value_desc = c60
      2 value_mean = c12
    1 stratification_type_cd = f8
    1 stratification_type_disp = c40
    1 stratification_type_desc = c60
    1 stratification_type_mean = c12
    1 manual_enroll_id_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE item_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->prot_master_id=0))
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname =
  "Missing prot_master_id - Unable to save configuration."
  GO TO exit_script
 ENDIF
 SET item_cnt = size(request->items,5)
 FOR (idx = 1 TO item_cnt)
   IF ((request->items[idx].ct_prot_config_value_id > 0.0))
    SET new_id = nextsequence(0)
    INSERT  FROM ct_prot_config_value conf
     (conf.ct_prot_config_value_id, conf.prev_ct_prot_config_value_id, conf.prot_master_id,
     conf.item_cd, conf.config_value_cd, conf.beg_effective_dt_tm,
     conf.end_effective_dt_tm, conf.updt_dt_tm, conf.updt_id,
     conf.updt_task, conf.updt_applctx, conf.updt_cnt)(SELECT
      new_id, conf1.prev_ct_prot_config_value_id, conf1.prot_master_id,
      conf1.item_cd, conf1.config_value_cd, conf1.beg_effective_dt_tm,
      cnvtdatetime(script_date), conf1.updt_dt_tm, conf1.updt_id,
      conf1.updt_task, conf1.updt_applctx, conf1.updt_cnt
      FROM ct_prot_config_value conf1
      WHERE (conf1.ct_prot_config_value_id=request->items[idx].ct_prot_config_value_id))
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into ct_prot_config_value table."
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     conf.ct_prot_config_value_id
     FROM ct_prot_config_value conf
     WHERE (conf.ct_prot_config_value_id=request->items[idx].ct_prot_config_value_id)
     WITH nocounter, forupdate(conf)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_prot_config_value table."
     GO TO exit_script
    ENDIF
    UPDATE  FROM ct_prot_config_value conf
     SET conf.prev_ct_prot_config_value_id = conf.prev_ct_prot_config_value_id, conf.prot_master_id
       = request->prot_master_id, conf.item_cd = request->items[idx].item_cd,
      conf.config_value_cd = request->items[idx].value_cd, conf.beg_effective_dt_tm = cnvtdatetime(
       script_date), conf.updt_dt_tm = cnvtdatetime(sysdate),
      conf.updt_id = reqinfo->updt_id, conf.updt_task = reqinfo->updt_task, conf.updt_applctx =
      reqinfo->updt_applctx,
      conf.updt_cnt = (conf.updt_cnt+ 1)
     WHERE (conf.ct_prot_config_value_id=request->items[idx].ct_prot_config_value_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_prot_config_value."
     GO TO exit_script
    ENDIF
   ELSE
    SET new_id = nextsequence(0)
    INSERT  FROM ct_prot_config_value conf
     SET conf.ct_prot_config_value_id = new_id, conf.prev_ct_prot_config_value_id = new_id, conf
      .prot_master_id = request->prot_master_id,
      conf.item_cd = request->items[idx].item_cd, conf.config_value_cd = request->items[idx].value_cd,
      conf.beg_effective_dt_tm = cnvtdatetime(script_date),
      conf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), conf.updt_dt_tm = cnvtdatetime
      (sysdate), conf.updt_id = reqinfo->updt_id,
      conf.updt_task = reqinfo->updt_task, conf.updt_applctx = reqinfo->updt_applctx, conf.updt_cnt
       = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Inserting new record into ct_prot_config_value table."
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
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
 SET last_mod = "000"
 SET mod_date = "December 12, 2008"
END GO

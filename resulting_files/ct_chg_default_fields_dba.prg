CREATE PROGRAM ct_chg_default_fields:dba
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
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET cnt = size(request->fields,5)
 FOR (idx = 1 TO cnt)
   IF ((request->fields[idx].ct_default_custom_fld_id > 0.0))
    SET new_id = nextsequence(0)
    INSERT  FROM ct_default_custom_fields dcf
     (dcf.ct_default_custom_fld_id, dcf.prev_ct_default_custom_fld_id, dcf.field_key,
     dcf.protocol_type_cd, dcf.field_position, dcf.beg_effective_dt_tm,
     dcf.end_effective_dt_tm, dcf.updt_dt_tm, dcf.updt_id,
     dcf.updt_task, dcf.updt_applctx, dcf.updt_cnt,
     dcf.logical_domain_id)(SELECT
      new_id, dcf1.prev_ct_default_custom_fld_id, dcf1.field_key,
      dcf1.protocol_type_cd, dcf1.field_position, dcf1.beg_effective_dt_tm,
      cnvtdatetime(script_date), dcf1.updt_dt_tm, dcf1.updt_id,
      dcf1.updt_task, dcf1.updt_applctx, dcf1.updt_cnt,
      dcf1.logical_domain_id
      FROM ct_default_custom_fields dcf1
      WHERE (dcf1.ct_default_custom_fld_id=request->fields[idx].ct_default_custom_fld_id))
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting previous record into ct_default_custom_fields table."
     GO TO check_error
    ENDIF
    SELECT INTO "nl:"
     dcf.ct_default_custom_fld_id
     FROM ct_default_custom_fields dcf
     WHERE (dcf.ct_default_custom_fld_id=request->fields[idx].ct_default_custom_fld_id)
     WITH nocounter, forupdate(dcf)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_default_custom_fields table."
     GO TO check_error
    ENDIF
    UPDATE  FROM ct_default_custom_fields dcf
     SET dcf.field_position = request->fields[idx].field_position, dcf.end_effective_dt_tm =
      IF ((request->fields[idx].delete_ind=1)) cnvtdatetime(script_date)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00")
      ENDIF
      , dcf.updt_dt_tm = cnvtdatetime(script_date),
      dcf.updt_id = reqinfo->updt_id, dcf.updt_task = reqinfo->updt_task, dcf.updt_applctx = reqinfo
      ->updt_applctx,
      dcf.updt_cnt = (dcf.updt_cnt+ 1)
     WHERE (dcf.ct_default_custom_fld_id=request->fields[idx].ct_default_custom_fld_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_default_custom_fields."
     GO TO check_error
    ENDIF
   ELSE
    SET new_id = nextsequence(0)
    INSERT  FROM ct_default_custom_fields cfv
     SET cfv.ct_default_custom_fld_id = new_id, cfv.prev_ct_default_custom_fld_id = new_id, cfv
      .protocol_type_cd = request->fields[idx].protocol_type_cd,
      cfv.field_key = request->fields[idx].field_key, cfv.field_position = request->fields[idx].
      field_position, cfv.beg_effective_dt_tm = cnvtdatetime(script_date),
      cfv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), cfv.updt_dt_tm = cnvtdatetime(
       script_date), cfv.updt_id = reqinfo->updt_id,
      cfv.updt_task = reqinfo->updt_task, cfv.updt_applctx = reqinfo->updt_applctx, cfv.updt_cnt = 0,
      cfv.logical_domain_id = domain_reply->logical_domain_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting new record into ct_default_custom_fields table."
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
 SET mod_date = "October 17, 2019"
END GO

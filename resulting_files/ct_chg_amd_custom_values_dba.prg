CREATE PROGRAM ct_chg_amd_custom_values:dba
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
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE values_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE item_cnt = i4 WITH protect, noconstant(0)
 DECLARE item_idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET values_cnt = size(request->values,5)
 FOR (idx = 1 TO values_cnt)
   IF ((request->values[idx].ct_prot_amd_custom_fld_id > 0.0))
    CALL echo("UPDATE")
    SET new_id = nextsequence(0)
    INSERT  FROM ct_prot_amd_custom_fld_val cfv
     (cfv.ct_prot_amd_custom_fld_id, cfv.prev_ct_prot_amd_custom_fld_id, cfv.ct_custom_field_id,
     cfv.prot_amendment_id, cfv.field_position, cfv.value_cd,
     cfv.value_dt_tm, cfv.value_text, cfv.beg_effective_dt_tm,
     cfv.end_effective_dt_tm, cfv.updt_dt_tm, cfv.updt_id,
     cfv.updt_task, cfv.updt_applctx, cfv.updt_cnt)(SELECT
      new_id, cfv1.prev_ct_prot_amd_custom_fld_id, cfv1.ct_custom_field_id,
      cfv1.prot_amendment_id, cfv1.field_position, cfv1.value_cd,
      cfv1.value_dt_tm, cfv1.value_text, cfv1.beg_effective_dt_tm,
      cnvtdatetime(script_date), cfv1.updt_dt_tm, cfv1.updt_id,
      cfv1.updt_task, cfv1.updt_applctx, cfv1.updt_cnt
      FROM ct_prot_amd_custom_fld_val cfv1
      WHERE (cfv1.ct_prot_amd_custom_fld_id=request->values[idx].ct_prot_amd_custom_fld_id))
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting previous record into ct_prot_amd_custom_fld_val table."
     GO TO check_error
    ENDIF
    SELECT INTO "nl:"
     cfv.ct_prot_amd_custom_fld_id
     FROM ct_prot_amd_custom_fld_val cfv
     WHERE (cfv.ct_prot_amd_custom_fld_id=request->values[idx].ct_prot_amd_custom_fld_id)
     WITH nocounter, forupdate(cfr)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_prot_amd_custom_fld_val table."
     GO TO check_error
    ENDIF
    UPDATE  FROM ct_prot_amd_custom_fld_val cfv
     SET cfv.field_position = request->values[idx].field_position, cfv.value_cd = request->values[idx
      ].value_cd, cfv.value_dt_tm =
      IF ((request->values[idx].value_dt_tm > 0)) cnvtdatetime(request->values[idx].value_dt_tm)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00")
      ENDIF
      ,
      cfv.value_text = request->values[idx].value_text, cfv.end_effective_dt_tm =
      IF ((request->values[idx].delete_ind=1)) cnvtdatetime(script_date)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00")
      ENDIF
      , cfv.updt_dt_tm = cnvtdatetime(script_date),
      cfv.updt_id = reqinfo->updt_id, cfv.updt_task = reqinfo->updt_task, cfv.updt_applctx = reqinfo
      ->updt_applctx,
      cfv.updt_cnt = (cfv.updt_cnt+ 1)
     WHERE (cfv.ct_prot_amd_custom_fld_id=request->values[idx].ct_prot_amd_custom_fld_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_prot_amd_custom_fld_val."
     GO TO check_error
    ENDIF
   ELSE
    SET new_id = nextsequence(0)
    INSERT  FROM ct_prot_amd_custom_fld_val cfv
     SET cfv.ct_prot_amd_custom_fld_id = new_id, cfv.prev_ct_prot_amd_custom_fld_id = new_id, cfv
      .prot_amendment_id = request->values[idx].prot_amendment_id,
      cfv.ct_custom_field_id = request->values[idx].ct_custom_field_id, cfv.field_position = request
      ->values[idx].field_position, cfv.value_cd = request->values[idx].value_cd,
      cfv.value_dt_tm =
      IF ((request->values[idx].value_dt_tm > 0)) cnvtdatetime(request->values[idx].value_dt_tm)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00")
      ENDIF
      , cfv.value_text = request->values[idx].value_text, cfv.beg_effective_dt_tm = cnvtdatetime(
       script_date),
      cfv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), cfv.updt_dt_tm = cnvtdatetime(
       script_date), cfv.updt_id = reqinfo->updt_id,
      cfv.updt_task = reqinfo->updt_task, cfv.updt_applctx = reqinfo->updt_applctx, cfv.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting new record into ct_prot_amd_custom_fld_val table."
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
 SET last_mod = "000"
 SET mod_date = "August 5, 2008"
END GO

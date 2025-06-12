CREATE PROGRAM ct_chg_field_group_reltn:dba
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
 DECLARE reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reltn_cnt = size(request->reltns,5)
 FOR (idx = 1 TO reltn_cnt)
   IF ((request->reltns[idx].ct_custom_fld_grp_rel_id > 0.0))
    CALL echo("UPDATE")
    SET new_id = nextsequence(0)
    INSERT  FROM ct_custom_field_group_reltn cfr
     (cfr.ct_custom_fld_grp_rel_id, cfr.prev_ct_custom_fld_grp_rel_id, cfr.field_key,
     cfr.group_cd, cfr.beg_effective_dt_tm, cfr.end_effective_dt_tm,
     cfr.updt_dt_tm, cfr.updt_id, cfr.updt_task,
     cfr.updt_applctx, cfr.updt_cnt, cfr.logical_domain_id)(SELECT
      new_id, cfr1.prev_ct_custom_fld_grp_rel_id, cfr1.field_key,
      cfr1.group_cd, cfr1.beg_effective_dt_tm, cnvtdatetime(script_date),
      cfr1.updt_dt_tm, cfr1.updt_id, cfr1.updt_task,
      cfr1.updt_applctx, cfr1.updt_cnt, cfr1.logical_domain_id
      FROM ct_custom_field_group_reltn cfr1
      WHERE (cfr1.ct_custom_fld_grp_rel_id=request->reltns[idx].ct_custom_fld_grp_rel_id))
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting previous record into ct_custom_field_group_reltn table."
     GO TO check_error
    ENDIF
    SELECT INTO "nl:"
     cfr.ct_custom_fld_grp_rel_id
     FROM ct_custom_field_group_reltn cfr
     WHERE (cfr.ct_custom_fld_grp_rel_id=request->reltns[idx].ct_custom_fld_grp_rel_id)
     WITH nocounter, forupdate(cfr)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_custom_field_group_reltn table."
     GO TO check_error
    ENDIF
    UPDATE  FROM ct_custom_field_group_reltn cfr
     SET cfr.field_key = request->reltns[idx].field_key, cfr.group_cd = request->reltns[idx].group_cd,
      cfr.end_effective_dt_tm =
      IF ((request->reltns[idx].delete_ind=1)) cnvtdatetime(script_date)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00")
      ENDIF
      ,
      cfr.updt_dt_tm = cnvtdatetime(script_date), cfr.updt_id = reqinfo->updt_id, cfr.updt_task =
      reqinfo->updt_task,
      cfr.updt_applctx = reqinfo->updt_applctx, cfr.updt_cnt = (cfr.updt_cnt+ 1)
     WHERE (cfr.ct_custom_fld_grp_rel_id=request->reltns[idx].ct_custom_fld_grp_rel_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_custom_field_group_reltn."
     GO TO check_error
    ENDIF
   ELSE
    SET new_id = nextsequence(0)
    INSERT  FROM ct_custom_field_group_reltn cfr
     SET cfr.ct_custom_fld_grp_rel_id = new_id, cfr.prev_ct_custom_fld_grp_rel_id = new_id, cfr
      .field_key = request->reltns[idx].field_key,
      cfr.group_cd = request->reltns[idx].group_cd, cfr.beg_effective_dt_tm = cnvtdatetime(
       script_date), cfr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
      cfr.updt_dt_tm = cnvtdatetime(script_date), cfr.updt_id = reqinfo->updt_id, cfr.updt_task =
      reqinfo->updt_task,
      cfr.updt_applctx = reqinfo->updt_applctx, cfr.updt_cnt = 0, cfr.logical_domain_id =
      domain_reply->logical_domain_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting new record into ct_custom_field_group_reltn table."
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
 SET mod_date = "March 17, 2019"
END GO

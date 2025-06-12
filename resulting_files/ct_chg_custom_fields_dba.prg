CREATE PROGRAM ct_chg_custom_fields:dba
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
 RECORD deleted_fields(
   1 fields[*]
     2 field_key = c30
 )
 RECORD reltn_request(
   1 reltns[*]
     2 ct_custom_fld_grp_rel_id = f8
     2 field_key = c30
     2 group_cd = f8
     2 delete_ind = i2
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
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE duplication_error = i2 WITH private, constant(4)
 DECLARE delete_error = i2 WITH private, constant(5)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE field_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE duplicate_found = i2 WITH protect, noconstant(0)
 DECLARE del_cnt = i4 WITH protect, noconstant(0)
 DECLARE reltn_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET field_cnt = size(request->fields,5)
 SET del_cnt = 0
 FOR (idx = 1 TO field_cnt)
   SET duplicate_found = 0
   IF ((request->fields[idx].ct_custom_field_id > 0.0))
    IF ((request->fields[idx].delete_ind=1))
     SELECT INTO "nl:"
      FROM ct_prot_amd_custom_fld_val val
      WHERE (val.ct_custom_field_id=request->fields[idx].ct_custom_field_id)
       AND val.end_effective_dt_tm > cnvtdatetime(sysdate)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET fail_flag = delete_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Field being used in ct_prot_amd_custom_fld_val."
      GO TO check_error
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     cf.ct_custom_field_id
     FROM ct_custom_field cf
     WHERE (cf.ct_custom_field_id=request->fields[idx].ct_custom_field_id)
     WITH nocounter, forupdate(cf)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_custom_field table."
     GO TO check_error
    ENDIF
    UPDATE  FROM ct_custom_field cf
     SET cf.active_ind = 0, cf.updt_dt_tm = cnvtdatetime(script_date), cf.updt_id = reqinfo->updt_id,
      cf.updt_task = reqinfo->updt_task, cf.updt_applctx = reqinfo->updt_applctx, cf.updt_cnt = (cf
      .updt_cnt+ 1)
     WHERE (cf.ct_custom_field_id=request->fields[idx].ct_custom_field_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_custom_field."
     GO TO check_error
    ENDIF
    IF ((request->fields[idx].delete_ind=1))
     SET del_cnt += 1
     SET stat = alterlist(deleted_fields->fields,del_cnt)
     SET deleted_fields->fields[del_cnt].field_key = request->fields[idx].field_key
    ENDIF
   ELSE
    CALL echo("Checking for duplicates")
    SELECT INTO "nl:"
     cf.ct_custom_field_id
     FROM ct_custom_field cf
     WHERE (cf.field_key=request->fields[idx].field_key)
      AND (cf.logical_domain_id=domain_reply->logical_domain_id)
     HEAD cf.field_key
      duplicate_found = 1
     WITH nocounter
    ;end select
    IF (duplicate_found=1)
     CALL echo("Found duplicate")
     SET fail_flag = duplication_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Duplicate field key found in ct_custom_field."
     GO TO check_error
    ENDIF
   ENDIF
   IF ((request->fields[idx].delete_ind=0))
    SET new_id = nextsequence(0)
    INSERT  FROM ct_custom_field cf
     SET cf.ct_custom_field_id = new_id, cf.field_key = request->fields[idx].field_key, cf
      .field_label = request->fields[idx].field_label,
      cf.field_type_cd = request->fields[idx].field_type_cd, cf.code_set = request->fields[idx].
      code_set, cf.active_ind = 1,
      cf.updt_dt_tm = cnvtdatetime(script_date), cf.updt_id = reqinfo->updt_id, cf.updt_task =
      reqinfo->updt_task,
      cf.updt_applctx = reqinfo->updt_applctx, cf.updt_cnt = 0, cf.logical_domain_id = domain_reply->
      logical_domain_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into ct_custom_field table."
     GO TO check_error
    ENDIF
   ENDIF
 ENDFOR
 SET field_cnt = size(request->reltns,5)
 IF (field_cnt > 0
  AND del_cnt=0)
  EXECUTE ct_chg_field_group_reltn
 ELSEIF (del_cnt > 0)
  IF (field_cnt > 0)
   SET stat = alterlist(reltn_request->reltns,field_cnt)
   FOR (idx = 1 TO field_cnt)
     SET reltn_request->reltns[idx].ct_custom_fld_grp_rel_id = request->reltns[idx].
     ct_custom_fld_grp_rel_id
     SET reltn_request->reltns[idx].group_cd = request->reltns[idx].group_cd
     SET reltn_request->reltns[idx].delete_ind = request->reltns[idx].delete_ind
   ENDFOR
  ENDIF
  SELECT INTO "nl:"
   FROM ct_custom_field_group_reltn cfr,
    (dummyt d1  WITH seq = value(del_cnt))
   PLAN (d1)
    JOIN (cfr
    WHERE (cfr.field_key=deleted_fields->fields[d1.seq].field_key)
     AND cfr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (cfr.logical_domain_id=domain_reply->logical_domain_id))
   HEAD REPORT
    reltn_cnt = field_cnt
   DETAIL
    reltn_cnt += 1
    IF ((mod(reltn_cnt,9)=(field_cnt+ 1)))
     stat = alterlist(reltn_request->reltns,(reltn_cnt+ 9))
    ENDIF
    reltn_request->reltns[reltn_cnt].ct_custom_fld_grp_rel_id = cfr.ct_custom_fld_grp_rel_id,
    reltn_request->reltns[reltn_cnt].field_key = cfr.field_key, reltn_request->reltns[reltn_cnt].
    group_cd = cfr.group_cd,
    reltn_request->reltns[reltn_cnt].delete_ind = 1
   FOOT REPORT
    stat = alterlist(reltn_request->reltns,reltn_cnt)
   WITH nocounter
  ;end select
  EXECUTE ct_chg_field_group_reltn  WITH replace("REQUEST","RELTN_REQUEST")
 ENDIF
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
   OF duplication_error:
    SET reply->status_data.subeventstatus[1].operationname = "DUPLICATE KEY"
    SET reply->status_data.status = "D"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE ERROR"
    SET reply->status_data.status = "R"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD deleted_fields
 FREE RECORD reltn_request
 SET last_mod = "001"
 SET mod_date = "March 17, 2019"
END GO

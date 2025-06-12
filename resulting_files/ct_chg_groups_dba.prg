CREATE PROGRAM ct_chg_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 curqual = i4
    1 qual[*]
      2 status = i2
      2 error_num = i4
      2 error_msg = vc
      2 code_value = f8
      2 cki = vc
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
 DECLARE core_cd_error = i2 WITH private, constant(4)
 DECLARE duplicate_error = i2 WITH private, constant(5)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE group_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE dup_ind = i4 WITH protect, noconstant(0)
 DECLARE cnt_to_updt = i4 WITH protect, noconstant(0)
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(request->cd_value_list,5)))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=17911
    AND cv.active_ind=1
    AND cv.display=trim(request->cd_value_list[d.seq].display)
    AND (((request->cd_value_list[d.seq].action_type_flag=1)) OR ((request->cd_value_list[d.seq].
   action_type_flag=2))) )
  DETAIL
   IF ((cv.code_value != request->cd_value_list[d.seq].code_value))
    dup_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (dup_ind=1)
  SET fail_flag = duplicate_error
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Duplicate code value found."
  GO TO check_error
 ENDIF
 SET group_cnt = size(request->cd_value_list,5)
 FOR (idx = 1 TO group_cnt)
   IF ((request->cd_value_list[idx].action_type_flag=3))
    SET new_id = nextsequence(0)
    INSERT  FROM ct_custom_field_group_reltn cfr
     (cfr.ct_custom_fld_grp_rel_id, cfr.prev_ct_custom_fld_grp_rel_id, cfr.ct_custom_field_id,
     cfr.group_cd, cfr.beg_effective_dt_tm, cfr.end_effective_dt_tm,
     cfr.updt_dt_tm, cfr.updt_id, cfr.updt_task,
     cfr.updt_applctx, cfr.updt_cnt, cfr.logical_domain_id)(SELECT
      new_id, cfr1.prev_ct_custom_fld_grp_rel_id, cfr1.ct_custom_field_id,
      cfr1.group_cd, cfr1.beg_effective_dt_tm, cnvtdatetime(script_date),
      cfr1.updt_dt_tm, cfr1.updt_id, cfr1.updt_task,
      cfr1.updt_applctx, cfr1.updt_cnt, cfr1.logical_domain_id
      FROM ct_custom_field_group_reltn cfr1
      WHERE (cfr1.group_cd=request->cd_value_list[idx].code_value))
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into ct_custom_field_group_reltn table."
     GO TO check_error
    ENDIF
    SELECT INTO "nl:"
     cfr.ct_custom_fld_grp_rel_id
     FROM ct_custom_field_group_reltn cfr
     WHERE (cfr.group_cd=request->cd_value_list[idx].code_value)
     WITH nocounter, forupdate(cfr)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking into ct_custom_field_group_reltn table."
     GO TO check_error
    ENDIF
    UPDATE  FROM ct_custom_field_group_reltn cfr
     SET cfr.end_effective_dt_tm = cnvtdatetime(script_date), cfr.updt_dt_tm = cnvtdatetime(
       script_date), cfr.updt_id = reqinfo->updt_id,
      cfr.updt_task = reqinfo->updt_task, cfr.updt_applctx = reqinfo->updt_applctx, cfr.updt_cnt = (
      cf.updt_cnt+ 1)
     WHERE (cfr.group_cd=request->cd_value_list[idx].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into ct_custom_field_group_reltn."
     GO TO check_error
    ENDIF
   ENDIF
 ENDFOR
 FREE RECORD core_reply
 RECORD core_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE core_ens_cd_value  WITH replace("REPLY",core_reply)
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(request->cd_value_list,5)))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=17911
    AND cv.active_ind=1
    AND (cv.display=request->cd_value_list[d.seq].display)
    AND (((request->cd_value_list[d.seq].action_type_flag=1)) OR ((request->cd_value_list[d.seq].
   action_type_flag=2))) )
  DETAIL
   updt_cnt += 1
  WITH nocounter
 ;end select
 IF (dup_ind=1)
  SET fail_flag = core_cd_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error updating/inserting the group."
  GO TO check_error
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
   OF core_cd_error:
    SET reply->status_data.subeventstatus[1].operationname = "CORE SCRIPT EXECUTE"
   OF duplicate_error:
    SET reply->status_data.subeventstatus[1].operationname = "DUPLICATE CODE VALUE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD core_reply
 SET last_mod = "001"
 SET mod_date = "March 18, 2019"
END GO

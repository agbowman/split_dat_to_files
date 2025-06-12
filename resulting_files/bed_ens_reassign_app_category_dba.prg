CREATE PROGRAM bed_ens_reassign_app_category:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET old_cat
 RECORD old_cat(
   1 list[*]
     2 application_group_cd = f8
     2 sequence = i4
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET app_group_cnt = size(request->app_group_list,5)
 IF (app_group_cnt=0)
  SET error_flag = "Y"
  SET error_msg = "No records in the list"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO app_group_cnt)
   SET old_cat_id = 0.0
   SELECT INTO "NL:"
    FROM br_app_cat_comp bacc
    WHERE (bacc.application_group_cd=request->app_group_list[i].app_grp_code_value)
    DETAIL
     old_cat_id = bacc.category_id
    WITH nocounter
   ;end select
   IF (old_cat_id > 0.0)
    DELETE  FROM br_app_cat_comp bacc
     WHERE (bacc.application_group_cd=request->app_group_list[i].app_grp_code_value)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = "Unable to remove the old relationship"
     GO TO exit_script
    ENDIF
    SET old_cat_count = 0
    SELECT INTO "NL:"
     FROM br_app_cat_comp bacc
     WHERE bacc.category_id=old_cat_id
     ORDER BY sequence
     DETAIL
      old_cat_count = (old_cat_count+ 1), start = alterlist(old_cat->list,old_cat_count), old_cat->
      list[old_cat_count].application_group_cd = bacc.application_group_cd,
      old_cat->list[old_cat_count].sequence = old_cat_count
     WITH nocounter
    ;end select
    IF (old_cat_count > 0)
     UPDATE  FROM br_app_cat_comp bacc,
       (dummyt d  WITH seq = old_cat_count)
      SET bacc.seq = 1, bacc.sequence = old_cat->list[d.seq].sequence
      PLAN (d)
       JOIN (bacc
       WHERE (bacc.application_group_cd=old_cat->list[d.seq].application_group_cd))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = "Unable to resequence the old category"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF ((request->category_id > 0.0))
    SET sequence_num = 0
    SELECT INTO "NL:"
     count = count(*)
     FROM br_app_cat_comp bacc
     WHERE (bacc.category_id=request->category_id)
     FOOT REPORT
      sequence_num = (count+ 1)
     WITH nocounter
    ;end select
    INSERT  FROM br_app_cat_comp bacc
     SET bacc.category_id = request->category_id, bacc.application_group_cd = request->
      app_group_list[i].app_grp_code_value, bacc.sequence = sequence_num,
      bacc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bacc.updt_id = reqinfo->updt_id, bacc
      .updt_task = reqinfo->updt_task,
      bacc.updt_applctx = reqinfo->updt_applctx, bacc.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = "Unable to add the new relationship"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REASSIGN_APP_CATEGORY","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

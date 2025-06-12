CREATE PROGRAM bbd_chg_donor_unlock_corr:dba
 RECORD reply(
   1 results[1]
     2 status = c1
     2 person_id = f8
     2 unlock_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c200
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c200
 )
 DECLARE stat = i4 WITH protect, noconstant(alter(reply->results,request->unlock_count))
 DECLARE person_count = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE cur_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE text_id = f8 WITH protect, noconstant(0.0)
 DECLARE correct_donor_id_new = f8 WITH protect, noconstant(0.0)
 DECLARE text_success = i4 WITH protect, noconstant(0)
 DECLARE correction_type_cd_new = f8 WITH protect, noconstant(0.0)
 DECLARE success_count = i4 WITH protect, noconstant(0)
 DECLARE cv_cnt = i4 WITH protect, noconstant(1)
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14115,"DNRUNLOCK",cv_cnt,correction_type_cd_new)
 IF (correction_type_cd_new=0.0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_unlock_corr"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "correction_type_cd_new"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 FOR (person_count = 1 TO request->unlock_count)
  SELECT INTO "nl:"
   p.*
   FROM person_donor p
   PLAN (p
    WHERE (p.person_id=request->qual[person_count].person_id)
     AND (p.updt_cnt=request->qual[person_count].person_donor_updt_cnt)
     AND p.lock_ind=1)
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET reply->results[person_count].status = "F"
  ELSE
   UPDATE  FROM person_donor p
    SET p.lock_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (p
     WHERE (p.person_id=request->qual[person_count].person_id)
      AND (p.updt_cnt=request->qual[person_count].person_donor_updt_cnt)
      AND p.lock_ind=1)
    WITH nocounter
   ;end update
   IF (curqual=0)
    ROLLBACK
    SET reply->results[person_count].status = "F"
   ELSE
    SET text_id = 0.0
    SET text_success = 1
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET correct_donor_id_new = new_pathnet_seq
    IF ((request->qual[person_count].correction_text_ind=1))
     SELECT INTO "nl:"
      seqn = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       text_id = seqn
      WITH format, nocounter
     ;end select
     INSERT  FROM long_text lt
      SET lt.long_text_id = text_id, lt.parent_entity_name = "BBD_CORRECT_DONOR", lt.parent_entity_id
        = correct_donor_id_new,
       lt.long_text = request->qual[person_count].correction_text, lt.updt_cnt = 0, lt.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       lt.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET text_success = 0
     ENDIF
    ENDIF
    IF (text_success=0)
     ROLLBACK
     SET reply->results[person_count].status = "F"
    ELSE
     INSERT  FROM bbd_correct_donor b
      SET b.correct_donor_id = correct_donor_id_new, b.person_id = request->qual[person_count].
       person_id, b.correction_type_cd = correction_type_cd_new,
       b.correction_reason_cd = request->qual[person_count].correction_reason_cd, b
       .correction_text_id = text_id, b.eligibility_type_cd = 0,
       b.defer_until_dt_tm = null, b.lock_ind = 1, b.elig_for_reinstate_ind = null,
       b.reinstated_ind = null, b.reinstated_dt_tm = null, b.active_ind = 1,
       b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_cnt = 0,
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      ROLLBACK
      SET reply->results[person_count].status = "F"
     ELSE
      COMMIT
      SET reply->results[person_count].status = "S"
      SET success_count = (success_count+ 1)
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (success_count=0)
  SET reply->status_data.status = "F"
 ELSEIF ((success_count < request->unlock_count))
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

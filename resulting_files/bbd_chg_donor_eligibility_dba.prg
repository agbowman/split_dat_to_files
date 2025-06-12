CREATE PROGRAM bbd_chg_donor_eligibility:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c75
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE text_id = f8 WITH protect, noconstant(0.0)
 DECLARE correct_donor_id_new = f8 WITH protect, noconstant(0.0)
 DECLARE correction_type_cd_new = f8 WITH protect, noconstant(0.0)
 DECLARE cv_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE new_pathnet_seq = f8 WITH pr0tect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14115,"DNRELIG",cv_cnt,correction_type_cd_new)
 IF (correction_type_cd_new=0.0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_eligibility"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to read donation result correction type code value"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM person_donor p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->person_donor_updt_cnt))
  WITH nocounter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_eligibility"
  SET reply->status_data.subeventstatus[1].operationname = "lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_donor p
  SET p.lock_ind = 0, p.eligibility_type_cd =
   IF ((request->eligibility_type_cd_ind=1)) request->eligibility_type_cd
   ELSE p.eligibility_type_cd
   ENDIF
   , p.defer_until_dt_tm =
   IF ((request->defer_until_dt_tm_ind=1)) cnvtdatetime(request->defer_until_dt_tm)
   ELSE p.defer_until_dt_tm
   ENDIF
   ,
   p.elig_for_reinstate_ind =
   IF ((request->elig_for_reinstate_ind_chg=1)) request->elig_for_reinstate_ind
   ELSE p.elig_for_reinstate_ind
   ENDIF
   , p.reinstated_ind =
   IF ((request->reinstated_ind_chg=1)) request->reinstated_ind
   ELSE p.reinstated_ind
   ENDIF
   , p.reinstated_dt_tm =
   IF ((request->reinstated_dt_tm_ind=1)) cnvtdatetime(request->reinstated_dt_tm)
   ELSE p.reinstated_dt_tm
   ENDIF
   ,
   p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->
   updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->person_donor_updt_cnt))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_eligibility"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET text_id = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET correct_donor_id_new = new_pathnet_seq
 IF ((request->correction_text_ind=1))
  SELECT INTO "nl:"
   seqn = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    text_id = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM long_text lt
   SET lt.long_text_id = text_id, lt.parent_entity_name = "BBD_CORRECT_DONOR", lt.parent_entity_id =
    correct_donor_id_new,
    lt.long_text = request->correction_text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_eligibility"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long text id"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM bbd_correct_donor b
  SET b.correct_donor_id = correct_donor_id_new, b.person_id = request->person_id, b
   .correction_type_cd = correction_type_cd_new,
   b.correction_reason_cd = request->correction_reason_cd, b.correction_text_id = text_id, b
   .eligibility_type_cd =
   IF ((request->eligibility_type_cd_ind=1)) request->old_eligibility_type_cd
   ELSE 0
   ENDIF
   ,
   b.defer_until_dt_tm =
   IF ((request->defer_until_dt_tm_ind=1)) cnvtdatetime(request->old_defer_until_dt_tm)
   ELSE null
   ENDIF
   , b.lock_ind = null, b.elig_for_reinstate_ind =
   IF ((request->elig_for_reinstate_ind_chg=1))
    IF ((request->elig_for_reinstate_ind=1)) 0
    ELSE 1
    ENDIF
   ELSE - (1)
   ENDIF
   ,
   b.reinstated_ind =
   IF ((request->reinstated_ind_chg=1))
    IF ((request->reinstated_ind=1)) 0
    ELSE 1
    ENDIF
   ELSE - (1)
   ENDIF
   , b.reinstated_dt_tm =
   IF ((request->reinstated_dt_tm_ind=1)) cnvtdatetime(request->old_reinstated_dt_tm)
   ELSE null
   ENDIF
   , b.active_ind = 1,
   b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_cnt = 0,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_eligibility"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_correct_donor"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO

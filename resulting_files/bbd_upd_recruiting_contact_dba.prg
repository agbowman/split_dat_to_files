CREATE PROGRAM bbd_upd_recruiting_contact:dba
 RECORD reply(
   1 contact_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD donor(
   1 defer_dt_tm = di8
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE cdf_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE deferred_elig_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE temp_elig_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE good_elig_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new_eligibility_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE exist_eligibility_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new_contact_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_recruit_result_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_eligibility_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_deferral_reason_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_donation_result_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET code_set = 14237
 SET cdf_mean = "TEMP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,temp_elig_type_cd)
 SET cdf_mean = "GOOD"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,good_elig_type_cd)
 SET cdf_mean = "PERMNENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,deferred_elig_type_cd)
 IF ((((request->eligibility_type_mean="TEMPDEF")) OR ((request->eligibility_type_mean="FAILED"))) )
  SET new_eligibility_type_cd = temp_elig_type_cd
 ELSEIF ((((request->eligibility_type_mean="SUCCESS")) OR ((((request->eligibility_type_mean=
 "APPOINT")) OR ((((request->eligibility_type_mean="CALLBACK")) OR ((request->eligibility_type_mean=
 "ALERT"))) )) )) )
  SET new_eligibility_type_cd = good_elig_type_cd
 ELSEIF ((request->eligibility_type_mean="PERMDEF"))
  SET new_eligibility_type_cd = deferred_elig_type_cd
 ENDIF
 SET code_set = 14220
 SET cdf_mean = "RECRUIT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,type_cd)
 IF (((type_cd=0.0) OR (((temp_elig_type_cd=0.0) OR (((good_elig_type_cd=0.0) OR (
 deferred_elig_type_cd=0.0)) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Error retrieving eligibility_type_cd  (",type_cd,") from the code_value table")
  ELSEIF (temp_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Error retrieving temp eligibility_type_cd  (",temp_elig_type_cd,") from the code_value table")
  ELSEIF (good_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Error retrieving good eligibility_type_cd  (",good_elig_type_cd,") from the code_value table")
  ELSEIF (deferral_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Error retrieving deferal eligibility_type_cd  (",deferral_elig_type_cd,
    ") from the code_value table")
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dual"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error retrieving a new pathnet sequenced number."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET new_contact_id = new_pathnet_seq
 SET reply->contact_id = new_contact_id
 INSERT  FROM bbd_donor_contact dc
  SET dc.contact_id = new_contact_id, dc.person_id = request->person_id, dc.encntr_id = 0,
   dc.contact_type_cd = type_cd, dc.init_contact_prsnl_id = reqinfo->updt_id, dc.contact_outcome_cd
    = request->outcome_cd,
   dc.contact_dt_tm = cnvtdatetime(curdate,curtime3), dc.needed_dt_tm = null, dc.contact_status_cd =
   0,
   dc.owner_area_cd = 0, dc.inventory_area_cd = 0, dc.organization_id = 0,
   dc.active_ind = 1, dc.active_status_cd = reqdata->active_status_cd, dc.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dc.active_status_prsnl_id = reqinfo->updt_id, dc.updt_applctx = reqinfo->updt_applctx, dc
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dc.updt_id = reqinfo->updt_id, dc.updt_task = reqinfo->updt_task, dc.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting new information into the bbd_donor_contact table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
  GO TO exit_script
 ENDIF
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dual"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error retrieving a new pathnet sequenced number."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
  GO TO exit_script
 ENDIF
 SET new_recruit_result_id = new_pathnet_seq
 INSERT  FROM bbd_recruitment_rslts rr
  SET rr.recruit_result_id = new_recruit_result_id, rr.contact_id = new_contact_id, rr.person_id =
   request->person_id,
   rr.recruit_prsnl_id = reqinfo->updt_id, rr.outcome_cd = request->outcome_cd, rr.recruit_list_id =
   request->recruit_list_id,
   rr.active_ind = 1, rr.active_status_cd = reqdata->active_status_cd, rr.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   rr.active_status_prsnl_id = reqinfo->updt_id, rr.updt_applctx = reqinfo->updt_applctx, rr
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rr.updt_id = reqinfo->updt_id, rr.updt_task = reqinfo->updt_task, rr.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_recruitment_rslts"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting new information into the bbd_recruitment_rslts table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 4
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pd.*
  FROM person_donor pd
  WHERE (pd.person_id=request->person_id)
   AND (pd.updt_cnt=request->person_donor_updt_cnt)
  DETAIL
   exist_eligibility_type_cd = pd.eligibility_type_cd, donor->defer_dt_tm = pd.defer_until_dt_tm
  WITH nocounter, forupdate(pd)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error attempting to lock the person_donor table."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 5
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_donor p
  SET p.lock_ind = 0, p.eligibility_type_cd =
   IF (exist_eligibility_type_cd=deferred_elig_type_cd) exist_eligibility_type_cd
   ELSE
    IF (exist_eligibility_type_cd=good_elig_type_cd) new_eligibility_type_cd
    ELSE
     IF (exist_eligibility_type_cd=temp_elig_type_cd)
      IF (new_eligibility_type_cd=deferred_elig_type_cd) new_eligibility_type_cd
      ELSE exist_eligibility_type_cd
      ENDIF
     ELSE new_eligibility_type_cd
     ENDIF
    ENDIF
   ENDIF
   , p.defer_until_dt_tm =
   IF ((request->update_defer_until=1)
    AND exist_eligibility_type_cd != deferred_elig_type_cd)
    IF ((request->clear_defer_dt_tm_ind=1)) null
    ELSE
     IF ((donor->defer_dt_tm=null)) cnvtdatetime(request->eligible_dt_tm)
     ELSE
      IF (cnvtdatetime(request->eligible_dt_tm) > cnvtdatetime(donor->defer_dt_tm)) cnvtdatetime(
        request->eligible_dt_tm)
      ELSE cnvtdatetime(donor->defer_dt_tm)
      ENDIF
     ENDIF
    ENDIF
   ELSE cnvtdatetime(donor->defer_dt_tm)
   ENDIF
   ,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
   .updt_cnt+ 1),
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
  WHERE (p.person_id=request->person_id)
   AND (p.updt_cnt=request->person_donor_updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error updating the person_donor table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 6
  GO TO exit_script
 ENDIF
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dual"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error retrieving a new pathnet sequenced number."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 7
  GO TO exit_script
 ENDIF
 SET new_eligibility_id = new_pathnet_seq
 INSERT  FROM bbd_donor_eligibility b
  SET b.eligibility_id = new_eligibility_id, b.contact_id = new_contact_id, b.person_id = request->
   person_id,
   b.encntr_id = 0, b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd,
   b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
   updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.eligibility_type_cd = new_eligibility_type_cd, b
   .eligible_dt_tm = cnvtdatetime(request->eligible_dt_tm)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_eligibility"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting a new donor eligibility type."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 8
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO request->deferral_reasons_count)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status = "S"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].targetobjectname = "dual"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error retrieving a new pathnet sequenced number."
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 9
    GO TO exit_script
   ENDIF
   SET new_deferral_reason_id = new_pathnet_seq
   INSERT  FROM bbd_deferral_reason b
    SET b.deferral_reason_id = new_deferral_reason_id, b.eligibility_id = new_eligibility_id, b
     .person_id = request->person_id,
     b.contact_id = new_contact_id, b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd,
     b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
     updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.reason_cd = request->qual[x].reason_cd, b
     .eligible_dt_tm =
     IF (cnvtstring(request->qual[x].reason_eligible_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[x].reason_eligible_dt_tm)
     ENDIF
     ,
     b.occurred_dt_tm =
     IF (cnvtstring(request->qual[x].occurred_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[x].occurred_dt_tm)
     ENDIF
     , b.calc_elig_dt_tm =
     IF (cnvtstring(request->qual[x].calc_elig_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[x].calc_elig_dt_tm)
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_contact.prg"
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_deferral_reasons"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error inserting into the deferral reasons table."
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 10
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO

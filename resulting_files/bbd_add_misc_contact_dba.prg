CREATE PROGRAM bbd_add_misc_contact:dba
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
 DECLARE update_deferral_ind = i2
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cdf_meaning = fillstring(12," ")
 SET deferred_elig_type_cd = 0.0
 SET good_elig_type_cd = 0.0
 SET temp_elig_type_cd = 0.0
 SET contact_status_cd = 0.0
 SET eligibility_type_cd = 0.0
 SET exist_eligibility_type_cd = 0.0
 SET update_deferral_ind = 1
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,deferred_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,temp_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,good_elig_type_cd)
 IF (((deferred_elig_type_cd=0.0) OR (((temp_elig_type_cd=0.0) OR (good_elig_type_cd=0.0)) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (deferred_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read deferred eligibility type code value"
  ELSEIF (good_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read good donor status code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read temp donor status code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->contact_type_mean="COUNSEL"))
  SET code_value = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(14220,"COUNSEL",code_cnt,code_value)
  IF (code_value=0.0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "retrieve"
   SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "unable to retrieve code value for 14220 and COUNSEL"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  SET contact_status_cd = code_value
 ELSE
  SET code_value = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(14220,"OTHER",code_cnt,code_value)
  IF (code_value=0.0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "retrieve"
   SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "unable to retrieve code value for 14220 and OTHER"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  SET contact_status_cd = code_value
 ENDIF
 IF ((request->person_donor_ind=1))
  SET cv_cnt = 1
  IF ((request->eligibility_type_mean="FAILED"))
   SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="TEMPDEF"))
   SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="SUCCESS"))
   SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="APPOINT"))
   SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="CALLBACK"))
   SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="ALERT"))
   SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="PERMDEF"))
   SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="COUNRES"))
   SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
  ELSEIF ((request->eligibility_type_mean="RECFAIL"))
   SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
  ELSE
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "eligibility"
   SET reply->status_data.subeventstatus[1].targetobjectname = "meaning error"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  IF (eligibility_type_cd=0.0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "select"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET new_contact_id = new_pathnet_seq
 SET reply->contact_id = new_contact_id
 INSERT  FROM bbd_donor_contact dc
  SET dc.contact_id = new_pathnet_seq, dc.person_id = request->person_id, dc.encntr_id = 0,
   dc.active_ind = 1, dc.active_status_cd = reqdata->active_status_cd, dc.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dc.active_status_prsnl_id = reqinfo->updt_id, dc.updt_applctx = reqinfo->updt_applctx, dc
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dc.updt_id = reqinfo->updt_id, dc.updt_task = reqinfo->updt_task, dc.updt_cnt = 0,
   dc.contact_type_cd = contact_status_cd, dc.init_contact_prsnl_id = request->contact_prsnl_id, dc
   .contact_outcome_cd = request->outcome_cd,
   dc.contact_dt_tm = cnvtdatetime(request->contact_dt_tm)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd donor contact table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET new_other_contact_id = new_pathnet_seq
 INSERT  FROM bbd_other_contact oc
  SET oc.other_contact_id = new_pathnet_seq, oc.contact_id = new_contact_id, oc.person_id = request->
   person_id,
   oc.outcome_cd = request->outcome_cd, oc.contact_dt_tm = cnvtdatetime(request->contact_dt_tm), oc
   .contact_prsnl_id = request->contact_prsnl_id,
   oc.active_ind = 1, oc.active_status_cd = reqdata->active_status_cd, oc.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   oc.active_status_prsnl_id = reqinfo->updt_id, oc.updt_applctx = reqinfo->updt_applctx, oc
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_cnt = 0,
   oc.method_cd = request->method_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_other_contact"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_other_contact table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pd.*
  FROM person_donor pd
  PLAN (pd
   WHERE (pd.person_id=request->person_id)
    AND (pd.updt_cnt=request->person_donor_updt_cnt)
    AND pd.lock_ind=1)
  DETAIL
   exist_eligibility_type_cd = pd.eligibility_type_cd, update_deferral_ind = 0
   IF (datetimecmp(cnvtdatetime(request->defer_until_dt_tm),pd.defer_until_dt_tm) > 0)
    update_deferral_ind = 1
   ELSE
    update_deferral_ind = 0
   ENDIF
  WITH counter, forupdate(pd)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "lock"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_donor pd
  SET pd.lock_ind = 0, pd.eligibility_type_cd =
   IF ((request->person_donor_ind=1))
    IF (exist_eligibility_type_cd=deferred_elig_type_cd) exist_eligibility_type_cd
    ELSE
     IF (exist_eligibility_type_cd=good_elig_type_cd) eligibility_type_cd
     ELSE
      IF (exist_eligibility_type_cd=temp_elig_type_cd)
       IF (eligibility_type_cd=deferred_elig_type_cd) eligibility_type_cd
       ELSE exist_eligibility_type_cd
       ENDIF
      ELSE eligibility_type_cd
      ENDIF
     ENDIF
    ENDIF
   ELSE pd.eligibility_type_cd
   ENDIF
   , pd.defer_until_dt_tm =
   IF ((request->person_donor_ind=1)
    AND exist_eligibility_type_cd != deferred_elig_type_cd)
    IF (eligibility_type_cd=temp_elig_type_cd)
     IF (nullind(pd.defer_until_dt_tm)=1) cnvtdatetime(request->defer_until_dt_tm)
     ELSE
      IF (update_deferral_ind=1) cnvtdatetime(request->defer_until_dt_tm)
      ELSE pd.defer_until_dt_tm
      ENDIF
     ENDIF
    ELSE pd.defer_until_dt_tm
    ENDIF
   ELSE pd.defer_until_dt_tm
   ENDIF
   ,
   pd.updt_applctx = reqinfo->updt_applctx, pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_id = reqinfo->
   updt_id,
   pd.updt_task = reqinfo->updt_task, pd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE (pd.person_id=request->person_id)
   AND (pd.updt_cnt=request->person_donor_updt_cnt)
   AND pd.lock_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_donor update"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->person_donor_ind=1))
  DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
  SET new_pathnet_seq = 0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET new_eligibility_id = new_pathnet_seq
  INSERT  FROM bbd_donor_eligibility de
   SET de.eligibility_id = new_pathnet_seq, de.contact_id = new_contact_id, de.person_id = request->
    person_id,
    de.encntr_id = 0, de.active_ind = 1, de.active_status_cd = reqdata->active_status_cd,
    de.active_status_dt_tm = cnvtdatetime(curdate,curtime3), de.active_status_prsnl_id = reqinfo->
    updt_id, de.updt_applctx = reqinfo->updt_applctx,
    de.updt_dt_tm = cnvtdatetime(curdate,curtime3), de.updt_id = reqinfo->updt_id, de.updt_task =
    reqinfo->updt_task,
    de.updt_cnt = 0, de.eligibility_type_cd = eligibility_type_cd, de.eligible_dt_tm =
    IF ((request->deferral_reasons_ind=0)) null
    ELSE cnvtdatetime(request->defer_until_dt_tm)
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_eligibility"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd donor eligibility table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  IF ((request->deferral_reasons_ind=1))
   FOR (x = 1 TO request->deferral_reasons_count)
     DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
     SET new_pathnet_seq = 0
     SELECT INTO "nl:"
      seqn = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_pathnet_seq = seqn
      WITH format, nocounter
     ;end select
     SET new_deferral_reason_id = new_pathnet_seq
     INSERT  FROM bbd_deferral_reason dr
      SET dr.deferral_reason_id = new_pathnet_seq, dr.eligibility_id = new_eligibility_id, dr
       .contact_id = new_contact_id,
       dr.person_id = request->person_id, dr.active_ind = 1, dr.active_status_cd = reqdata->
       active_status_cd,
       dr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dr.active_status_prsnl_id = reqinfo->
       updt_id, dr.updt_applctx = reqinfo->updt_applctx,
       dr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dr.updt_id = reqinfo->updt_id, dr.updt_task =
       reqinfo->updt_task,
       dr.updt_cnt = 0, dr.reason_cd = request->qual[x].reason_cd, dr.eligible_dt_tm =
       IF (cnvtstring(request->qual[x].eligible_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[x].eligible_dt_tm)
       ENDIF
       ,
       dr.occurred_dt_tm =
       IF (cnvtstring(request->qual[x].occurred_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[x].occurred_dt_tm)
       ENDIF
       , dr.calc_elig_dt_tm =
       IF (cnvtstring(request->qual[x].calc_elig_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[x].calc_elig_dt_tm)
       ENDIF
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].operationname = "insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_deferral_reason"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd deferral reason table"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
      GO TO exit_script
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->add_contact_r_table=1))
  DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
  SET new_pathnet_seq = 0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET new_contact_reltn_id = new_pathnet_seq
  INSERT  FROM bbd_donor_contact_r dcr
   SET dcr.contact_reltn_id = new_pathnet_seq, dcr.contact_id = new_contact_id, dcr
    .related_contact_id = request->donor_contact_id,
    dcr.person_id = request->person_id, dcr.active_ind = 1, dcr.active_status_cd = reqdata->
    active_status_cd,
    dcr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dcr.active_status_prsnl_id = reqinfo->
    updt_id, dcr.updt_applctx = reqinfo->updt_applctx,
    dcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcr.updt_id = reqinfo->updt_id, dcr.updt_task =
    reqinfo->updt_task,
    dcr.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd donor contact r table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
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

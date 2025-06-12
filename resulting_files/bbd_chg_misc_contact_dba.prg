CREATE PROGRAM bbd_chg_misc_contact:dba
 RECORD reply(
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
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cdf_meaning = fillstring(12," ")
 SET reas_count = 0
 SET deferred_elig_type_cd = 0.0
 SET good_elig_type_cd = 0.0
 SET temp_elig_type_cd = 0.0
 SET contact_status_cd = 0.0
 SET eligibility_type_cd = 0.0
 SET exist_eligibility_type_cd = 0.0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,deferred_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,temp_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,good_elig_type_cd)
 IF ((request->contact_type_mean="COUNSEL"))
  SET code_value = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(14220,"COUNSEL",code_cnt,code_value)
  IF (code_value=0)
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
  IF (code_value=0)
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
 IF ((((request->add_donor_eligibility=1)) OR ((request->update_donor_eligibility=1))) )
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
  ELSE
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
   SET reply->status_data.subeventstatus[1].operationname = "eligibility"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "meaning error"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  IF (eligibility_type_cd=0.0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
   SET reply->status_data.subeventstatus[1].operationname = "select"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->update_donor_contact=1))
  SELECT INTO "nl:"
   dc.*
   FROM bbd_donor_contact dc
   PLAN (dc
    WHERE (dc.contact_id=request->donor_contact_id)
     AND (dc.updt_cnt=request->donor_contact_updt_cnt))
   WITH nocounter, forupdate(dc)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "contact_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor contact lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_donor_contact dc
   SET dc.contact_type_cd =
    IF ((request->contact_type_ind=1)) contact_status_cd
    ELSE dc.contact_type_cd
    ENDIF
    , dc.contact_outcome_cd =
    IF ((request->outcome_ind=1)) request->outcome_cd
    ELSE dc.contact_outcome_cd
    ENDIF
    , dc.contact_dt_tm =
    IF ((request->contact_dt_tm_ind=1)) cnvtdatetime(request->contact_dt_tm)
    ELSE dc.contact_dt_tm
    ENDIF
    ,
    dc.updt_applctx = reqinfo->updt_applctx, dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc
    .updt_id = reqinfo->updt_id,
    dc.updt_task = reqinfo->updt_task, dc.updt_cnt = (dc.updt_cnt+ 1)
   WHERE (dc.contact_id=request->donor_contact_id)
    AND (dc.updt_cnt=request->donor_contact_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd donor contact table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->update_other_contact=1))
  SELECT INTO "nl:"
   oc.*
   FROM bbd_other_contact oc
   PLAN (oc
    WHERE (oc.contact_id=request->donor_contact_id)
     AND (oc.updt_cnt=request->other_contact_updt_cnt))
   WITH nocounter, forupdate(oc)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "contact_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor other contact lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_other_contact oc
   SET oc.outcome_cd =
    IF ((request->outcome_ind=1)) request->outcome_cd
    ELSE oc.outcome_cd
    ENDIF
    , oc.contact_dt_tm =
    IF ((request->contact_dt_tm_ind=1)) cnvtdatetime(request->contact_dt_tm)
    ELSE oc.contact_dt_tm
    ENDIF
    , oc.contact_prsnl_id =
    IF ((request->contact_prsnl_ind=1)) request->contact_prsnl_id
    ELSE oc.contact_prsnl_id
    ENDIF
    ,
    oc.method_cd =
    IF ((request->method_ind=1)) request->method_cd
    ELSE oc.method_cd
    ENDIF
    , oc.updt_applctx = reqinfo->updt_applctx, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1)
   WHERE (oc.contact_id=request->donor_contact_id)
    AND (oc.updt_cnt=request->other_contact_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_other_contact"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_other_contact table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pd.*
  FROM person_donor pd
  PLAN (pd
   WHERE (pd.person_id=request->person_id)
    AND (pd.updt_cnt=request->person_donor_updt_cnt)
    AND pd.lock_ind=1)
  DETAIL
   exist_eligibility_type_cd = pd.eligibility_type_cd
  WITH counter, forupdate(pd)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
  SET reply->status_data.subeventstatus[1].operationname = "lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_donor pd
  SET pd.lock_ind = 0, pd.eligibility_type_cd =
   IF ((request->eligibility_type_mean_ind=1))
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
   IF ((request->defer_until_dt_tm_ind=1)
    AND exist_eligibility_type_cd != deferred_elig_type_cd)
    IF (cnvtdatetime(request->defer_until_dt_tm) > cnvtdatetime(pd.defer_until_dt_tm)) cnvtdatetime(
      request->defer_until_dt_tm)
    ELSE pd.defer_until_dt_tm
    ENDIF
   ELSE pd.defer_until_dt_tm
   ENDIF
   ,
   pd.updt_applctx = reqinfo->updt_applctx, pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_id = reqinfo->
   updt_id,
   pd.updt_task = reqinfo->updt_task, pd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (pd
   WHERE (pd.person_id=request->person_id)
    AND (pd.updt_cnt=request->person_donor_updt_cnt)
    AND pd.lock_ind=1)
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
 IF ((request->add_donor_eligibility=1))
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
   SET de.eligibility_id = new_pathnet_seq, de.contact_id = request->donor_contact_id, de.person_id
     = request->person_id,
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
   FOR (x = 1 TO request->reasons_count)
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
       .contact_id = request->donor_contact_id,
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
 IF ((request->update_donor_eligibility=1))
  SELECT INTO "nl:"
   de.*
   FROM bbd_donor_eligibility de
   PLAN (de
    WHERE (de.eligibility_id=request->eligibility_id)
     AND (de.updt_cnt=request->eligibility_updt_cnt))
   WITH nocounter, forupdate(de)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "eligibility"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_donor_eligibility"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_donor_eligibility de
   SET de.updt_applctx = reqinfo->updt_applctx, de.updt_dt_tm = cnvtdatetime(curdate,curtime3), de
    .updt_id = reqinfo->updt_id,
    de.updt_task = reqinfo->updt_task, de.updt_cnt = (de.updt_cnt+ 1), de.eligibility_type_cd =
    IF ((request->eligibility_type_mean_ind=1)) eligibility_type_cd
    ELSE de.eligibility_type_cd
    ENDIF
    ,
    de.eligible_dt_tm =
    IF ((request->defer_until_dt_tm_ind=1))
     IF (cnvtdatetime(request->defer_until_dt_tm) > cnvtdatetime(de.eligible_dt_tm)) cnvtdatetime(
       request->defer_until_dt_tm)
     ELSE de.eligible_dt_tm
     ENDIF
    ELSE de.eligible_dt_tm
    ENDIF
   PLAN (de
    WHERE (de.eligibility_id=request->eligibility_id)
     AND (de.updt_cnt=request->eligibility_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_eligibility"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd donor eligibility table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  FOR (reas_count = 1 TO request->reasons_count)
    IF ((request->qual[reas_count].add_indicator=1))
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
     INSERT  FROM bbd_deferral_reason b
      SET b.deferral_reason_id = new_pathnet_seq, b.eligibility_id = request->eligibility_id, b
       .contact_id = request->donor_contact_id,
       b.person_id = request->person_id, b.active_ind = 1, b.active_status_cd = reqdata->
       active_status_cd,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
       updt_id, b.updt_applctx = reqinfo->updt_applctx,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_cnt = 0, b.reason_cd = request->qual[reas_count].reason_cd, b.eligible_dt_tm =
       IF (cnvtstring(request->qual[reas_count].eligible_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[reas_count].eligible_dt_tm)
       ENDIF
       ,
       b.occurred_dt_tm =
       IF (cnvtstring(request->qual[reas_count].occurred_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[reas_count].occurred_dt_tm)
       ENDIF
       , b.calc_elig_dt_tm =
       IF (cnvtstring(request->qual[reas_count].calc_elig_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[reas_count].calc_elig_dt_tm)
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
     ELSE
      SET request->qual[reas_count].deferral_reason_id = new_deferral_reason_id
     ENDIF
    ELSEIF ((request->qual[reas_count].add_indicator=2))
     SELECT INTO "nl:"
      b.*
      FROM bbd_deferral_reason b
      PLAN (b
       WHERE (b.deferral_reason_id=request->qual[reas_count].deferral_reason_id)
        AND (b.updt_cnt=request->qual[reas_count].updt_cnt))
      WITH nocounter, forupdate(b)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
      SET reply->status_data.subeventstatus[1].operationname = "lock1"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons lock"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = reas_count
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
     UPDATE  FROM bbd_deferral_reason b
      SET b.reason_cd = request->qual[reas_count].reason_cd, b.eligible_dt_tm =
       IF (cnvtstring(request->qual[reas_count].eligible_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[reas_count].eligible_dt_tm)
       ENDIF
       , b.occurred_dt_tm =
       IF (cnvtstring(request->qual[reas_count].occurred_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[reas_count].occurred_dt_tm)
       ENDIF
       ,
       b.calc_elig_dt_tm =
       IF (cnvtstring(request->qual[reas_count].calc_elig_dt_tm)="-1") null
       ELSE cnvtdatetime(request->qual[reas_count].calc_elig_dt_tm)
       ENDIF
       , b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
       updt_applctx
      PLAN (b
       WHERE (b.deferral_reason_id=request->qual[reas_count].deferral_reason_id)
        AND (b.updt_cnt=request->qual[reas_count].updt_cnt))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
      SET reply->status_data.subeventstatus[1].operationname = "update"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = reas_count
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
    ELSE
     SELECT INTO "nl:"
      b.*
      FROM bbd_deferral_reason b
      PLAN (b
       WHERE (b.deferral_reason_id=request->qual[reas_count].deferral_reason_id)
        AND (b.updt_cnt=request->qual[reas_count].updt_cnt))
      WITH nocounter, forupdate(b)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
      SET reply->status_data.subeventstatus[1].operationname = "lock2"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons lock"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = reas_count
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
     UPDATE  FROM bbd_deferral_reason b
      SET b.active_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
       updt_id,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
       updt_applctx
      PLAN (b
       WHERE (b.deferral_reason_id=request->qual[reas_count].deferral_reason_id)
        AND (b.updt_cnt=request->qual[reas_count].updt_cnt))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_misc_contact"
      SET reply->status_data.subeventstatus[1].operationname = "inactivate"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = reas_count
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
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

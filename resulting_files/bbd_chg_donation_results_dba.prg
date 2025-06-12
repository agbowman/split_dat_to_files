CREATE PROGRAM bbd_chg_donation_results:dba
 RECORD reply(
   1 product_id = f8
   1 quar_status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c150
       3 sub_event_dt_tm = di8
 )
 DECLARE gsub_product_event_status = c2 WITH protect, noconstant("  ")
 RECORD donation_rec(
   1 latest_drawn_dt_tm = dq8
 )
 DECLARE deferral_reason_id_new = f8 WITH protect, noconstant(0.0)
 RECORD person_donor_rec(
   1 exist_eligibility_type_cd = f8
   1 exist_defer_until_dt_tm = dq8
   1 last_donation_dt_tm = dq8
 )
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE text_id = f8 WITH protect, noconstant(0.0)
 DECLARE reas_count = i4 WITH protect, noconstant(0)
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 DECLARE product_id_new = f8 WITH protect, noconstant(0.0)
 DECLARE product_event_id_new = f8 WITH protect, noconstant(0.0)
 DECLARE product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE correction_type_cd_new = f8 WITH protect, noconstant(0.0)
 DECLARE contributor_system = f8 WITH protect, noconstant(0.0)
 DECLARE data_status_cd_new = f8 WITH protect, noconstant(0.0)
 DECLARE donation_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE autologous_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE directed_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE quarantined_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE person_reltn_type_cd_new = f8 WITH protect, noconstant(0.0)
 DECLARE eligibility_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE deferred_elig_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE good_elig_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE temp_elig_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE exist_eligibility_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE correct_donor_id = f8 WITH protect, noconstant(0.0)
 DECLARE text_success = i4 WITH protect, noconstant(0)
 DECLARE cv_cnt = i4 WITH protect, noconstant(1)
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",cv_cnt,data_status_cd_new)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(351,"BBRECIPIENT",cv_cnt,person_reltn_type_cd_new)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,deferred_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,good_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,temp_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"20",cv_cnt,donation_event_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"10",cv_cnt,autologous_event_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"11",cv_cnt,directed_event_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"2",cv_cnt,quarantined_event_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14115,"DNRRESULTS",cv_cnt,correction_type_cd_new)
 IF (((data_status_cd_new=0.0) OR (((person_reltn_type_cd_new=0.0) OR (((deferred_elig_type_cd=0.0)
  OR (((temp_elig_type_cd=0.0) OR (((good_elig_type_cd=0.0) OR (((donation_event_type_cd=0.0) OR (((
 autologous_event_type_cd=0.0) OR (((correction_type_cd_new=0.0) OR (((directed_event_type_cd=0.0)
  OR (quarantined_event_type_cd=0.0)) )) )) )) )) )) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (data_status_cd_new=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read data status code value"
  ELSEIF (person_reltn_type_cd_new=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read person relation type code value"
  ELSEIF (deferred_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read deferred eligibility type code value"
  ELSEIF (donation_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read donation event type code value"
  ELSEIF (correction_type_cd_new=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read donation result correction type code value"
  ELSEIF (autologous_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read autlogous event type code value"
  ELSEIF (good_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read good donor status code value"
  ELSEIF (temp_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read temp donor status code value"
  ELSEIF (quarantined_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read quarantined event type code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read directed event type code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET cv_cnt = 1
 IF ((request->eligibility_type_mean="FAILED"))
  SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,eligibility_type_cd)
 ELSEIF ((request->eligibility_type_mean="TEMPDEF"))
  SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,eligibility_type_cd)
 ELSEIF ((request->eligibility_type_mean="SUCCESS"))
  SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd)
 ELSEIF ((request->eligibility_type_mean="PERMDEF"))
  SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,eligibility_type_cd)
 ELSE
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
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
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(89,"CERNER",cv_cnt,contributor_system)
 IF ((((request->updt_contact_table=1)) OR ((request->drawn_dt_tm_ind=1))) )
  SELECT INTO "nl:"
   b.*
   FROM bbd_donor_contact b
   PLAN (b
    WHERE (b.contact_id=request->contact_id)
     AND (b.updt_cnt=request->contact_updt_cnt))
   WITH nocounter, forupdate(b)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "contact_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor contact lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_donor_contact b
   SET b.needed_dt_tm =
    IF ((request->update_needed_dt_tm=1)) cnvtdatetime(request->needed_dt_tm)
    ELSE b.needed_dt_tm
    ENDIF
    , b.contact_dt_tm =
    IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(request->drawn_dt_tm)
    ELSE b.contact_dt_tm
    ENDIF
    , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   WHERE (b.contact_id=request->contact_id)
    AND (b.updt_cnt=request->contact_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor contact table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->update_donor_eligibility=1))
  SELECT INTO "nl:"
   b.*
   FROM bbd_donor_eligibility b
   PLAN (b
    WHERE (b.eligibility_id=request->eligibility_id)
     AND (b.updt_cnt=request->eligibility_updt_cnt))
   WITH nocounter, forupdate(b)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "eligibility"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_donor_eligibility"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_donor_eligibility b
   SET b.eligibility_type_cd =
    IF ((request->eligibility_type_mean_ind=1)) eligibility_type_cd
    ELSE b.eligibility_type_cd
    ENDIF
    , b.eligible_dt_tm =
    IF ((request->defer_until_dt_tm_ind=1))
     IF (cnvtdatetime(request->defer_until_dt_tm) > cnvtdatetime(b.eligible_dt_tm)) cnvtdatetime(
       request->defer_until_dt_tm)
     ELSE b.eligible_dt_tm
     ENDIF
    ELSE b.eligible_dt_tm
    ENDIF
    , b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   PLAN (b
    WHERE (b.eligibility_id=request->eligibility_id)
     AND (b.updt_cnt=request->eligibility_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_donor_eligibility"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET correct_donor_id = new_pathnet_seq
 SET text_id = 0.0
 SET text_success = 1
 IF ((request->correction_text_ind=1))
  SELECT INTO "nl:"
   seqn = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    text_id = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM long_text lt
   SET lt.long_text_id = text_id, lt.parent_entity_name = "BBD_CORRECT_DON_RSLTS", lt
    .parent_entity_id = correct_donor_id,
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
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long text id"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->update_donation_result_table=1))
  SELECT INTO "nl:"
   b.*
   FROM bbd_donation_results b
   PLAN (b
    WHERE (b.donation_result_id=request->donation_result_id)
     AND (b.updt_cnt=request->donation_result_updt_cnt))
   WITH nocounter, forupdate(b)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "donation results lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_donation_results b
   SET b.drawn_dt_tm =
    IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(request->drawn_dt_tm)
    ELSE b.drawn_dt_tm
    ENDIF
    , b.start_dt_tm =
    IF ((request->start_dt_tm_ind=1)) cnvtdatetime(request->start_dt_tm)
    ELSE b.start_dt_tm
    ENDIF
    , b.stop_dt_tm =
    IF ((request->stop_dt_tm_ind=1)) cnvtdatetime(request->stop_dt_tm)
    ELSE b.stop_dt_tm
    ENDIF
    ,
    b.procedure_cd =
    IF ((request->procedure_cd_ind=1)) request->procedure_cd
    ELSE b.procedure_cd
    ENDIF
    , b.venipuncture_site_cd =
    IF ((request->venipuncture_cd_ind=1)) request->venipuncture_cd
    ELSE b.venipuncture_site_cd
    ENDIF
    , b.bag_type_cd =
    IF ((request->bag_type_cd_ind=1)) request->bag_type_cd
    ELSE b.bag_type_cd
    ENDIF
    ,
    b.phleb_prsnl_id =
    IF ((request->phleb_prsnl_id_ind=1)) request->phleb_prsnl_id
    ELSE b.phleb_prsnl_id
    ENDIF
    , b.outcome_cd =
    IF ((request->outcome_cd_ind=1)) request->outcome_cd
    ELSE b.outcome_cd
    ENDIF
    , b.specimen_volume =
    IF ((request->specimen_volume_ind=1)) request->specimen_volume
    ELSE b.specimen_volume
    ENDIF
    ,
    b.total_volume =
    IF ((((request->specimen_volume_ind=1)) OR ((request->cur_volume_ind=1))) ) (request->cur_volume
     + request->specimen_volume)
    ELSE b.total_volume
    ENDIF
    , b.specimen_unit_meas_cd =
    IF ((request->spec_unit_of_meas_cd_ind=1)) request->spec_unit_of_meas_cd
    ELSE b.specimen_unit_meas_cd
    ENDIF
    , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   PLAN (b
    WHERE (b.donation_result_id=request->donation_result_id)
     AND (b.updt_cnt=request->donation_result_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_donation_results"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->drawn_dt_tm_ind=1))
  SELECT INTO "nl:"
   FROM bbd_donation_results bdr
   WHERE (bdr.person_id=request->person_id)
   ORDER BY bdr.drawn_dt_tm DESC
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt=1)
     donation_rec->latest_drawn_dt_tm = bdr.drawn_dt_tm
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM person_donor p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->person_donor_updt_cnt)
    AND p.lock_ind=1)
  DETAIL
   person_donor_rec->exist_eligibility_type_cd = p.eligibility_type_cd, person_donor_rec->
   exist_defer_until_dt_tm = cnvtdatetime(p.defer_until_dt_tm), person_donor_rec->last_donation_dt_tm
    = cnvtdatetime(p.last_donation_dt_tm)
  WITH nocounter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = concat("lock ",request->
   person_donor_updt_cnt,p.updt_cnt)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_donor p
  SET p.eligibility_type_cd =
   IF ((request->eligibility_type_mean_ind=1))
    IF ((person_donor_rec->exist_eligibility_type_cd=deferred_elig_type_cd)) person_donor_rec->
     exist_eligibility_type_cd
    ELSE
     IF ((person_donor_rec->exist_eligibility_type_cd=temp_elig_type_cd)
      AND eligibility_type_cd=good_elig_type_cd) person_donor_rec->exist_eligibility_type_cd
     ELSE eligibility_type_cd
     ENDIF
    ENDIF
   ELSE p.eligibility_type_cd
   ENDIF
   , p.defer_until_dt_tm =
   IF ((request->defer_until_dt_tm_ind=1)
    AND (person_donor_rec->exist_eligibility_type_cd != deferred_elig_type_cd))
    IF (cnvtdatetime(request->defer_until_dt_tm) > cnvtdatetime(person_donor_rec->
     exist_defer_until_dt_tm)) cnvtdatetime(request->defer_until_dt_tm)
    ELSE p.defer_until_dt_tm
    ENDIF
   ELSE p.defer_until_dt_tm
   ENDIF
   , p.donation_level =
   IF ((request->update_don_level_ind=1)) (p.donation_level+ request->per_volume_level)
   ELSE p.donation_level
   ENDIF
   ,
   p.last_donation_dt_tm =
   IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(donation_rec->latest_drawn_dt_tm)
   ELSE p.last_donation_dt_tm
   ENDIF
   , p.lock_ind = 0, p.updt_cnt = (p.updt_cnt+ 1),
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo
   ->updt_task,
   p.updt_applctx = reqinfo->updt_applctx
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->person_donor_updt_cnt))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 INSERT  FROM bbd_correct_don_rslts b
  SET b.correct_don_result_id = correct_donor_id, b.encntr_person_reltn_id =
   IF ((request->inactivate_encntr_person_reltn=1)) request->encntr_person_reltn_id
   ELSE 0
   ENDIF
   , b.needed_dt_tm =
   IF ((request->update_needed_dt_tm=1)) cnvtdatetime(request->old_needed_dt_tm)
   ELSE null
   ENDIF
   ,
   b.recipient_reltn_cd = request->related_person_reltn_cd, b.donation_result_id = request->
   donation_result_id, b.contact_id = request->contact_id,
   b.person_id = request->person_id, b.correction_type_cd = correction_type_cd_new, b
   .correction_reason_cd = request->correction_reason_cd,
   b.correction_text_id = text_id, b.drawn_dt_tm =
   IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(request->old_drawn_dt_tm)
   ELSE null
   ENDIF
   , b.procedure_type_cd =
   IF ((request->procedure_cd_ind=1)) request->old_procedure_cd
   ELSE 0
   ENDIF
   ,
   b.phleb_prsnl_id =
   IF ((request->phleb_prsnl_id_ind=1)) request->old_phleb_prsnl_id
   ELSE 0
   ENDIF
   , b.start_dt_tm =
   IF ((request->start_dt_tm_ind=1)) cnvtdatetime(request->old_start_dt_tm)
   ELSE null
   ENDIF
   , b.stop_dt_tm =
   IF ((request->stop_dt_tm_ind=1)) cnvtdatetime(request->old_stop_dt_tm)
   ELSE null
   ENDIF
   ,
   b.venipuncture_site_cd =
   IF ((request->venipuncture_cd_ind=1)) request->old_venipuncture_cd
   ELSE 0
   ENDIF
   , b.outcome_cd =
   IF ((request->outcome_cd_ind=1)) request->old_outcome_cd
   ELSE 0
   ENDIF
   , b.bag_type_cd =
   IF ((request->bag_type_cd_ind=1)) request->old_bag_type_cd
   ELSE 0
   ENDIF
   ,
   b.specimen_volume =
   IF ((request->specimen_volume_ind=1)) request->old_specimen_volume
   ELSE - (1)
   ENDIF
   , b.total_drawn =
   IF ((((request->specimen_volume_ind=1)) OR ((request->cur_volume_ind=1))) ) (request->
    old_cur_volume+ request->old_specimen_volume)
   ELSE 0
   ENDIF
   , b.facility_cd =
   IF ((request->facility_cd_ind=1)) request->old_facility_cd
   ELSE 0.0
   ENDIF
   ,
   b.building_cd =
   IF ((request->building_cd_ind=1)) request->old_building_cd
   ELSE 0.0
   ENDIF
   , b.ambulatory_cd =
   IF ((request->ambulatory_cd_ind=1)) request->old_ambulatory_cd
   ELSE 0.0
   ENDIF
   , b.room_cd =
   IF ((request->room_cd_ind=1)) request->old_room_cd
   ELSE 0.0
   ENDIF
   ,
   b.bed_cd =
   IF ((request->bed_cd_ind=1)) request->old_bed_cd
   ELSE 0.0
   ENDIF
   , b.specimen_unit_meas_cd =
   IF ((request->spec_unit_of_meas_cd_ind=1)) request->old_spec_unit_of_meas_cd
   ELSE 0
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
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_correct_don_rslts"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 FOR (reas_count = 1 TO request->reasons_count)
   IF ((request->qual[reas_count].add_indicator=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET deferral_reason_id_new = new_pathnet_seq
    INSERT  FROM bbd_deferral_reason b
     SET b.contact_id = request->contact_id, b.deferral_reason_id = deferral_reason_id_new, b
      .eligibility_id = request->eligibility_id,
      b.person_id = request->person_id, b.active_ind = 1, b.active_status_cd = reqdata->
      active_status_cd,
      b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
      updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.reason_cd = request->qual[reas_count].reason_cd, b
      .eligible_dt_tm =
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
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_deferral_reasons"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons table"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET request->qual[reas_count].deferral_reason_id = deferral_reason_id_new
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
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
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
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
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
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
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
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
     SET reply->status_data.subeventstatus[1].operationname = "inactivate"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = reas_count
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
   ENDIF
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET deferral_reason_id_new = new_pathnet_seq
   INSERT  FROM bbd_correct_def_reason b
    SET b.correct_def_reason_id = deferral_reason_id_new, b.correct_don_result_id = correct_donor_id,
     b.deferral_reason_id = request->qual[reas_count].deferral_reason_id,
     b.reason_cd = request->qual[reas_count].reason_cd, b.add_remove_ind =
     IF ((request->qual[reas_count].add_indicator=1)) 1
     ELSE 0
     ENDIF
     , b.eligible_dt_tm =
     IF (cnvtstring(request->qual[reas_count].old_eligible_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[reas_count].old_eligible_dt_tm)
     ENDIF
     ,
     b.occurred_dt_tm =
     IF (cnvtstring(request->qual[reas_count].old_occurred_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[reas_count].old_occurred_dt_tm)
     ENDIF
     , b.calc_dt_tm =
     IF (cnvtstring(request->qual[reas_count].old_calc_elig_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[reas_count].old_calc_elig_dt_tm)
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
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_correct_def_reason"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "correct def reasons table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
 ENDFOR
 IF ((request->update_product_table=1))
  SELECT INTO "nl:"
   p.*
   FROM product p
   PLAN (p
    WHERE (p.product_id=request->product_id)
     AND (p.updt_cnt=request->product_updt_cnt))
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM product p
   SET p.product_cd =
    IF ((request->product_cd_ind=1)) request->product_cd
    ELSE p.product_cd
    ENDIF
    , p.product_cat_cd =
    IF ((request->product_cat_cd_ind=1)) request->product_cat_cd
    ELSE p.product_cat_cd
    ENDIF
    , p.product_class_cd =
    IF ((request->product_class_cd_ind=1)) request->product_class_cd
    ELSE p.product_class_cd
    ENDIF
    ,
    p.product_nbr =
    IF ((request->product_nbr_ind=1)) request->product_nbr
    ELSE p.product_nbr
    ENDIF
    , p.cur_inv_locn_cd =
    IF ((request->cur_inv_locn_cd_ind=1)) request->cur_inv_locn_cd
    ELSE p.cur_inv_locn_cd
    ENDIF
    , p.orig_inv_locn_cd =
    IF (p.orig_inv_locn_cd=0) request->old_cur_inv_locn_cd
    ELSE p.orig_inv_locn_cd
    ENDIF
    ,
    p.cur_unit_meas_cd =
    IF ((request->cur_unit_of_meas_cd_ind=1)) request->cur_unit_of_meas_cd
    ELSE p.cur_unit_meas_cd
    ENDIF
    , p.orig_unit_meas_cd =
    IF (p.orig_unit_meas_cd=0) request->old_cur_unit_of_meas_cd
    ELSE p.orig_unit_meas_cd
    ENDIF
    , p.cur_expire_dt_tm =
    IF ((request->cur_expire_dt_tm_ind=1)) cnvtdatetime(request->cur_expire_dt_tm)
    ELSE p.cur_expire_dt_tm
    ENDIF
    ,
    p.cur_owner_area_cd =
    IF ((request->cur_owner_area_cd_ind=1)) request->cur_owner_area_cd
    ELSE p.cur_owner_area_cd
    ENDIF
    , p.cur_inv_area_cd =
    IF ((request->cur_inv_area_cd_ind=1)) request->cur_inv_area_cd
    ELSE p.cur_inv_area_cd
    ENDIF
    , p.corrected_ind = request->product_corrected_ind,
    p.disease_cd = request->disease_cd, p.donation_type_cd = request->donation_type_cd, p
    .cur_supplier_id = request->cur_supplier_id,
    p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx
   PLAN (p
    WHERE (p.product_id=request->product_id)
     AND (p.updt_cnt=request->product_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->update_blood_product_table=1))
  SELECT INTO "nl:"
   bp.*
   FROM blood_product bp
   PLAN (bp
    WHERE (bp.product_id=request->product_id)
     AND (bp.updt_cnt=request->blood_product_updt_cnt))
   WITH nocounter, forupdate(bp)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "blood product lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM blood_product bp
   SET bp.product_cd =
    IF ((request->product_cd_ind=1)) request->product_cd
    ELSE bp.product_cd
    ENDIF
    , bp.cur_volume =
    IF ((request->cur_volume_ind=1)) request->cur_volume
    ELSE bp.cur_volume
    ENDIF
    , bp.segment_nbr =
    IF ((request->segment_nbr_ind=1)) request->segment_nbr
    ELSE bp.segment_nbr
    ENDIF
    ,
    bp.lot_nbr =
    IF ((request->lot_nbr_ind=1)) request->lot_nbr
    ELSE bp.lot_nbr
    ENDIF
    , bp.autologous_ind = request->autologous_ind, bp.directed_ind = request->directed_ind,
    bp.drawn_dt_tm = cnvtdatetime(request->drawn_dt_tm), bp.updt_cnt = (bp.updt_cnt+ 1), bp
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->
    updt_applctx
   PLAN (bp
    WHERE (bp.product_id=request->product_id)
     AND (bp.updt_cnt=request->blood_product_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "blood product"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->product_corrected_ind=1))
  SET new_pathnet_seq = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET corr_id = new_pathnet_seq
  INSERT  FROM corrected_product cp
   SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.correction_type_cd =
    correction_type_cd_new,
    cp.correction_reason_cd = request->correction_reason_cd, cp.product_nbr =
    IF ((request->product_nbr_ind=1)) request->old_product_nbr
    ELSE null
    ENDIF
    , cp.product_sub_nbr = null,
    cp.alternate_nbr = null, cp.product_cd =
    IF ((request->product_cd_ind=1)) request->old_product_cd
    ELSE 0
    ENDIF
    , cp.product_class_cd =
    IF ((request->product_class_cd_ind=1)) request->old_product_class_cd
    ELSE 0
    ENDIF
    ,
    cp.product_cat_cd =
    IF ((request->product_cat_cd=1)) request->old_product_cat_cd
    ELSE 0
    ENDIF
    , cp.supplier_id = 0, cp.recv_dt_tm = null,
    cp.volume =
    IF ((request->cur_volume_ind=1)) request->old_cur_volume
    ELSE 0
    ENDIF
    , cp.unit_meas_cd =
    IF ((request->cur_unit_of_meas_cd_ind=1)) request->old_cur_unit_of_meas_cd
    ELSE 0
    ENDIF
    , cp.expire_dt_tm =
    IF ((request->cur_expire_dt_tm_ind=1)) cnvtdatetime(request->old_cur_expire_dt_tm)
    ELSE cnvtdatetime("")
    ENDIF
    ,
    cp.abo_cd = 0, cp.rh_cd = 0, cp.segment_nbr =
    IF ((request->segment_nbr_ind=1)) request->old_segment_nbr
    ELSE null
    ENDIF
    ,
    cp.orig_updt_cnt = request->product_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(request->
     prod_updt_dt_tm), cp.orig_updt_id = request->prod_updt_id,
    cp.orig_updt_task = request->prod_updt_task, cp.orig_updt_applctx = request->prod_updt_applctx,
    cp.correction_note = request->correction_text,
    cp.product_event_id = 0, cp.event_dt_tm = cnvtdatetime(""), cp.reason_cd = 0,
    cp.autoclave_ind = null, cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
    cp.manifest_nbr = null, cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
    updt_applctx,
    cp.person_id = request->person_id, cp.encntr_id = request->encntr_id, cp.expected_usage_dt_tm =
    cnvtdatetime(""),
    cp.cur_owner_area_cd =
    IF ((request->cur_owner_area_cd_ind=1)) request->old_cur_owner_area_cd
    ELSE 0
    ENDIF
    , cp.cur_inv_area_cd =
    IF ((request->cur_inv_area_cd_ind=1)) request->old_cur_inv_area_cd
    ELSE 0
    ENDIF
    , cp.donation_type_cd = request->old_donation_type_cd,
    cp.disease_cd = request->old_disease_cd, cp.orig_lot_nbr = request->old_lot_nbr
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "corrected_product"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_product_ind=1))
  SET seqnbr = 0.0
  SELECT INTO "nl:"
   snbr = seq(blood_bank_seq,nextval)
   FROM dual
   DETAIL
    seqnbr = snbr
   WITH format, counter
  ;end select
  SET product_id_new = seqnbr
  INSERT  FROM product p
   SET p.product_id = product_id_new, p.product_cd = request->product_cd, p.product_cat_cd = request
    ->product_cat_cd,
    p.product_class_cd = request->product_class_cd, p.product_nbr = cnvtupper(request->product_nbr),
    p.product_sub_nbr = null,
    p.alternate_nbr = null, p.pooled_product_id = 0, p.modified_product_id = 0,
    p.locked_ind = 0, p.cur_inv_locn_cd = 0, p.orig_inv_locn_cd = 0,
    p.recv_dt_tm = null, p.recv_prsnl_id = 0, p.orig_ship_cond_cd = 0,
    p.orig_vis_insp_cd = 0, p.storage_temp_cd = 0, p.cur_unit_meas_cd = request->cur_unit_of_meas_cd,
    p.orig_unit_meas_cd = request->cur_unit_of_meas_cd, p.pooled_product_ind = 0, p
    .modified_product_ind = 0,
    p.donated_by_relative_ind = 0, p.corrected_ind = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.active_ind = 1, p.active_status_cd = reqdata->
    active_status_cd,
    p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
    updt_id, p.cur_expire_dt_tm = cnvtdatetime(request->cur_expire_dt_tm),
    p.cur_owner_area_cd = request->cur_owner_area_cd, p.cur_inv_area_cd = request->cur_inv_area_cd, p
    .cur_inv_device_id = 0,
    p.cur_dispense_device_id = 0, p.disease_cd = request->disease_cd, p.donation_type_cd = request->
    donation_type_cd,
    p.cur_supplier_id = request->cur_supplier_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "new product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ELSE
   SET reply->product_id = product_id_new
  ENDIF
  INSERT  FROM blood_product bp
   SET bp.product_id = product_id_new, bp.product_cd = request->product_cd, bp.supplier_prefix = "",
    bp.cur_volume = request->cur_volume, bp.orig_label_abo_cd = 0.0, bp.orig_label_rh_cd = 0.0,
    bp.cur_abo_cd = 0, bp.cur_rh_cd = 0, bp.segment_nbr =
    IF ((request->segment_nbr="")) null
    ELSE request->segment_nbr
    ENDIF
    ,
    bp.orig_expire_dt_tm = cnvtdatetime(request->cur_expire_dt_tm), bp.orig_volume = request->
    cur_volume, bp.lot_nbr =
    IF ((request->lot_nbr="")) null
    ELSE request->lot_nbr
    ENDIF
    ,
    bp.updt_cnt = 0, bp.updt_dt_tm = cnvtdatetime(curdate,curtime3), bp.updt_id = reqinfo->updt_id,
    bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->updt_applctx, bp.active_ind = 1,
    bp.active_status_cd = reqdata->active_status_cd, bp.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), bp.active_status_prsnl_id = reqinfo->updt_id,
    bp.autologous_ind = request->autologous_ind, bp.directed_ind = request->directed_ind, bp
    .drawn_dt_tm = cnvtdatetime(request->drawn_dt_tm),
    bp.donor_person_id = request->person_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "blood_product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "blood product table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  SET product_event_id_new = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    product_event_id_new = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM product_event pe
   SET pe.product_event_id = product_event_id_new, pe.product_id = product_id_new, pe.order_id = 0,
    pe.bb_result_id = 0, pe.event_type_cd = donation_event_type_cd, pe.event_prsnl_id = request->
    phleb_prsnl_id,
    pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id,
    pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind = 1,
    pe.active_status_cd = reqdata->active_status_cd, pe.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), pe.active_status_prsnl_id = reqinfo->updt_id,
    pe.event_status_flag = 0, pe.person_id = request->person_id, pe.event_dt_tm = cnvtdatetime(
     request->drawn_dt_tm),
    pe.encntr_id = request->encntr_id, pe.event_tz =
    IF (curutc=1) curtimezoneapp
    ELSE 0
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product event table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  IF ((((request->autologous_ind=1)) OR ((request->directed_ind=1))) )
   SET product_event_id_new = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     product_event_id_new = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM product_event pe
    SET pe.product_event_id = product_event_id_new, pe.product_id = product_id_new, pe.order_id = 0,
     pe.bb_result_id = 0, pe.event_type_cd =
     IF ((request->autologous_ind=1)) autologous_event_type_cd
     ELSE directed_event_type_cd
     ENDIF
     , pe.event_prsnl_id = request->phleb_prsnl_id,
     pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id,
     pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind = 1,
     pe.active_status_cd = reqdata->active_status_cd, pe.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), pe.active_status_prsnl_id = reqinfo->updt_id,
     pe.event_status_flag = 0, pe.person_id = 0, pe.event_dt_tm = cnvtdatetime(request->drawn_dt_tm),
     pe.encntr_id = 0, pe.event_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "insert2"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "product event table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  SET donation_product_id_new = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    donation_product_id_new = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM bbd_don_product_r d
   SET d.donation_product_id = donation_product_id_new, d.donation_results_id = request->
    donation_result_id, d.contact_id = request->contact_id,
    d.person_id = request->person_id, d.product_id = product_id_new, d.updt_cnt = 0,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
    reqinfo->updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.active_ind = 1, d.active_status_cd = reqdata->
    active_status_cd,
    d.active_status_dt_tm = cnvtdatetime(curdate,curtime3), d.active_status_prsnl_id = reqinfo->
    updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_don_product_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor product table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  IF ((request->auto_directed_ind=1))
   INSERT  FROM auto_directed a
    SET a.product_event_id = product_event_id_new, a.product_id = product_id_new, a.person_id =
     request->auto_dir_person_id,
     a.associated_dt_tm = cnvtdatetime(request->drawn_dt_tm), a.updt_cnt = 0, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
     updt_applctx,
     a.active_ind = 1, a.active_status_cd = reqdata->active_status_cd, a.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     a.active_status_prsnl_id = reqinfo->updt_id, a.encntr_id = request->encntr_id, a
     .expected_usage_dt_tm = cnvtdatetime(request->needed_dt_tm)
    WITH counter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "auto_directed"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  SET correct_don_prod_id_new = 0.0
  SELECT INTO "nl:"
   snbr = seq(blood_bank_seq,nextval)
   FROM dual
   DETAIL
    correct_don_prod_id_new = snbr
   WITH format, counter
  ;end select
  INSERT  FROM bbd_correct_don_prod_r cd
   SET cd.correct_don_prod_id = correct_don_prod_id_new, cd.correct_don_result_id = correct_donor_id,
    cd.donation_product_id = donation_product_id_new,
    cd.donation_results_id = request->donation_result_id, cd.contact_id = request->contact_id, cd
    .person_id = request->person_id,
    cd.product_id = product_id_new, cd.add_remove_ind = request->add_product_ind, cd.updt_cnt = 0,
    cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_id = reqinfo->updt_id, cd.updt_task =
    reqinfo->updt_task,
    cd.updt_applctx = reqinfo->updt_applctx, cd.active_ind = 1, cd.active_status_cd = reqdata->
    active_status_cd,
    cd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cd.active_status_prsnl_id = reqinfo->
    updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert1"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "donation_product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_correct_don_prod_r"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->quarantine_reason_cd > 0))
  CALL echo(build("entering if quarantine_reason_cd"))
  SET reply->quar_status = "X"
  CALL add_product_event(request->product_id,0,0,0,0,
   quarantined_event_type_cd,cnvtdatetime(curdate,curtime3),request->phleb_prsnl_id,0,0,
   0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  IF (gsub_product_event_status="FS")
   SET reply->quar_status = "F"
  ELSEIF (gsub_product_event_status="FA")
   SET reply->quar_status = "F"
  ELSEIF (gsub_product_event_status="OK")
   CALL echo(build("product_event OK:  curqual =",curqual))
   CALL echo(build("product_event_id =",product_event_id))
   INSERT  FROM quarantine qu
    SET qu.product_event_id = product_event_id, qu.product_id = request->product_id, qu
     .quar_reason_cd = request->quarantine_reason_cd,
     qu.orig_quar_qty = 0, qu.cur_quar_qty = 0, qu.active_ind = 1,
     qu.active_status_cd = reqdata->active_status_cd, qu.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), qu.active_status_prsnl_id = reqinfo->updt_id,
     qu.updt_cnt = 0, qu.updt_dt_tm = cnvtdatetime(curdate,curtime3), qu.updt_task = reqinfo->
     updt_task,
     qu.updt_id = reqinfo->updt_id, qu.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET reply->quar_status = "F"
   ENDIF
   IF ((reply->quar_status != "X"))
    IF ((reply->quar_status="F"))
     ROLLBACK
    ELSE
     COMMIT
     CALL echo(build("quarantine OK:  curqual =",curqual))
     SET reply->quar_status = "S"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((request->update_auto_directed_ind=1)
  AND (request->inactivate_directed_ind=0)
  AND (request->inactivate_autologous_ind=0))
  SELECT INTO "nl:"
   ad.*
   FROM auto_directed ad
   WHERE (ad.product_event_id=request->auto_dir_product_event_id)
    AND (ad.updt_cnt=request->auto_directed_updt_cnt)
   WITH counter, forupdate(ad)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock1"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed update"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM auto_directed ad
   SET ad.associated_dt_tm =
    IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(request->drawn_dt_tm)
    ELSE ad.associated_dt_tm
    ENDIF
    , ad.updt_cnt = (ad.updt_cnt+ 1), ad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ad.updt_id = reqinfo->updt_id, ad.updt_task = reqinfo->updt_task, ad.updt_applctx = reqinfo->
    updt_applctx,
    ad.expected_usage_dt_tm =
    IF ((request->update_needed_dt_tm=1)) cnvtdatetime(request->needed_dt_tm)
    ELSE ad.expected_usage_dt_tm
    ENDIF
   WHERE (ad.product_event_id=request->auto_dir_product_event_id)
    AND (ad.updt_cnt=request->auto_directed_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update1"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "auto_directed"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  IF ((((request->drawn_dt_tm_ind=1)) OR ((request->phleb_prsnl_id_ind=1))) )
   SELECT INTO "nl:"
    pe.*
    FROM product_event pe
    WHERE (pe.product_event_id=request->auto_dir_product_event_id)
     AND (pe.updt_cnt=request->auto_dir_product_event_updt_cnt)
    WITH counter, forupdate(pe)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto dir product event"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
   UPDATE  FROM product_event pe
    SET pe.event_dt_tm =
     IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(request->drawn_dt_tm)
     ELSE pe.event_dt_tm
     ENDIF
     , pe.event_prsnl_id =
     IF ((request->phleb_prsnl_id_ind=1)) request->phleb_prsnl_id
     ELSE pe.event_prsnl_id
     ENDIF
     , pe.updt_cnt = (pe.updt_cnt+ 1),
     pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
     reqinfo->updt_task,
     pe.updt_applctx = reqinfo->updt_applctx
    WHERE (pe.product_event_id=request->auto_dir_product_event_id)
     AND (pe.updt_cnt=request->auto_dir_product_event_updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "update3"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "update auto/dir"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->inactivate_autologous_ind=1))
  SELECT INTO "nl:"
   pe.*
   FROM product_event pe
   WHERE (pe.product_event_id=request->auto_dir_product_event_id)
    AND (pe.updt_cnt=request->auto_dir_product_event_updt_cnt)
   WITH counter, forupdate(pe)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto inactivate"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM product_event pe
   SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
    updt_applctx
   WHERE (pe.product_event_id=request->auto_dir_product_event_id)
    AND (pe.updt_cnt=request->auto_dir_product_event_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivte autologous"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->inactivate_directed_ind=1))
  SELECT INTO "nl:"
   pe.*
   FROM product_event pe
   WHERE (pe.product_event_id=request->auto_dir_product_event_id)
    AND (pe.updt_cnt=request->auto_dir_product_event_updt_cnt)
   WITH counter, forupdate(pe)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "directed inactivate"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM product_event pe
   SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
    updt_applctx
   WHERE (pe.product_event_id=request->auto_dir_product_event_id)
    AND (pe.updt_cnt=request->auto_dir_product_event_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivte directed"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((((request->update_drawn_product_event=1)) OR ((((request->drawn_dt_tm_ind=1)) OR ((request->
 phleb_prsnl_id_ind=1)
  AND (request->drawn_product_event_id > 0))) )) )
  SELECT INTO "nl:"
   pe.*
   FROM product_event pe
   WHERE (pe.product_event_id=request->drawn_product_event_id)
    AND (pe.updt_cnt=request->drawn_product_event_updt_cnt)
   WITH counter, forupdate(pe)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "drawn update"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM product_event pe
   SET pe.event_dt_tm =
    IF ((request->drawn_dt_tm_ind=1)) cnvtdatetime(request->drawn_dt_tm)
    ELSE pe.event_dt_tm
    ENDIF
    , pe.event_prsnl_id =
    IF ((request->phleb_prsnl_id_ind=1)) request->phleb_prsnl_id
    ELSE pe.event_prsnl_id
    ENDIF
    , pe.updt_cnt = (pe.updt_cnt+ 1),
    pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
    reqinfo->updt_task,
    pe.updt_applctx = reqinfo->updt_applctx
   WHERE (pe.product_event_id=request->drawn_product_event_id)
    AND (pe.updt_cnt=request->drawn_product_event_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "update drawn"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_autologous_ind=1))
  SET product_event_id_new = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    product_event_id_new = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM product_event pe
   SET pe.product_event_id = product_event_id_new, pe.product_id = request->product_id, pe.order_id
     = 0,
    pe.bb_result_id = 0, pe.event_type_cd = autologous_event_type_cd, pe.event_prsnl_id = request->
    phleb_prsnl_id,
    pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id,
    pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind = 1,
    pe.active_status_cd = reqdata->active_status_cd, pe.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), pe.active_status_prsnl_id = reqinfo->updt_id,
    pe.event_status_flag = 0, pe.person_id = request->auto_dir_person_id, pe.event_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pe.encntr_id = request->encntr_id, pe.event_tz =
    IF (curutc=1) curtimezoneapp
    ELSE 0
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert autologous"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product event table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_directed_ind=1))
  SET product_event_id_new = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    product_event_id_new = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM product_event pe
   SET pe.product_event_id = product_event_id_new, pe.product_id = request->product_id, pe.order_id
     = 0,
    pe.bb_result_id = 0, pe.event_type_cd = directed_event_type_cd, pe.event_prsnl_id = request->
    phleb_prsnl_id,
    pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id,
    pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind = 1,
    pe.active_status_cd = reqdata->active_status_cd, pe.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), pe.active_status_prsnl_id = reqinfo->updt_id,
    pe.event_status_flag = 0, pe.person_id = request->auto_dir_person_id, pe.event_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pe.encntr_id = request->encntr_id, pe.event_tz =
    IF (curutc=1) curtimezoneapp
    ELSE 0
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert directed"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product event table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((((request->add_directed_ind=1)) OR ((request->add_autologous_ind=1))) )
  INSERT  FROM auto_directed a
   SET a.product_event_id = product_event_id_new, a.product_id = request->product_id, a.person_id =
    request->auto_dir_person_id,
    a.associated_dt_tm = cnvtdatetime(request->drawn_dt_tm), a.updt_cnt = 0, a.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.active_ind = 1, a.active_status_cd = reqdata->active_status_cd, a.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    a.active_status_prsnl_id = reqinfo->updt_id, a.encntr_id = request->encntr_id, a
    .expected_usage_dt_tm = cnvtdatetime(request->needed_dt_tm)
   WITH counter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert2"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "auto_directed"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((((request->inactivate_directed_ind=1)) OR ((request->inactivate_autologous_ind=1))) )
  SELECT INTO "nl:"
   ad.*
   FROM auto_directed ad
   WHERE (ad.product_event_id=request->auto_dir_product_event_id)
    AND (ad.updt_cnt=request->auto_directed_updt_cnt)
   WITH counter, forupdate(ad)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock2"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed update"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM auto_directed ad
   SET ad.active_ind = 0, ad.updt_cnt = (ad.updt_cnt+ 1), ad.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    ad.updt_id = reqinfo->updt_id, ad.updt_task = reqinfo->updt_task, ad.updt_applctx = reqinfo->
    updt_applctx
   WHERE (ad.product_event_id=request->auto_dir_product_event_id)
    AND (ad.updt_cnt=request->auto_directed_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "update2"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "auto_directed"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->inactivate_product=1))
  SELECT INTO "nl:"
   p.*
   FROM product p
   PLAN (p
    WHERE (p.product_id=request->product_id)
     AND (p.updt_cnt=request->product_updt_cnt))
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivate lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM product p
   SET p.corrected_ind = request->product_corrected_ind, p.active_ind = 0, p.locked_ind = 0,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo
    ->updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
   PLAN (p
    WHERE (p.product_id=request->product_id)
     AND (p.updt_cnt=request->product_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivate product"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   bp.*
   FROM blood_product bp
   PLAN (bp
    WHERE (bp.product_id=request->product_id)
     AND (bp.updt_cnt=request->blood_product_updt_cnt))
   WITH nocounter, forupdate(bp)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "blood_product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivate lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM blood_product bp
   SET bp.active_ind = 0, bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->
    updt_applctx
   PLAN (bp
    WHERE (bp.product_id=request->product_id)
     AND (bp.updt_cnt=request->blood_product_updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "blood_product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivate blood_product"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   pe.*
   FROM product_event pe
   WHERE (pe.product_event_id=request->drawn_product_event_id)
    AND (pe.updt_cnt=request->drawn_product_event_updt_cnt)
   WITH counter, forupdate(pe)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "drawn inactivate"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM product_event pe
   SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
    updt_applctx
   WHERE (pe.product_event_id=request->drawn_product_event_id)
    AND (pe.updt_cnt=request->drawn_product_event_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "inactivte autologous"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   dp.*
   FROM bbd_don_product_r dp
   WHERE (dp.donation_product_id=request->donation_product_id)
    AND (dp.updt_cnt=request->donation_product_updt_cnt)
   WITH counter, forupdate(dp)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "donation_product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_don_product_r"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_don_product_r dp
   SET dp.active_ind = 0, dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    dp.updt_id = reqinfo->updt_id, dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->
    updt_applctx
   WHERE (dp.donation_product_id=request->donation_product_id)
    AND (dp.updt_cnt=request->donation_product_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "donation_product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_don_product_r"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  SET correct_don_prod_id_new = 0.0
  SELECT INTO "nl:"
   snbr = seq(blood_bank_seq,nextval)
   FROM dual
   DETAIL
    correct_don_prod_id_new = snbr
   WITH format, counter
  ;end select
  INSERT  FROM bbd_correct_don_prod_r cd
   SET cd.correct_don_prod_id = correct_don_prod_id_new, cd.correct_don_result_id = correct_donor_id,
    cd.donation_product_id = request->donation_product_id,
    cd.donation_results_id = request->donation_result_id, cd.contact_id = request->contact_id, cd
    .person_id = request->person_id,
    cd.product_id = request->product_id, cd.add_remove_ind = request->add_product_ind, cd.updt_cnt =
    0,
    cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_id = reqinfo->updt_id, cd.updt_task =
    reqinfo->updt_task,
    cd.updt_applctx = reqinfo->updt_applctx, cd.active_ind = 1, cd.active_status_cd = reqdata->
    active_status_cd,
    cd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cd.active_status_prsnl_id = reqinfo->
    updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "donation_product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_correct_don_prod_r"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
  GO TO exit_script
 ENDIF
 SUBROUTINE add_product_event_with_inventory_area_cd(sub_product_id,sub_person_id,sub_encntr_id,
  sub_order_id,sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_locn_cd)
   CALL echo(build(" PRODUCT_ID - ",sub_product_id," PERSON_ID - ",sub_person_id," ENCNTR_ID - ",
     sub_encntr_id," SUB_RODER_ID - ",sub_order_id," BB_RESULT_ID - ",sub_bb_result_id,
     " EVENT_TYPE_ID - ",sub_event_type_cd," EVENT_DT_TM_ID - ",sub_event_dt_tm," PRSNL_ID - ",
     sub_event_prsnl_id," EVENT_STATUS_FLAG - ",sub_event_status_flag," override_ind - ",
     sub_override_ind,
     " override_reason_cd - ",sub_override_reason_cd," related_pe_id - ",sub_related_product_event_id,
     " active_ind - ",
     sub_active_ind," active_status_cd - ",sub_active_status_cd," active_status_dt_tm - ",
     sub_active_status_dt_tm,
     " status_prsnl_id - ",sub_active_status_prsnl_id," inventoy_area_cd - ",sub_locn_cd))
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
      , pe.inventory_area_cd = sub_locn_cd
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
   SET reply->quar_status = gsub_product_event_status
 END ;Subroutine
#exit_script
 SET reqinfo->commit_ind = 0
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 FREE SET person_donor_rec
 FREE SET donation_rec
END GO

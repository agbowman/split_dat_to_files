CREATE PROGRAM bbd_add_donation_results:dba
 RECORD reply(
   1 product_id_new = f8
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
       3 sub_event_dt_tm = di8
 )
 DECLARE update_eligibility_ind = i2
 DECLARE exist_eligibility_dt_tm = f8
 DECLARE exist_last_donation_dt_tm = f8
 SET reply->status_data.status = "F"
 SET reply->product_id_new = 0.0
 SET failed = "F"
 SET eligibility_id_new = 0.0
 SET encounter_status_cd = 0.0
 SET eligibility_type_cd_new = 0.0
 SET contact_status_cd_new = 0.0
 SET product_id_new = 0.0
 SET donation_event_type_cd = 0.0
 SET person_reltn_type_cd_new = 0.0
 SET data_status_cd_new = 0.0
 SET contributor_system = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET bbd_donor_contact_type_cd = 0.0
 SET deferred_elig_type_cd = 0.0
 SET suspend_elig_type_cd = 0.0
 SET good_elig_type_cd = 0.0
 SET exist_eligibility_type_cd = 0.0
 SET required_cv_recs = 9
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",cv_cnt,data_status_cd_new)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(261,"DISCHARGED",cv_cnt,encounter_status_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(351,"BBRECIPIENT",cv_cnt,person_reltn_type_cd_new)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14220,"DONATE",cv_cnt,bbd_donor_contact_type_cd)
 SET cv_cnt = 1
 IF ((request->contact_status_mean="CANCELLED"))
  SET stat = uar_get_meaning_by_codeset(14224,"CANCELLED",cv_cnt,contact_status_cd_new)
 ELSEIF ((request->contact_status_mean="COMPLETE"))
  SET stat = uar_get_meaning_by_codeset(14224,"COMPLETE",cv_cnt,contact_status_cd_new)
 ELSEIF ((request->contact_status_mean="PENDING"))
  SET stat = uar_get_meaning_by_codeset(14224,"PENDING",cv_cnt,contact_status_cd_new)
 ELSE
  SET stat = uar_get_meaning_by_codeset(14224,"TESTING",cv_cnt,contact_status_cd_new)
 ENDIF
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,deferred_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,suspend_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,good_elig_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"20",cv_cnt,donation_event_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"10",cv_cnt,autologous_event_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"11",cv_cnt,directed_event_type_cd)
 IF (((data_status_cd_new=0.0) OR (((encounter_status_cd=0.0) OR (((person_reltn_type_cd_new=0.0) OR
 (((bbd_donor_contact_type_cd=0.0) OR (((contact_status_cd_new=0.0) OR (((deferred_elig_type_cd=0.0)
  OR (((suspend_elig_type_cd=0.0) OR (((good_elig_type_cd=0.0) OR (((donation_event_type_cd=0.0) OR (
 ((autologous_event_type_cd=0.0) OR (directed_event_type_cd=0.0)) )) )) )) )) )) )) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (data_status_cd_new=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read data status code value"
  ELSEIF (encounter_status_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read encounter status code value"
  ELSEIF (person_reltn_type_cd_new=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read person relation type code value"
  ELSEIF (bbd_donor_contact_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read donor contact code value"
  ELSEIF (contact_status_cd_new=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read contact status code value"
  ELSEIF (deferred_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read deferred eligibility type code value"
  ELSEIF (suspend_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read suspended eligibility type code value"
  ELSEIF (good_elig_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read good eligibility type code value"
  ELSEIF (donation_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read donation event type code value"
  ELSEIF (autologous_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read autlogous event type code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read directed event type code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 IF ((request->eligibility_type_mean="FAILED"))
  SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,eligibility_type_cd_new)
 ELSEIF ((request->eligibility_type_mean="TEMPDEF"))
  SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,eligibility_type_cd_new)
 ELSEIF ((request->eligibility_type_mean="SUCCESS"))
  SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_type_cd_new)
 ELSEIF ((request->eligibility_type_mean="PERMDEF"))
  SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,eligibility_type_cd_new)
 ELSE
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "eligibility"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "meaning error"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 IF (eligibility_type_cd_new=0.0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "eligibility_type_cd"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(89,"CERNER",cv_cnt,contributor_system)
 SELECT INTO "nl:"
  p.*
  FROM person_donor p
  WHERE (p.person_id=request->person_id)
   AND (p.updt_cnt=request->person_donor_updt_cnt)
   AND p.lock_ind=1
  DETAIL
   exist_eligibility_type_cd = p.eligibility_type_cd, exist_eligibility_dt_tm = cnvtdatetime(p
    .defer_until_dt_tm), exist_last_donation_dt_tm = cnvtdatetime(p.last_donation_dt_tm)
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor person lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET update_eligibility_ind = 0
 IF (exist_eligibility_type_cd=deferred_elig_type_cd)
  SET eligibility_type_cd_new = exist_eligibility_type_cd
 ELSEIF (exist_eligibility_type_cd=suspend_elig_type_cd
  AND eligibility_type_cd_new=good_elig_type_cd)
  SET eligibility_type_cd_new = exist_eligibility_type_cd
 ELSE
  SET update_eligibility_ind = 1
 ENDIF
 UPDATE  FROM person_donor p
  SET p.lock_ind = 0, p.eligibility_type_cd = eligibility_type_cd_new, p.defer_until_dt_tm =
   IF ((request->update_defer_until=1)
    AND exist_eligibility_type_cd != deferred_elig_type_cd)
    IF ((request->clear_defer_dt_tm_ind=1)) null
    ELSE
     IF (nullind(p.defer_until_dt_tm)=1) cnvtdatetime(request->eligible_dt_tm)
     ELSE
      IF (cnvtdatetime(request->eligible_dt_tm) > cnvtdatetime(exist_eligibility_dt_tm)) cnvtdatetime
       (request->eligible_dt_tm)
      ELSE p.defer_until_dt_tm
      ENDIF
     ENDIF
    ENDIF
   ELSE p.defer_until_dt_tm
   ENDIF
   ,
   p.last_donation_dt_tm =
   IF (cnvtdatetime(request->drawn_dt_tm) > cnvtdatetime(exist_last_donation_dt_tm)) cnvtdatetime(
     request->drawn_dt_tm)
   ELSE p.last_donation_dt_tm
   ENDIF
   , p.donation_level =
   IF ((request->count_as_donation_ind=1)) (p.donation_level+ request->per_volume_level)
   ELSE p.donation_level
   ENDIF
   , p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task,
   p.updt_applctx = reqinfo->updt_applctx
  WHERE (p.person_id=request->person_id)
   AND (p.updt_cnt=request->person_donor_updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "person donor table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
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
 SET eligibility_id_new = new_pathnet_seq
 INSERT  FROM bbd_donor_eligibility b
  SET b.eligibility_id = eligibility_id_new, b.contact_id = request->contact_id, b.person_id =
   request->person_id,
   b.encntr_id = request->encntr_id, b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd,
   b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
   updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.eligibility_type_cd = eligibility_type_cd_new, b
   .eligible_dt_tm =
   IF (update_eligibility_ind=1) cnvtdatetime(request->eligible_dt_tm)
   ELSE cnvtdatetime(exist_eligibility_dt_tm)
   ENDIF
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_eligibility"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor eligibility table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET deferral_reason_id_new = 0.0
 FOR (x = 1 TO request->deferral_reasons_count)
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
    SET b.deferral_reason_id = deferral_reason_id_new, b.eligibility_id = eligibility_id_new, b
     .person_id = request->person_id,
     b.contact_id = request->contact_id, b.active_ind = 1, b.active_status_cd = reqdata->
     active_status_cd,
     b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
     updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.reason_cd = request->qual[x].reason_cd, b
     .eligible_dt_tm =
     IF (cnvtstring(request->qual[x].eligible_dt_tm)="-1") null
     ELSE cnvtdatetime(request->qual[x].eligible_dt_tm)
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
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_deferral_reasons"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "deferral reasons table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  b.*
  FROM bbd_donor_contact b
  WHERE (b.contact_id=request->contact_id)
   AND (b.updt_cnt=request->bbd_donor_contact_updt_cnt)
  WITH counter, forupdate(b)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
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
   IF ((request->needed_ind=0)) null
   ELSE cnvtdatetime(request->needed_dt_tm)
   ENDIF
   , b.contact_status_cd = contact_status_cd_new, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  WHERE (b.contact_id=request->contact_id)
   AND (b.updt_cnt=request->bbd_donor_contact_updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donor contact table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET donation_result_id_new = 0.0
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET donation_result_id_new = new_pathnet_seq
 INSERT  FROM bbd_donation_results b
  SET b.donation_result_id = donation_result_id_new, b.encntr_id = request->encntr_id, b.person_id =
   request->person_id,
   b.contact_id = request->contact_id, b.drawn_dt_tm = cnvtdatetime(request->drawn_dt_tm), b
   .start_dt_tm =
   IF ((request->start_dt_tm_ind=0)) null
   ELSE cnvtdatetime(request->start_dt_tm)
   ENDIF
   ,
   b.stop_dt_tm =
   IF ((request->stop_dt_tm_ind=0)) null
   ELSE cnvtdatetime(request->stop_dt_tm)
   ENDIF
   , b.procedure_cd = request->procedure_cd, b.venipuncture_site_cd = request->venipuncture_site_cd,
   b.bag_type_cd = request->bag_type_cd, b.phleb_prsnl_id = request->phleb_prsnl_id, b.outcome_cd =
   request->outcome_cd,
   b.specimen_volume = request->specimen_volume, b.specimen_unit_meas_cd = request->
   specimen_unit_of_meas_cd, b.total_volume = (request->specimen_volume+ request->volume_drawn),
   b.owner_area_cd = request->draw_owner_area_cd, b.inv_area_cd = request->draw_inv_area_cd, b
   .draw_station_cd = request->draw_station_cd,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_cnt = 0,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
   b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), b.active_status_prsnl_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donation_results"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "donation result table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
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
    p.product_sub_nbr = request->product_sub_nbr,
    p.flag_chars = request->flag_chars, p.alternate_nbr = null, p.pooled_product_id = 0,
    p.modified_product_id = 0, p.locked_ind = 0, p.cur_inv_locn_cd = 0,
    p.orig_inv_locn_cd = 0, p.cur_supplier_id = 0, p.recv_dt_tm = null,
    p.recv_prsnl_id = 0, p.orig_ship_cond_cd = 0, p.orig_vis_insp_cd = 0,
    p.storage_temp_cd = 0, p.cur_unit_meas_cd = request->unit_of_meas_cd, p.orig_unit_meas_cd =
    request->unit_of_meas_cd,
    p.pooled_product_ind = 0, p.modified_product_ind = 0, p.donated_by_relative_ind = 0,
    p.corrected_ind = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
    p.updt_cnt = 0, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx,
    p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    p.active_status_prsnl_id = reqinfo->updt_id, p.cur_expire_dt_tm = cnvtdatetime(request->
     expire_dt_tm), p.cur_owner_area_cd = request->owner_area_cd,
    p.cur_inv_area_cd = request->inv_area_cd, p.cur_inv_device_id = 0, p.cur_dispense_device_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "product table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ELSE
   SET reply->product_id_new = product_id_new
  ENDIF
  INSERT  FROM blood_product bp
   SET bp.product_id = product_id_new, bp.product_cd = request->product_cd, bp.supplier_prefix = "",
    bp.cur_volume = request->volume_drawn, bp.orig_label_abo_cd = 0.0, bp.orig_label_rh_cd = 0.0,
    bp.cur_abo_cd = 0.0, bp.cur_rh_cd = 0.0, bp.segment_nbr =
    IF ((request->segment_nbr="")) null
    ELSE request->segment_nbr
    ENDIF
    ,
    bp.orig_expire_dt_tm = cnvtdatetime(request->expire_dt_tm), bp.orig_volume = request->
    volume_drawn, bp.lot_nbr =
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
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
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
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
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
     pe.event_status_flag = 0, pe.person_id = request->auto_dir_person_id, pe.event_dt_tm =
     cnvtdatetime(request->drawn_dt_tm),
     pe.encntr_id = request->encntr_id, pe.event_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
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
   SET d.donation_product_id = donation_product_id_new, d.donation_results_id =
    donation_result_id_new, d.contact_id = request->contact_id,
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
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
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
     .expected_usage_dt_tm = cnvtdatetime(request->expected_usage_dt_tm)
    WITH counter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "auto_directed"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "auto directed table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
   AND (e.person_id=request->person_id)
   AND (e.updt_cnt=request->encntr_updt_cnt)
  WITH counter, forupdate(e)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "encntr_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "encounter lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM encounter e
  SET e.encntr_status_cd = encounter_status_cd, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
   .updt_id = reqinfo->updt_id,
   e.updt_cnt = (e.updt_cnt+ 1), e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->
   updt_applctx
  WHERE (e.encntr_id=request->encntr_id)
   AND (e.person_id=request->person_id)
   AND (e.updt_cnt=request->encntr_updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "encntr_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "encounter table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 IF ((request->inactivate_encntr_person_reltn=1))
  SELECT INTO "nl:"
   ep.*
   FROM encntr_person_reltn ep
   WHERE (ep.encntr_person_reltn_id=request->encntr_person_reltn_id)
    AND (ep.updt_cnt=request->encntr_person_reltn_updt_cnt)
   WITH counter, forupdate(ep)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "lock1"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "encntr_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "encntr_person_reltn inactivate"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM encntr_person_reltn ep
   SET ep.updt_cnt = (ep.updt_cnt+ 1), ep.updt_dt_tm = cnvtdatetime(curdate,curtime3), ep.updt_id =
    reqinfo->updt_id,
    ep.updt_task = reqinfo->updt_task, ep.updt_applctx = reqinfo->updt_applctx, ep.active_ind = 0
   WHERE (ep.encntr_person_reltn_id=request->encntr_person_reltn_id)
    AND (ep.updt_cnt=request->encntr_person_reltn_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "encntr_person_reltn"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "encntr person reltn table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_encntr_person_reltn=1))
  SET encntr_person_reltn_id_new = 0.0
  SELECT INTO "nl:"
   seqn = seq(encounter_seq,nextval)
   FROM dual
   DETAIL
    encntr_person_reltn_id_new = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM encntr_person_reltn ep
   SET ep.encntr_person_reltn_id = encntr_person_reltn_id_new, ep.person_reltn_type_cd =
    person_reltn_type_cd_new, ep.encntr_id = request->encntr_id,
    ep.person_reltn_cd = 0, ep.related_person_reltn_cd = request->related_person_reltn_cd, ep
    .related_person_id = request->auto_dir_person_id,
    ep.updt_cnt = 0, ep.updt_dt_tm = cnvtdatetime(curdate,curtime3), ep.updt_id = reqinfo->updt_id,
    ep.updt_task = reqinfo->updt_task, ep.updt_applctx = reqinfo->updt_applctx, ep.active_ind = 1,
    ep.active_status_cd = reqdata->active_status_cd, ep.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), ep.active_status_prsnl_id = reqinfo->updt_id,
    ep.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ep.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 23:59:59:99"), ep.data_status_cd = data_status_cd_new,
    ep.data_status_dt_tm = cnvtdatetime(curdate,curtime3), ep.data_status_prsnl_id = reqinfo->updt_id,
    ep.contributor_system_cd = contributor_system,
    ep.contact_role_cd = 0, ep.genetic_relationship_ind = 1, ep.living_with_ind = 0,
    ep.visitation_allowed_cd = 0, ep.priority_seq = 0, ep.free_text_cd = 0,
    ep.ft_rel_person_name = "", ep.internal_seq = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "encntr_person_reltn"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "encntr person reltn table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->nbr_of_exceptions=0))
  GO TO exit_script
 ENDIF
 SET count = 0
 FOR (count = 1 TO request->nbr_of_exceptions)
   SET exception_status = "I"
   SET bb_exception_id = 0.0
   SET person_to_add = request->person_id
   CALL add_bb_exception(request->exceptions[count].exception_type_mean,request->exceptions[count].
    override_reason_cd,person_to_add,request->contact_id,bbd_donor_contact_type_cd)
   IF (exception_status="S")
    SET failed = "F"
   ELSE
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_donation_results"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "exception"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb_exception table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE add_bb_exception(exception_type_mean,override_reason_cd_new,person_id,
  donor_contact_id_new,donor_contact_type_cd_new)
   DECLARE exception_type_cd_new = f8 WITH protect, noconstant(0.0)
   SET exception_status = "I"
   SET code_set = 0
   SET code_value = 0.0
   SET cdf_meaning = fillstring(80," ")
   SET code_cnt = 1
   SET cdf_meaning = exception_type_mean
   SET code_set = 14072
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
   IF (code_value=0)
    SET exception_status = "F"
   ELSE
    SET exception_type_cd_new = code_value
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = bb_exception_id, b.product_event_id = 0, b.exception_type_cd =
      exception_type_cd_new,
      b.exception_dt_tm = cnvtdatetime(curdate,curtime3), b.event_type_cd = 0, b.from_abo_cd = 0,
      b.from_rh_cd = 0, b.to_abo_cd = 0, b.to_rh_cd = 0,
      b.override_reason_cd = override_reason_cd_new, b.result_id = 0, b.perform_result_id = 0,
      b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
      b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
      b.person_id =
      IF (person_id > 0) person_id
      ELSE 0
      ENDIF
      , b.donor_contact_id = donor_contact_id_new, b.donor_contact_type_cd =
      donor_contact_type_cd_new
     WITH counter
    ;end insert
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO

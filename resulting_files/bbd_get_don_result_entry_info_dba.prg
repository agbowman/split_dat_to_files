CREATE PROGRAM bbd_get_don_result_entry_info:dba
 RECORD reply(
   1 person_id = f8
   1 donor_number = vc
   1 bde_eligibility_id = f8
   1 bde_eligibility_type_cd = f8
   1 bde_eligibility_type_disp = c40
   1 bde_eligibility_type_mean = c12
   1 bde_eligible_dt_tm = dq8
   1 bde_updt_cnt = i4
   1 pd_eligibility_type_cd = f8
   1 pd_eligibility_type_disp = c40
   1 pd_eligibility_type_mean = c12
   1 pd_defer_until_dt_tm = dq8
   1 pd_lock_ind = i2
   1 pd_updt_cnt = i4
   1 pd_elig_for_reinstate_ind = i2
   1 pd_updt_applctx = i4
   1 bdc_contact_id = f8
   1 bdc_updt_cnt = i4
   1 bdr_donation_result_id = f8
   1 bdr_encntr_id = f8
   1 bdr_procedure_cd = f8
   1 bdr_procedure_disp = c40
   1 bdr_procedure_mean = c12
   1 bdr_outcome_cd = f8
   1 bdr_outcome_disp = c40
   1 bdr_outcome_mean = c12
   1 bdr_drawn_dt_tm = dq8
   1 bdr_updt_cnt = i4
   1 pab_abo_cd = f8
   1 pab_abo_disp = c40
   1 pab_rh_cd = f8
   1 pab_rh_disp = c40
   1 pab_updt_cnt = i4
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
 SET reply->status_data.status = "F"
 SET alias_type_cd = 0.0
 SET s_cnt = 0
 SET failed = ""
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"DONORID",cv_cnt,alias_type_cd)
 IF (alias_type_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "BBD_GET_DON_RESULT_ENTRY_INFO"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "alias type cd"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM bbd_don_product_r bdpr,
   bbd_donation_results bdr,
   bbd_donor_contact bdc,
   person_donor pd,
   person_alias pa,
   bbd_donor_eligibility bde,
   (dummyt d  WITH seq = 1),
   donor_aborh dab
  PLAN (bdpr
   WHERE (bdpr.product_id=request->product_id)
    AND bdpr.active_ind=1)
   JOIN (bdr
   WHERE bdr.donation_result_id=bdpr.donation_results_id
    AND bdr.active_ind=1)
   JOIN (bdc
   WHERE bdc.contact_id=bdpr.contact_id
    AND bdc.active_ind=1)
   JOIN (pd
   WHERE pd.person_id=bdpr.person_id
    AND pd.active_ind=1)
   JOIN (bde
   WHERE bde.encntr_id=bdr.encntr_id
    AND bde.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=pd.person_id
    AND pa.person_alias_type_cd=alias_type_cd
    AND pa.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (dab
   WHERE dab.person_id=pd.person_id
    AND dab.active_ind=1)
  DETAIL
   reply->person_id = pd.person_id, reply->donor_number = pa.alias, reply->bde_eligibility_id = bde
   .eligibility_id,
   reply->bde_eligibility_type_cd = bde.eligibility_type_cd, reply->bde_eligible_dt_tm = bde
   .eligible_dt_tm, reply->bde_updt_cnt = bde.updt_cnt,
   reply->pd_eligibility_type_cd = pd.eligibility_type_cd, reply->pd_defer_until_dt_tm = pd
   .defer_until_dt_tm, reply->pd_updt_cnt = pd.updt_cnt,
   reply->pd_lock_ind = pd.lock_ind, reply->pd_updt_applctx = pd.updt_applctx, reply->
   pd_elig_for_reinstate_ind = pd.elig_for_reinstate_ind,
   reply->bdc_contact_id = bdc.contact_id, reply->bdc_updt_cnt = bdc.updt_cnt, reply->
   bdr_donation_result_id = bdr.donation_result_id,
   reply->bdr_encntr_id = bdr.encntr_id, reply->bdr_procedure_cd = bdr.procedure_cd, reply->
   bdr_outcome_cd = bdr.outcome_cd,
   reply->bdr_drawn_dt_tm = bdr.drawn_dt_tm, reply->bdr_updt_cnt = bdr.updt_cnt, reply->pab_abo_cd =
   dab.abo_cd,
   reply->pab_rh_cd = dab.rh_cd, reply->pab_updt_cnt = dab.updt_cnt
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO

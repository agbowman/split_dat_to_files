CREATE PROGRAM ct_get_validate_for_activation:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 amendment_nbr = i4
    1 amendment_reason = i2
    1 appl_disease = i2
    1 prot_objective = i2
    1 prot_modality = i2
    1 strat_defined_ind = i2
    1 reason_no_strat = vc
    1 reason_for_failure = vc
    1 site_target_over = i2
    1 site_target = i2
    1 duration_unit = i2
    1 support_type = i2
    1 data_capture_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->amendment_reason = 0
 SET reply->appl_disease = 0
 SET reply->prot_modality = 0
 SET reply->prot_objective = 0
 SET reply->site_target = 0
 SET reply->site_target_over = 0
 SET reply->duration_unit = 0
 SET reply->support_type = 0
 DECLARE primary_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE accrual_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17438,"YES",1,accrual_cd)
 SELECT INTO "nl:"
  ar_id = ar.amendment_reason_id, ad_id = ad.appl_disease_id, pm_id = pm.prot_modality_id,
  po_id = po.prot_objective_id, pa.prot_amendment_id, pa.amendment_nbr
  FROM prot_amendment pa,
   amendment_reason ar,
   appl_disease ad,
   prot_modality pm,
   prot_master prms,
   prot_objective po,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4
  PLAN (pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id))
   JOIN (prms
   WHERE pa.prot_master_id=prms.prot_master_id)
   JOIN (d1)
   JOIN (ar
   WHERE ar.prot_amendment_id=pa.prot_amendment_id)
   JOIN (d2)
   JOIN (ad
   WHERE ad.prot_amendment_id=pa.prot_amendment_id)
   JOIN (d3)
   JOIN (pm
   WHERE pm.prot_amendment_id=pa.prot_amendment_id)
   JOIN (d4)
   JOIN (po
   WHERE po.prot_amendment_id=pa.prot_amendment_id)
  DETAIL
   reply->amendment_nbr = pa.amendment_nbr, reply->data_capture_ind = pa.data_capture_ind
   IF (cnvtint(ar_id) > 0)
    reply->amendment_reason = 1
   ENDIF
   IF (cnvtint(ad_id) > 0)
    reply->appl_disease = 1
   ENDIF
   IF (((cnvtint(pm_id) > 0) OR (uar_get_code_meaning(prms.prot_type_cd)="NONTHERAPEUT")) )
    reply->prot_modality = 1
   ENDIF
   IF (cnvtint(po_id) > 0)
    reply->prot_objective = 1
   ENDIF
   IF (pa.anticipated_prot_dur_value > 0.0)
    IF (pa.anticipated_prot_dur_uom_cd > 0.0)
     reply->duration_unit = 1
    ENDIF
   ELSEIF (pa.anticipated_prot_dur_value=0.0)
    IF (pa.anticipated_prot_dur_uom_cd=0.0)
     reply->duration_unit = 1
    ENDIF
   ENDIF
   IF (pa.targeted_accrual > 0)
    reply->site_target = 1
    IF (pa.groupwide_targeted_accrual > 0)
     IF (pa.targeted_accrual < pa.groupwide_targeted_accrual)
      reply->site_target_over = 1
     ENDIF
    ELSE
     reply->site_target_over = 1
    ENDIF
   ELSE
    reply->site_target_over = 1
    IF (pa.accrual_required_indc_cd != accrual_cd)
     reply->site_target = 1
    ENDIF
   ENDIF
  WITH nocounter, dontcare = ar, dontcare = ad,
   dontcare = pm, outerjoin = d4
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,primary_cd)
 SELECT INTO "nl:"
  FROM prot_grant_sponsor pgs,
   support_type st
  PLAN (pgs
   WHERE (pgs.prot_amendment_id=request->prot_amendment_id)
    AND pgs.primary_secondary_cd=primary_cd)
   JOIN (st
   WHERE st.prot_grant_sponsor_id=outerjoin(pgs.prot_grant_sponsor_id))
  DETAIL
   IF (st.prot_grant_sponsor_id > 0)
    reply->support_type = 1
   ELSE
    reply->support_type = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stratum_chk_a_ok_func_isok = 0
 SET stratum_chk_a_ok_func_amendid = request->prot_amendment_id
 SET stratum_chk_a_ok_func_reason = fillstring(999," ")
 EXECUTE ct_stratum_chk_a_ok_func
 IF (stratum_chk_a_ok_func_isok != true)
  CALL echo("fail")
  SET reply->strat_defined_ind = false
  SET reply->reason_no_strat = stratum_chk_a_ok_func_reason
  CALL echo(stratum_chk_a_ok_func_reason)
 ELSE
  CALL echo("success")
  SET reply->strat_defined_ind = true
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echo(build("Amd Id = ",request->prot_amendment_id))
 CALL echo(build("amd Nbr = ",reply->amendment_nbr))
 CALL echo(build("reason = ",reply->amendment_reason))
 CALL echo(build("app_disease = ",reply->appl_disease))
 CALL echo(build("prot_mod = ",reply->prot_modality))
 CALL echo(build("prot obj = ",reply->prot_objective))
 CALL echo(build("status = ",reply->status_data.status))
 SET last_mod = "003"
 SET mod_date = "June 06, 2008"
END GO

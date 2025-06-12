CREATE PROGRAM ct_get_assessment:dba
 RECORD reply(
   1 patient_enrolled = i2
   1 enrolling_consent = i2
   1 amendment_nbr = i4
   1 revision_nbr_txt = vc
   1 prot_amendment_id = f8
   1 amendment_status = vc
   1 protocol_status = vc
   1 assessments[*]
     2 prot_amendment_id = f8
     2 amendment_nbr = i4
     2 amendment_status = vc
     2 prot_questionnaire_id = f8
     2 questionnaire_name = vc
     2 pt_elig_tracking_id = f8
     2 elig_status_cd = f8
     2 elig_status_disp = vc
     2 elig_status_mean = vc
     2 reason_ineligible_cd = f8
     2 reason_ineligible_disp = vc
     2 reason_ineligible_mean = vc
     2 elig_request_person = vc
     2 recorded_dt_tm = dq8
     2 revision_ind = i2
     2 revision_nbr_txt = c30
   1 pending_assessments[*]
     2 prot_questionnaire_id = f8
     2 questionnaire_name = vc
     2 questionnaire_type_cd = f8
     2 questionnaire_type_disp = vc
     2 questionnaire_type_mean = vc
     2 elig_status_cd = f8
     2 elig_status_disp = vc
     2 elig_status_mean = vc
   1 questionnaires[*]
     2 prot_questionnaire_id = f8
     2 questionnaire_name = vc
     2 desc_text = vc
     2 desc_long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->patient_enrolled = false
 SET reply->amendment_status = ""
 SET failed = - (1)
 CALL echo(build("patient enrolled",reply->patient_enrolled))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE pending_cnt = i2 WITH protect, noconstant(0)
 DECLARE yes_cd = f8 WITH protect, noconstant(0) = 0.0
 DECLARE eligible_cd = f8 WITH protect, noconstant(0.0)
 DECLARE incomplete_cd = f8 WITH protect, noconstant(0.0)
 DECLARE elignoverif_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE amendment_status = vc WITH protect, noconstant("")
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activeamdnbr = i4 WITH public, noconstant(0)
 DECLARE activeamdid = f8 WITH public, noconstant(0.0)
 DECLARE activerevisionind = i2 WITH public, noconstant(0)
 DECLARE activerevisionnbrtxt = vc
 DECLARE pmid = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17283,"YES",1,yes_cd)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGIBLE",1,eligible_cd)
 SET stat = uar_get_meaning_by_codeset(17285,"INCOMPLETE",1,incomplete_cd)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGNOVER",1,elignoverif_cd)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr,
   ct_pt_amd_assignment ct
  PLAN (ppr
   WHERE (ppr.prot_master_id=request->prot_master_id)
    AND (ppr.person_id=request->person_id)
    AND ppr.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (ct
   WHERE ct.reg_id=ppr.reg_id
    AND ct.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   reply->patient_enrolled = true, prot_amendment_id = ct.prot_amendment_id,
   CALL echo("enrolled")
  WITH nocounter
 ;end select
 SET reply->prot_amendment_id = prot_amendment_id
 IF ((reply->patient_enrolled=0))
  SELECT INTO "nl:"
   pc.consent_id
   FROM pt_consent pc,
    prot_amendment pa,
    pt_elig_consent_reltn pecr,
    prot_master pm
   PLAN (pm
    WHERE (pm.parent_prot_master_id=request->prot_master_id)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id)
    JOIN (pc
    WHERE pc.prot_amendment_id=pa.prot_amendment_id
     AND (pc.person_id=request->person_id)
     AND pc.not_returned_reason_cd=0
     AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND pc.consent_signed_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pecr
    WHERE (pecr.consent_id= Outerjoin(pc.consent_id)) )
   HEAD pc.consent_id
    IF (pecr.pt_elig_consent_reltn_id=0)
     reply->enrolling_consent = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  concheck = decode(con.seq,"CON","none")
  FROM pt_elig_tracking pet,
   prot_questionnaire pq,
   prot_amendment pa,
   person p,
   prot_master pm,
   dummyt d,
   pt_elig_consent_reltn pecr,
   pt_consent con
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
   JOIN (pq
   WHERE pq.prot_amendment_id=pa.prot_amendment_id)
   JOIN (pet
   WHERE pet.prot_questionnaire_id=pq.prot_questionnaire_id
    AND (pet.person_id=request->person_id)
    AND pet.last_attempt_indicator_cd=yes_cd)
   JOIN (p
   WHERE p.person_id=pet.elig_request_person_id)
   JOIN (d)
   JOIN (pecr
   WHERE pecr.pt_elig_tracking_id=pet.pt_elig_tracking_id)
   JOIN (con
   WHERE con.consent_id=pecr.consent_id
    AND con.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND con.not_returned_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND con.consent_signed_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
  ORDER BY pa.amendment_nbr
  HEAD REPORT
   reply->protocol_status = trim(uar_get_code_meaning(pm.prot_status_cd)), cnt = 0
  DETAIL
   IF ((pq.questionnaire_type_cd=request->questionnaire_type_cd))
    cnt += 1, bstat = alterlist(reply->assessments,cnt), reply->assessments[cnt].pt_elig_tracking_id
     = pet.pt_elig_tracking_id,
    reply->assessments[cnt].elig_status_cd = pet.elig_status_cd, reply->assessments[cnt].
    reason_ineligible_cd = pet.reason_ineligible_cd, reply->assessments[cnt].recorded_dt_tm = pet
    .beg_effective_dt_tm,
    reply->assessments[cnt].elig_request_person = p.name_full_formatted, reply->assessments[cnt].
    prot_amendment_id = pa.prot_amendment_id, reply->assessments[cnt].amendment_nbr = pa
    .amendment_nbr,
    reply->assessments[cnt].revision_ind = pa.revision_ind, reply->assessments[cnt].revision_nbr_txt
     = pa.revision_nbr_txt, reply->assessments[cnt].amendment_status = trim(uar_get_code_meaning(pa
      .amendment_status_cd)),
    reply->assessments[cnt].prot_questionnaire_id = pq.prot_questionnaire_id, reply->assessments[cnt]
    .questionnaire_name = pq.questionnaire_name,
    CALL echo(build("elig status Cd = ",pet.elig_status_cd)),
    CALL echo(build("reason ineligible Cd = ",pet.reason_ineligible_cd))
   ENDIF
   CALL echo(build("ConCheck = ",concheck))
   IF (((concheck="CON"
    AND ((pet.elig_status_cd=eligible_cd) OR (pet.elig_status_cd=elignoverif_cd)) ) OR (pet
   .elig_status_cd=incomplete_cd)) )
    pending_cnt += 1, bstat = alterlist(reply->pending_assessments,pending_cnt), reply->
    pending_assessments[pending_cnt].prot_questionnaire_id = pq.prot_questionnaire_id,
    reply->pending_assessments[pending_cnt].questionnaire_name = pq.questionnaire_name, reply->
    pending_assessments[pending_cnt].questionnaire_type_cd = pq.questionnaire_type_cd, reply->
    pending_assessments[pending_cnt].elig_status_cd = pet.elig_status_cd
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 CALL echo(build("cnt = ",cnt))
 IF (curqual > 0)
  IF (cnt=0)
   SET reply->status_data.status = "Q"
   IF ((reply->patient_enrolled=true)
    AND (request->questionnaire_type_cd=enrolling_cd))
    SET reply->status_data.status = "E"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF (curqual=0)
  IF ((reply->patient_enrolled=true)
   AND (request->questionnaire_type_cd=enrolling_cd))
   SET reply->status_data.status = "E"
  ELSEIF ((reply->enrolling_consent=1))
   SET reply->status_data.status = "C"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 IF ((reply->patient_enrolled=false))
  SET pmid = request->prot_master_id
  SET activeamdnbr = 0
  SET activeamdid = 0.0
  SET activerevisionind = 0
  SET activerevisionnbrtxt = ""
  EXECUTE ct_get_active_a_nbr
  SET reply->amendment_nbr = activeamdnbr
  SET reply->revision_nbr_txt = activerevisionnbrtxt
  SET reply->prot_amendment_id = activeamdid
 ELSE
  SET activeamdid = prot_amendment_id
  SELECT INTO "nl:"
   pa.amendment_nbr, pa.revision_nbr_txt
   FROM prot_amendment pa
   WHERE pa.prot_amendment_id=activeamdid
   DETAIL
    reply->amendment_nbr = pa.amendment_nbr, reply->revision_nbr_txt = pa.revision_nbr_txt, reply->
    amendment_status = uar_get_code_meaning(pa.amendment_status_cd),
    CALL echo(pa.amendment_nbr)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(activeamdid)
 SET questionnairecnt = 0
 SELECT INTO "nl:"
  pq.prot_questionnaire_id
  FROM prot_questionnaire pq,
   long_text_reference ltr
  PLAN (pq
   WHERE pq.prot_amendment_id=activeamdid
    AND (pq.questionnaire_type_cd=request->questionnaire_type_cd)
    AND pq.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ltr
   WHERE (ltr.long_text_id= Outerjoin(pq.desc_long_text_id)) )
  DETAIL
   questionnairecnt += 1, stat = alterlist(reply->questionnaires,questionnairecnt), reply->
   questionnaires[questionnairecnt].prot_questionnaire_id = pq.prot_questionnaire_id,
   reply->questionnaires[questionnairecnt].questionnaire_name = pq.questionnaire_name, reply->
   questionnaires[questionnairecnt].desc_text = ltr.long_text, reply->questionnaires[questionnairecnt
   ].desc_long_text_id = pq.desc_long_text_id
  WITH nocounter
 ;end select
 CALL echo(build("patient enrolled",reply->patient_enrolled))
#exit_script
 SET last_mod = "015"
 SET mod_date = "Nov 26, 2020"
END GO

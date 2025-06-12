CREATE PROGRAM bbd_get_patient_recip_info:dba
 RECORD reply(
   1 abo_cd = f8
   1 abo_disp = c15
   1 rh_cd = f8
   1 rh_disp = c15
   1 diagnosis = vc
   1 admit_dr_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET encntr_used = 0
 SET reply->diagnosis = ""
 SET reply->admit_dr_disp = ""
 SET reply->status_data.status = "I"
 SELECT INTO "nl:"
  p.*
  FROM person_aborh p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  DETAIL
   reply->abo_cd = p.abo_cd, reply->rh_cd = p.rh_cd
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->abo_cd = 0
  SET reply->rh_cd = 0
 ENDIF
 SET code_value = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(261,"ACTIVE",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_get_patient_recip_info"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 261 and ACTIVE"
  GO TO exit_script
 ENDIF
 SET encntr_active_cd = code_value
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e
  WHERE (e.person_id=request->person_id)
   AND e.active_ind=1
   AND e.encntr_status_cd=encntr_active_cd
  DETAIL
   reply->diagnosis = e.reason_for_visit, encntr_used = e.encntr_id
  WITH nocounter
 ;end select
 SET code_value = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_get_patient_recip_info"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 333 and ADMITDOC"
  GO TO exit_script
 ENDIF
 SET admit_doc_cd = code_value
 IF (encntr_used > 0)
  SELECT INTO "nl:"
   p.person_id, p.name_full_formatted, epr.seq
   FROM encntr_prsnl_reltn epr,
    prsnl p
   PLAN (epr
    WHERE epr.encntr_prsnl_r_cd=admit_doc_cd
     AND epr.encntr_id=encntr_used)
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
   DETAIL
    reply->admit_dr_disp = p.name_full_formatted
   WITH counter
  ;end select
  IF (curqual=0)
   SET reply->admit_dr_disp = ""
  ENDIF
  IF ((reply->status_data.status="I"))
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
END GO

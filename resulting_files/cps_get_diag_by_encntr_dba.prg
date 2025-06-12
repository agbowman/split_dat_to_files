CREATE PROGRAM cps_get_diag_by_encntr:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 diag_qual = i4
   1 diag[*]
     2 diagnosis_id = f8
     2 organization_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_desc = c60
     2 source_vocabulary_mean = c12
     2 diag_ftdesc = vc
     2 diag_dt_tm = dq8
     2 diag_type_cd = f8
     2 diagnostic_category_cd = f8
     2 diag_priority = i4
     2 diag_prsnl_id = f8
     2 diag_prsnl_name = vc
     2 diag_class_cd = f8
     2 confid_level_cd = f8
     2 attestation_dt_tm = dq8
     2 reference_nbr = vc
     2 seg_unique_key = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 principle_type_cd = f8
     2 originating_nomenclature_id = f8
     2 originating_source_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dfinal = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17,"FINAL",1,dfinal)
 DECLARE idx1 = i4 WITH noconstant(0), public
 IF ((request->qual_knt > 0))
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n,
    nomenclature n1,
    prsnl p,
    encounter e
   PLAN (d
    WHERE (d.person_id=request->person_id)
     AND expand(idx1,1,request->qual_knt,d.encntr_id,request->qual[idx1].encntr_id,
     request->qual_knt)
     AND d.active_ind=1
     AND (((request->zero_dx_type_ind=1)
     AND d.diag_type_cd=0) OR ((((request->final_dx_type_ind=1)
     AND d.diag_type_cd=dfinal) OR ((request->final_dx_type_ind=0)
     AND (request->zero_dx_type_ind=0))) )) )
    JOIN (e
    WHERE e.encntr_id=d.encntr_id)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
    JOIN (n1
    WHERE (n1.nomenclature_id= Outerjoin(d.originating_nomenclature_id)) )
    JOIN (p
    WHERE p.person_id=d.diag_prsnl_id)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->diag,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->diag,(knt+ 9))
    ENDIF
    reply->diag[knt].diagnosis_id = d.diagnosis_id, reply->diag[knt].organization_id = e
    .organization_id, reply->diag[knt].person_id = d.person_id,
    reply->diag[knt].encntr_id = d.encntr_id, reply->diag[knt].nomenclature_id = n.nomenclature_id
    IF (n.source_string > " ")
     reply->diag[knt].source_string = n.source_string
    ELSE
     reply->diag[knt].source_string = d.diag_ftdesc
    ENDIF
    reply->diag[knt].source_identifier = n.source_identifier, reply->diag[knt].source_vocabulary_cd
     = n.source_vocabulary_cd, reply->diag[knt].diag_ftdesc = d.diag_ftdesc,
    reply->diag[knt].diag_dt_tm = d.diag_dt_tm, reply->diag[knt].diag_type_cd = d.diag_type_cd, reply
    ->diag[knt].diagnostic_category_cd = d.diagnostic_category_cd,
    reply->diag[knt].diag_priority = d.diag_priority, reply->diag[knt].diag_prsnl_id = d
    .diag_prsnl_id, reply->diag[knt].diag_prsnl_name = p.name_full_formatted,
    reply->diag[knt].diag_class_cd = d.diag_class_cd, reply->diag[knt].confid_level_cd = d
    .confid_level_cd, reply->diag[knt].attestation_dt_tm = d.attestation_dt_tm,
    reply->diag[knt].reference_nbr = d.reference_nbr, reply->diag[knt].seg_unique_key = d
    .seg_unique_key, reply->diag[knt].beg_effective_dt_tm = d.beg_effective_dt_tm,
    reply->diag[knt].end_effective_dt_tm = d.end_effective_dt_tm, reply->diag[knt].
    contributor_system_cd = d.contributor_system_cd, reply->diag[knt].principle_type_cd = n
    .principle_type_cd
    IF (n1.nomenclature_id > 0)
     stat = assign(validate(reply->diag[knt].originating_nomenclature_id),n1.nomenclature_id), stat
      = assign(validate(reply->diag[knt].originating_source_string),n1.source_string)
    ELSE
     stat = assign(validate(reply->diag[knt].originating_nomenclature_id),0.0), stat = assign(
      validate(reply->diag[knt].originating_source_string)," ")
    ENDIF
   FOOT REPORT
    reply->diag_qual = knt, stat = alterlist(reply->diag,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DIAGNOSIS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSEIF ((reply->diag_qual < 1))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SELECT
   IF ((request->ex_encntr_id > 0))
    PLAN (d
     WHERE (d.person_id=request->person_id)
      AND (d.encntr_id != request->ex_encntr_id)
      AND d.active_ind=1
      AND (((request->zero_dx_type_ind=1)
      AND d.diag_type_cd=0) OR ((((request->final_dx_type_ind=1)
      AND d.diag_type_cd=dfinal) OR ((request->final_dx_type_ind=0)
      AND (request->zero_dx_type_ind=0))) )) )
     JOIN (e
     WHERE e.encntr_id=d.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=d.nomenclature_id)
     JOIN (n1
     WHERE (n1.nomenclature_id= Outerjoin(d.originating_nomenclature_id)) )
     JOIN (p
     WHERE p.person_id=d.diag_prsnl_id)
   ELSE
    PLAN (d
     WHERE (d.person_id=request->person_id)
      AND d.active_ind=1
      AND (((request->zero_dx_type_ind=1)
      AND d.diag_type_cd=0) OR ((((request->final_dx_type_ind=1)
      AND d.diag_type_cd=dfinal) OR ((request->final_dx_type_ind=0)
      AND (request->zero_dx_type_ind=0))) )) )
     JOIN (e
     WHERE e.encntr_id=d.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=d.nomenclature_id)
     JOIN (n1
     WHERE (n1.nomenclature_id= Outerjoin(d.originating_nomenclature_id)) )
     JOIN (p
     WHERE p.person_id=d.diag_prsnl_id)
   ENDIF
   INTO "nl:"
   FROM diagnosis d,
    nomenclature n,
    nomenclature n1,
    prsnl p,
    encounter e
   HEAD REPORT
    knt = 0, stat = alterlist(reply->diag,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->diag,(knt+ 9))
    ENDIF
    reply->diag[knt].diagnosis_id = d.diagnosis_id, reply->diag[knt].organization_id = e
    .organization_id, reply->diag[knt].person_id = d.person_id,
    reply->diag[knt].encntr_id = d.encntr_id, reply->diag[knt].nomenclature_id = n.nomenclature_id
    IF (n.nomenclature_id > 0)
     reply->diag[knt].source_string = n.source_string
    ELSE
     reply->diag[knt].source_string = d.diag_ftdesc
    ENDIF
    reply->diag[knt].source_identifier = n.source_identifier, reply->diag[knt].source_vocabulary_cd
     = n.source_vocabulary_cd, reply->diag[knt].diag_ftdesc = d.diag_ftdesc,
    reply->diag[knt].diag_dt_tm = d.diag_dt_tm, reply->diag[knt].diag_type_cd = d.diag_type_cd, reply
    ->diag[knt].diagnostic_category_cd = d.diagnostic_category_cd,
    reply->diag[knt].diag_priority = d.diag_priority, reply->diag[knt].diag_prsnl_id = d
    .diag_prsnl_id, reply->diag[knt].diag_prsnl_name = p.name_full_formatted,
    reply->diag[knt].diag_class_cd = d.diag_class_cd, reply->diag[knt].confid_level_cd = d
    .confid_level_cd, reply->diag[knt].attestation_dt_tm = d.attestation_dt_tm,
    reply->diag[knt].reference_nbr = d.reference_nbr, reply->diag[knt].seg_unique_key = d
    .seg_unique_key, reply->diag[knt].beg_effective_dt_tm = d.beg_effective_dt_tm,
    reply->diag[knt].end_effective_dt_tm = d.end_effective_dt_tm, reply->diag[knt].
    contributor_system_cd = d.contributor_system_cd, reply->diag[knt].principle_type_cd = n
    .principle_type_cd
    IF (n1.nomenclature_id > 0)
     stat = assign(validate(reply->diag[knt].originating_nomenclature_id),n1.nomenclature_id), stat
      = assign(validate(reply->diag[knt].originating_source_string),n1.source_string)
    ELSE
     stat = assign(validate(reply->diag[knt].originating_nomenclature_id),0.0), stat = assign(
      validate(reply->diag[knt].originating_source_string)," ")
    ENDIF
   FOOT REPORT
    reply->diag_qual = knt, stat = alterlist(reply->diag,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DIAGNOSIS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSEIF ((reply->diag_qual < 1))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL auditdiagnosisaccess(reply)
 SUBROUTINE (auditdiagnosisaccess(reply_record=vc(ref)) =null)
   SET modify = hipaa
   SET cclaud->hipaamode = 0
   DECLARE ldiagnosistotal = i4 WITH private, constant(size(reply_record->diag,5))
   DECLARE ldiagnosisindex = i4 WITH protect, noconstant(0)
   FOR (ldiagnosisindex = 1 TO ldiagnosistotal)
     EXECUTE cclaudit 0, "Query Encounter", "Diagnosis",
     "Encounter", "Patient", "Encounter",
     "Access/Use", reply_record->diag[ldiagnosisindex].encntr_id, trim(build("DIAGNOSIS_ID=",
       reply_record->diag[ldiagnosisindex].diagnosis_id))
   ENDFOR
 END ;Subroutine
#exit_script
 SET script_version = "MOD 007 04/30/2024 KS2604"
END GO

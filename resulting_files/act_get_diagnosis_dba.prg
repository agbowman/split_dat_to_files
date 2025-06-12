CREATE PROGRAM act_get_diagnosis:dba
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
 FREE SET reply
 RECORD reply(
   1 diag_qual = i4
   1 diag[*]
     2 diagnosis_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 nomenclature_id = f8
     2 diag_dt_tm = dq8
     2 diag_type_cd = f8
     2 diagnostic_category_cd = f8
     2 diag_priority = i4
     2 diag_prsnl_id = f8
     2 diag_class_cd = f8
     2 confid_level_cd = f8
     2 attestation_dt_tm = dq8
     2 reference_nbr = vc
     2 seg_unique_key = vc
     2 diag_ftdesc = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 source_string = vc
     2 string_identifier = c18
     2 source_identifier = vc
     2 ranking_cd = f8
     2 confirmation_status_cd = f8
     2 clinical_service_cd = f8
     2 comment = vc
     2 comment_updt_id = f8
     2 comment_updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT
  IF ((request->except_encntr_ind=1)
   AND (request->encntr_id > 0))
   PLAN (d
    WHERE (d.person_id=request->person_id)
     AND (d.encntr_id != request->encntr_id)
     AND d.active_ind=1
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSEIF ((request->person_id > 0)
   AND (request->encntr_id=0)
   AND (request->diag_id=0))
   PLAN (d
    WHERE (request->person_id=d.person_id)
     AND d.active_ind=1
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSEIF ((request->person_id=0)
   AND (request->encntr_id > 0)
   AND (request->diag_id=0))
   PLAN (d
    WHERE (request->encntr_id=d.encntr_id)
     AND d.active_ind=1
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSEIF ((request->person_id=0)
   AND (request->encntr_id=0)
   AND (request->diag_id > 0))
   PLAN (d
    WHERE (request->diag_id=d.diagnosis_id)
     AND d.active_ind=1
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSEIF ((request->person_id > 0)
   AND (request->encntr_id > 0)
   AND (request->diag_id=0))
   PLAN (d
    WHERE (request->person_id=d.person_id)
     AND d.active_ind=1
     AND (request->encntr_id=d.encntr_id)
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSEIF ((request->person_id > 0)
   AND (request->encntr_id=0)
   AND (request->diag_id > 0))
   PLAN (d
    WHERE (request->diag_id=d.diagnosis_id)
     AND d.active_ind=1
     AND (request->person_id=d.person_id)
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSEIF ((request->person_id=0)
   AND (request->encntr_id > 0)
   AND (request->diag_id > 0))
   PLAN (d
    WHERE (request->diag_id=d.diagnosis_id)
     AND d.active_ind=1
     AND (request->encntr_id=d.encntr_id)
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ELSE
   PLAN (d
    WHERE (request->diag_id=d.diagnosis_id)
     AND (request->encntr_id=d.encntr_id)
     AND (request->person_id=d.person_id)
     AND d.active_ind=1
     AND ((d.nomenclature_id > 0) OR (d.diag_ftdesc > " "))
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.long_blob_id=outerjoin(d.long_blob_id)
     AND l.active_ind=outerjoin(1))
  ENDIF
  INTO "NL:"
  FROM diagnosis d,
   long_blob l
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->diag,10)
  DETAIL
   count1 = (count1+ 1)
   IF (size(reply->diag,5) > count1)
    stat = alterlist(reply->diag,(count1+ 5))
   ENDIF
   reply->diag[count1].diagnosis_id = d.diagnosis_id, reply->diag[count1].person_id = d.person_id,
   reply->diag[count1].encntr_id = d.encntr_id,
   reply->diag[count1].nomenclature_id = d.nomenclature_id, reply->diag[count1].diag_dt_tm = d
   .diag_dt_tm, reply->diag[count1].diag_type_cd = d.diag_type_cd,
   reply->diag[count1].diagnostic_category_cd = d.diagnostic_category_cd, reply->diag[count1].
   diag_priority = d.diag_priority, reply->diag[count1].diag_prsnl_id = d.diag_prsnl_id,
   reply->diag[count1].diag_class_cd = d.diag_class_cd, reply->diag[count1].confid_level_cd = d
   .confid_level_cd, reply->diag[count1].attestation_dt_tm = d.attestation_dt_tm,
   reply->diag[count1].reference_nbr = d.reference_nbr, reply->diag[count1].seg_unique_key = d
   .seg_unique_key, reply->diag[count1].diag_ftdesc = d.diag_ftdesc,
   reply->diag[count1].active_ind = d.active_ind, reply->diag[count1].active_status_cd = d
   .active_status_cd, reply->diag[count1].active_status_dt_tm = d.active_status_dt_tm,
   reply->diag[count1].active_status_prsnl_id = d.active_status_prsnl_id, reply->diag[count1].
   beg_effective_dt_tm = d.beg_effective_dt_tm, reply->diag[count1].end_effective_dt_tm = d
   .end_effective_dt_tm,
   reply->diag[count1].contributor_system_cd = d.contributor_system_cd, reply->diag[count1].updt_id
    = d.updt_id, reply->diag[count1].updt_dt_tm = d.updt_dt_tm,
   reply->diag[count1].ranking_cd = d.ranking_cd, reply->diag[count1].confirmation_status_cd = d
   .confirmation_status_cd, reply->diag[count1].clinical_service_cd = d.clinical_service_cd,
   reply->diag[count1].comment = l.long_blob, reply->diag[count1].comment_updt_id = l.updt_id, reply
   ->diag[count1].comment_updt_dt_tm = l.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->diag,count1), reply->diag_qual = count1
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
END GO

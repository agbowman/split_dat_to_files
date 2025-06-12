CREATE PROGRAM cps_get_encounter:dba
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
   1 encounter_qual = i4
   1 encounter[*]
     2 encntr_id = f8
     2 beg_effective_dt_tm = dq8
     2 encntr_type_cd = f8
     2 encntr_type_disp = c40
     2 encntr_type_desc = c60
     2 encntr_type_mean = c12
     2 encntr_type_class_cd = f8
     2 encntr_type_class_disp = c40
     2 encntr_type_class_desc = c60
     2 encntr_type_class_mean = c12
     2 encntr_status_cd = f8
     2 financial_class_cd = f8
     2 financial_class_disp = c40
     2 pre_reg_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 arrive_dt_tm = dq8
     2 admit_type_cd = f8
     2 admit_type_disp = c40
     2 admit_type_desc = c60
     2 admit_type_mean = c12
     2 referring_comment = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = c40
     2 loc_facility_desc = c60
     2 loc_facility_mean = c12
     2 loc_building_cd = f8
     2 loc_building_disp = c40
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = c40
     2 loc_nurse_unit_desc = c60
     2 loc_nurse_unit_mean = c12
     2 reason_for_visit = vc
     2 disch_dt_tm = dq8
     2 encntr_prsnl_r_cd = f8
     2 encntr_prsnl_r_disp = c40
     2 provider_name = vc
     2 reltn_knt = i4
     2 reltn[*]
       3 reltn_cd = f8
       3 person_id = f8
       3 person_name = vc
       3 beg_effective_dt_tm = dq8
       3 expiration_ind = i2
       3 expire_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cancelled_cd = 0.0
 SET code_value = 0.0
 SET code_set = 261
 SET cdf_meaning = "CANCELLED"
 EXECUTE cpm_get_cd_for_cdf
 SET cancelled_cd = code_value
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  e.encntr_id, e.reg_dt_tm
  FROM encounter e
  PLAN (e
   WHERE (e.person_id=request->person_id)
    AND e.encntr_status_cd != cancelled_cd
    AND e.active_ind=1
    AND e.encntr_id > 0)
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id
  HEAD REPORT
   knt = 0, stat = alterlist(reply->encounter,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->encounter,(knt+ 9))
   ENDIF
   reply->encounter[knt].encntr_id = e.encntr_id, reply->encounter[knt].beg_effective_dt_tm = e
   .beg_effective_dt_tm, reply->encounter[knt].encntr_type_cd = e.encntr_type_cd,
   reply->encounter[knt].encntr_status_cd = e.encntr_status_cd, reply->encounter[knt].
   encntr_type_class_cd = e.encntr_type_class_cd, reply->encounter[knt].financial_class_cd = e
   .financial_class_cd,
   reply->encounter[knt].pre_reg_dt_tm = e.pre_reg_dt_tm, reply->encounter[knt].reg_dt_tm = e
   .reg_dt_tm, reply->encounter[knt].arrive_dt_tm = e.arrive_dt_tm,
   reply->encounter[knt].admit_type_cd = e.admit_type_cd, reply->encounter[knt].referring_comment = e
   .referring_comment, reply->encounter[knt].loc_facility_cd = e.loc_facility_cd,
   reply->encounter[knt].loc_building_cd = e.loc_building_cd, reply->encounter[knt].loc_nurse_unit_cd
    = e.loc_nurse_unit_cd, reply->encounter[knt].reason_for_visit = e.reason_for_visit,
   reply->encounter[knt].disch_dt_tm = e.disch_dt_tm
  FOOT REPORT
   reply->encounter_qual = knt, stat = alterlist(reply->encounter,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCOUNTER"
  GO TO exit_script
 ENDIF
 IF ((reply->encounter_qual < 1))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = fillstring(12," ")
 SET rank_found = 5
 SET code_set = 333
 SET code_value = 0.0
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attenddoc_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admitdoc_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "ORDERDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET orderdoc_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "REFERDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET referdoc_cd = code_value
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, epr.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(reply->encounter_qual)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (epr
   WHERE (epr.encntr_id=reply->encounter[d.seq].encntr_id)
    AND epr.encntr_prsnl_r_cd IN (attenddoc_cd, admitdoc_cd, orderdoc_cd, referdoc_cd)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND ((p.physician_ind+ 0)=1))
  ORDER BY d.seq, epr.beg_effective_dt_tm DESC
  HEAD d.seq
   rank_found = 5
  DETAIL
   IF (rank_found > 1)
    IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
     reply->encounter[d.seq].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[d.seq].
     provider_name = p.name_full_formatted, rank_found = 1
    ENDIF
    IF (rank_found > 2)
     IF (epr.encntr_prsnl_r_cd=admitdoc_cd)
      reply->encounter[d.seq].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[d.seq].
      provider_name = p.name_full_formatted, rank_found = 2
     ENDIF
     IF (rank_found > 3)
      IF (epr.encntr_prsnl_r_cd=orderdoc_cd)
       reply->encounter[d.seq].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[d.seq].
       provider_name = p.name_full_formatted, rank_found = 3
      ENDIF
      IF (rank_found > 4)
       IF (epr.encntr_prsnl_r_cd=referdoc_cd)
        reply->encounter[d.seq].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[d.seq].
        provider_name = p.name_full_formatted, rank_found = 4
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
 IF ((((reply->encounter_qual < 1)) OR ((request->reltn_knt < 1))) )
  GO TO exit_script
 ELSEIF ((request->reltn_knt < 1))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d1.seq, d2.seq, epr.beg_effective_dt_tm
  FROM (dummyt d1  WITH seq = value(reply->encounter_qual)),
   (dummyt d2  WITH seq = value(request->reltn_knt)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0)
   JOIN (epr
   WHERE (epr.encntr_id=reply->encounter[d1.seq].encntr_id)
    AND (epr.encntr_prsnl_r_cd=request->reltn[d2.seq].reltn_cd)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  ORDER BY d1.seq, epr.encntr_prsnl_r_cd, epr.beg_effective_dt_tm DESC
  HEAD d1.seq
   knt = 0, stat = alterlist(reply->encounter[d1.seq].reltn,10)
  HEAD epr.encntr_prsnl_r_cd
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->encounter[d1.seq].reltn,(knt+ 9))
   ENDIF
   reply->encounter[d1.seq].reltn[knt].reltn_cd = epr.encntr_prsnl_r_cd, reply->encounter[d1.seq].
   reltn[knt].person_id = p.person_id, reply->encounter[d1.seq].reltn[knt].person_name = p
   .name_full_formatted,
   reply->encounter[d1.seq].reltn[knt].beg_effective_dt_tm = epr.beg_effective_dt_tm, reply->
   encounter[d1.seq].reltn[knt].expiration_ind = epr.expiration_ind, reply->encounter[d1.seq].reltn[
   knt].expire_dt_tm = epr.expire_dt_tm
  FOOT  d1.seq
   reply->encounter[d1.seq].reltn_knt = knt, stat = alterlist(reply->encounter[d1.seq].reltn,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->encounter_qual > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_program
 SET script_version = "014 03/20/01 SF3151"
END GO

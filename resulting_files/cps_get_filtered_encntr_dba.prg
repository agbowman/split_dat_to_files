CREATE PROGRAM cps_get_filtered_encntr:dba
 SET the_date_tm = cnvtdatetime(curdate,curtime3)
 FREE SET reply
 RECORD reply(
   1 best_encntr_id = f8
   1 pref_match = i2
   1 encounter_qual = i4
   1 encounter[*]
     2 pref_match = i2
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
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = c40
     2 loc_nurse_unit_desc = c60
     2 loc_nurse_unit_mean = c12
     2 reason_for_visit = vc
     2 disch_dt_tm = dq8
     2 encntr_prsnl_r_cd = f8
     2 encntr_prsnl_r_disp = c40
     2 provider_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp1
 RECORD temp1(
   1 elist[*]
     2 el
       3 encntr_id = f8
       3 reg_dt_tm = dq8
       3 reg_dt_null = i2
       3 disch_dt_tm = dq8
       3 disch_dt_null = i2
       3 encntr_type_class_cd = f8
       3 encntr_status_cd = f8
 )
 FREE SET temp2
 RECORD temp2(
   1 elist[*]
     2 el
       3 encntr_id = f8
       3 reg_dt_tm = dq8
       3 reg_dt_null = i2
       3 disch_dt_tm = dq8
       3 disch_dt_null = i2
       3 encntr_type_class_cd = f8
       3 encntr_status_cd = f8
 )
 FREE SET encntr_type
 RECORD encntr_type(
   1 encntr_qual[*]
     2 encntr_type = vc
     2 type_cd = f8
 )
 FREE SET encntr_status
 RECORD encntr_status(
   1 status_qual[*]
     2 encntr_status = vc
     2 status_cd = f8
 )
 SET encntr_future_display = 1
 SET encntr_type_ind = 1
 SET encntr_status_ind = 1
 SET cdf_meaning = fillstring(12," ")
 SET cancelled_cd = 0.0
 SET code_value = 0.0
 SET code_set = 261
 SET cdf_meaning = "CANCELLED"
 EXECUTE cpm_get_cd_for_cdf
 SET cancelled_cd = code_value
 SET disch_cd = 0.0
 SET code_value = 0.0
 SET code_set = 261
 SET cdf_meaning = "DISCHARGED"
 EXECUTE cpm_get_cd_for_cdf
 SET disch_cd = code_value
 IF ((request->use_filters=0))
  GO TO get_all
 ENDIF
 SELECT INTO "NL:"
  a.app_prefs_id, n.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE (a.application_number=reqinfo->updt_app)
    AND a.prsnl_id < 1
    AND a.position_cd < 1)
   JOIN (n
   WHERE n.parent_entity_name="APP_PREFS"
    AND n.parent_entity_id=a.app_prefs_id
    AND n.pvc_name="ENCNTR_TYPE_DISPLAY")
  HEAD REPORT
   count1 = 0, start = 1
   FOR (i = 1 TO 256)
     IF (substring(i,1,n.pvc_value) IN (",", " "))
      count1 = (count1+ 1)
      IF (size(encntr_type->encntr_qual,5) <= count1)
       stat = alterlist(encntr_type->encntr_qual,count1)
      ENDIF
      encntr_type->encntr_qual[count1].encntr_type = substring(start,(i - start),n.pvc_value), start
       = (i+ 1)
      IF (substring(i,1,n.pvc_value)=" ")
       i = 256
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET encntr_type_ind = 0
 ELSE
  SELECT INTO "nl:"
   c.cdf_meaning
   FROM code_value c,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (c
    WHERE c.code_set=69
     AND (c.display_key=encntr_type->encntr_qual[d.seq].encntr_type))
   HEAD c.cdf_meaning
    encntr_type->encntr_qual[d.seq].type_cd = c.code_value
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET encntr_type_ind = 0
  ELSE
   SET encntr_type_ind = 1
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  a.app_prefs_id, n.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE (a.application_number=reqinfo->updt_app)
    AND a.prsnl_id < 1
    AND a.position_cd < 1)
   JOIN (n
   WHERE n.parent_entity_name="APP_PREFS"
    AND n.parent_entity_id=a.app_prefs_id
    AND n.pvc_name="ENCNTR_STATUS_DISPLAY")
  HEAD REPORT
   count1 = 0, start = 1
   FOR (i = 1 TO 256)
     IF (substring(i,1,n.pvc_value) IN (",", " "))
      count1 = (count1+ 1)
      IF (size(encntr_status->status_qual,5) <= count1)
       stat = alterlist(encntr_status->status_qual,count1)
      ENDIF
      encntr_status->status_qual[count1].encntr_status = substring(start,(i - start),n.pvc_value),
      start = (i+ 1)
      IF (substring(i,1,n.pvc_value)=" ")
       i = 256
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET encntr_status_ind = 0
 ELSE
  SELECT INTO "nl:"
   c.cdf_meaning
   FROM code_value c,
    (dummyt d  WITH seq = value(size(encntr_status->status_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (c
    WHERE c.code_set=261
     AND (c.cdf_meaning=encntr_status->status_qual[d.seq].encntr_status))
   HEAD c.cdf_meaning
    encntr_status->status_qual[d.seq].status_cd = c.code_value
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET encntr_status_ind = 0
  ELSE
   SET encntr_status_ind = 1
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  a.app_prefs_id, n.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE (a.application_number=reqinfo->updt_app)
    AND a.prsnl_id < 1
    AND a.position_cd < 1)
   JOIN (n
   WHERE n.parent_entity_name="APP_PREFS"
    AND n.parent_entity_id=a.app_prefs_id
    AND n.pvc_name="ENCNTR_FUTURE_DISPLAY")
  HEAD REPORT
   encntr_future_display = cnvtint(n.pvc_value)
  WITH nocounter
 ;end select
 IF (encntr_type_ind=1
  AND encntr_status_ind=1)
  GO TO get_type_status
 ELSEIF (encntr_type_ind=1)
  GO TO get_type
 ELSEIF (encntr_status_ind=1)
  GO TO get_status
 ELSE
  GO TO get_all
 ENDIF
#get_type_status
 SELECT
  IF (encntr_future_display=1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_type_class_cd=encntr_type->encntr_qual[d.seq].type_cd)
     AND (e.encntr_status_cd=encntr_status->status_qual[d1.seq].status_cd)
     AND e.encntr_status_cd != cancelled_cd
     AND e.active_ind=1)
  ELSE
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_type_class_cd=encntr_type->encntr_qual[d.seq].type_cd)
     AND (e.encntr_status_cd=encntr_status->status_qual[d1.seq].status_cd)
     AND e.reg_dt_tm <= cnvtdatetime(curdate,curtime)
     AND e.encntr_status_cd != cancelled_cd
     AND e.active_ind=1)
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  FROM encounter e,
   (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
   (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5)))
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(temp1->elist,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   temp1->elist[knt].el.encntr_id = e.encntr_id
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
   temp1->elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd, temp1->elist[knt].el.
   encntr_status_cd = e.encntr_status_cd
  FOOT REPORT
   stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 GO TO find_best
#get_type
 SELECT
  IF (encntr_future_display=1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_type_class_cd=encntr_type->encntr_qual[d.seq].type_cd)
     AND e.encntr_status_cd != cancelled_cd
     AND e.active_ind=1)
  ELSE
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_type_class_cd=encntr_type->encntr_qual[d.seq].type_cd)
     AND e.encntr_status_cd != cancelled_cd
     AND e.reg_dt_tm <= cnvtdatetime(curdate,curtime)
     AND e.active_ind=1)
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  FROM encounter e,
   (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5)))
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(temp1->elist,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   temp1->elist[knt].el.encntr_id = e.encntr_id
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
   temp1->elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd, temp1->elist[knt].el.
   encntr_status_cd = e.encntr_status_cd
  FOOT REPORT
   stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 GO TO find_best
#get_status
 SELECT
  IF (encntr_future_display=1)
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_status_cd=encntr_status->status_qual[d1.seq].status_cd)
     AND e.encntr_status_cd != cancelled_cd
     AND e.active_ind=1)
  ELSE
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_status_cd=encntr_status->status_qual[d1.seq].status_cd)
     AND e.encntr_status_cd != cancelled_cd
     AND e.reg_dt_tm <= cnvtdatetime(curdate,curtime)
     AND e.active_ind=1)
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  FROM encounter e,
   (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5)))
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(temp1->elist,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   temp1->elist[knt].el.encntr_id = e.encntr_id
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
   temp1->elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd, temp1->elist[knt].el.
   encntr_status_cd = e.encntr_status_cd
  FOOT REPORT
   stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 GO TO find_best
#get_all
 SELECT
  IF (encntr_future_display=1)
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND e.encntr_status_cd != cancelled_cd
     AND e.active_ind=1)
  ELSE
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND e.encntr_status_cd != cancelled_cd
     AND e.reg_dt_tm <= cnvtdatetime(curdate,curtime)
     AND e.active_ind=1)
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  FROM encounter e
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(temp1->elist,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   temp1->elist[knt].el.encntr_id = e.encntr_id
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
   temp1->elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd, temp1->elist[knt].el.
   encntr_status_cd = e.encntr_status_cd
  FOOT REPORT
   stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 GO TO find_best
#find_best
 SET knt1 = size(temp1->elist,5)
 SET knt2 = 0
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
 SELECT DISTINCT INTO "NL:"
  e.encntr_id, e.reg_dt_tm, epr.beg_effective_dt_tm,
  disch_null = nullind(e.disch_dt_tm), reg_null = nullind(e.reg_dt_tm)
  FROM encounter e,
   encntr_prsnl_reltn epr,
   prsnl p,
   (dummyt d  WITH seq = 1)
  PLAN (e
   WHERE (e.person_id=request->person_id)
    AND e.encntr_status_cd != cancelled_cd
    AND e.active_ind=1
    AND e.encntr_id > 0)
   JOIN (d
   WHERE d.seq=1)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd IN (attenddoc_cd, admitdoc_cd, orderdoc_cd, referdoc_cd)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND ((p.physician_ind+ 0)=1))
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC, cnvtdatetime(epr.beg_effective_dt_tm)
    DESC
  HEAD REPORT
   kount = 0, stat = alterlist(reply->encounter,10)
   IF (knt1 < 1)
    stat = alterlist(temp1->elist,10)
   ENDIF
  HEAD e.encntr_id
   kount = (kount+ 1)
   IF (mod(kount,10)=1
    AND kount != 1)
    stat = alterlist(reply->encounter,(kount+ 9))
   ENDIF
   reply->encounter[kount].encntr_id = e.encntr_id, reply->encounter[kount].beg_effective_dt_tm = e
   .beg_effective_dt_tm, reply->encounter[kount].encntr_type_cd = e.encntr_type_cd,
   reply->encounter[kount].encntr_status_cd = e.encntr_status_cd, reply->encounter[kount].
   encntr_type_class_cd = e.encntr_type_class_cd, reply->encounter[kount].pre_reg_dt_tm = e
   .pre_reg_dt_tm,
   reply->encounter[kount].reg_dt_tm = e.reg_dt_tm, reply->encounter[kount].arrive_dt_tm = e
   .arrive_dt_tm, reply->encounter[kount].admit_type_cd = e.admit_type_cd,
   reply->encounter[kount].referring_comment = e.referring_comment, reply->encounter[kount].
   loc_facility_cd = e.loc_facility_cd, reply->encounter[kount].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd,
   reply->encounter[kount].reason_for_visit = e.reason_for_visit, reply->encounter[kount].disch_dt_tm
    = e.disch_dt_tm, rank_found = 5
   IF (knt1 < 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alterlist(temp1->elist,(kount+ 9))
    ENDIF
    temp1->elist[kount].el.encntr_id = e.encntr_id
    IF (reg_null=0)
     temp1->elist[kount].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[kount].el.reg_dt_null
      = 0
    ELSE
     temp1->elist[kount].el.reg_dt_null = 1
    ENDIF
    IF (disch_null=0)
     temp1->elist[kount].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[kount].el.
     disch_dt_null = 0
    ELSE
     temp1->elist[kount].el.disch_dt_null = 1
    ENDIF
    temp1->elist[kount].el.encntr_type_class_cd = e.encntr_type_class_cd, temp1->elist[kount].el.
    encntr_status_cd = e.encntr_status_cd
   ENDIF
  DETAIL
   IF (rank_found > 1)
    IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
     reply->encounter[kount].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[kount].
     provider_name = p.name_full_formatted, rank_found = 1
    ENDIF
    IF (rank_found > 2)
     IF (epr.encntr_prsnl_r_cd=admitdoc_cd)
      reply->encounter[kount].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[kount].
      provider_name = p.name_full_formatted, rank_found = 2
     ENDIF
     IF (rank_found > 3)
      IF (epr.encntr_prsnl_r_cd=orderdoc_cd)
       reply->encounter[kount].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[kount].
       provider_name = p.name_full_formatted, rank_found = 3
      ENDIF
      IF (rank_found > 4)
       IF (epr.encntr_prsnl_r_cd=referdoc_cd)
        reply->encounter[kount].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->encounter[kount].
        provider_name = p.name_full_formatted, rank_found = 4
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   reply->encounter_qual = kount, stat = alterlist(reply->encounter,kount)
   IF (knt1 < 1)
    stat = alterlist(temp1->elist,kount)
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (knt1 > 0)
  SET reply->pref_match = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(knt1)),
    (dummyt d2  WITH seq = value(reply->encounter_qual))
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE (reply->encounter[d2.seq].encntr_id=temp1->elist[d1.seq].el.encntr_id))
   DETAIL
    reply->encounter[d2.seq].pref_match = 1
   WITH nocounter
  ;end select
 ELSE
  SET reply->pref_match = 0
  SET knt1 = size(temp1->elist,5)
 ENDIF
 IF (knt1=1)
  SET reply->best_encntr_id = temp1->elist[knt1].el.encntr_id
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF ((reqinfo->updt_app != 600005))
  GO TO skip_inpat_check
 ENDIF
 SET code_value = 0.0
 SET code_set = 69
 SET cdf_meaning = "INPATIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET inpatient_cd = code_value
 FOR (x = 1 TO knt1)
   IF ((temp1->elist[x].el.encntr_type_class_cd != inpatient_cd))
    SET knt2 = knt2
   ELSE
    SET knt2 = (knt2+ 1)
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
#skip_inpat_check
 IF ((reqinfo->updt_app != 961000))
  GO TO skip_outpat_check
 ENDIF
 SET code_value = 0.0
 SET code_set = 69
 SET cdf_meaning = "OUTPATIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET outpatient_cd = code_value
 FOR (x = 1 TO knt1)
   IF ((temp1->elist[x].el.encntr_type_class_cd != outpatient_cd))
    SET knt2 = knt2
   ELSE
    SET knt2 = (knt2+ 1)
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
#skip_outpat_check
 FOR (x = 1 TO knt1)
   IF ((((temp1->elist[x].el.encntr_status_cd=disch_cd)) OR ((temp1->elist[x].el.disch_dt_null=0)
    AND (temp1->elist[x].el.disch_dt_tm < cnvtdatetime(curdate,0)))) )
    SET knt2 = knt2
   ELSE
    SET knt2 = (knt2+ 1)
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
 FOR (x = 1 TO knt1)
   IF ((((temp1->elist[x].el.reg_dt_null=1)) OR ((temp1->elist[x].el.reg_dt_tm > cnvtdatetime(curdate,
    curtime)))) )
    SET knt2 = knt2
   ELSE
    SET knt2 = (knt2+ 1)
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
 IF (datetimediff(cnvtdatetime(the_date_tm),cnvtdatetime(temp1->elist[knt1].reg_dt_tm)) <= 0)
  SET reply->best_encntr_id = temp1->elist[knt1].el.encntr_id
  SET reply->status_data.status = "S"
 ELSE
  SET reply->best_encntr_id = temp1->elist[1].el.encntr_id
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 IF ((reply->pref_match < 1))
  SET reply->best_encntr_id = - (1.0)
 ENDIF
END GO

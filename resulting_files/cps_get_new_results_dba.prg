CREATE PROGRAM cps_get_new_results:dba
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
   1 qual_knt = i4
   1 qual[*]
     2 person_id = f8
     2 new_result_ind = i2
     2 check_events_ind = i2
     2 bookmark_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET review_type_cd = 0.0
 SET code_set = 104
 SET cdf_meaning = "RESULT REVIE"
 EXECUTE cpm_get_cd_for_cdf
 SET review_type_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Failed to get code_value for cdf_meaning ",trim(cdf_meaning)," from code_set ",trim(cnvtstring(
     code_set)))
  GO TO exit_script
 ENDIF
 IF ((request->since_dt_tm < 1))
  SET request->since_dt_tm = cnvtdatetime((curdate - 31),0)
 ENDIF
 IF ((request->event_set_qual > 0))
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq
   FROM v500_event_set_code es,
    (dummyt d  WITH seq = value(request->event_set_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (es
    WHERE (es.event_set_name=request->event_set[d.seq].event_set_name))
   ORDER BY d.seq
   DETAIL
    IF (es.event_set_cd > 0)
     request->event_set[d.seq].event_set_cd = es.event_set_cd
    ELSE
     request->event_set[d.seq].event_set_cd = 0.0
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "V500_EVENT_SET_CODE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   person_id = request->person[d1.seq].person_id
   FROM person_patient pp,
    person_prsnl_activity ppa,
    (dummyt d1  WITH seq = value(request->person_qual)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (pp
    WHERE (pp.person_id=request->person[d1.seq].person_id)
     AND pp.last_event_updt_dt_tm != null
     AND pp.active_ind=1
     AND cnvtdatetime(sysdate) >= pp.beg_effective_dt_tm
     AND cnvtdatetime(sysdate) < pp.end_effective_dt_tm)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (ppa
    WHERE (ppa.prsnl_id=request->prsnl_id)
     AND ppa.person_id=pp.person_id
     AND ppa.ppa_type_cd=review_type_cd
     AND ppa.active_ind=1)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->qual,10)
   HEAD person_id
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].person_id = person_id, reply->qual[knt].check_events_ind = 1
   DETAIL
    IF (pp.person_id > 0)
     IF (ppa.ppa_id > 0)
      IF (pp.last_event_updt_dt_tm < ppa.ppa_last_dt_tm)
       reply->qual[knt].check_events_ind = 0
      ELSE
       reply->qual[knt].bookmark_dt_tm = ppa.ppa_last_dt_tm
      ENDIF
     ELSE
      IF ((pp.last_event_updt_dt_tm < request->since_dt_tm))
       reply->qual[knt].check_events_ind = 0
      ELSE
       reply->qual[knt].bookmark_dt_tm = request->since_dt_tm
      ENDIF
     ENDIF
    ELSE
     reply->qual[knt].check_events_ind = 0
    ENDIF
   FOOT REPORT
    reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter, outerjoin = d1, outerjoin = d2
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_PATIENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SELECT DISTINCT INTO "nl:"
   d.seq, ce.person_id, ex1.event_cd,
   ex2.event_set_cd
   FROM (dummyt d  WITH seq = value(reply->qual_knt)),
    (dummyt d2  WITH seq = value(request->event_set_qual)),
    clinical_event ce,
    v500_event_set_explode ex1,
    v500_event_set_explode ex2
   PLAN (d
    WHERE d.seq > 0
     AND (reply->qual[d.seq].check_events_ind=1))
    JOIN (ce
    WHERE (ce.person_id=reply->qual[d.seq].person_id)
     AND ce.updt_dt_tm > cnvtdatetime(reply->qual[d.seq].bookmark_dt_tm))
    JOIN (ex1
    WHERE ex1.event_cd=ce.event_cd)
    JOIN (d2
    WHERE (request->event_set[d2.seq].event_set_cd > 0))
    JOIN (ex2
    WHERE ex2.event_cd=ex1.event_cd
     AND (ex2.event_set_cd=request->event_set[d2.seq].event_set_cd))
   ORDER BY d.seq, ce.person_id, ex1.event_cd,
    ex2.event_set_cd
   HEAD REPORT
    person_id = 0.0, event_cd = 0.0
   HEAD d.seq
    new_result = false
   HEAD ex1.event_cd
    possible = true
   DETAIL
    IF (new_result=false
     AND possible=true
     AND ex2.event_set_cd < 1)
     possible = true
    ELSE
     possible = false
    ENDIF
   FOOT  ex1.event_cd
    IF (possible=true)
     reply->qual[d.seq].new_result_ind = 1, new_result = true
    ENDIF
    CALL echo(build("###   new_result   :",new_result))
   WITH nocounter, outerjoin = d, outerjoin = d2
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CLINICAL_EVENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   person_id = request->person[d1.seq].person_id
   FROM person_patient pp,
    person_prsnl_activity ppa,
    (dummyt d1  WITH seq = value(request->person_qual)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (pp
    WHERE (pp.person_id=request->person[d1.seq].person_id)
     AND pp.last_event_updt_dt_tm != null
     AND pp.active_ind=1
     AND cnvtdatetime(sysdate) >= pp.beg_effective_dt_tm
     AND cnvtdatetime(sysdate) < pp.end_effective_dt_tm)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (ppa
    WHERE (ppa.prsnl_id=request->prsnl_id)
     AND ppa.person_id=pp.person_id
     AND ppa.ppa_type_cd=review_type_cd
     AND ppa.active_ind=1)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->qual,10)
   HEAD person_id
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].person_id = person_id, reply->qual[knt].new_result_ind = 1
   DETAIL
    IF (pp.person_id > 0)
     IF (ppa.ppa_id > 0)
      IF (pp.last_event_updt_dt_tm < ppa.ppa_last_dt_tm)
       reply->qual[knt].new_result_ind = 0
      ELSE
       reply->qual[knt].bookmark_dt_tm = ppa.ppa_last_dt_tm
      ENDIF
     ELSE
      IF ((pp.last_event_updt_dt_tm < request->since_dt_tm))
       reply->qual[knt].new_result_ind = 0
      ELSE
       reply->qual[knt].bookmark_dt_tm = request->since_dt_tm
      ENDIF
     ENDIF
    ELSE
     reply->qual[knt].new_result_ind = 0
    ENDIF
   FOOT REPORT
    reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter, outerjoin = d1, outerjoin = d2
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_PATIENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ENDIF
END GO

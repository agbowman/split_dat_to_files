CREATE PROGRAM cps_get_new_result_reltn:dba
 FREE SET treply
 RECORD treply(
   1 person_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 last_event_updt_dt_tm = dq8
 )
 FREE SET reply
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 bookmark_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET count1 = 0
 SET count2 = 0
 SET knt = 0
 SET reply->status_data.status = "F"
 SET review_type_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET prsnl_to_get = cnvtint(size(request->prsnl_list,5))
 SET types_to_get = cnvtint(size(request->ppr_type_list,5))
 SET code_set = 104
 SET cdf_meaning = "RESULT REVIE"
 EXECUTE cpm_get_cd_for_cdf
 SET review_type_cd = code_value
 IF ((request->get_type_ind > 0))
  SELECT DISTINCT INTO "nl:"
   p.person_id
   FROM (dummyt d1  WITH seq = value(prsnl_to_get)),
    (dummyt d2  WITH seq = value(types_to_get)),
    person_prsnl_reltn ppr,
    person p,
    person_patient pp
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (ppr
    WHERE (ppr.prsnl_person_id=request->prsnl_list[d1.seq].person_id)
     AND (ppr.person_prsnl_r_cd=request->ppr_type_list[d2.seq].person_prsnl_r_cd)
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pp
    WHERE pp.person_id=ppr.person_id
     AND pp.last_event_updt_dt_tm != null
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pp.person_id
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    knt = 0, stat = alterlist(treply->person_list,10)
   DETAIL
    knt = (knt+ 1)
    IF (knt > size(treply->person_list,5))
     stat = alterlist(treply->person_list,(knt+ 9))
    ENDIF
    treply->person_list[knt].person_id = p.person_id, treply->person_list[knt].name_full_formatted =
    p.name_full_formatted, treply->person_list[knt].last_event_updt_dt_tm = pp.last_event_updt_dt_tm
   FOOT REPORT
    stat = alterlist(treply->person_list,knt)
   WITH nocounter
  ;end select
  SET nbr_of_persons = size(treply->person_list,5)
  SELECT DISTINCT INTO "nl:"
   p.person_id
   FROM (dummyt d1  WITH seq = value(prsnl_to_get)),
    (dummyt d2  WITH seq = value(types_to_get)),
    (dummyt d4  WITH seq = value(nbr_of_persons)),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    encounter e,
    person p,
    person_patient pp
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (epr
    WHERE (epr.prsnl_person_id=request->prsnl_list[d1.seq].person_id)
     AND (epr.encntr_prsnl_r_cd=request->ppr_type_list[d2.seq].person_prsnl_r_cd)
     AND epr.active_ind=1
     AND epr.expiration_ind=0)
    JOIN (e
    WHERE e.encntr_id=epr.encntr_id
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pp
    WHERE pp.person_id=e.person_id
     AND pp.last_event_updt_dt_tm != null
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pp.person_id
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (d4
    WHERE (treply->person_list[d4.seq].person_id=p.person_id))
   ORDER BY p.person_id
   HEAD REPORT
    knt = size(treply->person_list,5), stat = alterlist(treply->person_list,(knt+ 10))
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(treply->person_list,(knt+ 9))
    ENDIF
    treply->person_list[knt].person_id = p.person_id, treply->person_list[knt].name_full_formatted =
    p.name_full_formatted, treply->person_list[knt].last_event_updt_dt_tm = pp.last_event_updt_dt_tm
   FOOT REPORT
    stat = alterlist(treply->person_list,knt)
   WITH nocounter, outerjoin = d5, dontexist
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   p.person_id
   FROM (dummyt d1  WITH seq = value(prsnl_to_get)),
    person_prsnl_reltn ppr,
    person p,
    person_patient pp
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (ppr
    WHERE (ppr.prsnl_person_id=request->prsnl_list[d1.seq].person_id)
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pp
    WHERE pp.person_id=ppr.person_id
     AND pp.last_event_updt_dt_tm != null
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pp.person_id
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    knt = 0, stat = alterlist(treply->person_list,10)
   DETAIL
    knt = (knt+ 1)
    IF (knt > size(treply->person_list,5))
     stat = alterlist(treply->person_list,(knt+ 9))
    ENDIF
    treply->person_list[knt].person_id = p.person_id, treply->person_list[knt].name_full_formatted =
    p.name_full_formatted, treply->person_list[knt].last_event_updt_dt_tm = pp.last_event_updt_dt_tm
   FOOT REPORT
    stat = alterlist(treply->person_list,knt)
   WITH nocounter
  ;end select
  SET nbr_of_persons = size(treply->person_list,5)
  SELECT DISTINCT INTO "nl:"
   p.person_id
   FROM (dummyt d1  WITH seq = value(prsnl_to_get)),
    (dummyt d4  WITH seq = value(nbr_of_persons)),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    encounter e,
    person p,
    person_patient pp
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (epr
    WHERE (epr.prsnl_person_id=request->prsnl_list[d1.seq].person_id)
     AND epr.active_ind=1
     AND epr.expiration_ind=0)
    JOIN (e
    WHERE e.encntr_id=epr.encntr_id
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pp
    WHERE pp.person_id=e.person_id
     AND pp.last_event_updt_dt_tm != null
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pp.person_id
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (d4
    WHERE (treply->person_list[d4.seq].person_id=p.person_id))
   ORDER BY p.person_id
   HEAD REPORT
    knt = size(treply->person_list,5), stat = alterlist(treply->person_list,(knt+ 10))
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(treply->person_list,(knt+ 9))
    ENDIF
    treply->person_list[knt].person_id = p.person_id, treply->person_list[knt].name_full_formatted =
    p.name_full_formatted, treply->person_list[knt].last_event_updt_dt_tm = pp.last_event_updt_dt_tm
   FOOT REPORT
    stat = alterlist(treply->person_list,knt)
   WITH nocounter, outerjoin = d5, dontexist
  ;end select
 ENDIF
 SET total_people = size(treply->person_list,5)
 IF (total_people > 0)
  SELECT DISTINCT INTO "nl:"
   person_id = treply->person_list[d2.seq].person_id, name = substring(1,100,treply->person_list[d2
    .seq].name_full_formatted), last_event_updt_dt_tm = treply->person_list[d2.seq].
   last_event_updt_dt_tm
   FROM (dummyt d1  WITH seq = value(prsnl_to_get)),
    (dummyt d2  WITH seq = value(total_people)),
    person_prsnl_activity ppa
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (ppa
    WHERE (ppa.prsnl_id=request->prsnl_list[d1.seq].person_id)
     AND (ppa.person_id=treply->person_list[d2.seq].person_id)
     AND ppa.ppa_type_cd=review_type_cd
     AND ppa.active_ind=1)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->person_list,total_people)
   DETAIL
    IF (last_event_updt_dt_tm >= ppa.ppa_last_dt_tm)
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->person_list,(knt+ 9))
     ENDIF
     reply->person_list[knt].person_id = person_id, reply->person_list[knt].name_full_formatted =
     name, reply->person_list[knt].bookmark_dt_tm = ppa.ppa_last_dt_tm
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->person_list,knt)
   WITH nocounter, outerjoin = d2
  ;end select
 ENDIF
 IF (size(reply->person_list,5) < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY_ASSIGNMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_program
END GO

CREATE PROGRAM dcp_get_new_result_reltn:dba
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET review_type_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 104
 SET cdf_meaning = "RESULT REVIE"
 EXECUTE cpm_get_cd_for_cdf
 SET review_type_cd = code_value
 SELECT DISTINCT INTO "nl:"
  ppr.person_id, ppr.prsnl_person_id, p.person_id,
  pp.person_id, ppa.person_id
  FROM person_prsnl_reltn ppr,
   person p,
   person_patient pp,
   (dummyt d  WITH seq = 1),
   person_prsnl_activity ppa
  PLAN (ppr
   WHERE (ppr.prsnl_person_id=request->prsnl_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE ppr.person_id=p.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pp
   WHERE p.person_id=pp.person_id
    AND pp.last_event_updt_dt_tm != null
    AND pp.active_ind=1
    AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d)
   JOIN (ppa
   WHERE pp.person_id=ppa.person_id
    AND (ppa.prsnl_id=request->prsnl_id)
    AND ppa.ppa_type_cd=review_type_cd
    AND ppa.active_ind=1)
  ORDER BY ppr.person_id
  HEAD REPORT
   count1 = 0
  DETAIL
   IF (pp.last_event_updt_dt_tm >= ppa.ppa_last_dt_tm)
    count1 = (count1+ 1)
    IF (count1 > size(reply->person_list,5))
     stat = alterlist(reply->person_list,(count1+ 10))
    ENDIF
    reply->person_list[count1].person_id = p.person_id, reply->person_list[count1].
    name_full_formatted = p.name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT DISTINCT INTO "nl:"
  epr.encntr_id, epr.prsnl_person_id, p.person_id,
  pp.person_id, ppa.person_id
  FROM encntr_prsnl_reltn epr,
   encounter e,
   person p,
   person_patient pp,
   (dummyt d  WITH seq = 1),
   person_prsnl_activity ppa
  PLAN (epr
   WHERE (epr.prsnl_person_id=request->prsnl_id)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE epr.encntr_id=e.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pp
   WHERE p.person_id=pp.person_id
    AND pp.last_event_updt_dt_tm != null
    AND pp.active_ind=1
    AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d)
   JOIN (ppa
   WHERE pp.person_id=ppa.person_id
    AND (ppa.prsnl_id=request->prsnl_id)
    AND ppa.ppa_type_cd=review_type_cd)
  ORDER BY epr.encntr_id
  HEAD REPORT
   col + 0
  DETAIL
   IF (pp.last_event_updt_dt_tm >= ppa.ppa_last_dt_tm)
    count1 = (count1+ 1)
    IF (count1 > size(reply->person_list,5))
     stat = alterlist(reply->person_list,(count1+ 10))
    ENDIF
    reply->person_list[count1].person_id = p.person_id, reply->person_list[count1].
    name_full_formatted = p.name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET stat = alterlist(reply->person_list,count1)
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM cps_get_per_prvdr_by_ntwk_sub:dba
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET name_type_cd_value = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=213
   AND c.cdf_meaning="CURRENT"
  DETAIL
   name_type_cd_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_ntwk_prvdr p,
   person r,
   prsnl l,
   person_name n
  PLAN (p
   WHERE  $1
    AND  $2
    AND  $3
    AND p.active_ind=1
    AND p.prsnl_id > 0
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (r
   WHERE p.prsnl_id=r.person_id)
   JOIN (l
   WHERE r.person_id=l.person_id)
   JOIN (n
   WHERE n.person_id=r.person_id
    AND n.name_type_cd=name_type_cd_value)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,100)=1)
    stat = alterlist(reply->person_ntwk_prvdr,(count1+ 100)), stat = alterlist(reply->person,(count1
     + 100)), stat = alterlist(reply->prsnl,(count1+ 100))
   ENDIF
   reply->person_ntwk_prvdr[count1].person_ntwk_prvdr_id = p.person_ntwk_prvdr_id, reply->
   person_ntwk_prvdr[count1].updt_cnt = p.updt_cnt, reply->person_ntwk_prvdr[count1].prsnl_id = p
   .prsnl_id,
   reply->person_ntwk_prvdr[count1].network_id = p.network_id, reply->person_ntwk_prvdr[count1].
   specialty_cd = p.specialty_cd, reply->person[count1].person_id = r.person_id,
   reply->person[count1].updt_cnt = r.updt_cnt, reply->person[count1].name_last = r.name_last, reply
   ->person[count1].name_first = r.name_first,
   reply->person[count1].name_middle = r.name_middle, reply->person[count1].name_full_formatted = r
   .name_full_formatted, reply->person[count1].beg_effective_dt_tm = cnvtdatetime(r
    .beg_effective_dt_tm),
   reply->person[count1].end_effective_dt_tm = cnvtdatetime(r.end_effective_dt_tm), reply->person[
   count1].name_degree = n.name_degree, reply->person[count1].name_suffix = n.name_suffix,
   reply->prsnl[count1].person_id = l.person_id, reply->prsnl[count1].name_last_key = l.name_last_key,
   reply->prsnl[count1].name_first_key = l.name_first_key,
   reply->prsnl[count1].prsnl_type_cd = l.prsnl_type_cd, reply->prsnl[count1].name_full_formatted = l
   .name_full_formatted, reply->prsnl[count1].physician_ind = l.physician_ind
  WITH nocounter, outerjoin = n
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON_NTWK_PRVDR"
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->person_ntwk_prvdr,count1)
  SET stat = alterlist(reply->person,count1)
  SET stat = alterlist(reply->prsnl,count1)
 ENDIF
#9999_end
END GO

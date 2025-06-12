CREATE PROGRAM dcp_get_mrn:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->person_list,5))
 SET mrn_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   pa.person_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    person_alias pa
   PLAN (d)
    JOIN (pa
    WHERE (pa.person_id=request->person_list[d.seq].person_id)
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY pa.person_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].person_id = pa.person_id, reply->get_list[count1].mrn = cnvtalias(pa
     .alias,pa.alias_pool_cd)
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

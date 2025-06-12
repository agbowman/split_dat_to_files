CREATE PROGRAM dcp_get_finnbr:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->encntr_list,5))
 SET finnbr_cd = 0.0
 SET mrn_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   ea.encntr_id, ea.encntr_alias_type_cd, ea.alias
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    encntr_alias ea
   PLAN (d)
    JOIN (ea
    WHERE (ea.encntr_id=request->encntr_list[d.seq].encntr_id)
     AND ((ea.encntr_alias_type_cd=finnbr_cd) OR (ea.encntr_alias_type_cd=mrn_cd))
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY ea.encntr_id, ea.encntr_alias_type_cd
   HEAD REPORT
    count1 = 0
   HEAD ea.encntr_id
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].encntr_id = ea.encntr_id
   HEAD ea.encntr_alias_type_cd
    IF (ea.encntr_alias_type_cd=finnbr_cd)
     reply->get_list[count1].finnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSEIF (ea.encntr_alias_type_cd=mrn_cd)
     reply->get_list[count1].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
   DETAIL
    col + 0
   FOOT  ea.encntr_alias_type_cd
    col + 0
   FOOT  ea.encntr_id
    col + 0
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

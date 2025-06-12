CREATE PROGRAM dcp_get_task_svc_res:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->person_list,5))
 SET task_res_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 357
 SET cdf_meaning = "TASK RES"
 EXECUTE cpm_get_cd_for_cdf
 SET task_res_cd = code_value
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   pg.prsnl_group_id, pgr.prsnl_group_reltn_id, pgr.person_id
   FROM prsnl_group pg,
    (dummyt d  WITH seq = value(nbr_to_get)),
    prsnl_group_reltn pgr
   PLAN (pg
    WHERE pg.prsnl_group_type_cd=task_res_cd
     AND pg.active_ind=1
     AND pg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (d)
    JOIN (pgr
    WHERE pg.prsnl_group_id=pgr.prsnl_group_id
     AND (pgr.person_id=request->person_list[d.seq].person_id)
     AND pgr.active_ind=1
     AND pgr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pgr.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY pgr.person_id
   HEAD REPORT
    count1 = 0
   HEAD pgr.person_id
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].person_id = pgr.person_id, reply->get_list[count1].service_resource_cd =
    pg.service_resource_cd
   DETAIL
    col + 0
   FOOT  pgr.person_id
    col + 0
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

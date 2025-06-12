CREATE PROGRAM dcp_get_orig_prov_id:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 SET new_action_type_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET new_action_type_cd = code_value
 SELECT INTO "nl:"
  oa.order_id
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   order_action oa
  PLAN (d)
   JOIN (oa
   WHERE (oa.order_id=request->order_list[d.seq].order_id)
    AND oa.action_type_cd=new_action_type_cd)
  ORDER BY oa.order_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].order_id = oa.order_id, reply->get_list[count1].order_provider_id = oa
   .order_provider_id
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

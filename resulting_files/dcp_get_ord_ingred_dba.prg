CREATE PROGRAM dcp_get_ord_ingred:dba
 SET count1 = 0
 SET count2 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 SET new_action_type_cd = 0.0
 SET modify_action_type_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET new_action_type_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_action_type_cd = code_value
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   oi.order_id, oi.catalog_cd
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    order_action oa,
    order_ingredient oi
   PLAN (d)
    JOIN (oa
    WHERE (oa.order_id=request->order_list[d.seq].order_id)
     AND ((oa.action_type_cd=new_action_type_cd) OR (oa.action_type_cd=modify_action_type_cd))
     AND oa.action_rejected_ind=0)
    JOIN (oi
    WHERE oa.order_id=oi.order_id
     AND oa.action_sequence=oi.action_sequence)
   ORDER BY oi.order_id, oi.catalog_cd, oi.action_sequence DESC
   HEAD REPORT
    count1 = 0
   HEAD oi.order_id
    count2 = 0, count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].order_id = oi.order_id
   HEAD oi.catalog_cd
    count2 += 1
    IF (count2 > size(reply->get_list[count1].ingred_list,5))
     stat = alterlist(reply->get_list[count1].ingred_list,(count2+ 10))
    ENDIF
    reply->get_list[count1].ingred_list[count2].order_mnemonic = oi.order_mnemonic
   FOOT  oi.catalog_cd
    col + 0
   FOOT  oi.order_id
    stat = alterlist(reply->get_list[count1].ingred_list,count2)
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

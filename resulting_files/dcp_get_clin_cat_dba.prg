CREATE PROGRAM dcp_get_clin_cat:dba
 RECORD reply(
   1 get_list[*]
     2 dcp_clin_cat_cd = f8
     2 new_view_name = c12
     2 aos_cat_gen_pref_name = c32
     2 aos_cat_cust_pref_name = c32
     2 aos_cat_sys_pref_name = c32
     2 rx_mask_pref_name = c32
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
 SET nbr_to_get = cnvtint(size(request->cat_list,5))
 SELECT
  IF ((request->cat_list[1].dcp_clin_cat_cd > 0.0))
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    dcp_clinical_category dcc
   PLAN (d)
    JOIN (dcc
    WHERE (dcc.dcp_clin_cat_cd=request->cat_list[d.seq].dcp_clin_cat_cd))
  ELSE
   FROM dcp_clinical_category dcc
   PLAN (dcc
    WHERE dcc.dcp_clin_cat_cd > 0.0)
  ENDIF
  INTO "nl:"
  dcc.dcp_clin_cat_cd
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].dcp_clin_cat_cd = dcc.dcp_clin_cat_cd, reply->get_list[count1].
   new_view_name = dcc.new_view_name, reply->get_list[count1].aos_cat_gen_pref_name = dcc
   .aos_cat_gen_pref_name,
   reply->get_list[count1].aos_cat_cust_pref_name = dcc.aos_cat_cust_pref_name, reply->get_list[
   count1].aos_cat_sys_pref_name = dcc.aos_cat_sys_pref_name, reply->get_list[count1].
   rx_mask_pref_name = dcc.rx_mask_pref_name
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

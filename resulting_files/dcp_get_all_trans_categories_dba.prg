CREATE PROGRAM dcp_get_all_trans_categories:dba
 RECORD reply(
   1 qual[*]
     2 category_id = f8
     2 category_name = vc
     2 transfer_type_cd = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
 )
 SET cat_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cat.cf_category_name, cat.cf_transfer_type_cd, cat.dcp_cf_trans_cat_id
  FROM dcp_cf_trans_cat cat
  WHERE (cat.cf_transfer_type_cd=request->transfer_type_cd)
  ORDER BY cat.cf_category_name
  HEAD REPORT
   cat_cnt = 0
  DETAIL
   cat_cnt = (cat_cnt+ 1)
   IF (mod(cat_cnt,10)=1)
    stat = alterlist(reply->qual,(cat_cnt+ 9))
   ENDIF
   reply->qual[cat_cnt].active_ind = cat.active_ind, reply->qual[cat_cnt].category_id = cat
   .dcp_cf_trans_cat_id, reply->qual[cat_cnt].category_name = substring(1,100,cat.cf_category_name),
   reply->qual[cat_cnt].transfer_type_cd = cat.cf_transfer_type_cd
  FOOT REPORT
   stat = alterlist(reply->qual,cat_cnt)
  WITH nocounter
 ;end select
 IF (cat_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
END GO

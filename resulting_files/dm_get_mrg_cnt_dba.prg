CREATE PROGRAM dm_get_mrg_cnt:dba
 RECORD reply(
   1 tot_mrg_cnt = i4
   1 tot_ref_cnt = i4
   1 tot_ref_err_cnt = i4
   1 cur_mrg_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET i = 0
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_merge_action a
  WHERE a.merge_status_flag IN (7, 1)
  DETAIL
   reply->tot_mrg_cnt = y
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_merge_action a
  WHERE a.merge_status_flag IN (7, 1)
   AND a.ref_domain_name=trim(request->ref_domain_name)
  DETAIL
   reply->tot_ref_cnt = y
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_merge_action a
  WHERE a.merge_status_flag=2
   AND a.active_ind=1
  DETAIL
   reply->tot_ref_err_cnt = y
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  maxid = max(c.merge_id)
  FROM dm_merge_action c
  WHERE c.merge_status_flag=1
  DETAIL
   reply->cur_mrg_id = maxid
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO

CREATE PROGRAM dcp_solcap_vdpa_capability:dba
 FREE RECORD reply
 RECORD reply(
   1 solcap[*]
     2 identifier = vc
     2 degree_of_use_num = i4
     2 degree_of_use_str = vc
     2 distinct_user_count = i4
     2 position[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 facility[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 other[*]
       3 category_name = vc
       3 value[*]
         4 display = vc
         4 value_num = i4
         4 value_str = vc
 )
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.1.00002.1"
 SELECT INTO "nl:"
  vdpaorders = count(o.order_id), users = count(DISTINCT o.updt_id)
  FROM orders o
  WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
   AND o.dosing_method_flag=1
  DETAIL
   reply->solcap[1].degree_of_use_num = vdpaorders, reply->solcap[1].distinct_user_count = users
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO

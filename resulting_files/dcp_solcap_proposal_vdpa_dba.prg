CREATE PROGRAM dcp_solcap_proposal_vdpa:dba
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
 SET reply->solcap[1].identifier = "PJ069467.1"
 SELECT INTO "nl:"
  vdpaproposal = count(op.order_proposal_id), users = count(DISTINCT op.updt_id)
  FROM order_proposal op
  WHERE op.created_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
   AND op.dosing_method_flag=1
  DETAIL
   reply->solcap[1].degree_of_use_num = vdpaproposal, reply->solcap[1].distinct_user_count = users
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO

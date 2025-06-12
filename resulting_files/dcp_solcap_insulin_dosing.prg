CREATE PROGRAM dcp_solcap_insulin_dosing
 SET modify = predeclare
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
 DECLARE istatus = i2 WITH protect, noconstant(0)
 SET istatus = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2012.1.00103.7"
 SELECT INTO "nl:"
  inumberofdosingoffall = count(*)
  FROM order_catalog oc
  WHERE oc.dosing_all_ingred_ind=1
   AND oc.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
  DETAIL
   reply->solcap[1].degree_of_use_num = inumberofdosingoffall
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO

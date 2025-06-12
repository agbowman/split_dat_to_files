CREATE PROGRAM dcp_solcap_linking_orders
 SET modify = predeclare
 DECLARE istatus = i2 WITH protect, noconstant(0)
 SET istatus = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2013.1.00099.1"
 SELECT INTO "nl:"
  inumberofgroups = count(*)
  FROM act_pw_comp_g apcg
  WHERE apcg.type_mean="LINKEDCOMP"
   AND apcg.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   reply->solcap[1].degree_of_use_num = inumberofgroups,
   CALL echo("123")
  WITH nocounter
 ;end select
 SET reply->solcap[2].identifier = "2013.1.00099.2"
 SELECT INTO "nl:"
  inumberofoverrides = count(*)
  FROM act_pw_comp_g_action apcga
  WHERE apcga.type_flag=1
   AND apcga.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
  DETAIL
   reply->solcap[2].degree_of_use_num = inumberofoverrides
  WITH nocounter
 ;end select
END GO

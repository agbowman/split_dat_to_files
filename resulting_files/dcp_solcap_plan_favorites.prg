CREATE PROGRAM dcp_solcap_plan_favorites
 SET modify = predeclare
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lsolutioncapabilitycount = i4 WITH protect, noconstant(0)
 SET lsolutioncapabilitycount = (value(size(reply->solcap,5))+ 1)
 SET stat = alterlist(reply->solcap,lsolutioncapabilitycount)
 SET reply->solcap[lsolutioncapabilitycount].identifier = "2010.1.00065.1"
 SELECT DISTINCT INTO "nl:"
  pcp.pathway_customized_plan_id
  FROM pathway_customized_plan pcp
  PLAN (pcp
   WHERE pcp.create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pcp.pathway_customized_plan_id > 0.0)
  ORDER BY pcp.pathway_customized_plan_id
  HEAD REPORT
   dummy = 0
  HEAD pcp.pathway_customized_plan_id
   reply->solcap[lsolutioncapabilitycount].degree_of_use_num += 1
  DETAIL
   dummy = 0
  FOOT  pcp.pathway_customized_plan_id
   dummy = 0
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 SET lsolutioncapabilitycount = (value(size(reply->solcap,5))+ 1)
 SET stat = alterlist(reply->solcap,lsolutioncapabilitycount)
 SET reply->solcap[lsolutioncapabilitycount].identifier = "2010.1.00065.2"
 SELECT DISTINCT INTO "nl:"
  pw.pw_group_nbr
  FROM pathway pw
  PLAN (pw
   WHERE pw.order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pw.pathway_customized_plan_id > 0.0
    AND pw.pw_group_nbr > 0.0)
  ORDER BY pw.pw_group_nbr
  HEAD REPORT
   dummy = 0
  HEAD pw.pw_group_nbr
   reply->solcap[lsolutioncapabilitycount].degree_of_use_num += 1
  DETAIL
   dummy = 0
  FOOT  pw.pw_group_nbr
   dummy = 0
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 SET lsolutioncapabilitycount = (value(size(reply->solcap,5))+ 1)
 SET stat = alterlist(reply->solcap,lsolutioncapabilitycount)
 SET reply->solcap[lsolutioncapabilitycount].identifier = "2010.2.00133.1"
 SELECT DISTINCT INTO "nl:"
  pcn.long_text_id
  FROM pathway_customized_notify pcn
  PLAN (pcn
   WHERE pcn.notification_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pcn.long_text_id > 0.0)
  ORDER BY pcn.long_text_id
  HEAD REPORT
   dummy = 0
  HEAD pcn.long_text_id
   reply->solcap[lsolutioncapabilitycount].degree_of_use_num += 1
  DETAIL
   dummy = 0
  FOOT  pcn.long_text_id
   dummy = 0
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
END GO

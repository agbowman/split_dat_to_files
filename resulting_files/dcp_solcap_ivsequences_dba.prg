CREATE PROGRAM dcp_solcap_ivsequences:dba
 DECLARE ivsequence_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
 SET stat = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2012.1.00062.1"
 SELECT INTO "nl:"
  ivsequences = count(DISTINCT p.pw_group_nbr)
  FROM pathway p
  WHERE p.order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND p.pathway_type_cd=ivsequence_cd
  DETAIL
   reply->solcap[1].degree_of_use_num = ivsequences
  WITH nocounter
 ;end select
 SET reply->solcap[2].identifier = "2012.1.00062.2"
 SELECT INTO "nl:"
  orderspartofivsequences = count(a.act_pw_comp_id)
  FROM pathway p,
   act_pw_comp a
  PLAN (p
   WHERE p.order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
    )
    AND p.pathway_type_cd=ivsequence_cd)
   JOIN (a
   WHERE p.pathway_id=a.pathway_id)
  FOOT REPORT
   reply->solcap[2].degree_of_use_num = orderspartofivsequences
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO

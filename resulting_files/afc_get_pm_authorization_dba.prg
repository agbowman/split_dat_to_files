CREATE PROGRAM afc_get_pm_authorization:dba
 DECLARE versionnbr = vc
 SET versionnbr = "001"
 CALL echo(build("AFC_GET_PM_AUTHORIZATION Version: ",versionnbr))
 RECORD reply(
   1 authorization_nbr = c50
 )
 DECLARE dauthtypecd = f8
 SET stat = uar_get_meaning_by_codeset(14949,nullterm("AUTH"),1,dauthtypecd)
 SELECT INTO "nl:"
  FROM authorization a
  WHERE (a.encntr_id=request->encntr_id)
   AND (a.health_plan_id=request->health_plan_id)
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND a.auth_type_cd=dauthtypecd
   AND a.active_ind=1
  DETAIL
   reply->authorization_nbr = a.auth_nbr,
   CALL echo(build("Authorization_nbr: ",a.auth_nbr))
  WITH nocounter
 ;end select
END GO

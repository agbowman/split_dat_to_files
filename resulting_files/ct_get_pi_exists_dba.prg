CREATE PROGRAM ct_get_pi_exists:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET pi_cd = 0.0
 SET prsnl_role_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET stat = uar_get_meaning_by_codeset(17296,"PERSONAL",1,prsnl_role_cd)
 SELECT INTO "nl:"
  pr.prot_role_id
  FROM prot_role pr
  WHERE (pr.prot_amendment_id=request->prot_amendment_id)
   AND pr.prot_role_cd=pi_cd
   AND pr.prot_role_type_cd=prsnl_role_cd
   AND pr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echo(build("status:",reply->status_data.status))
END GO

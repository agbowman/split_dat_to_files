CREATE PROGRAM aps_get_research_accounts:dba
 RECORD reply(
   1 qual[*]
     2 research_account_id = f8
     2 organization_id = f8
     2 name = c40
     2 description = c100
     2 account_nbr = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM research_account ra
  PLAN (ra
   WHERE ra.active_ind=1
    AND ra.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ra.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ra.name_key
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].research_account_id = ra.research_account_id, reply->qual[cnt].organization_id =
   ra.organization_id, reply->qual[cnt].name = ra.name,
   reply->qual[cnt].description = ra.description, reply->qual[cnt].account_nbr = ra.account_nbr,
   CALL echo(build("research_account_id =",reply->qual[cnt].research_account_id)),
   CALL echo(build("organization_id =",reply->qual[cnt].organization_id)),
   CALL echo(build("name =",reply->qual[cnt].name)),
   CALL echo(build("description =",reply->qual[cnt].description)),
   CALL echo(build("account_nbr =",reply->qual[cnt].account_nbr)),
   CALL echo(".")
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PHONE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM bbd_get_org_alias:dba
 RECORD reply(
   1 qual[*]
     2 formatted_alias = vc
     2 org_alias_type_disp = vc
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
 SET stat = alterlist(reply->qual,20)
 SELECT INTO "nl:"
  c.display, new_alias = cnvtalias(a.alias,a.alias_pool_cd)
  FROM organization_alias a,
   code_value c
  PLAN (a
   WHERE (a.organization_id=request->organization_id)
    AND cnvtdatetime(curdate,curtime3) >= a.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= a.end_effective_dt_tm
    AND a.active_ind=1)
   JOIN (c
   WHERE c.code_value=a.org_alias_type_cd
    AND cnvtdatetime(curdate,curtime3) >= a.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= a.end_effective_dt_tm
    AND a.active_ind=1)
  DETAIL
   count = (count+ 1)
   IF (mod(count,20)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 19))
   ENDIF
   reply->qual[count].org_alias_type_disp = c.display, reply->qual[count].formatted_alias = new_alias
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO

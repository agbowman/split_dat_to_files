CREATE PROGRAM dcp_get_logical_domain_usr:dba
 RECORD reply(
   1 logical_domain_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), reply->logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSEIF (count=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO

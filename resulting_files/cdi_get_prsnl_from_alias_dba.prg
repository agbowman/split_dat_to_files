CREATE PROGRAM cdi_get_prsnl_from_alias:dba
 RECORD reply(
   1 prsnl_qual[*]
     2 person_id = f8
     2 name_full_formatted = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM prsnl_alias pa,
   person p
  PLAN (pa
   WHERE (pa.alias=request->alias)
    AND (pa.prsnl_alias_type_cd=request->prsnl_alias_type_cd)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE pa.person_id=p.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   stat = alterlist(reply->prsnl_qual,10)
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->prsnl_qual))
    stat = alterlist(reply->prsnl_qual,(count+ 9))
   ENDIF
   reply->prsnl_qual[count].person_id = p.person_id, reply->prsnl_qual[count].name_full_formatted = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prsnl_qual,count)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

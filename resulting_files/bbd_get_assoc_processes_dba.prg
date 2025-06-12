CREATE PROGRAM bbd_get_assoc_processes:dba
 RECORD reply(
   1 qual[*]
     2 process_mean = c12
     2 process_display = vc
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
 SET module_cd = 0.0
 SELECT INTO "nl:"
  m.code_value
  FROM code_value m
  WHERE m.code_set=1660
   AND (m.cdf_meaning=request->module_mean)
  DETAIL
   module_cd = cnvtint(m.code_value)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  c.cdf_meaning, c.display
  FROM question q,
   code_value c
  PLAN (q
   WHERE q.module_cd=module_cd
    AND q.active_ind=1
    AND q.dwb_ind=0)
   JOIN (c
   WHERE c.code_set=1662
    AND q.process_cd=c.code_value)
  ORDER BY q.process_cd, 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].process_mean = c
   .cdf_meaning,
   reply->qual[count].process_display = c.display
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO

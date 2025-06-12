CREATE PROGRAM atr_get_frmt_script:dba
 RECORD reply(
   1 qual[*]
     2 format_script = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT
  IF ((request->mode=1))
   WHERE d.object="P"
    AND d.object_name="PFMT_P*"
  ELSEIF ((request->mode=2))
   WHERE d.object="P"
    AND d.object_name="PFMT_E*"
  ELSEIF ((request->mode=3))
   WHERE d.object="P"
    AND d.object_name="PFMT_*"
  ELSE
  ENDIF
  INTO "nl:"
  d.object_name
  FROM dprotect d
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].format_script = d.object_name
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

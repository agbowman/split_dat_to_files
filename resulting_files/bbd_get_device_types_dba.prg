CREATE PROGRAM bbd_get_device_types:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_set=14203
   AND c.code_value > 0
   AND c.active_ind=1
   AND cnvtdatetime(curdate,curtime3) >= c.begin_effective_dt_tm
   AND cnvtdatetime(curdate,curtime3) <= c.end_effective_dt_tm
  ORDER BY c.display
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].code_value = c
   .code_value,
   reply->qual[count].display = c.display
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "BBD_GET_DEVICE_TYPES.PRG"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to retrieve device types"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 0
 ENDIF
#exitscript
END GO

CREATE PROGRAM bbt_get_abo_barcodes:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET val_count = 0
 SELECT INTO "nl:"
  cv.code_value, cv.code_set, cve.field_name,
  cve.field_value, cv.display
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=1640
    AND cv.active_ind=1
    AND cnvtdatetime(curdate,curtime3) >= cv.begin_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= cv.end_effective_dt_tm)
   JOIN (cve
   WHERE cve.code_value=cv.code_value
    AND cve.field_name="Barcode")
  DETAIL
   val_count = (val_count+ 1), stat = alterlist(reply->qual,val_count), reply->qual[val_count].
   code_value = cv.code_value,
   reply->qual[val_count].display = cv.display, reply->qual[val_count].field_value = cve.field_value
  WITH nocounter
 ;end select
 IF (val_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

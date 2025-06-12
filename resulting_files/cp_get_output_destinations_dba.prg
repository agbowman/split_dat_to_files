CREATE PROGRAM cp_get_output_destinations:dba
 RECORD reply(
   1 device_type_flag = i2
   1 qual[*]
     2 output_dest_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET status = "Z"
 SET count1 = 0
 SET count2 = 0
 SET code_value1 = 0.0
 SET code_set1 = 3000
 SET cdf_meaning1 = "PRINT QUEUE"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET printer_cd = code_value1
 SELECT INTO "nl:"
  FROM device d,
   device_xref dx,
   output_dest od
  PLAN (d
   WHERE cnvtupper(d.description)=cnvtupper(request->queue_name)
    AND d.device_type_cd=printer_cd)
   JOIN (dx
   WHERE dx.parent_entity_id=d.device_cd)
   JOIN (od
   WHERE od.device_cd=dx.device_cd)
  HEAD REPORT
   count1 = 0, reply->device_type_flag = 1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].output_dest_cd = od.output_dest_cd
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   remote_device_type rdt,
   remote_device rd,
   output_dest od
  PLAN (cv
   WHERE cv.code_set=2210
    AND cnvtupper(cv.description)=cnvtupper(request->queue_name))
   JOIN (rdt
   WHERE rdt.output_format_cd=cv.code_value)
   JOIN (rd
   WHERE rd.remote_dev_type_id=rdt.remote_dev_type_id)
   JOIN (od
   WHERE od.device_cd=rd.device_cd)
  HEAD REPORT
   IF (cv.cdf_meaning="FAX")
    reply->device_type_flag = 2
   ELSE
    reply->device_type_flag = 3
   ENDIF
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].output_dest_cd = od.output_dest_cd
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET status = "S"
 ENDIF
 IF (count1 > 0)
  SET stat = alterlist(reply->qual,count1)
 ENDIF
#exit_script
 IF (status != "S")
  SET reply->status_data.status = status
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

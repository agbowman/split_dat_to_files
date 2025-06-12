CREATE PROGRAM bed_get_application:dba
 FREE SET reply
 RECORD reply(
   1 applications[*]
     2 app_number = i4
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET appcount = size(request->applications,5)
 IF (appcount=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->applications,appcount)
 FOR (x = 1 TO appcount)
  SET reply->applications[x].app_number = request->applications[x].app_number
  SET reply->applications[x].description = " "
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = appcount),
   br_name_value b,
   dummyt d2
  PLAN (d)
   JOIN (b
   WHERE b.br_nv_key1="APPLICATION_NAME")
   JOIN (d2
   WHERE (cnvtreal(trim(b.br_name))=request->applications[d.seq].app_number))
  HEAD d.seq
   reply->applications[d.seq].description = b.br_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = appcount),
   application a
  PLAN (d
   WHERE (reply->applications[d.seq].description=" "))
   JOIN (a
   WHERE (a.application_number=request->applications[d.seq].app_number))
  HEAD d.seq
   reply->applications[d.seq].description = a.description
  WITH nocounter, skipbedrock = 1
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

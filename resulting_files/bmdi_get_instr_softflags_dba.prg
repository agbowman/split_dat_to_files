CREATE PROGRAM bmdi_get_instr_softflags:dba
 SET trace = nocost
 SET message = noinformation
 RECORD reply(
   1 rtlsoftflags = vc
   1 infsoftflags = vc
   1 resultformat = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i4
 DECLARE labformat = f8
 SET count = 0
 SELECT INTO "nl:"
  FROM lab_instrument_custom lic
  WHERE (lic.service_resource_cd=request->service_resource_cd)
  DETAIL
   count = (count+ 1)
   IF (((lic.process_flag=2) OR (lic.process_flag=3)) )
    IF (size(reply->infsoftflags,1) <= 0)
     reply->infsoftflags = lic.custom_option
    ELSE
     reply->infsoftflags = concat(reply->infsoftflags,lic.custom_option)
    ENDIF
   ENDIF
   IF (((lic.process_flag=1) OR (lic.process_flag=3)) )
    IF (size(reply->rtlsoftflags,1) <= 0)
     reply->rtlsoftflags = lic.custom_option
    ELSE
     reply->rtlsoftflags = concat(reply->rtlsoftflags,lic.custom_option)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM lab_instrument li
  WHERE (li.service_resource_cd=request->service_resource_cd)
  DETAIL
   labformat = li.result_format_cd
  WITH nocounter
 ;end select
 SET reply->resultformat = uar_get_code_meaning(labformat)
 CALL echo(build("resultformat: ",reply->resultformat))
 IF (count=0)
  SET reply->status_data.status = "Z"
  CALL echo(build("status_data->status = ",reply->status_data.status))
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(build("status_data->status = ",reply->status_data.status))
 ENDIF
END GO

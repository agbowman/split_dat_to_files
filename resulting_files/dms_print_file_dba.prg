CREATE PROGRAM dms_print_file:dba
 CALL echo("<==================== Entering DMS_PRINT_FILE Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error"
 DECLARE file_length = i4 WITH constant(size(request->file_blob))
 DECLARE dms_prefix = vc WITH constant("dms")
 DECLARE file_extension = vc WITH noconstant
 CASE (cnvtlower(trim(request->media_type)))
  OF "text/plain":
   SET file_extension = "txt"
  OF "application/postscript":
   SET file_extension = "ps"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unsupported media type"
   SET reply->status_data.subeventstatus[1].targetobjectname = "request->media_type"
   SET reply->status_data.subeventstatus[1].operationname = "PARSE"
   GO TO exit_script
 ENDCASE
 CALL parser("execute cpm_create_file_name dms_prefix, file_extension go")
 IF ((cpm_cfn_info->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Could not create file name"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cpm_create_file_name"
  SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
  GO TO exit_script
 ENDIF
 DECLARE file_name = vc WITH constant(nullterm(cpm_cfn_info->file_name_full_path))
 CALL echo(build("Temp file name is ",file_name))
 DECLARE uar_fopen(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fopen",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fopen"
 DECLARE uar_fwrite(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "decc$shr", uar_axp = "decc$fwrite", image_aix = "libc.a(shr.o)",
 uar_aix = "fwrite"
 DECLARE uar_fclose(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fclose",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fclose"
 DECLARE file_handle = i4 WITH constant(uar_fopen(nullterm(file_name),nullterm("w+b")))
 IF (file_handle=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Could not create file"
  SET reply->status_data.subeventstatus[1].targetobjectname = "fopen"
  SET reply->status_data.subeventstatus[1].operationname = "OPEN"
  GO TO exit_script
 ENDIF
 DECLARE count = i4 WITH constant(uar_fwrite(request->file_blob,1,file_length,file_handle))
 DECLARE close_stat = i4 WITH constant(uar_fclose(file_handle))
 IF (count != file_length)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Could not write all data to file."
  SET reply->status_data.subeventstatus[1].targetobjectname = "fwrite"
  SET reply->status_data.subeventstatus[1].operationname = "WRITE"
  GO TO exit_script
 ENDIF
 IF (close_stat != 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Could not close file"
  SET reply->status_data.subeventstatus[1].targetobjectname = "fclose"
  SET reply->status_data.subeventstatus[1].operationname = "CLOSE"
  GO TO exit_script
 ENDIF
 DECLARE spoolcommand1 = vc WITH noconstant
 DECLARE spoolcommand2 = vc WITH noconstant
 SET spoolcommand1 = concat("set spool = '",file_name,"' ",request->printer_name," with deleted, ")
 SET spoolcommand2 = build("copy = ",request->copies)
 IF ((request->orientation=2))
  SET spoolcommand2 = concat(spoolcommand2,", landscape")
 ENDIF
 IF (textlen(trim(request->paper_tray)) > 0)
  SET spoolcommand2 = concat(spoolcommand2,", print = ",request->paper_tray)
 ENDIF
 SET spoolcommand2 = concat(spoolcommand2," go")
 CALL echo(concat(spoolcommand1,spoolcommand2))
 CALL parser(spoolcommand1)
 CALL parser(spoolcommand2)
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "No error"
#exit_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_PRINT_FILE Script ====================>")
END GO

CREATE PROGRAM ccl_printfile:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cmdspool = vc
 DECLARE slandscape = vc
 DECLARE scompress = vc
 DECLARE sdiomode = vc
 DECLARE sdeleted = vc
 DECLARE ccomma1 = c1
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 IF (validate(request->devicecd,0) > 0)
  SELECT INTO "NL:"
   d.name
   FROM device d
   WHERE (d.device_cd=request->devicecd)
   DETAIL
    request->printer_name = trim(d.name)
   WITH nocounter
  ;end select
 ENDIF
 SET invalidchar = findstring(";",request->printer_name)
 IF (invalidchar > 0)
  SET errmsg = "Invalid printer name! Please remove ';'"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET sdiomode = concat("DIO=",request->diomode)
 IF (cnvtupper(request->landscape)="Y")
  SET slandscape = ",LANDSCAPE"
 ENDIF
 IF (cnvtupper(request->compress)="Y")
  SET scompress = ",COMPRESS"
 ENDIF
 IF (cnvtupper(request->deleted)="Y")
  SET sdeleted = ",DELETED"
 ENDIF
 SET cmdspool = concat("set spool = '",request->module_dir,request->module_name,"' ",request->
  printer_name,
  " with ",sdiomode,slandscape,scompress,sdeleted,
  " go")
 CALL echo(cmdspool)
 CALL parser(cmdspool)
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "PRINT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_PRINTFILE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

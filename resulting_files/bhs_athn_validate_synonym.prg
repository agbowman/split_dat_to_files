CREATE PROGRAM bhs_athn_validate_synonym
 FREE RECORD result
 RECORD result(
   1 is_valid = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req500680
 RECORD req500680(
   1 qual[*]
     2 synonym_id = f8
   1 facility_cd = f8
 ) WITH protect
 FREE RECORD rep500680
 RECORD rep500680(
   1 qual[*]
     2 synonym_id = f8
     2 active_ind = i2
     2 hide_flag = i2
     2 virtual_view_ind = i2
   1 status_data
     2 status = vc
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callissynonymvalid(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID SYNONYM ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID FACILITY CD PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callissynonymvalid(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<IsValid>",cnvtint(result->is_valid),"</IsValid>"), col + 1,
     v1, row + 1, col + 1,
     "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req500680
 FREE RECORD rep500680
 SUBROUTINE callissynonymvalid(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500196)
   DECLARE requestid = i4 WITH protect, constant(500680)
   SET stat = alterlist(req500680->qual,1)
   SET req500680->qual[1].synonym_id =  $2
   SET req500680->facility_cd =  $3
   CALL echorecord(req500680)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req500680,
    "REC",rep500680,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep500680)
   IF ((rep500680->status_data.status="S")
    AND size(rep500680->qual,5) > 0)
    IF ((rep500680->qual[1].active_ind=1)
     AND (rep500680->qual[1].hide_flag=0)
     AND (rep500680->qual[1].virtual_view_ind=1))
     SET result->is_valid = 1
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO

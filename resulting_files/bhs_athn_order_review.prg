CREATE PROGRAM bhs_athn_order_review
 FREE RECORD result
 RECORD result(
   1 error_ind = i2
   1 error_str = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req560202
 RECORD req560202(
   1 reviewlist[*]
     2 orderid = f8
     2 reviewtypeflag = i2
     2 providerid = f8
     2 locationcd = f8
     2 rejectedind = i2
     2 reviewpersonnelid = f8
     2 proxypersonnelid = f8
     2 proxyreasoncd = f8
     2 catalogtypecd = f8
     2 actionsequence = i2
     2 reviewactionflag = i2
     2 digitalsignatureident = c64
     2 bypassprescriptionreqprinting = i2
     2 reviewpersonnelgroupid = f8
 ) WITH protect
 FREE RECORD rep560202
 RECORD rep560202(
   1 errorind = i2
   1 reviewlist[*]
     2 orderid = f8
     2 errorind = i2
     2 errorstr = vc
     2 needind = i2
     2 errorflag = i4
     2 actionsequence = i4
   1 status_data
     2 status = vc
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
       3 requestnumber = i4
       3 orderid = f8
       3 actionseq = i4
       3 substatus = vc
 ) WITH protect
 DECLARE callormorderreview(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ORDER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (((( $4 < 1)) OR (( $4 > 4))) )
  CALL echo("INVALID REVIEW TYPE FLAG PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $5 <= 0.0))
  CALL echo("INVALID CATALOG TYPE CD PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $6 <= 0))
  CALL echo("INVALID ACTION SEQUENCE PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callormorderreview(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<ErrorInd>",cnvtint(result->error_ind),"</ErrorInd>"), col + 1,
    v1, row + 1, v2 = build("<ErrorStr>",trim(replace(replace(replace(replace(replace(result->
           error_str,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
     "</ErrorStr>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req560202
 FREE RECORD rep560202
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callormorderreview(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500196)
   DECLARE requestid = i4 WITH protect, constant(560202)
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    SET result->error_ind = 1
    SET result->error_str = "Impersonate user failed"
    RETURN(fail)
   ENDIF
   SET stat = alterlist(req560202->reviewlist,1)
   SET req560202->reviewlist[1].orderid =  $2
   SET req560202->reviewlist[1].reviewtypeflag =  $4
   SET req560202->reviewlist[1].reviewpersonnelid =  $3
   SET req560202->reviewlist[1].catalogtypecd =  $5
   SET req560202->reviewlist[1].actionsequence =  $6
   CALL echorecord(req560202)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req560202,
    "REC",rep560202,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    SET result->error_ind = 1
    SET result->error_str = "TdbExecute failed"
    RETURN(fail)
   ENDIF
   CALL echorecord(rep560202)
   SET result->error_ind = rep560202->errorind
   IF (size(rep560202->reviewlist,5) > 0)
    SET result->error_str = rep560202->reviewlist[1].errorstr
   ENDIF
   IF ((rep560202->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO

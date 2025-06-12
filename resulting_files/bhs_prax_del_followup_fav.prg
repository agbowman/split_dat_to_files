CREATE PROGRAM bhs_prax_del_followup_fav
 FREE RECORD result
 RECORD result(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE calldeletefollowupfav(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID FAVORITE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calldeletefollowupfav(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4250044
 FREE RECORD rep4250044
 SUBROUTINE calldeletefollowupfav(null)
   FREE RECORD req4250044
   RECORD req4250044(
     1 favorite_id = f8
     1 prsnl_id = f8
     1 who_name = vc
     1 who_id = f8
     1 who_string = vc
     1 when_dt_tm = dq8
     1 when_within_cd = f8
     1 when_in_val = i4
     1 when_in_type_flag = i2
     1 when_needed_ind = i2
     1 where_txt = vc
     1 comment_txt = vc
     1 recipient_txt = vc
   ) WITH protect
   FREE RECORD rep4250044
   RECORD rep4250044(
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET req4250044->favorite_id =  $2
   CALL echorecord(req4250044)
   EXECUTE fn_add_del_followup_favorites  WITH replace("REQUEST","REQ4250044"), replace("REPLY",
    "REP4250044")
   CALL echorecord(rep4250044)
   IF ((rep4250044->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO

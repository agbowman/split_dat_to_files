CREATE PROGRAM bhs_athn_get_ord_sentence
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
 FREE RECORD req120000
 RECORD req120000(
   1 order_sentence_id = f8
 ) WITH protect
 FREE RECORD rep120000
 RECORD rep120000(
   1 qual[*]
     2 sequence = i4
     2 oe_field_value = f8
     2 oe_field_id = f8
     2 oe_field_display_value = vc
     2 oe_field_meaning_id = f8
     2 field_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetordsentdetails(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ORDER SENTENCE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetordsentdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<OEFields>",
     row + 1
     FOR (idx = 1 TO size(rep120000->qual,5))
       col + 1, "<OEField>", row + 1,
       v1 = build("<FieldValue>",cnvtint(rep120000->qual[idx].oe_field_value),"</FieldValue>"), col
        + 1, v1,
       row + 1, v2 = build("<FieldId>",cnvtint(rep120000->qual[idx].oe_field_id),"</FieldId>"), col
        + 1,
       v2, row + 1, v3 = build("<FieldDisplayValue>",trim(replace(replace(replace(replace(replace(
              rep120000->qual[idx].oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
           "'","&apos;",0),'"',"&quot;",0),3),"</FieldDisplayValue>"),
       col + 1, v3, row + 1,
       v4 = build("<FieldMeaningId>",cnvtint(rep120000->qual[idx].oe_field_meaning_id),
        "</FieldMeaningId>"), col + 1, v4,
       row + 1, v5 = build("<FieldTypeFlag>",rep120000->qual[idx].field_type_flag,"</FieldTypeFlag>"),
       col + 1,
       v5, row + 1, col + 1,
       "</OEField>", row + 1
     ENDFOR
     col + 1, "</OEFields>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req120000
 FREE RECORD rep120000
 SUBROUTINE callgetordsentdetails(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500196)
   DECLARE requestid = i4 WITH protect, constant(120000)
   SET req120000->order_sentence_id =  $2
   CALL echorecord(req120000)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req120000,
    "REC",rep120000,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep120000)
   IF ((rep120000->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO

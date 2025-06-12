CREATE PROGRAM ams_add_route:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
 FREE RECORD request_303060
 RECORD request_303060(
   1 short_description = c40
   1 long_description = c50
   1 order_category = i4
   1 active_ind = i2
 )
 FREE RECORD request_303062
 RECORD request_303062(
   1 form_cd = f8
   1 route_cd = f8
 )
 FREE RECORD reply_303060
 RECORD reply_303060(
   1 route_cd = f8
   1 updt_cnt = i4
   1 codeval_updt_cnt = i4
   1 codevalext_updt_cnt = i4
   1 status_data[*]
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reply_303062
 RECORD reply_303062(
   1 status_data[*]
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FOR (i = 1 TO value(size(file_content->qual,5)))
   SET stat = initrec(request_303060)
   SET stat = initrec(request_303062)
   SET request_303060->short_description = trim(file_content->qual[i].short_description)
   SET request_303060->long_description = trim(file_content->qual[i].long_description)
   IF (trim(file_content->qual[i].order_type)="Medication")
    SET request_303060->order_category = 1
   ELSEIF (trim(file_content->qual[i].order_type)="Intermittent")
    SET request_303060->order_category = 2
   ELSEIF (trim(file_content->qual[i].order_type)="Continuous")
    SET request_303060->order_category = 4
   ENDIF
   SET request_303060->active_ind = 1
   SET stat = tdbexecute(300400,303060,303060,"REC",request_303060,
    "REC",reply_303060)
   SET request_303062->route_cd = reply_303060->route_cd
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=4002
     AND cv.display=trim(file_content->qual[i].form)
    DETAIL
     request_303062->form_cd = cv.code_value
    WITH nocounter
   ;end select
   SET stat = tdbexecute(300400,303062,303062,"REC",request_303062,
    "REC",reply_303062)
 ENDFOR
 CALL echorecord(request_303060)
 CALL echorecord(request_303062)
 CALL echorecord(reply_303060)
 CALL echorecord(reply_303062)
#exit_script
 SET script_ver = " 000 05/15/16 AR043066  Initial Release "
END GO

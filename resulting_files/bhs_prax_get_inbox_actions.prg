CREATE PROGRAM bhs_prax_get_inbox_actions
 FREE RECORD result
 RECORD result(
   1 actions[*]
     2 action_cd = f8
     2 action_disp = vc
     2 active_ind = i2
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD result_seq
 RECORD result_seq(
   1 list[*]
     2 ref_idx = i4
 ) WITH protect
 FREE RECORD req500374
 RECORD req500374(
   1 code_set = i4
   1 qual_cnt = i2
   1 qual[*]
     2 cdf_meaning = c12
 ) WITH protect
 FREE RECORD rep500374
 RECORD rep500374(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = vc
     2 description = vc
     2 active_ind = i2
     2 collation_seq = i4
     2 display_key = vc
     2 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetactions(null) = i2
 DECLARE sortresults(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (textlen(trim( $2,3)) <= 0)
  CALL echo("INVALID MESSAGE TYPE PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetactions(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = sortresults(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<Actions>",
     row + 1
     FOR (idx = 1 TO size(result_seq->list,5))
      pos = result_seq->list[idx].ref_idx,
      IF ((result->actions[pos].active_ind=1))
       col + 1, "<Action>", row + 1,
       v1 = build("<CodeValue>",cnvtint(result->actions[pos].action_cd),"</CodeValue>"), col + 1, v1,
       row + 1, v2 = build("<Display>",trim(replace(replace(replace(replace(replace(result->actions[
              pos].action_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
          "&quot;",0),3),"</Display>"), col + 1,
       v2, row + 1, col + 1,
       "</Action>", row + 1
      ENDIF
     ENDFOR
     col + 1, "</Actions>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req500374
 FREE RECORD rep500374
 FREE RECORD result_seq
 SUBROUTINE callgetactions(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600105)
   DECLARE requestid = i4 WITH constant(500374)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SET req500374->code_set = 3400
   SET req500374->qual_cnt = 1
   SET stat = alterlist(req500374->qual,req500374->qual_cnt)
   SET req500374->qual[1].cdf_meaning = trim( $2,3)
   CALL echorecord(req500374)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req500374,
    "REC",rep500374,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep500374)
   IF ((rep500374->status_data.status="S"))
    SET stat = alterlist(result->actions,size(rep500374->qual,5))
    FOR (idx = 1 TO size(rep500374->qual,5))
      SET result->actions[idx].action_cd = rep500374->qual[idx].code_value
      SET result->actions[idx].action_disp = rep500374->qual[idx].display
      SET result->actions[idx].active_ind = rep500374->qual[idx].active_ind
      SET result->actions[idx].collation_seq = rep500374->qual[idx].collation_seq
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE sortresults(null)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   IF (size(result->actions,5) > 0)
    SET stat = alterlist(result_seq->list,size(result->actions,5))
    SELECT INTO "NL:"
     sortkey = result->actions[d.seq].collation_seq
     FROM (dummyt d  WITH seq = size(result->actions,5))
     PLAN (d
      WHERE d.seq > 0)
     ORDER BY sortkey
     DETAIL
      rcnt = (rcnt+ 1), result_seq->list[rcnt].ref_idx = d.seq
     WITH nocounter, time = 30
    ;end select
   ENDIF
   CALL echorecord(result_seq)
   RETURN(success)
 END ;Subroutine
END GO

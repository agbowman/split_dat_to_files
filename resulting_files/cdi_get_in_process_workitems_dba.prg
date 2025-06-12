CREATE PROGRAM cdi_get_in_process_workitems:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual_cnt = i4
    1 ids_qual[*]
      2 work_item_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE inprocess = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"INPROCESS"))
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_IN_PROCESS_WORKITEMS **********")
 CALL echo(sline)
 SELECT INTO "nl:"
  FROM cdi_work_item wi
  WHERE wi.status_cd=inprocess
   AND (wi.owner_prsnl_id=reqinfo->updt_id)
   AND wi.end_effective_dt_tm > cnvtdatetime(sysdate)
  HEAD REPORT
   dstat = alterlist(reply->ids_qual,10), count = 0
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    dstat = alterlist(reply->ids_qual,(count+ 9))
   ENDIF
   reply->ids_qual[count].work_item_id = wi.cdi_work_item_id, sscriptstatus = "S"
  FOOT REPORT
   reply->qual_cnt = count, dstat = alterlist(reply->ids_qual,count)
  WITH nocounter
 ;end select
 IF (sscriptstatus="F")
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No in process work item found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_in_process_workitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_in_process_workitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_in_process_workitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Work items found"
 ENDIF
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 05/08/2014")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_IN_PROCESS_WORKITEMS **********")
 CALL echo(sline)
END GO

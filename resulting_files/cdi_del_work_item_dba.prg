CREATE PROGRAM cdi_del_work_item:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 qual[*]
      2 work_item_id = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 work_item_id = f8
      2 status = c1
      2 status_reason = vc
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
 DECLARE lreq_size = i4 WITH protect, constant(size(request->qual,5))
 DECLARE dstarttime = f8 WITH protect, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE ldcnt = i4 WITH protect, noconstant(0)
 DECLARE lscnt = i4 WITH protect, noconstant(0)
 DECLARE sstatus = c1 WITH protect, noconstant("")
 DECLARE sstatusreason = vc WITH protect, noconstant("")
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_DEL_WORK_ITEM **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET reply->qual_cnt = lreq_size
 SET dstat = alterlist(reply->qual,lreq_size)
 FOR (lidx = 1 TO lreq_size)
   SET reply->qual[lidx].work_item_id = request->qual[lidx].work_item_id
   SET reply->qual[lidx].status = "F"
   SET reply->qual[lidx].status_reason = "Invalid work_item_id"
 ENDFOR
 SELECT INTO "nl:"
  FROM cdi_work_item wi,
   prsnl p
  PLAN (wi
   WHERE expand(lidx,1,lreq_size,wi.cdi_work_item_id,reply->qual[lidx].work_item_id)
    AND wi.cdi_work_item_id > 0)
   JOIN (p
   WHERE p.person_id=wi.owner_prsnl_id)
  ORDER BY wi.cdi_work_item_id
  HEAD wi.cdi_work_item_id
   lidx = locateval(lidx,1,lreq_size,wi.cdi_work_item_id,reply->qual[lidx].work_item_id)
   IF (lidx > 0)
    IF (p.person_id > 0
     AND (p.person_id != reqinfo->updt_id))
     reply->qual[lidx].status = "F", reply->qual[lidx].status_reason = "Work Item Locked"
    ELSE
     reply->qual[lidx].status = "", reply->qual[lidx].status_reason = ""
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (lcnt = 1 TO reply->qual_cnt)
   IF ((reply->qual[lcnt].status != "F"))
    SET sstatus = "F"
    SET sstatusreason = ""
    SELECT INTO "nl:"
     FROM cdi_work_queue_item_reltn ir
     WHERE (ir.cdi_work_item_id=reply->qual[lcnt].work_item_id)
     WITH forupdate(ir)
    ;end select
    SET ldcnt = curqual
    IF (ldcnt > 0)
     DELETE  FROM cdi_work_queue_item_reltn ir
      WHERE (ir.cdi_work_item_id=reply->qual[lcnt].work_item_id)
     ;end delete
     IF (curqual=ldcnt)
      SET sstatus = "S"
      SET sstatusreason = ""
     ELSE
      SET sstatus = "F"
      SET sstatusreason = "Delete Failure - cdi_work_queue_item_reltn"
     ENDIF
    ENDIF
    IF (sstatus != "F")
     SELECT INTO "nl:"
      FROM long_text lt
      WHERE (lt.parent_entity_id=reply->qual[lcnt].work_item_id)
       AND lt.parent_entity_name="CDI_WORK_ITEM"
      WITH forupdate(lt)
     ;end select
     SET ldcnt = curqual
     IF (ldcnt > 0)
      DELETE  FROM long_text lt
       WHERE (lt.parent_entity_id=reply->qual[lcnt].work_item_id)
        AND lt.parent_entity_name="CDI_WORK_ITEM"
      ;end delete
      IF (curqual=ldcnt)
       SET sstatus = "S"
       SET sstatusreason = ""
      ELSE
       SET sstatus = "F"
       SET sstatusreason = "Delete Failure - long_text"
      ENDIF
     ENDIF
    ENDIF
    IF (sstatus != "F")
     SELECT INTO "nl:"
      FROM cdi_work_item wi
      WHERE (wi.prev_cdi_work_item_id=reply->qual[lcnt].work_item_id)
      WITH forupdate(wi)
     ;end select
     SET ldcnt = curqual
     IF (ldcnt > 0)
      DELETE  FROM cdi_work_item wi
       WHERE (wi.prev_cdi_work_item_id=reply->qual[lcnt].work_item_id)
      ;end delete
      IF (curqual=ldcnt)
       SET lscnt = (lscnt+ 1)
       SET sstatus = "S"
       SET sstatusreason = ""
      ELSE
       SET sstatus = "F"
       SET sstatusreason = "Delete Failure - cdi_work_item"
      ENDIF
     ELSE
      SET sstatus = "F"
      SET sstatusreason = "Lock Row Failure - cdi_work_item"
     ENDIF
    ENDIF
    SET reply->qual[lcnt].status = sstatus
    SET reply->qual[lcnt].status_reason = sstatusreason
    IF (sstatus="S")
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
   ENDIF
 ENDFOR
 IF ((lscnt=reply->qual_cnt))
  SET sscriptstatus = "S"
  SET sscriptmsg = "All work items were successfully deleted"
 ELSEIF (lscnt > 0)
  SET sscriptstatus = "S"
  SET sscriptmsg = "Some work items failed to delete, check individual status"
 ELSE
  SET sscriptstatus = "Z"
  SET sscriptmsg = "All work items failed to delete"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DEL_WORK_ITEM"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 11/11/2010")
 SET modify = nopredeclare
 CALL echo(sline)
 CALL echo("********** END CDI_DEL_WORK_ITEM **********")
 CALL echo(sline)
END GO

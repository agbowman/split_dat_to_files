CREATE PROGRAM dcp_upd_io_total_definition:dba
 DECLARE exec_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 IF (validate(debug_ind,0) != 1)
  SET debug_ind = 0
 ENDIF
 SET modify = predeclare
 RECORD reply(
   1 io_total_definition_id = f8
   1 dup_name_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req(
   1 debug_ind = i2
   1 io_total_definition_id = f8
   1 total_definition_name = vc
 )
 RECORD rep(
   1 no_dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH noconstant("F")
 IF ((((request->ensure_type="A")) OR ((request->ensure_type="M"))) )
  SET req->debug_ind = debug_ind
  SET req->io_total_definition_id = request->io_total_definition_id
  SET req->total_definition_name = request->total_definition_name
  EXECUTE dcp_check_dup_def_name  WITH replace("REQUEST","REQ"), replace("REPLY","REP")
  IF ((rep->no_dup_ind=0))
   SET failed = "T"
   SET reply->dup_name_ind = 1
   GO TO exit_program
  ENDIF
 ENDIF
 DECLARE addtotaldefinition(null) = null
 DECLARE addtotalelemreltns(total_group_id=f8,updt_dt_tm=q8) = null
 DECLARE modifytotaldefinition(null) = null
 DECLARE removetotaldefinition(null) = null
 IF ((request->ensure_type="A"))
  CALL addtotaldefinition(null)
 ELSEIF ((request->ensure_type="M"))
  CALL modifytotaldefinition(null)
 ELSEIF ((request->ensure_type="D"))
  CALL removetotaldefinition(null)
 ELSE
  SET failed = "T"
  GO TO exit_program
 ENDIF
 SUBROUTINE addtotaldefinition(null)
   DECLARE total_group_id = f8 WITH protect, noconstant(0.0)
   DECLARE total_definition_id = f8 WITH protect, noconstant(0.0)
   DECLARE updt_dt_tm = q8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
   SET reply->status_data.subeventstatus[1].operationname = "AddTotalDefinition"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     total_group_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL Q1"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   INSERT  FROM io_total_group_definition itg
    SET itg.io_total_group_id = total_group_id, itg.updt_applctx = reqinfo->updt_applctx, itg
     .updt_cnt = 0,
     itg.updt_dt_tm = cnvtdatetime(curdate,curtime3), itg.updt_id = reqinfo->updt_id, itg.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "IO_TOTAL_GROUP_DEFINITION"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     total_definition_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL Q2"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   INSERT  FROM io_total_definition itd
    SET itd.io_total_definition_id = total_definition_id, itd.prev_io_total_definition_id =
     total_definition_id, itd.io_total_group_id = total_group_id,
     itd.task_assay_cd = request->task_assay_cd, itd.total_definition_name = substring(1,200,request
      ->total_definition_name), itd.total_duration_type_cd = request->total_duration_type_cd,
     itd.total_duration = request->total_duration, itd.total_operation_type_cd = request->
     total_operation_cd, itd.total_type_cd = request->total_type_cd,
     itd.beg_effective_dt_tm = cnvtdatetime(updt_dt_tm), itd.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), itd.updt_applctx = reqinfo->updt_applctx,
     itd.updt_cnt = 0, itd.updt_dt_tm = cnvtdatetime(updt_dt_tm), itd.updt_id = reqinfo->updt_id,
     itd.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "IO_TOTAL_DEFINITION"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   CALL addtotalelemreltns(total_group_id,updt_dt_tm)
   SET reply->io_total_definition_id = total_definition_id
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
   SET reply->status_data.subeventstatus[1].operationname = "AddTotalDefinition"
 END ;Subroutine
 SUBROUTINE addtotalelemreltns(total_group_id,updt_dt_tm)
   DECLARE def_element_id = f8 WITH protect, noconstant(0.0)
   DECLARE def_element_reltn_id = f8 WITH protect, noconstant(0.0)
   DECLARE elem_cnt = i4 WITH protect, noconstant(size(request->io_total_definition_elements,5))
   SET reply->status_data.subeventstatus[1].operationname = "AddTotalElemReltns"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   FOR (j = 1 TO elem_cnt)
     SELECT INTO "nl:"
      ide.io_definition_element_id
      FROM io_definition_element ide
      WHERE (ide.event_cd=request->io_total_definition_elements[j].event_cd)
       AND (ide.route_cd=request->io_total_definition_elements[j].route_cd)
       AND (ide.iv_event_cd=request->io_total_definition_elements[j].iv_event_cd)
       AND ide.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      DETAIL
       def_element_id = ide.io_definition_element_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SELECT INTO "nl:"
       nextseqnum = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        def_element_id = cnvtreal(nextseqnum)
       WITH nocounter
      ;end select
      IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
       SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL Q1"
       SET failed = "T"
       GO TO exit_program
      ENDIF
      INSERT  FROM io_definition_element ite
       SET ite.io_definition_element_id = def_element_id, ite.prev_io_definition_element_id =
        def_element_id, ite.event_cd = request->io_total_definition_elements[j].event_cd,
        ite.route_cd = request->io_total_definition_elements[j].route_cd, ite.iv_event_cd = request->
        io_total_definition_elements[j].iv_event_cd, ite.beg_effective_dt_tm = cnvtdatetime(
         updt_dt_tm),
        ite.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ite.updt_applctx = reqinfo->
        updt_applctx, ite.updt_cnt = 0,
        ite.updt_dt_tm = cnvtdatetime(updt_dt_tm), ite.updt_id = reqinfo->updt_id, ite.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
       SET reply->status_data.subeventstatus[1].targetobjectname = "IO_DEF_ELEMENT_RELTN"
       SET failed = "T"
       GO TO exit_program
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       def_element_reltn_id = cnvtreal(nextseqnum)
      WITH nocounter
     ;end select
     IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
      SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL Q2"
      SET failed = "T"
      GO TO exit_program
     ENDIF
     INSERT  FROM io_def_element_reltn idr
      SET idr.io_def_element_reltn_id = def_element_reltn_id, idr.prev_io_def_element_reltn_id =
       def_element_reltn_id, idr.io_total_group_id = total_group_id,
       idr.io_definition_element_id = def_element_id, idr.beg_effective_dt_tm = cnvtdatetime(
        updt_dt_tm), idr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       idr.updt_applctx = reqinfo->updt_applctx, idr.updt_cnt = 0, idr.updt_dt_tm = cnvtdatetime(
        updt_dt_tm),
       idr.updt_id = reqinfo->updt_id, idr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
      SET reply->status_data.subeventstatus[1].targetobjectname = "IO_DEF_ELEMENT_RELTN"
      SET failed = "T"
      GO TO exit_program
     ENDIF
   ENDFOR
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
 END ;Subroutine
 SUBROUTINE modifytotaldefinition(null)
   DECLARE total_group_id = f8 WITH protect, noconstant(0.0)
   DECLARE updt_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   SET reply->status_data.subeventstatus[1].operationname = "ModifyTotalDefinition"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   INSERT  FROM io_total_definition itv
    (itv.io_total_definition_id, itv.prev_io_total_definition_id, itv.io_total_group_id,
    itv.task_assay_cd, itv.total_definition_name, itv.total_duration,
    itv.total_duration_type_cd, itv.total_operation_type_cd, itv.total_type_cd,
    itv.beg_effective_dt_tm, itv.end_effective_dt_tm, itv.updt_applctx,
    itv.updt_cnt, itv.updt_dt_tm, itv.updt_id,
    itv.updt_task)(SELECT
     seq(carenet_seq,nextval), itd.io_total_definition_id, itd.io_total_group_id,
     itd.task_assay_cd, itd.total_definition_name, itd.total_duration,
     itd.total_duration_type_cd, itd.total_operation_type_cd, itd.total_type_cd,
     itd.beg_effective_dt_tm, cnvtdatetime(updt_dt_tm), reqinfo->updt_applctx,
     0, cnvtdatetime(updt_dt_tm), reqinfo->updt_id,
     reqinfo->updt_task
     FROM io_total_definition itd
     WHERE (itd.io_total_definition_id=request->io_total_definition_id)
      AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
    WITH nocounter
   ;end insert
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "VERSIONING OF DEFINITION TABLE FAILED"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM io_total_definition ide
    WHERE (ide.io_total_definition_id=request->io_total_definition_id)
     AND ((ide.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    DETAIL
     total_group_id = ide.io_total_group_id
    WITH nocounter, forupdate(ide)
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "LOCK FAILED ON DEFINITION TABLE"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   UPDATE  FROM io_total_definition itd
    SET itd.total_definition_name = request->total_definition_name, itd.task_assay_cd = request->
     task_assay_cd, itd.total_duration = request->total_duration,
     itd.total_duration_type_cd = request->total_duration_type_cd, itd.total_operation_type_cd =
     request->total_operation_cd, itd.total_type_cd = request->total_type_cd,
     itd.beg_effective_dt_tm = cnvtdatetime(updt_dt_tm), itd.updt_applctx = reqinfo->updt_applctx,
     itd.updt_cnt = (itd.updt_cnt+ 1),
     itd.updt_dt_tm = cnvtdatetime(updt_dt_tm), itd.updt_id = reqinfo->updt_id, itd.updt_task =
     reqinfo->updt_task
    WHERE (itd.io_total_definition_id=request->io_total_definition_id)
     AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
   ;end update
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "DEFINITION ROW UPDATE FAILED"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM io_def_element_reltn idr
    WHERE idr.io_total_group_id=total_group_id
     AND ((idr.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    WITH nocounter, forupdate(idr)
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "IO_DEF_ELEMENT_RELTN"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM io_def_element_reltn idr
     SET idr.end_effective_dt_tm = cnvtdatetime(updt_dt_tm), idr.updt_applctx = reqinfo->updt_applctx,
      idr.updt_cnt = (idr.updt_cnt+ 1),
      idr.updt_dt_tm = cnvtdatetime(updt_dt_tm), idr.updt_id = reqinfo->updt_id, idr.updt_task =
      reqinfo->updt_task
     WHERE idr.io_total_group_id=total_group_id
      AND idr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
     WITH nocounter
    ;end update
    IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
     SET reply->status_data.subeventstatus[1].targetobjectname = "IO_DEF_ELEMENT_RELTN"
     SET failed = "T"
     GO TO exit_program
    ENDIF
   ENDIF
   CALL addtotalelemreltns(total_group_id,updt_dt_tm)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
   SET reply->status_data.subeventstatus[1].operationname = "ModifyTotalDefinition"
 END ;Subroutine
 SUBROUTINE removetotaldefinition(null)
   DECLARE total_group_id = f8 WITH protect, noconstant(0.0)
   DECLARE updt_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   SET reply->status_data.subeventstatus[1].operationname = "RemoveTotalDefinition"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SELECT INTO "nl:"
    FROM io_total_definition itd
    WHERE (itd.io_total_definition_id=request->io_total_definition_id)
     AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    DETAIL
     total_group_id = itd.io_total_group_id
    WITH nocounter, forupdate(itd)
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "LOCK FAILED ON DEFINITION TABLE"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   UPDATE  FROM io_total_definition itd
    SET itd.end_effective_dt_tm = cnvtdatetime(updt_dt_tm), itd.updt_applctx = reqinfo->updt_applctx,
     itd.updt_cnt = (itd.updt_cnt+ 1),
     itd.updt_dt_tm = cnvtdatetime(updt_dt_tm), itd.updt_id = reqinfo->updt_id, itd.updt_task =
     reqinfo->updt_task
    WHERE (itd.io_total_definition_id=request->io_total_definition_id)
     AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    WITH nocounter
   ;end update
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "DEFINITION ROW UPDATE FAILED"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM io_def_element_reltn idr
    WHERE idr.io_total_group_id=total_group_id
     AND ((idr.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    WITH nocounter, forupdate(idr)
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "LOCK FAILED ON DEF ELEMENT RELTN TABLE"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   UPDATE  FROM io_def_element_reltn idr
    SET idr.end_effective_dt_tm = cnvtdatetime(updt_dt_tm), idr.updt_applctx = reqinfo->updt_applctx,
     idr.updt_cnt = (idr.updt_cnt+ 1),
     idr.updt_dt_tm = cnvtdatetime(updt_dt_tm), idr.updt_id = reqinfo->updt_id, idr.updt_task =
     reqinfo->updt_task
    WHERE idr.io_total_group_id=total_group_id
     AND idr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    WITH nocounter
   ;end update
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "DEF ELEMENT RELATION ROW UPDATE FAILED"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
   SET reply->status_data.subeventstatus[1].operationname = "RemoveTotalDefinition"
 END ;Subroutine
#exit_program
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 IF (debug_ind=1)
  CALL echo("*********************")
  CALL echo("*	 THE REQUEST    *")
  CALL echo("*********************")
  CALL echorecord(request)
  CALL echo("*********************")
  CALL echo("*	  THE REPLY     *")
  CALL echo("*********************")
  CALL echorecord(reply)
  CALL echo("*********************")
  CALL echo("*	  EXEC TIME     *")
  CALL echo("*********************")
  CALL echo(build("TOTAL EXECUTION TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),
     exec_dt_tm,5)))
 ENDIF
END GO

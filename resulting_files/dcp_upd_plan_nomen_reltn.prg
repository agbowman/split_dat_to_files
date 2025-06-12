CREATE PROGRAM dcp_upd_plan_nomen_reltn
 SET modify = predeclare
 DECLARE child_count = i2 WITH constant(value(size(request->reltns,5)))
 DECLARE planicd9_cd = f8 WITH constant(uar_get_code_by("MEANING",23549,"PLANICD9"))
 DECLARE i = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE cstatus = c1 WITH noconstant("S")
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE insert_plan_diagnosis_reltn(idx=i4) = c1
 DECLARE update_plan_diagnosis_reltn(idx=i4) = c1
 DECLARE remove_plan_diagnosis_reltn(idx=i4) = c1
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (child_count <= 0)
  CALL report_failure("INSERT","F","DCP_UPD_PLAN_NOMEN_RELTN",
   "Nothing to UPDATE - relationship list is EMPTY")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO child_count)
   IF ((request->reltns[i].action_mean="INSERT"))
    SET cstatus = insert_plan_diagnosis_reltn(i)
    IF (cstatus="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_NOMEN_RELTN",
      "Unable to insert new plan diagnosis relation records")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->reltns[i].action_mean="MODIFY"))
    SET cstatus = update_plan_diagnosis_reltn(i)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_NOMEN_RELTN",
      "Unable to update plan diagnosis relation records")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->reltns[i].action_mean="REMOVE"))
    SET cstatus = remove_plan_diagnosis_reltn(i)
    IF (cstatus="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_NOMEN_RELTN",
      "Unable to inactivate plan diagnosis relation records")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE insert_plan_diagnosis_reltn(idx)
   DECLARE new_reltn_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(entity_reltn_seq,nextval)
    FROM dual
    DETAIL
     new_reltn_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   IF (new_reltn_id <= 0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_NOMEN_RELTN",
     "Failed to generate unique id for NOMEN_ENTITY_RELTN table")
    GO TO exit_script
   ENDIF
   INSERT  FROM nomen_entity_reltn ner
    SET ner.nomen_entity_reltn_id = new_reltn_id, ner.nomenclature_id = request->reltns[idx].
     nomenclature_id, ner.parent_entity_name = "PATHWAY",
     ner.parent_entity_id = request->pathway_id, ner.child_entity_name = "DIAGNOSIS", ner
     .child_entity_id = request->reltns[idx].diagnosis_id,
     ner.reltn_type_cd = planicd9_cd, ner.person_id = request->person_id, ner.encntr_id = request->
     encntr_id,
     ner.active_ind = 1, ner.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ner
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     ner.activity_type_cd = 0, ner.priority = request->reltns[idx].priority, ner.reltn_subtype_cd = 0,
     ner.updt_dt_tm = cnvtdatetime(curdate,curtime3), ner.updt_id = reqinfo->updt_id, ner.updt_task
      = reqinfo->updt_task,
     ner.updt_cnt = 0, ner.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_NOMEN_RELTN",
     "Failed to insert new row(s) into NOMEN_ENTITY_RELTN table")
    GO TO exit_script
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE update_plan_diagnosis_reltn(idx)
   SELECT INTO "nl:"
    ner.*
    FROM nomen_entity_reltn ner
    WHERE (ner.nomen_entity_reltn_id=request->reltns[idx].nomen_entity_reltn_id)
    WITH forupdate(ner), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_NOMEN_RELTN",
     "Unable to lock row on nomen_entity_reltn table")
    GO TO exit_script
   ENDIF
   UPDATE  FROM nomen_entity_reltn ner
    SET ner.priority = request->reltns[idx].priority, ner.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ner.updt_id = reqinfo->updt_id,
     ner.updt_task = reqinfo->updt_task, ner.updt_cnt = (ner.updt_cnt+ 1), ner.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (ner.nomen_entity_reltn_id=request->reltns[idx].nomen_entity_reltn_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_NOMEN_RELTN",
     "Unable to update priority on NOMEN_ENTITY_RELTN")
    GO TO exit_script
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE remove_plan_diagnosis_reltn(idx)
   SELECT INTO "nl:"
    ner.*
    FROM nomen_entity_reltn ner
    WHERE (ner.nomen_entity_reltn_id=request->reltns[idx].nomen_entity_reltn_id)
    WITH forupdate(ner), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_NOMEN_RELTN",
     "Unable to lock row on nomen_entity_reltn table")
    GO TO exit_script
   ENDIF
   UPDATE  FROM nomen_entity_reltn ner
    SET ner.active_ind = 0, ner.updt_dt_tm = cnvtdatetime(curdate,curtime3), ner.updt_id = reqinfo->
     updt_id,
     ner.updt_task = reqinfo->updt_task, ner.updt_cnt = (ner.updt_cnt+ 1), ner.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (ner.nomen_entity_reltn_id=request->reltns[idx].nomen_entity_reltn_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_NOMEN_RELTN",
     "Unable to inactivate row on NOMEN_ENTITY_RELTN")
    GO TO exit_script
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = trim(opname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_UPD_PLAN_NOMEN_RELTN",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "July 20, 2011"
END GO

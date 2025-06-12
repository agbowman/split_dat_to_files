CREATE PROGRAM dcp_upd_dcp_sect:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  RECORD reply(
    1 dcp_section_ref_id = f8
    1 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET forms_temp
 RECORD forms_temp(
   1 forms[*]
     2 form_instance_id = f8
     2 dcp_forms_ref_id = f8
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE now = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dscriptstarttime = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dactionstarttime = dq8 WITH protect, noconstant(0)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE fail_ind = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE ref_id = f8 WITH protect, noconstant(request->dcp_section_ref_id)
 DECLARE instance_id = f8 WITH protect, noconstant(0.0)
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE input_id = f8 WITH protect, noconstant(0.0)
 DECLARE client_modify = i2 WITH protect, noconstant(0)
 DECLARE exact_match = i2 WITH protect, noconstant(0)
 DECLARE entity_reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE formcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE input_cnt = i4 WITH protect, noconstant(0)
 DECLARE prop_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE script_debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(debug_ind))
  SET script_debug_ind = debug_ind
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 IF (ref_id > 0)
  SELECT INTO "nl:"
   FROM dcp_section_ref dsr
   WHERE dsr.dcp_section_ref_id=ref_id
    AND (dsr.updt_cnt=request->updt_cnt)
    AND dsr.active_ind=1
   DETAIL
    updt_cnt = (dsr.updt_cnt+ 1)
   WITH maxqual(dsr,1), nocounter
  ;end select
  IF (curqual=0)
   CALL echo("No active section found for the dcp_section_ref_id and updt_cnt.")
   CALL fillsubeventstatus("SELECT","F","dcp_upd_dcp_sect",
    "Section not found matching the dcp_section_ref_id and updt_cnt.  It may have been updated by someone else."
    )
   SELECT INTO "nl:"
    FROM dcp_section_ref dsr
    WHERE dsr.dcp_section_ref_id=ref_id
     AND dsr.active_ind=1
    DETAIL
     CALL echo(build("Active row's updt_cnt=",dsr.updt_cnt))
    WITH nocounter
   ;end select
   SET fail_ind = 1
   GO TO exit_script
  ELSE
   CALL echo(build("New updt_cnt=",updt_cnt))
  ENDIF
  UPDATE  FROM dcp_section_ref dsr
   SET dsr.active_ind = 0, dsr.end_effective_dt_tm = cnvtdatetime(now), dsr.updt_dt_tm = cnvtdatetime
    (now),
    dsr.updt_id = reqinfo->updt_id, dsr.updt_task = reqinfo->updt_task, dsr.updt_applctx = reqinfo->
    updt_applctx,
    dsr.updt_cnt = (dsr.updt_cnt+ 1)
   WHERE dsr.dcp_section_ref_id=ref_id
    AND dsr.active_ind=1
   WITH nocounter
  ;end update
 ELSE
  SELECT INTO "nl:"
   w = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    ref_id = w
   WITH nocounter
  ;end select
  CALL echo(build("New dcp_section_ref_id=",ref_id))
 ENDIF
 SELECT INTO "nl:"
  w = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   instance_id = w
  WITH nocounter
 ;end select
 CALL echo(build("New dcp_section_instance_id=",instance_id))
 INSERT  FROM dcp_section_ref dsr
  SET dsr.dcp_section_ref_id = ref_id, dsr.dcp_section_instance_id = instance_id, dsr.description =
   request->description,
   dsr.definition = request->definition, dsr.task_assay_cd = request->task_assay_cd, dsr.event_cd =
   request->event_cd,
   dsr.beg_effective_dt_tm = cnvtdatetime(now), dsr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
   dsr.active_ind = 1,
   dsr.width = request->width, dsr.height = request->height, dsr.updt_dt_tm = cnvtdatetime(now),
   dsr.updt_id = reqinfo->updt_id, dsr.updt_task = reqinfo->updt_task, dsr.updt_applctx = reqinfo->
   updt_applctx,
   dsr.updt_cnt = updt_cnt
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL echo("Failed to insert the new dcp_section_ref row.")
  CALL fillsubeventstatus("INSERT","F","dcp_upd_dcp_sect",
   "Failed to insert a row into dcp_section_ref.")
  SET fail_ind = 1
  GO TO exit_script
 ENDIF
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Section update/insert time = ",datetimediff(cnvtdatetime(curdate,curtime3),
     dactionstarttime,5)))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SET input_cnt = size(request->input_list,5)
 FOR (i = 1 TO input_cnt)
   SELECT INTO "nl:"
    w = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     input_id = w
    WITH nocounter
   ;end select
   INSERT  FROM dcp_input_ref dir
    SET dir.dcp_input_ref_id = input_id, dir.dcp_section_ref_id = ref_id, dir.dcp_section_instance_id
      = instance_id,
     dir.description = request->input_list[i].description, dir.module = request->input_list[i].module,
     dir.input_ref_seq = request->input_list[i].input_ref_seq,
     dir.input_type = request->input_list[i].input_type, dir.active_ind = 1, dir.updt_cnt = 0,
     dir.updt_dt_tm = cnvtdatetime(now), dir.updt_id = reqinfo->updt_id, dir.updt_task = reqinfo->
     updt_task,
     dir.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL echo(build("Failed to insert the new dcp_input_ref row for input=",i))
    CALL fillsubeventstatus("INSERT","F","dcp_upd_dcp_sect",
     "Failed to insert a row into dcp_input_ref.")
    SET fail_ind = 1
    GO TO exit_script
   ENDIF
   SET prop_cnt = size(request->input_list[i].nv,5)
   IF (prop_cnt > 0)
    INSERT  FROM name_value_prefs nvp,
      (dummyt d  WITH seq = value(prop_cnt))
     SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_name =
      "DCP_INPUT_REF", nvp.parent_entity_id = input_id,
      nvp.pvc_name = request->input_list[i].nv[d.seq].pvc_name, nvp.pvc_value = request->input_list[i
      ].nv[d.seq].pvc_value, nvp.merge_name = request->input_list[i].nv[d.seq].merge_name,
      nvp.merge_id = request->input_list[i].nv[d.seq].merge_id, nvp.sequence = request->input_list[i]
      .nv[d.seq].sequence, nvp.active_ind = 1,
      nvp.updt_dt_tm = cnvtdatetime(now), nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->
      updt_task,
      nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
     PLAN (d)
      JOIN (nvp)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo(build("Failed to insert the new name_value_prefs row for input=",i))
     CALL fillsubeventstatus("INSERT","F","dcp_upd_dcp_sect",
      "Failed to insert a row into name_value_prefs.")
     SET fail_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
 CALL fillsubeventstatus("INSERT","S","dcp_upd_dcp_sect",build("Input control insert time = ",
   delapsedtime))
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Input control insert time = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 IF ((request->cki > " "))
  SELECT INTO "nl:"
   FROM cki_entity_reltn cki
   WHERE cki.parent_entity_id=ref_id
    AND cki.parent_entity_name="DCP_SECTION_REF"
   DETAIL
    IF ((cki.cki != request->cki))
     client_modify = 1
    ELSE
     exact_match = 1
    ENDIF
   WITH nocounter, forupdate(cki)
  ;end select
  IF (client_modify=1)
   UPDATE  FROM cki_entity_reltn cki1
    SET cki1.cki = request->cki, cki1.updt_dt_tm = cnvtdatetime(now), cki1.updt_id = reqinfo->updt_id,
     cki1.updt_task = reqinfo->updt_task, cki1.updt_applctx = reqinfo->updt_applctx, cki1.updt_cnt =
     (cki1.updt_cnt+ 1)
    WHERE cki1.parent_entity_id=ref_id
     AND cki1.parent_entity_name="DCP_SECTION_REF"
    WITH nocounter
   ;end update
  ELSEIF (exact_match=0)
   SELECT INTO "nl:"
    w = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     entity_reltn_id = w
    WITH nocounter
   ;end select
   INSERT  FROM cki_entity_reltn cki2
    SET cki2.cki = request->cki, cki2.cki_entity_reltn_id = entity_reltn_id, cki2.parent_entity_id =
     ref_id,
     cki2.parent_entity_name = "DCP_SECTION_REF", cki2.updt_dt_tm = cnvtdatetime(now), cki2.updt_id
      = reqinfo->updt_id,
     cki2.updt_task = reqinfo->updt_task, cki2.updt_applctx = reqinfo->updt_applctx, cki2.updt_cnt =
     0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("CKI insert/update time = ",datetimediff(cnvtdatetime(curdate,curtime3),
     dactionstarttime,5)))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM dcp_forms_def dfd,
   dcp_forms_ref dfr
  WHERE dfd.dcp_section_ref_id=ref_id
   AND dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
   AND dfr.active_ind=1
  DETAIL
   formcnt = (formcnt+ 1)
   IF (mod(formcnt,10)=1)
    stat = alterlist(forms_temp->forms,(formcnt+ 9))
   ENDIF
   forms_temp->forms[formcnt].form_instance_id = dfr.dcp_form_instance_id, forms_temp->forms[formcnt]
   .dcp_forms_ref_id = dfr.dcp_forms_ref_id
  FOOT REPORT
   stat = alterlist(forms_temp->forms,formcnt)
  WITH nocounter
 ;end select
 IF (script_debug_ind=2)
  CALL echo("Forms that contain the updated section.")
  CALL echorecord(forms_temp)
 ENDIF
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Identify forms time = ",datetimediff(cnvtdatetime(curdate,curtime3),
     dactionstarttime,5)))
  CALL echo(build("formcnt = ",formcnt))
  CALL echo("*******************************************************")
 ENDIF
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("Error found before scanning the forms.")
  CALL echo(build("ERROR CODE: ",ierrorcode))
  CALL echo(build("ERROR MESSAGE: ",serrormsg))
  CALL fillsubeventstatus("ERROR","F","dcp_upd_dcp_sect",serrormsg)
  SET fail_ind = 1
  GO TO exit_script
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 FOR (loop_cnt = 1 TO formcnt)
   IF ((request->dcp_forms_ref_id != forms_temp->forms[loop_cnt].dcp_forms_ref_id))
    EXECUTE dcp_scan_form forms_temp->forms[loop_cnt].form_instance_id
    SET ierrorcode = error(serrormsg,1)
    IF (ierrorcode != 0)
     CALL echo(build("Error while scanning the form with dcp_form_instance_id=",forms_temp->forms[
       loop_cnt].form_instance_id))
     CALL echo(build("ERROR CODE: ",ierrorcode))
     CALL echo(build("ERROR MESSAGE: ",serrormsg))
     CALL fillsubeventstatus("ERROR","F","dcp_upd_dcp_sect",serrormsg)
     SET fail_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
 CALL fillsubeventstatus("UPDATE","S","dcp_upd_dcp_sect",build("Scan all forms time = ",delapsedtime)
  )
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Scan all forms time = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
#exit_script
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dscriptstarttime,5)
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo(build("ERROR CODE: ",ierrorcode))
  CALL echo(build("ERROR MESSAGE: ",serrormsg))
  CALL fillsubeventstatus("ERROR","F","dcp_upd_dcp_sect",serrormsg)
  CALL fillsubeventstatus("UPDATE","F","dcp_upd_dcp_sect",build("Execution time=",delapsedtime))
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSEIF (fail_ind=1)
  CALL echo("Failure reported.  Exiting.")
  CALL fillsubeventstatus("UPDATE","F","dcp_upd_dcp_sect",build("Execution time=",delapsedtime))
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  CALL echo("******** Success ********")
  CALL fillsubeventstatus("UPDATE","S","dcp_upd_dcp_sect",build("Forms updated=",formcnt))
  CALL fillsubeventstatus("UPDATE","S","dcp_upd_dcp_sect",build("Execution time=",delapsedtime))
  SET reply->status_data.status = "S"
  SET reply->dcp_section_ref_id = ref_id
  SET reply->updt_cnt = updt_cnt
  SET reqinfo->commit_ind = 1
 ENDIF
 IF (script_debug_ind=2)
  CALL echorecord(reply)
 ENDIF
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo("dcp_upd_dcp_sect Last Modified = 007 11/04/10")
  CALL echo(build("dcp_upd_dcp_sect Total Time = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 IF (script_debug_ind=0)
  FREE SET forms_temp
 ENDIF
 SET modify = nopredeclare
END GO

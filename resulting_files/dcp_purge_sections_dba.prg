CREATE PROGRAM dcp_purge_sections:dba
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 FREE SET temp
 RECORD temp(
   1 sections[*]
     2 dcp_section_instance_id = f8
     2 dcp_section_ref_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 activity = i2
   1 properties[*]
     2 name_value_prefs_id = f8
 )
 SET modify = predeclare
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE delete_ind = i2 WITH protect, noconstant(false)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prop_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dcp_section_ref dsr
  WHERE dsr.active_ind=0
   AND dsr.dcp_section_ref_id > 0
  ORDER BY dsr.dcp_section_instance_id
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->sections,cnt), temp->sections[cnt].dcp_section_instance_id
    = dsr.dcp_section_instance_id,
   temp->sections[cnt].dcp_section_ref_id = dsr.dcp_section_ref_id, temp->sections[cnt].
   beg_effective_dt_tm = dsr.beg_effective_dt_tm, temp->sections[cnt].end_effective_dt_tm = dsr
   .end_effective_dt_tm,
   temp->sections[cnt].activity = 0
  WITH nocounter
 ;end select
 CALL echo(build("Count:",cnt))
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_forms_def dfd,
   dcp_forms_ref dfr
  PLAN (d)
   JOIN (dfd
   WHERE (dfd.dcp_section_ref_id=temp->sections[d.seq].dcp_section_ref_id))
   JOIN (dfr
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfr.beg_effective_dt_tm > cnvtdatetime(temp->sections[d.seq].beg_effective_dt_tm)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(temp->sections[d.seq].end_effective_dt_tm))
  DETAIL
   temp->sections[d.seq].activity = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_forms_def dfd,
   dcp_forms_ref dfr
  PLAN (d
   WHERE (temp->sections[d.seq].activity=0))
   JOIN (dfd
   WHERE (dfd.dcp_section_ref_id=temp->sections[d.seq].dcp_section_ref_id))
   JOIN (dfr
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfr.end_effective_dt_tm >= cnvtdatetime(temp->sections[d.seq].beg_effective_dt_tm)
    AND dfr.beg_effective_dt_tm < cnvtdatetime(temp->sections[d.seq].beg_effective_dt_tm))
  DETAIL
   temp->sections[d.seq].activity = 1
  WITH counter
 ;end select
 FOR (i = 1 TO cnt)
   IF ((temp->sections[i].activity=0))
    SELECT INTO "nl:"
     FROM dcp_input_ref dir,
      name_value_prefs nv
     PLAN (dir
      WHERE (dir.dcp_section_instance_id=temp->sections[i].dcp_section_instance_id))
      JOIN (nv
      WHERE nv.parent_entity_id=dir.dcp_input_ref_id
       AND nv.parent_entity_name="DCP_INPUT_REF")
     DETAIL
      prop_cnt = (prop_cnt+ 1), stat = alterlist(temp->properties,prop_cnt), temp->properties[
      prop_cnt].name_value_prefs_id = nv.name_value_prefs_id
     WITH nocounter
    ;end select
    CALL echo(build("Delete:",temp->sections[i].dcp_section_instance_id))
    SET delete_ind = true
    DELETE  FROM dcp_input_ref
     WHERE (dcp_section_instance_id=temp->sections[i].dcp_section_instance_id)
     WITH nocounter
    ;end delete
    DELETE  FROM dcp_section_ref
     WHERE (dcp_section_instance_id=temp->sections[i].dcp_section_instance_id)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
 FOR (i = 1 TO prop_cnt)
  SET delete_ind = true
  DELETE  FROM name_value_prefs
   WHERE (name_value_prefs_id=temp->properties[i].name_value_prefs_id)
   WITH nocounter
  ;end delete
 ENDFOR
 CALL echo(cnt)
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_PURGE_SECTIONS",serrormsg)
  ROLLBACK
 ELSEIF (delete_ind=false)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET modify = nopredeclare
END GO

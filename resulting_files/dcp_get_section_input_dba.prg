CREATE PROGRAM dcp_get_section_input:dba
 IF (validate(reply,"Y")="Y")
  RECORD reply(
    1 dcp_section_instance_id = f8
    1 dcp_section_ref_id = f8
    1 description = vc
    1 definition = vc
    1 task_assay_cd = f8
    1 task_assay_disp = vc
    1 event_cd = f8
    1 event_disp = vc
    1 active_ind = i2
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
    1 updt_cnt = i4
    1 input_cnt = i2
    1 input_list[*]
      2 dcp_input_ref_id = f8
      2 input_ref_seq = i4
      2 description = vc
      2 module = vc
      2 input_type = i4
      2 updt_cnt = i4
      2 nv_cnt = i2
      2 nv[*]
        3 pvc_name = vc
        3 pvc_value = vc
        3 merge_id = f8
        3 sequence = i4
    1 cki = vc
    1 width = i4
    1 height = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET modify = predeclare
 DECLARE instance_id = f8 WITH protect, noconstant(request->dcp_section_instance_id)
 DECLARE ref_id = f8 WITH protect, noconstant(request->dcp_section_ref_id)
 DECLARE input_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE nv_cnt = i4 WITH protect, noconstant(0)
 DECLARE dsr_where = vc WITH protect, noconstant(fillstring(500," "))
 DECLARE reply_status = c1 WITH protect, noconstant("F")
 IF (ref_id=0
  AND instance_id=0)
  SELECT INTO "nl"
   FROM cki_entity_reltn cki,
    dcp_section_ref dsr
   PLAN (cki
    WHERE (cki.cki=request->cki))
    JOIN (dsr
    WHERE dsr.dcp_section_ref_id=cki.parent_entity_id
     AND dsr.active_ind=1)
   DETAIL
    ref_id = dsr.dcp_section_ref_id, instance_id = dsr.dcp_section_instance_id
   WITH nocounter
  ;end select
 ENDIF
 IF (ref_id=0
  AND instance_id=0)
  SET reply->status_data.subeventstatus[1].operationname = "CKI_ENTITY_RELTN"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Cannot Find the CKI '",request
   ->cki,"' in above table")
  GO TO exit_script
 ENDIF
 SELECT
  IF (instance_id=0)
   PLAN (dsr
    WHERE dsr.dcp_section_ref_id=ref_id
     AND dsr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND dsr.active_ind=1)
    JOIN (dir
    WHERE dir.dcp_section_instance_id=outerjoin(dsr.dcp_section_instance_id))
    JOIN (nvp
    WHERE nvp.parent_entity_id=outerjoin(dir.dcp_input_ref_id)
     AND nvp.parent_entity_name=outerjoin("DCP_INPUT_REF")
     AND nvp.active_ind=outerjoin(1))
  ELSE
  ENDIF
  INTO "nl:"
  dsr.dcp_section_ref_id, dir.dcp_input_ref_id, dir.input_ref_seq,
  nvp.name_value_prefs_id
  FROM dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (dsr
   WHERE dsr.dcp_section_instance_id=instance_id)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=outerjoin(dsr.dcp_section_instance_id))
   JOIN (nvp
   WHERE nvp.parent_entity_id=outerjoin(dir.dcp_input_ref_id)
    AND nvp.parent_entity_name=outerjoin("DCP_INPUT_REF")
    AND nvp.active_ind=outerjoin(1))
  ORDER BY dsr.dcp_section_ref_id, dir.input_ref_seq, dir.dcp_input_ref_id,
   nvp.sequence
  HEAD REPORT
   input_list_cnt = 0, reply->dcp_section_instance_id = dsr.dcp_section_instance_id, reply->
   dcp_section_ref_id = dsr.dcp_section_ref_id,
   reply->description = dsr.description, reply->definition = dsr.definition, reply->task_assay_cd =
   dsr.task_assay_cd,
   reply->event_cd = dsr.event_cd, reply->active_ind = dsr.active_ind, reply->beg_effective_dt_tm =
   dsr.beg_effective_dt_tm,
   reply->end_effective_dt_tm = dsr.end_effective_dt_tm, reply->updt_cnt = dsr.updt_cnt, reply->width
    = dsr.width,
   reply->height = dsr.height
  HEAD dir.dcp_input_ref_id
   IF (dir.dcp_input_ref_id > 0)
    input_list_cnt = (input_list_cnt+ 1)
    IF (input_list_cnt > size(reply->input_list,5))
     stat = alterlist(reply->input_list,(input_list_cnt+ 10))
    ENDIF
    reply->input_list[input_list_cnt].dcp_input_ref_id = dir.dcp_input_ref_id, reply->input_list[
    input_list_cnt].input_ref_seq = dir.input_ref_seq, reply->input_list[input_list_cnt].module = dir
    .module,
    reply->input_list[input_list_cnt].input_type = dir.input_type, reply->input_list[input_list_cnt].
    updt_cnt = dir.updt_cnt
    IF (dir.input_type=1
     AND dir.module=trim("PFPMCtrls")
     AND dir.description = null)
     reply->input_list[input_list_cnt].description = trim("Gestational Age Person")
    ELSEIF (dir.input_type=2
     AND dir.module=trim("PFPMCtrls")
     AND dir.description = null)
     reply->input_list[input_list_cnt].description = trim("Gestational Age Encntr")
    ELSE
     reply->input_list[input_list_cnt].description = dir.description
    ENDIF
   ENDIF
   nv_cnt = 0
  DETAIL
   IF (nvp.name_value_prefs_id > 0
    AND input_list_cnt > 0)
    nv_cnt = (nv_cnt+ 1)
    IF (nv_cnt > size(reply->input_list[input_list_cnt].nv,5))
     stat = alterlist(reply->input_list[input_list_cnt].nv,(nv_cnt+ 10))
    ENDIF
    reply->input_list[input_list_cnt].nv[nv_cnt].pvc_name = nvp.pvc_name, reply->input_list[
    input_list_cnt].nv[nv_cnt].pvc_value = nvp.pvc_value, reply->input_list[input_list_cnt].nv[nv_cnt
    ].merge_id = nvp.merge_id,
    reply->input_list[input_list_cnt].nv[nv_cnt].sequence = nvp.sequence
   ENDIF
  FOOT  dir.dcp_input_ref_id
   IF (dir.dcp_input_ref_id > 0)
    reply->input_list[input_list_cnt].nv_cnt = nv_cnt, stat = alterlist(reply->input_list[
     input_list_cnt].nv,nv_cnt)
   ENDIF
  FOOT REPORT
   reply->input_cnt = input_list_cnt, stat = alterlist(reply->input_list,input_list_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply_status = "Z"
 ELSE
  SET reply_status = "S"
 ENDIF
 IF (textlen(trim(request->cki))=0
  AND (reply->dcp_section_ref_id > 0))
  SELECT INTO "nl:"
   FROM cki_entity_reltn cki1
   WHERE (cki1.parent_entity_id=reply->dcp_section_ref_id)
   DETAIL
    reply->cki = cki1.cki
   WITH nocounter
  ;end select
 ELSE
  SET reply->cki = request->cki
 ENDIF
#exit_script
 SET reply->status_data.status = reply_status
END GO

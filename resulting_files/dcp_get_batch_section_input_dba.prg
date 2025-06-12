CREATE PROGRAM dcp_get_batch_section_input:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sections[*]
      2 dcp_section_instance_id = f8
      2 dcp_section_ref_id = f8
      2 description = vc
      2 definition = vc
      2 task_assay_cd = f8
      2 task_assay_disp = vc
      2 event_cd = f8
      2 event_disp = vc
      2 active_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 updt_cnt = i4
      2 input_cnt = i2
      2 cki = vc
      2 input_list[*]
        3 dcp_input_ref_id = f8
        3 input_ref_seq = i4
        3 description = vc
        3 module = vc
        3 input_type = i4
        3 updt_cnt = i4
        3 nv_cnt = i2
        3 nv[*]
          4 pvc_name = vc
          4 pvc_value = vc
          4 merge_id = f8
          4 sequence = i4
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
 DECLARE instance_id = f8 WITH noconstant
 DECLARE ref_id = f8 WITH noconstant
 DECLARE section_request_count = i4 WITH noconstant(0)
 DECLARE section_count = i4 WITH noconstant(0)
 DECLARE input_count = i4 WITH noconstant(0)
 DECLARE name_value_pref_count = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 SET section_request_count = size(request->sections,5)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->sections,section_request_count)
 FOR (j = 1 TO section_request_count)
  SET instance_id = request->sections[j].dcp_section_instance_id
  IF (instance_id=0)
   SET ref_id = request->sections[j].dcp_section_ref_id
   SET reply->sections[j].cki = request->sections[j].cki
   IF (ref_id=0
    AND instance_id=0)
    SELECT INTO "nl"
     FROM cki_entity_reltn cki,
      dcp_section_ref dsr
     PLAN (cki
      WHERE (cki.cki=request->sections[j].cki))
      JOIN (dsr
      WHERE (dsr.dcp_section_ref_id= Outerjoin(cki.parent_entity_id))
       AND (dsr.active_ind= Outerjoin(1)) )
     DETAIL
      ref_id = dsr.dcp_section_ref_id, instance_id = dsr.dcp_section_instance_id
     WITH nocounter
    ;end select
   ENDIF
   IF (ref_id=0
    AND instance_id=0)
    SET reply->status_data.subeventstatus[1].operationname = "CKI_ENTITY_RELTN"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Cannot Find the CKI in above table"
    GO TO exit_script
   ENDIF
   IF (instance_id=0)
    SELECT INTO "nl:"
     FROM dcp_section_ref s
     WHERE s.dcp_section_ref_id=ref_id
      AND s.active_ind=1
     DETAIL
      instance_id = s.dcp_section_instance_id
     WITH maxqual(s,1), nocounter
    ;end select
   ENDIF
   IF (instance_id=0)
    GO TO exit_script
   ENDIF
   SET request->sections[j].dcp_section_instance_id = instance_id
   SET request->sections[j].dcp_section_ref_id = ref_id
  ENDIF
 ENDFOR
 SET input_count = 0
 SET name_value_pref_count = 0
 SELECT INTO "nl:"
  dsr.dcp_section_ref_id, dir.dcp_input_ref_id, dir.input_ref_seq,
  nvp.name_value_prefs_id
  FROM (dummyt drequest  WITH seq = value(section_request_count)),
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (drequest)
   JOIN (dsr
   WHERE (dsr.dcp_section_instance_id=request->sections[drequest.seq].dcp_section_instance_id))
   JOIN (dir
   WHERE (dir.dcp_section_instance_id= Outerjoin(dsr.dcp_section_instance_id)) )
   JOIN (nvp
   WHERE (nvp.parent_entity_id= Outerjoin(dir.dcp_input_ref_id))
    AND (nvp.parent_entity_name= Outerjoin("DCP_INPUT_REF"))
    AND (nvp.active_ind= Outerjoin(1)) )
  ORDER BY drequest.seq, dsr.dcp_section_instance_id, dir.input_ref_seq,
   dir.dcp_input_ref_id
  HEAD REPORT
   section_count = 0
  HEAD dsr.dcp_section_instance_id
   section_count += 1, input_count = 0, reply->sections[section_count].dcp_section_instance_id = dsr
   .dcp_section_instance_id,
   reply->sections[section_count].dcp_section_ref_id = dsr.dcp_section_ref_id, reply->sections[
   section_count].description = dsr.description, reply->sections[section_count].definition = dsr
   .definition,
   reply->sections[section_count].task_assay_cd = dsr.task_assay_cd, reply->sections[section_count].
   event_cd = dsr.event_cd, reply->sections[section_count].active_ind = dsr.active_ind,
   reply->sections[section_count].beg_effective_dt_tm = dsr.beg_effective_dt_tm, reply->sections[
   section_count].end_effective_dt_tm = dsr.end_effective_dt_tm, reply->sections[section_count].
   updt_cnt = dsr.updt_cnt
  HEAD dir.dcp_input_ref_id
   IF (dir.dcp_input_ref_id > 0)
    input_count += 1
    IF (input_count > size(reply->sections[section_count].input_list,5))
     stat = alterlist(reply->sections[section_count].input_list,(input_count+ 10))
    ENDIF
    reply->sections[section_count].input_list[input_count].dcp_input_ref_id = dir.dcp_input_ref_id,
    reply->sections[section_count].input_list[input_count].input_ref_seq = dir.input_ref_seq, reply->
    sections[section_count].input_list[input_count].description = dir.description,
    reply->sections[section_count].input_list[input_count].module = dir.module, reply->sections[
    section_count].input_list[input_count].input_type = dir.input_type, reply->sections[section_count
    ].input_list[input_count].updt_cnt = dir.updt_cnt
   ENDIF
   name_value_pref_count = 0
  DETAIL
   IF (nvp.name_value_prefs_id > 0
    AND input_count > 0)
    name_value_pref_count += 1
    IF (name_value_pref_count > size(reply->sections[section_count].input_list[input_count].nv,5))
     stat = alterlist(reply->sections[section_count].input_list[input_count].nv,(
      name_value_pref_count+ 10))
    ENDIF
    reply->sections[section_count].input_list[input_count].nv[name_value_pref_count].pvc_name = nvp
    .pvc_name, reply->sections[section_count].input_list[input_count].nv[name_value_pref_count].
    pvc_value = nvp.pvc_value, reply->sections[section_count].input_list[input_count].nv[
    name_value_pref_count].merge_id = nvp.merge_id,
    reply->sections[section_count].input_list[input_count].nv[name_value_pref_count].sequence = nvp
    .sequence
   ENDIF
  FOOT  dir.dcp_input_ref_id
   IF (dir.dcp_input_ref_id > 0)
    reply->sections[section_count].input_list[input_count].nv_cnt = name_value_pref_count, stat =
    alterlist(reply->sections[section_count].input_list[input_count].nv,name_value_pref_count)
   ENDIF
  FOOT  dsr.dcp_section_instance_id
   reply->sections[section_count].input_cnt = input_count, stat = alterlist(reply->sections[
    section_count].input_list,input_count)
  WITH nocounter
 ;end select
 IF (section_count != section_request_count)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DCP_SECTION_REF"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to find all requested sections"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FOR (j = 1 TO section_count)
   IF ((reply->sections[j].cki <= " "))
    SELECT INTO "nl:"
     FROM cki_entity_reltn cki1
     WHERE (cki1.parent_entity_id=reply->sections[j].dcp_section_ref_id)
     DETAIL
      reply->sections[j].cki = cki1.cki
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
END GO

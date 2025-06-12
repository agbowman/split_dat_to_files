CREATE PROGRAM dcp_get_form_activity:dba
 SET modify maxvarlen 20971520
 IF ( NOT (validate(reply,0)))
  CALL echo("reply not defined")
  RECORD reply(
    1 dcp_forms_activity_id = f8
    1 dcp_forms_ref_id = f8
    1 person_id = f8
    1 encntr_id = f8
    1 updt_cnt = i4
    1 form_dt_tm = dq8
    1 form_tz = i4
    1 form_status_cd = f8
    1 flags = i4
    1 beg_activity_dt_tm = dq8
    1 last_activity_dt_tm = dq8
    1 active_ind = i2
    1 version_dt_tm = dq8
    1 prsnl[*]
      2 prsnl_id = f8
      2 prsnl_ft = vc
      2 proxy_id = f8
      2 activity_dt_tm = dq8
      2 activity_tz = i4
    1 comp[*]
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 component_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 task_id = f8
    1 description = vc
    1 ignore_req_ind = i2
    1 task_type_cd = f8
    1 task_updt_cnt = i4
    1 task_dt_tm = dq8
    1 charges[1]
      2 provider_id = f8
      2 location_cd = f8
      2 diagnosis[*]
        3 nomen_id = f8
        3 source_string = vc
        3 source_identifier = vc
      2 cpt_modifier[*]
        3 modifier_cd = f8
        3 display = vc
        3 description = vc
    1 long_blob = gvc
  )
 ENDIF
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET activityformid = request->form_activity_id
 DECLARE provcd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGEPROV")))
 DECLARE loccd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGELOC")))
 DECLARE diag_entry = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGEDIAG")))
 DECLARE cpt_entry = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGECPT")))
 DECLARE blobcd = f8 WITH constant(uar_get_code_by("MEANING",18189,nullterm("FORMXML")))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE countd = i4 WITH protect, noconstant(0)
 DECLARE countc = i4 WITH protect, noconstant(0)
 DECLARE newsize = i4 WITH protect, noconstant(0)
 DECLARE outbuf = vc WITH protect, noconstant(" ")
 DECLARE blobun = i4 WITH protect, noconstant(0)
 SET blobout = fillstring(20971520," ")
 DECLARE fulldatasize = i4 WITH protect, noconstant(0)
 IF (activityformid=0)
  SET query_event_id = request->primary_event_id
  SET cdf_meaning = "CLINCALEVENT"
  IF ((request->primary_event_id=0))
   SET query_event_id = request->document_event_id
   SET cdf_meaning = "TEXTREND"
  ENDIF
  SET code_set = 18189
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  SET compcd = code_value
  SELECT INTO "nl:"
   FROM dcp_forms_activity_comp c
   WHERE c.parent_entity_id=query_event_id
    AND c.parent_entity_id > 0.0
    AND c.component_cd=compcd
   DETAIL
    activityformid = c.dcp_forms_activity_id
   WITH nocounter, maxqual(c,1)
  ;end select
 ENDIF
 IF (activityformid=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_forms_activity"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_activity a
  WHERE a.dcp_forms_activity_id=activityformid
  DETAIL
   reply->dcp_forms_activity_id = a.dcp_forms_activity_id, reply->dcp_forms_ref_id = a
   .dcp_forms_ref_id, reply->person_id = a.person_id,
   reply->encntr_id = a.encntr_id, reply->updt_cnt = a.updt_cnt, reply->form_dt_tm = cnvtdatetime(a
    .form_dt_tm),
   reply->form_tz = validate(a.form_tz,0), reply->form_status_cd = a.form_status_cd, reply->flags = a
   .flags,
   reply->beg_activity_dt_tm = cnvtdatetime(a.beg_activity_dt_tm), reply->last_activity_dt_tm =
   cnvtdatetime(a.last_activity_dt_tm), reply->active_ind = a.active_ind,
   reply->task_id = a.task_id, reply->description = a.description
   IF (a.version_dt_tm=null)
    reply->version_dt_tm = cnvtdatetime(a.beg_activity_dt_tm)
   ELSE
    reply->version_dt_tm = cnvtdatetime(a.version_dt_tm)
   ENDIF
  WITH nocounter, maxqual(a,1)
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_forms_activity"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((reply->task_id != 0)
  AND (request->get_form_task_ind != 0))
  SELECT INTO "nl:"
   FROM task_activity ta,
    order_task ot
   PLAN (ta
    WHERE (ta.task_id= Outerjoin(reply->task_id)) )
    JOIN (ot
    WHERE (ot.reference_task_id= Outerjoin(ta.reference_task_id)) )
   DETAIL
    reply->task_type_cd = ta.task_type_cd, reply->task_updt_cnt = ta.updt_cnt, reply->task_dt_tm = ta
    .task_dt_tm,
    reply->ignore_req_ind = ot.ignore_req_ind
  ;end select
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_forms_activity_prsnl p
  WHERE p.dcp_forms_activity_id=activityformid
  ORDER BY p.activity_dt_tm
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->prsnl,(cnt+ 10))
   ENDIF
   reply->prsnl[cnt].prsnl_id = p.prsnl_id, reply->prsnl[cnt].prsnl_ft = p.prsnl_ft, reply->prsnl[cnt
   ].proxy_id = p.proxy_id,
   reply->prsnl[cnt].activity_dt_tm = cnvtdatetime(p.activity_dt_tm), reply->prsnl[cnt].activity_tz
    = validate(p.activity_tz,0)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prsnl,cnt)
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_forms_activity_comp c
  WHERE c.dcp_forms_activity_id=activityformid
   AND  NOT (c.component_cd IN (provcd, loccd, diag_entry, cpt_entry))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->comp,(cnt+ 10))
   ENDIF
   reply->comp[cnt].parent_entity_name = c.parent_entity_name, reply->comp[cnt].parent_entity_id = c
   .parent_entity_id, reply->comp[cnt].component_cd = c.component_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->comp,cnt)
 SELECT INTO "nl:"
  dc.parent_entity_id
  FROM dcp_forms_activity_comp dc
  WHERE dc.dcp_forms_activity_id=activityformid
   AND dc.component_cd IN (provcd, loccd)
  DETAIL
   IF (dc.component_cd=provcd)
    reply->charges[0].provider_id = dc.parent_entity_id
   ELSEIF (dc.component_cd=loccd)
    reply->charges[0].location_cd = dc.parent_entity_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dc.parent_entity_id
  FROM dcp_forms_activity_comp dc,
   nomenclature n
  PLAN (dc
   WHERE dc.dcp_forms_activity_id=activityformid
    AND dc.component_cd=diag_entry)
   JOIN (n
   WHERE n.nomenclature_id=dc.parent_entity_id)
  HEAD REPORT
   countd = 0
  DETAIL
   countd += 1
   IF (mod(countd,10)=1)
    stat = alterlist(reply->charges[0].diagnosis,(countd+ 9))
   ENDIF
   reply->charges[0].diagnosis[countd].nomen_id = n.nomenclature_id, reply->charges[0].diagnosis[
   countd].source_string = n.source_string, reply->charges[0].diagnosis[countd].source_identifier = n
   .source_identifier
  FOOT REPORT
   stat = alterlist(reply->charges[0].diagnosis,countd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dc.parent_entity_id
  FROM dcp_forms_activity_comp dc,
   code_value cv
  PLAN (dc
   WHERE dc.dcp_forms_activity_id=activityformid
    AND dc.component_cd=cpt_entry)
   JOIN (cv
   WHERE cv.code_value=dc.parent_entity_id)
  HEAD REPORT
   countc = 0
  DETAIL
   countc += 1
   IF (mod(countc,10)=1)
    stat = alterlist(reply->charges[0].cpt_modifier,(countc+ 9))
   ENDIF
   reply->charges[0].cpt_modifier[countc].modifier_cd = cv.code_value, reply->charges[0].
   cpt_modifier[countc].display = cv.display, reply->charges[0].cpt_modifier[countc].description = cv
   .description
  FOOT REPORT
   stat = alterlist(reply->charges[0].cpt_modifier,countc)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity_comp dc,
   long_blob lb
  PLAN (dc
   WHERE dc.dcp_forms_activity_id=activityformid
    AND dc.component_cd=blobcd)
   JOIN (lb
   WHERE lb.long_blob_id=dc.parent_entity_id
    AND lb.active_ind=1)
  DETAIL
   fulldatasize = blobgetlen(lb.long_blob), stat = memrealloc(outbuf,1,build("C",fulldatasize)),
   fullblob = blobget(outbuf,0,lb.long_blob),
   blobun = uar_ocf_uncompress(outbuf,size(outbuf),blobout,size(blobout),newsize), blobout =
   substring(1,newsize,blobout), reply->long_blob = blobout
  WITH nocounter
 ;end select
#exit_script
 SET modify = hipaa
 EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
 "Person", "Patient", "DCP FORMS",
 "Access/Use", request->form_activity_id, ""
 IF ((reply->encntr_id != 0))
  EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
  "Encounter", "Patient", "Encounter",
  "Access/Use", reply->encntr_id, ""
 ELSE
  EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
  "Person", "Patient", "Patient",
  "Access/Use", reply->person_id, ""
 ENDIF
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO

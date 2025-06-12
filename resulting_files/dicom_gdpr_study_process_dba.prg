CREATE PROGRAM dicom_gdpr_study_process:dba
 IF ( NOT (validate(request)))
  RECORD request(
    1 person_id = f8
    1 mode = i2
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE count = i4 WITH noconstant(0)
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0)
 DECLARE code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"DICOM_SIUID"))
 DECLARE getlogicaldomainid(null) = null WITH protect
 RECORD studyinstanceuids(
   1 qual[*]
     2 blob_handle = vc
     2 jq_primary_key = f8
 ) WITH protect
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce,
   ce_blob_result cbr
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (cbr
   WHERE cbr.event_id=ce.event_id
    AND cbr.storage_cd=code_value)
  DETAIL
   count += 1, stat = alterlist(studyinstanceuids->qual,count), studyinstanceuids->qual[count].
   blob_handle = cbr.blob_handle
  WITH nocounter
 ;end select
 IF (size(studyinstanceuids->qual,5) > 0)
  IF ((request->mode=1))
   SET reply->status_data.subeventstatus[1].operationname = "HIDE"
   INSERT  FROM cps_jq_camm_gdpr_hidestudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.entity_ident = studyinstanceuids->qual[dt.seq].blob_handle, cps
     .cps_jq_camm_gdpr_hidestudy_id = seq(cps_job_seq,nextval), cps.sys_ts = cnvttimestamp(
      datetimezone(cnvtdatetime(sysdate),0,2)),
     cps.next_retry_ts = cnvttimestamp(datetimezone(cnvtdatetime(sysdate),0,2))
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JQ_CAMM_GDPR_HIDESTUDY"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM cps_jq_camm_gdpr_hidestudy cps,
     (dummyt dt  WITH seq = count)
    PLAN (dt)
     JOIN (cps
     WHERE (cps.entity_ident=studyinstanceuids->qual[dt.seq].blob_handle))
    DETAIL
     studyinstanceuids->qual[dt.seq].jq_primary_key = cps.cps_jq_camm_gdpr_hidestudy_id
    WITH nocounter
   ;end select
   INSERT  FROM cps_jp_camm_gdpr_hidestudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.cps_jq_camm_gdpr_hidestudy_id = studyinstanceuids->qual[dt.seq].jq_primary_key, cps
     .cps_jp_camm_gdpr_hidestudy_id = seq(cps_job_seq,nextval), cps.param_name = "PERSON_ID",
     cps.param_value = cnvtstring(request->person_id), cps.sys_ts = cnvttimestamp(datetimezone(
       cnvtdatetime(sysdate),0,2)), cps.sequence_nbr = 0
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_GDPR_HIDESTUDY"
    GO TO exit_script
   ENDIF
   CALL getlogicaldomainid(null)
   INSERT  FROM cps_jp_camm_gdpr_hidestudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.cps_jq_camm_gdpr_hidestudy_id = studyinstanceuids->qual[dt.seq].jq_primary_key, cps
     .cps_jp_camm_gdpr_hidestudy_id = seq(cps_job_seq,nextval), cps.param_name = "LOGICAL_DOMAIN_ID",
     cps.param_value = cnvtstring(logical_domain_id), cps.sys_ts = cnvttimestamp(datetimezone(
       cnvtdatetime(sysdate),0,2)), cps.sequence_nbr = 1
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_GDPR_HIDESTUDY"
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->mode=2))
   SET reply->status_data.subeventstatus[1].operationname = "RESTORE"
   INSERT  FROM cps_jq_camm_gdpr_reststudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.entity_ident = studyinstanceuids->qual[dt.seq].blob_handle, cps
     .cps_jq_camm_gdpr_reststudy_id = seq(cps_job_seq,nextval), cps.sys_ts = cnvttimestamp(
      datetimezone(cnvtdatetime(sysdate),0,2)),
     cps.next_retry_ts = cnvttimestamp(datetimezone(cnvtdatetime(sysdate),0,2))
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JQ_CAMM_GDPR_RESTSTUDY"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM cps_jq_camm_gdpr_reststudy cps,
     (dummyt dt  WITH seq = count)
    PLAN (dt)
     JOIN (cps
     WHERE (cps.entity_ident=studyinstanceuids->qual[dt.seq].blob_handle))
    DETAIL
     studyinstanceuids->qual[dt.seq].jq_primary_key = cps.cps_jq_camm_gdpr_reststudy_id
    WITH nocounter
   ;end select
   INSERT  FROM cps_jp_camm_gdpr_reststudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.cps_jq_camm_gdpr_reststudy_id = studyinstanceuids->qual[dt.seq].jq_primary_key, cps
     .cps_jp_camm_gdpr_reststudy_id = seq(cps_job_seq,nextval), cps.param_name = "PERSON_ID",
     cps.param_value = cnvtstring(request->person_id), cps.sys_ts = cnvttimestamp(datetimezone(
       cnvtdatetime(sysdate),0,2)), cps.sequence_nbr = 0
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_GDPR_RESTSTUDY"
    GO TO exit_script
   ENDIF
   CALL getlogicaldomainid(null)
   INSERT  FROM cps_jp_camm_gdpr_reststudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.cps_jq_camm_gdpr_reststudy_id = studyinstanceuids->qual[dt.seq].jq_primary_key, cps
     .cps_jp_camm_gdpr_reststudy_id = seq(cps_job_seq,nextval), cps.param_name = "LOGICAL_DOMAIN_ID",
     cps.param_value = cnvtstring(logical_domain_id), cps.sys_ts = cnvttimestamp(datetimezone(
       cnvtdatetime(sysdate),0,2)), cps.sequence_nbr = 1
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_GDPR_RESTSTUDY"
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->mode=3))
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   INSERT  FROM cps_jq_camm_gdpr_delstudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.entity_ident = studyinstanceuids->qual[dt.seq].blob_handle, cps
     .cps_jq_camm_gdpr_delstudy_id = seq(cps_job_seq,nextval), cps.sys_ts = cnvttimestamp(
      datetimezone(cnvtdatetime(sysdate),0,2)),
     cps.next_retry_ts = cnvttimestamp(datetimezone(cnvtdatetime(sysdate),0,2))
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JQ_CAMM_GDPR_DELSTUDY"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM cps_jq_camm_gdpr_delstudy cps,
     (dummyt dt  WITH seq = count)
    PLAN (dt)
     JOIN (cps
     WHERE (cps.entity_ident=studyinstanceuids->qual[dt.seq].blob_handle))
    DETAIL
     studyinstanceuids->qual[dt.seq].jq_primary_key = cps.cps_jq_camm_gdpr_delstudy_id
    WITH nocounter
   ;end select
   INSERT  FROM cps_jp_camm_gdpr_delstudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.cps_jq_camm_gdpr_delstudy_id = studyinstanceuids->qual[dt.seq].jq_primary_key, cps
     .cps_jp_camm_gdpr_delstudy_id = seq(cps_job_seq,nextval), cps.param_name = "PERSON_ID",
     cps.param_value = cnvtstring(request->person_id), cps.sys_ts = cnvttimestamp(datetimezone(
       cnvtdatetime(sysdate),0,2)), cps.sequence_nbr = 0
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_GDPR_DELSTUDY"
    GO TO exit_script
   ENDIF
   CALL getlogicaldomainid(null)
   INSERT  FROM cps_jp_camm_gdpr_delstudy cps,
     (dummyt dt  WITH seq = count)
    SET cps.cps_jq_camm_gdpr_delstudy_id = studyinstanceuids->qual[dt.seq].jq_primary_key, cps
     .cps_jp_camm_gdpr_delstudy_id = seq(cps_job_seq,nextval), cps.param_name = "LOGICAL_DOMAIN_ID",
     cps.param_value = cnvtstring(logical_domain_id), cps.sys_ts = cnvttimestamp(datetimezone(
       cnvtdatetime(sysdate),0,2)), cps.sequence_nbr = 1
    PLAN (dt)
     JOIN (cps)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_GDPR_DELSTUDY"
    GO TO exit_script
   ENDIF
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No studies found for the given person."
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to queue job"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSEIF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Job Queued successfully"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
 SUBROUTINE getlogicaldomainid(null)
   SELECT INTO "nl:"
    FROM person p
    WHERE (person_id=request->person_id)
    DETAIL
     logical_domain_id = p.logical_domain_id
    WITH nocounter
   ;end select
 END ;Subroutine
END GO

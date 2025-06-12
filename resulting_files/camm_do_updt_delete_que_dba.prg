CREATE PROGRAM camm_do_updt_delete_que:dba
 CALL echo("<=================== Entering CAMM_DO_UPDT_DELETE_QUE Script ===================>")
 IF ( NOT (validate(request)))
  RECORD request(
    1 person_id = f8
  )
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
 CALL echorecord(request)
 DECLARE countmedia = i4 WITH noconstant(0)
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0.0)
 DECLARE getlogicaldomainid(null) = null WITH protect
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE generatejobseqid(null) = null WITH protect
 FREE RECORD mediaobjectids
 RECORD mediaobjectids(
   1 qual[*]
     2 media_object_identifier = vc
     2 jq_primary_key = f8
 ) WITH protect
 SET reply->status_data.status = "F"
 SET code_value = uar_get_code_by("MEANING",25,"MMF")
 CALL echo(build2("code value: ",code_value))
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce,
   ce_blob_result c
  PLAN (ce
   WHERE (ce.person_id=request->person_id))
   JOIN (c
   WHERE c.event_id=ce.event_id
    AND c.storage_cd=code_value)
  DETAIL
   countmedia += 1, stat = alterlist(mediaobjectids->qual,countmedia), mediaobjectids->qual[
   countmedia].media_object_identifier = c.blob_handle
  WITH nocounter
 ;end select
 CALL echorecord(mediaobjectids)
 IF (size(mediaobjectids->qual,5) > 0)
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  INSERT  FROM cps_jq_camm_deletecontent cps,
    (dummyt dt  WITH seq = countmedia)
   SET cps.cps_jq_camm_deletecontent_id = seq(cps_job_seq,nextval), cps.entity_ident = mediaobjectids
    ->qual[dt.seq].media_object_identifier, cps.sys_ts = cnvttimestamp(datetimezone(cnvtdatetime(
       sysdate),0,2)),
    cps.next_retry_ts = cnvttimestamp(datetimezone(cnvtdatetime(sysdate),0,2))
   PLAN (dt)
    JOIN (cps)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JQ_CAMM_DELETECONTENT"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM cps_jq_camm_deletecontent cps,
    (dummyt dt  WITH seq = countmedia)
   PLAN (dt)
    JOIN (cps
    WHERE (cps.entity_ident=mediaobjectids->qual[dt.seq].media_object_identifier))
   DETAIL
    mediaobjectids->qual[dt.seq].jq_primary_key = cps.cps_jq_camm_deletecontent_id
   WITH nocounter
  ;end select
  INSERT  FROM cps_jp_camm_deletecontent cps,
    (dummyt dt  WITH seq = countmedia)
   SET cps.cps_jp_camm_deletecontent_id = seq(cps_job_seq,nextval), cps.cps_jq_camm_deletecontent_id
     = mediaobjectids->qual[dt.seq].jq_primary_key, cps.param_name = "PERSON_ID",
    cps.param_value = cnvtstring(request->person_id), cps.sequence_nbr = 0, cps.sys_ts =
    cnvttimestamp(datetimezone(cnvtdatetime(sysdate),0,2))
   PLAN (dt)
    JOIN (cps)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_DELETECONTENT"
   GO TO exit_script
  ENDIF
  CALL getlogicaldomainid(null)
  INSERT  FROM cps_jp_camm_deletecontent cps,
    (dummyt dt  WITH seq = countmedia)
   SET cps.cps_jp_camm_deletecontent_id = seq(cps_job_seq,nextval), cps.cps_jq_camm_deletecontent_id
     = mediaobjectids->qual[dt.seq].jq_primary_key, cps.param_name = "LOGICAL_DOMAIN_ID",
    cps.param_value = cnvtstring(logical_domain_id), cps.sequence_nbr = 1, cps.sys_ts = cnvttimestamp
    (datetimezone(cnvtdatetime(sysdate),0,2))
   PLAN (dt)
    JOIN (cps)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CPS_JP_CAMM_DELETECONTENT"
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No objects found for the given person."
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
END GO

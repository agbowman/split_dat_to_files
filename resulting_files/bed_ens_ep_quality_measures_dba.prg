CREATE PROGRAM bed_ens_ep_quality_measures:dba
 IF ( NOT (validate(reply,0)))
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
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE req_size = i4 WITH protect
 SET req_size = size(request->eligible_providers,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   br_elig_prov_meas_reltn qmr
  PLAN (d)
   JOIN (qmr
   WHERE (qmr.br_eligible_provider_id=request->eligible_providers[d.seq].eligible_provider_id)
    AND qmr.active_ind=1
    AND qmr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
   ENDIF
   delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_id = qmr.br_elig_prov_meas_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_name = "BR_ELIG_PROV_MEAS_RELTN"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("DELHISTERROR")
 DELETE  FROM (dummyt d  WITH seq = req_size),
   br_elig_prov_meas_reltn qmr
  SET qmr.seq = 1
  PLAN (d)
   JOIN (qmr
   WHERE (qmr.br_eligible_provider_id=request->eligible_providers[d.seq].eligible_provider_id)
    AND qmr.active_ind=1
    AND qmr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Error deleting all saved measures")
 FOR (j = 1 TO req_size)
   FOR (i = 1 TO size(request->eligible_providers[j].quality_measures,5))
     SET br_elig_prov_meas_reltn_id = 0.0
     SELECT INTO "nl:"
      z = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       br_elig_prov_meas_reltn_id = cnvtreal(z)
      WITH nocounter
     ;end select
     INSERT  FROM br_elig_prov_meas_reltn qmr
      SET qmr.br_elig_prov_meas_reltn_id = br_elig_prov_meas_reltn_id, qmr.br_eligible_provider_id =
       request->eligible_providers[j].eligible_provider_id, qmr.pca_quality_measure_id = request->
       eligible_providers[j].quality_measures[i].quality_measure_id,
       qmr.measure_seq = request->eligible_providers[j].quality_measures[i].sequence, qmr.updt_dt_tm
        = cnvtdatetime(curdate,curtime3), qmr.updt_id = reqinfo->updt_id,
       qmr.updt_task = reqinfo->updt_task, qmr.updt_applctx = reqinfo->updt_applctx, qmr.updt_cnt = 0,
       qmr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), qmr.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00"), qmr.orig_br_elig_prov_meas_r_id =
       br_elig_prov_meas_reltn_id,
       qmr.active_ind = 1
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Error inserting relations to quality measures")
   ENDFOR
 ENDFOR
 IF (delete_hist_cnt > 0)
  INSERT  FROM br_delete_hist his,
    (dummyt d  WITH seq = delete_hist_cnt)
   SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
    deleted_item[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_item[d.seq].
    parent_entity_id,
    his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task =
    reqinfo->updt_task,
    his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
     curdate,curtime3)
   PLAN (d)
    JOIN (his)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("DELHISTINSERTFAILED1")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

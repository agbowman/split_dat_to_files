CREATE PROGRAM bed_get_ep_quality_measures:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 eligible_providers[*]
      2 eligible_provider_id = f8
      2 quality_measures[*]
        3 quality_measure_id = f8
        3 sequence = i2
        3 display = vc
        3 description = vc
        3 cki = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE req_size = i4 WITH protect, noconstant(size(request->eligible_providers,5))
 DECLARE measure_cnt = i4 WITH protect, noconstant(0)
 DECLARE ep_with_qm_cnt = i4 WITH protect, noconstant(0)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl"
  FROM (dummyt d  WITH seq = req_size),
   br_elig_prov_meas_reltn qmr,
   pca_quality_measure pqm,
   code_value cv
  PLAN (d)
   JOIN (qmr
   WHERE (qmr.br_eligible_provider_id=request->eligible_providers[d.seq].eligible_provider_id)
    AND qmr.active_ind=1
    AND qmr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pqm
   WHERE pqm.pca_quality_measure_id=qmr.pca_quality_measure_id)
   JOIN (cv
   WHERE cv.code_value=pqm.measure_cd)
  ORDER BY qmr.br_eligible_provider_id
  HEAD qmr.br_eligible_provider_id
   ep_with_qm_cnt = (ep_with_qm_cnt+ 1), stat = alterlist(reply->eligible_providers,ep_with_qm_cnt),
   reply->eligible_providers[ep_with_qm_cnt].eligible_provider_id = qmr.br_eligible_provider_id,
   measure_cnt = 0
  DETAIL
   measure_cnt = (measure_cnt+ 1), stat = alterlist(reply->eligible_providers[ep_with_qm_cnt].
    quality_measures,measure_cnt), reply->eligible_providers[ep_with_qm_cnt].quality_measures[
   measure_cnt].quality_measure_id = qmr.pca_quality_measure_id,
   reply->eligible_providers[ep_with_qm_cnt].quality_measures[measure_cnt].sequence = qmr.seq, reply
   ->eligible_providers[ep_with_qm_cnt].quality_measures[measure_cnt].display = pqm.display_txt,
   reply->eligible_providers[ep_with_qm_cnt].quality_measures[measure_cnt].description = pqm
   .description_txt,
   reply->eligible_providers[ep_with_qm_cnt].quality_measures[measure_cnt].cki = cv.cki
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selected quality measures.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

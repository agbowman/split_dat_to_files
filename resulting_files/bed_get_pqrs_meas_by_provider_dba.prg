CREATE PROGRAM bed_get_pqrs_meas_by_provider:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 provider_id = f8
      2 measures[*]
        3 meas_provider_reltn_id = f8
        3 measure_id = f8
        3 display = vc
        3 pilot_eligible_ind = i2
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
 DECLARE ep_cnt = i4
 DECLARE measure_cnt = i4
 DECLARE p_temp_cnt = i4
 DECLARE m_temp_cnt = i4
 SET ep_cnt = 0
 SET measure_cnt = 0
 SET pcnt = size(request->providers,5)
 IF (pcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pcnt)),
    br_pqrs_meas_provider_reltn m,
    br_pqrs_meas ms
   PLAN (d)
    JOIN (m
    WHERE (m.br_eligible_provider_id=request->providers[d.seq].provider_id)
     AND m.active_ind=1
     AND m.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (request->pilot_measures_flag=m.pilot_eligible_ind))
    JOIN (ms
    WHERE ms.br_pqrs_meas_id=m.br_pqrs_meas_id
     AND (((request->pilot_measures_flag=0)) OR (ms.pilot_core_ind=0)) )
   ORDER BY m.br_eligible_provider_id
   HEAD REPORT
    p_temp_cnt = 0, stat = alterlist(reply->providers,100)
   HEAD m.br_eligible_provider_id
    ep_cnt = (ep_cnt+ 1), p_temp_cnt = (p_temp_cnt+ 1)
    IF (p_temp_cnt > 100)
     p_temp_cnt = 1, stat = alterlist(reply->providers,(ep_cnt+ 100))
    ENDIF
    reply->providers[ep_cnt].provider_id = m.br_eligible_provider_id, measure_cnt = 0, m_temp_cnt = 0,
    stat = alterlist(reply->providers[ep_cnt].measures,100)
   DETAIL
    measure_cnt = (measure_cnt+ 1), m_temp_cnt = (m_temp_cnt+ 1)
    IF (m_temp_cnt > 100)
     m_temp_cnt = 1, stat = alterlist(reply->providers[ep_cnt].measures,(measure_cnt+ 100))
    ENDIF
    reply->providers[ep_cnt].measures[measure_cnt].meas_provider_reltn_id = m
    .br_pqrs_meas_provider_reltn_id, reply->providers[ep_cnt].measures[measure_cnt].measure_id = m
    .br_pqrs_meas_id, reply->providers[ep_cnt].measures[measure_cnt].display = ms.meas_display,
    reply->providers[ep_cnt].measures[measure_cnt].pilot_eligible_ind = m.pilot_eligible_ind
   FOOT  m.br_eligible_provider_id
    stat = alterlist(reply->providers[ep_cnt].measures,measure_cnt)
   FOOT REPORT
    stat = alterlist(reply->providers,ep_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error selecting PQRS measures for Eligible Providers.")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

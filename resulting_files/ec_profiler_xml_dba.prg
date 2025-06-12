CREATE PROGRAM ec_profiler_xml:dba
 PROMPT
  "Profiler Event ID: " = "0",
  "FTP Host: " = "",
  "FTP User: " = "",
  "FTP Password: " = ""
  WITH eventid, host, user,
  password
 RECORD rpt(
   1 client_mnemonic = vc
   1 environment_name = vc
   1 event_id = f8
   1 measurement_cnt = i2
   1 measurements[*]
     2 measurement_nbr = i2
     2 result_cnt = i2
     2 results[*]
       3 result_dt_tm = dq8
       3 facility = vc
       3 position = vc
       3 capability_in_use_ind = i2
       3 detail_cnt = i2
       3 details[*]
         4 detail_name = vc
         4 detail_value = vc
 )
 SET rpt->event_id = cnvtreal( $EVENTID)
 SELECT INTO "nl"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name IN ("CLIENT MNEMONIC", "DM_ENV_NAME")
  DETAIL
   IF (di.info_name="CLIENT MNEMONIC")
    rpt->client_mnemonic = di.info_char
   ELSEIF (di.info_name="DM_ENV_NAME")
    rpt->environment_name = di.info_char
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM ec_profiler_result epr,
   code_value cv1,
   code_value cv2,
   ec_measurement em,
   dummyt d,
   ec_profiler_result_detail eprd
  PLAN (epr
   WHERE (epr.ec_profiler_event_id=rpt->event_id))
   JOIN (cv1
   WHERE cv1.code_value=epr.facility_cd)
   JOIN (cv2
   WHERE cv2.code_value=epr.position_cd)
   JOIN (em
   WHERE em.ec_measurement_id=epr.ec_measurement_id)
   JOIN (d)
   JOIN (eprd
   WHERE eprd.ec_profiler_result_id=epr.ec_profiler_result_id)
  ORDER BY em.measurement_nbr, epr.ec_profiler_result_id, cv1.display,
   cv2.display
  HEAD em.measurement_nbr
   measurementcnt = (rpt->measurement_cnt+ 1), rpt->measurement_cnt = measurementcnt, stat =
   alterlist(rpt->measurements,measurementcnt),
   rpt->measurements[measurementcnt].measurement_nbr = em.measurement_nbr
  HEAD epr.ec_profiler_result_id
   resultcnt = (rpt->measurements[measurementcnt].result_cnt+ 1), rpt->measurements[measurementcnt].
   result_cnt = resultcnt, stat = alterlist(rpt->measurements[measurementcnt].results,resultcnt),
   rpt->measurements[measurementcnt].results[resultcnt].facility = cv1.display, rpt->measurements[
   measurementcnt].results[resultcnt].position = cv2.display, rpt->measurements[measurementcnt].
   results[resultcnt].result_dt_tm = epr.result_dt_tm,
   rpt->measurements[measurementcnt].results[resultcnt].capability_in_use_ind = epr
   .capability_in_use_ind
  DETAIL
   detailcnt = (rpt->measurements[measurementcnt].results[resultcnt].detail_cnt+ 1), rpt->
   measurements[measurementcnt].results[resultcnt].detail_cnt = detailcnt, stat = alterlist(rpt->
    measurements[measurementcnt].results[resultcnt].details,detailcnt),
   rpt->measurements[measurementcnt].results[resultcnt].details[detailcnt].detail_name = eprd
   .detail_name, rpt->measurements[measurementcnt].results[resultcnt].details[detailcnt].detail_value
    = eprd.detail_value_txt
  WITH outerjoin = d, nocounter
 ;end select
 DECLARE filename = vc WITH noconstant(""), protect
 SELECT INTO "nl"
  FROM ec_profiler_event epe
  WHERE (epe.ec_profiler_event_id=rpt->event_id)
  DETAIL
   filename = cnvtlower(build2("ec_profiler_",trim(rpt->client_mnemonic),"_",trim(rpt->
      environment_name),"_",
     trim(cnvtstring(rpt->event_id)),".xml"))
  WITH nocounter
 ;end select
 CALL echoxml(rpt,filename)
 FREE RECORD request
 RECORD request(
   1 shost = vc
   1 susername = vc
   1 spassword = vc
   1 sfile = vc
   1 sremotedir = vc
   1 sremotefilename = vc
   1 bdellocalfileind = i2
   1 bencryptfileind = i2
 )
 SET request->shost =  $HOST
 SET request->susername =  $USER
 SET request->spassword =  $PASSWORD
 SET request->sfile = filename
 EXECUTE pft_ftp
END GO

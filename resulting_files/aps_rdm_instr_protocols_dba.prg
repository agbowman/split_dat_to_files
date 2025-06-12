CREATE PROGRAM aps_rdm_instr_protocols:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE llistcnt = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE serrormsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE lerrorcode = i4 WITH public, noconstant(0)
 DECLARE lupdcnt = i4 WITH protect, noconstant(0)
 RECORD request(
   1 qual[*]
     2 instrument_protocol_id = f8
     2 instrument_type_cd = f8
     2 universal_service_ident = vc
     2 protocol_name = vc
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting aps_rdm_instr_protocols.prg script"
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM (dummyt d  WITH seq = llistcnt),
   code_value cv,
   instrument_protocol ip
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=2074
    AND (cv.cdf_meaning=requestin->list_0[d.seq].instrument_type_mean))
   JOIN (ip
   WHERE ip.protocol_name=outerjoin(requestin->list_0[d.seq].protocol_name)
    AND ip.instrument_type_cd=outerjoin(cv.code_value))
  DETAIL
   IF (ip.instrument_type_cd=0.0
    AND size(trim(ip.universal_service_ident),1)=0)
    lupdcnt = (lupdcnt+ 1)
    IF (mod(lupdcnt,10)=1)
     stat = alterlist(request->qual,(lupdcnt+ 9))
    ENDIF
    request->qual[lupdcnt].instrument_type_cd = cv.code_value, request->qual[lupdcnt].
    universal_service_ident = requestin->list_0[d.seq].universal_service_ident, request->qual[lupdcnt
    ].protocol_name = requestin->list_0[d.seq].protocol_name
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(request->qual,lupdcnt)
 IF (lupdcnt > 0)
  EXECUTE dm2_install_get_bulk_seq "request->qual", lupdcnt, "instrument_protocol_id",
  1, "pathnet_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   SET readme_data->message = concat("DM2_INSTALL_GET_BULK_SEQ Failed: ",m_dm2_seq_stat->s_error_msg)
   SET readme_data->status = "F"
   FREE SET m_dm2_seq_stat
   GO TO exit_script
  ENDIF
  FREE SET m_dm2_seq_stat
  INSERT  FROM (dummyt d  WITH seq = lupdcnt),
    instrument_protocol ip
   SET ip.instrument_protocol_id = request->qual[d.seq].instrument_protocol_id, ip.instrument_type_cd
     = request->qual[d.seq].instrument_type_cd, ip.universal_service_ident = request->qual[d.seq].
    universal_service_ident,
    ip.protocol_name = request->qual[d.seq].protocol_name, ip.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), ip.updt_id = reqinfo->updt_id,
    ip.updt_applctx = reqinfo->updt_applctx, ip.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ip)
   WITH nocounter
  ;end insert
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme successful: No Rows to update on instrument_protocol table"
  GO TO exit_script
 ENDIF
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode != 0)
  SET readme_data->message = concat("Failed during insert into instrument_protocol: ",serrormsg)
  SET readme_data->status = "F"
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
  SET readme_data->message = "Instrument Protocols were successfully updated."
  SET readme_data->status = "S"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

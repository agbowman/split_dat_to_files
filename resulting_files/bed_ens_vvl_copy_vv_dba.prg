CREATE PROGRAM bed_ens_vvl_copy_vv:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_syn
 RECORD temp_syn(
   1 syns[*]
     2 syn_id = f8
 )
 FREE SET temp_del_syn
 RECORD temp_del_syn(
   1 syns[*]
     2 syn_id = f8
     2 fac_code = f8
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET req_cnt = size(request->source_facilities,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO req_cnt)
  SET ct_size = size(request->source_facilities[x].copy_to,5)
  IF (ct_size > 0)
   SET tot_cnt = 0
   SELECT INTO "nl:"
    FROM order_catalog_synonym os,
     ocs_facility_r ofr
    PLAN (os
     WHERE os.catalog_type_cd=pharm_ct
      AND os.activity_type_cd=pharm_at
      AND ((os.mnemonic_type_cd+ 0) IN (primary_code_value, brand_code_value, dcp_code_value,
     c_code_value, e_code_value,
     m_code_value, n_code_value)))
     JOIN (ofr
     WHERE ofr.synonym_id=os.synonym_id
      AND (ofr.facility_cd=request->source_facilities[x].facility_code_value))
    HEAD REPORT
     cnt = 0, tot_cnt = 0, stat = alterlist(temp_syn->syns,100)
    DETAIL
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp_syn->syns,(tot_cnt+ 100)), cnt = 1
     ENDIF
     temp_syn->syns[tot_cnt].syn_id = os.synonym_id
    FOOT REPORT
     stat = alterlist(temp_syn->syns,tot_cnt)
    WITH nocounter
   ;end select
   SET dtot_cnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ct_size)),
     order_catalog_synonym os,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (os
     WHERE os.catalog_type_cd=pharm_ct
      AND os.activity_type_cd=pharm_at
      AND ((os.mnemonic_type_cd+ 0) IN (primary_code_value, brand_code_value, dcp_code_value,
     c_code_value, e_code_value,
     m_code_value, n_code_value)))
     JOIN (ofr
     WHERE ofr.synonym_id=os.synonym_id
      AND (ofr.facility_cd=request->source_facilities[x].copy_to[d.seq].facility_code_value))
    ORDER BY d.seq
    HEAD REPORT
     cnt = 0, dtot_cnt = 0, stat = alterlist(temp_del_syn->syns,100)
    DETAIL
     cnt = (cnt+ 1), dtot_cnt = (dtot_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp_del_syn->syns,(dtot_cnt+ 100)), cnt = 1
     ENDIF
     temp_del_syn->syns[dtot_cnt].syn_id = ofr.synonym_id, temp_del_syn->syns[dtot_cnt].fac_code =
     ofr.facility_cd
    FOOT REPORT
     stat = alterlist(temp_del_syn->syns,dtot_cnt)
    WITH nocounter
   ;end select
   IF (dtot_cnt > 0)
    SET ierrcode = 0
    DELETE  FROM ocs_facility_r ofr,
      (dummyt d  WITH seq = value(dtot_cnt))
     SET ofr.seq = 1
     PLAN (d)
      JOIN (ofr
      WHERE (ofr.synonym_id=temp_del_syn->syns[d.seq].syn_id)
       AND (ofr.facility_cd=temp_del_syn->syns[d.seq].fac_code))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (tot_cnt > ct_size)
    FOR (y = 1 TO ct_size)
      SET ierrcode = 0
      INSERT  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = value(tot_cnt))
       SET ofr.synonym_id = temp_syn->syns[d.seq].syn_id, ofr.facility_cd = request->
        source_facilities[x].copy_to[y].facility_code_value, ofr.updt_applctx = reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (ofr)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ELSE
    FOR (y = 1 TO tot_size)
      SET ierrcode = 0
      INSERT  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = value(ct_size))
       SET ofr.synonym_id = temp_syn->syns[y].syn_id, ofr.facility_cd = request->source_facilities[x]
        .copy_to[d.seq].facility_code_value, ofr.updt_applctx = reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (ofr)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO

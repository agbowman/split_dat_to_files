CREATE PROGRAM bed_copy_form_statuses:dba
 DECLARE writeerrormessage(message=vc) = null
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
 RECORD tempcopyfrom(
   1 copy_from[*]
     2 synonym_id = f8
     2 inpatient_code_value = f8
     2 outpatient_code_value = f8
     2 rx_synonym_visibility_ind = i2
 )
 RECORD tempcopyto(
   1 copy_to[*]
     2 facility_code_value = f8
     2 synonym_id = f8
     2 inpatient_code_value = f8
     2 outpatient_code_value = f8
     2 rx_synonym_visibility_ind = i2
 )
 DECLARE rx_syn_vsby_ind_col_exist = i2 WITH protect, noconstant(0)
 SET rx_syn_vsby_ind_col_exist = checkdic("OCS_FACILITY_FORMULARY_R.RX_SYNONYM_VISIBILITY_IND","A",0)
 DECLARE serrmsg = vc
 DECLARE ierrcode = i4
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE copy_to_cnt = i4
 SET copy_to_cnt = size(request->copy_to_facilities,5)
 IF (copy_to_cnt=0)
  SET stat = writeerrormessage("No copy to facilities defined")
  GO TO exit_script
 ENDIF
 IF ((request->copy_flag=0))
  DECLARE tot_row_cnt = i4
  DECLARE temp_cnt = i4
  SET tot_row_cnt = 0
  SET temp_cnt = 0
  SELECT INTO "nl:"
   FROM ocs_facility_formulary_r offr
   PLAN (offr
    WHERE (offr.facility_cd=request->copy_from_facility)
     AND offr.synonym_id > 0)
   HEAD REPORT
    tot_row_cnt = 0, temp_cnt = 0, stat = alterlist(tempcopyfrom->copy_from,10)
   DETAIL
    tot_row_cnt = (tot_row_cnt+ 1), temp_cnt = (temp_cnt+ 1)
    IF (temp_cnt > 10)
     stat = alterlist(tempcopyfrom->copy_from,(tot_row_cnt+ 10)), temp_cnt = 1
    ENDIF
    tempcopyfrom->copy_from[tot_row_cnt].inpatient_code_value = offr.inpatient_formulary_status_cd,
    tempcopyfrom->copy_from[tot_row_cnt].outpatient_code_value = offr.outpatient_formulary_status_cd,
    tempcopyfrom->copy_from[tot_row_cnt].synonym_id = offr.synonym_id
    IF (rx_syn_vsby_ind_col_exist > 0)
     tempcopyfrom->copy_from[tot_row_cnt].rx_synonym_visibility_ind = validate(offr
      .rx_synonym_visibility_ind,0)
    ENDIF
   FOOT REPORT
    stat = alterlist(tempcopyfrom->copy_from,tot_row_cnt)
   WITH nocounter
  ;end select
  DELETE  FROM ocs_facility_formulary_r offr,
    (dummyt d  WITH seq = copy_to_cnt)
   SET offr.seq = 1
   PLAN (d
    WHERE (request->copy_to_facilities[d.seq].code_value > 0))
    JOIN (offr
    WHERE (offr.facility_cd=request->copy_to_facilities[d.seq].code_value)
     AND offr.synonym_id > 0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET stat = writeerrormessage("Error deleting from ocs_facility_formulary_r")
   GO TO exit_script
  ENDIF
  DECLARE cnt = i4
  SET cnt = 0
  FOR (i = 1 TO copy_to_cnt)
    FOR (j = 1 TO tot_row_cnt)
      SET cnt = (cnt+ 1)
      SET stat = alterlist(tempcopyto->copy_to,cnt)
      SET tempcopyto->copy_to[cnt].facility_code_value = request->copy_to_facilities[i].code_value
      SET tempcopyto->copy_to[cnt].inpatient_code_value = tempcopyfrom->copy_from[j].
      inpatient_code_value
      SET tempcopyto->copy_to[cnt].outpatient_code_value = tempcopyfrom->copy_from[j].
      outpatient_code_value
      SET tempcopyto->copy_to[cnt].synonym_id = tempcopyfrom->copy_from[j].synonym_id
      IF (rx_syn_vsby_ind_col_exist > 0)
       SET tempcopyto->copy_to[cnt].rx_synonym_visibility_ind = validate(tempcopyfrom->copy_from[j].
        rx_synonym_visibility_ind,0)
      ENDIF
    ENDFOR
  ENDFOR
  IF (cnt=0)
   GO TO exit_script
  ENDIF
  IF (rx_syn_vsby_ind_col_exist > 0)
   INSERT  FROM ocs_facility_formulary_r offr,
     (dummyt d  WITH seq = cnt)
    SET offr.facility_cd = tempcopyto->copy_to[d.seq].facility_code_value, offr
     .inpatient_formulary_status_cd = tempcopyto->copy_to[d.seq].inpatient_code_value, offr
     .ocs_facility_formulary_r_id = seq(reference_seq,nextval),
     offr.outpatient_formulary_status_cd = tempcopyto->copy_to[d.seq].outpatient_code_value, offr
     .synonym_id = tempcopyto->copy_to[d.seq].synonym_id, offr.rx_synonym_visibility_ind = validate(
      tempcopyto->copy_to[d.seq].rx_synonym_visibility_ind,0),
     offr.updt_applctx = reqinfo->updt_applctx, offr.updt_cnt = 0, offr.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     offr.updt_id = reqinfo->updt_id, offr.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (offr)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM ocs_facility_formulary_r offr,
     (dummyt d  WITH seq = cnt)
    SET offr.facility_cd = tempcopyto->copy_to[d.seq].facility_code_value, offr
     .inpatient_formulary_status_cd = tempcopyto->copy_to[d.seq].inpatient_code_value, offr
     .ocs_facility_formulary_r_id = seq(reference_seq,nextval),
     offr.outpatient_formulary_status_cd = tempcopyto->copy_to[d.seq].outpatient_code_value, offr
     .synonym_id = tempcopyto->copy_to[d.seq].synonym_id, offr.updt_applctx = reqinfo->updt_applctx,
     offr.updt_cnt = 0, offr.updt_dt_tm = cnvtdatetime(curdate,curtime3), offr.updt_id = reqinfo->
     updt_id,
     offr.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (offr)
    WITH nocounter
   ;end insert
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET stat = writeerrormessage("Error inserting into ocs_facility_formulary_r")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->copy_flag=1))
  UPDATE  FROM ocs_facility_formulary_r ocsffr,
    (dummyt d  WITH seq = copy_to_cnt)
   SET ocsffr.outpatient_formulary_status_cd = ocsffr.inpatient_formulary_status_cd, ocsffr
    .updt_applctx = reqinfo->updt_applctx, ocsffr.updt_cnt = (ocsffr.updt_cnt+ 1),
    ocsffr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocsffr.updt_id = reqinfo->updt_id, ocsffr
    .updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ocsffr
    WHERE (ocsffr.facility_cd=request->copy_to_facilities[d.seq].code_value)
     AND ocsffr.synonym_id > 0)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET stat = writeerrormessage("Error updating ocs_facility_formulary_r")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->copy_flag=2))
  UPDATE  FROM ocs_facility_formulary_r ocsffr,
    (dummyt d  WITH seq = copy_to_cnt)
   SET ocsffr.inpatient_formulary_status_cd = ocsffr.outpatient_formulary_status_cd, ocsffr
    .updt_applctx = reqinfo->updt_applctx, ocsffr.updt_cnt = (ocsffr.updt_cnt+ 1),
    ocsffr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocsffr.updt_id = reqinfo->updt_id, ocsffr
    .updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ocsffr
    WHERE (ocsffr.facility_cd=request->copy_to_facilities[d.seq].code_value)
     AND ocsffr.synonym_id > 0)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET stat = writeerrormessage("Error updating ocs_facility_formulary_r")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE writeerrormessage(message)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(message)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 END ;Subroutine
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

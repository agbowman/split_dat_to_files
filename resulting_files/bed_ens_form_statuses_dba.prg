CREATE PROGRAM bed_ens_form_statuses:dba
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
 FREE SET tempadd
 RECORD tempadd(
   1 temp[*]
     2 synonym_id = f8
     2 facility_code_value = f8
     2 inpatient_code_value = f8
     2 outpatient_code_value = f8
     2 rx_synonym_visibility_ind = i2
 )
 FREE SET tempmodify
 RECORD tempmodify(
   1 temp[*]
     2 synonym_id = f8
     2 facility_code_value = f8
     2 inpatient_code_value = f8
     2 outpatient_code_value = f8
     2 rx_synonym_visibility_ind = i2
 )
 FREE SET tempdelete
 RECORD tempdelete(
   1 temp[*]
     2 synonym_id = f8
     2 facility_code_value = f8
 )
 DECLARE error_flag = vc
 DECLARE serrmsg = vc
 DECLARE ierrcode = i4
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE syncount = i4
 SET syncount = size(request->synonyms,5)
 IF (syncount=0)
  SET stat = writeerrormessage("No synonyms to ensure")
  GO TO exit_script
 ENDIF
 DECLARE addcount = i4
 DECLARE modcount = i4
 DECLARE delcount = i4
 SET addcount = 0
 SET modcount = 0
 SET delcount = 0
 DECLARE rx_syn_vsby_ind_col_exist = i2 WITH protect, noconstant(0)
 SET rx_syn_vsby_ind_col_exist = checkdic("OCS_FACILITY_FORMULARY_R.RX_SYNONYM_VISIBILITY_IND","A",0)
 FOR (i = 1 TO syncount)
   DECLARE faccount = i4
   SET faccount = size(request->synonyms[i].facilities,5)
   FOR (j = 1 TO faccount)
     IF ((request->synonyms[i].facilities[j].action_flag=1))
      SET addcount = (addcount+ 1)
      SET stat = alterlist(tempadd->temp,addcount)
      SET tempadd->temp[addcount].synonym_id = request->synonyms[i].synonym_id
      SET tempadd->temp[addcount].facility_code_value = request->synonyms[i].facilities[j].
      facility_code_value
      SET tempadd->temp[addcount].inpatient_code_value = request->synonyms[i].facilities[j].
      inpatient_code_value
      SET tempadd->temp[addcount].outpatient_code_value = request->synonyms[i].facilities[j].
      outpatient_code_value
      SET stat = assign(validate(tempadd->temp[addcount].rx_synonym_visibility_ind),validate(request
        ->synonyms[i].facilities[j].rx_synonym_visibility_ind,0))
     ELSEIF ((request->synonyms[i].facilities[j].action_flag=2))
      SET modcount = (modcount+ 1)
      SET stat = alterlist(tempmodify->temp,modcount)
      SET tempmodify->temp[modcount].synonym_id = request->synonyms[i].synonym_id
      SET tempmodify->temp[modcount].facility_code_value = request->synonyms[i].facilities[j].
      facility_code_value
      SET tempmodify->temp[modcount].inpatient_code_value = request->synonyms[i].facilities[j].
      inpatient_code_value
      SET tempmodify->temp[modcount].outpatient_code_value = request->synonyms[i].facilities[j].
      outpatient_code_value
      SET stat = assign(validate(tempmodify->temp[modcount].rx_synonym_visibility_ind),validate(
        request->synonyms[i].facilities[j].rx_synonym_visibility_ind,0))
     ELSEIF ((request->synonyms[i].facilities[j].action_flag=3))
      SET delcount = (delcount+ 1)
      SET stat = alterlist(tempdelete->temp,delcount)
      SET tempdelete->temp[delcount].synonym_id = request->synonyms[i].synonym_id
      SET tempdelete->temp[delcount].facility_code_value = request->synonyms[i].facilities[j].
      facility_code_value
     ENDIF
   ENDFOR
 ENDFOR
 IF (addcount > 0)
  IF (rx_syn_vsby_ind_col_exist > 0)
   INSERT  FROM ocs_facility_formulary_r ocsffr,
     (dummyt d  WITH seq = addcount)
    SET ocsffr.facility_cd = tempadd->temp[d.seq].facility_code_value, ocsffr
     .inpatient_formulary_status_cd = tempadd->temp[d.seq].inpatient_code_value, ocsffr
     .ocs_facility_formulary_r_id = seq(reference_seq,nextval),
     ocsffr.outpatient_formulary_status_cd = tempadd->temp[d.seq].outpatient_code_value, ocsffr
     .synonym_id = tempadd->temp[d.seq].synonym_id, ocsffr.rx_synonym_visibility_ind = validate(
      tempadd->temp[d.seq].rx_synonym_visibility_ind,0),
     ocsffr.updt_applctx = reqinfo->updt_applctx, ocsffr.updt_cnt = 0, ocsffr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ocsffr.updt_id = reqinfo->updt_id, ocsffr.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (ocsffr)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET stat = writeerrormessage("Error inserting into ocs_facility_formulary_r")
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM ocs_facility_formulary_r ocsffr,
     (dummyt d  WITH seq = addcount)
    SET ocsffr.facility_cd = tempadd->temp[d.seq].facility_code_value, ocsffr
     .inpatient_formulary_status_cd = tempadd->temp[d.seq].inpatient_code_value, ocsffr
     .ocs_facility_formulary_r_id = seq(reference_seq,nextval),
     ocsffr.outpatient_formulary_status_cd = tempadd->temp[d.seq].outpatient_code_value, ocsffr
     .synonym_id = tempadd->temp[d.seq].synonym_id, ocsffr.updt_applctx = reqinfo->updt_applctx,
     ocsffr.updt_cnt = 0, ocsffr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocsffr.updt_id =
     reqinfo->updt_id,
     ocsffr.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (ocsffr)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET stat = writeerrormessage("Error inserting into ocs_facility_formulary_r")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (modcount > 0)
  IF (rx_syn_vsby_ind_col_exist > 0)
   UPDATE  FROM ocs_facility_formulary_r ocsffr,
     (dummyt d  WITH seq = modcount)
    SET ocsffr.inpatient_formulary_status_cd = tempmodify->temp[d.seq].inpatient_code_value, ocsffr
     .outpatient_formulary_status_cd = tempmodify->temp[d.seq].outpatient_code_value, ocsffr
     .rx_synonym_visibility_ind = validate(tempmodify->temp[d.seq].rx_synonym_visibility_ind,0),
     ocsffr.updt_applctx = reqinfo->updt_applctx, ocsffr.updt_cnt = (ocsffr.updt_cnt+ 1), ocsffr
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ocsffr.updt_id = reqinfo->updt_id, ocsffr.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (ocsffr
     WHERE (ocsffr.facility_cd=tempmodify->temp[d.seq].facility_code_value)
      AND (ocsffr.synonym_id=tempmodify->temp[d.seq].synonym_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET stat = writeerrormessage("Error updating ocs_facility_formulary_r")
    GO TO exit_script
   ENDIF
  ELSE
   UPDATE  FROM ocs_facility_formulary_r ocsffr,
     (dummyt d  WITH seq = modcount)
    SET ocsffr.inpatient_formulary_status_cd = tempmodify->temp[d.seq].inpatient_code_value, ocsffr
     .outpatient_formulary_status_cd = tempmodify->temp[d.seq].outpatient_code_value, ocsffr
     .updt_applctx = reqinfo->updt_applctx,
     ocsffr.updt_cnt = (ocsffr.updt_cnt+ 1), ocsffr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ocsffr.updt_id = reqinfo->updt_id,
     ocsffr.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (ocsffr
     WHERE (ocsffr.facility_cd=tempmodify->temp[d.seq].facility_code_value)
      AND (ocsffr.synonym_id=tempmodify->temp[d.seq].synonym_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET stat = writeerrormessage("Error updating ocs_facility_formulary_r")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (delcount > 0)
  DELETE  FROM ocs_facility_formulary_r ocsffr,
    (dummyt d  WITH seq = delcount)
   SET ocsffr.seq = 1
   PLAN (d)
    JOIN (ocsffr
    WHERE (ocsffr.facility_cd=tempdelete->temp[d.seq].facility_code_value)
     AND (ocsffr.synonym_id=tempdelete->temp[d.seq].synonym_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET stat = writeerrormessage("Error deleting from ocs_facility_formulary_r")
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
  IF (rx_syn_vsby_ind_col_exist=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "bed_ens_form_statuses"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "RX_SYNONYM_VISIBILITY_IND column of OCS_FACILITY_FORMULARY table doesn't exist."
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO

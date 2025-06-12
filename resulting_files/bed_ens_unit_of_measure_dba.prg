CREATE PROGRAM bed_ens_unit_of_measure:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE SET reply
 RECORD reply(
   1 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET strength = 1
 SET volume = 2
 SET quantity = 4
 SET duration = 8
 SET rate = 16
 SET normalized = 32
 SET document_dose_rate = 64
 SET field_value = 0.0
 IF ((request->strength_ind=1))
  SET field_value = (field_value+ strength)
 ENDIF
 IF ((request->volume_ind=1))
  SET field_value = (field_value+ volume)
 ENDIF
 IF ((request->rate_ind=1))
  SET field_value = (field_value+ rate)
 ENDIF
 IF ((request->document_dose_rate_ind=1))
  SET field_value = (field_value+ document_dose_rate)
 ENDIF
 IF ((request->quantity_ind=1))
  SET field_value = (field_value+ quantity)
 ENDIF
 IF ((request->duration_ind=1))
  SET field_value = (field_value+ duration)
 ENDIF
 IF ((request->normalized_ind=1))
  SET field_value = (field_value+ normalized)
 ENDIF
 SET request_cv->cd_value_list[1].action_flag = 1
 SET request_cv->cd_value_list[1].code_set = 54
 SET request_cv->cd_value_list[1].cki = request->cki
 SET request_cv->cd_value_list[1].cdf_meaning = ""
 SET request_cv->cd_value_list[1].concept_cki = " "
 SET request_cv->cd_value_list[1].display = substring(1,40,request->display)
 SET request_cv->cd_value_list[1].description = substring(1,60,request->description)
 SET request_cv->cd_value_list[1].definition = request->description
 SET request_cv->cd_value_list[1].active_ind = 1
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET reply->code_value = reply_cv->qual[1].code_value
 ELSE
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert ",trim(request->display)," into codeset 54.")
  GO TO exit_script
 ENDIF
 INSERT  FROM code_value_extension c
  SET c.code_value = reply->code_value, c.code_set = 54, c.field_name = "PHARM_UNIT",
   c.field_type = 1.00, c.field_value = cnvtstring(field_value), c.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
   c.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert: ",trim(request->display),
   " into the code_value_extension table.")
  GO TO exit_script
 ENDIF
 IF ((request->cki > " "))
  DELETE  FROM br_name_value b
   WHERE b.br_nv_key1="MLTM_IGN_UNITS"
    AND (b.br_value=request->cki)
    AND b.br_name="MLTM_DRC_PREMISE"
   WITH nocounter
  ;end delete
 ENDIF
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

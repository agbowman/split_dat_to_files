CREATE PROGRAM bed_ens_res_sch_resource:dba
 FREE SET request_cv
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
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET req_size = size(request->resources,5)
 FOR (x = 1 TO req_size)
   IF ((request->resources[x].action_flag=2))
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_value = request->resources[x].sch_resource_code_value
    SET request_cv->cd_value_list[1].code_set = 14231
    SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->resources[x].mnemonic))
    SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->resources[x].mnemonic
      ))
    SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->resources[x].mnemonic
      ))
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="F"))
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert ",trim(request->resources[x].mnemonic),
      " into codeset 14231.")
     GO TO exit_script
    ENDIF
    UPDATE  FROM sch_resource s
     SET s.mnemonic = trim(substring(1,100,request->resources[x].mnemonic)), s.mnemonic_key = trim(
       cnvtupper(substring(1,100,request->resources[x].mnemonic))), s.description = trim(substring(1,
        200,request->resources[x].mnemonic)),
      s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
      reqinfo->updt_task,
      s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
     WHERE (s.resource_cd=request->resources[x].sch_resource_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to create scheduling resource for: ",trim(request->
       resources[x].mnemonic)," on sch_resource.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
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

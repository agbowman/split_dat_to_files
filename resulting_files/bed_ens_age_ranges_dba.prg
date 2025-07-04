CREATE PROGRAM bed_ens_age_ranges:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET acnt = size(request->age_ranges,5)
 FOR (a = 1 TO acnt)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 4000048
   SET request_cv->cd_value_list[1].code_value = request->age_ranges[a].code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,request->age_ranges[a].display)
   SET request_cv->cd_value_list[1].cdf_meaning = substring(1,12,request->age_ranges[a].mean)
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update ",trim(request->age_ranges[a].display),
     " into codeset 4000048.")
    GO TO exit_script
   ENDIF
   SELECT INTO "NL:"
    FROM code_value_extension cve
    WHERE (cve.code_value=request->age_ranges[a].code_value)
     AND cve.code_set=4000048
     AND cve.field_name="Upper Range"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM code_value_extension cve
     SET cve.code_value = request->age_ranges[a].code_value, cve.code_set = 4000048, cve.field_name
       = "Upper Range",
      cve.field_type = 1, cve.field_value = request->age_ranges[a].ext_field_value, cve.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_cnt = 0,
      cve.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert: ",trim(request->age_ranges[a].display),
      " into the code_value_extension table.")
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM code_value_extension cve
     SET cve.field_value = request->age_ranges[a].ext_field_value, cve.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), cve.updt_id = reqinfo->updt_id,
      cve.updt_task = reqinfo->updt_task, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_applctx =
      reqinfo->updt_applctx
     WHERE (cve.code_value=request->age_ranges[a].code_value)
      AND cve.code_set=4000048
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update: ",trim(request->age_ranges[a].display),
      " into the code_value_extension table.")
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

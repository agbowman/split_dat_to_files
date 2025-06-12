CREATE PROGRAM bed_ens_sch_resource:dba
 FREE SET reply
 RECORD reply(
   1 resources[*]
     2 resource_code_value = f8
     2 duplicate_ind = i2
     2 res_type_flag = i2
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET 14231_cd = 0.0
 DECLARE active = f8 WITH public, noconstant(0.0)
 DECLARE inactive = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE")
  DETAIL
   inactive = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(request->resources,5))
  SET stat = alterlist(reply->resources,x)
  IF ((request->resources[x].action_flag=1))
   SELECT INTO "nl:"
    FROM sch_resource sr
    PLAN (sr
     WHERE sr.mnemonic_key=cnvtupper(request->resources[x].mnemonic))
    DETAIL
     reply->resources[x].resource_code_value = sr.resource_cd, reply->resources[x].duplicate_ind = 1,
     reply->resources[x].res_type_flag = sr.res_type_flag
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 14231
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].display = request->resources[x].mnemonic
    SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->resources[x].
      mnemonic))
    SET request_cv->cd_value_list[1].description = request->resources[x].mnemonic
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET 14231_cd = reply_cv->qual[1].code_value
    ELSE
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET candidate_id = 0.0
    SELECT INTO "nl:"
     y = seq(sch_candidate_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      candidate_id = cnvtreal(y)
     WITH format, counter
    ;end select
    SET ierrcode = 0
    INSERT  FROM sch_resource sr
     SET sr.resource_cd = 14231_cd, sr.person_id = request->resources[x].person_id, sr.res_type_flag
       = 2,
      sr.mnemonic = request->resources[x].mnemonic, sr.mnemonic_key = cnvtupper(request->resources[x]
       .mnemonic), sr.description = request->resources[x].mnemonic,
      sr.version_dt_tm = cnvtdatetime("31-DEC-2100"), sr.null_dt_tm = cnvtdatetime("31-DEC-2100"), sr
      .info_sch_text_id = 0,
      sr.service_resource_cd = 0, sr.candidate_id = candidate_id, sr.active_ind = 1,
      sr.active_status_cd = active, sr.active_status_dt_tm = cnvtdatetime(curdate,curtime), sr
      .active_status_prsnl_id = reqinfo->updt_id,
      sr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), sr.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), sr.updt_dt_tm = cnvtdatetime(curdate,curtime),
      sr.updt_id = reqinfo->updt_id, sr.updt_cnt = 0, sr.updt_task = reqinfo->updt_task,
      sr.updt_applctx = reqinfo->updt_applctx, sr.mnemonic_key_nls = null, sr.item_id = 0,
      sr.item_location_cd = 0, sr.quota = request->resources[x].booking_limit
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ELSE
     SET reply->resources[x].resource_code_value = 14231_cd
    ENDIF
   ENDIF
  ELSEIF ((request->resources[x].action_flag=2))
   SET 14231_cd = request->resources[x].code_value
   SET ierrcode = 0
   UPDATE  FROM sch_resource sr
    SET sr.person_id = request->resources[x].person_id, sr.res_type_flag = 2, sr.beg_effective_dt_tm
      = cnvtdatetime(curdate,curtime3),
     sr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), sr.active_status_prsnl_id = reqinfo->
     updt_id, sr.active_ind = 1,
     sr.active_status_cd = active, sr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sr
     .updt_id = reqinfo->updt_id,
     sr.updt_cnt = (sr.updt_cnt+ 1), sr.updt_dt_tm = cnvtdatetime(curdate,curtime3), sr.updt_task =
     reqinfo->updt_task,
     sr.updt_applctx = reqinfo->updt_applctx, sr.quota = request->resources[x].booking_limit
    PLAN (sr
     WHERE (sr.resource_cd=request->resources[x].code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ELSE
    SET reply->resources[x].resource_code_value = 14231_cd
   ENDIF
  ELSEIF ((request->resources[x].action_flag=3))
   SET 14231_cd = request->resources[x].code_value
   SET ierrcode = 0
   UPDATE  FROM sch_resource sr
    SET sr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sr.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime3), sr.active_status_prsnl_id = reqinfo->updt_id,
     sr.active_ind = 0, sr.active_status_cd = inactive, sr.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     sr.updt_id = reqinfo->updt_id, sr.updt_cnt = (sr.updt_cnt+ 1), sr.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     sr.updt_task = reqinfo->updt_task, sr.updt_applctx = reqinfo->updt_applctx
    PLAN (sr
     WHERE (sr.resource_cd=request->resources[x].code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ELSE
    SET reply->resources[x].resource_code_value = 14231_cd
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

CREATE PROGRAM bed_ens_cs_prof_tech_tier:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET tech_cd = 0.0
 DECLARE tech_tier = vc
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=13031
    AND cv.cdf_meaning="TIERGROUP"
    AND cv.active_ind=1)
  ORDER BY cv.code_value DESC
  DETAIL
   tech_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE active = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active = cv.code_value
  WITH nocounter
 ;end select
 SET ocnt = size(request->organizations,5)
 FOR (x = 1 TO ocnt)
   SET 13035_tech_cd = 0.0
   SET prefix_found = 0
   SET tech_found = 0
   SELECT INTO "nl:"
    FROM br_organization b
    PLAN (b
     WHERE (b.organization_id=request->organizations[x].id))
    DETAIL
     prefix_found = 1
    WITH nocounter
   ;end select
   IF (prefix_found=0)
    SET ierrcode = 0
    INSERT  FROM br_organization b
     SET b.organization_id = request->organizations[x].id, b.br_prefix = request->organizations[x].
      prefix, b.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM bill_org_payor b
    PLAN (b
     WHERE (b.organization_id=request->organizations[x].id)
      AND b.bill_org_type_cd=tech_cd
      AND b.active_ind=1)
    DETAIL
     tech_found = 1
    WITH nocounter
   ;end select
   IF (tech_found=0)
    SET tech_tier = concat(request->organizations[x].prefix," Technical Tier")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].active_ind = 1
    SET request_cv->cd_value_list[1].code_set = 13035
    SET request_cv->cd_value_list[1].display = tech_tier
    SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(tech_tier))
    SET request_cv->cd_value_list[1].description = "Tier Group added by Tier Maint"
    SET request_cv->cd_value_list[1].definition = tech_tier
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=13035
       AND (cv.display_key=request_cv->cd_value_list[1].display_key))
     DETAIL
      13035_tech_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (13035_tech_cd=0)
     SET trace = recpersist
     EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
     IF ((reply_cv->status_data.status="S")
      AND (reply_cv->qual[1].code_value > 0))
      SET 13035_tech_cd = reply_cv->qual[1].code_value
     ELSE
      SET failed = "Y"
      SET reply->error_msg = "Failed to insert code value on code set 13035"
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = 0
    INSERT  FROM bill_org_payor b
     SET b.org_payor_id = seq(price_sched_seq,nextval), b.organization_id = request->organizations[x]
      .id, b.bill_org_type_cd = tech_cd,
      b.bill_org_type_id = 13035_tech_cd, b.priority = 0, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = active,
      b.active_status_dt_tm = cnvtdatetime(curdate,curtime), b.active_status_prsnl_id = reqinfo->
      updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
      b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.tier_group_cd = 0, b.interface_file_cd
       = 0,
      b.parent_entity_name = "CODE_VALUE", b.bill_org_type_string = null, b.bill_org_type_ind = 0
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
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

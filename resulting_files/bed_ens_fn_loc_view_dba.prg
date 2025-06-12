CREATE PROGRAM bed_ens_fn_loc_view:dba
 FREE SET reply
 RECORD reply(
   1 view_code_value = f8
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
 SET 220_cd = 0.0
 DECLARE pttrackroot = f8 WITH public, noconstant(0.0)
 DECLARE active = f8 WITH public, noconstant(0.0)
 DECLARE inactive = f8 WITH public, noconstant(0.0)
 DECLARE auth = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="PTTRACKROOT")
  DETAIL
   pttrackroot = cv.code_value
  WITH nocounter
 ;end select
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
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH")
  DETAIL
   auth = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].active_ind = 1
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].active_ind = 1
  SET request_cv->cd_value_list[1].code_value = request->view_code_value
 ELSEIF ((request->action_flag=3))
  SET request_cv->cd_value_list[1].action_flag = 3
  SET request_cv->cd_value_list[1].active_ind = 0
  SET request_cv->cd_value_list[1].code_value = request->view_code_value
 ENDIF
 SET request_cv->cd_value_list[1].code_set = 220
 SET request_cv->cd_value_list[1].cdf_meaning = "PTTRACKROOT"
 SET request_cv->cd_value_list[1].display = request->view_display
 SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->view_display))
 SET request_cv->cd_value_list[1].description = request->view_description
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET 220_cd = reply_cv->qual[1].code_value
 ELSE
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  SET ierrcode = 0
  INSERT  FROM location l
   SET l.location_cd = 220_cd, l.location_type_cd = pttrackroot, l.organization_id = 0,
    l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = active,
    l.active_status_dt_tm = cnvtdatetime(curdate,curtime), l.active_status_prsnl_id = reqinfo->
    updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
    l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), l.census_ind = 0, l.contributor_system_cd =
    0,
    l.data_status_cd = auth, l.data_status_dt_tm = cnvtdatetime(curdate,curtime), l
    .data_status_prsnl_id = reqinfo->updt_id,
    l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_cnt = 0,
    l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l
    .facility_accn_prefix_cd = 0,
    l.discipline_type_cd = 0, l.view_type_cd = 0, l.exp_lvl_cd = 0,
    l.chart_format_id = 0, l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0,
    l.registration_ind = null, l.contributor_source_cd = 0, l.ref_lab_acct_nbr = "",
    l.icu_ind = null, l.reserve_ind = 0
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=3))
  SET ierrcode = 0
  UPDATE  FROM location l
   SET l.active_ind = 0, l.active_status_cd = inactive, l.active_status_dt_tm = cnvtdatetime(curdate,
     curtime),
    l.active_status_prsnl_id = reqinfo->updt_id, l.end_effective_dt_tm = cnvtdatetime(curdate,curtime
     ), l.updt_dt_tm = cnvtdatetime(curdate,curtime),
    l.updt_id = reqinfo->updt_id, l.updt_cnt = 0, l.updt_task = reqinfo->updt_task,
    l.updt_applctx = reqinfo->updt_applctx
   PLAN (l
    WHERE l.location_cd=220_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reply->view_code_value = 220_cd
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

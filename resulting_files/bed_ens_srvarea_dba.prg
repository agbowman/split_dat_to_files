CREATE PROGRAM bed_ens_srvarea:dba
 FREE SET reply
 RECORD reply(
   1 srvarea_code_value = f8
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
 DECLARE srvarea = f8 WITH public, noconstant(0.0)
 DECLARE discipline = f8 WITH public, noconstant(0.0)
 DECLARE active = f8 WITH public, noconstant(0.0)
 DECLARE inactive = f8 WITH public, noconstant(0.0)
 DECLARE auth = f8 WITH public, noconstant(0.0)
 SET discipline = request->discipline_type_code_value
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="SRVAREA")
  DETAIL
   srvarea = cv.code_value
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
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="SRVAREA"
     AND cnvtupper(cv.display)=cnvtupper(request->srvarea.disp)
     AND cv.active_ind=0)
   DETAIL
    220_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=1)
   UPDATE  FROM code_value cv
    SET cv.active_ind = 1, cv.active_type_cd = active, cv.active_dt_tm = cnvtdatetime(curdate,curtime
      ),
     cv.inactive_dt_tm = null, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime), cv
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id =
     reqinfo->updt_id,
     cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx
    PLAN (cv
     WHERE cv.code_value=220_cd)
    WITH nocounter
   ;end update
   SET ierrcode = 0
   UPDATE  FROM location l
    SET l.organization_id = request->organization_id, l.resource_ind = 0, l.active_ind = 1,
     l.active_status_cd = active, l.active_status_dt_tm = cnvtdatetime(curdate,curtime), l
     .active_status_prsnl_id = reqinfo->updt_id,
     l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), l.updt_dt_tm = cnvtdatetime(curdate,curtime
      ), l.updt_id = reqinfo->updt_id,
     l.updt_cnt = (l.updt_cnt+ 1), l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
     updt_applctx,
     l.census_ind = 0, l.contributor_system_cd = 0, l.facility_accn_prefix_cd = 0,
     l.discipline_type_cd = discipline, l.view_type_cd = 0, l.exp_lvl_cd = 0,
     l.chart_format_id = 0, l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0,
     l.registration_ind = null, l.contributor_source_cd = 0, l.ref_lab_acct_nbr = "",
     l.icu_ind = null, l.reserve_ind = 0
    PLAN (l
     WHERE l.location_cd=220_cd)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
  ELSE
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].cdf_meaning = "SRVAREA"
   SET request_cv->cd_value_list[1].display = request->srvarea.disp
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->srvarea.disp))
   SET request_cv->cd_value_list[1].description = request->srvarea.disp
   SET request_cv->cd_value_list[1].definition = request->srvarea.disp
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET 220_cd = reply_cv->qual[1].code_value
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   INSERT  FROM location l
    SET l.location_cd = 220_cd, l.location_type_cd = srvarea, l.organization_id = request->
     organization_id,
     l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = active,
     l.active_status_dt_tm = cnvtdatetime(curdate,curtime), l.active_status_prsnl_id = reqinfo->
     updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
     l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), l.census_ind = 0, l.contributor_system_cd
      = 0,
     l.data_status_cd = auth, l.data_status_dt_tm = cnvtdatetime(curdate,curtime), l
     .data_status_prsnl_id = reqinfo->updt_id,
     l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_cnt = 0,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l
     .facility_accn_prefix_cd = 0,
     l.discipline_type_cd = discipline, l.view_type_cd = 0, l.exp_lvl_cd = 0,
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
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].code_value = request->srvarea.code_value
  SET request_cv->cd_value_list[1].code_set = 220
  SET request_cv->cd_value_list[1].cdf_meaning = "SRVAREA"
  SET request_cv->cd_value_list[1].display = request->srvarea.disp
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->srvarea.disp))
  SET request_cv->cd_value_list[1].description = request->srvarea.disp
  SET request_cv->cd_value_list[1].definition = request->srvarea.disp
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 220_cd = reply_cv->qual[1].code_value
  ELSE
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET upd_loc = 0
  SELECT INTO "nl:"
   FROM location l
   PLAN (l
    WHERE (l.location_cd=request->srvarea.code_value)
     AND (l.organization_id != request->organization_id))
   DETAIL
    upd_loc = 1
   WITH nocounter
  ;end select
  IF (upd_loc=1)
   SET ierrcode = 0
   UPDATE  FROM location l
    SET l.organization_id = request->organization_id, l.resource_ind = 0, l.active_ind = 1,
     l.active_status_cd = active, l.active_status_dt_tm = cnvtdatetime(curdate,curtime), l
     .active_status_prsnl_id = reqinfo->updt_id,
     l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), l.census_ind = 0, l.contributor_system_cd
      = 0,
     l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_cnt = (l
     .updt_cnt+ 1),
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l
     .facility_accn_prefix_cd = 0,
     l.discipline_type_cd = discipline, l.view_type_cd = 0, l.exp_lvl_cd = 0,
     l.chart_format_id = 0, l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0,
     l.registration_ind = null, l.contributor_source_cd = 0, l.ref_lab_acct_nbr = "",
     l.icu_ind = null, l.reserve_ind = 0
    PLAN (l
     WHERE (l.location_cd=request->srvarea.code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
  ENDIF
 ELSEIF ((request->action_flag=3))
  SET request_cv->cd_value_list[1].action_flag = 3
  SET request_cv->cd_value_list[1].code_value = request->srvarea.code_value
  SET request_cv->cd_value_list[1].code_set = 220
  SET request_cv->cd_value_list[1].cdf_meaning = "SRVAREA"
  SET request_cv->cd_value_list[1].display = request->srvarea.disp
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->srvarea.disp))
  SET request_cv->cd_value_list[1].description = request->srvarea.disp
  SET request_cv->cd_value_list[1].definition = request->srvarea.disp
  SET request_cv->cd_value_list[1].active_ind = 0
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 220_cd = reply_cv->qual[1].code_value
  ELSE
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM location l
   SET l.active_ind = 0, l.active_status_cd = inactive, l.active_status_dt_tm = cnvtdatetime(curdate,
     curtime),
    l.active_status_prsnl_id = reqinfo->updt_id, l.end_effective_dt_tm = cnvtdatetime(curdate,curtime
     ), l.updt_dt_tm = cnvtdatetime(curdate,curtime),
    l.updt_id = reqinfo->updt_id, l.updt_cnt = (l.updt_cnt+ 1), l.updt_task = reqinfo->updt_task,
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
  SET ierrcode = 0
  UPDATE  FROM location_group lg
   SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm = cnvtdatetime
    (curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
    lg.active_ind = 0, lg.active_status_cd = inactive, lg.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3),
    lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
   PLAN (lg
    WHERE (lg.parent_loc_cd=request->srvarea.code_value))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  FREE SET temp
  RECORD temp(
    1 rqual[*]
      2 resource_cd = f8
      2 cqual[*]
        3 calendar = vc
        3 aqual[*]
          4 area_cd = f8
  )
  SET rcnt = 0
  SET ccnt = 0
  SET acnt = 0
  SELECT INTO "nl:"
   FROM loc_resource_calendar l
   PLAN (l
    WHERE (l.location_cd=request->srvarea.code_value))
   ORDER BY l.service_resource_cd
   HEAD l.service_resource_cd
    ccnt = 0, acnt = 0, rcnt = (rcnt+ 1),
    stat = alterlist(temp->rqual,rcnt), temp->rqual[rcnt].resource_cd = l.service_resource_cd
   WITH nocounter
  ;end select
  IF (rcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(rcnt)),
     loc_resource_calendar l
    PLAN (d)
     JOIN (l
     WHERE (l.service_resource_cd=temp->rqual[d.seq].resource_cd))
    ORDER BY d.seq, l.description, l.location_cd
    HEAD d.seq
     ccnt = 0, acnt = 0
    HEAD l.description
     acnt = 0, ccnt = (ccnt+ 1), stat = alterlist(temp->rqual[d.seq].cqual,ccnt),
     temp->rqual[d.seq].cqual[ccnt].calendar = l.description
    HEAD l.location_cd
     acnt = (acnt+ 1), stat = alterlist(temp->rqual[d.seq].cqual[ccnt].aqual,acnt), temp->rqual[d.seq
     ].cqual[ccnt].aqual[acnt].area_cd = l.location_cd
    WITH nocounter
   ;end select
   FOR (x = 1 TO rcnt)
    SET ccnt = size(temp->rqual[x].cqual,5)
    IF (ccnt > 0)
     FOR (y = 1 TO ccnt)
       SET area_found = 0
       SET acnt = size(temp->rqual[x].cqual[y].aqual,5)
       FOR (z = 1 TO acnt)
         IF ((temp->rqual[x].cqual[y].aqual[z].area_cd=request->srvarea.code_value))
          SET area_found = 1
         ENDIF
       ENDFOR
       IF (acnt=1
        AND area_found=1)
        UPDATE  FROM loc_resource_calendar l
         SET l.location_cd = 0
         WHERE (l.service_resource_cd=temp->rqual[x].resource_cd)
          AND (l.location_cd=request->srvarea.code_value)
         WITH nocounter
        ;end update
        UPDATE  FROM loc_resource_r l
         SET l.location_cd = 0
         WHERE (l.service_resource_cd=temp->rqual[x].resource_cd)
          AND (l.location_cd=request->srvarea.code_value)
         WITH nocounter
        ;end update
       ELSEIF (acnt > 1
        AND area_found=1)
        DELETE  FROM loc_resource_calendar l
         WHERE (l.service_resource_cd=temp->rqual[x].resource_cd)
          AND (l.location_cd=request->srvarea.code_value)
         WITH nocounter
        ;end delete
        DELETE  FROM loc_resource_r l
         WHERE (l.service_resource_cd=temp->rqual[x].resource_cd)
          AND (l.location_cd=request->srvarea.code_value)
         WITH nocounter
        ;end delete
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reply->srvarea_code_value = 220_cd
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

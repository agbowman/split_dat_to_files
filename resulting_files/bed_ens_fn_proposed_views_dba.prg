CREATE PROGRAM bed_ens_fn_proposed_views:dba
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
 SET failed = "N"
 SET usa_ind = 0
 SET uk_ind = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
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
 SELECT INTO "nl:"
  FROM br_client b
  PLAN (b)
  DETAIL
   IF (b.region="USA")
    usa_ind = 1
   ELSEIF (b.region="UK")
    uk_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD trkview(
   1 qual[*]
     2 display = vc
     2 code_value = f8
 )
 DECLARE fn_prefix = vc
 SELECT INTO "nl:"
  FROM br_name_value b
  PLAN (b
   WHERE b.br_nv_key1="FNTRKGRP_PREFIX"
    AND b.br_name=cnvtstring(track_group_cd))
  DETAIL
   fn_prefix = b.br_value
  WITH nocounter
 ;end select
 IF (ed_code_value > 0)
  DECLARE ed_display = vc
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_value=ed_code_value
     AND cv.active_ind=1)
   DETAIL
    ed_display = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF (usa_ind=1)
  IF (ed_code_value > 0)
   SET stat = alterlist(trkview->qual,4)
   SET trkview->qual[1].display = concat(trim(fn_prefix)," ",trim(ed_display)," All Beds")
   SET trkview->qual[2].display = concat(trim(fn_prefix)," ",trim(ed_display)," All Beds + Checkout")
   SET trkview->qual[3].display = concat(trim(fn_prefix)," ",trim(ed_display)," Waiting Room")
   SET trkview->qual[4].display = concat(trim(fn_prefix)," ",trim(ed_display)," Greaseboard")
  ELSE
   SET stat = alterlist(trkview->qual,4)
   SET trkview->qual[1].display = concat(trim(fn_prefix)," All Beds")
   SET trkview->qual[2].display = concat(trim(fn_prefix)," All Beds + Checkout")
   SET trkview->qual[3].display = concat(trim(fn_prefix)," Waiting Room")
   SET trkview->qual[4].display = concat(trim(fn_prefix)," Greaseboard")
  ENDIF
 ELSEIF (uk_ind=1)
  IF (ed_code_value > 0)
   SET stat = alterlist(trkview->qual,4)
   SET trkview->qual[1].display = concat(trim(fn_prefix)," ",trim(ed_display)," All Beds")
   SET trkview->qual[2].display = concat(trim(fn_prefix)," ",trim(ed_display)," All Beds + Checkout")
   SET trkview->qual[3].display = concat(trim(fn_prefix)," ",trim(ed_display)," Waiting Room")
   SET trkview->qual[4].display = concat(trim(fn_prefix)," ",trim(ed_display)," Whiteboard")
  ELSE
   SET stat = alterlist(trkview->qual,4)
   SET trkview->qual[1].display = concat(trim(fn_prefix)," All Beds")
   SET trkview->qual[2].display = concat(trim(fn_prefix)," All Beds + Checkout")
   SET trkview->qual[3].display = concat(trim(fn_prefix)," Waiting Room")
   SET trkview->qual[4].display = concat(trim(fn_prefix)," Whiteboard")
  ENDIF
 ENDIF
 FOR (pv = 1 TO size(trkview->qual,5))
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].cdf_meaning = "PTTRACKROOT"
   SET request_cv->cd_value_list[1].display = trkview->qual[pv].display
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(trkview->qual[pv].display))
   SET request_cv->cd_value_list[1].description = trkview->qual[pv].display
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET trkview->qual[pv].code_value = reply_cv->qual[1].code_value
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   INSERT  FROM location l
    SET l.location_cd = trkview->qual[pv].code_value, l.location_type_cd = pttrackroot, l
     .organization_id = 0,
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
   FREE SET request_view
   RECORD request_view(
     1 llist[*]
       2 loc_code_value = f8
       2 loc_type_flag = i2
       2 vlist[*]
         3 view_code_value = f8
         3 action_flag = i2
   )
   FREE SET rl
   RECORD rl(
     1 roomlist[*]
       2 code_value = f8
   )
   IF (pv=1)
    SET cnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(rooms->cnt)),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=rooms->qual[d.seq].cd)
       AND cv.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      IF (cv.cdf_meaning="CHECKOUT")
       cnt = cnt
      ELSE
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = cv.code_value,
       stat = alterlist(rl->roomlist,cnt), rl->roomlist[cnt].code_value = cv.code_value, request_view
       ->llist[cnt].loc_type_flag = 0,
       stat = alterlist(request_view->llist[cnt].vlist,1), request_view->llist[cnt].vlist[1].
       view_code_value = trkview->qual[pv].code_value, request_view->llist[cnt].vlist[1].action_flag
        = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (size(rl->roomlist,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rl->roomlist,5))),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=rl->roomlist[d.seq].code_value)
        AND lg.root_loc_cd=0
        AND lg.active_ind=1)
      DETAIL
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = lg.child_loc_cd,
       request_view->llist[cnt].loc_type_flag = 1, stat = alterlist(request_view->llist[cnt].vlist,1),
       request_view->llist[cnt].vlist[1].view_code_value = trkview->qual[pv].code_value,
       request_view->llist[cnt].vlist[1].action_flag = 1
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (pv=2)
    INSERT  FROM br_name_value br
     SET br.br_name_value_id = seq(bedrock_seq,nextval), br.br_nv_key1 = "FNLOCVIEW_ALLBEDS+CHECKOUT",
      br.br_name = "CVFROMCS220",
      br.br_value = cnvtstring(trkview->qual[pv].code_value), br.updt_cnt = 0, br.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    SET cnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(rooms->cnt)),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=rooms->qual[d.seq].cd)
       AND cv.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
      loc_code_value = cv.code_value,
      stat = alterlist(rl->roomlist,cnt), rl->roomlist[cnt].code_value = cv.code_value, request_view
      ->llist[cnt].loc_type_flag = 0,
      stat = alterlist(request_view->llist[cnt].vlist,1), request_view->llist[cnt].vlist[1].
      view_code_value = trkview->qual[pv].code_value, request_view->llist[cnt].vlist[1].action_flag
       = 1
     WITH nocounter
    ;end select
    IF (size(rl->roomlist,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rl->roomlist,5))),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=rl->roomlist[d.seq].code_value)
        AND lg.root_loc_cd=0
        AND lg.active_ind=1)
      DETAIL
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = lg.child_loc_cd,
       request_view->llist[cnt].loc_type_flag = 1, stat = alterlist(request_view->llist[cnt].vlist,1),
       request_view->llist[cnt].vlist[1].view_code_value = trkview->qual[pv].code_value,
       request_view->llist[cnt].vlist[1].action_flag = 1
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (pv=3)
    SET cnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(rooms->cnt)),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=rooms->qual[d.seq].cd)
       AND cv.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      IF (cv.cdf_meaning="WAITROOM")
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = cv.code_value,
       stat = alterlist(rl->roomlist,cnt), rl->roomlist[cnt].code_value = cv.code_value, request_view
       ->llist[cnt].loc_type_flag = 0,
       stat = alterlist(request_view->llist[cnt].vlist,1), request_view->llist[cnt].vlist[1].
       view_code_value = trkview->qual[pv].code_value, request_view->llist[cnt].vlist[1].action_flag
        = 1
      ELSE
       cnt = cnt
      ENDIF
     WITH nocounter
    ;end select
    IF (size(rl->roomlist,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rl->roomlist,5))),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=rl->roomlist[d.seq].code_value)
        AND lg.root_loc_cd=0
        AND lg.active_ind=1)
      DETAIL
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = lg.child_loc_cd,
       request_view->llist[cnt].loc_type_flag = 1, stat = alterlist(request_view->llist[cnt].vlist,1),
       request_view->llist[cnt].vlist[1].view_code_value = trkview->qual[pv].code_value,
       request_view->llist[cnt].vlist[1].action_flag = 1
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (pv=4)
    SET cnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(rooms->cnt)),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=rooms->qual[d.seq].cd)
       AND cv.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      IF (cv.cdf_meaning IN ("CHECKOUT", "WAITROOM"))
       cnt = cnt
      ELSE
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = cv.code_value,
       stat = alterlist(rl->roomlist,cnt), rl->roomlist[cnt].code_value = cv.code_value, request_view
       ->llist[cnt].loc_type_flag = 0,
       stat = alterlist(request_view->llist[cnt].vlist,1), request_view->llist[cnt].vlist[1].
       view_code_value = trkview->qual[pv].code_value, request_view->llist[cnt].vlist[1].action_flag
        = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (size(rl->roomlist,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rl->roomlist,5))),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=rl->roomlist[d.seq].code_value)
        AND lg.root_loc_cd=0
        AND lg.active_ind=1)
      DETAIL
       cnt = (cnt+ 1), stat = alterlist(request_view->llist,cnt), request_view->llist[cnt].
       loc_code_value = lg.child_loc_cd,
       request_view->llist[cnt].loc_type_flag = 1, stat = alterlist(request_view->llist[cnt].vlist,1),
       request_view->llist[cnt].vlist[1].view_code_value = trkview->qual[pv].code_value,
       request_view->llist[cnt].vlist[1].action_flag = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET trace = recpersist
   EXECUTE bed_ens_fn_loc_view_info  WITH replace("REQUEST",request_view), replace("REPLY",reply_view
    )
   IF ((reply_view->status_data.status="S"))
    SET failed = "N"
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

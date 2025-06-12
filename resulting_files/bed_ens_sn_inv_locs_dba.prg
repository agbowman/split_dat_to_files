CREATE PROGRAM bed_ens_sn_inv_locs:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 error_msg = vc
    1 inv_locations[*]
      2 location_code_value = f8
      2 inv_locators[*]
        3 locator_code_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 FREE SET temp_root
 RECORD temp_root(
   1 roots[*]
     2 code_value = f8
 )
 FREE SET temp_seq
 RECORD temp_seq(
   1 seqs[*]
     2 sequence = i4
 )
 FREE SET temp_loc
 RECORD temp_loc(
   1 locs[*]
     2 action_flag = i2
     2 code_value = f8
     2 display = c15
     2 sequence = i4
     2 active_ind = i2
     2 coll_seq = i4
     2 active_stat = f8
     2 upd_act_ind = i2
 )
 SET active_code_value = 0.0
 SET invloc_code_value = 0.0
 SET invlocator_code_value = 0.0
 SET auth_code_value = 0.0
 SET powerchart_code_value = 0.0
 SET view_code_value = 0.0
 SET cnt = 0
 SET cnt2 = 0
 SET pcnt = 0
 SET list_cnt = 0
 SET tot_list_cnt = 0
 SET sub_cnt = 0
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET inactive_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="INVLOC"
   AND cv.active_ind=1
  DETAIL
   invloc_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="INVLOCATOR"
   AND cv.active_ind=1
  DETAIL
   invlocator_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=89
   AND cv.cdf_meaning="POWERCHART"
   AND cv.active_ind=1
  DETAIL
   powerchart_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="INVVIEW"
   AND cv.active_ind=1
  DETAIL
   view_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = size(request->inv_locations,5)
 FOR (x = 1 TO cnt)
  SET stat = initrec(temp_root)
  IF ((request->inv_locations[x].action_flag=1))
   SET colseq = 0
   SELECT INTO "nl:"
    csq = max(c.collation_seq)
    FROM code_value c
    PLAN (c
     WHERE c.code_set=220
      AND c.cdf_meaning="INVLOC")
    DETAIL
     colseq = csq
    WITH nocounter
   ;end select
   SET stat = initrec(request_cv)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].cdf_meaning = "INVLOC"
   SET request_cv->cd_value_list[1].concept_cki = ""
   SET request_cv->cd_value_list[1].display = substring(1,40,request->inv_locations[x].display)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->inv_locations[x].
    description)
   SET request_cv->cd_value_list[1].definition = ""
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].collation_seq = (colseq+ 1)
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET request->inv_locations[x].code_value = reply_cv->qual[1].code_value
   ELSE
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to insert ",trim(request->inv_locations[x].display),
     " into codeset 220.")
    GO TO exit_script
   ENDIF
   SET pcnt = size(request->inv_locations[x].parents,5)
   IF (pcnt > 0)
    SET stat = alterlist(temp_seq->seqs,pcnt)
    SELECT INTO "nl:"
     lsq = max(lg.sequence)
     FROM (dummyt d  WITH seq = value(pcnt)),
      location_group lg
     PLAN (d)
      JOIN (lg
      WHERE (lg.parent_loc_cd=request->inv_locations[x].parents[d.seq].code_value)
       AND lg.active_ind=1)
     ORDER BY d.seq
     DETAIL
      temp_seq->seqs[d.seq].sequence = (lsq+ 1)
     WITH nocounter
    ;end select
    SET ierrcode = 0
    INSERT  FROM location_group lg,
      (dummyt d  WITH seq = value(pcnt))
     SET lg.parent_loc_cd = request->inv_locations[x].parents[d.seq].code_value, lg.child_loc_cd =
      request->inv_locations[x].code_value, lg.location_group_type_cd = request->inv_locations[x].
      parents[d.seq].type_code_value,
      lg.active_ind = 1, lg.active_status_cd = active_code_value, lg.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      lg.active_status_prsnl_id = reqinfo->updt_id, lg.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), lg.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      lg.sequence = temp_seq->seqs[d.seq].sequence, lg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lg.updt_id = reqinfo->updt_id,
      lg.updt_task = reqinfo->updt_task, lg.updt_cnt = 0, lg.updt_applctx = reqinfo->updt_applctx,
      lg.root_loc_cd = request->inv_locations[x].parents[d.seq].inv_view_code_value, lg.view_type_cd
       = 0
     PLAN (d)
      JOIN (lg)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET cnt2 = size(request->inv_locations[x].inv_locators,5)
   SET stat = alterlist(temp_loc->locs,cnt2)
   IF (cnt2 > 0)
    SET colseq = 0
    SELECT INTO "nl:"
     csq = max(c.collation_seq)
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="INVLOCATOR")
     DETAIL
      colseq = csq
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt2))
     PLAN (d)
     ORDER BY d.seq
     HEAD d.seq
      temp_loc->locs[d.seq].action_flag = request->inv_locations[x].inv_locators[d.seq].action_flag,
      temp_loc->locs[d.seq].active_ind = request->inv_locations[x].inv_locators[d.seq].active_ind
      IF ((request->inv_locations[x].inv_locators[d.seq].active_ind=1))
       temp_loc->locs[d.seq].active_stat = active_code_value
      ELSE
       temp_loc->locs[d.seq].active_stat = inactive_code_value
      ENDIF
      temp_loc->locs[d.seq].code_value = request->inv_locations[x].inv_locators[d.seq].code_value
      IF ((request->inv_locations[x].inv_locators[d.seq].action_flag=1))
       colseq = (colseq+ 1), temp_loc->locs[d.seq].coll_seq = colseq
      ENDIF
      temp_loc->locs[d.seq].display = request->inv_locations[x].inv_locators[d.seq].display, temp_loc
      ->locs[d.seq].sequence = request->inv_locations[x].inv_locators[d.seq].sequence
     WITH nocounter
    ;end select
    FOR (y = 1 TO cnt2)
      IF ((request->inv_locations[x].inv_locators[y].active_ind=1))
       SELECT INTO "NL:"
        j = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         request->inv_locations[x].inv_locators[y].code_value = cnvtreal(j)
        WITH format, counter
       ;end select
      ENDIF
    ENDFOR
    SET ierrcode = 0
    INSERT  FROM code_value cv,
      (dummyt d  WITH seq = value(cnt2))
     SET cv.code_value = request->inv_locations[x].inv_locators[d.seq].code_value, cv.cdf_meaning =
      "INVLOCATOR", cv.code_set = 220,
      cv.active_ind = 1, cv.display = trim(substring(1,40,request->inv_locations[x].inv_locators[d
        .seq].display)), cv.display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->
          inv_locations[x].inv_locators[d.seq].display)))),
      cv.description = trim(substring(1,60,request->inv_locations[x].inv_locators[d.seq].display)),
      cv.definition = "", cv.data_status_cd = auth_code_value,
      cv.collation_seq = temp_loc->locs[d.seq].coll_seq, cv.concept_cki = "", cv.cki = null,
      cv.active_type_cd = temp_loc->locs[d.seq].active_stat, cv.active_dt_tm = cnvtdatetime(curdate,
       curtime3), cv.inactive_dt_tm = null,
      cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv.end_effective_dt_tm =
      cnvtdatetime("31-DEC-2100"), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx,
      cv.updt_cnt = 0
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=1))
      JOIN (cv)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (y = 1 TO cnt2)
     IF ((request->inv_locations[x].inv_locators[y].action_flag=1))
      IF (pcnt > 0)
       SET ierrcode = 0
       INSERT  FROM location_group lg,
         (dummyt d  WITH seq = value(pcnt))
        SET lg.parent_loc_cd = request->inv_locations[x].code_value, lg.child_loc_cd = request->
         inv_locations[x].inv_locators[y].code_value, lg.location_group_type_cd = invloc_code_value,
         lg.active_ind = 1, lg.active_status_cd = active_code_value, lg.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         lg.active_status_prsnl_id = reqinfo->updt_id, lg.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), lg.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         lg.sequence = request->inv_locations[x].inv_locators[y].sequence, lg.updt_dt_tm =
         cnvtdatetime(curdate,curtime3), lg.updt_id = reqinfo->updt_id,
         lg.updt_task = reqinfo->updt_task, lg.updt_cnt = 0, lg.updt_applctx = reqinfo->updt_applctx,
         lg.root_loc_cd = request->inv_locations[x].parents[d.seq].inv_view_code_value, lg
         .view_type_cd = 0
        PLAN (d)
         JOIN (lg)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (cnt2 > 0)
    SET ierrcode = 0
    INSERT  FROM location l,
      (dummyt d  WITH seq = value(cnt2))
     SET l.location_cd = request->inv_locations[x].inv_locators[d.seq].code_value, l.location_type_cd
       = invlocator_code_value, l.organization_id = request->inv_locations[x].parents[1].
      organization_id,
      l.resource_ind = 0.0, l.active_ind = 1, l.active_status_cd = active_code_value,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
      updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.census_ind = 0.0, l.contributor_system_cd = powerchart_code_value, l.data_status_cd =
      auth_code_value,
      l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.data_status_prsnl_id = reqinfo->updt_id,
      l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.facility_accn_prefix_cd = 0,
      l.discipline_type_cd = 0, l.view_type_cd = 0, l.exp_lvl_cd = 0,
      l.chart_format_id = 0, l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0,
      l.registration_ind = null, l.contributor_source_cd = 0, l.ref_lab_acct_nbr = " ",
      l.icu_ind = null, l.reserve_ind = 0
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=1))
      JOIN (l)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ELSEIF ((request->inv_locations[x].action_flag=0))
   SET cnt2 = size(request->inv_locations[x].inv_locators,5)
   SET stat = alterlist(temp_loc->locs,cnt2)
   IF (cnt2 > 0)
    SET colseq = 0
    SELECT INTO "nl:"
     csq = max(c.collation_seq)
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="INVLOCATOR")
     DETAIL
      colseq = csq
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt2)),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE cv.code_value=outerjoin(request->inv_locations[x].inv_locators[d.seq].code_value))
     ORDER BY d.seq
     HEAD d.seq
      temp_loc->locs[d.seq].action_flag = request->inv_locations[x].inv_locators[d.seq].action_flag,
      temp_loc->locs[d.seq].active_ind = request->inv_locations[x].inv_locators[d.seq].active_ind
      IF ((request->inv_locations[x].inv_locators[d.seq].active_ind=1))
       temp_loc->locs[d.seq].active_stat = active_code_value
      ELSE
       temp_loc->locs[d.seq].active_stat = inactive_code_value
      ENDIF
      IF (cv.code_value > 0
       AND (cv.active_ind != request->inv_locations[x].inv_locators[d.seq].active_ind))
       temp_loc->locs[d.seq].upd_act_ind = 1
      ENDIF
      temp_loc->locs[d.seq].code_value = request->inv_locations[x].inv_locators[d.seq].code_value
      IF ((request->inv_locations[x].inv_locators[d.seq].action_flag=1))
       colseq = (colseq+ 1), temp_loc->locs[d.seq].coll_seq = colseq
      ENDIF
      temp_loc->locs[d.seq].display = request->inv_locations[x].inv_locators[d.seq].display, temp_loc
      ->locs[d.seq].sequence = request->inv_locations[x].inv_locators[d.seq].sequence
     WITH nocounter
    ;end select
    FOR (y = 1 TO cnt2)
      IF ((request->inv_locations[x].inv_locators[y].action_flag=1))
       SELECT INTO "NL:"
        j = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         request->inv_locations[x].inv_locators[y].code_value = cnvtreal(j)
        WITH format, counter
       ;end select
      ENDIF
    ENDFOR
    SET ierrcode = 0
    INSERT  FROM code_value cv,
      (dummyt d  WITH seq = value(cnt2))
     SET cv.code_value = request->inv_locations[x].inv_locators[d.seq].code_value, cv.cdf_meaning =
      "INVLOCATOR", cv.code_set = 220,
      cv.active_ind = 1, cv.display = trim(substring(1,40,request->inv_locations[x].inv_locators[d
        .seq].display)), cv.display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->
          inv_locations[x].inv_locators[d.seq].display)))),
      cv.description = trim(substring(1,60,request->inv_locations[x].inv_locators[d.seq].display)),
      cv.definition = "", cv.data_status_cd = auth_code_value,
      cv.collation_seq = temp_loc->locs[d.seq].coll_seq, cv.concept_cki = "", cv.cki = null,
      cv.active_type_cd = temp_loc->locs[d.seq].active_stat, cv.active_dt_tm = cnvtdatetime(curdate,
       curtime3), cv.inactive_dt_tm = null,
      cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv.end_effective_dt_tm =
      cnvtdatetime("31-DEC-2100"), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx,
      cv.updt_cnt = 0
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=1))
      JOIN (cv)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM code_value cv,
      (dummyt d  WITH seq = value(cnt2))
     SET cv.display = trim(substring(1,40,request->inv_locations[x].inv_locators[d.seq].display)), cv
      .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->inv_locations[x].
          inv_locators[d.seq].display)))), cv.description = trim(substring(1,60,request->
        inv_locations[x].inv_locators[d.seq].display)),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
      reqinfo->updt_task,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=2)
       AND (temp_loc->locs[d.seq].upd_act_ind=0))
      JOIN (cv
      WHERE (cv.code_value=request->inv_locations[x].inv_locators[d.seq].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM code_value cv,
      (dummyt d  WITH seq = value(cnt2))
     SET cv.display = trim(substring(1,40,request->inv_locations[x].inv_locators[d.seq].display)), cv
      .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->inv_locations[x].
          inv_locators[d.seq].display)))), cv.description = trim(substring(1,60,request->
        inv_locations[x].inv_locators[d.seq].display)),
      cv.active_ind = request->inv_locations[x].inv_locators[d.seq].active_ind, cv.active_type_cd =
      temp_loc->locs[d.seq].active_stat, cv.active_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.inactive_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), cv.updt_id = reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
      .updt_cnt+ 1),
      cv.end_effective_dt_tm = evaluate(request->inv_locations[x].inv_locators[d.seq].active_ind,1,cv
       .end_effective_dt_tm,0,cnvtdatetime(curdate,curtime3))
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=2)
       AND (temp_loc->locs[d.seq].upd_act_ind=1)
       AND (temp_loc->locs[d.seq].active_ind=0))
      JOIN (cv
      WHERE (cv.code_value=request->inv_locations[x].inv_locators[d.seq].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM code_value cv,
      (dummyt d  WITH seq = value(cnt2))
     SET cv.display = trim(substring(1,40,request->inv_locations[x].inv_locators[d.seq].display)), cv
      .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->inv_locations[x].
          inv_locators[d.seq].display)))), cv.description = trim(substring(1,60,request->
        inv_locations[x].inv_locators[d.seq].display)),
      cv.active_ind = request->inv_locations[x].inv_locators[d.seq].active_ind, cv.active_type_cd =
      temp_loc->locs[d.seq].active_stat, cv.active_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
      reqinfo->updt_task,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=2)
       AND (temp_loc->locs[d.seq].upd_act_ind=1)
       AND (temp_loc->locs[d.seq].active_ind=1))
      JOIN (cv
      WHERE (cv.code_value=request->inv_locations[x].inv_locators[d.seq].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (y = 1 TO cnt2)
     IF ((request->inv_locations[x].inv_locators[y].action_flag=1))
      SET root_size = size(temp_root->roots,5)
      IF (root_size=0)
       SET list_cnt = 0
       SELECT DISTINCT INTO "nl:"
        lg.root_loc_cd
        FROM location_group lg,
         location_group lg2
        PLAN (lg
         WHERE (lg.child_loc_cd=request->inv_locations[x].code_value)
          AND lg.root_loc_cd > 0
          AND lg.active_ind=1)
         JOIN (lg2
         WHERE lg2.parent_loc_cd=lg.root_loc_cd
          AND lg2.location_group_type_cd=view_code_value
          AND lg2.active_ind=1)
        ORDER BY lg.root_loc_cd
        HEAD REPORT
         list_cnt = 0, tot_list_cnt = 0, stat = alterlist(temp_root->roots,10)
        DETAIL
         list_cnt = (list_cnt+ 1), tot_list_cnt = (tot_list_cnt+ 1)
         IF (tot_list_cnt > 10)
          stat = alterlist(temp_root->roots,(list_cnt+ 10)), tot_list_cnt = 1
         ENDIF
         temp_root->roots[list_cnt].code_value = lg.root_loc_cd
        FOOT REPORT
         stat = alterlist(temp_root->roots,list_cnt)
        WITH nocounter
       ;end select
       SET root_size = list_cnt
      ENDIF
      IF (root_size > 0)
       SET ierrcode = 0
       INSERT  FROM location_group lg,
         (dummyt d  WITH seq = value(root_size))
        SET lg.parent_loc_cd = request->inv_locations[x].code_value, lg.child_loc_cd = request->
         inv_locations[x].inv_locators[y].code_value, lg.location_group_type_cd = invloc_code_value,
         lg.active_ind = 1, lg.active_status_cd = active_code_value, lg.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         lg.active_status_prsnl_id = reqinfo->updt_id, lg.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), lg.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         lg.sequence = request->inv_locations[x].inv_locators[y].sequence, lg.updt_dt_tm =
         cnvtdatetime(curdate,curtime3), lg.updt_id = reqinfo->updt_id,
         lg.updt_task = reqinfo->updt_task, lg.updt_cnt = 0, lg.updt_applctx = reqinfo->updt_applctx,
         lg.root_loc_cd = temp_root->roots[d.seq].code_value, lg.view_type_cd = 0
        PLAN (d)
         JOIN (lg)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((((request->inv_locations[x].inv_locators[y].action_flag=2)) OR ((request->
     inv_locations[x].inv_locators[y].action_flag=5))) )
      SET root_size = size(temp_root->roots,5)
      IF (root_size=0)
       SET list_cnt = 0
       SELECT DISTINCT INTO "nl:"
        lg.root_loc_cd
        FROM location_group lg,
         location_group lg2
        PLAN (lg
         WHERE (lg.child_loc_cd=request->inv_locations[x].code_value)
          AND lg.root_loc_cd > 0
          AND lg.active_ind=1)
         JOIN (lg2
         WHERE lg2.parent_loc_cd=lg.root_loc_cd
          AND lg2.location_group_type_cd=view_code_value
          AND lg2.active_ind=1)
        ORDER BY lg.root_loc_cd
        HEAD REPORT
         list_cnt = 0, tot_list_cnt = 0, stat = alterlist(temp_root->roots,10)
        DETAIL
         list_cnt = (list_cnt+ 1), tot_list_cnt = (tot_list_cnt+ 1)
         IF (tot_list_cnt > 10)
          stat = alterlist(temp_root->roots,(list_cnt+ 10)), tot_list_cnt = 1
         ENDIF
         temp_root->roots[list_cnt].code_value = lg.root_loc_cd
        FOOT REPORT
         stat = alterlist(temp_root->roots,list_cnt)
        WITH nocounter
       ;end select
       SET root_size = list_cnt
      ENDIF
      IF (root_size > 0)
       SET ierrcode = 0
       UPDATE  FROM location_group lg,
         (dummyt d  WITH seq = value(root_size))
        SET lg.sequence = request->inv_locations[x].inv_locators[y].sequence, lg.active_ind = request
         ->inv_locations[x].inv_locators[y].active_ind, lg.active_status_cd = evaluate(request->
          inv_locations[x].inv_locators[y].active_ind,1,active_code_value,0,inactive_code_value),
         lg.end_effective_dt_tm = evaluate(request->inv_locations[x].inv_locators[y].active_ind,1,lg
          .end_effective_dt_tm,0,cnvtdatetime(curdate,curtime3)), lg.updt_applctx = reqinfo->
         updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1),
         lg.updt_dt_tm = cnvtdatetime(curdate,curtime3), lg.updt_id = reqinfo->updt_id, lg.updt_task
          = reqinfo->updt_task
        PLAN (d)
         JOIN (lg
         WHERE (lg.child_loc_cd=request->inv_locations[x].inv_locators[y].code_value)
          AND (lg.parent_loc_cd=request->inv_locations[x].code_value)
          AND (lg.root_loc_cd=temp_root->roots[d.seq].code_value))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (cnt2 > 0)
    SET org_id = 0.0
    SELECT INTO "nl:"
     l.organization_id
     FROM location l
     WHERE (location_cd=request->inv_locations[x].code_value)
     DETAIL
      org_id = l.organization_id
     WITH nocounter
    ;end select
    SET ierrcode = 0
    INSERT  FROM location l,
      (dummyt d  WITH seq = value(cnt2))
     SET l.location_cd = request->inv_locations[x].inv_locators[d.seq].code_value, l.location_type_cd
       = invlocator_code_value, l.organization_id = org_id,
      l.resource_ind = 0.0, l.active_ind = 1, l.active_status_cd = active_code_value,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
      updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.census_ind = 0.0, l.contributor_system_cd = powerchart_code_value, l.data_status_cd =
      auth_code_value,
      l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.data_status_prsnl_id = reqinfo->updt_id,
      l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.facility_accn_prefix_cd = 0,
      l.discipline_type_cd = 0, l.view_type_cd = 0, l.exp_lvl_cd = 0,
      l.chart_format_id = 0, l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0,
      l.registration_ind = null, l.contributor_source_cd = 0, l.ref_lab_acct_nbr = " ",
      l.icu_ind = null, l.reserve_ind = 0
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=1))
      JOIN (l)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM location l,
      (dummyt d  WITH seq = value(cnt2))
     SET l.active_ind = request->inv_locations[x].inv_locators[d.seq].active_ind, l.active_status_cd
       = evaluate(request->inv_locations[x].inv_locators[d.seq].active_ind,1,active_code_value,0,
       inactive_code_value), l.end_effective_dt_tm = evaluate(request->inv_locations[x].inv_locators[
       d.seq].active_ind,1,l.end_effective_dt_tm,0,cnvtdatetime(curdate,curtime3)),
      l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1), l.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task
     PLAN (d
      WHERE (request->inv_locations[x].inv_locators[d.seq].action_flag=2))
      JOIN (l
      WHERE (l.location_cd=request->inv_locations[x].inv_locators[d.seq].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (cnt > 0)
  SET ierrcode = 0
  INSERT  FROM location l,
    (dummyt d  WITH seq = value(cnt))
   SET l.location_cd = request->inv_locations[d.seq].code_value, l.location_type_cd =
    invloc_code_value, l.organization_id = request->inv_locations[d.seq].parents[1].organization_id,
    l.resource_ind = 0.0, l.active_ind = 1, l.active_status_cd = active_code_value,
    l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
    updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    l.census_ind = 0.0, l.contributor_system_cd = powerchart_code_value, l.data_status_cd =
    auth_code_value,
    l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.data_status_prsnl_id = reqinfo->updt_id,
    l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
    l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.facility_accn_prefix_cd = 0,
    l.discipline_type_cd = 0, l.view_type_cd = 0, l.exp_lvl_cd = 0,
    l.chart_format_id = 0, l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0,
    l.registration_ind = null, l.contributor_source_cd = 0, l.ref_lab_acct_nbr = " ",
    l.icu_ind = null, l.reserve_ind = 0
   PLAN (d
    WHERE (request->inv_locations[d.seq].action_flag=1))
    JOIN (l)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
  SET stat = alterlist(reply->inv_locations,cnt)
  FOR (x = 1 TO cnt)
    SET reply->inv_locations[x].location_code_value = request->inv_locations[x].code_value
    SET lsize = size(request->inv_locations[x].inv_locators,5)
    IF (lsize > 0)
     SET stat = alterlist(reply->inv_locations[x].inv_locators,lsize)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(lsize))
      ORDER BY d.seq
      HEAD d.seq
       reply->inv_locations[x].inv_locators[d.seq].locator_code_value = request->inv_locations[x].
       inv_locators[d.seq].code_value
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
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

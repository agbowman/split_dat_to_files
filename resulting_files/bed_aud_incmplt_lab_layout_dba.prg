CREATE PROGRAM bed_aud_incmplt_lab_layout:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
  )
 ENDIF
 RECORD temp(
   1 srlist[*]
     2 sr_desc = vc
     2 sr_disp = vc
     2 sr_disp_key = vc
     2 sr_cd = f8
     2 sr_type_disp = vc
     2 sr_type_cd = f8
     2 missing_org_ind = i2
     2 missing_disc_type_ind = i2
     2 disc_mismatch_ind = i2
     2 missing_act_type_ind = i2
     2 missing_calendar_ind = i2
     2 missing_login_loc_ind = i2
 )
 RECORD hold(
   1 ilist[*]
     2 inst_cd = f8
     2 inst_disp = vc
     2 inst_desc = vc
     2 inst_disp_key = vc
     2 missing_org_ind = i2
     2 dlist[*]
       3 dept_cd = f8
       3 dept_disp = vc
       3 dept_desc = vc
       3 dept_disp_key = vc
       3 missing_org_ind = i2
       3 missing_disc_type_ind = i2
       3 slist[*]
         4 sect_cd = f8
         4 sect_desc = vc
         4 sect_disp = vc
         4 sect_disp_key = vc
         4 missing_org_ind = i2
         4 missing_disc_type_ind = i2
         4 disc_mismatch_ind = i2
         4 missing_act_type_ind = i2
         4 sslist[*]
           5 ssect_cd = f8
           5 ssect_desc = vc
           5 ssect_disp = vc
           5 ssect_disp_key = vc
           5 cs_login_loc_cd = f8
           5 missing_org_ind = i2
           5 missing_disc_type_ind = i2
           5 disc_mismatch_ind = i2
           5 missing_act_type_ind = i2
           5 multiplexor_ind = i2
           5 missing_cal_ind = i2
           5 missing_ll_ind = i2
           5 blist[*]
             6 b_cd = f8
             6 b_desc = vc
             6 b_disp = vc
             6 b_disp_key = vc
             6 b_type_cd = f8
             6 cs_login_loc_cd = f8
             6 missing_org_ind = i2
             6 missing_disc_type_ind = i2
             6 disc_mismatch_ind = i2
             6 missing_act_type_ind = i2
             6 missing_cal_ind = i2
             6 missing_ll_ind = i2
 )
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Display Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Missing Organization"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Missing Discipline Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Discipline Type Mismatch"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Missing Activity Type"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Missing Calendar"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Missing Login Location"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "location_cd"
 SET reply->collist[10].data_type = 2
 SET reply->collist[10].hide_ind = 1
 SET glb_ac_cd = get_code_value(106,"GLB")
 SET lab_ct_cd = get_code_value(6000,"GENERAL LAB")
 SET inst_cd = get_code_value(223,"INSTITUTION")
 SET dept_cd = get_code_value(223,"DEPARTMENT")
 SET sect_cd = get_code_value(223,"SECTION")
 SET subsect_cd = get_code_value(223,"SUBSECTION")
 SET bench_cd = get_code_value(223,"BENCH")
 SET instr_cd = get_code_value(223,"INSTRUMENT")
 SET totinst_cnt = 0
 SET inst_missingorg_cnt = 0
 SET totgldept_cnt = 0
 SET gldept_missingorg_cnt = 0
 SET gldept_missingdisc_cnt = 0
 SET totglsect_cnt = 0
 SET glsect_missingorg_cnt = 0
 SET glsect_missingdisc_cnt = 0
 SET glsect_discmismatch_cnt = 0
 SET glsect_missingact_cnt = 0
 SET totglssect_cnt = 0
 SET glssect_missingorg_cnt = 0
 SET glssect_missingdisc_cnt = 0
 SET glssect_discmismatch_cnt = 0
 SET glssect_missingact_cnt = 0
 SET totmultplex_cnt = 0
 SET multplex_missingcal_cnt = 0
 SET multplex_missingll_cnt = 0
 SET totglbench_cnt = 0
 SET glbench_missingcal_cnt = 0
 SET glbench_missingll_cnt = 0
 SET glbench_missingorg_cnt = 0
 SET glbench_missingact_cnt = 0
 SET glbench_missingdisc_cnt = 0
 SET glbench_discmismatch_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET high_volume_cnt = 0
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM resource_group rg
   PLAN (rg
    WHERE rg.resource_group_type_cd IN (inst_cd, dept_cd, sect_cd, subsect_cd, bench_cd,
    instr_cd)
     AND rg.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt=3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET icnt = 0
 SELECT INTO "nl:"
  FROM service_resource sr,
   code_value cv
  PLAN (sr
   WHERE sr.service_resource_type_cd=inst_cd
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd
    AND cv.active_ind=1)
  HEAD REPORT
   icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(hold->ilist,icnt), hold->ilist[icnt].inst_cd = sr
   .service_resource_cd,
   hold->ilist[icnt].inst_disp = cv.display, hold->ilist[icnt].inst_desc = cv.description, hold->
   ilist[icnt].inst_disp_key = cv.display_key
   IF (sr.organization_id=0)
    hold->ilist[icnt].missing_org_ind = 1
   ELSE
    hold->ilist[icnt].missing_org_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (icnt=0)
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = icnt),
   resource_group rg1,
   service_resource sr1,
   code_value cv1
  PLAN (d)
   JOIN (rg1
   WHERE (rg1.parent_service_resource_cd=hold->ilist[d.seq].inst_cd)
    AND rg1.resource_group_type_cd=inst_cd
    AND rg1.active_ind=1)
   JOIN (sr1
   WHERE sr1.service_resource_cd=rg1.child_service_resource_cd
    AND sr1.service_resource_type_cd=dept_cd
    AND sr1.active_ind=1
    AND sr1.discipline_type_cd IN (0, lab_ct_cd))
   JOIN (cv1
   WHERE cv1.code_value=sr1.service_resource_cd
    AND cv1.active_ind=1)
  HEAD d.seq
   dcnt = 0
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(hold->ilist[d.seq].dlist,dcnt), hold->ilist[d.seq].dlist[dcnt].
   dept_cd = cv1.code_value,
   hold->ilist[d.seq].dlist[dcnt].dept_disp = cv1.display, hold->ilist[d.seq].dlist[dcnt].dept_desc
    = cv1.description, hold->ilist[d.seq].dlist[dcnt].dept_disp_key = cv1.display_key
   IF (sr1.organization_id=0)
    hold->ilist[d.seq].dlist[dcnt].missing_org_ind = 1
   ELSE
    hold->ilist[d.seq].dlist[dcnt].missing_org_ind = 0
   ENDIF
   IF (sr1.discipline_type_cd=0)
    hold->ilist[d.seq].dlist[dcnt].missing_disc_type_ind = 1
   ELSE
    hold->ilist[d.seq].dlist[dcnt].missing_disc_type_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 FOR (i = 1 TO icnt)
  SET dcnt = size(hold->ilist[i].dlist,5)
  IF (dcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = dcnt),
     resource_group rg1,
     service_resource sr1,
     code_value cv1
    PLAN (d
     WHERE (hold->ilist[i].dlist[d.seq].missing_disc_type_ind=0))
     JOIN (rg1
     WHERE (rg1.parent_service_resource_cd=hold->ilist[i].dlist[d.seq].dept_cd)
      AND rg1.resource_group_type_cd=dept_cd
      AND rg1.active_ind=1)
     JOIN (sr1
     WHERE sr1.service_resource_cd=rg1.child_service_resource_cd
      AND sr1.service_resource_type_cd=sect_cd
      AND sr1.active_ind=1)
     JOIN (cv1
     WHERE cv1.code_value=sr1.service_resource_cd
      AND cv1.active_ind=1)
    HEAD d.seq
     scnt = 0
    DETAIL
     scnt = (scnt+ 1), stat = alterlist(hold->ilist[i].dlist[d.seq].slist,scnt), hold->ilist[i].
     dlist[d.seq].slist[scnt].sect_cd = cv1.code_value,
     hold->ilist[i].dlist[d.seq].slist[scnt].sect_desc = cv1.description, hold->ilist[i].dlist[d.seq]
     .slist[scnt].sect_disp = cv1.display, hold->ilist[i].dlist[d.seq].slist[scnt].sect_disp_key =
     cv1.display_key
     IF (sr1.organization_id=0)
      hold->ilist[i].dlist[d.seq].slist[scnt].missing_org_ind = 1
     ELSE
      hold->ilist[i].dlist[d.seq].slist[scnt].missing_org_ind = 0
     ENDIF
     IF (sr1.discipline_type_cd=0)
      hold->ilist[i].dlist[d.seq].slist[scnt].missing_disc_type_ind = 1
     ELSE
      hold->ilist[i].dlist[d.seq].slist[scnt].missing_disc_type_ind = 0
     ENDIF
     IF (sr1.discipline_type_cd > 0
      AND sr1.discipline_type_cd != lab_ct_cd)
      hold->ilist[i].dlist[d.seq].slist[scnt].disc_mismatch_ind = 1
     ELSE
      hold->ilist[i].dlist[d.seq].slist[scnt].disc_mismatch_ind = 0
     ENDIF
     IF (sr1.activity_type_cd=0)
      hold->ilist[i].dlist[d.seq].slist[scnt].missing_act_type_ind = 1
     ELSE
      hold->ilist[i].dlist[d.seq].slist[scnt].missing_act_type_ind = 0
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 FOR (i = 1 TO icnt)
  SET dcnt = size(hold->ilist[i].dlist,5)
  FOR (d = 1 TO dcnt)
    SET scnt = size(hold->ilist[i].dlist[d].slist,5)
    SET sscnt = 0
    IF (scnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = scnt),
       resource_group rg1,
       service_resource sr1,
       code_value cv1,
       (dummyt d2  WITH seq = 1),
       resource_group rg2,
       service_resource sr2,
       code_value cv2
      PLAN (d)
       JOIN (rg1
       WHERE (rg1.parent_service_resource_cd=hold->ilist[i].dlist[d].slist[d.seq].sect_cd)
        AND rg1.resource_group_type_cd=sect_cd
        AND rg1.active_ind=1)
       JOIN (sr1
       WHERE sr1.service_resource_cd=rg1.child_service_resource_cd
        AND sr1.service_resource_type_cd=subsect_cd
        AND sr1.active_ind=1)
       JOIN (cv1
       WHERE cv1.code_value=sr1.service_resource_cd
        AND cv1.active_ind=1)
       JOIN (d2)
       JOIN (rg2
       WHERE rg2.parent_service_resource_cd=cv1.code_value
        AND rg2.resource_group_type_cd=subsect_cd
        AND rg2.active_ind=1)
       JOIN (sr2
       WHERE sr2.service_resource_cd=rg2.child_service_resource_cd
        AND sr2.service_resource_type_cd IN (bench_cd, instr_cd)
        AND sr2.active_ind=1)
       JOIN (cv2
       WHERE cv2.code_value=sr2.service_resource_cd
        AND cv2.active_ind=1)
      ORDER BY d.seq, sr1.service_resource_cd
      HEAD d.seq
       sscnt = 0
      HEAD sr1.service_resource_cd
       sscnt = (sscnt+ 1), stat = alterlist(hold->ilist[i].dlist[d].slist[d.seq].sslist,sscnt), hold
       ->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].ssect_cd = cv1.code_value,
       hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].ssect_desc = cv1.description, hold->ilist[i
       ].dlist[d].slist[d.seq].sslist[sscnt].ssect_disp = cv1.display, hold->ilist[i].dlist[d].slist[
       d.seq].sslist[sscnt].ssect_disp_key = cv1.display_key,
       hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].cs_login_loc_cd = sr1.cs_login_loc_cd
       IF (sr1.organization_id=0)
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].missing_org_ind = 1
       ELSE
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].missing_org_ind = 0
       ENDIF
       IF (sr1.discipline_type_cd=0)
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].missing_disc_type_ind = 1
       ELSE
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].missing_disc_type_ind = 0
       ENDIF
       IF (sr1.discipline_type_cd > 0
        AND sr1.discipline_type_cd != lab_ct_cd)
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].disc_mismatch_ind = 1
       ELSE
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].disc_mismatch_ind = 0
       ENDIF
       IF (sr1.activity_type_cd=0)
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].missing_act_type_ind = 1
       ELSE
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].missing_act_type_ind = 0
       ENDIF
       bcnt = 0
      DETAIL
       IF (cv2.code_value > 0)
        bcnt = (bcnt+ 1), stat = alterlist(hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist,
         bcnt), hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].b_cd = cv2.code_value,
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].b_desc = cv2.description, hold
        ->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].b_disp = cv2.display, hold->ilist[
        i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].b_disp_key = cv2.display_key,
        hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].b_type_cd = sr2
        .service_resource_type_cd, hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].
        cs_login_loc_cd = sr2.cs_login_loc_cd
        IF (sr2.organization_id=0)
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].missing_org_ind = 1
        ELSE
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].missing_org_ind = 0
        ENDIF
        IF (sr2.discipline_type_cd=0)
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].missing_disc_type_ind = 1
        ELSE
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].missing_disc_type_ind = 0
        ENDIF
        IF (sr2.discipline_type_cd > 0
         AND sr2.discipline_type_cd != lab_ct_cd)
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].disc_mismatch_ind = 1
        ELSE
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].disc_mismatch_ind = 0
        ENDIF
        IF (sr2.activity_type_cd=0)
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].missing_act_type_ind = 1
        ELSE
         hold->ilist[i].dlist[d].slist[d.seq].sslist[sscnt].blist[bcnt].missing_act_type_ind = 0
        ENDIF
       ENDIF
      WITH nocounter, outerjoin = d2
     ;end select
    ENDIF
  ENDFOR
 ENDFOR
 SET tcnt = 0
 SET totinst_cnt = icnt
 FOR (i = 1 TO icnt)
   IF ((hold->ilist[i].missing_org_ind=1))
    SET inst_missingorg_cnt = (inst_missingorg_cnt+ 1)
    SET tcnt = (tcnt+ 1)
    SET stat = alterlist(temp->srlist,tcnt)
    SET temp->srlist[tcnt].sr_cd = hold->ilist[i].inst_cd
    SET temp->srlist[tcnt].sr_desc = hold->ilist[i].inst_desc
    SET temp->srlist[tcnt].sr_disp = hold->ilist[i].inst_disp
    SET temp->srlist[tcnt].sr_disp_key = hold->ilist[i].inst_disp_key
    SET temp->srlist[tcnt].sr_type_cd = inst_cd
    SET temp->srlist[tcnt].missing_org_ind = 1
    SET temp->srlist[tcnt].missing_disc_type_ind = 0
    SET temp->srlist[tcnt].disc_mismatch_ind = 0
    SET temp->srlist[tcnt].missing_act_type_ind = 0
    SET temp->srlist[tcnt].missing_calendar_ind = 0
    SET temp->srlist[tcnt].missing_login_loc_ind = 0
   ENDIF
   SET dcnt = size(hold->ilist[i].dlist,5)
   SET totgldept_cnt = (totgldept_cnt+ dcnt)
   FOR (d = 1 TO dcnt)
     IF ((((hold->ilist[i].dlist[d].missing_org_ind=1)) OR ((hold->ilist[i].dlist[d].
     missing_disc_type_ind=1))) )
      SET tcnt = (tcnt+ 1)
      SET stat = alterlist(temp->srlist,tcnt)
      SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].dept_desc
      SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].dept_disp
      SET temp->srlist[tcnt].sr_disp_key = hold->ilist[i].dlist[d].dept_disp_key
      SET temp->srlist[tcnt].sr_type_cd = dept_cd
      IF ((hold->ilist[i].dlist[d].missing_org_ind=1))
       SET temp->srlist[tcnt].missing_org_ind = 1
       SET gldept_missingorg_cnt = (gldept_missingorg_cnt+ 1)
      ELSE
       SET temp->srlist[tcnt].missing_org_ind = 0
      ENDIF
      IF ((hold->ilist[i].dlist[d].missing_disc_type_ind=1))
       SET temp->srlist[tcnt].missing_disc_type_ind = 1
       SET gldept_missingdisc_cnt = (gldept_missingdisc_cnt+ 1)
      ELSE
       SET temp->srlist[tcnt].missing_disc_type_ind = 0
      ENDIF
      SET temp->srlist[tcnt].disc_mismatch_ind = 0
      SET temp->srlist[tcnt].missing_act_type_ind = 0
      SET temp->srlist[tcnt].missing_calendar_ind = 0
      SET temp->srlist[tcnt].missing_login_loc_ind = 0
     ENDIF
     SET scnt = size(hold->ilist[i].dlist[d].slist,5)
     SET totglsect_cnt = (totglsect_cnt+ scnt)
     FOR (s = 1 TO scnt)
       IF ((((hold->ilist[i].dlist[d].slist[s].missing_org_ind=1)) OR ((((hold->ilist[i].dlist[d].
       slist[s].missing_disc_type_ind=1)) OR ((((hold->ilist[i].dlist[d].slist[s].disc_mismatch_ind=1
       )) OR ((hold->ilist[i].dlist[d].slist[s].missing_act_type_ind=1))) )) )) )
        SET tcnt = (tcnt+ 1)
        SET stat = alterlist(temp->srlist,tcnt)
        SET temp->srlist[tcnt].sr_cd = hold->ilist[i].dlist[d].slist[s].sect_cd
        SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].slist[s].sect_desc
        SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].slist[s].sect_disp
        SET temp->srlist[tcnt].sr_disp_key = hold->ilist[i].dlist[d].slist[s].sect_disp_key
        SET temp->srlist[tcnt].sr_type_cd = sect_cd
        SET temp->srlist[tcnt].missing_org_ind = hold->ilist[i].dlist[d].slist[s].missing_org_ind
        SET temp->srlist[tcnt].missing_disc_type_ind = hold->ilist[i].dlist[d].slist[s].
        missing_disc_type_ind
        SET temp->srlist[tcnt].disc_mismatch_ind = hold->ilist[i].dlist[d].slist[s].disc_mismatch_ind
        SET temp->srlist[tcnt].missing_act_type_ind = hold->ilist[i].dlist[d].slist[s].
        missing_act_type_ind
        SET temp->srlist[tcnt].missing_calendar_ind = 0
        SET temp->srlist[tcnt].missing_login_loc_ind = 0
        IF ((temp->srlist[tcnt].missing_org_ind=1))
         SET glsect_missingorg_cnt = (glsect_missingorg_cnt+ 1)
        ENDIF
        IF ((temp->srlist[tcnt].missing_disc_type_ind=1))
         SET glsect_missingdisc_cnt = (glsect_missingdisc_cnt+ 1)
        ENDIF
        IF ((temp->srlist[tcnt].disc_mismatch_ind=1))
         SET glsect_discmismatch_cnt = (glsect_discmismatch_cnt+ 1)
        ENDIF
        IF ((temp->srlist[tcnt].missing_act_type_ind=1))
         SET glsect_missingact_cnt = (glsect_missingact_cnt+ 1)
        ENDIF
       ENDIF
       SET sscnt = size(hold->ilist[i].dlist[d].slist[s].sslist,5)
       SET totglssect_cnt = (totglssect_cnt+ sscnt)
       FOR (ss = 1 TO sscnt)
         SET multiplexor_ind = 0
         SELECT INTO "nl:"
          FROM sub_section ss
          PLAN (ss
           WHERE (ss.service_resource_cd=hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_cd))
          DETAIL
           IF (ss.multiplexor_ind=1)
            multiplexor_ind = 1
           ELSE
            multiplexor_ind = 0
           ENDIF
          WITH nocounter
         ;end select
         IF (multiplexor_ind=1)
          SET totmultplex_cnt = (totmultplex_cnt+ 1)
          IF ((hold->ilist[i].dlist[d].slist[s].sslist[ss].cs_login_loc_cd > 0))
           SET hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_ll_ind = 0
          ELSE
           SET hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_ll_ind = 1
          ENDIF
          SET hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_cal_ind = 1
          SELECT INTO "nl:"
           FROM loc_resource_calendar lrc
           PLAN (lrc
            WHERE (lrc.service_resource_cd=hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_cd)
             AND lrc.active_ind=1)
           DETAIL
            hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_cal_ind = 0
           WITH nocounter
          ;end select
         ELSE
          SET hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_ll_ind = 0
          SET hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_cal_ind = 0
         ENDIF
         IF ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_org_ind=1)) OR ((((hold->ilist[i]
         .dlist[d].slist[s].sslist[ss].missing_disc_type_ind=1)) OR ((((hold->ilist[i].dlist[d].
         slist[s].sslist[ss].disc_mismatch_ind=1)) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss]
         .missing_act_type_ind=1)) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_cal_ind
         =1)) OR ((hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_ll_ind=1))) )) )) )) )) )
          SET tcnt = (tcnt+ 1)
          SET stat = alterlist(temp->srlist,tcnt)
          SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_desc
          SET temp->srlist[tcnt].sr_cd = hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_cd
          SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_disp
          SET temp->srlist[tcnt].sr_disp_key = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          ssect_disp_key
          SET temp->srlist[tcnt].sr_type_cd = subsect_cd
          SET temp->srlist[tcnt].missing_org_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          missing_org_ind
          SET temp->srlist[tcnt].missing_disc_type_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          missing_disc_type_ind
          SET temp->srlist[tcnt].disc_mismatch_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          disc_mismatch_ind
          SET temp->srlist[tcnt].missing_act_type_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          missing_act_type_ind
          SET temp->srlist[tcnt].missing_calendar_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          missing_cal_ind
          SET temp->srlist[tcnt].missing_login_loc_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          missing_ll_ind
          IF ((temp->srlist[tcnt].missing_org_ind=1))
           SET glssect_missingorg_cnt = (glssect_missingorg_cnt+ 1)
          ENDIF
          IF ((temp->srlist[tcnt].missing_disc_type_ind=1))
           SET glssect_missingdisc_cnt = (glssect_missingdisc_cnt+ 1)
          ENDIF
          IF ((temp->srlist[tcnt].disc_mismatch_ind=1))
           SET glssect_discmismatch_cnt = (glssect_discmismatch_cnt+ 1)
          ENDIF
          IF ((temp->srlist[tcnt].missing_act_type_ind=1))
           SET glssect_missingact_cnt = (glssect_missingact_cnt+ 1)
          ENDIF
          IF ((temp->srlist[tcnt].missing_calendar_ind=1))
           SET multplex_missingcal_cnt = (multplex_missingcal_cnt+ 1)
          ENDIF
          IF ((temp->srlist[tcnt].missing_login_loc_ind=1))
           SET multplex_missingll_cnt = (multplex_missingll_cnt+ 1)
          ENDIF
         ENDIF
         SET bcnt = size(hold->ilist[i].dlist[d].slist[s].sslist[ss].blist,5)
         SET totglbench_cnt = (totglbench_cnt+ bcnt)
         FOR (b = 1 TO bcnt)
           IF ((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].cs_login_loc_cd > 0))
            SET hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_ll_ind = 0
           ELSE
            SET hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_ll_ind = 1
           ENDIF
           SET hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_cal_ind = 1
           SELECT INTO "nl:"
            FROM loc_resource_calendar lrc
            PLAN (lrc
             WHERE (lrc.service_resource_cd=hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].b_cd
             )
              AND lrc.active_ind=1)
            DETAIL
             hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_cal_ind = 0
            WITH nocounter
           ;end select
           IF ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_org_ind=1)) OR ((((
           hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_disc_type_ind=1)) OR ((((hold
           ->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].disc_mismatch_ind=1)) OR ((((hold->ilist[
           i].dlist[d].slist[s].sslist[ss].blist[b].missing_act_type_ind=1)) OR ((((hold->ilist[i].
           dlist[d].slist[s].sslist[ss].blist[b].missing_cal_ind=1)) OR ((hold->ilist[i].dlist[d].
           slist[s].sslist[ss].blist[b].missing_ll_ind=1))) )) )) )) )) )
            SET tcnt = (tcnt+ 1)
            SET stat = alterlist(temp->srlist,tcnt)
            SET temp->srlist[tcnt].sr_cd = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].b_cd
            SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
            b_desc
            SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
            b_disp
            SET temp->srlist[tcnt].sr_disp_key = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b]
            .b_disp_key
            SET temp->srlist[tcnt].sr_type_cd = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
            b_type_cd
            SET temp->srlist[tcnt].missing_org_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
            blist[b].missing_org_ind
            SET temp->srlist[tcnt].missing_disc_type_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss
            ].blist[b].missing_disc_type_ind
            SET temp->srlist[tcnt].disc_mismatch_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
            blist[b].disc_mismatch_ind
            SET temp->srlist[tcnt].missing_act_type_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss]
            .blist[b].missing_act_type_ind
            SET temp->srlist[tcnt].missing_calendar_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss]
            .blist[b].missing_cal_ind
            SET temp->srlist[tcnt].missing_login_loc_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss
            ].blist[b].missing_ll_ind
            IF ((temp->srlist[tcnt].missing_org_ind=1))
             SET glbench_missingorg_cnt = (glbench_missingorg_cnt+ 1)
            ENDIF
            IF ((temp->srlist[tcnt].missing_disc_type_ind=1))
             SET glbench_missingdisc_cnt = (glbench_missingdisc_cnt+ 1)
            ENDIF
            IF ((temp->srlist[tcnt].disc_mismatch_ind=1))
             SET glbench_discmismatch_cnt = (glbench_discmismatch_cnt+ 1)
            ENDIF
            IF ((temp->srlist[tcnt].missing_act_type_ind=1))
             SET glbench_missingact_cnt = (glbench_missingact_cnt+ 1)
            ENDIF
            IF ((temp->srlist[tcnt].missing_calendar_ind=1))
             SET glbench_missingcal_cnt = (glbench_missingcal_cnt+ 1)
            ENDIF
            IF ((temp->srlist[tcnt].missing_login_loc_ind=1))
             SET glbench_missingll_cnt = (glbench_missingll_cnt+ 1)
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET rcnt = 0
 IF (tcnt > 0)
  SELECT INTO "nl:"
   sr_disp = cnvtupper(temp->srlist[d.seq].sr_desc), sr_type_disp = cv.display_key, sr_cd = temp->
   srlist[d.seq].sr_cd
   FROM (dummyt d  WITH seq = tcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->srlist[d.seq].sr_type_cd)
     AND cv.active_ind=1
     AND cv.code_set=223)
   ORDER BY sr_disp, sr_type_disp, sr_cd
   HEAD REPORT
    rcnt = 0
   HEAD sr_cd
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,10),
    reply->rowlist[rcnt].celllist[1].string_value = temp->srlist[d.seq].sr_desc, reply->rowlist[rcnt]
    .celllist[2].string_value = temp->srlist[d.seq].sr_disp, reply->rowlist[rcnt].celllist[3].
    string_value = cv.display
    IF ((temp->srlist[d.seq].missing_org_ind=1))
     reply->rowlist[rcnt].celllist[4].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[4].string_value = " "
    ENDIF
    IF ((temp->srlist[d.seq].missing_disc_type_ind=1))
     reply->rowlist[rcnt].celllist[5].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[5].string_value = " "
    ENDIF
    IF ((temp->srlist[d.seq].disc_mismatch_ind=1))
     reply->rowlist[rcnt].celllist[6].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[6].string_value = " "
    ENDIF
    IF ((temp->srlist[d.seq].missing_act_type_ind=1))
     reply->rowlist[rcnt].celllist[7].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[7].string_value = " "
    ENDIF
    IF ((temp->srlist[d.seq].missing_calendar_ind=1))
     reply->rowlist[rcnt].celllist[8].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[8].string_value = " "
    ENDIF
    IF ((temp->srlist[d.seq].missing_login_loc_ind=1))
     reply->rowlist[rcnt].celllist[9].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[9].string_value = " "
    ENDIF
    reply->rowlist[rcnt].celllist[10].double_value = temp->srlist[d.seq].sr_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (rcnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,6)
 SET reply->statlist[1].statistic_meaning = "LABHIERMISSINGORG"
 SET reply->statlist[1].total_items = ((((totinst_cnt+ totgldept_cnt)+ totglsect_cnt)+ totglssect_cnt
 )+ totglbench_cnt)
 SET reply->statlist[1].qualifying_items = ((((inst_missingorg_cnt+ gldept_missingorg_cnt)+
 glsect_missingorg_cnt)+ glssect_missingorg_cnt)+ glbench_missingorg_cnt)
 IF ((reply->statlist[1].qualifying_items > 0))
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "LABHIERMISSINGDISC"
 SET reply->statlist[2].total_items = (((totgldept_cnt+ totglsect_cnt)+ totglssect_cnt)+
 totglbench_cnt)
 SET reply->statlist[2].qualifying_items = (((gldept_missingdisc_cnt+ glsect_missingdisc_cnt)+
 glssect_missingdisc_cnt)+ glbench_missingdisc_cnt)
 IF ((reply->statlist[2].qualifying_items > 0))
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].statistic_meaning = "LABHIERMISSINGACT"
 SET reply->statlist[3].total_items = ((totglsect_cnt+ totglssect_cnt)+ totglbench_cnt)
 SET reply->statlist[3].qualifying_items = ((glsect_missingact_cnt+ glssect_missingact_cnt)+
 glbench_missingact_cnt)
 IF ((reply->statlist[3].qualifying_items > 0))
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].statistic_meaning = "LABHIERMISSINGLL"
 SET reply->statlist[4].total_items = (totmultplex_cnt+ totglbench_cnt)
 SET reply->statlist[4].qualifying_items = (glbench_missingll_cnt+ multplex_missingll_cnt)
 IF ((reply->statlist[4].qualifying_items > 0))
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
 ENDIF
 SET reply->statlist[5].statistic_meaning = "LABHIERMISSINGCAL"
 SET reply->statlist[5].total_items = (totmultplex_cnt+ totglbench_cnt)
 SET reply->statlist[5].qualifying_items = (glbench_missingcal_cnt+ multplex_missingcal_cnt)
 IF ((reply->statlist[5].qualifying_items > 0))
  SET reply->statlist[5].status_flag = 3
 ELSE
  SET reply->statlist[5].status_flag = 1
 ENDIF
 SET reply->statlist[6].statistic_meaning = "LABHIERDISCMISMATCH"
 SET reply->statlist[6].total_items = ((totglsect_cnt+ totglssect_cnt)+ totglbench_cnt)
 SET reply->statlist[6].qualifying_items = ((glsect_discmismatch_cnt+ glssect_discmismatch_cnt)+
 glbench_discmismatch_cnt)
 IF ((reply->statlist[6].qualifying_items > 0))
  SET reply->statlist[6].status_flag = 3
 ELSE
  SET reply->statlist[6].status_flag = 1
 ENDIF
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("incmplt_lab_layout_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

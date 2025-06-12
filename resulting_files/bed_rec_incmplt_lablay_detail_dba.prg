CREATE PROGRAM bed_rec_incmplt_lablay_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 RECORD hold(
   1 ilist[*]
     2 inst_cd = f8
     2 inst_disp = vc
     2 inst_desc = vc
     2 missing_org_ind = i2
     2 dlist[*]
       3 dept_cd = f8
       3 dept_disp = vc
       3 dept_desc = vc
       3 missing_org_ind = i2
       3 missing_disc_type_ind = i2
       3 slist[*]
         4 sect_cd = f8
         4 sect_desc = vc
         4 sect_disp = vc
         4 missing_org_ind = i2
         4 missing_disc_type_ind = i2
         4 disc_mismatch_ind = i2
         4 missing_act_type_ind = i2
         4 sslist[*]
           5 ssect_cd = f8
           5 ssect_desc = vc
           5 ssect_disp = vc
           5 missing_org_ind = i2
           5 missing_disc_type_ind = i2
           5 disc_mismatch_ind = i2
           5 missing_act_type_ind = i2
           5 multiplexor_ind = i2
           5 missing_cal_ind = i2
           5 missing_ll_ind = i2
           5 missing_loc_ind = i2
           5 nonlab_cal_ind = i2
           5 blist[*]
             6 b_cd = f8
             6 b_desc = vc
             6 b_disp = vc
             6 b_type_cd = f8
             6 missing_org_ind = i2
             6 missing_disc_type_ind = i2
             6 disc_mismatch_ind = i2
             6 missing_act_type_ind = i2
             6 missing_cal_ind = i2
             6 missing_ll_ind = i2
             6 missing_loc_ind = i2
             6 nonlab_cal_ind = i2
 )
 RECORD temp(
   1 srlist[*]
     2 sr_desc = vc
     2 sr_disp = vc
     2 sr_cd = f8
     2 sr_type_disp = vc
     2 sr_type_cd = f8
     2 missing_org_ind = i2
     2 missing_disc_type_ind = i2
     2 disc_mismatch_ind = i2
     2 missing_act_type_ind = i2
     2 missing_calendar_ind = i2
     2 missing_login_loc_ind = i2
     2 missing_loc_ind = i2
     2 nonlab_cal_ind = i2
 )
 SET lab_ct_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
  DETAIL
   lab_ct_cd = cv.code_value
  WITH nocounter
 ;end select
 SET inst_cd = 0.0
 SET dept_cd = 0.0
 SET sect_cd = 0.0
 SET subsect_cd = 0.0
 SET bench_cd = 0.0
 SET instr_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("INSTITUTION", "DEPARTMENT", "SECTION", "SUBSECTION", "BENCH",
  "INSTRUMENT")
  DETAIL
   IF (cv.cdf_meaning="INSTITUTION")
    inst_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DEPARTMENT")
    dept_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SECTION")
    sect_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SUBSECTION")
    subsect_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BENCH")
    bench_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INSTRUMENT")
    instr_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET ap_act_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="AP"
   AND cv.active_ind=1
  DETAIL
   ap_act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ap_proc_subact_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=5801
   AND cv.cdf_meaning="APPROCESS"
   AND cv.active_ind=1
  DETAIL
   ap_proc_subact_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET check_miss_org_ind = 0
 SET check_miss_disc_type_ind = 0
 SET check_mismatch_disc_ind = 0
 SET check_miss_act_type_ind = 0
 SET check_miss_cal_ind = 0
 SET check_miss_login_loc_ind = 0
 SET check_miss_loc_ind = 0
 SET check_non_lab_ind = 0
 SET miss_org_col_nbr = 0
 SET miss_disc_type_col_nbr = 0
 SET mismatch_disc_col_nbr = 0
 SET miss_act_type_col_nbr = 0
 SET miss_cal_col_nbr = 0
 SET miss_login_loc_col_nbr = 0
 SET miss_loc_col_nbr = 0
 SET non_lab_col_nbr = 0
 SET col_cnt = (3+ plsize)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Display Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Resource Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET next_col = 3
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISSORGREL"))
    SET check_miss_org_ind = 1
    SET next_col = (next_col+ 1)
    SET miss_org_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Organization Relationships"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISSDISTYP"))
    SET check_miss_disc_type_ind = 1
    SET next_col = (next_col+ 1)
    SET miss_disc_type_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Discipline Types"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISMATCHDIS"))
    SET check_mismatch_disc_ind = 1
    SET next_col = (next_col+ 1)
    SET mismatch_disc_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Mismatched Discipline Types"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISSACTTYP"))
    SET check_miss_act_type_ind = 1
    SET next_col = (next_col+ 1)
    SET miss_act_type_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Activity Types"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISSCALENDAR"))
    SET check_miss_cal_ind = 1
    SET next_col = (next_col+ 1)
    SET miss_cal_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Calendars"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISSLOGINLOC"))
    SET check_miss_login_loc_ind = 1
    SET next_col = (next_col+ 1)
    SET miss_login_loc_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Log-In Locations"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYMISSLOC"))
    SET check_miss_loc_ind = 1
    SET next_col = (next_col+ 1)
    SET miss_loc_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Locations"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="LABLAYNONLABSRVAREA"))
    SET check_non_lab_ind = 1
    SET next_col = (next_col+ 1)
    SET non_lab_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Non-Laboratory Service Areas In Calendars"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 SET reply->run_status_flag = 1
 SET icnt = 0
 SELECT INTO "nl:"
  FROM service_resource sr,
   code_value cv,
   dummyt d1,
   resource_group rg1,
   service_resource sr1,
   code_value cv1,
   dummyt d2,
   resource_group rg2,
   service_resource sr2,
   code_value cv2,
   dummyt d3,
   resource_group rg3,
   service_resource sr3,
   code_value cv3,
   sub_section ss,
   dummyt d4,
   resource_group rg4,
   service_resource sr4,
   code_value cv4
  PLAN (sr
   WHERE sr.service_resource_type_cd=inst_cd
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd
    AND cv.active_ind=1)
   JOIN (d1)
   JOIN (rg1
   WHERE rg1.parent_service_resource_cd=cv.code_value
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
   JOIN (d2)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=cv1.code_value
    AND rg2.resource_group_type_cd=dept_cd
    AND rg2.active_ind=1)
   JOIN (sr2
   WHERE sr2.service_resource_cd=rg2.child_service_resource_cd
    AND sr2.service_resource_type_cd=sect_cd
    AND sr2.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=sr2.service_resource_cd
    AND cv2.active_ind=1)
   JOIN (d3)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=cv2.code_value
    AND rg3.resource_group_type_cd=sect_cd
    AND rg3.active_ind=1)
   JOIN (sr3
   WHERE sr3.service_resource_cd=rg3.child_service_resource_cd
    AND sr3.service_resource_type_cd=subsect_cd
    AND sr3.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=sr3.service_resource_cd
    AND cv3.active_ind=1)
   JOIN (ss
   WHERE ss.service_resource_cd=sr3.service_resource_cd)
   JOIN (d4)
   JOIN (rg4
   WHERE rg4.parent_service_resource_cd=cv3.code_value
    AND rg4.resource_group_type_cd=subsect_cd
    AND rg4.active_ind=1)
   JOIN (sr4
   WHERE sr4.service_resource_cd=rg4.child_service_resource_cd
    AND sr4.service_resource_type_cd IN (bench_cd, instr_cd)
    AND sr4.active_ind=1)
   JOIN (cv4
   WHERE cv4.code_value=sr4.service_resource_cd
    AND cv4.active_ind=1)
  ORDER BY sr.service_resource_cd, sr1.service_resource_cd, sr2.service_resource_cd,
   sr3.service_resource_cd, sr4.service_resource_cd
  HEAD sr.service_resource_cd
   IF (sr.service_resource_cd > 0)
    icnt = (icnt+ 1), stat = alterlist(hold->ilist,icnt), hold->ilist[icnt].inst_cd = sr
    .service_resource_cd,
    hold->ilist[icnt].inst_disp = cv.display, hold->ilist[icnt].inst_desc = cv.description
    IF (sr.organization_id=0)
     hold->ilist[icnt].missing_org_ind = 1
    ENDIF
    dcnt = 0
   ENDIF
  HEAD sr1.service_resource_cd
   IF (sr1.service_resource_cd > 0)
    dcnt = (dcnt+ 1), stat = alterlist(hold->ilist[icnt].dlist,dcnt), hold->ilist[icnt].dlist[dcnt].
    dept_cd = sr1.service_resource_cd,
    hold->ilist[icnt].dlist[dcnt].dept_disp = cv1.display, hold->ilist[icnt].dlist[dcnt].dept_desc =
    cv1.description
    IF (sr1.organization_id=0)
     hold->ilist[icnt].dlist[dcnt].missing_org_ind = 1
    ENDIF
    IF (sr1.discipline_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].missing_disc_type_ind = 1
    ENDIF
    scnt = 0
   ENDIF
  HEAD sr2.service_resource_cd
   IF (sr2.service_resource_cd > 0)
    scnt = (scnt+ 1), stat = alterlist(hold->ilist[icnt].dlist[dcnt].slist,scnt), hold->ilist[icnt].
    dlist[dcnt].slist[scnt].sect_cd = sr2.service_resource_cd,
    hold->ilist[icnt].dlist[dcnt].slist[scnt].sect_disp = cv2.display, hold->ilist[icnt].dlist[dcnt].
    slist[scnt].sect_desc = cv2.description
    IF (sr2.organization_id=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].missing_org_ind = 1
    ENDIF
    IF (sr2.discipline_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].missing_disc_type_ind = 1
    ENDIF
    IF (sr2.discipline_type_cd > 0
     AND sr2.discipline_type_cd != lab_ct_cd)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].disc_mismatch_ind = 1
    ENDIF
    IF (sr2.activity_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].missing_act_type_ind = 1
    ENDIF
    sscnt = 0
   ENDIF
  HEAD sr3.service_resource_cd
   IF (sr3.service_resource_cd > 0)
    sscnt = (sscnt+ 1), stat = alterlist(hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist,sscnt),
    hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].ssect_cd = sr3.service_resource_cd,
    hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].ssect_disp = cv3.display, hold->ilist[
    icnt].dlist[dcnt].slist[scnt].sslist[sscnt].ssect_desc = cv3.description, hold->ilist[icnt].
    dlist[dcnt].slist[scnt].sslist[sscnt].multiplexor_ind = ss.multiplexor_ind
    IF (sr3.organization_id=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].missing_org_ind = 1
    ENDIF
    IF (sr3.discipline_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].missing_disc_type_ind = 1
    ENDIF
    IF (sr3.discipline_type_cd > 0
     AND sr3.discipline_type_cd != lab_ct_cd)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].disc_mismatch_ind = 1
    ENDIF
    IF (sr3.activity_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].missing_act_type_ind = 1
    ENDIF
    IF (ss.multiplexor_ind=1
     AND sr3.cs_login_loc_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].missing_ll_ind = 1
    ENDIF
    IF (ss.multiplexor_ind=1
     AND sr3.location_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].missing_loc_ind = 1
    ENDIF
    bcnt = 0
   ENDIF
  HEAD sr4.service_resource_cd
   IF (sr4.service_resource_cd > 0)
    bcnt = (bcnt+ 1), stat = alterlist(hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist,
     bcnt), hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].b_cd = sr4
    .service_resource_cd,
    hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].b_disp = cv4.display, hold->
    ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].b_desc = cv4.description, hold->
    ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].b_type_cd = sr4
    .service_resource_type_cd
    IF (sr4.organization_id=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].missing_org_ind = 1
    ENDIF
    IF (sr4.discipline_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].missing_disc_type_ind = 1
    ENDIF
    IF (sr4.discipline_type_cd > 0
     AND sr4.discipline_type_cd != lab_ct_cd)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].disc_mismatch_ind = 1
    ENDIF
    IF (sr4.activity_type_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].missing_act_type_ind = 1
    ENDIF
    IF (((sr4.activity_type_cd != ap_act_type_cd
     AND sr4.cs_login_loc_cd=0) OR (sr4.activity_type_cd=ap_act_type_cd
     AND sr4.activity_subtype_cd=ap_proc_subact_type_cd
     AND sr4.cs_login_loc_cd=0)) )
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].missing_ll_ind = 1
    ENDIF
    IF (sr4.location_cd=0)
     hold->ilist[icnt].dlist[dcnt].slist[scnt].sslist[sscnt].blist[bcnt].missing_loc_ind = 1
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4
 ;end select
 SET tcnt = 0
 FOR (i = 1 TO icnt)
   IF ((hold->ilist[i].missing_org_ind=1)
    AND check_miss_org_ind=1)
    SET tcnt = (tcnt+ 1)
    SET stat = alterlist(temp->srlist,tcnt)
    SET temp->srlist[tcnt].sr_cd = hold->ilist[i].inst_cd
    SET temp->srlist[tcnt].sr_desc = hold->ilist[i].inst_desc
    SET temp->srlist[tcnt].sr_disp = hold->ilist[i].inst_disp
    SET temp->srlist[tcnt].sr_type_cd = inst_cd
    SET temp->srlist[tcnt].missing_org_ind = 1
    SET temp->srlist[tcnt].missing_disc_type_ind = 0
    SET temp->srlist[tcnt].disc_mismatch_ind = 0
    SET temp->srlist[tcnt].missing_act_type_ind = 0
    SET temp->srlist[tcnt].missing_calendar_ind = 0
    SET temp->srlist[tcnt].missing_login_loc_ind = 0
   ENDIF
   SET dcnt = size(hold->ilist[i].dlist,5)
   FOR (d = 1 TO dcnt)
     IF ((((hold->ilist[i].dlist[d].missing_org_ind=1)
      AND check_miss_org_ind=1) OR ((hold->ilist[i].dlist[d].missing_disc_type_ind=1)
      AND check_miss_disc_type_ind=1)) )
      SET tcnt = (tcnt+ 1)
      SET stat = alterlist(temp->srlist,tcnt)
      SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].dept_desc
      SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].dept_disp
      SET temp->srlist[tcnt].sr_type_cd = dept_cd
      SET temp->srlist[tcnt].missing_org_ind = hold->ilist[i].dlist[d].missing_org_ind
      SET temp->srlist[tcnt].missing_disc_type_ind = hold->ilist[i].dlist[d].missing_disc_type_ind
      SET temp->srlist[tcnt].disc_mismatch_ind = 0
      SET temp->srlist[tcnt].missing_act_type_ind = 0
      SET temp->srlist[tcnt].missing_calendar_ind = 0
      SET temp->srlist[tcnt].missing_login_loc_ind = 0
     ENDIF
     SET scnt = size(hold->ilist[i].dlist[d].slist,5)
     FOR (s = 1 TO scnt)
       IF ((((hold->ilist[i].dlist[d].slist[s].missing_org_ind=1)
        AND check_miss_org_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].missing_disc_type_ind=1)
        AND check_miss_disc_type_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].disc_mismatch_ind=1)
        AND check_mismatch_disc_ind=1) OR ((hold->ilist[i].dlist[d].slist[s].missing_act_type_ind=1)
        AND check_miss_act_type_ind=1)) )) )) )
        SET tcnt = (tcnt+ 1)
        SET stat = alterlist(temp->srlist,tcnt)
        SET temp->srlist[tcnt].sr_cd = hold->ilist[i].dlist[d].slist[s].sect_cd
        SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].slist[s].sect_desc
        SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].slist[s].sect_disp
        SET temp->srlist[tcnt].sr_type_cd = sect_cd
        SET temp->srlist[tcnt].missing_org_ind = hold->ilist[i].dlist[d].slist[s].missing_org_ind
        SET temp->srlist[tcnt].missing_disc_type_ind = hold->ilist[i].dlist[d].slist[s].
        missing_disc_type_ind
        SET temp->srlist[tcnt].disc_mismatch_ind = hold->ilist[i].dlist[d].slist[s].disc_mismatch_ind
        SET temp->srlist[tcnt].missing_act_type_ind = hold->ilist[i].dlist[d].slist[s].
        missing_act_type_ind
        SET temp->srlist[tcnt].missing_calendar_ind = 0
        SET temp->srlist[tcnt].missing_login_loc_ind = 0
       ENDIF
       SET sscnt = size(hold->ilist[i].dlist[d].slist[s].sslist,5)
       FOR (ss = 1 TO sscnt)
         IF (((check_miss_cal_ind=1) OR (check_non_lab_ind=1))
          AND (hold->ilist[i].dlist[d].slist[s].sslist[ss].multiplexor_ind=1))
          SET found_calendar = 0
          SET found_bad_calendar = 0
          SELECT INTO "nl:"
           FROM loc_resource_calendar lrc,
            location l
           PLAN (lrc
            WHERE (lrc.service_resource_cd=hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_cd)
             AND lrc.active_ind=1)
            JOIN (l
            WHERE l.location_cd=outerjoin(lrc.location_cd)
             AND lrc.active_ind=outerjoin(1))
           DETAIL
            IF (((lrc.location_cd=0) OR (lrc.location_cd > 0
             AND l.location_cd > 0)) )
             found_calendar = 1
             IF (found_bad_calendar=0
              AND lrc.location_cd > 0
              AND l.location_cd > 0
              AND l.discipline_type_cd != lab_ct_cd)
              found_bad_calendar = 1
             ENDIF
            ENDIF
           WITH nocounter
          ;end select
          IF (found_calendar=0)
           SET hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_cal_ind = 1
          ENDIF
          IF (found_bad_calendar=1)
           SET hold->ilist[i].dlist[d].slist[s].sslist[ss].nonlab_cal_ind = 1
          ENDIF
         ENDIF
         IF ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_org_ind=1)
          AND check_miss_org_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].
         missing_disc_type_ind=1)
          AND check_miss_disc_type_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].
         disc_mismatch_ind=1)
          AND check_mismatch_disc_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].
         missing_act_type_ind=1)
          AND check_miss_act_type_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].
         missing_cal_ind=1)
          AND check_miss_cal_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].missing_ll_ind
         =1)
          AND check_miss_login_loc_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].
         missing_loc_ind=1)
          AND check_miss_loc_ind=1) OR ((hold->ilist[i].dlist[d].slist[s].sslist[ss].nonlab_cal_ind=1
         )
          AND check_non_lab_ind=1)) )) )) )) )) )) )) )
          SET tcnt = (tcnt+ 1)
          SET stat = alterlist(temp->srlist,tcnt)
          SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_desc
          SET temp->srlist[tcnt].sr_cd = hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_cd
          SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].slist[s].sslist[ss].ssect_disp
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
          SET temp->srlist[tcnt].missing_loc_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          missing_loc_ind
          SET temp->srlist[tcnt].nonlab_cal_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
          nonlab_cal_ind
         ENDIF
         SET bcnt = size(hold->ilist[i].dlist[d].slist[s].sslist[ss].blist,5)
         FOR (b = 1 TO bcnt)
          IF (((check_miss_cal_ind=1) OR (check_non_lab_ind=1)) )
           SET found_calendar = 0
           SET found_bad_calendar = 0
           SELECT INTO "nl:"
            FROM loc_resource_calendar lrc,
             location l
            PLAN (lrc
             WHERE (lrc.service_resource_cd=hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].b_cd
             )
              AND lrc.active_ind=1)
             JOIN (l
             WHERE l.location_cd=outerjoin(lrc.location_cd)
              AND l.active_ind=outerjoin(1))
            DETAIL
             IF (((lrc.location_cd=0) OR (lrc.location_cd > 0
              AND l.location_cd > 0)) )
              found_calendar = 1
              IF (found_bad_calendar=0
               AND lrc.location_cd > 0
               AND l.location_cd > 0
               AND l.discipline_type_cd != lab_ct_cd)
               found_bad_calendar = 1
              ENDIF
             ENDIF
            WITH nocounter
           ;end select
           IF (found_calendar=0)
            SET hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_cal_ind = 1
           ENDIF
           IF (found_bad_calendar=1)
            SET hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].nonlab_cal_ind = 1
           ENDIF
          ENDIF
          IF ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].missing_org_ind=1)
           AND check_miss_org_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
          missing_disc_type_ind=1)
           AND check_miss_disc_type_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b
          ].disc_mismatch_ind=1)
           AND check_mismatch_disc_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b]
          .missing_act_type_ind=1)
           AND check_miss_act_type_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b]
          .missing_cal_ind=1)
           AND check_miss_cal_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
          missing_ll_ind=1)
           AND check_miss_login_loc_ind=1) OR ((((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b
          ].missing_loc_ind=1)
           AND check_miss_loc_ind=1) OR ((hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
          nonlab_cal_ind=1)
           AND check_non_lab_ind=1)) )) )) )) )) )) )) )
           SET tcnt = (tcnt+ 1)
           SET stat = alterlist(temp->srlist,tcnt)
           SET temp->srlist[tcnt].sr_cd = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].b_cd
           SET temp->srlist[tcnt].sr_desc = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
           b_desc
           SET temp->srlist[tcnt].sr_disp = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
           b_disp
           SET temp->srlist[tcnt].sr_type_cd = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[b].
           b_type_cd
           SET temp->srlist[tcnt].missing_org_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
           blist[b].missing_org_ind
           SET temp->srlist[tcnt].missing_disc_type_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss]
           .blist[b].missing_disc_type_ind
           SET temp->srlist[tcnt].disc_mismatch_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
           blist[b].disc_mismatch_ind
           SET temp->srlist[tcnt].missing_act_type_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
           blist[b].missing_act_type_ind
           SET temp->srlist[tcnt].missing_calendar_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
           blist[b].missing_cal_ind
           SET temp->srlist[tcnt].missing_login_loc_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss]
           .blist[b].missing_ll_ind
           SET temp->srlist[tcnt].missing_loc_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].
           blist[b].missing_loc_ind
           SET temp->srlist[tcnt].nonlab_cal_ind = hold->ilist[i].dlist[d].slist[s].sslist[ss].blist[
           b].nonlab_cal_ind
          ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET rcnt = 0
 IF (tcnt > 0)
  SELECT INTO "nl:"
   sr_disp = cnvtupper(temp->srlist[d.seq].sr_disp), sr_type_disp = cv.display_key, sr_cd = temp->
   srlist[d.seq].sr_cd
   FROM (dummyt d  WITH seq = tcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->srlist[d.seq].sr_type_cd)
     AND cv.active_ind=1
     AND cv.code_set=223)
   ORDER BY sr_disp, sr_type_disp, sr_cd
   HEAD sr_cd
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp->srlist[d.seq].sr_disp, reply->rowlist[rcnt]
    .celllist[2].string_value = temp->srlist[d.seq].sr_desc, reply->rowlist[rcnt].celllist[3].
    string_value = cv.display
    IF ((temp->srlist[d.seq].missing_org_ind=1)
     AND check_miss_org_ind=1)
     reply->rowlist[rcnt].celllist[miss_org_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].missing_disc_type_ind=1)
     AND check_miss_disc_type_ind=1)
     reply->rowlist[rcnt].celllist[miss_disc_type_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].disc_mismatch_ind=1)
     AND check_mismatch_disc_ind=1)
     reply->rowlist[rcnt].celllist[mismatch_disc_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].missing_act_type_ind=1)
     AND check_miss_act_type_ind=1)
     reply->rowlist[rcnt].celllist[miss_act_type_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].missing_calendar_ind=1)
     AND check_miss_cal_ind=1)
     reply->rowlist[rcnt].celllist[miss_cal_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].missing_login_loc_ind=1)
     AND check_miss_login_loc_ind=1)
     reply->rowlist[rcnt].celllist[miss_login_loc_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].missing_loc_ind=1)
     AND check_miss_loc_ind=1)
     reply->rowlist[rcnt].celllist[miss_loc_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->srlist[d.seq].nonlab_cal_ind=1)
     AND check_non_lab_ind=1)
     reply->rowlist[rcnt].celllist[non_lab_col_nbr].string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO

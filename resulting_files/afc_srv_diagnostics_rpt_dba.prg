CREATE PROGRAM afc_srv_diagnostics_rpt:dba
 FREE SET srv_diag_cs
 RECORD srv_diag_cs(
   1 not_at_chrg_pnt = f8
   1 no_pnt_item = f8
   1 no_pnt_tier = f8
   1 not_at_chrg_lvl = f8
   1 no_chrg_ind = f8
   1 no_tier_for_org = f8
   1 no_phleb_chrg = f8
 )
 FREE SET diag_info
 RECORD diag_info(
   1 event_count = i4
   1 charge_events[*]
     2 charge_event_id = f8
     2 master_event_id = f8
     2 master_ref_id = f8
     2 master_cont_cd = f8
     2 parent_ref_id = f8
     2 parent_cont_cd = f8
     2 item_ref_id = f8
     2 item_cont_cd = f8
     2 accession = c50
     2 order_id = f8
     2 person_id = f8
     2 person_name = c50
     2 encntr_id = f8
     2 coll_priority_cd = f8
     2 rpt_priority_cd = f8
     2 perf_loc_cd = f8
     2 act_count = i4
     2 charge_acts[*]
       3 charge_act_id = f8
       3 cea_type_cd = f8
       3 cea_prsnl_id = f8
       3 cea_first_name = vc
       3 cea_last_name = vc
       3 service_dt = c10
       3 service_tm = c5
       3 srv_resc_cd = f8
       3 srv_diag_cd = f8
       3 srv_diag1_id = f8
       3 srv_diag2_id = f8
       3 srv_diag3_id = f8
       3 srv_diag4_id = f8
 )
 FREE SET output
 RECORD output(
   1 lines = i4
   1 dashed_line = c131
   1 double_line = c131
   1 star_line = c131
   1 blank_line = c131
 )
 FREE SET outtable
 RECORD outtable(
   1 message = c131
 )
 SUBROUTINE initialize(dummy)
   DECLARE codeset = i4
   DECLARE meaning = c12
   DECLARE index = i4
   DECLARE codevalue = f8
   DECLARE iret = i4
   SET codeset = 18269
   SET meaning = "NOTATCHRGPNT"
   SET index = 1
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET srv_diag_cs->not_at_chrg_pnt = - (1)
   IF (iret=0)
    SET srv_diag_cs->not_at_chrg_pnt = codevalue
   ENDIF
   SET meaning = "NOPNTONITEM"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET srv_diag_cs->no_pnt_item = - (1)
   IF (iret=0)
    SET srv_diag_cs->no_pnt_item = codevalue
   ENDIF
   SET meaning = "NOPNTONTIER"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET srv_diag_cs->no_pnt_tier = - (1)
   IF (iret=0)
    SET srv_diag_cs->no_pnt_tier = codevalue
   ENDIF
   SET meaning = "NOTATCHRGLVL"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET srv_diag_cs->not_at_chrg_lvl = - (1)
   IF (iret=0)
    SET srv_diag_cs->not_at_chrg_lvl = codevalue
   ENDIF
   SET meaning = "NOCHARGEIND"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET srv_diag_cs->no_chrg_ind = - (1)
   IF (iret=0)
    SET srv_diag_cs->no_chrg_ind = codevalue
   ENDIF
   SET meaning = "NOTIERFORORG"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET srv_diag_cs->no_tier_for_org = - (1)
   IF (iret=0)
    SET srv_diag_cs->no_tier_for_org = codevalue
   ENDIF
   SET output->dashed_line = fillstring(132,"-")
   SET output->double_line = fillstring(132,"=")
   SET output->star_line = fillstring(132,"*")
   SET output->blank_line = fillstring(132," ")
 END ;Subroutine
 SUBROUTINE readdiaginfo(dummy)
   SET event_count = 0
   SELECT INTO "nl:"
    c.charge_event_id, c.ext_m_event_id, c.order_id,
    c.accession, c.person_id, c.encntr_id,
    c.perf_loc_cd, p.name_full_formatted
    FROM charge_event c,
     person p,
     (dummyt d1  WITH seq = value(diag_request->master_qual))
    PLAN (d1)
     JOIN (c
     WHERE (c.ext_m_event_id=diag_request->master_list[d1.seq].master_event_id))
     JOIN (p
     WHERE p.person_id=c.person_id)
    ORDER BY c.ext_m_event_id, c.charge_event_id
    DETAIL
     diag_info->event_count += 1, event_count = diag_info->event_count, stat = alterlist(diag_info->
      charge_events,event_count),
     diag_info->charge_events[event_count].charge_event_id = c.charge_event_id, diag_info->
     charge_events[event_count].master_event_id = c.ext_m_event_id, diag_info->charge_events[
     event_count].master_ref_id = c.ext_m_reference_id,
     diag_info->charge_events[event_count].master_cont_cd = c.ext_m_reference_cont_cd, diag_info->
     charge_events[event_count].parent_ref_id = c.ext_p_reference_id, diag_info->charge_events[
     event_count].parent_cont_cd = c.ext_p_reference_cont_cd,
     diag_info->charge_events[event_count].item_ref_id = c.ext_i_reference_id, diag_info->
     charge_events[event_count].item_cont_cd = c.ext_i_reference_cont_cd, diag_info->charge_events[
     event_count].order_id = c.order_id,
     diag_info->charge_events[event_count].accession = c.accession, diag_info->charge_events[
     event_count].person_id = c.person_id, diag_info->charge_events[event_count].encntr_id = c
     .encntr_id,
     diag_info->charge_events[event_count].coll_priority_cd = c.collection_priority_cd, diag_info->
     charge_events[event_count].rpt_priority_cd = c.report_priority_cd, diag_info->charge_events[
     event_count].perf_loc_cd = c.perf_loc_cd,
     diag_info->charge_events[event_count].person_name = p.name_full_formatted
    WITH nocounter
   ;end select
   SET act_count = 0
   SELECT INTO "nl:"
    ca.charge_event_act_id, ca.cea_type_cd, ca.cea_prsnl_id,
    ca.service_dt_tm, ca.srv_diag_cd, ca.srv_diag1_id,
    ca.srv_diag2_id, ca.srv_diag3_id, ca.srv_diag4_id
    FROM charge_event_act ca,
     (dummyt d1  WITH seq = value(diag_info->event_count))
    PLAN (d1)
     JOIN (ca
     WHERE (ca.charge_event_id=diag_info->charge_events[d1.seq].charge_event_id))
    DETAIL
     diag_info->charge_events[d1.seq].act_count += 1, act_count = diag_info->charge_events[d1.seq].
     act_count, stat = alterlist(diag_info->charge_events[d1.seq].charge_acts,act_count),
     diag_info->charge_events[d1.seq].charge_acts[act_count].charge_act_id = ca.charge_event_act_id,
     diag_info->charge_events[d1.seq].charge_acts[act_count].cea_type_cd = ca.cea_type_cd, diag_info
     ->charge_events[d1.seq].charge_acts[act_count].cea_prsnl_id = ca.cea_prsnl_id,
     diag_info->charge_events[d1.seq].charge_acts[act_count].service_dt = format(ca.service_dt_tm,
      "mm/dd/yyyy;;d"), diag_info->charge_events[d1.seq].charge_acts[act_count].service_tm = format(
      ca.service_dt_tm,"hh:mm;;m"), diag_info->charge_events[d1.seq].charge_acts[act_count].
     srv_resc_cd = ca.service_resource_cd,
     diag_info->charge_events[d1.seq].charge_acts[act_count].srv_diag_cd = ca.srv_diag_cd, diag_info
     ->charge_events[d1.seq].charge_acts[act_count].srv_diag1_id = ca.srv_diag1_id, diag_info->
     charge_events[d1.seq].charge_acts[act_count].srv_diag2_id = ca.srv_diag2_id,
     diag_info->charge_events[d1.seq].charge_acts[act_count].srv_diag3_id = ca.srv_diag3_id,
     diag_info->charge_events[d1.seq].charge_acts[act_count].srv_diag4_id = ca.srv_diag4_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE writelinetotable(first_time)
   IF (first_time=1)
    SELECT INTO TABLE afc_srv_diag
     afc_diagnostics = outtable->message
    ;end select
   ELSE
    SELECT INTO TABLE afc_srv_diag
     afc_diagnostics = outtable->message
     WITH append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE notatchargepoint("INTEXT")
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ",uar_get_code_description(diag_info->
     charge_events[event].charge_acts[act].srv_diag_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge Point Schedule: ",uar_get_code_display(diag_info->
     charge_events[event].charge_acts[act].srv_diag1_id))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge Point on Item:  ",uar_get_code_display(diag_info->
     charge_events[event].charge_acts[act].srv_diag2_id))
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
 END ;Subroutine
 SUBROUTINE nopointonitem("INTEXT")
   SET parent = fillstring(30," ")
   SET unique_item = fillstring(30," ")
   SET unique_ind = 0
   SET default = fillstring(30," ")
   SET default_ind = 0
   IF (pid=0
    AND pcd=0
    AND cid > 0
    AND ccd > 0)
    SET default_ind = 1
    SET unique_ind = 1
    SET default = bill_item
    SELECT INTO "nl:"
     FROM bill_item bi
     WHERE (bi.ext_parent_reference_id=diag_info->charge_events[event].master_ref_id)
      AND (bi.ext_parent_contributor_cd=diag_info->charge_events[event].master_cont_cd)
     DETAIL
      IF (bi.ext_child_reference_id=0
       AND bi.ext_child_contributor_cd=0)
       parent = bi.ext_description
      ELSEIF (bi.ext_child_reference_id=cid
       AND bi.ext_child_contributor_cd=ccd)
       unique_item = bi.ext_description
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (pid > 0
    AND pcd > 0
    AND cid > 0
    AND ccd > 0)
    SET unique_ind = 1
    SET unique_item = bill_item
    SELECT INTO "nl:"
     FROM bill_item bi
     WHERE bi.ext_parent_reference_id=pid
      AND bi.ext_parent_contributor_cd=pcd
      AND bi.ext_child_reference_id=0
      AND bi.ext_child_contributor_cd=0
     DETAIL
      parent = bi.ext_description
     WITH nocounter
    ;end select
   ELSE
    SET parent = bill_item
   ENDIF
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ",uar_get_code_description(diag_info->
     charge_events[event].charge_acts[act].srv_diag_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge Point Schedule: ",uar_get_code_display(diag_info->
     charge_events[event].charge_acts[act].srv_diag1_id))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Item:                  ",ext_owner)
   CALL writelinetotable(0)
   SET outtable->message = concat(fillstring(30," "),"---> ",parent)
   CALL writelinetotable(0)
   IF (unique_ind=1)
    SET outtable->message = concat(fillstring(38," "),"--->",unique_item)
    CALL writelinetotable(0)
    IF (default_ind=1)
     SET outtable->message = concat(fillstring(46," "),"--->",default)
     CALL writelinetotable(0)
    ENDIF
   ENDIF
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET parent
   FREE SET unique_item
   FREE SET unique_ind
   FREE SET default
   FREE SET default_ind
 END ;Subroutine
 SUBROUTINE filltierinfo(fin_cd,admit_cd,org_id,pat_cd,loc_cd,rpt_cd,coll_cd,srv_cd,act_cd,perf_cd)
   SET fin_class = fillstring(20," ")
   SET admit_type = fillstring(20," ")
   SET organization_name = fillstring(20," ")
   SET pat_loc = fillstring(20," ")
   SET order_loc = fillstring(20," ")
   SET rpt_priority = fillstring(20," ")
   SET coll_priority = fillstring(20," ")
   SET serv_rescource = fillstring(20," ")
   SET activity = fillstring(20," ")
   SET perf_loc = fillstring(20," ")
   IF (org_id > 0)
    SELECT INTO "nl"
     o.org_name
     FROM organization o
     WHERE o.organization_id=org_id
     DETAIL
      organization_name = o.org_name
     WITH nocounter
    ;end select
   ELSE
    SET organization_name = "-"
   ENDIF
   IF (fin_cd > 0)
    SET fin_class = uar_get_code_display(cnvtreal(fin_cd))
   ELSE
    SET fin_class = "-"
   ENDIF
   IF (admit_cd > 0)
    SET admit_type = uar_get_code_display(cnvtreal(admit_cd))
   ELSE
    SET admit_type = "-"
   ENDIF
   IF (pat_cd > 0)
    SET pat_loc = uar_get_code_display(cnvtreal(pat_cd))
   ELSE
    SET pat_loc = "-"
   ENDIF
   IF (loc_cd > 0)
    SET order_loc = uar_get_code_display(cnvtreal(loc_cd))
   ELSE
    SET order_loc = "-"
   ENDIF
   IF (srv_cd > 0)
    SET serv_resource = uar_get_code_display(cnvtreal(srv_cd))
   ELSE
    SET serv_resource = "-"
   ENDIF
   IF (coll_cd > 0)
    SET coll_priority = uar_get_code_display(cnvtreal(coll_cd))
   ELSE
    SET coll_priority = "-"
   ENDIF
   IF (rpt_cd > 0)
    SET rpt_priority = uar_get_code_display(cnvtreal(rpt_cd))
   ELSE
    SET rpt_priority = "-"
   ENDIF
   IF (act_cd > 0)
    SET activity = uar_get_code_display(cnvtreal(act_cd))
   ELSE
    SET activity = "-"
   ENDIF
   IF (perf_cd > 0)
    SET perf_loc = uar_get_code_display(cnvtreal(perf_cd))
   ELSE
    SET perf_loc = "-"
   ENDIF
   SET out_line = concat("    ",format(fin_class,"###############;;C")," ",format(admit_type,
     "####;;C")," ",
    format(organization_name,"###################;;C")," ",format(order_loc,"#########;;C")," ",
    format(serv_resource,"#########;;C"),
    " ",format(rpt_priority,"#########;;C")," ",format(pat_loc,"#########;;C")," ",
    format(coll_priority,"###########;;C")," ",format(perf_loc,"##########;;C")," ",format(activity,
     "###########;;C"))
   FREE SET fin_class
   FREE SET admit_type
   FREE SET organization_name
   FREE SET order_loc
   FREE SET serv_resource
   FREE SET rpt_priority
   FREE SET pat_loc
   FREE SET coll_priority
   FREE SET perf_loc
   FREE SET activity
 END ;Subroutine
 SUBROUTINE nopointontier("INTEXT")
   SET fin_class_cd = 0.0
   SET encntr_type_cd = 0.0
   SET pat_loc_cd = 0.0
   SET out_line = fillstring(120," ")
   SET matched = fillstring(3," ")
   SET order_loc_cd = 0.0
   SELECT INTO "nl:"
    e.financial_class_cd, e.encntr_type_cd, e.loc_nurse_unit_cd
    FROM encounter e
    WHERE (e.encntr_id=diag_info->charge_events[event].encntr_id)
    DETAIL
     fin_class_cd = e.financial_class_cd, encntr_type_cd = e.encntr_type_cd, pat_loc_cd = e
     .loc_nurse_unit_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ca.service_loc_cd
    FROM charge_event_act ca
    WHERE (ca.charge_event_id=diag_info->charge_events[event].charge_event_id)
     AND uar_get_code_meaning(ca.cea_type_cd)="ORDERED"
    DETAIL
     order_loc_cd = ca.service_loc_cd
    WITH nocounter
   ;end select
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ",uar_get_code_description(diag_info->
     charge_events[event].charge_acts[act].srv_diag_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Tier Group:            ",uar_get_code_display(diag_info->
     charge_events[event].charge_acts[act].srv_diag2_id))
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   SET outtable->message = "    Qualifying Information"
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   SET outtable->message =
   "    Financial      Admit                     Order     Service   Report    Patient   Collection  Performing Activity"
   CALL writelinetotable(0)
   SET outtable->message =
   "    Class          Type  Organization        Location  Resource  Priority  Location  Priority    Location   Type"
   CALL writelinetotable(0)
   SET outtable->message = concat("    ",output->dashed_line)
   CALL writelinetotable(0)
   CALL filltierinfo(fin_class_cd,encntr_type_cd,diag_info->charge_events[event].charge_acts[act].
    srv_diag1_id,pat_loc_cd,order_loc_cd,
    diag_info->charge_events[event].rpt_priority_cd,diag_info->charge_events[event].coll_priority_cd,
    diag_info->charge_events[event].charge_acts[act].srv_resc_cd,diag_info->charge_events[event].
    charge_acts[act].srv_diag3_id,diag_info->charge_events[event].perf_loc_cd)
   SET outtable->message = out_line
   CALL writelinetotable(0)
   SET outtable->message = concat("    ",output->dashed_line)
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET tier_list
   RECORD tier_list(
     1 tier_row[*]
       2 row_num = i4
       2 fin_class_cd = f8
       2 admit_type_cd = f8
       2 organization_id = f8
       2 ord_loc_cd = f8
       2 srv_resc_cd = f8
       2 rpt_priority_cd = f8
       2 pat_loc_cd = f8
       2 coll_priority_cd = f8
       2 perf_loc_cd = f8
       2 activity_type_cd = f8
   )
   SET row_num = 0
   SELECT INTO "nl:"
    tm.*
    FROM tier_matrix tm
    WHERE (tm.tier_group_cd=diag_info->charge_events[event].charge_acts[act].srv_diag2_id)
     AND tm.active_ind=1
    ORDER BY tm.tier_row_num
    DETAIL
     IF (row_num != tm.tier_row_num)
      row_num = tm.tier_row_num, stat = alterlist(tier_list->tier_row,row_num), tier_list->tier_row[
      row_num].row_num = row_num
     ENDIF
     IF (uar_get_code_meaning(tm.tier_cell_type_cd)="FIN CLASS")
      tier_list->tier_row[row_num].fin_class_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="VISITTYPE")
      tier_list->tier_row[row_num].admit_type_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="ORG")
      tier_list->tier_row[row_num].organization_id = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="ORD LOC")
      tier_list->tier_row[row_num].ord_loc_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="SERVICERES")
      tier_list->tier_row[row_num].srv_resc_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="RPT PRIORITY")
      tier_list->tier_row[row_num].rpt_priority_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="PAT LOC")
      tier_list->tier_row[row_num].pat_loc_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="COLL PRRIORITY")
      tier_list->tier_row[row_num].coll_priority_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="PERF LOC")
      tier_list->tier_row[row_num].perf_loc_cd = tm.tier_cell_value_id
     ELSEIF (uar_get_code_meaning(tm.tier_cell_type_cd)="ACTCODE")
      tier_list->tier_row[row_num].activity_type_cd = tm.tier_cell_value_id
     ENDIF
    WITH nocounter
   ;end select
   SET outtable->message = "    Tier Information"
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   SET outtable->message =
   "    Financial      Admit                     Order     Service   Report    Patient   Collection  Performing Activity"
   CALL writelinetotable(0)
   SET outtable->message =
   "    Class          Type  Organization        Location  Resource  Priority  Location  Priority    Location   Type         Match"
   CALL writelinetotable(0)
   SET outtable->message = concat("    ",output->dashed_line)
   CALL writelinetotable(0)
   SET loop_count = 0
   FOR (loop_count = 1 TO row_num)
     SET matched = "YES"
     IF ((tier_list->tier_row[loop_count].fin_class_cd > 0))
      IF ((tier_list->tier_row[loop_count].fin_class_cd != fin_class_cd))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].admit_type_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].admit_type_cd != encntr_type_cd))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].organization_id > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].organization_id != diag_info->charge_events[event].
      charge_acts[act].srv_diag1_id))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].pat_loc_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].pat_loc_cd != pat_loc_cd))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].ord_loc_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].ord_loc_cd != order_loc_cd))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].rpt_priority_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].rpt_priority_cd != diag_info->charge_events[event].
      rpt_priority_cd))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].coll_priority_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].coll_priority_cd != diag_info->charge_events[event].
      coll_priority_cd))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].srv_resc_cd > 0)
      AND matched="YES")
      SET matched = "NO"
      SET child_cd = diag_info->charge_events[event].charge_acts[act].srv_resc_cd
      IF ((tier_list->tier_row[loop_count].srv_resc_cd=child_cd))
       SET matched = "YES"
       SET found = 1
      ELSE
       SET found = 0
      ENDIF
      WHILE (found=0)
       SET found = 1
       SELECT INTO "nl:"
        rg.parent_service_resource_cd
        FROM resource_group rg
        WHERE rg.child_service_resource_cd=child_cd
        DETAIL
         IF ((rg.parent_service_resource_cd=tier_list->tier_row[loop_count].srv_resc_cd))
          matched = "YES"
         ELSE
          found = 0, child_cd = rg.parent_service_resource_cd
         ENDIF
        WITH nocounter
       ;end select
      ENDWHILE
     ENDIF
     IF ((tier_list->tier_row[loop_count].activity_type_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].activity_type_cd != diag_info->charge_events[event].
      charge_acts[act].srv_diag3_id))
       SET matched = "NO"
      ENDIF
     ENDIF
     IF ((tier_list->tier_row[loop_count].perf_loc_cd > 0)
      AND matched="YES")
      IF ((tier_list->tier_row[loop_count].perf_loc_cd != diag_info->charge_events[event].perf_loc_cd
      ))
       SET matched = "NO"
      ENDIF
     ENDIF
     CALL filltierinfo(tier_list->tier_row[loop_count].fin_class_cd,tier_list->tier_row[loop_count].
      admit_type_cd,tier_list->tier_row[loop_count].organization_id,tier_list->tier_row[loop_count].
      pat_loc_cd,tier_list->tier_row[loop_count].ord_loc_cd,
      tier_list->tier_row[loop_count].rpt_priority_cd,tier_list->tier_row[loop_count].
      coll_priority_cd,tier_list->tier_row[loop_count].srv_resc_cd,tier_list->tier_row[loop_count].
      activity_type_cd,tier_list->tier_row[loop_count].perf_loc_cd)
     SET outtable->message = concat(out_line," ",matched)
     CALL writelinetotable(0)
   ENDFOR
   SET outtable->message = concat("    ",output->dashed_line)
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET tier_list
   FREE SET fin_class_cd
   FREE SET pat_loc_cd
   FREE SET encntr_type_cd
   FREE SET out_line
   FREE SET matched
   FREE SET order_loc_cd
   FREE SET row_num
   FREE SET loop_count
 END ;Subroutine
 SUBROUTINE notatchargelevel("INTEXT")
   SET this_item = concat("    Item:                  ")
   SET parent = fillstring(50," ")
   SET parent_owner = fillstring(50," ")
   SET parent_level = fillstring(50," ")
   SET parent_ind = 0
   SET charge_level = fillstring(50," ")
   SET parent_item = fillstring(30," ")
   SET unique_item = fillstring(30," ")
   SET unique_ind = 0
   SET default = fillstring(30," ")
   SET default_ind = 0
   IF ((bill_id != diag_info->charge_events[event].charge_acts[act].srv_diag3_id))
    SET this_item = concat("    Child Item:            ")
    SET parent_ind = 1
    SELECT INTO "nl:"
     bi.ext_description, bi.ext_owner_cd, bim.key4_id
     FROM bill_item bi,
      bill_item_modifier bim
     PLAN (bi
      WHERE (bi.bill_item_id=diag_info->charge_events[event].charge_acts[act].srv_diag3_id))
      JOIN (bim
      WHERE (bim.bill_item_id=diag_info->charge_events[event].charge_acts[act].srv_diag3_id)
       AND (bim.key1_id=diag_info->charge_events[event].charge_acts[act].srv_diag1_id)
       AND bim.active_ind=1)
     DETAIL
      parent_owner = uar_get_code_display(bi.ext_owner_cd), parent = bi.ext_description, parent_level
       = uar_get_code_display(bim.key4_id)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    bim.key4_id
    FROM bill_item_modifier bim
    WHERE bim.bill_item_id=bill_id
     AND (bim.key1_id=diag_info->charge_events[event].charge_acts[act].srv_diag1_id)
     AND bim.active_ind=1
    DETAIL
     charge_level = uar_get_code_display(bim.key4_id)
    WITH nocounter
   ;end select
   IF (pid=0
    AND pcd=0
    AND cid > 0
    AND ccd > 0)
    SET default_ind = 1
    SET unique_ind = 1
    SET default = concat(format(bill_item,"####################;;C"),charge_level)
    SELECT INTO "nl:"
     FROM bill_item bi
     WHERE (bi.ext_parent_reference_id=diag_info->charge_events[event].master_ref_id)
      AND (bi.ext_parent_contributor_cd=diag_info->charge_events[event].master_cont_cd)
     DETAIL
      IF (bi.ext_child_reference_id=0
       AND bi.ext_child_contributor_cd=0)
       parent_item = bi.ext_description
      ELSEIF (bi.ext_child_reference_id=cid
       AND bi.ext_child_contributor_cd=ccd)
       unique_item = bi.ext_description
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (pid > 0
    AND pcd > 0
    AND cid > 0
    AND ccd > 0)
    SET unique_ind = 1
    SET unique_item = concat(format(bill_item,"####################;;C"),charge_level)
    SELECT INTO "nl:"
     FROM bill_item bi
     WHERE bi.ext_parent_reference_id=pid
      AND bi.ext_parent_contributor_cd=pcd
      AND bi.ext_child_reference_id=0
      AND bi.ext_child_contributor_cd=0
     DETAIL
      parent_item = bi.ext_description
     WITH nocounter
    ;end select
   ELSE
    SET parent_item = concat(format(bill_item,"####################;;C"),charge_level)
   ENDIF
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ",uar_get_code_description(diag_info->
     charge_events[event].charge_acts[act].srv_diag_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge Point Schedule: ",uar_get_code_display(diag_info->
     charge_events[event].charge_acts[act].srv_diag1_id))
   CALL writelinetotable(0)
   IF (parent_ind=1)
    SET outtable->message = concat("    Parent Item:           ",parent_owner)
    CALL writelinetotable(0)
    SET outtable->message = concat(fillstring(30," "),"---> ",format(parent,"####################;;C"
      ),parent_level)
    CALL writelinetotable(0)
   ENDIF
   SET outtable->message = concat(this_item,ext_owner)
   CALL writelinetotable(0)
   SET outtable->message = concat(fillstring(30," "),"---> ",parent_item)
   CALL writelinetotable(0)
   IF (unique_ind=1)
    SET outtable->message = concat(fillstring(38," "),"---> ",unique_item)
    CALL writelinetotable(0)
    IF (default_ind=1)
     SET outtable->message = concat(fillstring(46," "),"---> ",default_item)
     CALL writelinetotable(0)
    ENDIF
   ENDIF
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET this_item
   FREE SET parent
   FREE SET parent_item
   FREE SET parent_owner
   FREE SET parent_ind
   FREE SET parent_level
   FREE SET charge_level
   FREE SET unique_item
   FREE SET unique_ind
   FREE SET default
   FREE SET default_ind
 END ;Subroutine
 SUBROUTINE nochargeind("INTEXT")
   SET price_schedule = fillstring(100," ")
   SELECT INTO "nl:"
    ps.price_sched_desc
    FROM price_sched ps
    WHERE (ps.price_sched_id=diag_info->charge_events[event].charge_acts[act].srv_diag1_id)
    DETAIL
     price_schedule = ps.price_sched_desc
    WITH nocounter
   ;end select
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ",uar_get_code_description(diag_info->
     charge_events[event].charge_acts[act].srv_diag_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Price Schedule:        ",price_schedule)
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET price_schedule
 END ;Subroutine
 SUBROUTINE notierfororg("INTEXT")
   SET organization_name = fillstring(100," ")
   SELECT INTO "nl"
    o.org_name
    FROM organization o
    WHERE (o.organization_id=diag_info->charge_events[event].charge_acts[act].srv_diag1_id)
    DETAIL
     organization_name = o.org_name
    WITH nocounter
   ;end select
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ",uar_get_code_description(diag_info->
     charge_events[event].charge_acts[act].srv_diag_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Organization:          ",organization_name)
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET organization_name
 END ;Subroutine
 SUBROUTINE nophlebchrg("INTEXT")
   SET phlebotomy_charging = fillstring(3," ")
   SET phleb_group_ind = fillstring(40," ")
   SELECT INTO "nl:"
    p.name_last, p.name_first
    FROM person p
    WHERE (p.person_id=diag_info->charge_events[event].charge_acts[act].cea_prsnl_id)
    DETAIL
     diag_info->charge_events[event].charge_acts[act].cea_first_name = p.name_first, diag_info->
     charge_events[event].charge_acts[act].cea_last_name = p.name_last
    WITH nocounter
   ;end select
   IF ((diag_info->charge_events[event].charge_acts[act].srv_diag1_id=0))
    SET phlebotomy_charging = "OFF"
   ELSE
    SET phlebotomy_charging = "ON"
   ENDIF
   IF ((diag_info->charge_events[event].charge_acts[act].srv_diag2_id=0))
    SET phleb_group_ind = " is not in the phlebotomy group."
   ELSE
    SET phleb_group_ind = " is in the phlebotomy group."
   ENDIF
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   SET outtable->message = concat("    Reason:                ","Phlebotomy Charging is ",
    phlebotomy_charging," and ",diag_info->charge_events[event].charge_acts[act].cea_first_name,
    " ",diag_info->charge_events[event].charge_acts[act].cea_last_name,phleb_group_ind)
   CALL writelinetotable(0)
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET phelbotomy_charging
   FREE SET phleb_group_ind
 END ;Subroutine
 SUBROUTINE noreason("INTEXT")
   FREE SET charge_list
   RECORD charge_list(
     1 charges[10]
       2 charge_item_id = f8
       2 status = c17
       2 description = c22
       2 service_dt = c10
       2 service_tm = c5
       2 charge_type_cd = f8
       2 admit_type_cd = f8
       2 tier_group_cd = f8
       2 department = c50
       2 organization = c50
       2 manual = c5
   )
   SET charge = 0
   SELECT INTO "nl:"
    c.charge_item_id, c.process_flg, c.charge_description,
    c.service_dt_tm
    FROM charge c,
     organization o
    PLAN (c
     WHERE (c.charge_event_id=diag_info->charge_events[event].charge_event_id))
     JOIN (o
     WHERE o.organization_id=c.payor_id)
    DETAIL
     charge += 1, charge_list->charges[charge].charge_item_id = c.charge_item_id, charge_list->
     charges[charge].description = c.charge_description,
     charge_list->charges[charge].charge_type_cd = c.charge_type_cd, charge_list->charges[charge].
     admit_type_cd = c.admit_type_cd, charge_list->charges[charge].tier_group_cd = c.tier_group_cd
     IF (c.department_cd > 0)
      charge_list->charges[charge].department = uar_get_code_display(c.department_cd)
     ELSE
      charge_list->charges[charge].department = "-"
     ENDIF
     IF (c.manual_ind=0)
      charge_list->charges[charge].manual = "NO"
     ELSE
      charge_list->charges[charge].manual = "YES"
     ENDIF
     charge_list->charges[charge].organization = o.org_name, charge_list->charges[charge].service_dt
      = format(c.service_dt_tm,"mm/dd/yyyy;;d"), charge_list->charges[charge].service_tm = format(c
      .service_dt_tm,"hh:mm;;m")
     CASE (c.process_flg)
      OF 0:
       charge_list->charges[charge].status = "Pending"
      OF 1:
       charge_list->charges[charge].status = "Suspended"
      OF 2:
       charge_list->charges[charge].status = "Review"
      OF 3:
       charge_list->charges[charge].status = "On Hold"
      OF 4:
       charge_list->charges[charge].status = "Manual"
      OF 5:
       charge_list->charges[charge].status = "Skipped"
      OF 6:
       charge_list->charges[charge].status = "Combined"
      OF 7:
       charge_list->charges[charge].status = "Absorbed"
      OF 10:
       charge_list->charges[charge].status = "Offset"
      OF 11:
       charge_list->charges[charge].status = "Adjusted"
      OF 12:
       charge_list->charges[charge].status = "Grouped"
      OF 997:
       charge_list->charges[charge].status = "Stats Only"
      OF 999:
       charge_list->charges[charge].status = "Interfaced"
      ELSE
       charge_list->charges[charge].status = "Unknown"
     ENDCASE
    WITH nocounter
   ;end select
   SET outtable->message = concat("  Event:  ",uar_get_code_display(diag_info->charge_events[event].
     charge_acts[act].cea_type_cd))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Charge_event_act_id:   ",cnvtstring(diag_info->charge_events[
     event].charge_acts[act].charge_act_id,17,2))
   CALL writelinetotable(0)
   SET outtable->message = concat("    Service Date Time:     ",diag_info->charge_events[event].
    charge_acts[act].service_dt,"  ",diag_info->charge_events[event].charge_acts[act].service_tm)
   CALL writelinetotable(0)
   IF (charge > 0)
    SET outtable->message = "    Reason:                There was a charge created"
    CALL writelinetotable(0)
    SET outtable->message = output->blank_line
    CALL writelinetotable(0)
    SET outtable->message = concat("    Charge  ",fillstring(34," "),"Service    Charge Admit")
    CALL writelinetotable(0)
    SET outtable->message =
    "    Item ID  Description     Status        Date    Time  Type   Type    Tier Group   Department   Manual Organization"
    CALL writelinetotable(0)
    SET outtable->message = concat("    ",output->dashed_line)
    CALL writelinetotable(0)
    FOR (loop = 1 TO charge)
     SET outtable->message = concat("    ",format(cnvtstring(charge_list->charges[loop].
        charge_item_id,17,2),"#######;;C"),"  ",format(charge_list->charges[loop].description,
       "###############;;C")," ",
      format(charge_list->charges[loop].status,"##########;;C")," ",charge_list->charges[loop].
      service_dt," ",charge_list->charges[loop].service_tm,
      " ",format(uar_get_code_display(charge_list->charges[loop].charge_type_cd),"######;;C")," ",
      format(uar_get_code_display(charge_list->charges[loop].admit_type_cd),"#######;;C")," ",
      format(uar_get_code_display(charge_list->charges[loop].tier_group_cd),"############;;C")," ",
      format(charge_list->charges[loop].department,"############;;C")," ",format(charge_list->
       charges[loop].manual,"######;;C"),
      " ",format(charge_list->charges[loop].organization,"#########################;;C"))
     CALL writelinetotable(0)
    ENDFOR
    SET outtable->message = concat("    ",output->dashed_line)
    CALL writelinetotable(0)
   ELSE
    SET outtable->message = "    Reason:                No reason found"
    CALL writelinetotable(0)
   ENDIF
   SET outtable->message = output->blank_line
   CALL writelinetotable(0)
   FREE SET charge_list
   FREE SET charge
 END ;Subroutine
 SUBROUTINE processdiaginfo(dummy)
   SET outtable->message = concat(fillstring(50," "),"Afc Server Diagnostics Report")
   CALL writelinetotable(1)
   SET outtable->message = concat(fillstring(50," "),"-----------------------------")
   CALL writelinetotable(0)
   FOR (event = 1 TO diag_info->event_count)
     SET pid = 0
     SET pcd = 0
     SET cid = 0
     SET ccd = 0
     SET bill_item = fillstring(30," ")
     SET bill_id = 0.0
     SET ext_owner = fillstring(30," ")
     SET pid = diag_info->charge_events[event].master_ref_id
     SET pcd = diag_info->charge_events[event].master_cont_cd
     IF ((((diag_info->charge_events[event].item_ref_id != pid)) OR ((diag_info->charge_events[event]
     .item_cont_cd != pcd))) )
      SET cid = diag_info->charge_events[event].item_ref_id
      SET ccd = diag_info->charge_events[event].item_cont_cd
     ENDIF
     SELECT INTO "nl:"
      bi.ext_description, bi.bill_item_id
      FROM bill_item bi
      WHERE bi.ext_parent_reference_id=pid
       AND bi.ext_parent_contributor_cd=pcd
       AND bi.ext_child_reference_id=cid
       AND bi.ext_child_contributor_cd=ccd
      DETAIL
       bill_id = bi.bill_item_id, bill_item = bi.ext_description, ext_owner = uar_get_code_display(bi
        .ext_owner_cd)
      WITH nocounter
     ;end select
     IF (bill_id=0
      AND cid > 0
      AND ccd > 0)
      SET pid = 0
      SET pcd = 0
      SELECT INTO "nl:"
       bi.ext_description, bi.bill_item_id
       FROM bill_item bi
       WHERE bi.ext_parent_reference_id=pid
        AND bi.ext_parent_contributor_cd=pcd
        AND bi.ext_child_reference_id=cid
        AND bi.ext_child_contributor_cd=ccd
       DETAIL
        bill_id = bi.bill_item_id, bill_item = bi.ext_description, ext_owner = uar_get_code_display(
         bi.ext_owner_cd)
       WITH nocounter
      ;end select
     ENDIF
     IF (bill_id=0
      AND cid > 0
      AND ccd > 0)
      SET pid = cid
      SET pcd = ccd
      SET cid = 0
      SET ccd = 0
      SELECT INTO "nl:"
       bi.ext_description, bi.bill_item_id
       FROM bill_item bi
       WHERE bi.ext_parent_reference_id=pid
        AND bi.ext_parent_contributor_cd=pcd
        AND bi.ext_child_reference_id=0
        AND bi.ext_child_contributor_cd=0
       DETAIL
        bill_id = bi.bill_item_id, bill_item = bi.ext_description, ext_owner = uar_get_code_display(
         bi.ext_owner_cd)
       WITH nocounter
      ;end select
     ENDIF
     SET outtable->message = output->blank_line
     CALL writelinetotable(0)
     SET outtable->message =
     "Patient                   Bill Item                      Charge Event ID  Master Event ID  Order ID     Accession Number"
     CALL writelinetotable(0)
     SET outtable->message = output->dashed_line
     CALL writelinetotable(0)
     SET outtable->message = concat(format(diag_info->charge_events[event].person_name,
       "#########################;;C")," ",format(bill_item,"##############################;;C")," ",
      format(cnvtstring(diag_info->charge_events[event].charge_event_id,17,2),"################;;C"),
      " ",format(cnvtstring(diag_info->charge_events[event].master_event_id,17,2),
       "################;;C")," ",format(cnvtstring(diag_info->charge_events[event].order_id,17,2),
       "############;;C")," ",
      diag_info->charge_events[event].accession)
     CALL writelinetotable(0)
     SET outtable->message = output->double_line
     CALL writelinetotable(0)
     FOR (act = 1 TO diag_info->charge_events[event].act_count)
      SET type_mean = uar_get_code_meaning(diag_info->charge_events[event].charge_acts[act].
       cea_type_cd)
      IF (substring((size(trim(type_mean,3)) - 2),3,trim(type_mean,3)) != "ING")
       CASE (diag_info->charge_events[event].charge_acts[act].srv_diag_cd)
        OF srv_diag_cs->not_at_chrg_pnt:
         CALL notatchargepoint("INTEXT")
        OF srv_diag_cs->no_pnt_item:
         CALL nopointonitem("INTEXT")
        OF srv_diag_cs->no_pnt_tier:
         CALL nopointontier("INTEXT")
        OF srv_diag_cs->not_at_chrg_lvl:
         CALL notatchargelevel("INTEXT")
        OF srv_diag_cs->no_chrg_ind:
         CALL nochargeind("INTEXT")
        OF srv_diag_cs->no_tier_for_org:
         CALL notierfororg("INTEXT")
        OF srv_diag_cs->no_phleb_chrg:
         CALL nophlebchrg("INTEXT")
        ELSE
         CALL noreason("INTEXT")
       ENDCASE
      ENDIF
     ENDFOR
     SET outtable->message = output->double_line
     CALL writelinetotable(0)
   ENDFOR
   SET outtable->message = concat(fillstring(59," "),"End of Report")
   CALL writelinetotable(0)
   SET outtable->message = output->star_line
   CALL writelinetotable(0)
   FREE SET event
   FREE SET act
   FREE SET list_size
   FREE SET type_mean
   FREE SET pid
   FREE SET pcd
   FREE SET cid
   FREE SET ccd
   FREE SET bill_item
   FREE SET bill_id
   FREE SET ext_owner
 END ;Subroutine
 SUBROUTINE writediaginfo(dummy)
  SELECT
   afc_diagnostics
   FROM afc_srv_diag
   WITH nocounter
  ;end select
  CALL echo("WriteDiagInfo - end")
 END ;Subroutine
 CALL initialize("INTEXT")
 CALL readdiaginfo("INTEXT")
 CALL processdiaginfo("INTEXT")
 CALL writediaginfo("INTEXT")
 FREE SET diag_info
 FREE SET srv_diag_cs
 FREE SET output
END GO

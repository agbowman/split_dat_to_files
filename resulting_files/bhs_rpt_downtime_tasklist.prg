CREATE PROGRAM bhs_rpt_downtime_tasklist
 PROMPT
  "output:" = "ryan_downtime_tasklist",
  "Nurse Unit Display Key:" = "",
  "Testing Indicator" = "0"
  WITH outdev, unit_cd_disp_key, test_ind
 FREE RECORD work
 RECORD work(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 unit_str = vc
   1 unit_cd = f8
   1 t_cnt = i4
   1 tabs[*]
     2 tab_id = f8
     2 name = vc
     2 adhoc_ind = i2
     2 all_types_ind = i2
     2 all_classes_ind = i2
     2 all_statuses_ind = i2
     2 tt_cnt = i4
     2 types[*]
       3 value = f8
     2 tc_cnt = i4
     2 classes[*]
       3 value = f8
     2 ts_cnt = i4
     2 statuses[*]
       3 value = f8
   1 all_types_ind = i2
   1 all_classes_ind = i2
   1 all_statuses_ind = i2
   1 tt_cnt = i4
   1 types[*]
     2 value = f8
   1 tc_cnt = i4
   1 classes[*]
     2 value = f8
   1 ts_cnt = i4
   1 statuses[*]
     2 value = f8
   1 e_cnt = i4
   1 encntrs[*]
     2 reg_dt_tm = vc
     2 filename = vc
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 dob = vc
     2 mrn = vc
     2 fin = vc
     2 unit = vc
     2 room = vc
     2 allergy_text = vc
     2 a_cnt = i4
     2 allergies[*]
       3 text = vc
     2 tab_cnt = i4
     2 tabs[*]
       3 t_cnt = i4
       3 tasks[*]
         4 task_slot = i4
     2 t_cnt = i4
     2 tasks[*]
       3 order_slot = i4
       3 child_slot = i4
       3 tab_slot = i4
       3 task_id = f8
       3 order_id = f8
       3 desc = vc
       3 sch_dt_tm = vc
       3 task_class_cd = f8
       3 task_type_cd = f8
       3 task_status_cd = f8
     2 o_cnt = i4
     2 orders[*]
       3 order_id = f8
       3 co_cnt = i4
       3 children[*]
         4 order_id = f8
       3 catalog_cd = f8
       3 template_ind = i2
       3 desc = vc
       3 od_line = vc
       3 start_dt_tm = dq8
       3 last_task_result = vc
       3 comments_ind = i2
       3 comment_line = vc
       3 c_cnt = i4
       3 comments[*]
         4 type = vc
         4 text = vc
       3 t_cnt = i4
       3 tasks[*]
         4 task_slot = i4
 )
 DECLARE test_ind = i2
 DECLARE tmp_expand_class = i4
 DECLARE tmp_expand_type = i4
 DECLARE tmp_expand_status = i4
 DECLARE cs4_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE cs79_complete_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE cs79_discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"DISCONTINUED"))
 DECLARE cs79_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE cs79_onhold_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"ONHOLD"))
 DECLARE cs79_overdue_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE cs79_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE cs79_suspended_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"SUSPENDED"))
 DECLARE cs79_validation_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cs6000_pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE cs6004_incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs6025_adhoc_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"ADHOC"))
 DECLARE cs6025_cont_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE cs6025_nsch_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE cs6025_prn_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE cs6025_sch_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"SCH"))
 DECLARE cs12025_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 SET work->unit_str = trim( $UNIT_CD_DISP_KEY,3)
 SET work->beg_dt_tm = cnvtdatetime((curdate - 1),0)
 SET work->end_dt_tm = cnvtdatetime((curdate+ 1),235959)
 IF (cnvtint( $TEST_IND)=1)
  SET test_ind = 1
 ELSE
  SET test_ind = 0
 ENDIF
 DECLARE add_tab_value(value_type=vc,value=f8) = null
 DECLARE tmp_a = i4
 DECLARE tmp_b = i4
 SUBROUTINE add_tab_value(value_type,value)
   SET tmp_a = 0
   SET tmp_b = 0
   CASE (value_type)
    OF "class":
     SET work->tabs[t_cnt].tc_cnt = (work->tabs[t_cnt].tc_cnt+ 1)
     SET stat = alterlist(work->tabs[t_cnt].classes,work->tabs[t_cnt].tc_cnt)
     SET work->tabs[t_cnt].classes[work->tabs[t_cnt].tc_cnt].value = value
     IF ((work->tc_cnt > 0))
      SET tmp_a = locateval(tmp_b,1,work->tc_cnt,value,work->classes[tmp_b].value)
      IF ((work->classes[tmp_a].value != value))
       SET tmp_a = 0
      ENDIF
     ENDIF
     IF (tmp_a=0)
      SET work->tc_cnt = (work->tc_cnt+ 1)
      SET stat = alterlist(work->classes,work->tc_cnt)
      SET work->classes[work->tc_cnt].value = value
     ENDIF
    OF "type":
     SET work->tabs[t_cnt].tt_cnt = (work->tabs[t_cnt].tt_cnt+ 1)
     SET stat = alterlist(work->tabs[t_cnt].types,work->tabs[t_cnt].tt_cnt)
     SET work->tabs[t_cnt].types[work->tabs[t_cnt].tt_cnt].value = value
     IF ((work->tt_cnt > 0))
      SET tmp_a = locateval(tmp_b,1,work->tt_cnt,value,work->types[tmp_b].value)
      IF ((work->types[tmp_a].value != value))
       SET tmp_a = 0
      ENDIF
     ENDIF
     IF (tmp_a=0)
      SET work->tt_cnt = (work->tt_cnt+ 1)
      SET stat = alterlist(work->types,work->tt_cnt)
      SET work->types[work->tt_cnt].value = value
     ENDIF
    OF "status":
     SET work->tabs[t_cnt].ts_cnt = (work->tabs[t_cnt].ts_cnt+ 1)
     SET stat = alterlist(work->tabs[t_cnt].statuses,work->tabs[t_cnt].ts_cnt)
     SET work->tabs[t_cnt].statuses[work->tabs[t_cnt].ts_cnt].value = value
     IF ((work->ts_cnt > 0))
      SET tmp_a = locateval(tmp_b,1,work->ts_cnt,value,work->statuses[tmp_b].value)
      IF ((work->statuses[tmp_a].value != value))
       SET tmp_a = 0
      ENDIF
     ENDIF
     IF (tmp_a=0)
      SET work->ts_cnt = (work->ts_cnt+ 1)
      SET stat = alterlist(work->statuses,work->ts_cnt)
      SET work->statuses[work->ts_cnt].value = value
     ENDIF
   ENDCASE
 END ;Subroutine
 SELECT INTO "nl:"
  FROM tl_tab_position_xref ttpx,
   tl_tab_content ttc,
   tl_eligible_task_code tetc
  PLAN (ttpx
   WHERE ttpx.position_cd=value(uar_get_code_by("DISPLAYKEY",88,"BHSRN"))
    AND ttpx.active_ind=1)
   JOIN (ttc
   WHERE ttpx.tl_tab_id=ttc.tl_tab_id)
   JOIN (tetc
   WHERE outerjoin(ttpx.tl_tab_id)=tetc.tl_tab_id)
  ORDER BY ttpx.role_tab_nbr, ttpx.tl_tab_id, tetc.task_type_cd
  HEAD REPORT
   work->tc_cnt = 1, stat = alterlist(work->classes,work->tc_cnt), work->classes[work->tc_cnt].value
    = 0.00,
   work->tt_cnt = 1, stat = alterlist(work->types,work->tt_cnt), work->types[work->tt_cnt].value =
   0.00,
   work->ts_cnt = 1, stat = alterlist(work->statuses,work->ts_cnt), work->statuses[work->ts_cnt].
   value = 0.00,
   t_cnt = 0
  HEAD ttpx.role_tab_nbr
   t_cnt = t_cnt
  HEAD ttpx.tl_tab_id
   t_cnt = (work->t_cnt+ 1), stat = alterlist(work->tabs,t_cnt), work->t_cnt = t_cnt,
   work->tabs[t_cnt].tab_id = ttpx.tl_tab_id, work->tabs[t_cnt].name = ttc.tab_name, work->tabs[t_cnt
   ].all_classes_ind = ttc.alltimeparam_ind,
   work->tabs[t_cnt].all_types_ind = band(ttc.type_flag,1), work->tabs[t_cnt].all_statuses_ind = ttc
   .allstatus_ind
   IF ((work->tabs[t_cnt].all_classes_ind=1))
    work->all_classes_ind = work->tabs[t_cnt].all_classes_ind
   ELSE
    stat = add_tab_value("class",cs6025_adhoc_cd)
    IF (ttc.continuous_ind=1)
     stat = add_tab_value("class",cs6025_cont_cd)
    ENDIF
    IF (ttc.prn_ind=1)
     stat = add_tab_value("class",cs6025_prn_cd)
    ENDIF
    IF (ttc.scheduled_ind=1)
     stat = add_tab_value("class",cs6025_sch_cd)
    ENDIF
    IF (ttc.nonscheduled_ind=1)
     stat = add_tab_value("class",cs6025_nsch_cd)
    ENDIF
   ENDIF
   IF ((work->tabs[t_cnt].all_types_ind=1))
    work->all_types_ind = work->tabs[t_cnt].all_types_ind
   ENDIF
   IF ((work->tabs[t_cnt].all_statuses_ind=1))
    work->all_statuses_ind = work->tabs[t_cnt].all_statuses_ind
   ELSE
    IF (ttc.complete_ind=1)
     stat = add_tab_value("status",cs79_complete_cd)
    ENDIF
    IF (ttc.discontinued_ind=1)
     stat = add_tab_value("status",cs79_discontinued_cd)
    ENDIF
    IF (ttc.inprocess_ind=1)
     stat = add_tab_value("status",cs79_inprocess_cd)
    ENDIF
    IF (ttc.overdue_ind=1)
     stat = add_tab_value("status",cs79_overdue_cd)
    ENDIF
    IF (ttc.pending_ind=1)
     stat = add_tab_value("status",cs79_pending_cd), stat = add_tab_value("status",cs79_onhold_cd)
    ENDIF
    IF (ttc.suspend_ind=1)
     stat = add_tab_value("status",cs79_suspended_cd)
    ENDIF
    IF (ttc.pendingvalidation_ind=1)
     stat = add_tab_value("status",cs79_validation_cd)
    ENDIF
   ENDIF
  DETAIL
   stat = add_tab_value("type",tetc.task_type_cd)
  FOOT REPORT
   t_cnt = (work->t_cnt+ 1), stat = alterlist(work->tabs,t_cnt), work->t_cnt = t_cnt,
   work->tabs[t_cnt].name = "Adhoc/Non-Scheduled", work->tabs[t_cnt].all_types_ind = 1, stat =
   add_tab_value("class",0.00),
   stat = add_tab_value("class",cs6025_adhoc_cd), stat = add_tab_value("class",cs6025_nsch_cd), stat
    = add_tab_value("status",cs79_inprocess_cd),
   stat = add_tab_value("status",cs79_overdue_cd), stat = add_tab_value("status",cs79_pending_cd),
   stat = add_tab_value("status",cs79_onhold_cd),
   work->all_types_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE (cv.display_key=work->unit_str)
    AND cv.code_set=220
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
    AND cv.active_ind=1
    AND cv.data_status_cd=25)
  DETAIL
   work->unit_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((work->unit_cd <= 0.00))
  CALL echo("Nurse Unit not found.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea,
   person_alias pa,
   person p
  PLAN (ed
   WHERE (ed.loc_nurse_unit_cd=work->unit_cd)
    AND ed.beg_effective_dt_tm <= sysdate
    AND ed.end_effective_dt_tm >= sysdate
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=cs319_fin_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.person_alias_type_cd=cs4_mrn_cd)
  ORDER BY p.person_id, ed.beg_effective_dt_tm DESC
  HEAD p.person_id
   IF (((e.reg_dt_tm >= cnvtlookbehind("36,H",sysdate)
    AND (work->unit_str IN ("EDPEDI", "EDMAIN", "EDA", "EDGTA", "ESA",
   "ESB", "ESC", "ESD", "ESP", "ESX",
   "ESW"))) OR ( NOT ((work->unit_str IN ("EDPEDI", "EDMAIN", "EDA", "EDGTA", "ESA",
   "ESB", "ESC", "ESD", "ESP", "ESX",
   "ESW"))))) )
    work->e_cnt = (work->e_cnt+ 1), stat = alterlist(work->encntrs,work->e_cnt), work->encntrs[work->
    e_cnt].reg_dt_tm = format(e.reg_dt_tm,";;Q"),
    work->encntrs[work->e_cnt].person_id = p.person_id, work->encntrs[work->e_cnt].encntr_id = e
    .encntr_id, work->encntrs[work->e_cnt].name = build2(trim(p.name_full_formatted,3)," (",trim(
      uar_get_code_display(e.encntr_type_cd),3),")"),
    work->encntrs[work->e_cnt].dob = format(p.birth_dt_tm,"MM-DD-YYYY;;d"), work->encntrs[work->e_cnt
    ].fin = trim(ea.alias,3), work->encntrs[work->e_cnt].mrn = trim(pa.alias,3),
    work->encntrs[work->e_cnt].unit = trim(uar_get_code_display(ed.loc_nurse_unit_cd),3), work->
    encntrs[work->e_cnt].room = trim(uar_get_code_display(ed.loc_room_cd),3), work->encntrs[work->
    e_cnt].allergy_text = "NKA",
    work->encntrs[work->e_cnt].filename = build(trim(substring(1,5,trim(cnvtlower(cnvtalphanum(p
          .name_last_key,2)),4)),3),"_",trim(substring(1,4,trim(cnvtlower(cnvtalphanum(p
          .name_first_key,2)),4)),3),".ps"), work->encntrs[work->e_cnt].tab_cnt = work->t_cnt, stat
     = alterlist(work->encntrs[work->e_cnt].tabs,work->t_cnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   allergy a,
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=work->encntrs[d.seq].person_id)
    AND a.reaction_status_cd != cs12025_canceled_cd
    AND a.active_ind=1)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
  HEAD REPORT
   a_cnt = 0
  DETAIL
   a_cnt = (work->encntrs[d.seq].a_cnt+ 1), work->encntrs[d.seq].a_cnt = a_cnt, stat = alterlist(work
    ->encntrs[d.seq].allergies,a_cnt)
   IF (n.nomenclature_id > 0.00)
    work->encntrs[d.seq].allergies[a_cnt].text = trim(n.source_string)
   ELSE
    work->encntrs[d.seq].allergies[a_cnt].text = trim(a.substance_ftdesc)
   ENDIF
   IF (a_cnt <= 1)
    work->encntrs[d.seq].allergy_text = work->encntrs[d.seq].allergies[a_cnt].text
   ELSE
    work->encntrs[d.seq].allergy_text = build2(work->encntrs[d.seq].allergy_text,", ",work->encntrs[d
     .seq].allergies[a_cnt].text)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   task_activity ta,
   order_task ot,
   orders o
  PLAN (d)
   JOIN (ta
   WHERE (work->encntrs[d.seq].encntr_id=ta.encntr_id)
    AND ta.catalog_type_cd != cs6000_pharm_cd
    AND ta.reference_task_id > 0.00
    AND (((work->all_classes_ind=1)) OR (expand(tmp_expand_class,1,work->tc_cnt,ta.task_class_cd,work
    ->classes[tmp_expand_class].value)))
    AND (((work->all_types_ind=1)) OR (expand(tmp_expand_type,1,work->tt_cnt,ta.task_type_cd,work->
    types[tmp_expand_type].value)))
    AND (((work->all_statuses_ind=1)) OR (expand(tmp_expand_status,1,work->ts_cnt,ta.task_status_cd,
    work->statuses[tmp_expand_status].value))) )
   JOIN (ot
   WHERE ta.reference_task_id=ot.reference_task_id
    AND ot.cernertask_flag <= 0)
   JOIN (o
   WHERE outerjoin(ta.order_id)=o.order_id)
  ORDER BY d.seq, ot.task_description, ta.scheduled_dt_tm,
   ta.task_id
  HEAD REPORT
   tmp_class = 0, tmp_type = 0, tmp_status = 0,
   t_cnt = 0, co_cnt = 0, tmp_t_oid = 0.00,
   tmp_c_oid = 0.00, tmp_x = 0, tmp_o = 0,
   tmp_c = 0
  HEAD d.seq
   tmp_class = 0, tmp_type = 0, tmp_status = 0,
   t_cnt = 0, co_cnt = 0, tmp_t_oid = 0.00,
   tmp_c_oid = 0.00, tmp_x = 0, tmp_o = 0,
   tmp_c = 0
  DETAIL
   tmp_tab_slot = 0, tmp_cur_tab = 1, tmp_class = 0,
   tmp_type = 0, tmp_status = 0
   WHILE ((tmp_cur_tab < work->t_cnt)
    AND tmp_tab_slot=0)
     IF ((work->tabs[tmp_cur_tab].tc_cnt > 0))
      tmp_class = locateval(tmp_x,1,work->tabs[tmp_cur_tab].tc_cnt,ta.task_class_cd,work->tabs[
       tmp_cur_tab].classes[tmp_x].value), tmp_x = 0
      IF ((work->tabs[tmp_cur_tab].classes[tmp_class].value != ta.task_class_cd))
       tmp_class = 0
      ENDIF
     ENDIF
     IF ((work->tabs[tmp_cur_tab].tt_cnt > 0))
      tmp_type = locateval(tmp_x,1,work->tabs[tmp_cur_tab].tt_cnt,ta.task_type_cd,work->tabs[
       tmp_cur_tab].types[tmp_x].value), tmp_x = 0
      IF ((work->tabs[tmp_cur_tab].types[tmp_type].value != ta.task_type_cd))
       tmp_type = 0
      ENDIF
     ENDIF
     IF ((work->tabs[tmp_cur_tab].ts_cnt > 0))
      tmp_status = locateval(tmp_x,1,work->tabs[tmp_cur_tab].ts_cnt,ta.task_status_cd,work->tabs[
       tmp_cur_tab].statuses[tmp_x].value), tmp_x = 0
      IF ((work->tabs[tmp_cur_tab].statuses[tmp_status].value != ta.task_status_cd))
       tmp_status = 0
      ENDIF
     ENDIF
     IF ((((work->tabs[tmp_cur_tab].all_classes_ind=1)) OR (tmp_class > 0))
      AND (((work->tabs[tmp_cur_tab].all_types_ind=1)) OR (tmp_type > 0))
      AND (((work->tabs[tmp_cur_tab].all_statuses_ind=1)) OR (tmp_status > 0)) )
      tmp_tab_slot = tmp_cur_tab, tmp_cur_tab = (work->t_cnt+ 1)
     ELSE
      tmp_cur_tab = (tmp_cur_tab+ 1)
     ENDIF
   ENDWHILE
   IF (tmp_tab_slot > 0)
    t_cnt = (work->encntrs[d.seq].tabs[tmp_tab_slot].t_cnt+ 1), stat = alterlist(work->encntrs[d.seq]
     .tabs[tmp_tab_slot].tasks,t_cnt), work->encntrs[d.seq].tabs[tmp_tab_slot].t_cnt = t_cnt,
    work->encntrs[d.seq].tabs[tmp_tab_slot].tasks[t_cnt].task_slot = (work->encntrs[d.seq].t_cnt+ 1),
    t_cnt = (work->encntrs[d.seq].t_cnt+ 1), stat = alterlist(work->encntrs[d.seq].tasks,t_cnt),
    work->encntrs[d.seq].t_cnt = t_cnt, work->encntrs[d.seq].tasks[t_cnt].tab_slot = tmp_tab_slot,
    work->encntrs[d.seq].tasks[t_cnt].task_id = ta.task_id,
    work->encntrs[d.seq].tasks[t_cnt].order_id = ta.order_id, work->encntrs[d.seq].tasks[t_cnt].desc
     = ot.task_description, work->encntrs[d.seq].tasks[t_cnt].task_class_cd = ta.task_class_cd,
    work->encntrs[d.seq].tasks[t_cnt].task_type_cd = ta.task_type_cd, work->encntrs[d.seq].tasks[
    t_cnt].task_status_cd = ta.task_status_cd
    IF (ta.task_class_cd=cs6025_sch_cd)
     work->encntrs[d.seq].tasks[t_cnt].sch_dt_tm = format(ta.scheduled_dt_tm,"MM/DD/YY HH:MM;;D")
    ELSE
     work->encntrs[d.seq].tasks[t_cnt].sch_dt_tm = trim(uar_get_code_display(ta.task_class_cd),3)
    ENDIF
    tmp_t_oid = 0.00, tmp_c_oid = 0.00, tmp_x = 0,
    tmp_o = - (1), tmp_c = - (1)
    IF (o.order_id > 0.00)
     tmp_c_oid = o.order_id
     IF (o.template_order_id <= 0.00)
      tmp_t_oid = tmp_c_oid
     ELSE
      tmp_t_oid = o.template_order_id
     ENDIF
     IF ((work->encntrs[d.seq].o_cnt > 0))
      tmp_o = locateval(tmp_x,1,work->encntrs[d.seq].o_cnt,tmp_t_oid,work->encntrs[d.seq].orders[
       tmp_x].order_id), tmp_x = 0
      IF ((work->encntrs[d.seq].orders[tmp_o].order_id != tmp_t_oid))
       tmp_o = - (1)
      ELSE
       tmp_c = locateval(tmp_x,1,work->encntrs[d.seq].orders[tmp_o].co_cnt,tmp_c_oid,work->encntrs[d
        .seq].orders[tmp_o].children[tmp_x].order_id), tmp_x = 0
       IF ((work->encntrs[d.seq].orders[tmp_o].children[tmp_c].order_id != tmp_c_oid))
        tmp_c = - (1)
       ENDIF
      ENDIF
     ENDIF
     IF ((tmp_o=- (1)))
      tmp_o = (work->encntrs[d.seq].o_cnt+ 1), stat = alterlist(work->encntrs[d.seq].orders,tmp_o),
      work->encntrs[d.seq].o_cnt = tmp_o,
      work->encntrs[d.seq].orders[tmp_o].order_id = tmp_t_oid, tmp_x = (work->encntrs[d.seq].orders[
      tmp_o].co_cnt+ 1), stat = alterlist(work->encntrs[d.seq].orders[tmp_o].children,tmp_x),
      work->encntrs[d.seq].orders[tmp_o].co_cnt = tmp_x, work->encntrs[d.seq].orders[tmp_o].children[
      tmp_x].order_id = tmp_t_oid, tmp_x = 0
     ENDIF
     IF ((tmp_c=- (1)))
      tmp_c = (work->encntrs[d.seq].orders[tmp_o].co_cnt+ 1), stat = alterlist(work->encntrs[d.seq].
       orders[tmp_o].children,tmp_c), work->encntrs[d.seq].orders[tmp_o].co_cnt = tmp_c,
      work->encntrs[d.seq].orders[tmp_o].children[tmp_c].order_id = tmp_c_oid
     ENDIF
     work->encntrs[d.seq].tasks[t_cnt].order_slot = tmp_o, work->encntrs[d.seq].tasks[t_cnt].
     child_slot = tmp_c, t_cnt = (work->encntrs[d.seq].orders[tmp_o].t_cnt+ 1),
     stat = alterlist(work->encntrs[d.seq].orders[tmp_o].tasks,t_cnt), work->encntrs[d.seq].orders[
     tmp_o].tasks[t_cnt].task_slot = work->encntrs[d.seq].t_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, seq_mnemonic = substring(1,100,cnvtupper(o.hna_order_mnemonic))
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   order_comment oc,
   long_text lt
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].o_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=work->encntrs[d1.seq].orders[d2.seq].order_id))
   JOIN (oc
   WHERE outerjoin(o.order_id)=oc.order_id)
   JOIN (lt
   WHERE outerjoin(oc.long_text_id)=lt.long_text_id)
  ORDER BY d1.seq, d2.seq
  HEAD REPORT
   c_cnt = 0
  HEAD o.order_id
   work->encntrs[d1.seq].orders[d2.seq].catalog_cd = o.catalog_cd, work->encntrs[d1.seq].orders[d2
   .seq].desc = trim(o.hna_order_mnemonic,3), work->encntrs[d1.seq].orders[d2.seq].start_dt_tm = o
   .current_start_dt_tm,
   work->encntrs[d1.seq].orders[d2.seq].od_line = trim(o.order_detail_display_line,3), work->encntrs[
   d1.seq].orders[d2.seq].comments_ind = o.order_comment_ind
  DETAIL
   IF (oc.order_id > 0.00)
    c_cnt = (work->encntrs[d1.seq].orders[d2.seq].c_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
     orders[d2.seq].comments,c_cnt), work->encntrs[d1.seq].orders[d2.seq].comments[c_cnt].type = trim
    (uar_get_code_display(oc.comment_type_cd),3),
    work->encntrs[d1.seq].orders[d2.seq].comments[c_cnt].text = trim(lt.long_text,3)
    IF (c_cnt <= 1)
     work->encntrs[d1.seq].orders[d2.seq].comment_line = build2(work->encntrs[d1.seq].orders[d2.seq].
      comments[c_cnt].type,": ",work->encntrs[d1.seq].orders[d2.seq].comments[c_cnt].text)
    ELSE
     work->encntrs[d1.seq].orders[d2.seq].comment_line = build2(work->encntrs[d1.seq].orders[d2.seq].
      comment_line,char(13),work->encntrs[d1.seq].orders[d2.seq].comments[c_cnt].type,": ",work->
      encntrs[d1.seq].orders[d2.seq].comments[c_cnt].text)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE report_head(ncalc=i2) = f8 WITH protect
 DECLARE report_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_demographics(ncalc=i2) = f8 WITH protect
 DECLARE patient_demographicsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_allergies(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE patient_allergiesabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE tab_head(ncalc=i2) = f8 WITH protect
 DECLARE tab_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE report_divider(ncalc=i2) = f8 WITH protect
 DECLARE report_dividerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE task_description(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE task_descriptionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE order_description(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE order_descriptionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE order_details(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE order_detailsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE order_instructions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE order_instructionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE task_last_done(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE task_last_doneabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE task_details(ncalc=i2) = f8 WITH protect
 DECLARE task_detailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE task_addtl_notes(ncalc=i2) = f8 WITH protect
 DECLARE task_addtl_notesabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE refused_tasks(ncalc=i2) = f8 WITH protect
 DECLARE refused_tasksabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE refused_task_notes(ncalc=i2) = f8 WITH protect
 DECLARE refused_task_notesabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE signature_line(ncalc=i2) = f8 WITH protect
 DECLARE signature_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE page_foot(ncalc=i2) = f8 WITH protect
 DECLARE page_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remallergies_text = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpatient_allergies = i2 WITH noconstant(0), protect
 DECLARE _remtask_desc = i4 WITH noconstant(1), protect
 DECLARE _bconttask_description = i2 WITH noconstant(0), protect
 DECLARE _remorder_desc = i4 WITH noconstant(1), protect
 DECLARE _bcontorder_description = i2 WITH noconstant(0), protect
 DECLARE _remorder_details = i4 WITH noconstant(1), protect
 DECLARE _bcontorder_details = i2 WITH noconstant(0), protect
 DECLARE _remorder_instructions = i4 WITH noconstant(1), protect
 DECLARE _bcontorder_instructions = i2 WITH noconstant(0), protect
 DECLARE _remlast_done = i4 WITH noconstant(1), protect
 DECLARE _bconttask_last_done = i2 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica13b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica15b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen21s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE report_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE report_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.720000), private
   DECLARE __title_2 = vc WITH noconstant(build2(build2("Printed at ",format(cnvtdatetime(curdate,
        curtime3),"mm-dd-yyyy hh:mm;;d")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.500
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica15b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Permanent Record",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__title_2)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.500
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Downtime Nursing Intervention (Task Lists)",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_demographics(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_demographicsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_demographicsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.630000), private
   DECLARE __patient_name = vc WITH noconstant(build2(trim(work->encntrs[e].name,3),char(0))),
   protect
   DECLARE __patient_dob = vc WITH noconstant(build2(build2("DOB ",trim(work->encntrs[e].dob,3)),char
     (0))), protect
   DECLARE __patient_location = vc WITH noconstant(build2(build2("Location ",trim(work->encntrs[e].
       unit,3)," ",trim(work->encntrs[e].room,3)),char(0))), protect
   DECLARE __patient_acct_num = vc WITH noconstant(build2(build2("ACCT# ",trim(work->encntrs[e].fin,3
       )),char(0))), protect
   DECLARE __patient_mrn = vc WITH noconstant(build2(build2("MRN# ",trim(work->encntrs[e].mrn,3)),
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.510
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_dob)
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.510
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_location)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_acct_num)
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_mrn)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_allergies(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_allergiesabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_allergiesabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_allergies_text = f8 WITH noconstant(0.0), private
   DECLARE __allergies_text = vc WITH noconstant(build2(trim(allergies_text,3),char(0))), protect
   IF (bcontinue=0)
    SET _remallergies_text = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.198)
   SET rptsd->m_width = 6.802
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremallergies_text = _remallergies_text
   IF (_remallergies_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallergies_text,((size(
        __allergies_text) - _remallergies_text)+ 1),__allergies_text)))
    SET drawheight_allergies_text = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remallergies_text = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallergies_text,((size(__allergies_text
        ) - _remallergies_text)+ 1),__allergies_text)))))
     SET _remallergies_text = (_remallergies_text+ rptsd->m_drawlength)
    ELSE
     SET _remallergies_text = 0
    ENDIF
    SET growsum = (growsum+ _remallergies_text)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = 0.229
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.198)
   SET rptsd->m_width = 6.802
   SET rptsd->m_height = drawheight_allergies_text
   IF (ncalc=rpt_render
    AND _holdremallergies_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallergies_text,((
       size(__allergies_text) - _holdremallergies_text)+ 1),__allergies_text)))
   ELSE
    SET _remallergies_text = _holdremallergies_text
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tab_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tab_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tab_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica13b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tab_desc,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE report_divider(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_dividerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE report_dividerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),(offsety+ 0.068),(offsetx+ 8.000),(offsety+
     0.068))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE task_description(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = task_descriptionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE task_descriptionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_task_desc = f8 WITH noconstant(0.0), private
   DECLARE __task_desc = vc WITH noconstant(build2(trim(task_desc,3),char(0))), protect
   IF (bcontinue=0)
    SET _remtask_desc = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.063)
   SET rptsd->m_width = 6.948
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtask_desc = _remtask_desc
   IF (_remtask_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtask_desc,((size(
        __task_desc) - _remtask_desc)+ 1),__task_desc)))
    SET drawheight_task_desc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtask_desc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtask_desc,((size(__task_desc) -
       _remtask_desc)+ 1),__task_desc)))))
     SET _remtask_desc = (_remtask_desc+ rptsd->m_drawlength)
    ELSE
     SET _remtask_desc = 0
    ENDIF
    SET growsum = (growsum+ _remtask_desc)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.063)
   SET rptsd->m_width = 6.948
   SET rptsd->m_height = drawheight_task_desc
   IF (ncalc=rpt_render
    AND _holdremtask_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtask_desc,((size(
        __task_desc) - _holdremtask_desc)+ 1),__task_desc)))
   ELSE
    SET _remtask_desc = _holdremtask_desc
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.677
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TASK:",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE order_description(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = order_descriptionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE order_descriptionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order_desc = f8 WITH noconstant(0.0), private
   DECLARE __order_desc = vc WITH noconstant(build2(trim(order_desc,3),char(0))), protect
   IF (bcontinue=0)
    SET _remorder_desc = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.063)
   SET rptsd->m_width = 6.948
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremorder_desc = _remorder_desc
   IF (_remorder_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_desc,((size(
        __order_desc) - _remorder_desc)+ 1),__order_desc)))
    SET drawheight_order_desc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_desc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_desc,((size(__order_desc) -
       _remorder_desc)+ 1),__order_desc)))))
     SET _remorder_desc = (_remorder_desc+ rptsd->m_drawlength)
    ELSE
     SET _remorder_desc = 0
    ENDIF
    SET growsum = (growsum+ _remorder_desc)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.677
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ORDER:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.063)
   SET rptsd->m_width = 6.948
   SET rptsd->m_height = drawheight_order_desc
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
   IF (ncalc=rpt_render
    AND _holdremorder_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_desc,((size(
        __order_desc) - _holdremorder_desc)+ 1),__order_desc)))
   ELSE
    SET _remorder_desc = _holdremorder_desc
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE order_details(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = order_detailsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE order_detailsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order_details = f8 WITH noconstant(0.0), private
   DECLARE __order_details = vc WITH noconstant(build2(order_details_text,char(0))), protect
   IF (bcontinue=0)
    SET _remorder_details = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremorder_details = _remorder_details
   IF (_remorder_details > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_details,((size(
        __order_details) - _remorder_details)+ 1),__order_details)))
    SET drawheight_order_details = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_details = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_details,((size(__order_details)
        - _remorder_details)+ 1),__order_details)))))
     SET _remorder_details = (_remorder_details+ rptsd->m_drawlength)
    ELSE
     SET _remorder_details = 0
    ENDIF
    SET growsum = (growsum+ _remorder_details)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_order_details
   IF (ncalc=rpt_render
    AND _holdremorder_details > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_details,((
       size(__order_details) - _holdremorder_details)+ 1),__order_details)))
   ELSE
    SET _remorder_details = _holdremorder_details
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE order_instructions(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = order_instructionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE order_instructionsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order_instructions = f8 WITH noconstant(0.0), private
   DECLARE __order_instructions = vc WITH noconstant(build2(order_instructions_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remorder_instructions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremorder_instructions = _remorder_instructions
   IF (_remorder_instructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_instructions,((
       size(__order_instructions) - _remorder_instructions)+ 1),__order_instructions)))
    SET drawheight_order_instructions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_instructions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_instructions,((size(
        __order_instructions) - _remorder_instructions)+ 1),__order_instructions)))))
     SET _remorder_instructions = (_remorder_instructions+ rptsd->m_drawlength)
    ELSE
     SET _remorder_instructions = 0
    ENDIF
    SET growsum = (growsum+ _remorder_instructions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_order_instructions
   IF (ncalc=rpt_render
    AND _holdremorder_instructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_instructions,
       ((size(__order_instructions) - _holdremorder_instructions)+ 1),__order_instructions)))
   ELSE
    SET _remorder_instructions = _holdremorder_instructions
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE task_last_done(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = task_last_doneabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE task_last_doneabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_last_done = f8 WITH noconstant(0.0), private
   DECLARE __last_done = vc WITH noconstant(build2(task_last_done_text,char(0))), protect
   IF (bcontinue=0)
    SET _remlast_done = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.323)
   SET rptsd->m_width = 6.677
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlast_done = _remlast_done
   IF (_remlast_done > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlast_done,((size(
        __last_done) - _remlast_done)+ 1),__last_done)))
    SET drawheight_last_done = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlast_done = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlast_done,((size(__last_done) -
       _remlast_done)+ 1),__last_done)))))
     SET _remlast_done = (_remlast_done+ rptsd->m_drawlength)
    ELSE
     SET _remlast_done = 0
    ENDIF
    SET growsum = (growsum+ _remlast_done)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LAST DONE:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.323)
   SET rptsd->m_width = 6.677
   SET rptsd->m_height = drawheight_last_done
   IF (ncalc=rpt_render
    AND _holdremlast_done > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlast_done,((size(
        __last_done) - _holdremlast_done)+ 1),__last_done)))
   ELSE
    SET _remlast_done = _holdremlast_done
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE task_details(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = task_detailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE task_detailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.854
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SCH DT/TM:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(task_sch_text,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 3.260
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "TIME __________  INITIALS ________  CIS ______",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 0.604
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("STATUS:",char(0)))
    SET rptsd->m_flags = 8
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.115)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(task_status_text,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE task_addtl_notes(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = task_addtl_notesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE task_addtl_notesabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ADDITIONAL DOCUMENTATION:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE refused_tasks(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = refused_tasksabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE refused_tasksabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.720000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica13b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("OMITTED / REFUSED TASKS",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdallborders
    SET rptsd->m_paddingwidth = 0.067
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.427
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "BRADYCARDIA, BRADYPNEA, FAMILY REFUSED, HYPERTENSION, HYPOTENSION, INFLITRATED SITE, NO BLOOD RETURN, ORDER DIS",
       "CONTINUED, PATIENT NPO, PATIENT REFUSED, PATIENT NAUSEATED, PATIENT REFUSED, TACHYCARDIA, TACHYPNEA"
       ),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE refused_task_notes(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = refused_task_notesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE refused_task_notesabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "TASK _____________________  REASON _________________  TIME __________  INITIALS __________  CIS ______",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE signature_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = signature_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE signature_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "INITIALS ______  PRINTED NAME ______________________  SIGNATURE ___________________  TITLE ________",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE page_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE __page_num = vc WITH noconstant(build2(build2("PAGE ",trim(build2(cur_page),3)),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (cur_end_report=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("--- END OF REPORT ---",char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__page_num)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_DOWNTIME_TASKLIST"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.00
   SET rptreport->m_marginright = 0.00
   SET rptreport->m_margintop = 0.00
   SET rptreport->m_marginbottom = 0.00
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 15
   SET rptfont->m_bold = rpt_on
   SET _helvetica15b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 13
   SET rptfont->m_bold = rpt_on
   SET _helvetica13b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.021
   SET _pen21s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE tab = i4 WITH noconstant(0)
 DECLARE e = i4 WITH noconstant(0)
 DECLARE t = i4 WITH noconstant(0)
 DECLARE o = i4 WITH noconstant(0)
 DECLARE becont = i4 WITH noconstant(0)
 DECLARE cur_page = i4 WITH noconstant(0)
 DECLARE cur_end_report = i2 WITH noconstant(0)
 DECLARE tmp_remove = vc
 DECLARE blank_task_cnt = i4 WITH constant(3)
 DECLARE refused_task_cnt = i4 WITH constant(2)
 DECLARE sig_line_cnt = i4 WITH constant(3)
 DECLARE tmp_work_room = f8
 DECLARE tmp_height = f8
 DECLARE y_page_head = f8 WITH constant(0.5)
 DECLARE y_page_foot = f8 WITH constant(10.5)
 DECLARE page_foot_buffer = f8 WITH constant(0.15)
 DECLARE y_end_of_page = f8
 DECLARE y_end_of_report = f8
 DECLARE report_head_height = f8
 DECLARE report_divider_height = f8
 DECLARE patient_demo_height = f8
 DECLARE patient_allergies_height = f8
 DECLARE section_head_height = f8
 DECLARE task_details_height = f8
 DECLARE task_addtl_notes_height = f8
 DECLARE refused_task_height = f8
 DECLARE allergies_text = vc
 DECLARE section_desc = vc
 DECLARE task_desc = vc
 DECLARE order_desc = vc
 DECLARE order_details_text = vc
 DECLARE order_instructions_text = vc
 DECLARE task_last_done_text = vc
 DECLARE task_sch_text = vc
 DECLARE task_status_text = vc
 SET y_end_of_page = (y_page_foot - page_foot_buffer)
 SET y_end_of_report = ((y_end_of_page - page_foot_buffer) - (sig_line_cnt * signature_line(
  rpt_calcheight)))
 SET report_head_height = report_head(rpt_calcheight)
 SET report_divider_height = report_divider(rpt_calcheight)
 SET patient_demo_height = patient_demographics(rpt_calcheight)
 SET patient_allergies_height = patient_allergies(rpt_calcheight,8.5,becont)
 SET section_head_height = (tab_head(rpt_calcheight)+ report_divider_height)
 SET task_details_height = task_details(rpt_calcheight)
 SET task_addtl_notes_height = task_addtl_notes(rpt_calcheight)
 SET refused_task_height = ((refused_tasks(rpt_calcheight)+ (refused_task_cnt * refused_task_notes(
  rpt_calcheight)))+ report_divider_height)
 DECLARE sub_head_report(zero1=i2) = null
 DECLARE sub_head_page(beg_report=i2) = null
 DECLARE sub_get_work_room(zero2=i2) = null
 DECLARE sub_foot_page(end_report=i2) = null
 DECLARE sub_foot_report(zero4=i2) = null
 SUBROUTINE sub_head_report(zero1)
   IF (((test_ind=1
    AND e=1) OR (test_ind=0)) )
    SET d0 = initializereport(0)
   ENDIF
   SET cur_page = 0
   SET d0 = sub_head_page(1)
 END ;Subroutine
 SUBROUTINE sub_head_page(beg_report)
  SET _yoffset = y_page_head
  IF (beg_report=1)
   SET d0 = report_head(rpt_render)
   SET d0 = patient_demographics(rpt_render)
   SET allergies_text = work->encntrs[e].allergy_text
   SET d0 = patient_allergies(rpt_render,8.5,becont)
  ELSEIF (beg_report=0)
   SET d0 = patient_demographics(rpt_render)
   IF (tab > 0)
    SET print_section_desc_ind = 0
    SET d0 = report_divider(rpt_render)
    SET d0 = tab_head(rpt_render)
    SET d0 = report_divider(rpt_render)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE sub_get_work_room(zero2)
   RETURN((y_end_of_page - _yoffset))
 END ;Subroutine
 SUBROUTINE sub_foot_page(end_report)
   SET cur_page = (cur_page+ 1)
   SET _yoffset = y_page_foot
   SET d0 = page_foot(rpt_render)
   IF (end_report=0)
    SET d0 = pagebreak(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE sub_foot_report(zero4)
   SET cur_end_report = 1
   IF (_yoffset > y_end_of_report)
    SET d0 = pagebreak(0)
   ENDIF
   SET _yoffset = (y_end_of_report+ page_foot_buffer)
   FOR (sl = 1 TO sig_line_cnt)
     SET d0 = signature_line(rpt_render)
   ENDFOR
   IF (test_ind=0)
    SET d0 = sub_foot_page(1)
   ELSE
    IF ((e=work->e_cnt))
     SET d0 = sub_foot_page(1)
    ELSE
     SET d0 = sub_foot_page(0)
    ENDIF
   ENDIF
   IF (test_ind=0)
    SET d0 = finalizereport(work->encntrs[e].filename)
    SET spool value(work->encntrs[e].filename)  $OUTDEV
    SET tmp_remove = build2('set stat = remove("',work->encntrs[e].filename,'") go')
    CALL echo(tmp_remove)
    CALL parser(tmp_remove)
   ENDIF
   SET cur_end_report = 0
 END ;Subroutine
 FOR (e = 1 TO work->e_cnt)
   EXECUTE bhs_sys_pause 10
   SET d0 = sub_head_report(0)
   SET tab = 0
   FOR (tab = 1 TO work->t_cnt)
     IF (_yoffset >= y_end_of_page)
      SET d0 = sub_foot_page(0)
      SET d0 = sub_head_page(0)
     ENDIF
     SET tab_desc = work->tabs[tab].name
     SET d0 = report_divider(rpt_render)
     SET d0 = tab_head(rpt_render)
     SET d0 = report_divider(rpt_render)
     SET t = 0
     FOR (tmp_t = 1 TO work->encntrs[e].tabs[tab].t_cnt)
       SET t = work->encntrs[e].tabs[tab].tasks[tmp_t].task_slot
       IF (_yoffset >= y_end_of_page)
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
       ENDIF
       SET task_desc = " "
       SET tmp_get_work_room = sub_get_work_room(0)
       SET task_desc = trim(work->encntrs[e].tasks[t].desc,3)
       SET tmp_height = task_description(rpt_calcheight,tmp_work_room,becont)
       IF (((_yoffset+ tmp_height) >= y_end_of_page))
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET tmp_get_work_room = sub_get_work_room(0)
       ENDIF
       SET d0 = task_description(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET tmp_get_work_room = sub_get_work_room(0)
         SET d0 = task_description(rpt_render,tmp_work_room,becont)
       ENDWHILE
       SET o = 0
       IF ((work->encntrs[e].tasks[t].order_slot > 0))
        SET o = work->encntrs[e].tasks[t].order_slot
        IF (_yoffset >= y_end_of_page)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
        ENDIF
        SET order_desc = " "
        SET tmp_get_work_room = sub_get_work_room(0)
        SET order_desc = build2(work->encntrs[e].orders[o].desc," to start at ",format(work->encntrs[
          e].orders[o].start_dt_tm,"mm/dd/yyyy hh:mm;;d"))
        SET tmp_height = order_description(rpt_calcheight,tmp_work_room,becont)
        IF (((_yoffset+ tmp_height) >= y_end_of_page))
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET tmp_get_work_room = sub_get_work_room(0)
        ENDIF
        SET d0 = order_description(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET d0 = sub_foot_page(0)
          SET d0 = sub_head_page(0)
          SET tmp_get_work_room = sub_get_work_room(0)
          SET d0 = order_description(rpt_render,tmp_work_room,becont)
        ENDWHILE
        SET order_desc = " "
        IF (_yoffset >= y_end_of_page)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET order_desc = "Continued from Previous Page"
         SET d0 = order_description(rpt_render,0.20,becont)
         SET order_desc = " "
        ENDIF
        IF (trim(work->encntrs[e].orders[o].od_line,3) > " ")
         SET order_details_text = " "
         SET tmp_get_work_room = sub_get_work_room(0)
         SET order_details_text = work->encntrs[e].orders[o].od_line
         SET d0 = order_details(rpt_render,tmp_work_room,becont)
         WHILE (becont=1)
           SET d0 = sub_foot_page(0)
           SET d0 = sub_head_page(0)
           SET order_desc = "Continued from Previous Page"
           SET d0 = order_description(rpt_render,0.20,becont)
           SET order_desc = " "
           SET tmp_get_work_room = sub_get_work_room(0)
           SET d0 = order_details(rpt_render,tmp_work_room,becont)
         ENDWHILE
        ENDIF
        SET order_details_text = " "
        IF (_yoffset >= y_end_of_page)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET order_desc = "Continued from Previous Page"
         SET d0 = order_description(rpt_render,0.20,becont)
         SET order_desc = " "
        ENDIF
        IF (trim(work->encntrs[e].orders[o].comment_line,3) > " ")
         SET order_instructions_text = " "
         SET tmp_get_work_room = sub_get_work_room(0)
         SET order_instructions_text = work->encntrs[e].orders[o].comment_line
         SET d0 = order_instructions(rpt_render,tmp_work_room,becont)
         WHILE (becont=1)
           SET d0 = sub_foot_page(0)
           SET d0 = sub_head_page(0)
           SET order_desc = "Continued from Previous Page"
           SET d0 = order_description(rpt_render,0.20,becont)
           SET order_desc = " "
           SET tmp_get_work_room = sub_get_work_room(0)
           SET d0 = order_instructions(rpt_render,tmp_work_room,becont)
         ENDWHILE
        ENDIF
        SET order_instructions_text = " "
        IF (_yoffset >= y_end_of_page)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET order_desc = "Continued from Previous Page"
         SET d0 = order_description(rpt_render,0.20,becont)
         SET order_desc = " "
        ENDIF
        SET tmp_get_work_room = sub_get_work_room(0)
        SET task_last_done_text = " "
        IF (trim(work->encntrs[e].orders[o].last_task_result,3) > " ")
         SET task_last_done_text = trim(work->encntrs[e].orders[o].last_task_result,3)
        ELSE
         SET task_last_done_text = "Not Previously Given"
        ENDIF
        SET d0 = task_last_done(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET d0 = sub_foot_page(0)
          SET d0 = sub_head_page(0)
          SET order_desc = "Continued from Previous Page"
          SET d0 = order_description(rpt_render,0.20,becont)
          SET order_desc = " "
          SET tmp_get_work_room = sub_get_work_room(0)
          SET d0 = task_last_done(rpt_render,tmp_work_room,becont)
        ENDWHILE
        SET task_last_done_text = " "
       ENDIF
       SET tmp_height = task_details(rpt_calcheight)
       IF (((_yoffset+ tmp_height) >= y_end_of_page))
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET task_desc = "Continued from Previous Page"
        SET d0 = task_description(rpt_render,0.20,becont)
        SET task_desc = " "
       ENDIF
       SET task_sch_text = " "
       SET task_sch_text = work->encntrs[e].tasks[t].sch_dt_tm
       SET task_status_text = " "
       SET task_status_text = trim(uar_get_code_display(work->encntrs[e].tasks[t].task_status_cd),3)
       SET d0 = task_details(rpt_render)
       IF (_yoffset >= y_end_of_page)
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET task_desc = "Continued from Previous Page"
        SET d0 = task_description(rpt_render,0.20,becont)
        SET task_desc = " "
       ENDIF
       SET d0 = task_addtl_notes(rpt_render)
       SET d0 = report_divider(rpt_render)
     ENDFOR
     SET tmp_height = ((0.40+ task_details(rpt_calcheight))+ task_addtl_notes(rpt_calcheight))
     FOR (b = 1 TO blank_task_cnt)
       IF (((_yoffset+ tmp_height) >= y_end_of_page))
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
       ENDIF
       SET task_desc = " "
       SET task_sch_text = " "
       SET task_status_text = " "
       SET d0 = task_description(rpt_render,0.20,becont)
       SET d0 = order_description(rpt_render,0.20,becont)
       SET d0 = task_details(rpt_render)
       SET d0 = task_addtl_notes(rpt_render)
       IF (b < blank_task_cnt)
        SET d0 = report_divider(rpt_render)
       ENDIF
     ENDFOR
   ENDFOR
   SET tab = 0
   SET t = 0
   IF (((_yoffset+ refused_task_height) >= y_end_of_page))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = report_divider(rpt_render)
   SET d0 = refused_tasks(rpt_render)
   FOR (r = 1 TO refused_task_cnt)
     SET d0 = refused_task_notes(rpt_render)
   ENDFOR
   SET d0 = report_divider(rpt_render)
   IF (((_yoffset+ refused_task_height) >= y_end_of_page))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = sub_foot_report(0)
 ENDFOR
 IF (test_ind=1)
  SET d0 = finalizereport( $OUTDEV)
 ENDIF
#exit_script
 IF (test_ind=1)
  CALL echorecord(work)
 ENDIF
END GO

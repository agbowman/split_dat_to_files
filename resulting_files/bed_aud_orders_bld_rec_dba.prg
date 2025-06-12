CREATE PROGRAM bed_aud_orders_bld_rec:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
 )
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
 SET med_cd = get_code_value(6026,"MED")
 SET pharm_cd = get_code_value(6000,"PHARMACY")
 SET reschedorder_cd = get_code_value(6016,"RESCHEDORDER")
 SET yes_cd = get_code_value(6017,"YES")
 SET include_cd = get_code_value(6017,"INCLUDE")
 SET exclude_cd = get_code_value(6017,"EXCLUDE")
 SET order_cd = get_code_value(6003,"ORDER")
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Recommendation"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Grade"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET rcnt = 10
 SET stat = alterlist(reply->statlist,rcnt)
 SET stat = alterlist(reply->rowlist,rcnt)
 FOR (rcnt = 1 TO 10)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,2)
 ENDFOR
 SET reply->run_status_flag = 1
 SET reply->rowlist[1].celllist[1].string_value = concat(
  "The 'auto cancel orders on discharge' setting",
  " or 'inpatient discharge flag' setting is not defined.")
 SET reply->rowlist[1].celllist[2].string_value = "Pass"
 SET reply->statlist[1].statistic_meaning = "ORDERSCNCLONDISCHINDISCH"
 SET reply->statlist[1].total_items = 0
 SET reply->statlist[1].qualifying_items = 0
 SET reply->statlist[1].status_flag = 1
 SELECT INTO "nl:"
  FROM config_prefs cp
  PLAN (cp
   WHERE cp.config_name IN ("DSCH_CANCEL", "INDSCH_FLAG"))
  DETAIL
   IF (cp.config_value != "ALL"
    AND cp.config_value != "ORD"
    AND cp.config_value != "TEMP")
    reply->rowlist[1].celllist[2].string_value = "Fail", reply->statlist[1].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[2].celllist[1].string_value = concat(
  "The initial length of time to explode out order instances"," is <= 24 hours.")
 SET reply->rowlist[2].celllist[2].string_value = "Pass"
 SET reply->statlist[2].statistic_meaning = "ORDERSBRINITEXPLTIME"
 SET reply->statlist[2].total_items = 0
 SET reply->statlist[2].qualifying_items = 0
 SET reply->statlist[2].status_flag = 1
 SELECT INTO "nl:"
  FROM eco_flex_schedule efs
  DETAIL
   IF (efs.initial_explosion_hours > 24)
    reply->rowlist[2].celllist[2].string_value = "Fail", reply->statlist[2].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[3].celllist[1].string_value = concat(
  "The subsequent length of time to explode out order instances"," is <= 24 hours.")
 SET reply->rowlist[3].celllist[2].string_value = "Pass"
 SET reply->statlist[3].statistic_meaning = "ORDERSBRSUBSEXPLTIME"
 SET reply->statlist[3].total_items = 0
 SET reply->statlist[3].qualifying_items = 0
 SET reply->statlist[3].status_flag = 1
 SELECT INTO "nl:"
  FROM ops_job oj,
   ops_task ot
  PLAN (oj
   WHERE oj.name="ORM Explode Continuing Orders"
    AND oj.active_ind=1)
   JOIN (ot
   WHERE ot.ops_job_id=oj.ops_job_id
    AND ot.active_ind=1)
  DETAIL
   IF (((ot.frequency_type != 2) OR (((ot.time_ind != 1) OR (((ot.time_interval > 24
    AND ot.time_interval_ind=1) OR (ot.time_interval > 1440
    AND ot.time_interval_ind=0)) )) )) )
    reply->rowlist[3].celllist[2].string_value = "Fail", reply->statlist[3].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[4].celllist[1].string_value = concat(
  "The 'auto cancel orders on discharge' setting",
  " or 'outpatient discharge flag' setting is not defined.")
 SET reply->rowlist[4].celllist[2].string_value = "Pass"
 SET reply->statlist[4].statistic_meaning = "ORDCNCLONDISCHOROUTDISCH"
 SET reply->statlist[4].total_items = 0
 SET reply->statlist[4].qualifying_items = 0
 SET reply->statlist[4].status_flag = 1
 SELECT INTO "nl:"
  FROM config_prefs cp
  PLAN (cp
   WHERE cp.config_name IN ("DSCH_CANCEL", "OUTDSCH_FLAG"))
  DETAIL
   IF (cp.config_value != "ALL"
    AND cp.config_value != "ORD"
    AND cp.config_value != "TEMP")
    reply->rowlist[4].celllist[2].string_value = "Fail", reply->statlist[4].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[5].celllist[1].string_value = concat("The overdue time on all tasks is set to",
  " <= 1 hour.")
 SET reply->rowlist[5].celllist[2].string_value = "Pass"
 SET reply->statlist[5].statistic_meaning = "ORDERSBRTASKOVERDUETIME"
 SET reply->statlist[5].total_items = 0
 SET reply->statlist[5].qualifying_items = 0
 SET reply->statlist[5].status_flag = 1
 SELECT INTO "nl:"
  FROM order_task ot
  PLAN (ot
   WHERE ot.active_ind=1)
  DETAIL
   IF (((ot.overdue_units=1
    AND ot.overdue_min > 60) OR (ot.overdue_units=2
    AND ot.overdue_min > 1)) )
    reply->rowlist[5].celllist[2].string_value = "Fail", reply->statlist[5].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[6].celllist[1].string_value = concat("No retention times are set on medication",
  " tasks.")
 SET reply->rowlist[6].celllist[2].string_value = "Pass"
 SET reply->statlist[6].statistic_meaning = "ORDERSBRNOMEDRTNTIMES"
 SET reply->statlist[6].total_items = 0
 SET reply->statlist[6].qualifying_items = 0
 SET reply->statlist[6].status_flag = 1
 SELECT INTO "nl:"
  FROM order_task ot
  PLAN (ot
   WHERE ot.task_type_cd=med_cd
    AND ot.active_ind=1)
  DETAIL
   IF (ot.retain_time > 0)
    reply->rowlist[6].celllist[2].string_value = "Fail", reply->statlist[6].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[7].celllist[1].string_value = concat(
  "The 'reschedule order' privilege is turned OFF"," for medication orders.")
 SET reply->rowlist[7].celllist[2].string_value = "Pass"
 SET reply->statlist[7].statistic_meaning = "ORDERSBRRESCHMEDORD"
 SET reply->statlist[7].total_items = 0
 SET reply->statlist[7].qualifying_items = 0
 SET reply->statlist[7].status_flag = 1
 SELECT INTO "nl:"
  FROM privilege p,
   priv_loc_reltn plr,
   code_value cv,
   prsnl p2
  PLAN (p
   WHERE p.privilege_cd=reschedorder_cd
    AND p.priv_value_cd=yes_cd)
   JOIN (plr
   WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
    AND plr.active_ind=1
    AND plr.position_cd > 0)
   JOIN (cv
   WHERE cv.code_value=plr.position_cd
    AND cv.active_ind=1)
   JOIN (p2
   WHERE p2.position_cd=plr.position_cd
    AND p2.active_ind=1)
  HEAD p.privilege_id
   reply->rowlist[7].celllist[2].string_value = "Fail", reply->statlist[7].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->statlist[7].status_flag != 3))
  SELECT INTO "nl:"
   FROM privilege p,
    priv_loc_reltn plr,
    prsnl p2
   PLAN (p
    WHERE p.privilege_cd=reschedorder_cd
     AND p.priv_value_cd=yes_cd)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND plr.active_ind=1
     AND plr.person_id > 0)
    JOIN (p2
    WHERE p2.person_id=plr.person_id
     AND p2.active_ind=1)
   DETAIL
    reply->rowlist[7].celllist[2].string_value = "Fail", reply->statlist[7].status_flag = 3, reply->
    run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->statlist[7].status_flag != 3))
  SELECT INTO "nl:"
   FROM privilege p,
    privilege_exception pe,
    priv_loc_reltn plr,
    code_value cv,
    prsnl p2
   PLAN (p
    WHERE p.privilege_cd=reschedorder_cd
     AND p.priv_value_cd=include_cd)
    JOIN (pe
    WHERE pe.privilege_id=p.privilege_id
     AND pe.exception_entity_name="CATALOG TYPE"
     AND pe.exception_id=pharm_cd)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND plr.active_ind=1
     AND plr.position_cd > 0)
    JOIN (cv
    WHERE cv.code_value=plr.position_cd
     AND cv.active_ind=1)
    JOIN (p2
    WHERE p2.position_cd=plr.position_cd
     AND p2.active_ind=1)
   HEAD p.privilege_id
    reply->rowlist[7].celllist[2].string_value = "Fail", reply->statlist[7].status_flag = 3, reply->
    run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->statlist[7].status_flag != 3))
  SELECT INTO "nl:"
   FROM privilege p,
    privilege_exception pe,
    priv_loc_reltn plr,
    prsnl p2
   PLAN (p
    WHERE p.privilege_cd=reschedorder_cd
     AND p.priv_value_cd=include_cd)
    JOIN (pe
    WHERE pe.privilege_id=p.privilege_id
     AND pe.exception_entity_name="CATALOG TYPE"
     AND pe.exception_id=pharm_cd)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND plr.active_ind=1
     AND plr.person_id > 0)
    JOIN (p2
    WHERE p2.person_id=plr.person_id
     AND p2.active_ind=1)
   DETAIL
    reply->rowlist[7].celllist[2].string_value = "Fail", reply->statlist[7].status_flag = 3, reply->
    run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->statlist[7].status_flag != 3))
  SELECT INTO "nl:"
   FROM privilege p,
    (dummyt d  WITH seq = 1),
    privilege_exception pe,
    priv_loc_reltn plr,
    code_value cv,
    prsnl p2
   PLAN (p
    WHERE p.privilege_cd=reschedorder_cd
     AND p.priv_value_cd=exclude_cd)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND plr.active_ind=1
     AND plr.position_cd > 0)
    JOIN (cv
    WHERE cv.code_value=plr.position_cd
     AND cv.active_ind=1)
    JOIN (p2
    WHERE p2.position_cd=plr.position_cd
     AND p2.active_ind=1)
    JOIN (d)
    JOIN (pe
    WHERE pe.privilege_id=p.privilege_id
     AND pe.exception_entity_name="CATALOG TYPE"
     AND pe.exception_id=pharm_cd)
   HEAD p.privilege_id
    reply->rowlist[7].celllist[2].string_value = "Fail", reply->statlist[7].status_flag = 3, reply->
    run_status_flag = 3
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
 IF ((reply->statlist[7].status_flag != 3))
  SELECT INTO "nl:"
   FROM privilege p,
    (dummyt d  WITH seq = 1),
    privilege_exception pe,
    priv_loc_reltn plr,
    prsnl p2
   PLAN (p
    WHERE p.privilege_cd=reschedorder_cd
     AND p.priv_value_cd=exclude_cd)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND plr.active_ind=1
     AND plr.person_id > 0)
    JOIN (p2
    WHERE p2.person_id=plr.person_id
     AND p2.active_ind=1)
    JOIN (d)
    JOIN (pe
    WHERE pe.privilege_id=p.privilege_id
     AND pe.exception_entity_name="CATALOG TYPE"
     AND pe.exception_id=pharm_cd)
   DETAIL
    reply->rowlist[7].celllist[2].string_value = "Fail", reply->statlist[7].status_flag = 3, reply->
    run_status_flag = 3
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
 SET reply->rowlist[8].celllist[1].string_value = concat("The 'med list encntr filter' is set to",
  " all.")
 SET reply->rowlist[8].celllist[2].string_value = "Pass"
 SET reply->statlist[8].statistic_meaning = "ORDERSBRMEDLSTENCFILT"
 SET reply->statlist[8].total_items = 0
 SET reply->statlist[8].qualifying_items = 0
 SET reply->statlist[8].status_flag = 1
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap
  PLAN (nvp
   WHERE nvp.pvc_name="MED_LIST_ENCNTR_FILTER"
    AND nvp.active_ind=1
    AND nvp.pvc_value != "ALL")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.position_cd=0
    AND ap.prsnl_id=0)
  DETAIL
   reply->rowlist[8].celllist[2].string_value = "Fail", reply->statlist[8].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap,
   prsnl p
  PLAN (nvp
   WHERE nvp.pvc_name="MED_LIST_ENCNTR_FILTER"
    AND nvp.active_ind=1
    AND nvp.pvc_value != "ALL")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.prsnl_id > 0)
   JOIN (p
   WHERE p.person_id=ap.prsnl_id
    AND p.active_ind=1)
  DETAIL
   reply->rowlist[8].celllist[2].string_value = "Fail", reply->statlist[8].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap,
   code_value cv,
   prsnl p
  PLAN (nvp
   WHERE nvp.pvc_name="MED_LIST_ENCNTR_FILTER"
    AND nvp.active_ind=1
    AND nvp.pvc_value != "ALL")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.position_cd > 0)
   JOIN (cv
   WHERE cv.code_value=ap.position_cd
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.active_ind=1
    AND p.position_cd=ap.position_cd)
  DETAIL
   reply->rowlist[8].celllist[2].string_value = "Fail", reply->statlist[8].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 SET reply->rowlist[9].celllist[1].string_value = concat(
  "No medication order formats have the FUTURE"," ORDER indicator field.")
 SET reply->rowlist[9].celllist[2].string_value = "Pass"
 SET reply->statlist[9].statistic_meaning = "ORDERSBRMEDFUTUREORD"
 SET reply->statlist[9].total_items = 0
 SET reply->statlist[9].qualifying_items = 0
 SET reply->statlist[9].status_flag = 1
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   oe_format_fields off,
   order_entry_fields oeflds
  PLAN (oef
   WHERE oef.catalog_type_cd=pharm_cd
    AND oef.action_type_cd=order_cd)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.accept_flag != 2)
   JOIN (oeflds
   WHERE oeflds.oe_field_id=off.oe_field_id
    AND oeflds.oe_field_meaning_id=120)
  DETAIL
   reply->rowlist[9].celllist[2].string_value = "Fail", reply->statlist[9].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->statlist[9].status_flag=1))
  SELECT INTO "nl:"
   FROM order_entry_format oef,
    oe_format_fields off,
    order_entry_fields oeflds,
    accept_format_flexing aff
   PLAN (oef
    WHERE oef.catalog_type_cd=pharm_cd
     AND oef.action_type_cd=order_cd)
    JOIN (off
    WHERE off.oe_format_id=oef.oe_format_id)
    JOIN (oeflds
    WHERE oeflds.oe_field_id=off.oe_field_id
     AND oeflds.oe_field_meaning_id=120)
    JOIN (aff
    WHERE aff.oe_field_id=off.oe_field_id
     AND aff.action_type_cd=order_cd
     AND aff.oe_format_id=oef.oe_format_id
     AND aff.accept_flag != 2)
   DETAIL
    reply->rowlist[9].celllist[2].string_value = "Fail", reply->statlist[9].status_flag = 3, reply->
    run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 SET reply->rowlist[10].celllist[1].string_value = concat(
  "Multum interaction checking is turned on if medication"," orders are being placed.")
 SET reply->rowlist[10].celllist[2].string_value = "Pass"
 SET reply->statlist[10].statistic_meaning = "ORDERSBRMULTINTCHK"
 SET reply->statlist[10].total_items = 0
 SET reply->statlist[10].qualifying_items = 0
 SET reply->statlist[10].status_flag = 1
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap
  PLAN (nvp
   WHERE nvp.pvc_name IN ("MULPREF", "MULINTR")
    AND nvp.pvc_value != "1"
    AND nvp.active_ind=1)
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.position_cd=0
    AND ap.prsnl_id=0)
  DETAIL
   reply->rowlist[10].celllist[2].string_value = "Fail", reply->statlist[10].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->statlist[10].status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name IN ("MULPREF", "MULINTR")
     AND nvp.pvc_value != "1")
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.prsnl_id > 0)
    JOIN (p
    WHERE p.person_id=ap.prsnl_id
     AND p.active_ind=1)
   DETAIL
    reply->rowlist[10].celllist[2].string_value = "Fail", reply->statlist[10].status_flag = 3, reply
    ->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->statlist[10].status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap,
    code_value cv,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name IN ("MULPREF", "MULINTR")
     AND nvp.pvc_value != "1")
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.position_cd > 0)
    JOIN (cv
    WHERE cv.code_value=ap.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.active_ind=1
     AND p.position_cd=ap.position_cd)
   DETAIL
    reply->rowlist[10].celllist[2].string_value = "Fail", reply->statlist[10].status_flag = 3, reply
    ->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("orders_build_rec_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO

CREATE PROGRAM bhs_ma_message_center_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Type" = ""
  WITH outdev, type
 FREE RECORD rpt_data
 RECORD rpt_data(
   1 qual[*]
     2 pool_name = vc
     2 prsnl_group_id = f8
     2 clinical = i4
     2 l_clinical_general_cnt = i4
     2 clinical_sick = i4
     2 clinical_priority = i4
     2 clinical_priority_sick = i4
     2 clinical_ind = i4
     2 rx = i4
     2 l_rx_general_cnt = i4
     2 rx_priority = i4
     2 rx_ind = i4
     2 l_admin_cnt = i4
     2 l_admin_general_cnt = i4
     2 l_admin_priority_cnt = i4
     2 l_admin_ind = i4
 )
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE opened = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 DECLARE pending = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE phonemsg = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG"))
 SELECT INTO "nl:"
  FROM prsnl_group pg
  PLAN (pg
   WHERE pg.active_ind=1
    AND pg.prsnl_group_type_cd=0)
  ORDER BY pg.prsnl_group_name
  HEAD REPORT
   cnt = 0
  HEAD pg.prsnl_group_name
   IF (((findstring("CLINICAL",cnvtupper(pg.prsnl_group_name))) OR (((findstring("PRESCRIPTION",
    cnvtupper(pg.prsnl_group_name))) OR (((findstring("Greenfield Gastroenterology - Clinic",pg
    .prsnl_group_name)) OR (findstring("ADMIN",cnvtupper(pg.prsnl_group_name)))) )) )) )
    IF (mod(cnt,10)=0)
     stat = alterlist(rpt_data->qual,(cnt+ 10))
    ENDIF
    cnt += 1, rpt_data->qual[cnt].pool_name = pg.prsnl_group_name, rpt_data->qual[cnt].prsnl_group_id
     = pg.prsnl_group_id
    IF (((findstring("CLINICAL",cnvtupper(pg.prsnl_group_name))) OR (findstring(
     "Greenfield Gastroenterology - Clinic",pg.prsnl_group_name))) )
     rpt_data->qual[cnt].clinical_ind = 1
    ENDIF
    IF (findstring("PRESCRIPTION",cnvtupper(pg.prsnl_group_name)))
     rpt_data->qual[cnt].rx_ind = 1
    ENDIF
    IF (findstring("ADMIN",cnvtupper(pg.prsnl_group_name)))
     rpt_data->qual[cnt].l_admin_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(rpt_data->qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta,
   (dummyt d  WITH seq = size(rpt_data->qual,5))
  PLAN (d)
   JOIN (taa
   WHERE (taa.assign_prsnl_group_id=rpt_data->qual[d.seq].prsnl_group_id)
    AND taa.task_status_cd IN (opened, pending)
    AND taa.assign_prsnl_group_id > 0
    AND taa.active_ind=1
    AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.task_type_cd=phonemsg)
  ORDER BY d.seq, ta.task_id
  HEAD d.seq
   null
  HEAD ta.task_id
   IF (findstring("Clinical",rpt_data->qual[d.seq].pool_name) > 0)
    rpt_data->qual[d.seq].clinical += 1
    IF (findstring("SICK",cnvtupper(ta.msg_subject)) > 0)
     IF (ta.stat_ind=1)
      rpt_data->qual[d.seq].clinical_priority_sick += 1
     ELSE
      rpt_data->qual[d.seq].clinical_sick += 1
     ENDIF
    ELSE
     IF (ta.stat_ind=1)
      rpt_data->qual[d.seq].clinical_priority += 1
     ELSE
      rpt_data->qual[d.seq].l_clinical_general_cnt += 1
     ENDIF
    ENDIF
   ELSEIF (findstring("Prescription",rpt_data->qual[d.seq].pool_name) > 0)
    rpt_data->qual[d.seq].rx += 1
    IF (ta.stat_ind=1)
     rpt_data->qual[d.seq].rx_priority += 1
    ELSE
     rpt_data->qual[d.seq].l_rx_general_cnt += 1
    ENDIF
   ELSEIF (findstring("ADMIN",cnvtupper(rpt_data->qual[d.seq].pool_name)) > 0)
    rpt_data->qual[d.seq].l_admin_cnt += 1
    IF (ta.stat_ind=1)
     rpt_data->qual[d.seq].l_admin_priority_cnt += 1
    ELSE
     rpt_data->qual[d.seq].l_admin_general_cnt += 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (( $TYPE="Clinical"))
  SELECT INTO  $OUTDEV
   pool_name = substring(1,45,rpt_data->qual[d.seq].pool_name), total_messages = rpt_data->qual[d.seq
   ].clinical, total_general = rpt_data->qual[d.seq].l_clinical_general_cnt,
   total_general_sick = rpt_data->qual[d.seq].clinical_sick, total_priority_general = rpt_data->qual[
   d.seq].clinical_priority, total_priority_sick = rpt_data->qual[d.seq].clinical_priority_sick
   FROM (dummyt d  WITH seq = size(rpt_data->qual,5))
   PLAN (d
    WHERE (rpt_data->qual[d.seq].clinical_ind=1))
   ORDER BY d.seq
   WITH format, separator = " "
  ;end select
 ELSEIF (( $TYPE="Prescription"))
  SELECT INTO  $OUTDEV
   pool_name = substring(1,45,rpt_data->qual[d.seq].pool_name), total_messages = rpt_data->qual[d.seq
   ].rx, total_general = rpt_data->qual[d.seq].l_rx_general_cnt,
   total_priority = rpt_data->qual[d.seq].rx_priority
   FROM (dummyt d  WITH seq = size(rpt_data->qual,5))
   PLAN (d
    WHERE (rpt_data->qual[d.seq].rx_ind=1))
   ORDER BY d.seq
   WITH format, separator = " "
  ;end select
 ELSEIF (( $TYPE="Admin"))
  SELECT INTO  $OUTDEV
   pool_name = substring(1,45,rpt_data->qual[d.seq].pool_name), total_messages = rpt_data->qual[d.seq
   ].l_admin_cnt, total_general = rpt_data->qual[d.seq].l_admin_general_cnt,
   total_priority = rpt_data->qual[d.seq].l_admin_priority_cnt
   FROM (dummyt d  WITH seq = size(rpt_data->qual,5))
   PLAN (d
    WHERE (rpt_data->qual[d.seq].l_admin_ind=1))
   ORDER BY d.seq
   WITH format, separator = " "
  ;end select
 ENDIF
#exit_script
END GO

CREATE PROGRAM bhs_phy_metrics
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Date" = curdate
  WITH outdev, prompt2
 SET report_date = cnvtdate( $2)
 SET err_chk = "    "
 FREE RECORD phy_count
 RECORD phy_count(
   1 total_physicians = i4
   1 seq[*]
     2 physician_name = c25
     2 person_id = f8
     2 minutes_online = i2
     2 scripts_signed = i2
     2 scripts_cosign = i2
     2 historical_med = i2
     2 problems = i2
     2 allergies = i2
     2 endorsed_results = i2
     2 name_two = c25
     2 error_log = c24
 )
 SELECT INTO  $OUTDEV
  name = substring(1,25,p.name_full_formatted), o.application_number, o.minutes,
  o.start_day
  FROM omf_app_ctx_day_st o,
   prsnl p
  PLAN (o
   WHERE o.start_day=cnvtdate( $2)
    AND o.application_number IN (600005, 600036, 1000300, 3071000)
    AND o.minutes > 0)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.physician_ind=1)
  ORDER BY p.name_full_formatted, o.application_number
  HEAD REPORT
   all_phys = 0
  HEAD p.name_full_formatted
   total_min = 0, all_phys = (all_phys+ 1), stat = alterlist(phy_count->seq,all_phys),
   phy_count->total_physicians = all_phys, phy_count->seq[all_phys].physician_name = name, phy_count
   ->seq[all_phys].person_id = p.person_id,
   phy_count->seq[all_phys].error_log = "OK1."
  DETAIL
   total_min = (total_min+ o.minutes)
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].minutes_online = total_min
  WITH nocounter, separator = " ", format
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name2 = substring(1,25,p.name_full_formatted), a.allergy_instance_id
  FROM prsnl p,
   allergy a
  PLAN (p
   WHERE p.person_id IN (
   (SELECT
    oo.person_id
    FROM omf_app_ctx_day_st oo
    WHERE oo.start_day=cnvtdate( $2)
     AND oo.application_number IN (600005, 600036, 1000300, 3071000)
     AND oo.minutes > 0))
    AND p.physician_ind=1)
   JOIN (a
   WHERE a.created_prsnl_id=outerjoin(p.person_id)
    AND a.created_dt_tm >= outerjoin(cnvtdatetime(cnvtdate( $2),0000))
    AND a.created_dt_tm <= outerjoin(cnvtdatetime(cnvtdate( $2),2359)))
  ORDER BY p.name_full_formatted, a.allergy_instance_id, 0
  HEAD REPORT
   all_phys = 0
  HEAD p.name_full_formatted
   all_phys = (all_phys+ 1), allergy_cnt = 0, check_name = phy_count->seq[all_phys].physician_name
   IF (name2=check_name)
    err_chk = "OK2."
   ELSE
    phy_count->seq[all_phys].name_two = name2, err_chk = "All "
   ENDIF
   phy_count->seq[all_phys].name_two = name2, errors = phy_count->seq[all_phys].error_log, phy_count
   ->seq[all_phys].error_log = build(errors,err_chk)
  DETAIL
   IF (a.allergy_instance_id > 0)
    allergy_cnt = (allergy_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].allergies = allergy_cnt
  WITH maxrec = 100000
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name2 = substring(1,25,p.name_full_formatted), pr.problem_instance_id
  FROM prsnl p,
   problem pr
  PLAN (p
   WHERE p.person_id IN (
   (SELECT
    oo.person_id
    FROM omf_app_ctx_day_st oo
    WHERE oo.start_day=cnvtdate( $2)
     AND oo.application_number IN (600005, 600036, 1000300, 3071000)
     AND oo.minutes > 0))
    AND p.physician_ind=1)
   JOIN (pr
   WHERE pr.active_status_prsnl_id=outerjoin(p.person_id)
    AND pr.active_status_dt_tm >= outerjoin(cnvtdatetime(cnvtdate( $2),0000))
    AND pr.active_status_dt_tm <= outerjoin(cnvtdatetime(cnvtdate( $2),2359)))
  ORDER BY p.name_full_formatted, pr.problem_instance_id, 0
  HEAD REPORT
   all_phys = 0
  HEAD p.name_full_formatted
   all_phys = (all_phys+ 1), problem_cnt = 0, check_name = phy_count->seq[all_phys].physician_name
   IF (name2=check_name)
    err_chk = "OK3."
   ELSE
    phy_count->seq[all_phys].name_two = name2, err_chk = "Pro "
   ENDIF
   phy_count->seq[all_phys].name_two = name2, errors = phy_count->seq[all_phys].error_log, phy_count
   ->seq[all_phys].error_log = build(errors,err_chk)
  DETAIL
   IF (pr.problem_instance_id > 0)
    problem_cnt = (problem_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].problems = problem_cnt
  WITH maxrec = 100000
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name2 = substring(1,25,p.name_full_formatted), cev.action_type_cd
  FROM prsnl p,
   ce_event_prsnl cev
  PLAN (p
   WHERE p.person_id IN (
   (SELECT
    oo.person_id
    FROM omf_app_ctx_day_st oo
    WHERE oo.start_day=cnvtdate( $2)
     AND oo.application_number IN (600005, 600036, 1000300, 3071000)
     AND oo.minutes > 0))
    AND p.physician_ind=1)
   JOIN (cev
   WHERE cev.action_prsnl_id=outerjoin(p.person_id)
    AND cev.action_type_cd=outerjoin(882486)
    AND cev.action_dt_tm >= outerjoin(cnvtdatetime(cnvtdate( $2),0000))
    AND cev.action_dt_tm <= outerjoin(cnvtdatetime(cnvtdate( $2),2359)))
  ORDER BY p.name_full_formatted, cev.event_id, 0
  HEAD REPORT
   all_phys = 0
  HEAD p.name_full_formatted
   all_phys = (all_phys+ 1), results_cnt = 0, check_name = phy_count->seq[all_phys].physician_name
   IF (name2=check_name)
    err_chk = "OK4."
   ELSE
    phy_count->seq[all_phys].name_two = name2, err_chk = "Res "
   ENDIF
   phy_count->seq[all_phys].name_two = name2, errors = phy_count->seq[all_phys].error_log, phy_count
   ->seq[all_phys].error_log = build(errors,err_chk)
  DETAIL
   IF (cev.event_id > 0)
    results_cnt = (results_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].endorsed_results = results_cnt
  WITH maxrec = 100000
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name2 = substring(1,25,p.name_full_formatted), o.review_dt_tm, o.review_type_flag,
  orde.activity_type_cd, orde.order_id
  FROM order_review o,
   prsnl p,
   orders orde
  PLAN (p
   WHERE p.person_id IN (
   (SELECT
    oo.person_id
    FROM omf_app_ctx_day_st oo
    WHERE oo.start_day=cnvtdate( $2)
     AND oo.application_number IN (600005, 600036, 1000300, 3071000)
     AND oo.minutes > 0))
    AND p.physician_ind=1)
   JOIN (o
   WHERE o.review_personnel_id=outerjoin(p.person_id)
    AND o.review_dt_tm >= outerjoin(cnvtdatetime(cnvtdate( $2),0000))
    AND o.review_dt_tm <= outerjoin(cnvtdatetime(cnvtdate( $2),2359))
    AND o.review_type_flag=outerjoin(2))
   JOIN (orde
   WHERE orde.order_id=outerjoin(o.order_id)
    AND orde.activity_type_cd=outerjoin(705))
  ORDER BY p.name_full_formatted, o.order_id, 0
  HEAD REPORT
   all_phys = 0
  HEAD p.name_full_formatted
   all_phys = (all_phys+ 1), cosign_cnt = 0, check_name = phy_count->seq[all_phys].physician_name
   IF (name2=check_name)
    err_chk = "OK5."
   ELSE
    phy_count->seq[all_phys].name_two = name2, err_chk = "CoS "
   ENDIF
   phy_count->seq[all_phys].name_two = name2, errors = phy_count->seq[all_phys].error_log, phy_count
   ->seq[all_phys].error_log = build(errors,err_chk)
  DETAIL
   IF (orde.activity_type_cd > 0)
    cosign_cnt = (cosign_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].scripts_cosign = cosign_cnt, cosign_cnt = 0
  WITH maxrec = 100000
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name2 = substring(1,25,p.name_full_formatted), orde.order_id
  FROM prsnl p,
   orders orde,
   dummyt d1,
   dummyt d2
  PLAN (p
   WHERE p.person_id IN (
   (SELECT
    oo.person_id
    FROM omf_app_ctx_day_st oo
    WHERE oo.start_day=cnvtdate( $2)
     AND oo.application_number IN (600005, 600036, 1000300, 3071000)
     AND oo.minutes > 0))
    AND p.physician_ind=1)
   JOIN (d1)
   JOIN (orde
   WHERE orde.orig_order_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0000) AND cnvtdatetime(cnvtdate( $2
     ),2359)
    AND orde.active_status_prsnl_id=p.person_id
    AND ((orde.activity_type_cd=705) OR (orde.activity_type_cd=681
    AND orde.catalog_cd=61245331)) )
   JOIN (d2)
  ORDER BY p.name_full_formatted, orde.order_id, 0
  HEAD REPORT
   all_phys = 0
  HEAD p.name_full_formatted
   all_phys = (all_phys+ 1), home_cnt = 0, hosp_cnt = 0,
   check_name = phy_count->seq[all_phys].physician_name
   IF (name2=check_name)
    err_chk = "OK6."
   ELSE
    phy_count->seq[all_phys].name_two = name2, err_chk = "Scr "
   ENDIF
   phy_count->seq[all_phys].name_two = name2, errors = phy_count->seq[all_phys].error_log, phy_count
   ->seq[all_phys].error_log = build(errors,err_chk)
  DETAIL
   IF (orde.activity_type_cd=705)
    hosp_cnt = (hosp_cnt+ 1)
   ENDIF
   IF (orde.activity_type_cd=681
    AND orde.catalog_cd=61245331)
    home_cnt = (home_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].historical_med = home_cnt, phy_count->seq[all_phys].scripts_signed =
   hosp_cnt
  WITH maxrec = 100000, dontcare = orde
 ;end select
 SET size_array = (phy_count->total_physicians - 1)
 SELECT INTO  $OUTDEV
  d.seq, pname = phy_count->seq[d.seq].physician_name, id = phy_count->seq[d.seq].person_id,
  time = phy_count->seq[d.seq].minutes_online, allergy = phy_count->seq[d.seq].allergies, problem =
  phy_count->seq[d.seq].problems,
  scripts = phy_count->seq[d.seq].scripts_signed, cosign = phy_count->seq[d.seq].scripts_cosign,
  history = phy_count->seq[d.seq].historical_med,
  endorse = phy_count->seq[d.seq].endorsed_results, last_name = phy_count->seq[d.seq].name_two,
  errors = phy_count->seq[d.seq].error_log
  FROM (dummyt d  WITH seq = value(size_array))
  ORDER BY d.seq
  HEAD PAGE
   row + 1, col 40, "P H Y S I C I A N   M E T R I C S   F O R   C H A R T S   O P E N E D",
   row + 2, col 5, "Report Run On:",
   col 21, curdate"mm/dd/yyyy;;d", col 31,
   " at ", col 35, curtime"hh:mm;;s",
   col 60, "For Date: ", col 70,
   report_date"mm/dd/yyyy;;d", col 100, "PAGE: ",
   col 107, curpage, row + 3,
   col 1, "Physician Name", col 32,
   "Time Online", col 45, "Rx signed",
   col 58, "Total Rx ", col 70,
   "Hist Meds", col 81, "Problems",
   col 94, "Allergies", col 106,
   "Results", col 120, "TOTAL",
   row + 1
  DETAIL
   grand_total = (((((scripts+ cosign)+ history)+ problem)+ allergy)+ endorse), total_script = (
   scripts+ cosign), row + 1,
   col 1, pname, col 27,
   time, col 39, scripts,
   col 51, total_script, col 63,
   history, col 75, problem,
   col 87, allergy, col 99,
   endorse, col 112, grand_total
  FOOT REPORT
   row + 3, col 40, "E N D   O F   R E P O R T",
   row + 1
  WITH maxrec = 1000
 ;end select
END GO

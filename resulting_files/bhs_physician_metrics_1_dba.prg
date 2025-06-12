CREATE PROGRAM bhs_physician_metrics_1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Date" = curdate
  WITH outdev, prompt2
 FREE RECORD phy_count
 RECORD phy_count(
   1 total_physicians = i4
   1 seq[1000]
     2 physician_name = c20
     2 person_id = f8
     2 minutes_online = i2
     2 scripts_signed = i2
     2 scripts_total = i2
     2 historical_med = i2
     2 problems = i2
     2 allergies = i2
     2 endorsed_results = i2
     2 name_two = c10
 )
 SELECT INTO  $OUTDEV
  name = substring(1,20,p.name_full_formatted), o.application_number, o.minutes,
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
  HEAD PAGE
   row + 2, col 30, "Minutes",
   row + 1, col 1, "Physician Name",
   col 30, "Online", row + 1
  HEAD p.name_full_formatted
   total_min = 0, all_phys = (all_phys+ 1), phy_count->total_physicians = all_phys,
   phy_count->seq[all_phys].physician_name = name, phy_count->seq[all_phys].person_id = p.person_id
  DETAIL
   total_min = (total_min+ o.minutes)
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].minutes_online = total_min
  WITH nocounter, separator = " ", format
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name2 = substring(1,20,p.name_full_formatted), a.allergy_instance_id
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
   all_phys = (all_phys+ 1), allergy_cnt = 0, phy_count->seq[all_phys].name_two = name2
  DETAIL
   IF (a.allergy_instance_id > 0)
    allergy_cnt = (allergy_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].allergies = allergy_cnt
  WITH maxrec = 100000
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name3 = substring(1,20,p.name_full_formatted), pr.problem_instance_id
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
   all_phys = (all_phys+ 1), problem_cnt = 0, phy_count->seq[all_phys].name_two = name3
  DETAIL
   IF (pr.problem_instance_id > 0)
    problem_cnt = (problem_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].problems = problem_cnt
  WITH maxrec = 100000
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  name3 = substring(1,20,p.name_full_formatted), orde.order_id
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
   phy_count->seq[all_phys].name_two = name3
  DETAIL
   IF (orde.activity_type_cd=705)
    hosp_cnt = (hosp_cnt+ 1)
   ENDIF
   IF (orde.activity_type_cd=681
    AND orde.catalog_cd=61245331)
    home_cnt = (home_cnt+ 1)
   ENDIF
  FOOT  p.name_full_formatted
   phy_count->seq[all_phys].historical_med = home_cnt, phy_count->seq[all_phys].scripts_total =
   hosp_cnt
  FOOT REPORT
   FOR (i = 1 TO all_phys)
     pname = phy_count->seq[i].physician_name, id = phy_count->seq[i].person_id, time = phy_count->
     seq[i].minutes_online,
     allergy = phy_count->seq[i].allergies, problem = phy_count->seq[i].problems, scripts = phy_count
     ->seq[i].scripts_total,
     history = phy_count->seq[i].historical_med, new_name = phy_count->seq[i].name_two, row + 1,
     col 1, pname, col 27,
     time, col 39, scripts,
     col 51, history, col 63,
     problem, col 75, allergy,
     col 87, new_name
   ENDFOR
  WITH maxrec = 100000, dontcare = orde
 ;end select
END GO

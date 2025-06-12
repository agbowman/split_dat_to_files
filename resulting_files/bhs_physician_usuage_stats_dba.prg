CREATE PROGRAM bhs_physician_usuage_stats:dba
 FREE RECORD physician_count
 RECORD physician_count(
   1 phys[*]
     2 physician_name = c25
     2 phys_position = c40
     2 person_id = f8
     2 total_minutes = i4
     2 script_signed = i4
     2 script_cosigned = i4
     2 historical_meds = i4
     2 problems = i4
     2 allergies = i4
     2 results = i4
     2 total_count = i4
 )
 DECLARE cnt_script_signed = i4
 DECLARE cnt_script_cosign = i4
 DECLARE cnt_historical_med = i4
 DECLARE cnt_problems = i4
 DECLARE cnt_allergies = i4
 DECLARE cnt_results = i4
 DECLARE cnt_total = i4
 DECLARE phys_cnt = i4
 SET phys_cnt = 0
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd),
  o.log_ins, o.minutes, o.start_day
  FROM omf_app_ctx_day_st o,
   prsnl p
  PLAN (o
   WHERE o.start_day=cnvtdate(081506)
    AND o.application_number=600005)
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY p.name_full_formatted
  HEAD p.name_full_formatted
   row + 0, cnt_script_signed = 0, cnt_script_cosign = 0,
   cnt_historical_med = 0, cnt_problems = 0, cnt_allergies = 0,
   cnt_results = 0, cnt_total = 0, phys_cnt = (phys_cnt+ 1),
   stat = alterlist(physician_count->phys,phys_cnt), physician_count->phys[phys_cnt].physician_name
    = substring(1,25,p.name_full_formatted), physician_count->phys[phys_cnt].phys_position =
   substring(1,40,p_position_disp),
   physician_count->phys[phys_cnt].person_id = p.person_id
  DETAIL
   physician_count->phys[phys_cnt].total_minutes = o.minutes, row + 1, col 10,
   p.name_full_formatted, col 60, p.person_id,
   row + 1
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
END GO

CREATE PROGRAM bhs_hnam_sou_detail:dba
 SET cnt = 0
 RECORD usage(
   1 named_prsnl_total = f8
   1 prsnl_cnt = i4
   1 prsnl_qual[*]
     2 user_name = vc
     2 position = vc
     2 signon = vc
   1 pc_user_cnt = i4
   1 pc_user_qual[*]
     2 user_name = vc
     2 position = vc
     2 end_effective_dt_tm = dq8
     2 signon = vc
     2 times_in_cnt = i4
     2 minutes_used = f8
     2 last_used = dq8
     2 application = vc
   1 pco_user_cnt = i4
   1 pco_user_qual[*]
     2 user_name = vc
     2 position = vc
     2 end_effective_dt_tm = dq8
     2 signon = vc
     2 times_in_cnt = i4
     2 minutes_used = f8
     2 last_used = dq8
     2 application = vc
   1 pv_user_cnt = i4
   1 pv_user_qual[*]
     2 user_name = vc
     2 position = vc
     2 end_effective_dt_tm = dq8
     2 signon = vc
     2 times_in_cnt = i4
     2 minutes_used = f8
     2 last_used = dq8
     2 application = vc
   1 profile_user_cnt = i4
   1 profile_user_qual[*]
     2 user_name = vc
     2 position = vc
     2 end_effective_dt_tm = dq8
     2 signon = vc
     2 times_in_cnt = i4
     2 minutes_used = f8
     2 last_used = dq8
     2 application = vc
 )
 SET usage->named_prsnl_total = 0
 SET usage->prsnl_cnt = 0
 SET starttime = 0000
 SET endtime = 2400
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.username > "  "
   AND p.person_id > 0
   AND p.active_ind=1
   AND p.active_status_cd=188
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   usage->named_prsnl_total = (usage->named_prsnl_total+ 1), usage->prsnl_cnt = (usage->prsnl_cnt+ 1),
   atc = usage->prsnl_cnt,
   stat = alterlist(usage->prsnl_qual,atc), usage->prsnl_qual[atc].signon = p.username, usage->
   prsnl_qual[atc].position = uar_get_code_display(p.position_cd),
   usage->prsnl_qual[atc].user_name = concat(trim(substring(1,20,p.name_last_key)),"-",trim(substring
     (1,15,p.name_first_key)))
  WITH nocounter
 ;end select
 SET search_date =  $1
 SET end_date =  $2
 SET ac = 0
 SET usage->pc_user_cnt = 0
 SET usage->pco_user_cnt = 0
 SET usage->pv_user_cnt = 0
 SET usage->profile_user_cnt = 0
 SELECT INTO "nl:"
  oac.application_number, oac.person_id, p.person_id
  FROM omf_app_ctx_day_st oac,
   prsnl p
  PLAN (oac
   WHERE oac.person_id > 0
    AND oac.application_number IN (600005, 950001, 1120000, 1120014, 1120016,
   1120033, 961000)
    AND oac.start_day >= cnvtdate(search_date)
    AND oac.start_day <= cnvtdate(end_date))
   JOIN (p
   WHERE oac.person_id=p.person_id)
  ORDER BY oac.person_id, oac.application_number, oac.start_day
  HEAD oac.person_id
   x = 0
  HEAD oac.application_number
   IF (oac.application_number=600005)
    usage->pc_user_cnt = (usage->pc_user_cnt+ 1), uc = usage->pc_user_cnt, stat = alterlist(usage->
     pc_user_qual,uc),
    usage->pc_user_qual[uc].position = uar_get_code_display(p.position_cd), usage->pc_user_qual[uc].
    end_effective_dt_tm = p.end_effective_dt_tm, usage->pc_user_qual[uc].signon = p.username,
    usage->pc_user_qual[uc].user_name = concat(trim(substring(1,20,p.name_last_key)),"-",trim(
      substring(1,15,p.name_first_key))), usage->pc_user_qual[uc].times_in_cnt = 0, usage->
    pc_user_qual[uc].minutes_used = 0,
    usage->pc_user_qual[uc].application = "PowerChart / CareNet "
   ENDIF
   IF (oac.application_number IN (1120000, 1120014, 1120016, 1120033, 1120039))
    usage->profile_user_cnt = (usage->profile_user_cnt+ 1), uc = usage->profile_user_cnt, stat =
    alterlist(usage->profile_user_qual,uc),
    usage->profile_user_qual[uc].position = uar_get_code_display(p.position_cd), usage->
    profile_user_qual[uc].end_effective_dt_tm = p.end_effective_dt_tm, usage->profile_user_qual[uc].
    signon = p.username,
    usage->profile_user_qual[uc].user_name = concat(trim(substring(1,20,p.name_last_key)),"-",trim(
      substring(1,15,p.name_first_key))), usage->profile_user_qual[uc].times_in_cnt = 0, usage->
    profile_user_qual[uc].minutes_used = 0
    CASE (oac.application_number)
     OF 1120000:
      usage->profile_user_qual[uc].application = "Profile - Patient Deficiency Analysis"
     OF 1120014:
      usage->profile_user_qual[uc].application = "Profile - Chart Coding"
     OF 1120016:
      usage->profile_user_qual[uc].application = "Profile - Request Queue"
     OF 1120033:
      usage->profile_user_qual[uc].application = "Profile - Tracking"
     OF 1120039:
      usage->profile_user_qual[uc].application = "Profile - HIM Request Manager"
    ENDCASE
   ENDIF
   IF (oac.application_number=950001)
    usage->pv_user_cnt = (usage->pv_user_cnt+ 1), uc = usage->pv_user_cnt, stat = alterlist(usage->
     pv_user_qual,uc),
    usage->pv_user_qual[uc].position = uar_get_code_display(p.position_cd), usage->pv_user_qual[uc].
    end_effective_dt_tm = p.end_effective_dt_tm, usage->pv_user_qual[uc].signon = p.username,
    usage->pv_user_qual[uc].user_name = concat(trim(substring(1,20,p.name_last_key)),"-",trim(
      substring(1,15,p.name_first_key))), usage->pv_user_qual[uc].times_in_cnt = 0, usage->
    pv_user_qual[uc].minutes_used = 0,
    usage->pv_user_qual[uc].application = "PowerVision"
   ENDIF
   IF (oac.application_number=961000)
    usage->pco_user_cnt = (usage->pco_user_cnt+ 1), uc = usage->pco_user_cnt, stat = alterlist(usage
     ->pco_user_qual,uc),
    usage->pco_user_qual[uc].position = uar_get_code_display(p.position_cd), usage->pco_user_qual[uc]
    .end_effective_dt_tm = p.end_effective_dt_tm, usage->pco_user_qual[uc].signon = p.username,
    usage->pco_user_qual[uc].user_name = concat(trim(substring(1,20,p.name_last_key)),"-",trim(
      substring(1,15,p.name_first_key))), usage->pco_user_qual[uc].times_in_cnt = 0, usage->
    pco_user_qual[uc].minutes_used = 0,
    usage->pco_user_qual[uc].application = "PowerChart Office"
   ENDIF
  DETAIL
   IF (oac.application_number=600005)
    usage->pc_user_qual[uc].times_in_cnt = (usage->pc_user_qual[uc].times_in_cnt+ oac.frequency),
    usage->pc_user_qual[uc].minutes_used = (usage->pc_user_qual[uc].minutes_used+ oac.minutes), usage
    ->pc_user_qual[uc].last_used = oac.start_day
   ENDIF
   IF (oac.application_number=961000)
    usage->pco_user_qual[uc].times_in_cnt = (usage->pco_user_qual[uc].times_in_cnt+ oac.frequency),
    usage->pco_user_qual[uc].minutes_used = (usage->pco_user_qual[uc].minutes_used+ oac.minutes),
    usage->pco_user_qual[uc].last_used = oac.start_day
   ENDIF
   IF (oac.application_number=950001)
    usage->pv_user_qual[uc].times_in_cnt = (usage->pv_user_qual[uc].times_in_cnt+ oac.frequency),
    usage->pv_user_qual[uc].minutes_used = (usage->pv_user_qual[uc].minutes_used+ oac.minutes), usage
    ->pv_user_qual[uc].last_used = oac.start_day
   ENDIF
   IF (oac.application_number IN (1120000, 1120014, 1120016, 1120033, 1120039))
    usage->profile_user_qual[uc].times_in_cnt = (usage->profile_user_qual[uc].times_in_cnt+ oac
    .frequency), usage->profile_user_qual[uc].minutes_used = (usage->profile_user_qual[uc].
    minutes_used+ oac.minutes), usage->profile_user_qual[uc].last_used = oac.start_day
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "mine"
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  DETAIL
   disp_line = fillstring(175," "), disp_line = concat("Metric",",","Name of User",",","Position",
    ",","Signon"), row + 1,
   col 1, disp_line
   FOR (pc = 1 TO usage->prsnl_cnt)
     disp_line = fillstring(70," "), disp_line = concat("Active Personnel",",",trim(substring(1,35,
        usage->prsnl_qual[pc].user_name)),",",trim(substring(1,30,usage->prsnl_qual[pc].position)),
      ",",trim(substring(1,10,usage->prsnl_qual[pc].signon))), row + 1,
     col 1, disp_line
   ENDFOR
   row + 3, col 1, " ",
   disp_line = fillstring(70," "), disp_line = concat("Application",",","User",",","Position",
    ",","UserName",",","Times Used",",",
    "Minutes Used",",","Last Used",",","End Effective Date"), row + 1,
   col 1, disp_line
   FOR (uu = 1 TO usage->pc_user_cnt)
     start_dt = format(usage->pc_user_qual[uu].last_used,"mm/dd/yy;;d"), start_disp = concat(" ",
      start_dt), disp_line = fillstring(70," "),
     disp_line = concat(trim(usage->pc_user_qual[uu].application),",",trim(substring(1,30,usage->
        pc_user_qual[uu].user_name)),",",trim(substring(1,30,usage->pc_user_qual[uu].position)),
      ",",trim(substring(1,30,usage->pc_user_qual[uu].signon)),",",trim(cnvtstring(cnvtint(usage->
         pc_user_qual[uu].times_in_cnt))),",",
      trim(cnvtstring(cnvtint(usage->pc_user_qual[uu].minutes_used))),",",trim(start_disp),",",format
      (usage->pc_user_qual[uu].end_effective_dt_tm,"MM/DD/YYYY;;D")), row + 1, col 1,
     disp_line
   ENDFOR
   row + 3
   FOR (uu = 1 TO usage->pco_user_cnt)
     start_dt = format(usage->pco_user_qual[uu].last_used,"mm/dd/yy;;d"), start_disp = concat(" ",
      start_dt), disp_line = fillstring(70," "),
     disp_line = concat(trim(usage->pco_user_qual[uu].application),",",trim(substring(1,30,usage->
        pco_user_qual[uu].user_name)),",",trim(substring(1,30,usage->pco_user_qual[uu].position)),
      ",",trim(substring(1,30,usage->pco_user_qual[uu].signon)),",",trim(cnvtstring(cnvtint(usage->
         pco_user_qual[uu].times_in_cnt))),",",
      trim(cnvtstring(cnvtint(usage->pco_user_qual[uu].minutes_used))),",",trim(start_disp),",",
      format(usage->pco_user_qual[uu].end_effective_dt_tm,"MM/DD/YYYY;;D")), row + 1, col 1,
     disp_line
   ENDFOR
   row + 3
   FOR (uu = 1 TO usage->pv_user_cnt)
     start_dt = format(usage->pv_user_qual[uu].last_used,"mm/dd/yy;;d"), start_disp = concat(" ",
      start_dt), disp_line = fillstring(70," "),
     disp_line = concat(trim(usage->pv_user_qual[uu].application),",",trim(substring(1,30,usage->
        pv_user_qual[uu].user_name)),",",trim(substring(1,30,usage->pv_user_qual[uu].position)),
      ",",trim(substring(1,30,usage->pv_user_qual[uu].signon)),",",trim(cnvtstring(cnvtint(usage->
         pv_user_qual[uu].times_in_cnt))),",",
      trim(cnvtstring(cnvtint(usage->pv_user_qual[uu].minutes_used))),",",trim(start_disp),",",format
      (usage->pv_user_qual[uu].end_effective_dt_tm,"MM/DD/YYYY;;D")), row + 1, col 1,
     disp_line
   ENDFOR
   row + 3
   FOR (uu = 1 TO usage->profile_user_cnt)
     start_dt = format(usage->profile_user_qual[uu].last_used,"mm/dd/yy;;d"), start_disp = concat(" ",
      start_dt), disp_line = fillstring(70," "),
     disp_line = concat(trim(usage->profile_user_qual[uu].application),",",trim(substring(1,30,usage
        ->profile_user_qual[uu].user_name)),",",trim(substring(1,30,usage->profile_user_qual[uu].
        position)),
      ",",trim(substring(1,30,usage->profile_user_qual[uu].signon)),",",trim(cnvtstring(cnvtint(usage
         ->profile_user_qual[uu].times_in_cnt))),",",
      trim(cnvtstring(cnvtint(usage->profile_user_qual[uu].minutes_used))),",",trim(start_disp),",",
      format(usage->profile_user_qual[uu].end_effective_dt_tm,"MM/DD/YYYY;;D")), row + 1, col 1,
     disp_line
   ENDFOR
  WITH nocounter, maxcol = 178
 ;end select
END GO

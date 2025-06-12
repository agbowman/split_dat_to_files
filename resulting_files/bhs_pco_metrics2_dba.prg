CREATE PROGRAM bhs_pco_metrics2:dba
 EXECUTE bhs_sys_stand_subroutine
 IF (( $2=999))
  SET start_date = datetimefind(cnvtdatetime((curdate - 10),0),"M","B","B")
  SET end_date = datetimefind(cnvtdatetime((curdate - 10),0),"M","E","E")
  SET beg_date_disp = format(start_date,"MM/DD/YYYY;;d")
  SET end_date_disp = format(end_date,"MM/DD/YYYY;;d")
 ELSE
  SET start_date = cnvtdatetime(cnvtdate( $2),0)
  SET end_date = cnvtdatetime(cnvtdate( $3),235959)
  SET beg_date_disp = format(cnvtdate( $2),"MM/DD/YYYY;;d")
  SET end_date_disp = format(cnvtdate( $3),"MM/DD/YYYY;;d")
 ENDIF
 CALL echo(beg_date_disp)
 CALL echo(end_date_disp)
 IF (findstring("@", $1) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(cnvtdate( $2),0),
     "MMDDYYYY;;D")))
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE idx = i4
 SET start = 1
 SET report_date = concat("Report Period:  ",format(start_date,"mm/dd/yyyy;;q")," to ",format(
   end_date,"mm/dd/yyyy;;q"))
 SET endorse_results = uar_get_code_by("DISPLAY_KEY",21,"ENDORSE")
 SET perform_procedure = uar_get_code_by("DISPLAY_KEY",21,"PERFORM")
 SET pharmacy_orders = uar_get_code_by("DISPLAY_KEY",106,"PHARMACY")
 SET communication_orders = uar_get_code_by("DISPLAY_KEY",106,"COMMUNICATIONORDERS")
 SET home_meds = uar_get_code_by("DISPLAY_KEY",200,"HOMEMEDSUPDATEDINMEDICATIONPROFILE")
 DECLARE output_string = vc
 FREE RECORD phy_count
 RECORD phy_count(
   1 total_physicians = i4
   1 seq[*]
     2 physician_name = c25
     2 phys_last = c15
     2 phys_first = c10
     2 person_id = f8
     2 minutes_online = i4
     2 scripts_signed = i4
     2 scripts_cosign = i4
     2 all_scripts = i4
     2 historical_med = i4
     2 problems = i4
     2 allergies = i4
     2 endorsed_results = i4
     2 procedures = i4
     2 all_activity = i4
 )
 SELECT INTO "nl:"
  name = substring(1,25,p.name_full_formatted), phy_first = substring(1,10,p.name_first), phy_last =
  substring(1,15,p.name_last)
  FROM omf_app_ctx_month_st omf,
   prsnl p
  PLAN (p
   WHERE p.physician_ind=1
    AND p.username > " ")
   JOIN (omf
   WHERE omf.person_id=p.person_id
    AND omf.start_month=cnvtdatetime(start_date)
    AND omf.application_number=961000)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   all_phys = 0, stat = alterlist(phy_count->seq,10)
  DETAIL
   total_min = 0, all_phys = (all_phys+ 1)
   IF (mod(all_phys,10)=1)
    stat = alterlist(phy_count->seq,(all_phys+ 9))
   ENDIF
   phy_count->total_physicians = all_phys, phy_count->seq[all_phys].physician_name = name, phy_count
   ->seq[all_phys].phys_first = replace(phy_first,",","",0),
   phy_count->seq[all_phys].phys_last = replace(phy_last,",","",0), phy_count->seq[all_phys].
   person_id = p.person_id, phy_count->seq[all_phys].minutes_online = omf.minutes
  FOOT REPORT
   stat = alterlist(phy_count->seq,all_phys)
  WITH nocounter
 ;end select
 SET phys_count = size(phy_count->seq,5)
 FOR (x = 1 TO phys_count)
   SELECT INTO "nl"
    FROM allergy a
    PLAN (a
     WHERE (a.created_prsnl_id=phy_count->seq[x].person_id)
      AND a.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date))
    HEAD REPORT
     allergy_cnt = 0
    DETAIL
     allergy_cnt = (allergy_cnt+ 1)
    FOOT REPORT
     phy_count->seq[x].allergies = allergy_cnt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM problem pr
    PLAN (pr
     WHERE (pr.active_status_prsnl_id=phy_count->seq[x].person_id)
      AND pr.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date))
    HEAD REPORT
     problem_cnt = 0
    DETAIL
     problem_cnt = (problem_cnt+ 1)
    FOOT REPORT
     phy_count->seq[x].problems = problem_cnt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM ce_event_prsnl cev
    PLAN (cev
     WHERE (cev.action_prsnl_id=phy_count->seq[x].person_id)
      AND cev.action_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date))
    HEAD REPORT
     results_cnt = 0, procedure_cnt = 0
    DETAIL
     IF (cev.action_type_cd=endorse_results)
      results_cnt = (results_cnt+ 1)
     ELSEIF (cev.action_type_cd=perform_procedure)
      procedure_cnt = (procedure_cnt+ 1)
     ENDIF
    FOOT REPORT
     phy_count->seq[x].endorsed_results = results_cnt, phy_count->seq[x].procedures = procedure_cnt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_review o
    PLAN (o
     WHERE (o.review_personnel_id=phy_count->seq[x].person_id)
      AND o.review_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
      AND o.review_type_flag=2
      AND  EXISTS (
     (SELECT
      orde.order_id
      FROM orders orde
      WHERE orde.order_id=o.order_id
       AND orde.activity_type_cd=pharmacy_orders)))
    HEAD REPORT
     cosign_cnt = 0
    DETAIL
     cosign_cnt = (cosign_cnt+ 1)
    FOOT REPORT
     phy_count->seq[x].scripts_cosign = cosign_cnt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM orders orde
    PLAN (orde
     WHERE (orde.status_prsnl_id=phy_count->seq[x].person_id)
      AND orde.orig_order_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date))
    HEAD REPORT
     home_cnt = 0, hosp_cnt = 0
    DETAIL
     IF (orde.activity_type_cd=pharmacy_orders)
      hosp_cnt = (hosp_cnt+ 1)
     ENDIF
     IF (orde.activity_type_cd=communication_orders
      AND orde.catalog_cd=home_meds)
      home_cnt = (home_cnt+ 1)
     ENDIF
    FOOT REPORT
     phy_count->seq[x].historical_med = home_cnt, phy_count->seq[x].scripts_signed = hosp_cnt
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO phys_count)
  SET phy_count->seq[x].all_activity = ((((((phy_count->seq[x].scripts_signed+ phy_count->seq[x].
  scripts_cosign)+ phy_count->seq[x].historical_med)+ phy_count->seq[x].problems)+ phy_count->seq[x].
  allergies)+ phy_count->seq[x].endorsed_results)+ phy_count->seq[x].procedures)
  SET phy_count->seq[x].all_scripts = (phy_count->seq[x].scripts_signed+ phy_count->seq[x].
  scripts_cosign)
 ENDFOR
 IF (( $4="1"))
  SET size_array = phys_count
  SELECT INTO  $1
   d.seq, pname = phy_count->seq[d.seq].physician_name, id = phy_count->seq[d.seq].person_id,
   time = phy_count->seq[d.seq].minutes_online, allergy = phy_count->seq[d.seq].allergies, problem =
   phy_count->seq[d.seq].problems,
   procedures = phy_count->seq[d.seq].procedures, scripts = phy_count->seq[d.seq].scripts_signed,
   cosign = phy_count->seq[d.seq].scripts_cosign,
   total_script = phy_count->seq[d.seq].all_scripts, history = phy_count->seq[d.seq].historical_med,
   endorse = phy_count->seq[d.seq].endorsed_results,
   totals = phy_count->seq[d.seq].all_activity
   FROM (dummyt d  WITH seq = value(size_array))
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY d.seq
   HEAD PAGE
    row + 1, col 40, "P H Y S I C I A N   M E T R I C S   F O R   C H A R T S   O P E N E D",
    row + 2, col 5, "Report Run On:",
    col 50, report_date, col 102,
    "PAGE", col 107, curpage,
    row + 1, col 5, curdate"mm/dd/yyyy;;d",
    col 15, " at ", col 19,
    curtime"hh:mm;;s", row + 1, col 1,
    "Physician Name", col 32, "Time Online",
    col 44, "Rx signed", col 54,
    "Total Rx ", col 64, "Hist Meds",
    col 74, "Problems", col 84,
    "Allergies", col 94, "Results",
    col 104, "Procedures", col 116,
    "Totals", row + 1
   DETAIL
    grand_total = (((((scripts+ cosign)+ history)+ problem)+ allergy)+ endorse), total_script = (
    scripts+ cosign), row + 1,
    col 1, pname, col 27,
    time, col 46, scripts"####",
    col 56, total_script"####", col 66,
    history"####", col 76, problem"####",
    col 86, allergy"####", col 96,
    endorse"####", col 106, procedures"####",
    col 116, totals"#####"
   FOOT REPORT
    row + 3, col 40, "E N D   O F   R E P O R T",
    row + 1
   WITH maxrec = 1000
  ;end select
 ENDIF
 IF (( $4="2"))
  SET size_array = phys_count
  SELECT INTO  $1
   pname = phy_count->seq[d.seq].physician_name, time = phy_count->seq[d.seq].minutes_online, script
    = phy_count->seq[d.seq].scripts_signed,
   cosign = phy_count->seq[d.seq].scripts_cosign, scripts = phy_count->seq[d.seq].all_scripts,
   history = phy_count->seq[d.seq].historical_med,
   problem = phy_count->seq[d.seq].problems, allergy = phy_count->seq[d.seq].allergies, endorse =
   phy_count->seq[d.seq].endorsed_results,
   procedures = phy_count->seq[d.seq].procedures, totals = phy_count->seq[d.seq].all_activity
   FROM (dummyt d  WITH seq = value(size_array))
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY d.seq
   WITH noformfeed, format
  ;end select
 ENDIF
 IF (( $4="3"))
  SET size_array = phys_count
  SELECT INTO value(output_dest)
   d.seq, pname = phy_count->seq[d.seq].physician_name, plast = phy_count->seq[d.seq].phys_last,
   pfirst = phy_count->seq[d.seq].phys_first, id = phy_count->seq[d.seq].person_id, time = phy_count
   ->seq[d.seq].minutes_online,
   allergy = phy_count->seq[d.seq].allergies, problem = phy_count->seq[d.seq].problems, scripts =
   phy_count->seq[d.seq].scripts_signed,
   cosign = phy_count->seq[d.seq].scripts_cosign, all_script = phy_count->seq[d.seq].all_scripts,
   history = phy_count->seq[d.seq].historical_med,
   endorse = phy_count->seq[d.seq].endorsed_results, procedures = phy_count->seq[d.seq].procedures,
   totals = phy_count->seq[d.seq].all_activity
   FROM (dummyt d  WITH seq = value(size_array))
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY d.seq
   HEAD REPORT
    col 1, '"Date Range: ', beg_date_disp,
    " - ", end_date_disp, '"',
    row + 1, output_string = concat('"Phy Last","Phy First","Online Time","Rx signed",',
     '"Total RX","Hist Meds","Problems",','"Allergies","Results","Procedures","TOTAL"'), col 1,
    output_string, row + 1
   DETAIL
    output_string = build('"',plast,'"',',"',pfirst,
     '"',",",time,",",scripts,
     ",",all_script,",",history,",",
     problem,",",allergy,",",endorse,
     ",",procedures,",",totals), col 1, output_string,
    row + 1
   WITH noformfeed, maxrec = 1000, format = variable,
    compress, landscape
  ;end select
  IF (email_ind=1)
   DECLARE subject_line = vc
   SET filename_in = trim(concat(trim(output_dest),".dat"))
   SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
   SET subject_line = concat(curprog," - Baystate Medical Center Physician Metrics Report ",
    report_date)
   SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   CALL emailfile(filename_in,filename_out,trim( $1),subject_line,1)
  ENDIF
 ENDIF
#end_script
END GO

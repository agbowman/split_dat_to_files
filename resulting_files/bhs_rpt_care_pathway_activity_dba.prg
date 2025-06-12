CREATE PROGRAM bhs_rpt_care_pathway_activity:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Pathway Name (requires * for wildcard search):" = "*"
  WITH outdev, s_start_dt, s_stop_dt,
  s_path_name
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4003197_carepathway_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4109550143"))
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  patient_name = p.name_full_formatted, account# = ea.alias, cp_open_by = pr.name_full_formatted,
  cp_open = format(cp.beg_effective_dt_tm,"DD/MM/YY HH:mm:ss;;q"), cp_completed = cp
  .end_effective_dt_tm, cp_name = c.pathway_name,
  cp_status = uar_get_code_display(cp.pathway_activity_status_cd), cp_action = cpad
  .action_detail_entity_name, order_sentence = cpad.action_detail_text,
  action_status = uar_get_code_display(cpad.cp_action_detail_type_cd), order_place = format(cpad
   .updt_dt_tm,"DD/MM/YY HH:mm:ss;;q"), pr2.name_full_formatted,
  cpad.action_detail_entity_name
  FROM cp_pathway c,
   cp_pathway_activity cp,
   cp_pathway_action cpa,
   cp_pathway_action_detail cpad,
   encntr_alias ea,
   person p,
   prsnl pr,
   prsnl pr2
  PLAN (c
   WHERE (trim(cnvtupper(c.pathway_name),3)= $S_PATH_NAME)
    AND c.pathway_type_cd=mf_cs4003197_carepathway_cd)
   JOIN (cp
   WHERE cp.cp_pathway_id=c.cp_pathway_id
    AND cp.beg_effective_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt))
   JOIN (cpa
   WHERE cpa.pathway_instance_id=cp.pathway_instance_id)
   JOIN (cpad
   WHERE cpad.cp_pathway_action_id=cpa.cp_pathway_action_id
    AND cpad.action_detail_text != " ")
   JOIN (ea
   WHERE ea.encntr_id=cp.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (p
   WHERE p.person_id=cp.person_id)
   JOIN (pr
   WHERE pr.person_id=cp.prsnl_id)
   JOIN (pr2
   WHERE pr2.person_id=cpad.updt_id)
  ORDER BY cp.updt_dt_tm DESC
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO

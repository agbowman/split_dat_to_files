CREATE PROGRAM bhs_mu_rx_time:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Output File:" = " ",
  "Start Dt/Tm:" = cnvtdate(datetimeadd(datetimefind(sysdate,"W","B","B"),- (7))),
  "End Dt/Tm  :" = cnvtdate(datetimeadd(datetimefind(sysdate,"W","E","E"),- (7)))
  WITH outdev, output_file, beg_date,
  end_date
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_hlp_err
 DECLARE mf_dme_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DURABLEMEDICALEQUIPMENT"))
 DECLARE mf_medhist_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MEDICATIONHISTORY"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_outdev = vc WITH protect, constant(value( $OUTDEV))
 DECLARE ms_output_logical = vc WITH protect, constant("mu_out_rx_time")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE ms_dir_rem_mu_out = vc WITH protect, constant("/ciscoremuout/")
 DECLARE md_beg_dt_tm = dq8 WITH protect, constant(cnvtdatetime( $BEG_DATE,0))
 DECLARE md_end_dt_tm = dq8 WITH protect, constant(cnvtdatetime( $END_DATE,235959))
 DECLARE md_timer_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_timer_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_bp_npi = vc WITH protect, noconstant(" ")
 DECLARE ms_sp_npi = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_output_file = vc WITH protect, noconstant(trim( $OUTPUT_FILE,3))
 DECLARE mn_idx = i4 WITH protect, noconstant(0)
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_num = i4 WITH protect, noconstant(1)
 DECLARE mn_order_cnt = i4 WITH protect, noconstant(0)
 IF (validate(reply->c_status)=0)
  RECORD reply(
    1 c_status = c1
  )
 ENDIF
 SET reply->c_status = "F"
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 f_order_id = f8
     2 d_orig_order_dt_tm = dq8
     2 n_erx_ind = i4
     2 s_pharm_id = vc
     2 s_pharm_name = vc
     2 f_eid = f8
     2 s_fin = vc
     2 f_loc_facility_cd = f8
     2 s_loc_facility_disp = vc
     2 s_phy_name_full_formatted = vc
     2 s_phy_npi = vc
     2 f_phy_pid = f8
     2 s_phy_username = vc
 )
 IF (ms_output_file IN ("", " ", null))
  SET ms_output_file = concat("mu_rx_",format(md_beg_dt_tm,"YYYYMMDD;;D"),"_",format(md_end_dt_tm,
    "YYYYMMDD;;D"),".csv")
 ENDIF
 SET logical mu_out_rx_time value(ms_output_file)
 CALL echo(build("LOGICAL mu_out_rx_time:",logical(ms_output_logical)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown during setup.  Exiting.")
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script ",curprog))
 ENDIF
 CALL echo(concat("Output file:            ",logical(ms_output_logical)))
 CALL echo(concat("Range begin time:       ",format(md_beg_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")))
 CALL echo(concat("Range end time:         ",format(md_end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")))
 CALL echo(concat("Processing start time:  ",format(md_timer_start,"DD-MMM-YYYY HH:MM:SS;;D")))
 CALL echo(concat("Debug flag:             ",cnvtstring(ml_debug_flag)))
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   order_action oa,
   prsnl p,
   prsnl_alias pa,
   order_detail od,
   encntr_alias ea
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND  NOT (o.catalog_cd IN (mf_dme_cd, mf_medhist_cd))
    AND o.orig_ord_as_flag=1
    AND ((o.cki != "MUL.ORD!*") OR ( NOT ( EXISTS (
   (SELECT
    1
    FROM mltm_ndc_main_drug_code mnmdc
    WHERE mnmdc.drug_identifier=substring(9,6,o.cki)
     AND mnmdc.csa_schedule IN (2, 3, 4, 5)))))) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd=mf_ordered_cd
    AND oa.action_type_cd=mf_order_cd)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=mf_npi_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < sysdate
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_meaning= Outerjoin("*ROUTING*")) )
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < sysdate
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY o.order_id
  HEAD REPORT
   row + 0
  HEAD o.order_id
   mn_order_cnt += 1, stat = alterlist(temp->qual,mn_order_cnt), temp->qual[mn_order_cnt].f_order_id
    = o.order_id,
   temp->qual[mn_order_cnt].d_orig_order_dt_tm = o.orig_order_dt_tm, temp->qual[mn_order_cnt].f_eid
    = o.encntr_id, temp->qual[mn_order_cnt].s_fin = ea.alias,
   temp->qual[mn_order_cnt].f_loc_facility_cd = e.loc_facility_cd, temp->qual[mn_order_cnt].
   s_loc_facility_disp = uar_get_code_display(e.loc_facility_cd), temp->qual[mn_order_cnt].
   s_phy_name_full_formatted = p.name_full_formatted,
   temp->qual[mn_order_cnt].s_phy_npi = pa.alias, temp->qual[mn_order_cnt].f_phy_pid = p.person_id,
   temp->qual[mn_order_cnt].s_phy_username = p.username
  DETAIL
   IF (od.oe_field_meaning="ROUTINGPHARMACYID")
    temp->qual[mn_order_cnt].s_pharm_id = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="ROUTINGPHARMACYNAME")
    temp->qual[mn_order_cnt].s_pharm_name = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="REQROUTINGTYPE"
    AND trim(cnvtupper(od.oe_field_display_value))="ROUTE TO PHARMACY ELECTRONICALLY")
    temp->qual[mn_order_cnt].n_erx_ind = 1
   ENDIF
  FOOT  o.order_id
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 IF (size(temp->qual,5)=0)
  CALL echo("No prescriptions qualified.  Generating empty output file.")
  GO TO generate_report
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying prescriptions.  Exiting.")
  GO TO exit_script
 ENDIF
#generate_report
 SELECT INTO value(ms_output_logical)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("order_id,orig_order_dt_tm,eRx_ind,","encounter_id,account_number,",
    "order_date,physician_name_full_formatted,physician_npi,",
    "physician_person_id,physician_username"), row 0, col 0,
   ms_line
   FOR (mn_cnt = 1 TO size(temp->qual,5))
     ms_line = build(cnvtstring(temp->qual[mn_cnt].f_order_id),",",format(temp->qual[mn_cnt].
       d_orig_order_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),",",cnvtstring(temp->qual[mn_cnt].n_erx_ind),
      ",",cnvtstring(temp->qual[mn_cnt].f_eid),",",'"',temp->qual[mn_cnt].s_fin,
      '"',",",format(temp->qual[mn_cnt].d_orig_order_dt_tm,"YYYY-MM-DD;;D"),",",'"',
      temp->qual[mn_cnt].s_phy_name_full_formatted,'"',",",'"',temp->qual[mn_cnt].s_phy_npi,
      '"',",",cnvtstring(temp->qual[mn_cnt].f_phy_pid),",",'"',
      temp->qual[mn_cnt].s_phy_username,'"'), row + 1, col 0,
     ms_line
   ENDFOR
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 300, maxrow = 1
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while generating the output file.  Exiting.")
  GO TO exit_script
 ENDIF
 SET ms_ftp_cmd = concat("put ",ms_output_file)
 SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,".",
  ms_dir_rem_mu_out,"/dev/null"," ")
 SET md_timer_stop = sysdate
 SELECT INTO value(ms_outdev)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "The Meaningful Use Rx-based output csv file was created.",
   row + 1, ms_line = concat("Output file:            ",logical(ms_output_logical)), col 0,
   ms_line, row + 1, ms_line = concat("Records:                ",cnvtstring(size(temp->qual,5))),
   col 0, ms_line, row + 1,
   ms_line = concat("Range begin time:       ",format(md_beg_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")), col 0,
   ms_line,
   row + 1, ms_line = concat("Range end time:         ",format(md_end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"
     )), col 0,
   ms_line, row + 1, ms_line = concat("Processing start time:  ",format(md_timer_start,
     "DD-MMM-YYYY HH:MM:SS;;D")),
   col 0, ms_line, row + 1,
   ms_line = concat("Processing end time:    ",format(md_timer_stop,"DD-MMM-YYYY HH:MM:SS;;D")), col
   0, ms_line,
   row + 1, ms_line = concat("Processing time:        ",trim(cnvtstring(datetimediff(md_timer_stop,
       md_timer_start,4)),3)," minutes"), col 0,
   ms_line, row + 1, ms_line = concat("Debug flag:             ",cnvtstring(ml_debug_flag)),
   col 0, ms_line
  WITH nocounter
 ;end select
 SET reply->c_status = "S"
#exit_script
 IF (ml_debug_flag >= 5)
  CALL echorecord(temp)
 ENDIF
 IF (ml_debug_flag >= 0)
  CALL echo("############################################")
  CALL echo(concat("Status:                 ",reply->c_status))
  CALL echo(concat("Output file:            ",logical(ms_output_logical)))
  CALL echo(concat("Records:                ",cnvtstring(size(temp->qual,5))))
  CALL echo(concat("Processing start time:  ",format(md_timer_start,"DD-MMM-YYYY HH:MM:SS;;D")))
  CALL echo(concat("Processing start time:  ",format(md_timer_stop,"DD-MMM-YYYY HH:MM:SS;;D")))
  CALL echo(concat("Processing time:        ",trim(cnvtstring(datetimediff(md_timer_stop,
       md_timer_start,4)),3)," minutes"))
  CALL echo(concat("Debug flag:             ",cnvtstring(ml_debug_flag)))
  CALL echo("############################################")
 ENDIF
 SET stat = bhs_clear_error(0)
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Exiting script ",curprog," with status ",reply->c_status))
 ELSE
  FREE RECORD temp
 ENDIF
END GO

CREATE PROGRAM bhs_rpt_escript_auditnew:dba
 SET output_file = "jrwout"
 SET beg_date = cnvtdatetime("01-OCT-2011 00:00:00")
 SET end_date = cnvtdatetime("29-FEB-2012 23:59:59")
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
 DECLARE ms_output_logical = vc WITH protect, constant("mu_out_rx_time")
 DECLARE ms_ftp_host = vc WITH protect, constant("172.17.10.5")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE ms_dir_rem_mu_out = vc WITH protect, constant("/ciscoremuout/")
 DECLARE md_beg_dt_tm = dq8 WITH protect, constant(cnvtdatetime(beg_date))
 DECLARE md_end_dt_tm = dq8 WITH protect, constant(cnvtdatetime(end_date))
 DECLARE md_timer_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_timer_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_bp_npi = vc WITH protect, noconstant(" ")
 DECLARE ms_sp_npi = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE mn_idx = i4 WITH protect, noconstant(0)
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_num = i4 WITH protect, noconstant(1)
 DECLARE mn_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE s_pharm_name = vc WITH protect, noconstant(" ")
 IF (validate(reply->c_status)=0)
  RECORD reply(
    1 c_status = c1
  )
 ENDIF
 SET reply->c_status = "F"
 SET n_erx_ind = 0
 FREE RECORD temp
 RECORD temp(
   1 total[1]
     2 n_ord_cnt = f8
     2 n_baystate_cnt = f8
     2 n_nonbaystate_cnt = f8
     2 n_e_cnt = f8
   1 qual[*]
     2 pharm = vc
     2 sortorder = i4
   1 n_other_cnt = f8
 )
 FREE RECORD pharm
 RECORD pharm(
   1 list[*]
     2 name = vc
     2 address = vc
     2 city = vc
     2 distance = vc
     2 n_e_cnt = f8
     2 sortorder = i4
 )
 SET stat = alterlist(pharm->list,size(requestin->list_0,5))
 FOR (x = 1 TO size(requestin->list_0,5))
   SET pharm->list[x].address = requestin->list_0[x].address
   SET pharm->list[x].city = requestin->list_0[x].city
   SET pharm->list[x].name = requestin->list_0[x].name
   SET pharm->list[x].distance = requestin->list_0[x].distance
 ENDFOR
 CALL echo(build("LOGICAL mu_out_rx_time:",logical(output_file)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown during setup.  Exiting.")
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script ",curprog))
 ENDIF
 CALL echo(concat("Output file:            ",logical(output_file)))
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
   WHERE od.order_id=outerjoin(o.order_id)
    AND od.oe_field_meaning=outerjoin("*ROUTING*"))
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < sysdate
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY o.order_id
  HEAD REPORT
   pharmcnt = 0, stat = alterlist(temp->qual,1000)
  HEAD o.order_id
   s_pharm_name = "", n_erx_ind = 0, temp->total[1].n_ord_cnt = (temp->total[1].n_ord_cnt+ 1)
  DETAIL
   IF (od.oe_field_meaning="ROUTINGPHARMACYNAME")
    s_pharm_name = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="REQROUTINGTYPE"
    AND trim(cnvtupper(od.oe_field_display_value))="ROUTE TO PHARMACY ELECTRONICALLY")
    n_erx_ind = 1
   ENDIF
  FOOT  o.order_id
   IF (n_erx_ind=1)
    pharmcnt = (pharmcnt+ 1)
    IF (mod(pharmcnt,1000)=1)
     stat = alterlist(temp->qual,(pharmcnt+ 1000))
    ENDIF
    temp->qual[pharmcnt].pharm = trim(s_pharm_name,3), temp->total[1].n_e_cnt = (temp->total[1].
    n_e_cnt+ 1)
    IF (cnvtupper(s_pharm_name) IN ("BAYSTATE*"))
     temp->total[1].n_baystate_cnt = (temp->total[1].n_baystate_cnt+ 1), temp->qual[pharmcnt].
     sortorder = 100
    ELSE
     temp->total[1].n_nonbaystate_cnt = (temp->total[1].n_nonbaystate_cnt+ 1)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->qual,pharmcnt)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  pharmtemp = substring(1,40,temp->qual[d.seq].pharm)
  FROM (dummyt d  WITH seq = size(temp->qual,5))
  PLAN (d)
  ORDER BY pharmtemp
  HEAD REPORT
   totcnt = 0
  HEAD pharmtemp
   pharmcnt = 0
  DETAIL
   totcnt = (totcnt+ 1), pharmcnt = (pharmcnt+ 1)
  FOOT  pharmtemp
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(pharm->list,5),trim(pharmtemp,3),pharm->list[
    locnum].name)
   IF (pos > 0)
    pharm->list[pos].n_e_cnt = pharmcnt, pharm->list[pos].sortorder = temp->qual[d.seq].sortorder
   ELSE
    temp->n_other_cnt = (temp->n_other_cnt+ pharmcnt)
   ENDIF
  FOOT REPORT
   stat = alterlist(pharm->list,(size(pharm->list,5)+ 1)), pharm->list[size(pharm->list,5)].name =
   "Other", pharm->list[size(pharm->list,5)].n_e_cnt = temp->n_other_cnt,
   pharm->list[size(pharm->list,5)].sortorder = 99, pharm->list[size(pharm->list,5)].address = "",
   pharm->list[size(pharm->list,5)].distance = "",
   CALL echo(build("@@@@@@@@@@@",totcnt,"size",size(temp->qual,5)))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No prescriptions qualified.  Generating empty output file.")
  GO TO generate_report
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying prescriptions.  Exiting.")
  GO TO exit_script
 ENDIF
#generate_report
 CALL echorecord(pharm)
 SELECT INTO value(output_file)
  name = substring(1,40,pharm->list[d.seq].name), distance = substring(1,40,pharm->list[d.seq].
   distance), address = substring(1,40,pharm->list[d.seq].address),
  city = substring(1,40,pharm->list[d.seq].city), pcnt = pharm->list[d.seq].n_e_cnt, sort = pharm->
  list[d.seq].sortorder
  FROM (dummyt d  WITH seq = size(pharm->list,5))
  PLAN (d)
  ORDER BY sort DESC, pcnt DESC
  HEAD REPORT
   ms_line = concat(
    "Tot. EPrescribed,Tot. Non-EPrescribed, Tot. Baystate pharmacy,Tot. Non_Baystate pharmacy"), row
   0, col 0,
   ms_line, row 0, ms_line = build2(build2(temp->total[1].n_e_cnt),",",(temp->total[1].n_ord_cnt -
    temp->total[1].n_e_cnt),",",build2(temp->total[1].n_baystate_cnt),
    ",",build2(temp->total[1].n_nonbaystate_cnt)),
   row + 1, col 0, ms_line,
   ms_line = build2("Percent:",",,",build2((temp->total[1].n_baystate_cnt/ temp->total[1].n_e_cnt)),
    ",",build2((temp->total[1].n_nonbaystate_cnt/ temp->total[1].n_e_cnt))), row + 1, col 0,
   ms_line, ms_line = ",,,,", row + 1,
   col 0, ms_line, row + 1,
   col 0, ms_line, row + 1,
   col 0, ms_line, row 0,
   ms_line = concat("Name,Distance,Prescriptions Cnt,% Pres.Cnt,Address,City"), row + 1, col 0,
   ms_line, row 0
  DETAIL
   ms_line = build('"',name,'","',distance,'",',
    build2(pcnt),",",build2((pcnt/ temp->total[1].n_e_cnt)),',"',address,
    '","',city,'"'), row + 1, col 0,
   ms_line
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 300, maxrow = 1
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while generating the output file.  Exiting.")
  GO TO exit_script
 ENDIF
 EXECUTE bhs_ma_email_file
 CALL emailfile(build(output_file,".dat"),build(output_file,".csv"),"joshua.wherry@bhs.org",
  "eScriptionAudit",1)
 SET md_timer_stop = sysdate
 SELECT
  *
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "The Meaningful Use Rx-based output csv file was created.",
   row + 1, ms_line = concat("Output file:            ",logical(output_file)), col 0,
   ms_line, row + 1, ms_line = concat("Range begin time:       ",format(md_beg_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D")),
   col 0, ms_line, row + 1,
   ms_line = concat("Range end time:         ",format(md_end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")), col 0,
   ms_line,
   row + 1, ms_line = concat("Processing start time:  ",format(md_timer_start,
     "DD-MMM-YYYY HH:MM:SS;;D")), col 0,
   ms_line, row + 1, ms_line = concat("Processing end time:    ",format(md_timer_stop,
     "DD-MMM-YYYY HH:MM:SS;;D")),
   col 0, ms_line, row + 1,
   ms_line = concat("Processing time:        ",trim(cnvtstring(datetimediff(md_timer_stop,
       md_timer_start,4)),3)," minutes"), col 0, ms_line,
   row + 1, ms_line = concat("Debug flag:             ",cnvtstring(ml_debug_flag)), col 0,
   ms_line
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
  CALL echo(concat("Output file:            ",logical(output_file)))
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

CREATE PROGRAM dm_stat_reports
 FREE RECORD dsr_reports
 RECORD dsr_reports(
   1 begin_dt_tm = vc
   1 end_dt_tm = vc
   1 sort_by = vc
   1 report_type = vc
   1 stat_error_message = vc
   1 stat_error_flag = i2
   1 create_csv = i2
 ) WITH persistscript
 DECLARE dm_inp_parent = i2
 DECLARE dm_inp_child = i2
 DECLARE dm_inp_script = c30
 DECLARE dm_inp_num_stmts = i4
 DECLARE dm_inp_sort_by = c1
 DECLARE dm_dt_swap = c20
 DECLARE dm_inp_continue = c1
 DECLARE dm_input_validate = i2
 SET message = window
 SET accept = nopatcheck
#top_script
 SET dsr_reports->stat_error_flag = 0
 CALL header_box(13,60)
 CALL text(3,5,"Main Screen")
 CALL text(5,5,"0. Exit")
 CALL text(6,5,"1. System Monitoring Reports")
 CALL text(7,5,"2. Volume Reports")
 CALL text(8,5,"3. System Configuration Reports")
 CALL text(9,5,"4. Error Report")
 CALL text(10,5,"5. RTMS Reports")
 CALL text(11,5,fillstring(5,"-"))
 CALL accept(12,5,"9")
 SET dm_inp_parent = curaccept
#top_child
 CASE (dm_inp_parent)
  OF 0:
   GO TO exit_program
  OF 1:
   CALL header_box(13,60)
   CALL text(3,5,"System Monitoring Reports")
   CALL text(5,5,"0. Back to Main Screen")
   CALL text(6,5,"1. Node Utilization Summary")
   CALL text(7,5,"2. Node Utilization Detail")
   CALL text(8,5,"3. Message Log Summary")
   CALL text(9,5,"4. Message Log Detail")
   CALL text(10,5,fillstring(5,"-"))
   CALL accept(11,5,"9")
   SET dm_inp_child = curaccept
   CASE (dm_inp_child)
    OF 0:
     SET dm_inp_child = 0
    OF 1:
     CALL produce_report("Node Utilization Summary",1,"Metric","ESM_OSSTAT_SMRY")
    OF 2:
     CALL produce_report("Node Utilization Detail",1,"Metric","ESM_OSSTAT_DTL")
    OF 3:
     CALL produce_report("Message Log Summary",1,"Message Type","ESM_MSGLOG_SMRY")
    OF 4:
     CALL produce_report("Message Log Detail",1,"Message Type","ESM_MSGLOG_DTL")
    ELSE
     SET dm_inp_child = 1
   ENDCASE
  OF 2:
   CALL header_box(23,60)
   CALL text(3,5,"Volume Reports")
   CALL text(5,5,"0.  Back to Main Screen")
   CALL text(6,5,"1.  Application Volumes")
   CALL text(7,5,"2.  Order Volumes")
   CALL text(8,5,"3.  Chart Open Volumes")
   CALL text(9,5,"4.  Radiology Volumes")
   CALL text(10,5,"5.  PM Volumes")
   CALL text(11,5,"6.  Scheduling Volumes")
   CALL text(12,5,"7.  PathNet Volumes")
   CALL text(13,5,"8.  Inbound Interface Volumes")
   CALL text(14,5,"9.  Outbound Interface Volumes")
   CALL text(15,5,"10. Personnel Volumes")
   CALL text(16,5,"11. FirstNet Volumes")
   CALL text(17,5,"12. RRD Volumes Detail")
   CALL text(18,5,"13. RRD Volumes Summary")
   CALL text(19,5,"14. Outbound Interface Transaction Send")
   CALL text(20,5,"15. Outbound Interface Transaction Ignored")
   CALL text(21,5,fillstring(5,"-"))
   CALL accept(22,5,"99")
   SET dm_inp_child = curaccept
   CASE (dm_inp_child)
    OF 0:
     SET dm_inp_child = 0
    OF 1:
     CALL header_box(13,60)
     CALL text(3,5,"Application Volume Reports")
     CALL text(5,5,"0.  Back to Volume Reports")
     CALL text(6,5,"1.  For Physician Logins")
     CALL text(7,5,"2.  For Non-Physician Logins")
     CALL text(8,5,"3.  For Physician Distinct Users")
     CALL text(9,5,"4.  For Non-Physician Distinct Users")
     CALL accept(10,5,"99"
      WHERE curaccept IN (0, 1, 2, 3, 4,
      5, 6))
     SET dsr_rpt = curaccept
     CASE (dsr_rpt)
      OF 0:
       SET dm_inp_child = 1
      OF 1:
       CALL produce_report("Application Volumes - Physician Logins",1,"Application Name",
        "APP_VOLUMES - PHYSICIAN LOG INS")
      OF 2:
       CALL produce_report("Application Volumes - Non-Physician Logins",1,"Application Name",
        "APP_VOLUMES - NON-PHYSICIAN LOG INS")
      OF 3:
       CALL produce_report("Application Volumes - Physician Distinct Users",1,"Application Name",
        "APP_VOLUMES - PHYSICIAN DISTINCT USERS")
      OF 4:
       CALL produce_report("Application Volumes - Non-Physician Distinct Users",1,"Application Name",
        "APP_VOLUMES - NON-PHYS DISTINCT USERS")
     ENDCASE
    OF 2:
     CALL header_box(18,60)
     CALL text(3,5,"Order Volume Reports")
     CALL text(5,5,"0.  Back to Volume Reports")
     CALL text(6,5,"1.  For Pyxis")
     CALL text(7,5,"2.  For IV By Catalog Type")
     CALL text(8,5,"3.  For Non-IV By Catalog Type")
     CALL text(9,5,"4.  For PRN By Catalog Type")
     CALL text(10,5,"5.  For Non-PRN By Catalog Type")
     CALL text(11,5,"6.  For Physician By Catalog Type")
     CALL text(12,5,"7.  For Non-Physician BY Catalog Type")
     CALL text(13,5,"8.  For Bill Only By Catalog Type")
     CALL text(14,5,"9.  For Non-Bill Only By Catalog")
     CALL text(15,5,"10. By Catalog By Action")
     CALL text(16,5,"11. By Catalog By Care Set")
     CALL accept(17,5,"99"
      WHERE curaccept IN (0, 1, 2, 3, 4,
      5, 6, 7, 8, 9,
      10, 11))
     SET dsr_rpt = curaccept
     CASE (dsr_rpt)
      OF 0:
       SET dm_inp_child = 1
      OF 1:
       CALL produce_report("Order Volumes - Pyxis",1,"Catalog Name","ORDER_VOLUMES - PYXIS")
      OF 2:
       CALL produce_report("Order Volumes - IV By Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES - IV BY CATALOG TYPE")
      OF 3:
       CALL produce_report("Order Volumes - Non-IV By Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES - NON-IV BY CATALOG TYPE")
      OF 4:
       CALL produce_report("Order Volumes - PRN By Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES - PRN BY CATALOG TYPE")
      OF 5:
       CALL produce_report("Order Volumes - Non-PRN By Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES - NON-PRN BY CATALOG TYPE")
      OF 6:
       CALL produce_report("Order Volumes - Physician By Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES -PHYSICIAN BY CATALOG TYPE")
      OF 7:
       CALL produce_report("Order Volumes - Non-Physician BY Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES - NON-PHYS BY CATALOG TYPE")
      OF 8:
       CALL produce_report("Order Volumes - Bill Only By Catalog Type",1,"Catalog Name",
        "ORDER_VOLUMES -BILL ONLY BY CATALOG TYPE")
      OF 9:
       CALL produce_report("Order Volumes - Non-Bill Only By Catalog",1,"Catalog Name",
        "ORDER_VOLUMES - NON-BILL ONLY BY CATALOG")
      OF 10:
       CALL produce_report("Order Volumes - By Catalog By Action",1,"Catalog Name",
        "ORDER_VOLUMES - BY CATALOG BY ACTION")
      OF 11:
       CALL produce_report("Order Volumes - By Catalog By Care Set",1,"Catalog Name",
        "ORDER_VOLUMES - BY CATALOG BY CARE SET")
     ENDCASE
    OF 3:
     CALL produce_report("Chart Open Volumes",0," ","OPENED_CHART_VOLUMES")
    OF 4:
     CALL header_box(10,60)
     CALL text(3,5,"Radiology Volume Reports")
     CALL text(5,5,"0.  Back to Volume Reports")
     CALL text(6,5,"1.  For Orders")
     CALL text(7,5,"2.  For Orders By Report Status")
     CALL text(8,5,"3.  For Orders By Exam Status")
     CALL accept(9,5,"99"
      WHERE curaccept IN (0, 1, 2, 3))
     SET dsr_rpt = curaccept
     CASE (dsr_rpt)
      OF 0:
       SET dm_inp_child = 1
      OF 1:
       CALL produce_report("Radiology Volumes - Orders",1,"Action","RADIOLOGY_VOLUMES - ORDERS")
      OF 2:
       CALL produce_report("Radiology Volumes - Orders By Report Status",1,"Report Status",
        "RADIOLOGY_VOLUMES - ORDERS BY RPT STATUS")
      OF 3:
       CALL produce_report("Radiology Volumes - Orders By Exam Status",1,"Exam Status",
        "RADIOLOGY_VOLUMES -ORDERS BY EXAM STATUS")
     ENDCASE
    OF 5:
     CALL produce_report("PM Volumes",1,"Transaction","PM VOLUMES")
    OF 6:
     CALL produce_report("Scheduling Volumes",1,"Transaction","SCHEDULING VOLUMES")
    OF 7:
     CALL header_box(11,60)
     CALL text(3,5,"Pathnet Volume Reports")
     CALL text(5,5,"0.  Back to Volume Reports")
     CALL text(6,5,"1.  For Accessions")
     CALL text(7,5,"2.  For Gen Lab Containers")
     CALL text(8,5,"3.  For Gen Lab Lists")
     CALL text(9,5,"4.  For Results")
     CALL accept(10,5,"99"
      WHERE curaccept IN (0, 1, 2, 3, 4))
     SET dsr_rpt = curaccept
     CASE (dsr_rpt)
      OF 0:
       SET dm_inp_child = 1
      OF 1:
       CALL produce_report("Pathnet Volumes - Accessions",1,"Transaction",
        "PATHNET_VOLUMES - ACCESSIONS")
      OF 2:
       CALL produce_report("Pathnet Volumes - Gen Lab Containers",1,"Event Type",
        "PATHNET_VOLUMES - GEN LAB CONTAINERS")
      OF 3:
       CALL produce_report("Pathnet Volumes - Gen Lab Lists",1,"Transaction",
        "PATHNET_VOLUMES - GEN LAB LISTS")
      OF 4:
       CALL produce_report("Pathnet Volumes - Results",1,"Result Event/Activity Type/CareSet Flag",
        "PATHNET_VOLUMES - RESULTS")
     ENDCASE
    OF 8:
     CALL produce_report("Inbound Interface Volumes",1,"Source/Transaction","ESI Interface Volumes")
    OF 9:
     CALL produce_report("Outbound Interface Volumes",1,"Transaction",
      "ESO Outbound Interface Volumes")
    OF 10:
     CALL header_box(15,60)
     CALL text(3,5,"Personnel Reports")
     CALL text(5,5,"0.  Back to Volume Reports")
     CALL text(6,5,"1.  For Active Physician With Signon")
     CALL text(7,5,"2.  For Active Physician With No Signon")
     CALL text(8,5,"3.  For Active Other With Signon")
     CALL text(9,5,"4.  For Active Other With No Signon")
     CALL text(10,5,"5.  For Inactive Physician With Signon")
     CALL text(11,5,"6.  For Inactive Physician With No Signon")
     CALL text(12,5,"7.  For Inactive Other With Signon")
     CALL text(13,5,"8.  For Inactive Other With No Signon")
     CALL accept(14,5,"99"
      WHERE curaccept IN (0, 1, 2, 3, 4,
      5, 6, 7, 8))
     SET dsr_rpt = curaccept
     CASE (dsr_rpt)
      OF 0:
       SET dm_inp_child = 1
      OF 1:
       CALL produce_report("Personnel - Active Physician With Signon",1,"Personnel Type",
        "PERSONNEL-ACTIVE PHYSICIAN WITH SIGNON")
      OF 2:
       CALL produce_report("Personnel - Active Physician With No Signon",1,"Personnel Type",
        "PERSONNEL-ACTIVE PHYSICIAN WITH NOSIGNON")
      OF 3:
       CALL produce_report("Personnel - Active Other With Signon",1,"Personnel Type",
        "PERSONNEL-ACTIVE OTHER WITH SIGNON")
      OF 4:
       CALL produce_report("Personnel - Active Other With No Signon",1,"Personnel Type",
        "PERSONNEL-ACTIVE OTHER WITH NOSIGNON")
      OF 5:
       CALL produce_report("Personnel - Inactive Physician With Signon",1,"Personnel Type",
        "PERSONNEL-INACTIVE PHYSICIAN WITH SIGNON")
      OF 6:
       CALL produce_report("Personnel - Inactive Physician With No Signon",1,"Personnel Type",
        "PERSONNEL-INACTIVE PHYS WITH NOSIGNON")
      OF 7:
       CALL produce_report("Personnel - Inactive Other With Signon",1,"Personnel Type",
        "PERSONNEL-INACTIVE OTHER WITH SIGNON")
      OF 8:
       CALL produce_report("Personnel - Inactive Other With No Signon",1,"Personnel Type",
        "PERSONNEL-INACTIVE OTHER WITH NOSIGNON")
     ENDCASE
    OF 11:
     CALL produce_report("FirstNet Volumes",1,"Transaction","FIRSTNET VOLUMES")
    OF 12:
     CALL produce_report("RRD Volumes Detail",1,"Transaction","ESM_RRD_METRICS_DTL")
    OF 13:
     CALL produce_report("RRD Volumes Summary",1,"Transaction","ESM_RRD_METRICS_SMRY")
    OF 14:
     CALL produce_report("Outbound Interface Transaction Send",1,"Transaction",
      "ESO COM Srv Transactions Sent")
    OF 15:
     CALL produce_report("Outbound Interface Transaction Ignored",1,"Transaction",
      "ESO COM Srv Transactions Ignored")
    ELSE
     SET dm_inp_child = 1
   ENDCASE
  OF 3:
   CALL header_box(10,60)
   CALL text(3,5,"System Configuration Reports")
   CALL text(5,5,"0. Back to Main Screen")
   CALL text(6,5,"1. Millennium Configuration")
   CALL text(7,5,"2. OS Configuration")
   CALL text(8,5,fillstring(5,"-"))
   CALL accept(9,5,"9")
   SET dm_inp_child = curaccept
   CASE (dm_inp_child)
    OF 0:
     SET dm_inp_child = 0
    OF 1:
     CALL produce_report("Millennium Configuration",0," ","ESM_MILLCONFIG")
    OF 2:
     CALL produce_report("OS Configuration",0," ","ESM_OSCONFIG")
    ELSE
     SET dm_inp_child = 1
   ENDCASE
  OF 4:
   CALL produce_report("Error Report",0," ","DM_STAT_GATHER_ERRORS")
  OF 5:
   CALL header_box(10,60)
   CALL text(3,5,"RTMS Reports")
   CALL text(5,5,"0. Back to Main Screen")
   CALL text(6,5,"1. RTMS by Date")
   CALL text(7,5,"2. RTMS by Hour")
   CALL text(8,5,fillstring(5,"-"))
   CALL accept(9,5,"9")
   SET dm_inp_child = curaccept
   CASE (dm_inp_child)
    OF 0:
     SET dm_inp_child = 0
    OF 1:
     CALL produce_report("RTMS by Date",0," ","SLA_AGGREGATE_HOURLY1")
    OF 2:
     CALL produce_report("RTMS by Hour",0," ","SLA_AGGREGATE_HOURLY2")
    ELSE
     SET dm_inp_child = 1
   ENDCASE
  ELSE
   SET dm_inp_child = 0
 ENDCASE
 IF (dm_inp_child=0)
  GO TO top_script
 ELSE
  GO TO top_child
 ENDIF
 SUBROUTINE produce_report(report_name,sort_by_ind_main,sort_by_name_main,report_type)
   IF (sort_by_ind_main=0)
    CALL header_box(13,80)
   ELSE
    CALL header_box(15,80)
   ENDIF
   CALL text(3,2,report_name)
   CALL dm_get_user_inputs(sort_by_ind_main,sort_by_name_main)
 END ;Subroutine
 SUBROUTINE stat_error(null)
   SET dm_last_inp = 1
   IF ((dsr_reports->stat_error_flag=1))
    IF (findstring("ORA-01013",dsr_reports->stat_error_message)=0)
     SET dm_loops1 = ((textlen(dsr_reports->stat_error_message)/ 65)+ 1)
     CALL header_box((dm_loops1+ 8),70)
     CALL text(3,25,"ERROR FOUND")
     SET dm_start = 1
     SET dm_end = 65
     FOR (dm_for_cnt = 1 TO dm_loops1)
       CALL text((dm_for_cnt+ 4),2,substring(dm_start,dm_end,dsr_reports->stat_error_message))
       SET dm_start = (dm_start+ dm_end)
       SET dm_end = (dm_end+ dm_end)
     ENDFOR
     CALL text((dm_loops1+ 5),4,"0. Exit")
     CALL text((dm_loops1+ 6),4,"1. Back to Main Screen")
     CALL accept((dm_loops1+ 7),4,"9")
     SET dm_last_inp = curaccept
    ENDIF
   ENDIF
   IF (dm_last_inp=1)
    GO TO top_script
   ELSEIF (dm_last_inp=0)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE header_box(box_length,box_width)
   CALL clear(1,1)
   CALL box(1,1,box_length,box_width)
   CALL box(1,1,4,box_width)
   CALL clear(2,2,(box_width - 2))
   CALL text(2,25,"MSA REPORTS")
   CALL clear(3,2,(box_width - 2))
   FOR (for_cnt = 5 TO (box_length - 1))
     CALL clear(for_cnt,2,(box_width - 2))
   ENDFOR
 END ;Subroutine
 SUBROUTINE dm_get_user_inputs(sort_by_ind,sort_by_name)
   DECLARE dgu_date = i2
   SET dgu_date = 0
   CALL text(5,2,"Enter Begin Date/Time (DD-MMM-YYYY HH:MM:SS) ")
   CALL text(7,2,"Enter End Date/Time (DD-MMM-YYYY HH:MM:SS) ")
   IF (sort_by_ind=1)
    CALL text(9,2,concat("Enter Sort By (",substring(1,1,sort_by_name),"=",sort_by_name,
      ", D=Date/Time)"))
    CALL text(11,2,"Create external text (csv) file of report data (Y/N)")
    CALL text(13,2,"C=Continue, R=Return to Menu")
   ELSEIF (sort_by_ind=2)
    CALL text(15,2,"C=Continue, R=Return to Menu")
   ELSE
    CALL text(9,2,"Create external text (csv) file of report data (Y/N)")
    CALL text(11,2,"C=Continue, R=Return to Menu")
   ENDIF
   IF (validate(report_type,"ZZZ") != "ZZZ"
    AND validate(report_type,"YYY") != "YYY")
    IF (report_type IN ("ESM_OSCONFIG", "ESM_MILLCONFIG"))
     CALL accept(6,2,"P(20);CU",format(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime)),
       "01-MMM-YYYY 00:00:00;;d"))
     SET dsr_reports->begin_dt_tm = curaccept
     SET dgu_date = 1
    ENDIF
   ENDIF
   IF ( NOT (dgu_date))
    CALL accept(6,2,"P(20);CU",format(cnvtdatetime(curdate,curtime3),"01-MMM-YYYY 00:00:00;;d"))
    SET dsr_reports->begin_dt_tm = curaccept
   ENDIF
   SET dm_input_validate = 0
   WHILE (dm_input_validate=0)
     IF (check_date(dsr_reports->begin_dt_tm))
      CALL text(6,25,"** Invalid Date/Time **")
      CALL accept(6,2,"P(20);CU",dsr_reports->begin_dt_tm)
      SET dsr_reports->begin_dt_tm = curaccept
     ELSE
      CALL text(6,25,"                       ")
      SET dm_input_validate = 1
     ENDIF
   ENDWHILE
   CALL accept(8,2,"P(20);CU",format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;d"))
   SET dsr_reports->end_dt_tm = curaccept
   SET dm_input_validate = 0
   WHILE (dm_input_validate=0)
     IF (check_date(dsr_reports->end_dt_tm))
      CALL text(8,25,"** Invalid Date/Time **")
      CALL accept(8,2,"P(20);CU",dsr_reports->end_dt_tm)
      SET dsr_reports->end_dt_tm = curaccept
     ELSE
      CALL text(8,25,"                       ")
      SET dm_input_validate = 1
     ENDIF
   ENDWHILE
   IF (datetimediff(cnvtdatetime(dsr_reports->end_dt_tm),cnvtdatetime(dsr_reports->begin_dt_tm),6) <
   0)
    SET dm_dt_swap = dsr_reports->end_dt_tm
    SET dsr_reports->end_dt_tm = dsr_reports->begin_dt_tm
    SET dsr_reports->begin_dt_tm = dm_dt_swap
   ENDIF
   IF (sort_by_ind=1)
    SET dm_input_validate = 0
    WHILE (dm_input_validate=0)
      CALL accept(10,2,"A;CU","D")
      SET dm_inp_sort_by = curaccept
      IF (dm_inp_sort_by="D")
       SET dsr_reports->sort_by = "stat_snap_dt_tm"
       SET dm_input_validate = 1
      ELSEIF (dm_inp_sort_by=substring(1,1,sort_by_name))
       SET dsr_reports->sort_by = "stat_name"
       SET dm_input_validate = 1
      ENDIF
    ENDWHILE
    CALL accept(12,2,"A;CU","N"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SET dsr_reports->create_csv = 1
    ELSE
     SET dsr_reports->create_csv = 0
    ENDIF
    SET dm_input_validate = 0
    WHILE (dm_input_validate=0)
      CALL accept(14,2,"A;CU","C")
      SET dm_inp_continue = curaccept
      IF (dm_inp_continue="C")
       CALL dm_processing_request(null)
       SET dsr_reports->report_type = report_type
       EXECUTE dm_stat_reports_gen
       CALL stat_error(null)
       SET dm_input_validate = 1
      ELSEIF (dm_inp_continue="R")
       SET dm_input_validate = 1
       GO TO top_child
      ENDIF
    ENDWHILE
   ELSEIF (sort_by_ind=0)
    SET dsr_reports->sort_by = "stat_snap_dt_tm"
    CALL accept(10,2,"A;CU","N"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SET dsr_reports->create_csv = 1
    ELSE
     SET dsr_reports->create_csv = 0
    ENDIF
    SET dm_input_validate = 0
    WHILE (dm_input_validate=0)
      CALL accept(12,2,"A;CU","C")
      SET dm_inp_continue = curaccept
      IF (dm_inp_continue="C")
       CALL dm_processing_request(null)
       SET dsr_reports->report_type = report_type
       EXECUTE dm_stat_reports_gen
       CALL stat_error(null)
       SET dm_input_validate = 1
      ELSEIF (dm_inp_continue="R")
       SET dm_input_validate = 1
       GO TO top_child
      ENDIF
    ENDWHILE
   ELSE
    SET dsr_reports->sort_by = "stat_snap_dt_tm"
   ENDIF
 END ;Subroutine
 SUBROUTINE check_date(inp_date)
   IF (((cnvtint(substring(1,2,inp_date)) < 1) OR (cnvtint(substring(1,2,inp_date)) > 31)) )
    RETURN(1)
   ELSEIF (substring(3,1,inp_date) != "-")
    RETURN(1)
   ELSEIF ( NOT (cnvtupper(substring(4,3,inp_date)) IN ("JAN", "FEB", "MAR", "APR", "MAY",
   "JUN", "JUL", "AUG", "SEP", "OCT",
   "NOV", "DEC")))
    RETURN(1)
   ELSEIF ( NOT (isnumeric(substring(8,4,inp_date))))
    RETURN(1)
   ELSEIF (substring(7,1,inp_date) != "-")
    RETURN(1)
   ELSEIF (((cnvtint(substring(13,2,inp_date)) < 0) OR (cnvtint(substring(13,2,inp_date)) > 23)) )
    RETURN(1)
   ELSEIF (((cnvtint(substring(16,2,inp_date)) < 0) OR (cnvtint(substring(16,2,inp_date)) > 59)) )
    RETURN(1)
   ELSEIF (((cnvtint(substring(19,2,inp_date)) < 0) OR (cnvtint(substring(19,2,inp_date)) > 59)) )
    RETURN(1)
   ELSEIF (substring(15,1,inp_date) != ":")
    RETURN(1)
   ELSEIF (substring(18,1,inp_date) != ":")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_processing_request(null)
   CALL clear(1,1)
   CALL video(b)
   CALL text(1,1,"Processing request.....")
   CALL video(n)
 END ;Subroutine
#exit_program
 SET message = nowindow
 FREE RECORD dsr_reports
 FREE RECORD temp_report
END GO

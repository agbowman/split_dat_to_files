CREATE PROGRAM dm_stat_reports_old:dba
 FREE RECORD dsr_reports
 RECORD dsr_reports(
   1 begin_dt_tm = vc
   1 end_dt_tm = vc
   1 sort_by = vc
   1 report_type = vc
   1 stat_error_message = vc
   1 stat_error_flag = i2
 ) WITH persistscript
 FREE RECORD temp_report
 RECORD temp_report(
   1 qual[*]
     2 stat_id = f8
     2 score = f8
     2 buffer_gets = f8
     2 executions = f8
     2 disk_reads = f8
     2 script_name = vc
     2 snap_dt_tm_begin = vc
     2 snap_dt_tm_end = vc
     2 qual[*]
       3 sql_stmt = vc
 )
 DECLARE dm_inp_parent = i2
 DECLARE dm_inp_child = i2
 DECLARE dm_inp_script = c30
 DECLARE dm_inp_num_stmts = i4
 DECLARE dm_inp_sort_by = c1
 DECLARE dm_dt_swap = c20
 DECLARE dm_inp_continue = c1
 DECLARE dm_input_validate = i2
 SET message = window
#top_script
 SET dsr_reports->stat_error_flag = 0
 CALL header_box(11,60)
 CALL text(3,5,"Main Screen")
 CALL text(5,5,"0. Exit")
 CALL text(6,5,"1. System Monitoring Reports")
 CALL text(7,5,"2. Volume Reports")
 CALL text(8,5,"3. System Configuration Reports")
 CALL text(9,5,fillstring(5,"-"))
 CALL accept(10,5,"9")
 SET dm_inp_parent = curaccept
#top_child
 CASE (dm_inp_parent)
  OF 0:
   GO TO exit_program
  OF 1:
   CALL header_box(13,60)
   CALL text(3,5,"System Monitoring Reports")
   CALL text(5,5,"0. Back to Main Screen")
   CALL text(6,5,"1. TOP SQL Statements")
   CALL text(7,5,"2. Node Utilization Summary")
   CALL text(8,5,"3. Node Utilization Detail")
   CALL text(9,5,"4. Message Log Summary")
   CALL text(10,5,"5. Message Log Detail")
   CALL text(11,5,fillstring(5,"-"))
   CALL accept(12,5,"9")
   SET dm_inp_child = curaccept
   CASE (dm_inp_child)
    OF 0:
     SET dm_inp_child = 0
    OF 1:
     CALL header_box(17,70)
     CALL text(3,2,"TOP SQL Statements")
     CALL text(9,2,"Enter Script Name ")
     CALL text(11,2,"Enter Number of Statements to Return ")
     CALL text(13,2,"Enter Sort By (S=Score, B=Buffer_Gets, E=Executions, D=Disk Reads)")
     CALL dm_get_user_inputs(2," ")
     CALL accept(10,2,"P(30);CU","*")
     SET dm_inp_script = curaccept
     CALL accept(12,2,"9999",0100)
     SET dm_inp_num_stmts = curaccept
     SET dm_input_validate = 0
     WHILE (dm_input_validate=0)
       CALL accept(14,2,"P;CU","S")
       SET dm_inp_sort_by = curaccept
       IF (dm_inp_sort_by IN ("S", "B", "E", "D"))
        SET dm_input_validate = 1
       ENDIF
     ENDWHILE
     SET dm_input_validate = 0
     WHILE (dm_input_validate=0)
       CALL accept(16,2,"A;CU","C")
       SET dm_inp_continue = curaccept
       IF (dm_inp_continue="C")
        CALL dm_processing_request(null)
        EXECUTE dm_stat_report_top_sql
        CALL stat_error(null)
        SET dm_input_validate = 1
       ELSEIF (dm_inp_continue="R")
        SET dm_input_validate = 1
        GO TO top_child
       ENDIF
     ENDWHILE
    OF 2:
     CALL produce_report("Node Utilization Summary",1,"Metric","ESM_OSSTAT_SMRY")
    OF 3:
     CALL produce_report("Node Utilization Detail",1,"Metric","ESM_OSSTAT_DTL")
    OF 4:
     CALL produce_report("Message Log Summary",1,"Message Type","ESM_MSGLOG_SMRY")
    OF 5:
     CALL produce_report("Message Log Detail",1,"Message Type","ESM_MSGLOG_DTL")
    ELSE
     SET dm_inp_child = 1
   ENDCASE
  OF 2:
   CALL header_box(22,60)
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
   CALL text(16,5,"11. Pharmacy Volumes")
   CALL text(17,5,"12. FirstNet Volumes")
   CALL text(18,5,"13. RRD Volumes Detail")
   CALL text(19,5,"14. RRD Volumes Summary")
   CALL text(20,5,fillstring(5,"-"))
   CALL accept(21,5,"99")
   SET dm_inp_child = curaccept
   CASE (dm_inp_child)
    OF 0:
     SET dm_inp_child = 0
    OF 1:
     CALL produce_report("Application Volumes",1,"Application Name","Application Volumes")
    OF 2:
     CALL produce_report("Order Volumes",1,"Order Action","ORDER_VOLUMES")
    OF 3:
     CALL produce_report("Chart Open Volumes",0," ","CHART_OPEN_VOLUMES")
    OF 4:
     CALL produce_report("Radiology Volumes",1,"Action","Radiology Volumes")
    OF 5:
     CALL produce_report("PM Volumes",1,"Transaction","PM VOLUMES")
    OF 6:
     CALL produce_report("Scheduling Volumes",1,"Transaction","SCHEDULING VOLUMES")
    OF 7:
     CALL produce_report("PathNet Volumes",1,"Transaction","Pathnet Volumes")
    OF 8:
     CALL produce_report("Inbound Interface Volumes",1,"Source/Transaction","ESI Interface Volumes")
    OF 9:
     CALL produce_report("Outbound Interface Volumes",1,"Transaction",
      "ESO Outbound Interface Volumes")
    OF 10:
     CALL produce_report("Personnel Volumes",1,"Personnel Type","Personnel Volumes")
    OF 11:
     CALL header_box(11,60)
     CALL text(3,2,"Pharmacy Volumes")
     CALL dm_get_user_inputs(3," ")
     SET dsr_reports->report_type = "Pharmacy Volumes"
     SET dm_input_validate = 0
     WHILE (dm_input_validate=0)
       CALL accept(10,2,"A;CU","C")
       SET dm_inp_continue = curaccept
       IF (dm_inp_continue="R")
        SET dm_input_validate = 1
        GO TO top_child
       ELSEIF (dm_inp_continue="C")
        CALL dm_processing_request(null)
        EXECUTE dm_stat_report_pharmacy_vols
        CALL stat_error(null)
        SET dm_input_validate = 1
       ENDIF
     ENDWHILE
    OF 12:
     CALL produce_report("FirstNet Volumes",1,"Transaction","FIRSTNET VOLUMES")
    OF 13:
     CALL produce_report("RRD Volumes Detail",1,"Transaction","ESM_RRD_METRICS_DTL")
    OF 14:
     CALL produce_report("RRD Volumes Summary",1,"Transaction","ESM_RRD_METRICS_SMRY")
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
    CALL header_box(11,60)
   ELSE
    CALL header_box(13,60)
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
   CALL text(5,2,"Enter Begin Date/Time (DD-MMM-YYYY HH:MM:SS) ")
   CALL text(7,2,"Enter End Date/Time (DD-MMM-YYYY HH:MM:SS) ")
   IF (sort_by_ind=1)
    CALL text(9,2,concat("Enter Sort By (",substring(1,1,sort_by_name),"=",sort_by_name,
      ", D=Date/Time)"))
    CALL text(11,2,"C=Continue, R=Return to Menu")
   ELSEIF (sort_by_ind=2)
    CALL text(15,2,"C=Continue, R=Return to Menu")
   ELSE
    CALL text(9,2,"C=Continue, R=Return to Menu")
   ENDIF
   CALL accept(6,2,"P(20);CU",format(cnvtdatetime(curdate,curtime3),"01-MMM-YYYY 00:00:00;;d"))
   SET dsr_reports->begin_dt_tm = curaccept
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
    SET dm_input_validate = 0
    WHILE (dm_input_validate=0)
      CALL accept(12,2,"A;CU","C")
      SET dm_inp_continue = curaccept
      IF (dm_inp_continue="C")
       CALL dm_processing_request(null)
       SET dsr_reports->report_type = report_type
       EXECUTE dm_stat_reports_gen_old
       CALL stat_error(null)
       SET dm_input_validate = 1
      ELSEIF (dm_inp_continue="R")
       SET dm_input_validate = 1
       GO TO top_child
      ENDIF
    ENDWHILE
   ELSEIF (sort_by_ind=0)
    SET dsr_reports->sort_by = "stat_snap_dt_tm"
    SET dm_input_validate = 0
    WHILE (dm_input_validate=0)
      CALL accept(10,2,"A;CU","C")
      SET dm_inp_continue = curaccept
      IF (dm_inp_continue="C")
       CALL dm_processing_request(null)
       SET dsr_reports->report_type = report_type
       EXECUTE dm_stat_reports_gen_old
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

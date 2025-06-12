CREATE PROGRAM dba_rpt_analyze
 PAINT
 SET instance_display = fillstring(80," ")
 SET owner_display = fillstring(80," ")
 SET ts_display = fillstring(80," ")
 SET obj_display = fillstring(80," ")
 SET table_atype_display = fillstring(80," ")
 SET table_etype_display = fillstring(80," ")
 SET table_enum_display = fillstring(80," ")
 SET index_atype_display = fillstring(80," ")
 SET index_etype_display = fillstring(80," ")
 SET index_enum_display = fillstring(80," ")
 SET block_size = fillstring(80," ")
 SET database_display = fillstring(80," ")
 SET db_link_display = fillstring(80," ")
 SET max_report_seq = 0
 SET inst_cd = 0
 CALL video(r)
 CALL box(1,1,20,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,10,"***  M I L L E N N I U M   A N A L Y Z E   R E P O R T  ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(06,05,"Database Instance ID: ")
 CALL text(08,05,"Report Seq <max report seq>: ")
 SET help = pos(9,15,10,50)
 SET help =
 SELECT INTO "nl:"
  ref.instance_cd, ref.db_name
  FROM ref_instance_id ref
  ORDER BY ref.instance_cd DESC
  WITH nocounter
 ;end select
 CALL accept(06,65,"99999999.99;")
 SET inst_cd = cnvtint(curaccept)
 SET help = off
 SELECT INTO dummyt
  max_reportseq = max(t.report_seq)
  FROM ref_report_parms_log t,
   ref_report_log s
  WHERE t.report_seq=s.report_seq
   AND s.report_cd=4
   AND t.parm_cd=1
   AND t.parm_value=cnvtstring(inst_cd)
  DETAIL
   max_report_seq = cnvtint(max_reportseq)
  WITH check, nocounter
 ;end select
 IF (max_report_seq <= 0)
  CALL video(b)
  CALL text(15,20,concat("NO Analyze Reports found for Instance ",trim(cnvtstring(inst_cd))))
  CALL pause(5)
  CALL video(n)
  GO TO endprogram
 ENDIF
 SET help = pos(9,15,10,50)
 SET help =
 SELECT INTO "nl:"
  ref.report_seq, ref.begin_date, name = substring(1,40,ref.user_notes)
  FROM ref_report_log ref,
   ref_report_parms_log parm
  WHERE ref.report_cd=4
   AND ref.report_seq=parm.report_seq
   AND parm.parm_cd=1
   AND parm.parm_value=cnvtstring(inst_cd)
  ORDER BY ref.report_seq DESC
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  ref.report_seq
  FROM ref_report_log ref,
   ref_report_parms_log parm
  WHERE ref.report_cd=4
   AND ref.report_seq=cnvtint(curaccept)
   AND ref.report_seq=parm.report_seq
   AND parm.parm_cd=1
   AND parm.parm_value=cnvtstring(inst_cd)
  ORDER BY ref.report_seq DESC
  WITH nocounter
 ;end select
 SET validate = required
 SET validate = 2
 CALL accept(08,65,"99999999.99;",max_report_seq)
 IF (curaccept=max_report_seq)
  SET rep_seq = cnvtint(max_report_seq)
 ELSE
  SET rep_seq = cnvtint(curaccept)
 ENDIF
 SET help = off
 SET validate = off
 CALL text(18,05,"Continue? (Y/N)")
 CALL accept(18,65,"A;CU","Y"
  WHERE curaccept IN ("N", "Y"))
 IF (curaccept="N")
  CALL text(11,05,"Skipping Report")
  CALL clear(1,1)
  GO TO endprogram
 ENDIF
 SELECT INTO "nl:"
  rrpl.*
  FROM ref_report_parms_log rrpl
  WHERE rep_seq=rrpl.report_seq
  HEAD REPORT
   col 0
  DETAIL
   CASE (rrpl.parm_cd)
    OF 1:
     instance_display = substring(1,78,rrpl.parm_value)
    OF 2:
     IF (rrpl.value_seq=1)
      owner_display = substring(1,78,rrpl.parm_value)
     ELSE
      owner_display = build(owner_display,",",rrpl.parm_value)
     ENDIF
    OF 3:
     IF (rrpl.value_seq=1)
      ts_display = substring(1,78,rrpl.parm_value)
     ELSE
      ts_display = build(ts_display,",",rrpl.parm_value)
     ENDIF
    OF 4:
     IF (rrpl.value_seq=1)
      obj_display = substring(1,78,rrpl.parm_value)
     ELSE
      obj_display = build(obj_display,",",rrpl.parm_value)
     ENDIF
    OF 5:
     table_atype_display = substring(1,78,rrpl.parm_value)
    OF 6:
     table_etype_display = substring(1,78,rrpl.parm_value)
    OF 7:
     table_enum_display = substring(1,78,rrpl.parm_value)
    OF 8:
     index_atype_display = substring(1,78,rrpl.parm_value)
    OF 9:
     index_etype_display = substring(1,78,rrpl.parm_value)
    OF 10:
     index_enum_display = substring(1,78,rrpl.parm_value)
    OF 11:
     block_size = substring(1,78,rrpl.parm_value)
   ENDCASE
 ;end select
 SELECT INTO "nl:"
  r.*
  FROM ref_instance_id r
  WHERE r.instance_cd=cnvtint(instance_display)
  DETAIL
   database_display = r.db_name, db_link_display = r.node_address
  WITH nocounter
 ;end select
 SELECT
  rrl.*, line1 = substring(1,35,rrl.user_notes), line2 = substring(36,70,rrl.user_notes),
  line3 = substring(71,105,rrl.user_notes), line4 = substring(106,140,rrl.user_notes), sl.*,
  log_text = substring(1,130,sl.log_notes)
  FROM space_log sl,
   ref_report_log rrl,
   dummyt d
  PLAN (rrl
   WHERE rrl.report_seq=rep_seq)
   JOIN (d)
   JOIN (sl
   WHERE rrl.report_seq=sl.report_seq)
  ORDER BY sl.log_seq, log_text
  HEAD REPORT
   IF (rrl.end_date=null)
    col 10, " DATA BELOW IS INCOMPLETE!!", row + 2
   ENDIF
   len_line2 = textlen(trim(line2)), len_line3 = textlen(trim(line3)), len_line4 = textlen(trim(line4
     )),
   col 5, "Report of Errors Created During ANALYZE for ",
   CALL print(trim(cnvtupper(database_display))),
   col + 1, ":", row + 1,
   col 5, "           Start Time           - ", rrl.begin_date"dd-mmm-yyyy hh:mm;;d",
   row + 1, col 5, "           End Time             - ",
   rrl.end_date"dd-mmm-yyyy hh:mm;;d", row + 1, col 5,
   "           Requested by         - ",
   CALL print(trim(rrl.request_user)), row + 1,
   col 5, "           User Notes           -  * ",
   CALL print(trim(line1)),
   row + 1
   IF (len_line2 > 0)
    col 5, "                                   * ",
    CALL print(trim(line2)),
    row + 1
   ENDIF
   IF (len_line3 > 0)
    col 5, "                                   * ",
    CALL print(trim(line3)),
    row + 1
   ENDIF
   IF (len_line4 > 0)
    col 5, "                                   * ",
    CALL print(trim(line4)),
    row + 1
   ENDIF
   row + 1, col 5, "Arguments: Report Sequence #    : ",
   CALL print(trim(cnvtstring(rrl.report_seq))), row + 1, col 5,
   "           Database             : ",
   CALL print(trim(cnvtupper(database_display))), row + 1,
   col 5, "           Instance Name        : ",
   CALL print(trim(cnvtupper(instance_display))),
   row + 1, col 5, "           DB Link Name         : ",
   CALL print(trim(cnvtupper(db_link_display))), row + 1, col 5,
   "           Owner                : ",
   CALL print(trim(owner_display)), row + 1,
   col 5, "           Tablespace           : ",
   CALL print(trim(ts_display)),
   row + 1, col 5, "           Object               : ",
   CALL print(trim(obj_display)), row + 1, col 5,
   "           Table Analyze Type   : ",
   CALL print(trim(table_atype_display)), row + 1,
   col 5, "           Table Estimate Type  : ",
   CALL print(trim(table_etype_display)),
   row + 1, col 5, "           Table Estimate Number: ",
   CALL print(trim(table_enum_display)), row + 1, col 5,
   "           Index Analyze Type   : ",
   CALL print(trim(index_atype_display)), row + 1,
   col 5, "           Index Estimate Type  : ",
   CALL print(trim(index_etype_display)),
   row + 1, col 5, "           Index Estimate Number: ",
   CALL print(trim(index_enum_display)), row + 1, col 5,
   "           Block Size           : ",
   CALL print(trim(block_size)), row + 2,
   col 5, "**********************************************************************", row + 1,
   col 5, "Note that the typical error is ORA-00054 (nowait).  The Analyze Report", row + 1,
   col 5, "will attempt five times to analyze an object.  Thus if an object has", row + 1,
   col 5, "Errors, then the analyze for that object DID NOT COMPLETE and the", row + 1,
   col 5, "internal Oracle tables were not updated.  If an object has less than 5", row + 1,
   col 5, "errors, then the analyze was successful during one of the 5 attempts.", row + 1,
   col 5, "**********************************************************************", row + 2,
   stars = fillstring(80,"*"), cnt = 0, prev_log = fillstring(80," "),
   prev_table = fillstring(80," "), cur_log = fillstring(80," "), cur_table = fillstring(80," "),
   log_line1 = fillstring(75," "), log_line2 = fillstring(75," "), log_line3 = fillstring(75," "),
   log_line4 = fillstring(75," "), log_line5 = fillstring(75," "), log_line6 = fillstring(75," "),
   log_line7 = fillstring(75," ")
  HEAD log_text
   tab_len = 0, tab_len = findstring("-",sl.log_notes,1), cur_table = substring(1,(tab_len - 1),sl
    .log_notes)
   IF (cur_table != prev_table)
    stars_tmp = substring(1,(tab_len - 2),stars), col 0, stars_tmp,
    row + 1, col 0, cur_table,
    row + 1, col 0, stars_tmp,
    row + 1
   ENDIF
  HEAD sl.log_seq
   log_line2_cnt = 0, log_line3_cnt = 0, log_line4_cnt = 0,
   log_line5_cnt = 0, log_line6_cnt = 0, log_line7_cnt = 0
  DETAIL
   len = 0, len = textlen(trim(sl.log_notes)), len_tmp = findstring("-",sl.log_notes,(tab_len+ 1)),
   len_tmp = findstring("-",sl.log_notes,(len_tmp+ 1)), len_space_tmp = findstring(" ",sl.log_notes,(
    (len_tmp+ 2)+ 60)), log_line1 = substring((len_tmp+ 2),(len_space_tmp - (len_tmp+ 2)),sl
    .log_notes)
   IF (len > len_space_tmp)
    len_space_tmp_second = findstring(" ",sl.log_notes,(len_space_tmp+ 60)), log_line2_cnt = 1,
    log_line2 = substring(len_space_tmp,(len_space_tmp_second - len_space_tmp),sl.log_notes),
    len_space_tmp = len_space_tmp_second
   ENDIF
   IF (len > len_space_tmp)
    len_space_tmp_second = findstring(" ",sl.log_notes,(len_space_tmp+ 60)), log_line3_cnt = 1,
    log_line3 = substring(len_space_tmp,(len_space_tmp_second - len_space_tmp),sl.log_notes),
    len_space_tmp = len_space_tmp_second
   ENDIF
   IF (len > len_space_tmp)
    len_space_tmp_second = findstring(" ",sl.log_notes,(len_space_tmp+ 60)), log_line4_cnt = 1,
    log_line4 = substring(len_space_tmp,(len_space_tmp_second - len_space_tmp),sl.log_notes),
    len_space_tmp = len_space_tmp_second
   ENDIF
   IF (len > len_space_tmp)
    len_space_tmp_second = findstring(" ",sl.log_notes,(len_space_tmp+ 60)), log_line5_cnt = 1,
    log_line5 = substring(len_space_tmp,(len_space_tmp_second - len_space_tmp),sl.log_notes),
    len_space_tmp = len_space_tmp_second
   ENDIF
   IF (len > len_space_tmp)
    len_space_tmp_second = findstring(" ",sl.log_notes,(len_space_tmp+ 60)), log_line6_cnt = 1,
    log_line6 = substring(len_space_tmp,(len_space_tmp_second - len_space_tmp),sl.log_notes),
    len_space_tmp = len_space_tmp_second
   ENDIF
   IF (len > len_space_tmp)
    len_space_tmp_second = findstring(" ",sl.log_notes,(len_space_tmp+ 60)), log_line7_cnt = 1,
    log_line7 = substring(len_space_tmp,(len_space_tmp_second - len_space_tmp),sl.log_notes),
    len_space_tmp = len_space_tmp_second
   ENDIF
   col 5, log_line1, row + 1
   IF (log_line2_cnt=1)
    col 5, log_line2, row + 1
   ENDIF
   IF (log_line3_cnt=1)
    col 5, log_line3, row + 1
   ENDIF
   IF (log_line4_cnt=1)
    col 5, log_line4, row + 1
   ENDIF
   IF (log_line5_cnt=1)
    col 5, log_line5, row + 1
   ENDIF
   IF (log_line6_cnt=1)
    col 5, log_line6, row + 1
   ENDIF
   IF (log_line7_cnt=1)
    col 5, log_line7, row + 1
   ENDIF
   row + 1
   IF (len > 0)
    cnt = (cnt+ 1)
   ENDIF
  FOOT  log_text
   prev_table = cur_table
  FOOT REPORT
   IF (cnt < 1)
    col 16, "*****************************************************", row + 1,
    col 16, "******   Analyze Report Finsihed Successfully  ******", row + 1,
    col 16, "******   No Errors were reported               ******", row + 1,
    col 16, "*****************************************************", row + 2
   ENDIF
   col 16, "           *****   End of Report  ******"
  WITH nullreport, outerjoin = d
 ;end select
#endprogram
END GO

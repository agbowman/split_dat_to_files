CREATE PROGRAM dba_rpt_space
 IF (validate(reply->status_data.status,"/")="/")
  FREE SET reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationstatus = c1
        3 operationname = c15
        3 targetobjectname = c15
        3 targetobjectvalue = c50
  )
 ENDIF
 IF (validate(request->outfile,"false")="false")
  SET outfile = "MINE"
 ELSE
  IF (trim(request->outfile)="")
   SET reply->subeventstatus[1].operationstatus = "F"
   SET reply->subeventstatus[1].operationname = "VALUATE"
   SET reply->subeventstatus[1].targetobjectname = "FIELD"
   SET reply->subeventstatus[1].targetobjectvalue = "OUTputFILEname"
   GO TO endprogram
  ELSE
   SET outfile = trim(request->outfile)
  ENDIF
 ENDIF
 IF ((validate(request->report_seq,- (1))=- (1)))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "report_seq"
  GO TO endprogram
 ELSE
  IF ((request->report_seq < 1))
   SET reply->subeventstatus[1].operationstatus = "F"
   SET reply->subeventstatus[1].operationname = "VALUATE"
   SET reply->subeventstatus[1].targetobjectname = "FIELD"
   SET reply->subeventstatus[1].targetobjectvalue = "report_seq"
   GO TO endprogram
  ELSE
   SET report_seq = request->report_seq
  ENDIF
 ENDIF
 SET reply->status_data.status = "F"
 RECORD parm_arr(
   1 qual[1]
     2 parm_cd = i4
     2 value_seq = i4
     2 parm_value = c200
 )
 SET cnt = 0
 SELECT INTO dummyt
  t.parm_cd, t.value_seq, t.parm_value
  FROM ref_report_parms_log t
  WHERE t.report_seq=cnvtint(report_seq)
  HEAD REPORT
   count = 1
  DETAIL
   IF (count > 1)
    stat = alter(parm_arr->qual,count)
   ENDIF
   parm_arr->qual[count].parm_cd = t.parm_cd, parm_arr->qual[count].value_seq = t.value_seq, parm_arr
   ->qual[count].parm_value = t.parm_value,
   count = (count+ 1)
  WITH nocounter
 ;end select
 SET total_count = size(parm_arr->qual,5)
 SET instance_display = fillstring(20," ")
 SET database_display = fillstring(20," ")
 SET db_link_display = fillstring(20," ")
 SET environment_display = fillstring(30," ")
 SET instance_cnt = 0
 FOR (x = 1 TO total_count)
   IF ((parm_arr->qual[x].parm_cd=1))
    SELECT INTO dummyt
     t.db_name, t.instance_name, t.node_address,
     d.environment_name
     FROM ref_instance_id t,
      dm_environment d,
      (dummyt du  WITH seq = 1)
     PLAN (t
      WHERE t.instance_cd=cnvtint(parm_arr->qual[x].parm_value))
      JOIN (du
      WHERE du.seq=1)
      JOIN (d
      WHERE t.environment_id=d.environment_id)
     DETAIL
      IF (instance_cnt=0)
       instance_display = t.instance_name, database_display = t.db_name, environment_display = d
       .environment_name,
       db_link_display = t.node_address
      ELSE
       database_display = concat(database_display,",",t.db_name), instance_display = concat(
        instance_display,",",t.instance_name), environment_display = concat(environment_display,",",d
        .environment_name),
       db_link_display = concat(db_link_display,",",t.node_address)
      ENDIF
     WITH nocounter, outerjoin = du
    ;end select
    SET instance_cnt = (instance_cnt+ 1)
   ENDIF
 ENDFOR
 SET owner_display = fillstring(120," ")
 SET owner_cnt = 0
 FOR (x = 1 TO total_count)
   IF ((parm_arr->qual[x].parm_cd=2))
    IF (owner_cnt > 0)
     SET owner_display = concat(trim(owner_display),",",parm_arr->qual[x].parm_value)
    ELSE
     SET owner_display = concat(parm_arr->qual[x].parm_value)
    ENDIF
    SET owner_cnt = (owner_cnt+ 1)
   ENDIF
 ENDFOR
 SET ts_display = fillstring(120," ")
 SET ts_cnt = 0
 FOR (x = 1 TO total_count)
   IF ((parm_arr->qual[x].parm_cd=3))
    IF (ts_cnt > 0)
     SET ts_display = concat(trim(ts_display),",",parm_arr->qual[x].parm_value)
    ELSE
     SET ts_display = concat(parm_arr->qual[x].parm_value)
    ENDIF
    SET ts_cnt = (ts_cnt+ 1)
   ENDIF
 ENDFOR
 SET obj_display = fillstring(120," ")
 SET obj_cnt = 0
 FOR (x = 1 TO total_count)
   IF ((parm_arr->qual[x].parm_cd=4))
    IF (obj_cnt > 0)
     SET obj_display = concat(trim(obj_display),",",parm_arr->qual[x].parm_value)
    ELSE
     SET obj_display = concat(parm_arr->qual[x].parm_value)
    ENDIF
    SET obj_cnt = (obj_cnt+ 1)
   ENDIF
 ENDFOR
 SET block_size = fillstring(10," ")
 FOR (x = 1 TO total_count)
   IF ((parm_arr->qual[x].parm_cd=11))
    SET block_size = cnvtstring(parm_arr->qual[x].parm_value)
   ENDIF
 ENDFOR
 FREE SET sp_log
 RECORD sp_log(
   1 qual[1]
     2 log_seq = f8
     2 log_notes = c2000
 )
 SELECT INTO dummy
  sl.log_notes, sl.log_seq, sl.report_seq
  FROM space_log sl
  WHERE sl.report_seq=cnvtint(report_seq)
  ORDER BY sl.log_seq
  HEAD REPORT
   count = 1
  DETAIL
   IF (count > 1)
    stat = alter(sp_log->qual,(count+ 1))
   ENDIF
   sp_log->qual[count].log_seq = sl.log_seq, sp_log->qual[count].log_notes = sl.log_notes, count = (
   count+ 1)
  WITH nocounter
 ;end select
 SET log_count = size(sp_log->qual,5)
 RECORD ts_arr(
   1 qual[1]
     2 tablespace_name = c30
     2 file_name = c50
     2 file_id = f8
     2 total_space = f8
     2 free_space = f8
     2 num_chunks = f8
     2 max_contig = f8
     2 min_contig = f8
     2 avg_contig = f8
 )
 IF (seg_type="T")
  SET seg_type = "TABLE"
 ENDIF
 IF (seg_type="I")
  SET seg_type = "INDEX"
 ENDIF
 SET accept = nopatcheck
 SELECT DISTINCT INTO dummyt
  sf.tablespace_name, sf.file_id, sf.file_name,
  sf.total_space, sf.free_space, sf.num_chunks,
  sf.max_contig, sf.min_contig, sf.avg_contig
  FROM space_files sf
  WHERE sf.report_seq=cnvtint(report_seq)
   AND sf.tablespace_name=patstring(tsp_name)
  ORDER BY sf.tablespace_name
  HEAD REPORT
   count = 1
  DETAIL
   IF (count > 1)
    stat = alter(ts_arr->qual,count)
   ENDIF
   ts_arr->qual[count].tablespace_name = sf.tablespace_name, ts_arr->qual[count].file_name = sf
   .file_name, ts_arr->qual[count].file_id = sf.file_id,
   ts_arr->qual[count].total_space = sf.total_space, ts_arr->qual[count].free_space = sf.free_space,
   ts_arr->qual[count].num_chunks = sf.num_chunks,
   ts_arr->qual[count].max_contig = sf.max_contig, ts_arr->qual[count].min_contig = sf.min_contig,
   ts_arr->qual[count].avg_contig = sf.avg_contig,
   count = (count+ 1)
  WITH check
 ;end select
 SET count = size(ts_arr->qual,5)
 SELECT DISTINCT
  so.tablespace_name, so.owner, so.segment_name,
  so.segment_type, so.total_space, so.free_space,
  so.extents, so.next_extent, so.row_count,
  so.pct_free, so.failure_flag, so.analyze_flag,
  so.end_dt_tm, rrl.begin_date, rrl.end_date,
  rrl.request_user, line1 = substring(1,125,rrl.user_notes), line2 = substring(126,125,rrl.user_notes
   )
  FROM ref_report_log rrl,
   space_objects so
  PLAN (rrl
   WHERE rrl.report_seq=cnvtint(report_seq))
   JOIN (so
   WHERE so.report_seq=rrl.report_seq
    AND so.tablespace_name=patstring(tsp_name)
    AND so.segment_name=patstring(seg_name)
    AND so.segment_type=patstring(seg_type)
    AND so.pct_free <= exp_pctfree
    AND so.extents >= exp_extents)
  ORDER BY so.tablespace_name, so.segment_name
  HEAD REPORT
   IF (rrl.end_date=null)
    col 10, " DATA BELOW IS INCOMPLETE!!", row + 2
   ENDIF
   col 5, "Space Report Generated:           Database Storage Summary for ",
   CALL print(trim(cnvtupper(database_display))),
   row + 1, col 5, "           Start Time           - ",
   rrl.begin_date"dd-mmm-yyyy hh:mm;;d", row + 1, col 5,
   "           End Time             - ", rrl.end_date"dd-mmm-yyyy hh:mm;;d", row + 1,
   col 5, "           Requested by         - ",
   CALL print(trim(rrl.request_user)),
   row + 1, col 5, "           User Notes           -  * ",
   CALL print(trim(line1)), row + 1, col 5,
   "                                   * ",
   CALL print(trim(line2)), row + 2,
   col 5, "Arguments: Report Sequence #    : ",
   CALL print(trim(cnvtstring(report_seq))),
   row + 1, col 5, "           Database             : ",
   CALL print(trim(cnvtupper(database_display))), row + 1, col 5,
   "           Instance Name        : ",
   CALL print(trim(cnvtupper(instance_display))), row + 1,
   col 5, "           Environment Name     : ",
   CALL print(trim(cnvtupper(environment_display))),
   row + 1, col 5, "           DB Link Name         : ",
   CALL print(trim(cnvtupper(db_link_display))), row + 1, col 5,
   "           Tablespace           : ",
   CALL print(trim(ts_display)), row + 1,
   col 5, "           Owner                : ",
   CALL print(trim(owner_display)),
   row + 1, col 5, "           Object               : ",
   CALL print(trim(obj_display)), row + 1, col 5,
   "           Block Size           : ",
   CALL print(trim(block_size)), row + 2,
   col 5, "Print Options    ", opt,
   col 60, "Exceptions       ", exceptions,
   row + 1, col 5, "           Tablespace Name  : ",
   tsp_name, col 60, "           Only segments with free space % <= ",
   exp_pctfree";l", row + 1, col 5,
   "           Segment Name     : ", seg_name, col 60,
   "           Only segments unable to extend  : ", uto_extend, row + 1,
   col 5, "           Segment Type     : ", seg_type,
   col 60, "           Extents                         >= ", exp_extents";l",
   BREAK, under = fillstring(173,"="), no_page = 0,
   sumf_ts = 0, sumf_fs = 0, sumf_cnt = 0,
   sumf_maxc = 0, sumf_minc = 9999999, sumf_avgc = 0,
   comments = fillstring(20," "), len = 0
  HEAD PAGE
   IF (curpage > 1
    AND row < 3
    AND no_page=2)
    col 1, curdate, " ",
    curtime"hh:mm:ss;;M",
    CALL center("+++++++   MILLENNIUM SPACE REPORT   +++++++",15,140), col 130,
    "Page: ", curpage"###;L", row + 1,
    col 1, "Comment Key notation", row + 1,
    col 3, "1 - Segment has less than 10% free space.", col 60,
    "2 - Not enough free space for segment to extend.", col 130, "3 - Analyze command failed.",
    row + 1, col 3, "4 - Collection unable to gather Row Count information. Row count set to -1.",
    row + 2
   ENDIF
  HEAD so.tablespace_name
   count = size(ts_arr->qual,5)
   FOR (counter = 1 TO count)
     IF ((ts_arr->qual[counter].tablespace_name=so.tablespace_name))
      sumf_ts = (sumf_ts+ ts_arr->qual[counter].total_space), sumf_fs = (sumf_fs+ ts_arr->qual[
      counter].free_space), sumf_cnt = (sumf_cnt+ ts_arr->qual[counter].num_chunks)
      IF ((ts_arr->qual[counter].max_contig > sumf_maxc))
       sumf_maxc = ts_arr->qual[counter].max_contig
      ENDIF
      IF ((ts_arr->qual[counter].min_contig < sumf_minc))
       sumf_minc = ts_arr->qual[counter].min_contig
      ENDIF
      IF (sumf_cnt != 0)
       sumf_avgc = (sumf_fs/ sumf_cnt)
      ENDIF
     ENDIF
   ENDFOR
   no_seg_heads = 0, no_rows = 0, sumo_ts = 0,
   sumo_e = 0, sumo_ne = 0
  DETAIL
   IF (uto_extend="Y")
    test_fs = sumf_maxc
   ENDIF
   IF (uto_extend="N")
    test_fs = 0
   ENDIF
   IF (((so.next_extent > test_fs
    AND uto_extend="Y") OR (so.next_extent >= test_fs
    AND uto_extend="N")) )
    sumo_ts = (sumo_ts+ so.total_space), sumo_e = (sumo_e+ so.extents), sumo_ne = (sumo_ne+ so
    .next_extent),
    no_rows = (no_rows+ 1)
    IF (no_seg_heads=0
     AND no_rows=1
     AND no_page=0)
     col 1, curdate, " ",
     curtime"hh:mm:ss;;M",
     CALL center("+++++++   MILLENNIUM SPACE REPORT   +++++++",15,140), col 130,
     "Page: ", curpage"###;L", row + 1,
     col 1, "Comment Key notation", row + 1,
     col 3, "1 - Segment has less than 10% free space.", col 60,
     "2 - Not enough free space for segment to extend.", col 130, "3 - Analyze command failed.",
     row + 1, col 3, "4 - Collection unable to gather Row Count information. Row count set to -1.",
     row + 2, no_page = 2
    ENDIF
    IF (no_seg_heads=0
     AND no_rows=1)
     col 0, "Tablespace: ",
     CALL print(trim(so.tablespace_name)),
     row + 2, col 0, "Objects:  Total Space",
     col 24, "Free Space", col 37,
     "Extents", col 48, "Next Extent",
     col 70, "Rows", col 78,
     "Pct Free", col 90, "Obj End Dt Tm",
     col 108, "Object Name - Type", col 160,
     "Comments", row + 1, no_seg_heads = 1
    ENDIF
    col 8, so.total_space"#############", col 22,
    so.free_space"############", col 38, so.extents"######",
    col 46, so.next_extent"#############", col 62,
    so.row_count"############", col 79, so.pct_free"#######",
    col 90, so.end_dt_tm"MM/DD HH:MM:SS;;d", col 108,
    CALL print(concat(trim(so.owner),".",trim(so.segment_name)," - ",trim(so.segment_type))),
    comments = " "
    IF (so.pct_free < 10)
     comments = "1,"
    ENDIF
    IF (so.next_extent > sumf_maxc)
     comments = concat(trim(comments)," 2,")
    ENDIF
    IF (so.failure_flag != "N"
     AND so.analyze_flag != "N")
     comments = concat(trim(comments)," 3,")
    ENDIF
    IF ((so.row_count=- (1)))
     comments = concat(trim(comments)," 4,")
    ENDIF
    IF (comments > " ")
     len = size(trim(comments),1), comments = substring(1,(len - 1),comments), comments = concat(
      "*** ",trim(comments)," ***")
    ENDIF
    col 160, comments, comments = " ",
    row + 1
   ENDIF
  FOOT  so.tablespace_name
   IF (no_rows > 0)
    col 0, "TOTALS: ", col 6,
    sumo_ts"###############", col 32, sumo_e"############",
    col 48, sumo_ne"###########", row + 2,
    col 0, "File Id", col 10,
    "Total Space", col 25, "Free Space",
    col 45, "Count", col 61,
    "Max", col 77, "Min",
    col 92, "Avg", row + 1,
    count = size(ts_arr->qual,5)
    FOR (counter = 1 TO count)
      IF ((ts_arr->qual[counter].tablespace_name=so.tablespace_name))
       col 0, ts_arr->qual[counter].file_id"#######", col 10,
       ts_arr->qual[counter].total_space"###########", col 25, ts_arr->qual[counter].free_space
       "##########",
       col 40, ts_arr->qual[counter].num_chunks"##########", col 55,
       ts_arr->qual[counter].max_contig"##########", col 70, ts_arr->qual[counter].min_contig
       "##########",
       col 85, ts_arr->qual[counter].avg_contig"##########", col 100,
       CALL print(trim(ts_arr->qual[counter].file_name)), row + 1
      ENDIF
    ENDFOR
    col 0, "TOTALS: ", col 10,
    sumf_ts"###########", col 25, sumf_fs"##########",
    col 40, sumf_cnt"##########", col 55,
    sumf_maxc"##########", col 70, sumf_minc"##########",
    col 85, sumf_avgc"##########", row + 1,
    col 0, under, row + 2
   ENDIF
   no_seg_heads = 0, no_rows = 0, sumo_ts = 0,
   sumo_e = 0, sumo_ne = 0, sumf_ts = 0,
   sumf_fs = 0, sumf_cnt = 0, sumf_maxc = 0,
   sumf_minc = 9999999, sumf_avgc = 0
  FOOT REPORT
   BREAK, line = fillstring(150," "), row + 1,
   CALL center("******   Space Summary Error Messages Received When Data Was Gathered   ******",15,
   140), row + 3
   FOR (count = 1 TO log_count)
     log_len = 0, col 0, sp_log->qual[count].log_seq
     FOR (cnt = 0 TO 4)
      line = substring(((cnt * 100)+ 1),100,sp_log->qual[count].log_notes),
      IF (line > " ")
       col 20, line, row + 1
      ENDIF
     ENDFOR
     row + 1
   ENDFOR
  WITH nullreport, nocounter, maxcol = 251,
   maxrow = 30, check
 ;end select
#endprogram
 SET reply->status_data.status = "S"
END GO

CREATE PROGRAM db_rpt_trend_space:dba
 PAINT
 SET message = noinformation
 SET trace = nocost
 SET st_seq = 0
 SET e_seq = 0
 SET rs = 0
 SET block_size = 0
 SET num_tsp1 = 0
 SET num_tsp2 = 0
 SET num_seg1 = 0
 SET num_seg2 = 0
 SET st_date = cnvtdatetime(curdate,curtime3)
 SET e_date = cnvtdatetime(curdate,curtime3)
 SET num_days = 0
 SET t1 = 0
 SET t2 = 0
 SET proj_days = 30
 SET proj_date = cnvtdatetime(curdate,curtime3)
 SET un = fillstring(120," ")
 SET seg_name = fillstring(40," ")
 SET seg_type = fillstring(10," ")
 SET tsp_name = fillstring(40," ")
 SET seg_name = "*"
 SET seg_type = "*"
 SET tsp_name = "*"
 SET opt = " "
 SET exep = "N"
 SET g_seg = "N"
 SET ext_proj_date = "N"
 SET no_exts = 0
 SET erows_day = 0
 SET eproj_size = 0
 RECORD proj(
   1 proj_factor = f8
 )
 SET proj->proj_factor = 1.0
 CALL video(r)
 CALL clear(1,1)
 CALL box(5,3,18,60)
 CALL video(n)
 CALL text(3,3,"Database Space Usage Trends",w)
 CALL text(8,15,"N. Generate New Report  ")
 CALL text(10,15,"O. Print Old Report ")
 CALL text(12,15,"Q. Quit")
 CALL text(15,12,"Enter your choice ('N','O','Q'): ")
 CALL accept(15,45,"A;cu","Q"
  WHERE curaccept IN ("N", "O", "Q"))
 SET ch = curaccept
 SELECT INTO "nl:"
  FROM v$parameter v
  WHERE v.name="db_block_size"
  HEAD REPORT
   block_size = 0
  DETAIL
   block_size = cnvtint(v.value)
  WITH nocounter
 ;end select
 IF (ch="O")
  CALL video(r)
  CALL clear(1,1)
  CALL box(6,5,17,60)
  CALL video(n)
  CALL text(4,5,"Print Old Report",w)
  CALL text(10,15,"Enter Report_seq :")
  CALL text(13,15,"All/Custom (A/C)  :")
  CALL text(23,1,"Help available on <HLP> key. Press F3 to exit.")
  SET help =
  SELECT
   r.report_seq";l", i.instance_name, r.begin_date
   FROM ref_report_log r,
    ref_report_parms_log p,
    ref_instance_id i
   WHERE r.report_seq=p.report_seq
    AND p.parm_cd=1
    AND r.report_cd=2
    AND r.end_date != null
    AND p.parm_value=cnvtstring(i.instance_cd)
   WITH nocounter
  ;end select
  SET validate =
  SELECT INTO "nl:"
   l.report_seq
   FROM ref_report_log l
   WHERE l.report_cd=2
    AND l.report_seq=curaccept
   WITH nocounter
  ;end select
  SET validate = 1
  CALL accept(10,35,"9(10)")
  SET rs = cnvtint(curaccept)
  SET validate = off
  SET help = off
  CALL text(23,1,"Enter only either 'A' for all or 'C' for custom.   ")
  CALL accept(13,35,"p;cu","A"
   WHERE curaccept IN ("A", "C"))
  SET opt = curaccept
  CALL clear(23,1)
  CALL text(23,1,"Generating report. Wait for your output filename.")
  IF (opt="C")
   GO TO options
  ENDIF
  IF (opt="A")
   GO TO print_report
  ENDIF
 ENDIF
 IF (ch="Q")
  GO TO terminate
 ENDIF
 CALL video(r)
 CALL clear(1,1)
 CALL box(3,3,20,77)
 CALL video(n)
 CALL text(2,2,"Generate New Trend Report ",w)
 CALL text(5,15,"Enter Start Report_seq :")
 CALL text(7,15,"Enter End Report_seq :")
 CALL text(9,15,"All/custom  (A/C) :")
 CALL text(11,15,"User Notes :")
 CALL text(23,1,"Help available on <HLP> key. Press F3 to exit.")
 SET help =
 SELECT
  r.report_seq";l", i.instance_name, r.begin_date
  FROM ref_report_log r,
   ref_report_parms_log p,
   ref_instance_id i
  WHERE r.report_seq=p.report_seq
   AND p.parm_cd=1
   AND p.parm_value=cnvtstring(i.instance_cd)
   AND r.report_cd=1
   AND r.end_date != null
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  r.report_seq
  FROM ref_report_log r
  WHERE r.report_cd=1
   AND r.report_seq=curaccept
 ;end select
 SET validate = 1
 CALL accept(5,50,"##########")
 SET st_seq = curaccept
 CALL accept(7,50,"##########")
 SET e_seq = curaccept
 SET help = off
 SET validate = off
 CALL clear(23,1)
 CALL text(23,1,"Enter only either 'A' for all or 'C' for custom")
 CALL accept(9,50,"p;cu","A"
  WHERE curaccept IN ("A", "C"))
 SET opt = curaccept
 CALL clear(23,1)
 CALL text(23,1,"Type in your notes. For additional lines press <return> .")
 SET un1 = fillstring(30," ")
 SET un2 = fillstring(30," ")
 SET un3 = fillstring(30," ")
 SET un4 = fillstring(30," ")
 CALL accept(11,40,"p(30);c"," ")
 SET un1 = curaccept
 IF (size(curaccept)=1)
  GO TO lun
 ENDIF
 CALL accept(12,40,"p(30);c"," ")
 SET un2 = curaccept
 IF (size(curaccept)=1)
  GO TO lun
 ENDIF
 CALL accept(13,40,"p(30);c"," ")
 SET un3 = curaccept
 IF (size(curaccept)=1)
  GO TO lun
 ENDIF
 CALL accept(14,40,"p(30);c"," ")
 SET un4 = curaccept
 IF (size(curaccept)=1)
  GO TO lun
 ENDIF
#lun
 SET un = concat(trim(un1),trim(un2),trim(un3),trim(un4))
#options
 IF (opt="C")
  CALL video(r)
  CALL clear(1,1)
  CALL box(4,3,22,77)
  CALL video(n)
  CALL text(2,3,"Custom Options for the Report",w)
  CALL text(6,10,"TableSpace :")
  CALL text(8,10,"Segment Type (T/I):")
  CALL text(10,10,"Segment Name:")
  CALL text(12,10,"Number of days for Projection :")
  CALL text(14,10,"Projection Factor :")
  CALL text(16,10,"Exceptions (Y/N) : ")
  SET accept = nopatcheck
  CALL accept(6,35,"p(35);cu","*")
  SET tsp_name = curaccept
  CALL accept(8,35,"p;cu","*"
   WHERE curaccept IN ("T", "I", "*"))
  SET seg_type = curaccept
  CALL accept(10,35,"p(35);cu","*")
  SET seg_name = curaccept
  CALL accept(12,50,"######",30)
  SET proj_days = curaccept
  CALL accept(14,50,"pppp",format(proj->proj_factor,"###.#;P0"))
  SET proj->proj_factor = cnvtreal(curaccept)
  SET exep = "N"
  CALL accept(16,35,"p;cu","N"
   WHERE curaccept IN ("Y", "N"))
  SET exep = curaccept
  IF (exep="Y")
   CALL text(17,20,"Only growing segments (Y/N)       : ")
   CALL text(18,20,"Extend by projected date (Y/N)    : ")
   CALL text(19,20,"No. of extents   >=               : ")
   CALL text(20,20,"Rows/DAY         >=               : ")
   CALL text(21,20,"Projected Allocated size (MB) >=  : ")
   CALL accept(17,60,"p;cu","N"
    WHERE curaccept IN ("Y", "N"))
   SET g_seg = curaccept
   CALL accept(18,60,"p;cu","N"
    WHERE curaccept IN ("Y", "N"))
   SET ext_proj_date = curaccept
   CALL accept(19,60,"9(4)",0)
   SET no_exts = curaccept
   CALL accept(20,60,"9(8)",0)
   SET erows_day = curaccept
   CALL accept(21,60,"9(8)",0)
   SET eproj_size = curaccept
  ENDIF
  CALL clear(23,1)
  CALL text(23,1,"Processing...")
  IF (ch="O")
   GO TO print_report
  ENDIF
 ENDIF
 RECORD trend_rec(
   1 qual[*]
     2 tablespace_name = c30
     2 total_space = i4
     2 free_space = i4
     2 used_space = i4
     2 num_chunks = i4
     2 total_change = i4
     2 free_change = i4
     2 chunks_change = i4
     2 days_till_full = f8
     2 full_date = dq8
     2 no_segments = i4
     2 comment1 = c20
     2 qual[*]
       3 owner = c30
       3 segment_name = c30
       3 segment_type = c12
       3 num_rows_added = i4
       3 total_space = i4
       3 total_change = i4
       3 used_space = i4
       3 free_space = i4
       3 rows_day = f8
       3 bytes_row = i4
       3 bytes_day = f8
       3 extents_added = i4
       3 extents = i4
       3 next_extent = i4
       3 next_extent_date = dq8
       3 days_till_next = i4
       3 pctincrease = i4
       3 dropped = c2
       3 created = c2
       3 migrated = c2
       3 comment1 = c20
       3 comment2 = c3
 )
 RECORD tsp_rec1(
   1 qual[*]
     2 tablespace_name = c30
     2 total_rows = i4
     2 total_space = f8
     2 free_space = f8
     2 used_space = f8
     2 no_segments = i4
     2 total_chunks = i4
     2 qual1[*]
       3 file_name = c50
       3 t_space = f8
       3 f_space = f8
       3 u_space = f8
       3 num_chunks = i4
     2 qual2[*]
       3 owner = c30
       3 segment_name = c30
       3 segment_type = c12
       3 total_space = f8
       3 free_space = f8
       3 used_space = f8
       3 extents = i4
       3 next_extent = i4
       3 row_count = f8
       3 pctincrease = f8
       3 comment1 = c3
 )
 RECORD tsp_rec2(
   1 qual[*]
     2 tablespace_name = c30
     2 total_rows = f8
     2 total_space = f8
     2 free_space = f8
     2 used_space = f8
     2 total_chunks = i4
     2 no_segments = i4
     2 qual1[*]
       3 file_name = c50
       3 t_space = f8
       3 f_space = f8
       3 u_space = f8
       3 num_chunks = i4
     2 qual2[*]
       3 owner = c30
       3 segment_name = c30
       3 segment_type = c12
       3 total_space = f8
       3 free_space = f8
       3 used_space = f8
       3 extents = i4
       3 next_extent = i4
       3 row_count = f8
       3 pctincrease = f8
       3 comment1 = c3
 )
 RECORD temp1(
   1 qual[*]
     2 tsp_name = c80
 )
 RECORD temp2(
   1 qual[*]
     2 tsp_name = c80
 )
 RECORD seg_rec1(
   1 qual[*]
     2 tablespace_name = c40
     2 owner = c30
     2 segment_name = c30
     2 total_space = f8
     2 free_space = f8
     2 used_space = f8
     2 extents = i4
     2 next_extent = i4
     2 num_rows = f8
     2 flag = c2
     2 comment = c20
 )
 RECORD seg_rec2(
   1 qual[*]
     2 tablespace_name = c40
     2 owner = c30
     2 segment_name = c40
     2 total_space = f8
     2 free_space = f8
     2 used_space = f8
     2 extents = i4
     2 next_extent = i4
     2 num_rows = f8
     2 rows_day = i4
     2 bytes_day = i4
     2 total_change = i4
     2 days_till_next = i4
     2 full_date = dq8
     2 flag = c2
     2 comment = c20
 )
 SELECT DISTINCT INTO "nl:"
  r_seq = decode(d1.seq,sf.report_seq,so.report_seq), side = decode(d1.seq,"FILE","OBJE"),
  tablespace_name = decode(d1.seq,sf.tablespace_name,so.tablespace_name),
  segment_name = decode(d1.seq,substring(1,81,sf.file_name),so.segment_name), free_space_nullind =
  nullind(so.free_space), sf.*,
  so.*
  FROM space_files sf,
   space_objects so,
   (dummyt d1  WITH seq = 1)
  PLAN (sf
   WHERE ((sf.report_seq=st_seq) OR (sf.report_seq=e_seq)) )
   JOIN (((d1
   WHERE 1=d1.seq)
   ) ORJOIN ((so
   WHERE so.report_seq=sf.report_seq
    AND so.tablespace_name=sf.tablespace_name)
   ))
  ORDER BY tablespace_name, r_seq, side,
   segment_name
  HEAD REPORT
   num_tsp1 = 0, num_tsp2 = 0
  HEAD r_seq
   num_files1 = 0, num_files2 = 0, numrecs1 = 0,
   numrecs2 = 0
   IF (r_seq=st_seq)
    num_tsp1 = (num_tsp1+ 1), stat = alterlist(tsp_rec1->qual,num_tsp1), tsp_rec1->qual[num_tsp1].
    tablespace_name = so.tablespace_name,
    tsp_rec1->qual[num_tsp1].total_rows = 0
   ENDIF
   IF (r_seq=e_seq)
    num_tsp2 = (num_tsp2+ 1), stat = alterlist(tsp_rec2->qual,num_tsp2), tsp_rec2->qual[num_tsp2].
    tablespace_name = so.tablespace_name,
    tsp_rec2->qual[num_tsp2].total_rows = 0
   ENDIF
  HEAD segment_name
   row + 0
  DETAIL
   IF (side="OBJE")
    IF (r_seq=st_seq)
     numrecs1 = (numrecs1+ 1), stat = alterlist(tsp_rec1->qual[num_tsp1].qual2,numrecs1), tsp_rec1->
     qual[num_tsp1].qual2[numrecs1].owner = so.owner,
     tsp_rec1->qual[num_tsp1].qual2[numrecs1].segment_name = so.segment_name, tsp_rec1->qual[num_tsp1
     ].qual2[numrecs1].segment_type = so.segment_type, tsp_rec1->qual[num_tsp1].qual2[numrecs1].
     free_space = so.free_space,
     tsp_rec1->qual[num_tsp1].qual2[numrecs1].total_space = so.total_space, tsp_rec1->qual[num_tsp1].
     qual2[numrecs1].extents = so.extents, tsp_rec1->qual[num_tsp1].qual2[numrecs1].next_extent = so
     .next_extent,
     tsp_rec1->qual[num_tsp1].qual2[numrecs1].row_count = so.row_count, tsp_rec1->qual[num_tsp1].
     qual2[numrecs1].pctincrease = so.pctincrease
     IF (1=free_space_nullind)
      tsp_rec1->qual[num_tsp1].qual2[numrecs1].comment1 = "2"
     ELSE
      tsp_rec1->qual[num_tsp1].qual2[numrecs1].comment1 = " "
     ENDIF
     tsp_rec1->qual[num_tsp1].qual2[numrecs1].used_space = (tsp_rec1->qual[num_tsp1].qual2[numrecs1].
     total_space - tsp_rec1->qual[num_tsp1].qual2[numrecs1].free_space), row + 1
    ENDIF
    IF (r_seq=e_seq)
     numrecs2 = (numrecs2+ 1), stat = alterlist(tsp_rec2->qual[num_tsp2].qual2,numrecs2), tsp_rec2->
     qual[num_tsp2].qual2[numrecs2].owner = so.owner,
     tsp_rec2->qual[num_tsp2].qual2[numrecs2].segment_name = so.segment_name, tsp_rec2->qual[num_tsp2
     ].qual2[numrecs2].segment_type = so.segment_type, tsp_rec2->qual[num_tsp2].qual2[numrecs2].
     total_space = so.total_space,
     tsp_rec2->qual[num_tsp2].qual2[numrecs2].free_space = so.free_space, tsp_rec2->qual[num_tsp2].
     qual2[numrecs2].extents = so.extents, tsp_rec2->qual[num_tsp2].qual2[numrecs2].next_extent = so
     .next_extent,
     tsp_rec2->qual[num_tsp2].qual2[numrecs2].row_count = so.row_count, tsp_rec2->qual[num_tsp2].
     qual2[numrecs2].pctincrease = so.pctincrease
     IF (1=free_space_nullind)
      tsp_rec2->qual[num_tsp2].qual2[numrecs2].comment1 = "3"
     ELSE
      tsp_rec2->qual[num_tsp2].qual2[numrecs2].comment1 = " "
     ENDIF
     tsp_rec2->qual[num_tsp2].qual2[numrecs2].used_space = (tsp_rec2->qual[num_tsp2].qual2[numrecs2].
     total_space - tsp_rec2->qual[num_tsp2].qual2[numrecs2].free_space), row + 1
    ENDIF
   ELSE
    IF (r_seq=st_seq)
     num_files1 = (num_files1+ 1), stat = alterlist(tsp_rec1->qual[num_tsp1].qual1,num_files1),
     tsp_rec1->qual[num_tsp1].qual1[num_files1].file_name = sf.file_name,
     tsp_rec1->qual[num_tsp1].qual1[num_files1].t_space = sf.total_space, tsp_rec1->qual[num_tsp1].
     qual1[num_files1].f_space = sf.free_space, tsp_rec1->qual[num_tsp1].qual1[num_files1].u_space =
     (sf.total_space - sf.free_space),
     tsp_rec1->qual[num_tsp1].qual1[num_files1].num_chunks = sf.num_chunks
    ENDIF
    IF (r_seq=e_seq)
     num_files2 = (num_files2+ 1), stat = alterlist(tsp_rec2->qual[num_tsp2].qual1,num_files2),
     tsp_rec2->qual[num_tsp2].qual1[num_files2].file_name = sf.file_name,
     tsp_rec2->qual[num_tsp2].qual1[num_files2].t_space = sf.total_space, tsp_rec2->qual[num_tsp2].
     qual1[num_files2].f_space = sf.free_space, tsp_rec2->qual[num_tsp2].qual1[num_files2].u_space =
     (sf.total_space - sf.free_space),
     tsp_rec2->qual[num_tsp2].qual1[num_files2].num_chunks = sf.num_chunks
    ENDIF
   ENDIF
  FOOT  segment_name
   IF (side="OBJE")
    IF (r_seq=st_seq)
     tsp_rec1->qual[num_tsp1].total_rows = (tsp_rec1->qual[num_tsp1].total_rows+ tsp_rec1->qual[
     num_tsp1].qual2[numrecs1].row_count)
    ENDIF
    IF (r_seq=e_seq)
     tsp_rec2->qual[num_tsp2].total_rows = (tsp_rec2->qual[num_tsp2].total_rows+ tsp_rec2->qual[
     num_tsp2].qual2[numrecs2].row_count)
    ENDIF
   ENDIF
  FOOT  r_seq
   free_space = 0.0, total_space = 0.0, used_space = 0.0,
   total_chunks = 0
   IF (r_seq=st_seq)
    lvar = 0
    FOR (lvar = 1 TO num_files1)
      free_space = (free_space+ tsp_rec1->qual[num_tsp1].qual1[lvar].f_space), total_space = (
      total_space+ tsp_rec1->qual[num_tsp1].qual1[lvar].t_space), used_space = (used_space+ tsp_rec1
      ->qual[num_tsp1].qual1[lvar].u_space),
      total_chunks = (total_chunks+ tsp_rec1->qual[num_tsp1].qual1[lvar].num_chunks)
    ENDFOR
    row + 1, tsp_rec1->qual[num_tsp1].tablespace_name = tablespace_name, tsp_rec1->qual[num_tsp1].
    total_space = total_space,
    tsp_rec1->qual[num_tsp1].free_space = free_space, tsp_rec1->qual[num_tsp1].used_space =
    used_space, tsp_rec1->qual[num_tsp1].total_chunks = total_chunks,
    tsp_rec1->qual[num_tsp1].no_segments = numrecs1, row + 1
   ENDIF
   IF (r_seq=e_seq)
    lvar = 0
    FOR (lvar = 1 TO num_files2)
      free_space = (free_space+ tsp_rec2->qual[num_tsp2].qual1[lvar].f_space), total_space = (
      total_space+ tsp_rec2->qual[num_tsp2].qual1[lvar].t_space), used_space = (used_space+ tsp_rec2
      ->qual[num_tsp2].qual1[lvar].u_space),
      total_chunks = (total_chunks+ tsp_rec2->qual[num_tsp2].qual1[lvar].num_chunks)
    ENDFOR
    row + 1, tsp_rec2->qual[num_tsp2].tablespace_name = tablespace_name, tsp_rec2->qual[num_tsp2].
    total_space = total_space,
    tsp_rec2->qual[num_tsp2].free_space = free_space, tsp_rec2->qual[num_tsp2].used_space =
    used_space, tsp_rec2->qual[num_tsp2].total_chunks = total_chunks,
    tsp_rec2->qual[num_tsp2].no_segments = numrecs2, row + 1
   ENDIF
  WITH counter, outerjoin = d1, maxcol = 250,
   format = variable, maxrow = 59
 ;end select
 SELECT INTO "nl:"
  so.tablespace_name
  FROM space_objects so
  WHERE so.report_seq=st_seq
   AND  NOT (so.tablespace_name IN (
  (SELECT
   o.tablespace_name
   FROM space_objects o
   WHERE o.report_seq=e_seq)))
  ORDER BY so.tablespace_name
  HEAD REPORT
   t1 = 0
  HEAD so.tablespace_name
   t1 = (t1+ 1), stat = alterlist(temp1->qual,t1)
  DETAIL
   temp1->qual.tsp_name = so.tablespace_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  so.tablespace_name
  FROM space_objects so
  WHERE so.report_seq=e_seq
   AND  NOT (so.tablespace_name IN (
  (SELECT
   o.tablespace_name
   FROM space_objects o
   WHERE o.report_seq=st_seq)))
  ORDER BY so.tablespace_name
  HEAD REPORT
   t2 = 0
  HEAD so.tablespace_name
   t2 = (t2+ 1), stat = alterlist(temp2->qual,t2)
  DETAIL
   temp2->qual.tsp_name = so.tablespace_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_report_log r
  WHERE r.report_seq IN (st_seq, e_seq)
  DETAIL
   IF (r.report_seq=st_seq)
    st_date = r.begin_date
   ELSE
    e_date = r.begin_date
   ENDIF
  WITH nocounter
 ;end select
 SET num_days = datetimecmp(e_date,st_date)
 SET proj_date = datetimeadd(e_date,proj_days)
 SET i = 0
 SET j = 0
 SET ttot_rows = 0.0
 SET ttot_bytes = 0.0
 SET trow_day = 0.0
 SET tbytes_row = 0
 SET tbytes_day = 0.0
 SET tfree_space = 0
 SET tfull_date = cnvtdatetime(curdate,curtime3)
 SET nos = 0
 SET stot_rows = 0.0
 SET srows_day = 0.0
 SET srow_bytes = 0.0
 SET sbytes_day = 0.0
 SET free_space = 0
 SET days_till_full = 0
 SET full_date = cnvtdatetime(curdate,curtime3)
 SET extents = 0
 SET next_extent_blocks = 0
 SET blocks_avail = 0
 SET n = 0
 SET adays = 0
 SET bbytes_day = 0.0
 SET chunk_change = 0
 FOR (i = 1 TO num_tsp1)
   FOR (j = 1 TO num_tsp2)
     IF ((tsp_rec1->qual[i].tablespace_name=tsp_rec2->qual[j].tablespace_name))
      SET n = (n+ 1)
      SET stat = alterlist(trend_rec->qual,n)
      SET trend_rec->qual[n].tablespace_name = tsp_rec1->qual[i].tablespace_name
      SET trend_rec->qual[n].total_change = (tsp_rec2->qual[j].total_space - tsp_rec1->qual[i].
      total_space)
      SET trend_rec->qual[n].total_space = tsp_rec2->qual[j].total_space
      SET trend_rec->qual[n].free_change = (tsp_rec2->qual[j].free_space - tsp_rec1->qual[i].
      free_space)
      SET trend_rec->qual[n].free_space = tsp_rec2->qual[j].free_space
      SET trend_rec->qual[n].used_space = (tsp_rec2->qual[j].used_space - tsp_rec1->qual[i].
      used_space)
      SET trend_rec->qual[n].chunks_change = (tsp_rec2->qual[j].total_chunks - tsp_rec1->qual[i].
      total_chunks)
      SET trend_rec->qual[n].num_chunks = tsp_rec2->qual[j].total_chunks
      SET trend_rec->qual[n].no_segments = tsp_rec1->qual[i].no_segments
      SET nos1 = tsp_rec1->qual[i].no_segments
      SET nos2 = tsp_rec2->qual[j].no_segments
      SET l = 0
      SET flag1 = 0
      SET flag2 = 0
      FOR (k = 1 TO nos1)
        SET flag1 = 0
        SET flag2 = 0
        FOR (m = 1 TO nos2)
          IF ((tsp_rec1->qual[i].qual2[k].segment_name=tsp_rec2->qual[j].qual2[m].segment_name)
           AND (tsp_rec1->qual[i].qual2[k].owner=tsp_rec2->qual[j].qual2[m].owner))
           SET flag1 = 1
           SET l = (l+ 1)
           SET stat = alterlist(trend_rec->qual[n].qual,l)
           SET trend_rec->qual[n].qual[l].owner = tsp_rec2->qual[j].qual2[m].owner
           SET trend_rec->qual[n].qual[l].segment_name = tsp_rec1->qual[i].qual2[k].segment_name
           SET trend_rec->qual[n].qual[l].segment_type = tsp_rec1->qual[i].qual2[k].segment_type
           SET trend_rec->qual[n].qual[l].pctincrease = tsp_rec2->qual[i].qual2[k].pctincrease
           SET trend_rec->qual[n].qual[l].total_change = (tsp_rec2->qual[j].qual2[m].total_space -
           tsp_rec1->qual[i].qual2[k].total_space)
           SET trend_rec->qual[n].qual[l].total_space = tsp_rec2->qual[j].qual2[m].total_space
           SET trend_rec->qual[n].qual[l].free_space = tsp_rec2->qual[j].qual2[m].free_space
           SET trend_rec->qual[n].qual[l].used_space = (tsp_rec2->qual[j].qual2[m].used_space -
           tsp_rec1->qual[i].qual2[k].used_space)
           SET stot_rows = (tsp_rec2->qual[j].qual2[m].row_count - tsp_rec1->qual[i].qual2[k].
           row_count)
           SET stot_bytes = (trend_rec->qual[n].qual[l].used_space * block_size)
           SET srow_day = (stot_rows/ num_days)
           SET sbytes_day = (stot_bytes/ num_days)
           SET free_space = tsp_rec2->qual[j].qual2[m].free_space
           SET days_till_full = ((free_space * block_size)/ sbytes_day)
           SET full_date = datetimeadd(e_date,days_till_full)
           SET extents = (tsp_rec2->qual[j].qual2[m].extents - tsp_rec1->qual[i].qual2[k].extents)
           SET trend_rec->qual[n].qual[l].num_rows_added = stot_rows
           SET trend_rec->qual[n].qual[l].rows_day = srow_day
           SET trend_rec->qual[n].qual[l].bytes_day = sbytes_day
           SET trend_rec->qual[n].qual[l].extents_added = extents
           SET trend_rec->qual[n].qual[l].extents = tsp_rec2->qual[j].qual2[m].extents
           SET trend_rec->qual[n].qual[l].next_extent = tsp_rec2->qual[j].qual2[m].next_extent
           SET trend_rec->qual[n].qual[l].days_till_next = days_till_full
           IF (sbytes_day=0)
            SET trend_rec->qual[n].qual[l].next_extent_date = null
           ENDIF
           IF (sbytes_day > 0)
            SET trend_rec->qual[n].qual[l].next_extent_date = full_date
           ENDIF
           SET trend_rec->qual[n].qual[l].comment1 = fillstring(20," ")
           IF (datetimecmp(full_date,proj_date) <= 0
            AND sbytes_day != 0)
            SET trend_rec->qual[n].qual[l].comment1 = "1"
           ENDIF
           IF ((tsp_rec1->qual[i].qual2[k].comment1 != " "))
            IF ((trend_rec->qual[n].qual[l].comment1=" "))
             SET trend_rec->qual[n].qual[l].comment1 = "2"
            ELSE
             SET trend_rec->qual[n].qual[l].comment1 = build(trend_rec->qual[n].qual[l].comment1,",2"
              )
            ENDIF
           ENDIF
           IF ((tsp_rec2->qual[j].qual2[m].comment1 != " "))
            IF ((trend_rec->qual[n].qual[l].comment1=" "))
             SET trend_rec->qual[n].qual[l].comment1 = "3"
            ELSE
             SET trend_rec->qual[n].qual[l].comment1 = build(trend_rec->qual[n].qual[l].comment1,",3"
              )
            ENDIF
           ENDIF
           SET trend_rec->qual[n].qual[l].dropped = "N"
           SET trend_rec->qual[n].qual[l].created = "N"
           SET trend_rec->qual[n].qual[l].migrated = "N"
          ENDIF
        ENDFOR
        IF (flag1=0)
         SET flag2 = 1
         SET l = (l+ 1)
         SET stat = alterlist(trend_rec->qual[n].qual,l)
         SET trend_rec->qual[n].qual[l].owner = tsp_rec1->qual[i].qual2[k].owner
         SET trend_rec->qual[n].qual[l].segment_name = tsp_rec1->qual[i].qual2[k].segment_name
         SET trend_rec->qual[n].qual[l].pctincrease = 0
         SET trend_rec->qual[n].qual[l].segment_type = tsp_rec1->qual[i].qual2[k].segment_type
         SET trend_rec->qual[n].qual[l].total_space = 0
         SET trend_rec->qual[n].qual[l].total_change = - (tsp_rec1->qual[i].qual2[k].total_space)
         SET trend_rec->qual[n].qual[l].free_space = - (tsp_rec1->qual[i].qual2[k].free_space)
         SET trend_rec->qual[n].qual[l].used_space = - (tsp_rec1->qual[i].qual2[k].used_space)
         SET stot_rows = - (tsp_rec1->qual[i].qual2[k].row_count)
         SET stot_bytes = (trend_rec->qual[n].qual[k].used_space * block_size)
         SET srow_day = (stot_rows/ num_days)
         SET sbytes_day = (stot_bytes/ num_days)
         SET free_space = tsp_rec1->qual[i].qual2[k].free_space
         SET days_till_full = ((free_space * block_size)/ sbytes_day)
         SET full_date = datetimeadd(e_date,days_till_full)
         SET extents = - (tsp_rec1->qual[i].qual2[k].extents)
         SET trend_rec->qual[n].qual[l].num_rows_added = stot_rows
         SET trend_rec->qual[n].qual[l].rows_day = null
         SET trend_rec->qual[n].qual[l].bytes_day = null
         SET trend_rec->qual[n].qual[l].extents_added = extents
         SET trend_rec->qual[n].qual[l].extents = 0
         SET trend_rec->qual[n].qual[l].next_extent = 0
         SET trend_rec->qual[n].qual[l].days_till_next = 0
         SET trend_rec->qual[n].qual[l].next_extent_date = null
         SET trend_rec->qual[n].qual[l].comment1 = fillstring(20," ")
         SET trend_rec->qual[n].qual[l].dropped = "Y"
         IF ((tsp_rec1->qual[i].qual2[k].comment1 != " "))
          IF ((trend_rec->qual[n].qual[l].comment1=" "))
           SET trend_rec->qual[n].qual[l].comment1 = "2"
          ELSE
           SET trend_rec->qual[n].qual[l].comment1 = build(trend_rec->qual[n].qual[l].comment1,",2")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      FOR (x = 1 TO nos2)
        SET flag = 0
        FOR (y = 1 TO nos1)
          IF ((tsp_rec2->qual[i].qual2[x].segment_name=tsp_rec1->qual[j].qual2[y].segment_name)
           AND (tsp_rec2->qual[i].qual2[x].owner=tsp_rec1->qual[j].qual2[y].owner))
           SET flag = 1
          ENDIF
        ENDFOR
        IF (flag=0)
         SET l = (l+ 1)
         SET stat = alterlist(trend_rec->qual[n].qual,l)
         SET trend_rec->qual[n].qual[l].owner = tsp_rec2->qual[j].qual2[x].owner
         SET trend_rec->qual[n].qual[l].segment_name = tsp_rec2->qual[j].qual2[x].segment_name
         SET trend_rec->qual[n].qual[l].segment_type = tsp_rec2->qual[j].qual2[x].segment_type
         SET trend_rec->qual[n].qual[l].pctincrease = tsp_rec2->qual[j].qual2[x].pctincrease
         SET trend_rec->qual[n].qual[l].total_space = tsp_rec2->qual[j].qual2[x].total_space
         SET trend_rec->qual[n].qual[l].total_change = tsp_rec2->qual[j].qual2[x].total_space
         SET trend_rec->qual[n].qual[l].free_space = tsp_rec2->qual[j].qual2[x].free_space
         SET trend_rec->qual[n].qual[l].used_space = tsp_rec2->qual[j].qual2[x].used_space
         SET trend_rec->qual[n].qual[l].created = "Y"
         SET stot_rows = tsp_rec2->qual[j].qual2[x].row_count
         SET stot_bytes = (trend_rec->qual[n].qual[l].used_space * block_size)
         SET srow_day = (stot_rows/ num_days)
         SET sbytes_day = (stot_bytes/ num_days)
         SET free_space = tsp_rec2->qual[j].qual2[x].free_space
         SET days_till_full = ((free_space * block_size)/ sbytes_day)
         SET full_date = datetimeadd(e_date,days_till_full)
         SET extents = tsp_rec2->qual[j].qual2[x].extents
         SET trend_rec->qual[n].qual[l].num_rows_added = stot_rows
         SET trend_rec->qual[n].qual[l].rows_day = null
         SET trend_rec->qual[n].qual[l].bytes_day = null
         SET trend_rec->qual[n].qual[l].extents_added = extents
         SET trend_rec->qual[n].qual[l].extents = tsp_rec2->qual[j].qual2[x].extents
         SET trend_rec->qual[n].qual[l].next_extent = tsp_rec2->qual[j].qual2[x].next_extent
         SET trend_rec->qual[n].qual[l].days_till_next = null
         SET trend_rec->qual[n].qual[l].next_extent_date = null
         SET trend_rec->qual[n].qual[l].comment1 = fillstring(20," ")
         IF ((tsp_rec2->qual[j].qual2[x].comment1 != " "))
          IF ((trend_rec->qual[n].qual[l].comment1=" "))
           SET trend_rec->qual[n].qual[l].comment1 = "3"
          ELSE
           SET trend_rec->qual[n].qual[l].comment1 = build(trend_rec->qual[n].qual[l].comment1,",3")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET trend_rec->qual[n].no_segments = l
     ENDIF
   ENDFOR
 ENDFOR
 IF (t1 > 0)
  FOR (j = 1 TO t1)
    FOR (i = 1 TO num_tsp1)
      IF ((tsp_rec1->qual[i].tablespace_name=temp1->qual[j].tsp_name))
       SET n = (n+ 1)
       SET stat = alterlist(trend_rec->qual,n)
       SET trend_rec->qual[n].tablespace_name = tsp_rec1->qual[i].tablespace_name
       SET trend_rec->qual[n].total_change = - (tsp_rec1->qual[i].total_space)
       SET trend_rec->qual[n].total_space = 0
       SET trend_rec->qual[n].free_change = - (tsp_rec1->qual[i].used_space)
       SET trend_rec->qual[n].free_space = 0
       SET trend_rec->qual[n].used_space = - (tsp_rec1->qual[i].used_space)
       SET trend_rec->qual[n].chunks_change = - (tsp_rec1->qual[i].total_chunks)
       SET trend_rec->qual[n].num_chunks = 0
       SET ttot_bytes = (trend_rec->qual[n].used_space * block_size)
       SET tbytes_day = (ttot_bytes/ num_days)
       SET tfree_space = tsp_rec1->qual[i].free_space
       SET tdays_till_full = ((tfree_space * block_size)/ tbytes_day)
       SET tfull_date = datetimeadd(e_date,tdays_till_full)
       SET trend_rec->qual[n].rows_day = trow_day
       SET trend_rec->qual[n].bytes_day = tbytes_day
       SET trend_rec->qual[n].days_till_full = tdays_till_full
       SET trend_rec->qual[n].full_date = tfull_date
       SET tproj_alloc_size = 0.0
       SET trend_rec->qual[n].no_segments = tsp_rec1->qual[i].no_segments
       SET nos1 = tsp_rec1->qual[i].no_segments
       SET k = 0
       FOR (k = 1 TO nos1)
         SET stat = alterlist(trend_rec->qual[n].qual,k)
         SET trend_rec->qual[n].qual[k].owner = tsp_rec1->qual[i].qual2[k].owner
         SET trend_rec->qual[n].qual[k].segment_name = tsp_rec1->qual[i].qual2[k].segment_name
         SET trend_rec->qual[n].qual[k].segment_type = tsp_rec1->qual[i].qual2[k].segment_type
         SET trend_rec->qual[n].qual[l].pctincrease = 0
         SET trend_rec->qual[n].qual[k].total_space = 0
         SET trend_rec->qual[n].qual[k].total_change = - (tsp_rec1->qual[i].qual2[k].total_space)
         SET trend_rec->qual[n].qual[k].free_space = - (tsp_rec1->qual[i].qual2[k].free_space)
         SET trend_rec->qual[n].qual[k].used_space = - (tsp_rec1->qual[i].qual2[k].used_space)
         SET trend_rec->qual[n].qual[k].dropped = "Y"
         SET stot_rows = - (tsp_rec1->qual[i].qual2[k].row_count)
         SET stot_bytes = (trend_rec->qual[n].qual[k].used_space * block_size)
         SET srow_day = (stot_rows/ num_days)
         SET sbytes_day = (stot_bytes/ num_days)
         SET free_space = - (tsp_rec1->qual[i].qual2[k].free_space)
         SET days_till_full = ((free_space * block_size)/ sbytes_day)
         SET full_date = datetimeadd(e_date,days_till_full)
         SET extents = - (tsp_rec1->qual[i].qual2[k].extents)
         SET trend_rec->qual[n].qual[k].num_rows_added = stot_rows
         SET trend_rec->qual[n].qual[k].rows_day = null
         SET trend_rec->qual[n].qual[k].bytes_day = null
         SET trend_rec->qual[n].qual[k].extents_added = extents
         SET trend_rec->qual[n].qual[k].extents = 0
         SET trend_rec->qual[n].qual[k].next_extent = 0
         SET trend_rec->qual[n].qual[k].days_till_next = null
         SET trend_rec->qual[n].qual[k].next_extent_date = null
         SET trend_rec->qual[n].qual[k].comment1 = fillstring(20," ")
         IF ((trend_rec->qual[n].qual[k].comment1=" "))
          SET trend_rec->qual[l].comment1 = "3"
         ELSE
          SET trend_rec->qual[l].comment1 = "1,3"
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF (t2 > 0)
  FOR (j = 1 TO t2)
    FOR (i = 1 TO num_tsp2)
      IF ((tsp_rec2->qual[i].tablespace_name=temp2->qual[j].tsp_name))
       SET n = (n+ 1)
       SET stat = alterlist(trend_rec->qual,n)
       SET trend_rec->qual[n].tablespace_name = tsp_rec2->qual[i].tablespace_name
       SET trend_rec->qual[n].total_space = tsp_rec2->qual[i].total_space
       SET trend_rec->qual[n].free_space = tsp_rec2->qual[i].free_space
       SET trend_rec->qual[n].used_space = tsp_rec2->qual[i].used_space
       SET trend_rec->qual[n].num_chunks = tsp_rec2->qual[i].total_chunks
       SET trend_rec->qual[n].total_change = tsp_rec2->qual[i].total_space
       SET trend_rec->qual[n].free_change = tsp_rec2->qual[i].free_space
       SET trend_rec->qual[n].chunks_change = tsp_rec2->qual[i].total_chunks
       SET ttot_bytes = (trend_rec->qual[n].used_space * block_size)
       SET tbytes_day = (ttot_bytes/ num_days)
       SET tfree_space = tsp_rec2->qual[i].free_space
       SET tdays_till_full = ((tfree_space * block_size)/ tbytes_day)
       SET tfull_date = datetimeadd(e_date,tdays_till_full)
       SET trend_rec->qual[n].bytes_day = tbytes_day
       SET trend_rec->qual[n].days_till_full = tdays_till_full
       SET trend_rec->qual[n].full_date = tfull_date
       SET nos2 = tsp_rec2->qual[i].no_segments
       SET trend_rec->qual[n].no_segments = tsp_rec2->qual[i].no_segments
       SET tproj_alloc_size = 0.0
       FOR (k = 1 TO nos2)
         SET stat = alterlist(trend_rec->qual[n].qual,k)
         SET trend_rec->qual[n].qual[k].owner = tsp_rec2->qual[i].qual2[k].owner
         SET trend_rec->qual[n].qual[k].segment_name = tsp_rec2->qual[i].qual2[k].segment_name
         SET trend_rec->qual[n].qual[k].segment_type = tsp_rec2->qual[i].qual2[k].segment_type
         SET trend_rec->qual[n].qual[l].pctincrease = tsp_rec2->qual[j].qual2[x].pctincrease
         SET trend_rec->qual[n].qual[k].total_space = tsp_rec2->qual[i].qual2[k].total_space
         SET trend_rec->qual[n].qual[k].total_change = tsp_rec2->qual[i].qual2[k].total_space
         SET trend_rec->qual[n].qual[k].free_space = tsp_rec2->qual[i].qual2[k].free_space
         SET trend_rec->qual[n].qual[k].used_space = tsp_rec2->qual[i].qual2[k].used_space
         SET trend_rec->qual[n].qual[k].created = "Y"
         SET stot_rows = tsp_rec2->qual[i].qual2[k].row_count
         SET stot_bytes = (trend_rec->qual[n].qual[k].used_space * block_size)
         SET srow_day = (stot_rows/ num_days)
         SET sbytes_day = (stot_bytes/ num_days)
         SET free_space = tsp_rec2->qual[i].qual2[k].free_space
         SET days_till_full = ((free_space * block_size)/ sbytes_day)
         SET full_date = datetimeadd(e_date,days_till_full)
         SET extents = tsp_rec2->qual[i].qual2[k].extents
         SET trend_rec->qual[n].qual[k].num_rows_added = stot_rows
         SET trend_rec->qual[n].qual[k].rows_day = null
         SET trend_rec->qual[n].qual[k].bytes_day = null
         SET trend_rec->qual[n].qual[k].extents_added = extents
         SET trend_rec->qual[n].qual[k].extents = tsp_rec2->qual[i].qual2[k].extents
         SET trend_rec->qual[n].qual[k].next_extent = tsp_rec2->qual[i].qual2[k].next_extent
         SET trend_rec->qual[n].qual[k].days_till_next = null
         SET trend_rec->qual[n].qual[k].next_extent_date = null
         SET trend_rec->qual[n].qual[k].comment1 = fillstring(20," ")
         IF ((trend_rec->qual[n].qual[k].comment1="  "))
          SET trend_rec->qual[n].qual[k].comment1 = "2"
         ELSE
          SET trend_rec->qual[n].qual[k].comment1 = build(trend_rec->qual[n].qual[k].comment1,",2")
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET i_code = 0
 SELECT INTO "nl:"
  new_seq = seq(report_sequence,nextval)
  FROM dual
  DETAIL
   rs = new_seq
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_report_log l,
   ref_report_parms_log p
  WHERE l.report_seq=p.report_seq
   AND l.report_seq=e_seq
   AND p.parm_cd=1
   AND l.report_cd=1
  DETAIL
   i_code = cnvtint(p.parm_value)
  WITH nocounter
 ;end select
 INSERT  FROM ref_report_log l
  SET l.report_seq = rs, l.report_cd = 2, l.begin_date = cnvtdatetime(curdate,curtime3),
   l.end_date = cnvtdatetime(curdate,curtime3), l.request_user = curuser, l.user_notes = un
  WITH nocounter
 ;end insert
 INSERT  FROM ref_report_parms_log p
  SET p.report_seq = rs, p.parm_cd = 1, p.value_seq = 1,
   p.parm_value = cnvtstring(i_code)
  WITH nocountei
 ;end insert
 INSERT  FROM ref_report_parms_log p
  SET p.report_seq = rs, p.parm_cd = 8, p.value_seq = 1,
   p.parm_value = cnvtstring(st_seq)
  WITH nocounter
 ;end insert
 INSERT  FROM ref_report_parms_log p
  SET p.report_seq = rs, p.parm_cd = 9, p.value_seq = 1,
   p.parm_value = cnvtstring(e_seq)
  WITH nocounter
 ;end insert
 SET cnt = 0
 FOR (cnt = 1 TO n)
   INSERT  FROM trend_tablespace ts
    SET ts.report_seq = rs, ts.instance_cd = i_code, ts.tablespace_name = trend_rec->qual[cnt].
     tablespace_name,
     ts.added_allocated_space = trend_rec->qual[cnt].used_space, ts.total_space = trend_rec->qual[cnt
     ].total_space, ts.free_space = trend_rec->qual[cnt].free_space,
     ts.total_space_growth = trend_rec->qual[cnt].total_change, ts.free_space_change = trend_rec->
     qual[cnt].free_change, ts.num_chunks = trend_rec->qual[cnt].num_chunks,
     ts.num_chunks_change = trend_rec->qual[cnt].chunks_change, ts.cmt = trend_rec->qual[cnt].
     comment1
    WITH nocounter
   ;end insert
 ENDFOR
 FOR (cnt = 1 TO n)
   FOR (j = 1 TO trend_rec->qual[cnt].no_segments)
     IF ((trend_rec->qual[cnt].qual[j].segment_name != null))
      IF ((trend_rec->qual[cnt].qual[j].dropped="Y"))
       IF ((trend_rec->qual[cnt].qual[j].comment1=" "))
        SET trend_rec->qual[cnt].qual[j].comment1 = "4"
       ELSE
        SET trend_rec->qual[cnt].qual[j].comment1 = build(trend_rec->qual[cnt].qual[j].comment1,",4")
       ENDIF
      ENDIF
      IF ((trend_rec->qual[cnt].qual[j].created="Y"))
       IF ((trend_rec->qual[cnt].qual[j].comment1=" "))
        SET trend_rec->qual[cnt].qual[j].comment1 = "5"
       ELSE
        SET trend_rec->qual[cnt].qual[j].comment1 = build(trend_rec->qual[cnt].qual[j].comment1,",5")
       ENDIF
      ENDIF
      INSERT  FROM trend_segment s
       SET s.report_seq = rs, s.instance_cd = i_code, s.owner = trend_rec->qual[cnt].qual[j].owner,
        s.segment_name = trend_rec->qual[cnt].qual[j].segment_name, s.segment_type = trend_rec->qual[
        cnt].qual[j].segment_type, s.pctincrease = trend_rec->qual[cnt].qual[j].pctincrease,
        s.tablespace_name = trend_rec->qual[cnt].tablespace_name, s.num_rows = trend_rec->qual[cnt].
        qual[j].num_rows_added, s.rows_day_value = trend_rec->qual[cnt].qual[j].rows_day,
        s.total_space = trend_rec->qual[cnt].qual[j].total_space, s.total_change = trend_rec->qual[
        cnt].qual[j].total_change, s.free_space = trend_rec->qual[cnt].qual[j].free_space,
        s.used_space = trend_rec->qual[cnt].qual[j].used_space, s.bytes_day_value = trend_rec->qual[
        cnt].qual[j].bytes_day, s.extents_added = trend_rec->qual[cnt].qual[j].extents_added,
        s.next_extent = trend_rec->qual[cnt].qual[j].next_extent, s.extents = trend_rec->qual[cnt].
        qual[j].extents, s.next_extent_date = cnvtdatetime(trend_rec->qual[cnt].qual[j].
         next_extent_date),
        s.days_till_next = trend_rec->qual[cnt].qual[j].days_till_next, s.cmt = trend_rec->qual[cnt].
        qual[j].comment1
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(tsp_rec1->qual,0)
 SET stat = alterlist(tsp_rec2->qual,0)
 SET stat = alterlist(trend_rec->qual,0)
 SELECT INTO "nl:"
  s.*
  FROM trend_segment s
  WHERE s.report_seq=rs
  ORDER BY s.segment_name, s.owner
  HEAD REPORT
   num_seg1 = 0, num_seg2 = 0
  DETAIL
   f_old = findstring("4",s.cmt,1), f_new = findstring("5",s.cmt,1)
   IF (f_old != 0)
    num_seg1 = (num_seg1+ 1), row + 1, col 1,
    s.segment_name, col 30, f_old,
    stat = alterlist(seg_rec1->qual,num_seg1), seg_rec1->qual[num_seg1].tablespace_name = s
    .tablespace_name, seg_rec1->qual[num_seg1].owner = s.owner,
    seg_rec1->qual[num_seg1].segment_name = s.segment_name, seg_rec1->qual[num_seg1].num_rows = s
    .num_rows, seg_rec1->qual[num_seg1].total_space = s.total_change,
    seg_rec1->qual[num_seg1].free_space = s.free_space, seg_rec1->qual[num_seg1].used_space = s
    .used_space, seg_rec1->qual[num_seg1].extents = s.extents,
    seg_rec1->qual[num_seg1].next_extent = s.next_extent, seg_rec1->qual[num_seg1].comment = s.cmt
   ENDIF
   IF (f_new != 0)
    num_seg2 = (num_seg2+ 1), stat = alterlist(seg_rec2->qual,num_seg2), row + 1,
    col 1, s.segment_name, col 30,
    f_new, seg_rec2->qual[num_seg2].tablespace_name = s.tablespace_name, seg_rec2->qual[num_seg2].
    owner = s.owner,
    seg_rec2->qual[num_seg2].segment_name = s.segment_name, seg_rec2->qual[num_seg2].num_rows = s
    .num_rows, seg_rec2->qual[num_seg2].total_space = s.total_space,
    seg_rec2->qual[num_seg2].free_space = s.free_space, seg_rec2->qual[num_seg2].used_space = s
    .used_space, seg_rec2->qual[num_seg2].extents = s.extents,
    seg_rec2->qual[num_seg2].next_extent = s.next_extent, seg_rec2->qual[num_seg2].comment = s.cmt
   ENDIF
  WITH nocounter
 ;end select
 IF (num_seg1 != 0
  AND num_seg2 != 0)
  FOR (i = 1 TO num_seg2)
    FOR (j = 1 TO num_seg1)
      IF ((seg_rec2->qual[i].segment_name=seg_rec1->qual[j].segment_name)
       AND (seg_rec2->qual[i].owner=seg_rec1->qual[j].owner))
       SET seg_rec2->qual[i].total_change = (seg_rec2->qual[i].total_space+ seg_rec1->qual[i].
       total_space)
       SET seg_rec2->qual[i].used_space = (seg_rec2->qual[i].used_space+ seg_rec1->qual[i].used_space
       )
       SET seg_rec2->qual[i].num_rows = (seg_rec2->qual[i].num_rows+ seg_rec1->qual[i].num_rows)
       SET srows_day = (seg_rec2->qual[i].num_rows/ num_days)
       SET sbytes_day = ((seg_rec2->qual[i].used_space * block_size)/ num_days)
       SET days_till_next = ((seg_rec2->qual[j].free_space * block_size)/ sbytes_day)
       SET full_date = datetimeadd(e_date,days_till_next)
       SET seg_rec2->qual[i].rows_day = srows_day
       SET seg_rec2->qual[i].bytes_day = sbytes_day
       IF (sbytes_day=0)
        SET seg_rec2->qual[i].full_date = null
       ENDIF
       IF (sbytes_day > 0)
        SET seg_rec2->qual[i].full_date = full_date
       ENDIF
       IF (datetimecmp(fulldate,proj_date) <= 0
        AND sbytes_day > 0)
        SET seg_rec2->qual[i].comment = "1"
       ENDIF
       IF ((seg_rec2->qual[i].comment="5"))
        SET seg_rec2->qual[i].comment = "7"
        IF (datetimecmp(fulldate,proj_date) <= 0
         AND sbytes_day > 0)
         SET seg_rec2->qual[i].comment = "1,7"
        ENDIF
       ENDIF
       IF ((seg_rec2->qual[i].comment="2,5"))
        SET seg_rec2->qual[i].comment = "2,7"
        IF (datetimecmp(fulldate,proj_date) <= 0
         AND sbytes_day > 0)
         SET seg_rec2->qual[i].comment = "1,2,7"
        ENDIF
       ENDIF
       IF ((seg_rec2->qual[i].comment="3,5"))
        SET seg_rec2->qual[i].comment = "3,7"
        IF (datetimecmp(fulldate,proj_date) <= 0
         AND sbytes_day > 0)
         SET seg_rec2->qual[i].comment = "1,3,7"
        ENDIF
       ENDIF
       SET seg_rec2->qual[i].days_till_next = days_till_next
       SET seg_rec2->qual[i].flag = "Y"
       SET seg_rec1->qual[i].flag = "Y"
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF (num_seg2 != 0)
  FOR (i = 1 TO num_seg2)
    IF ((seg_rec2->qual[i].flag="Y"))
     CALL echo(" in update statement")
     UPDATE  FROM trend_segment s
      SET s.total_change = seg_rec2->qual[i].total_change, s.num_rows = seg_rec2->qual[i].num_rows, s
       .rows_day_value = seg_rec2->qual[i].rows_day,
       s.bytes_day_value = seg_rec2->qual[i].bytes_day, s.days_till_next = seg_rec2->qual[i].
       days_till_next, s.next_extent_date = cnvtdatetime(seg_rec2->qual[i].full_date),
       s.cmt = seg_rec2->qual[i].comment
      WHERE s.report_seq=rs
       AND (s.segment_name=seg_rec2->qual[i].segment_name)
       AND (s.owner=seg_rec2->qual[i].owner)
       AND (s.tablespace_name=seg_rec2->qual[i].tablespace_name)
      WITH nocounter
     ;end update
    ENDIF
  ENDFOR
 ENDIF
 IF (num_seg1 != 0)
  FOR (i = 1 TO num_seg1)
    IF ((seg_rec1->qual[i].flag="Y"))
     CALL echo("in delete statement")
     DELETE  FROM trend_segment s
      WHERE s.report_seq=rs
       AND (s.segment_name=seg_rec1->qual[i].segment_name)
       AND (s.owner=seg_rec1->qual[i].owner)
       AND (s.tablespace_name=seg_rec1->qual[i].tablespace_name)
     ;end delete
    ENDIF
  ENDFOR
 ENDIF
#print_report
 IF (seg_type="T")
  SET seg_type = "TABLE"
 ENDIF
 IF (seg_type="I")
  SET seg_type = "INDEX"
 ENDIF
 SET u_notes1 = fillstring(200," ")
 SET u_notes2 = fillstring(200," ")
 SET r1_date = cnvtdatetime(curdate,curtime3)
 SET r2_date = cnvtdatetime(curdate,curtime3)
 SET inst_name1 = fillstring(30," ")
 SET inst_name2 = fillstring(30," ")
 SET fname = build("trend_",rs)
 SELECT INTO "nl:"
  FROM ref_report_log l,
   ref_report_parms_log p
  WHERE l.report_seq=p.report_seq
   AND l.report_seq=rs
   AND l.report_cd=2
   AND p.parm_cd IN (8, 9)
  DETAIL
   IF (p.parm_cd=8)
    st_seq = cnvtint(p.parm_value)
   ENDIF
   IF (p.parm_cd=9)
    e_seq = cnvtint(p.parm_value)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_report_log l,
   ref_report_parms_log p,
   ref_instance_id i
  WHERE l.report_seq=p.report_seq
   AND l.report_seq IN (st_seq, e_seq)
   AND p.parm_cd=1
   AND l.report_cd=1
   AND p.parm_value=cnvtstring(i.instance_cd)
  DETAIL
   IF (l.report_seq=st_seq)
    r1_date = l.begin_date, u_notes1 = l.user_notes, inst_name1 = i.instance_name
   ENDIF
   IF (l.report_seq=e_seq)
    r2_date = l.begin_date, u_notes2 = l.user_notes, inst_name2 = i.instance_name
   ENDIF
  WITH nocounter
 ;end select
 SET num_days = datetimecmp(r2_date,r1_date)
 SET proj_date = datetimeadd(r2_date,proj_days)
 SET eproj_sizemb = eproj_size
 IF (eproj_size > 0)
  SET eproj_size = (((eproj_size * 1024) * 1024)/ block_size)
 ENDIF
 IF (no_exts=0)
  SET no_exts = null
 ENDIF
 IF (erows_day=0)
  SET erows_day = null
 ENDIF
 IF (eproj_size=0)
  SET eproj_size = null
 ENDIF
 SET where_clause = fillstring(500," ")
 SET where_clause = "s.report_seq = ts.report_seq and ts.tablespace_name = s.tablespace_name "
 SET where_clause = build(where_clause,
  " and s.segment_name = patstring(seg_name) and s.segment_type = patstring(seg_type) ")
 IF (g_seg="Y")
  SET where_clause = build(where_clause," and s.bytes_day_value != 0")
 ENDIF
 IF (ext_proj_date="Y")
  SET where_clause = build(where_clause," and s.next_extent_date <= cnvtdatetime(proj_date) ")
 ENDIF
 SELECT INTO trim(fname)
  ts.*, s.*
  FROM trend_tablespace ts,
   trend_segment s
  PLAN (ts
   WHERE ts.report_seq=rs
    AND ts.tablespace_name=patstring(tsp_name))
   JOIN (s
   WHERE parser(where_clause))
  ORDER BY ts.tablespace_name, s.segment_name
  HEAD REPORT
   row + 1, row + 1, col 0,
   "Trend Report Generated : Date Time - ", curdate"dd-mmm-yyyy;;d", " - ",
   curtime"hh:mm;;m", row + 2, col 24,
   "Requested By - ", curuser, row + 2,
   col 24, "Report_seq : ", rs,
   row + 2, col 0, "Arguments : ",
   row + 2, col 24, "All or Custom      : ",
   opt, f = findstring("*",tsp_name)
   IF (findstring("*",tsp_name) > 1)
    tsp_name = concat(tsp_name,"*")
   ENDIF
   IF (findstring("*",tsp_name)=1)
    tsp_name = "*"
   ENDIF
   row + 2, col 24, "Tablespace         : ",
   tsp_name, row + 2, col 24,
   "Segment Type       : ", seg_type, f = findstring("*",seg_name)
   IF (findstring("*",seg_name) > 1)
    seg_name = concat(seg_name,"*")
   ENDIF
   IF (findstring("*",seg_name)=1)
    seg_name = "*"
   ENDIF
   row + 2, col 24, "Segment Name       : ",
   seg_name, row + 2, col 24,
   "Projected Days     : ", proj_days";l", col + 2,
   "Projected Date : ", proj_date"dd-mmm-yyyy;;d", row + 2,
   col 24, "Projection Factor   : ", proj->proj_factor"###.##",
   row + 2, col 24, "Block Size         : ",
   block_size";l", row + 2, col 24,
   "Exceptions  :", exep, row + 2,
   col 30, "Only Growing Segments                ", g_seg,
   row + 2, col 30, "Extend By Projected Date             ",
   ext_proj_date, row + 2, col 30,
   "No. Of Extents                    >= ", no_exts";l", row + 2,
   col 30, "Rows/Day                          >= ", erows_day";l",
   seproj_size = fillstring(15," "), seproj_size = cnvtstring(eproj_size), row + 2,
   col 30, "Projected Allocated Size (MB) >=     ", eproj_sizemb";l",
   col + 1, "( ", col + 0,
   CALL print(trim(seproj_size)), col + 0, " ) Blocks",
   row + 3, col 0, "Start Point : ",
   row + 2, col 24, "Report Seq : ",
   st_seq";l", row + 2, col 24,
   "Date          :", r1_date"dd-mmm-yyyy;;d", row + 2,
   col 24, "Instance Name :", inst_name1,
   u1 = substring(1,100,u_notes1), u2 = substring(100,200,u_notes1), row + 2,
   col 24, "User Notes    :", u1,
   row + 2, col 38, u2,
   row + 2, col 0, "End  Point   : ",
   row + 2, col 24, "Report Seq  : ",
   e_seq, row + 2, col 24,
   "Date          :", r2_date"dd-mmm-yyyy;;d", row + 2,
   col 24, "Instance Name :", inst_name2,
   u1 = substring(1,100,u_notes2), u2 = substring(100,200,u_notes2), row + 2,
   col 24, "User Notes    :", u1,
   row + 2, col 38, u2,
   row + 2, col 24, "Note: Projection factor effects only ",
   col + 0, "'Projected Used Blocks' and 'Projected Alloc. Blocks' columns", under = fillstring(173,
    "="),
   BREAK, no_page = 1
  HEAD PAGE
   IF (curpage > 1
    AND row < 3
    AND no_page=2)
    col 165, "page no:", curpage"#####;l",
    row + 1, col 0, "Space Trend Report as of :",
    curdate"dd-mmm-yyyy;;d", row + 1, col 0,
    "1. Extends by projected date", col 35, "2.Missing data from start point",
    col 75, "3.Missing data from end point", col 110,
    "4. Segment was dropped", row + 1, col 0,
    "5. New Segment", col 35, "6.TS Too small for projection",
    col 75, "7.Migrated Segment", row + 2
   ENDIF
  HEAD ts.tablespace_name
   sum_rows = 0, sum_rows_day = 0.0, sum_tot_bytes = 0,
   sum_bytes_day = 0.0, sum_extents = 0, sum_extents_added = 0,
   sum_proj_size = 0, sum_alloc_size = 0, no_seg_head = 0,
   no_rows = 0
  HEAD s.segment_name
   bbytes_day = (s.used_space/ num_days), proj_used_size = 0
   IF (bbytes_day >= 0)
    used_space = (s.total_space - s.free_space), proj_used_size = (used_space+ ((proj_days *
    bbytes_day) * proj->proj_factor))
   ENDIF
   tspace1 = s.total_space, ne = s.next_extent, nedt = s.next_extent_date,
   adays = 0.0
   WHILE (nedt <= proj_date
    AND bbytes_day > 0)
     tspace2 = (tspace1+ ne), ne = (ne+ (ne * (s.pctincrease/ 100))), fspace = (tspace2 - tspace1),
     adays = (fspace/ (bbytes_day * proj->proj_factor))
     IF (adays < 1)
      adays = 1
     ENDIF
     nedt = datetimeadd(nedt,adays), tspace1 = tspace2
   ENDWHILE
   proj_alloc_size = tspace1
   IF (proj_alloc_size >= eproj_size)
    IF (no_page=1)
     col 165, "page no:", curpage"####;l",
     row + 1, col 0, "Space Trend Report as of :",
     curdate"dd-mmm-yyyy;;d", row + 1, col 0,
     "1. Extends by projected date", col 35, "2.Missing data from start point",
     col 75, "3.Missing data from end point", col 110,
     "4. Segment was dropped", row + 1, col 0,
     "5. New Segment", col 35, "6.TS Too small for projection",
     col 75, "7.Migrated Segment", row + 2,
     no_page = 2
    ENDIF
    IF (no_seg_head=0)
     IF (row > 59)
      BREAK
     ENDIF
     col 0, "Tablespace  :", ts.tablespace_name,
     row + 1, col 0, "Segment ",
     col 31, "Type ", col 36,
     "Row", col 50, "Rows /",
     col 65, "Byte", col 80,
     "Bytes/", col 95, "Total ",
     col 108, "Extents ", col 121,
     "Next", col 135, "Projected ",
     col 150, "Projected", row + 1,
     col 36, "Change", col 50,
     "Day", col 65, "Change",
     col 80, "Day", col 95,
     "Extents", col 108, "Change",
     col 121, "Extent Date", col 135,
     "Used Blocks", col 150, "Alloc. Blocks",
     col 167, "Comment", row + 2,
     no_seg_head = 1
    ENDIF
    col 0, s.segment_name, type = s.segment_type
    IF (type="TABLE")
     type = "TB"
    ELSE
     type = "IX"
    ENDIF
    col 31, type, col 36,
    s.num_rows";l"
    IF (s.rows_day_value=0)
     col 50, "0"
    ELSE
     col 50, s.rows_day_value"#########.##;l"
    ENDIF
    tot_bytes = (s.used_space * block_size), col 65, tot_bytes";l"
    IF (s.bytes_day_value=0)
     col 80, "0"
    ELSE
     col 80, s.bytes_day_value"########.##;l"
    ENDIF
    col 95, s.extents";l", col 108,
    s.extents_added";l"
    IF (s.next_extent_date=null)
     col 121, "n/a"
    ELSE
     col 121, s.next_extent_date"dd-mmm-yyyy;;d"
    ENDIF
    col 135, proj_used_size";l", col 150,
    proj_alloc_size";l", col 167, s.cmt,
    row + 1, no_rows = (no_rows+ 1)
   ENDIF
   sum_rows = (sum_rows+ s.num_rows), sum_rows_day = (sum_rows_day+ s.rows_day_value), sum_tot_bytes
    = (sum_tot_bytes+ tot_bytes),
   sum_bytes_day = (sum_bytes_day+ s.bytes_day_value), sum_extents = (sum_extents+ s.extents),
   sum_extents_added = (sum_extents_added+ s.extents_added),
   sum_proj_size = (sum_proj_size+ proj_used_size), sum_alloc_size = (sum_alloc_size+ proj_alloc_size
   )
  FOOT  ts.tablespace_name
   IF (no_rows > 0)
    row + 1, col 3, "Segment Totals : ",
    col 36, sum_rows";l", col 50,
    sum_rows_day"############.##;l", col 65, sum_tot_bytes";l",
    col 80, sum_bytes_day"############.##;l", col 95,
    sum_extents";l", col 108, sum_extents_added";l",
    col 135, sum_proj_size";l", col 150,
    sum_alloc_size";l", row + 2
    IF (row > 61)
     BREAK
    ENDIF
    col 30, "Alloc. Block", col 50,
    "Total", col 85, "Free",
    col 120, "Free", row + 1,
    col 0, "Tablespace ", col 30,
    "Change ", col 50, "Space",
    col 65, "Change ", col 85,
    "Space", col 100, "Change",
    col 120, "Chunks", col 140,
    "Change", col 160, "Comments ",
    row + 2, col 0, ts.tablespace_name,
    col 30, ts.added_allocated_space"############;l", col 50,
    ts.total_space"##############;l", col 65, ts.total_space_growth"############;l",
    col 85, ts.free_space"################;l", col 100,
    ts.free_space_change"############;l", col 120, ts.num_chunks"########;l",
    col 140, ts.num_chunks_change"######;l", cmt = " "
    IF (sum_alloc_size > ts.total_space)
     cmt = "6"
    ENDIF
    col 160, cmt, row + 1,
    col 0, under, row + 2
   ENDIF
  WITH nocounter, maxcol = 250, format = variable,
   maxrow = 64
 ;end select
 CALL clear(23,1)
 CALL text(23,1,"Your report is available in ")
 CALL text(23,31,concat(trim(fname),".dat"))
 CALL accept(23,70,"p;c"," ")
 COMMIT
#terminate
 COMMIT
END GO

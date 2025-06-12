CREATE PROGRAM dm_table_list:dba
 PAINT
 SET width = 80
 FREE RECORD in_rec
 RECORD in_rec(
   1 qual[1]
     2 table_name = c30
     2 process_flg = i4
 )
 SET numrecs = 0
 SET dtl_env_id = 0.0
 IF (validate(dem_env_id,0) > 0)
  SET dtl_env_id = dem_env_id
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="DM_ENV_ID"
   DETAIL
    dtl_env_id = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dtl_env_id = 0
   CALL clear(1,1)
   CALL text(2,2,"Unable to find Environment ID from DM_INFO table!")
   CALL text(4,2,"This program will not be able to display the")
   CALL text(5,2,"output filenames from FIX_SCHEMA Generation")
   CALL text(6,2,"since the environment id was not found.")
   CALL text(7,2,"The contents of DM_TABLE_LIST table will be displayed")
   CALL text(8,2,"without the filenames.")
   CALL text(10,2,"Try running option #28 'DM Table List Query' from")
   CALL text(11,2,"DM_ENV_MAINT program to view the output filenames")
   CALL text(12,2,"from FIX_SCHEMA Generation.")
   CALL text(14,2,"Continue ? (Y/N)")
   CALL accept(14,20,"A;CU","Y")
   IF (curaccept != "Y")
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 SET width = 132
 CALL clear(1,1)
 CALL video(r)
 CALL text(1,1,"*** BUILD DM_TABLE_LIST PROGRAM ***",w)
 CALL video(n)
 EXECUTE FROM row_count TO row_count_exit
#display
 CALL text(8,1,"Display contents of DM_TABLE_LIST (Y/N): N")
 SET validate = 0
 CALL accept(8,42,"A;cu","N")
 IF (curaccept != "N"
  AND curaccept != "Y")
  GO TO display
 ELSE
  IF (curaccept="Y")
   IF (dtl_env_id=0)
    SELECT
     d.*
     FROM dm_table_list d
     ORDER BY d.table_name
     WITH nocounter
    ;end select
   ELSE
    EXECUTE FROM display_table_list TO display_table_list_exit
   ENDIF
  ENDIF
 ENDIF
 CALL video(r)
 CALL text(1,1,"*** BUILD DM_TABLE_LIST PROGRAM ***",w)
 CALL video(n)
 EXECUTE FROM row_count TO row_count_exit
 CALL text(8,1,concat("Display contents of DM_TABLE_LIST (Y/N): ",curaccept))
#del_rows
 CALL text(10,1,"Delete DM_TABLE_LIST rows (Y/N): N")
 SET validate = 0
 CALL accept(10,34,"A;CU","N")
 IF (curaccept != "N"
  AND curaccept != "Y")
  GO TO del_rows
 ELSE
  IF (curaccept="Y")
   DELETE  FROM dm_table_list
    WHERE 1=1
    WITH nocounter
   ;end delete
   COMMIT
   CALL text(11,1,"*** All rows deleted ***")
  ENDIF
 ENDIF
 CALL text(12,1,"Enter table name to insert in DM_TABLE_LIST.")
 CALL text(13,1,"Hit enter (blank) to quit.")
 CALL text(14,1,"Table:")
#inrec
 CALL text(15,1,"                                                            ")
 SET validate = 1
 SET validate =
 SELECT INTO "nl:"
  d.table_name
  FROM dm_tables_doc d
  WHERE d.table_name=trim(curaccept)
  WITH nocounter
 ;end select
 CALL accept(14,8,"p(30);cu"," ")
 IF (curaccept > " ")
  SET validate = off
  SET numrecs = (numrecs+ 1)
  IF (numrecs > 1)
   SET stat = alter(in_rec->qual,numrecs)
  ENDIF
  SET in_rec->qual[numrecs].table_name = curaccept
  CALL text(15,1,"Process Flag:")
  CALL accept(15,15,"9;",0
   WHERE curaccept BETWEEN 0 AND 3)
  SET in_rec->qual[numrecs].process_flg = cnvtint(curaccept)
  CALL text((2+ numrecs),45,cnvtstring(numrecs))
  CALL text((2+ numrecs),47,trim(in_rec->qual[numrecs].table_name))
  GO TO inrec
 ENDIF
 SET help = off
 SET message = nowindow
 FOR (x = 1 TO numrecs)
  INSERT  FROM dm_table_list d
   SET d.table_name = in_rec->qual[x].table_name, d.process_flg = in_rec->qual[x].process_flg, d
    .updt_applctx = 0,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0, d.updt_id = 0,
    d.updt_task = 0
   WHERE 1=1
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
 IF (dtl_env_id=0)
  SELECT
   d.*
   FROM dm_table_list d
   ORDER BY d.table_name
   WITH nocounter
  ;end select
 ELSE
  EXECUTE FROM display_table_list TO display_table_list_exit
 ENDIF
 GO TO end_program
#display_table_list
 RECORD space_summary(
   1 rdate = dq8
   1 rseq = i4
 ) WITH persist
 SELECT INTO "nl:"
  rseq = max(a.report_seq), y = max(a.begin_date)
  FROM ref_report_log a,
   ref_report_parms_log b,
   ref_instance_id c
  WHERE a.report_seq=b.report_seq
   AND b.parm_cd=1
   AND a.report_cd=1
   AND a.end_date IS NOT null
   AND b.parm_value=cnvtstring(c.instance_cd)
   AND c.environment_id=dtl_env_id
  DETAIL
   space_summary->rdate = y, space_summary->rseq = rseq
  WITH nocounter
 ;end select
 SELECT
  *
  FROM space_objects so,
   dm_table_list dtl,
   dm_tables_doc dtd
  WHERE so.segment_name=outerjoin(dtl.table_name)
   AND so.report_seq=outerjoin(space_summary->rseq)
   AND dtd.table_name=dtl.table_name
  ORDER BY dtl.table_name
  HEAD REPORT
   col 0, "TABLE_NAME", col 35,
   "PROCESS_FLG", col 50, "UPDT_DT_TM",
   col 65, "FILE NAME", row + 1
  DETAIL
   col 0, dtl.table_name, col 39,
   dtl.process_flg"#", col 50, dtl.updt_dt_tm"MM/DD/YYYY;;D"
   IF (((dtl.process_flg=1) OR (dtl.process_flg=3)) )
    IF (so.row_count > 100000)
     dms = substring(1,13,cnvtlower(cnvtalphanum(dtd.data_model_section)))
    ELSE
     dms = "routine"
    ENDIF
    output2_filename = cnvtlower(build("fix_schema_",dms,"_2.dat")), output2sql_filename = cnvtlower(
     build("fix_schema_",dms,"_2.sql")), output2com_filename = cnvtlower(build("fix_schema_",dms,
      "_2.com")),
    output2d_filename = cnvtlower(build("fix_schema_",dms,"_2d.dat")), output3_filename = cnvtlower(
     build("fix_schema_",dms,"_3.dat")), output3sql_filename = cnvtlower(build("fix_schema_",dms,
      "_3.lst")),
    output3d_filename = cnvtlower(build("fix_schema_",dms,"_3d.dat")), output4_filename = cnvtlower(
     build("fix_schema_",dms,"_4.dat")), output4d_filename = cnvtlower(build("fix_schema_",dms,
      "_4d.dat")),
    col 65, output2_filename
    IF (dtl.process_flg=3)
     ", ", output2d_filename
    ENDIF
   ENDIF
   row + 1
  WITH nocounter, formfeed = none
 ;end select
#display_table_list_exit
#row_count
 SET count1 = 0
 SET count_p1 = 0
 SET count_p2 = 0
 SET count_p3 = 0
 SET linestr = fillstring(60," ")
 SELECT INTO "nl:"
  FROM dm_table_list d
  DETAIL
   count1 = (count1+ 1)
   IF (d.process_flg=1)
    count_p1 = (count_p1+ 1)
   ELSEIF (d.process_flg=2)
    count_p2 = (count_p2+ 1)
   ELSEIF (d.process_flg=3)
    count_p3 = (count_p3+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET linestr = build(count1," rows(s) exist in DM_TABLE_LIST.")
 CALL text(3,2,linestr)
 IF (count_p1 > 0)
  SET linestr = build(count_p1," row(s) have process_flg = 1")
  CALL text(4,10,linestr)
 ENDIF
 IF (count_p2 > 0)
  SET linestr = build(count_p2," row(s) have process_flg = 2")
  CALL text(5,10,linestr)
 ENDIF
 IF (count_p3 > 0)
  SET linestr = build(count_p3," row(s) have process_flg = 3")
  CALL text(6,10,linestr)
 ENDIF
#row_count_exit
#end_program
END GO

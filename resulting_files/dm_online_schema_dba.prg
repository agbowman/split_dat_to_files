CREATE PROGRAM dm_online_schema:dba
 PAINT
 SET width = 132
 SET message = nowindow
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 IF (dos_batch)
  GO TO batch_process
 ENDIF
#main_process
 EXECUTE FROM 2000_main TO 2999_main_exit
 GO TO main_process
#batch_process
 EXECUTE FROM 2000_main_batch TO 2999_main_batch_exit
 GO TO 9999_exit_program
#1000_initialize
 SET cadd_not_null = "ADD NOT NULL CONSTRAINT"
 SET ccreate_index = "CREATE INDEX"
 SET ccreate_table = "CREATE TABLE"
 SET ccreate_unique_index = "CREATE UNIQUE INDEX"
 SET cadd_primary_key = "ADD PRIMARY KEY CONSTRAINT"
 SET creturn = 0
 SET cdown_arrow = 1
 SET cup_arrow = 2
 SET cpage_down = 6
 SET cpage_up = 5
 SET dos_err_num = 0
 SET dos_err_msg = fillstring(132," ")
 FREE RECORD work
 RECORD work(
   1 table_name = vc
   1 parameter = vc
   1 text = vc
   1 text2 = vc
   1 buffer[*]
     2 text = vc
   1 ocd = i4
   1 schema_date = dq8
   1 run_id = f8
   1 segment_name = vc
   1 segment_type = vc
   1 reorg_data_tspace = vc
   1 reorg_index_tspace = vc
   1 userlastupdt = dq8
   1 prompt_answer = vc
   1 ora_version = i4
   1 ora_param_ind = i2
   1 lock_mgr_ind = i2
   1 alter_param_ind = i2
   1 job_que_process = i4
   1 job_que_interval = i4
   1 job_que_keep_con = vc
 )
 SET cjob_que_process = 5
 SET cjob_que_interval = 10
 SET cjob_que_keep_con = "FALSE"
 FREE RECORD docd_reply
 RECORD docd_reply(
   1 status = c1
   1 err_msg = vc
 )
 FREE RECORD list
 RECORD list(
   1 list[*]
     2 text = vc
 )
 SET list_item = 0
 SET list_page = 0
 SET list_line = 0
 SET list_items = 0
 SET list_top = 0
 SET list_left = 0
 SET list_bottom = 0
 SET list_right = 0
 SET list_width = 0
 SET list_more = 0
 FREE RECORD list2
 RECORD list2(
   1 list[*]
     2 text = vc
 )
 SET list2_item = 0
 SET list2_page = 0
 SET list2_line = 0
 SET list2_items = 0
 SET list2_top = 0
 SET list2_left = 0
 SET list2_bottom = 0
 SET list2_right = 0
 SET list2_width = 0
 SET list2_more = 0
 SET done = 0
 SET stat = 0
 SET i = 0
 SET j = 0
 SET k = 0
 EXECUTE dm_set_env_id
 SET environment_id = 0.0
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
   AND i.info_number > 0.0
  DETAIL
   environment_id = i.info_number
  WITH nocounter
 ;end select
 IF ( NOT (environment_id))
  CALL kick("Unable to find an environment ID for this environment on the DM_INFO table.")
 ENDIF
 CALL draw_main_banner(environment_id)
 SET work->ora_param_ind = 0
 SET work->lock_mgr_ind = 0
 SET work->alter_param_ind = 0
 SET work->ora_version = 7
 SELECT INTO "nl:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   IF (cnvtupper(substring(1,7,p.product))="ORACLE7")
    work->ora_version = 7
   ELSE
    work->ora_version = 8
   ENDIF
  WITH nocounter
 ;end select
 CALL dos_check_ora_param(0)
 SET block = 0.0
 CALL parameter("DB_BLOCK_SIZE")
 SET block = cnvtreal(work->parameter)
 IF (block=0.0)
  CALL kick("No database block size found.")
 ENDIF
 SET min_extent_size = (block * 2)
 SET analyze = 0
 SELECT INTO "nl:"
  p.anal_percent
  FROM reorg_parms p
  WHERE p.insert_dt IN (
  (SELECT
   max(x.insert_dt)
   FROM reorg_parms x))
   AND p.anal_percent > 0
  DETAIL
   analyze = 1
  WITH nocounter
 ;end select
 SET summary_seq = 0
 SET prior_summary_seq = 0
 SET summary_days = 0
 SET temp_date = cnvtdatetime("31-DEC-2100")
 SELECT INTO "nl:"
  l.begin_date
  FROM ref_report_log l,
   ref_report_parms_log p,
   ref_instance_id i
  PLAN (l
   WHERE l.report_cd=1
    AND l.begin_date < cnvtdatetime("31-DEC-2199")
    AND l.end_date >= l.begin_date)
   JOIN (p
   WHERE p.report_seq=l.report_seq
    AND p.parm_cd=1)
   JOIN (i
   WHERE i.instance_cd=cnvtint(p.parm_value)
    AND i.environment_id=environment_id)
  ORDER BY l.begin_date DESC
  DETAIL
   IF ( NOT (summary_seq))
    IF (l.begin_date > cnvtdatetime((curdate - 30),curtime3))
     summary_seq = l.report_seq, temp_date = l.begin_date
    ENDIF
   ELSE
    IF ( NOT (prior_summary_seq))
     prior_summary_seq = l.report_seq, summary_days = datetimediff(temp_date,l.begin_date)
     IF ( NOT (summary_days))
      summary_days = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ( NOT (prior_summary_seq))
  CALL kick(
   "At least two space summary reports must exist in this environment, one created within the last 30 days."
   )
 ENDIF
 SET session_id = 0.0
 SET session_id = dos_get_session_id(0)
 SET prev_session_id = 0.0
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="REORG SESSION"
  DETAIL
   prev_session_id = i.info_number
  WITH nocounter
 ;end select
 IF (prev_session_id)
  IF (prev_session_id != session_id)
   CALL clear(4,1)
   CALL text(5,2,"This program is currently being run by someone else, or someone else started this")
   CALL text(6,2,"program and aborted.  It is strongly recommended that only one instance of this")
   CALL text(7,2,"program be running.")
   CALL text(9,2,"Do you want to continue (Y/N)? N")
   CALL accept(9,33,"P;CUS","N"
    WHERE curaccept IN ("N", "n", "Y", "y"))
   IF (cnvtupper(trim(curaccept,3)) != "Y")
    SET checking_session = 1
    GO TO 9999_exit_program
   ENDIF
   CALL clear(4,1)
  ENDIF
 ENDIF
 CALL clear_session(0)
 INSERT  FROM dm_info i
  SET i.info_domain = "DATA MANAGEMENT", i.info_name = "REORG SESSION", i.info_number = session_id,
   i.info_long_id = 0.0, i.updt_applctx = 0, i.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   i.updt_cnt = 0, i.updt_id = 0.0, i.updt_task = 0
  WITH nocounter
 ;end insert
 COMMIT
 SET reorg_tool_ind = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="ATG"
   AND d.info_name="724Reorg"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reorg_tool_ind = 1
 ENDIF
 SET dos_batch = 0
 SET dos_batch_target = fillstring(11," ")
 SET dos_batch_tspace = 0
 IF (validate(dm_online_schema_batch,- (1)) > 0)
  SET dos_batch = 1
 ENDIF
 FREE RECORD orig_segments
 RECORD orig_segments(
   1 segment_count = i4
   1 segment[*]
     2 segment_name = vc
     2 object_type = vc
     2 tablespace_name = vc
     2 new_ind = i2
     2 new_segment_name = vc
     2 new_tablespace_name = vc
     2 initial_extent = f8
     2 next_extent = f8
     2 max_extents = i4
     2 min_extents = i4
     2 pct_increase = i4
     2 pct_free = i4
     2 pct_used = i4
     2 freelists = i4
     2 freelist_groups = i4
     2 parallel_degree = c10
     2 instances = c10
     2 cash = c5
     2 ini_trans = i4
     2 max_trans = i4
     2 need_check = i2
     2 next_extent_cnt = i4
     2 total_space = f8
     2 used_space = f8
     2 day_space = f8
     2 valid = i2
     2 message1 = vc
     2 message2 = vc
 )
 SET orig_segments->segment_count = 0
 FREE RECORD map_tspace
 RECORD map_tspace(
   1 tspace[*]
     2 tablespace_name = vc
     2 user_map_ind = i2
     2 user_map_tspace = vc
   1 tspace_cnt = i4
 )
 SET map_tspace->tspace_cnt = 0
 SET reorg_tspace_ind = 0
 SET reorg_back_ind = 0
 SET reorg_tspace_setup = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name IN ("REORG DATA TABLESPACE", "REORG INDEX TABLESPACE")
  DETAIL
   IF (d.info_name="REORG DATA TABLESPACE")
    work->reorg_data_tspace = trim(substring(1,30,d.info_char),3)
   ELSE
    work->reorg_index_tspace = trim(substring(1,30,d.info_char),3)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND (work->reorg_data_tspace > " ")
  AND (work->reorg_index_tspace > " "))
  SET reorg_tspace_setup = 1
 ENDIF
 CALL clear(4,1)
 IF (reorg_tspace_setup)
  CALL text(5,2,
   "Current settings indicate that temporary tablespaces for the reorg process have been setup.")
 ELSE
  CALL text(5,2,"Setup for temporary tablespaces for the reorg process not found.")
 ENDIF
 CALL text(7,2,
  "Setting up temporary tablespaces (DATA and INDEX) for the reorg process allows the selected")
 CALL text(8,2,
  "table (and its indexes) to be moved back to the original tablespace once the schema changes")
 CALL text(9,2,
  "are complete.  This allows the use of Online Schema tool without adding significant amount")
 CALL text(10,2,
  "of space to various existing tablespaces.  Instead, the temoprary reorg tablespaces are used")
 CALL text(11,2,
  "during the Online Schema process; additional space may be required for these temporary")
 CALL text(12,2,"reorg tablespaces only.")
 IF (dos_batch)
  CALL text(14,2,
   "If temporary reorg tablespaces are setup, each table in this batch session will be moved")
  CALL text(15,2,"to these temporary reorg tablespaces and then moved back to original tablespace.")
 ELSE
  CALL text(14,2,
   "If you choose to setup temporary reorg tablespaces, you can still choose not to use these")
  CALL text(15,2,"tablespaces when selecting a table for the Online Schema process later.")
 ENDIF
 IF (reorg_tspace_setup)
  CALL text(17,2,"The following settings were found:")
  SET work->text = concat(" Temporary DATA tablespace = ",trim(work->reorg_data_tspace))
  CALL text(18,7,work->text)
  SET work->text = concat("Temporary INDEX tablespace = ",trim(work->reorg_index_tspace))
  CALL text(19,7,work->text)
  CALL clear(24,1)
  CALL text(24,2,"Continue with these settings ? (Y/N)")
  CALL accept(24,39,"P;CU","Y")
  IF (curaccept != "Y")
   GO TO 1010_reorg_tspace_setup
  ELSE
   GO TO 1019_reorg_tspace_setup_exit
  ENDIF
 ELSE
  CALL text(17,2,"Temporary tablespaces for the reorg process have not been setup for this domain.")
  SET work->text = "N"
  CALL clear(24,1)
  CALL text(24,2,"Do you wish to setup temporary reorg tablespaces ? (Y/N)")
  CALL accept(24,59,"P;CU","Y")
  IF (curaccept != "Y")
   SET reorg_tspace_setup = 0
   GO TO 1019_reorg_tspace_setup_exit
  ELSE
   GO TO 1010_reorg_tspace_setup
  ENDIF
 ENDIF
#1010_reorg_tspace_setup
 SET save_reorg_tspace_setup = reorg_tspace_setup
 SET temp_reorg_tspace_setup = 0
 IF (save_reorg_tspace_setup=0)
  SET temp_reorg_tspace_setup = 1
  GO TO accept_data_tspace
 ENDIF
#accept_reorg_tspace
 CALL clear(16,1)
 CALL text(17,2,"Clear existing setup for temporary reorg tablespaces ? (Y/N)")
 CALL accept(17,63,"P;CU","N")
 IF (curaccept != "Y")
  SET temp_reorg_tspace_setup = 1
 ELSE
  SET temp_reorg_tspace_setup = 0
  CALL text(19,2,"You have selected not to setup temporary reorg tablespaces.")
  GO TO accept_confirm_reorg_tspace
 ENDIF
#accept_data_tspace
 CALL text(19,2,"Please enter temporary reorg DATA tablespace: ")
 SET help =
 SELECT
  u.tablespace_name
  FROM user_tablespaces u
  WHERE substring(1,2,u.tablespace_name)="D_"
   AND u.status="ONLINE"
  ORDER BY u.tablespace_name
  WITH nocounter
 ;end select
 CALL status("Use <SHIFT> <F5> for help")
 IF (reorg_tspace_setup)
  CALL accept(19,48,"P(30);CU",work->reorg_data_tspace)
 ELSE
  CALL accept(19,48,"P(30);CU")
 ENDIF
 SET help = off
 SET work->text = cnvtupper(trim(curaccept,3))
 SELECT INTO "nl:"
  FROM user_tablespaces u
  WHERE (u.tablespace_name=work->text)
   AND substring(1,2,u.tablespace_name)="D_"
   AND u.status="ONLINE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO accept_data_tspace
 ENDIF
 SET work->reorg_data_tspace = work->text
#accept_index_tspace
 CALL text(20,2,"Please enter temporary reorg INDEX tablespace: ")
 SET help =
 SELECT
  u.tablespace_name
  FROM user_tablespaces u
  WHERE substring(1,2,u.tablespace_name)="I_"
   AND u.status="ONLINE"
  ORDER BY u.tablespace_name
  WITH nocounter
 ;end select
 CALL status("Use <SHIFT> <F5> for help")
 IF (reorg_tspace_setup)
  CALL accept(20,48,"P(30);CU",work->reorg_index_tspace)
 ELSE
  CALL accept(20,48,"P(30);CU")
 ENDIF
 SET help = off
 SET work->text = cnvtupper(trim(curaccept,3))
 SELECT INTO "nl:"
  FROM user_tablespaces u
  WHERE (u.tablespace_name=work->text)
   AND substring(1,2,u.tablespace_name)="I_"
   AND u.status="ONLINE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO accept_index_tspace
 ENDIF
 SET work->reorg_index_tspace = work->text
#accept_confirm_reorg_tspace
 CALL text(24,2,"Continue with these settings ? (Y/N)")
 CALL accept(24,39,"P;CU","Y")
 IF (curaccept != "Y")
  GO TO accept_reorg_tspace
 ELSE
  SET reorg_tspace_setup = temp_reorg_tspace_setup
  IF (reorg_tspace_setup)
   DELETE  FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name IN ("REORG DATA TABLESPACE", "REORG INDEX TABLESPACE")
    WITH nocounter
   ;end delete
   INSERT  FROM dm_info d
    SET d.info_domain = "DATA MANAGEMENT", d.info_name = "REORG DATA TABLESPACE", d.info_char = work
     ->reorg_data_tspace,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   INSERT  FROM dm_info d
    SET d.info_domain = "DATA MANAGEMENT", d.info_name = "REORG INDEX TABLESPACE", d.info_char = work
     ->reorg_index_tspace,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
  ELSE
   DELETE  FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name IN ("REORG DATA TABLESPACE", "REORG INDEX TABLESPACE")
    WITH nocounter
   ;end delete
   SET work->reorg_data_tspace = ""
   SET work->reorg_index_tspace = ""
  ENDIF
  COMMIT
 ENDIF
#1019_reorg_tspace_setup_exit
#1020_target_schema
 CALL clear(4,1)
 CALL text(5,2,"Please select the OCD number or schema date: ")
 SET help =
 SELECT INTO "nl:"
  d.run_id";l", d.ocd";l", d.schema_date"DD-MMM-YYYY;;D"
  FROM dm_schema_log d
  WHERE d.run_id > 0.0
   AND ((d.schema_date != cnvtdatetime("01-JAN-1900")) OR (d.schema_date = null))
  ORDER BY d.ocd DESC, d.schema_date DESC
  WITH nocounter
 ;end select
 CALL accept(5,50,"P(15);CF")
 SET help = off
 SELECT INTO "nl:"
  FROM dm_schema_log d
  WHERE d.run_id=cnvtreal(curaccept)
  DETAIL
   work->run_id = d.run_id
   IF (d.ocd > 0)
    work->ocd = d.ocd
   ELSE
    work->ocd = 0, work->schema_date = cnvtdatetime(d.schema_date)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO 1020_target_schema
 ENDIF
 CALL clear(5,50,15)
 IF (work->ocd)
  CALL text(5,50,trim(cnvtstring(work->ocd)))
 ELSE
  CALL text(5,50,format(work->schema_date,"DD-MMM-YYYY;;D"))
 ENDIF
 CALL status("Building list of tables...  Please wait.")
 FREE RECORD tbls
 RECORD tbls(
   1 tbl[*]
     2 name = vc
     2 add_not_null = i2
     2 create_index = i2
     2 downtime = f8
     2 rows = i4
     2 ocd = i4
     2 schema_date = dq8
     2 run_id = f8
 )
 SET tbl_count = 0
 SET tbl_count = dos_build_table_list(0)
 SET dos_rebuild_list = 0
 IF ( NOT (tbl_count))
  CALL clear(23,1)
  IF (work->ocd)
   SET work->text = concat("No tables found needing online schema changes for OCD ",trim(cnvtstring(
      work->ocd)),".")
  ELSE
   SET work->text = concat("No tables found needing online schema changes for schema date ",format(
     work->schema_date,"DD-MMM-YYYY;;D"),".")
  ENDIF
  CALL text(23,2,work->text)
  CALL text(24,2,"(S)elect another OCD or Schema Date, (Q)uit : ")
  CALL accept(24,48,"P;CU","S")
  IF (curaccept="Q")
   GO TO 9999_exit_program
  ENDIF
  GO TO 1020_target_schema
 ENDIF
#1999_initialize_exit
#2000_main
 EXECUTE FROM 2100_table TO 2199_table_exit
 EXECUTE FROM 2200_init TO 2299_init_exit
 EXECUTE FROM 2300_custom TO 2399_custom_exit
 EXECUTE FROM 2400_reorg TO 2499_reorg_exit
 IF (reorg_tspace_ind=0)
  GO TO 2010_cleanup
 ENDIF
 SET reorg_id = 0.0
 SET reorg_back_ind = 1
 EXECUTE FROM 2200_init TO 2299_init_exit
 EXECUTE FROM 2300_custom TO 2399_custom_exit
 EXECUTE FROM 2400_reorg TO 2499_reorg_exit
#2010_cleanup
 EXECUTE FROM 2500_cleanup TO 2599_cleanup_exit
#2999_main_exit
 GO TO main_process
#2000_main_batch
 EXECUTE FROM 2100_table TO 2101_table_exit
 FOR (tblndx = 1 TO tbl_count)
   SET work->table_name = tbls->tbl[tblndx].name
   SET work->run_id = tbls->tbl[tblndx].run_id
   SET work->ocd = tbls->tbl[tblndx].ocd
   IF ((tbls->tbl[tblndx].ocd=0))
    SET work->schema_date = tbls->tbl[tblndx].schema_date
   ENDIF
   SET reorg_back_ind = 0
   IF (reorg_tspace_setup)
    SET reorg_tspace_ind = 1
   ELSE
    SET reorg_tspace_ind = 0
   ENDIF
   EXECUTE FROM 2200_init TO 2299_init_exit
   EXECUTE FROM 2300_custom TO 2319_custom_exit
   SET all_valid = dos_check_segment_size(reorg_id)
   IF (all_valid)
    IF (reorg_tspace_ind)
     IF (reorg_back_ind=0)
      CALL dos_save_segment_info(reorg_id)
     ENDIF
    ENDIF
    EXECUTE FROM 2400_reorg TO 2499_reorg_exit
    IF (reorg_tspace_ind)
     SET reorg_id = 0.0
     SET reorg_back_ind = 1
     EXECUTE FROM 2200_init TO 2299_init_exit
     EXECUTE FROM 2300_custom TO 2319_custom_exit
     IF (reorg_tspace_ind
      AND reorg_back_ind)
      IF (all_valid)
       EXECUTE FROM 2400_reorg TO 2499_reorg_exit
      ENDIF
     ENDIF
    ENDIF
    EXECUTE FROM 2500_cleanup TO 2590_cleanup_exit
   ENDIF
 ENDFOR
#2999_main_batch_exit
 GO TO 9999_exit_program
#2100_table
 CALL dos_check_session_id(session_id)
 SET work->table_name = ""
 SET reorg_id = 0.0
 SET reorg_back_ind = 0
 CALL draw_table_banner(0)
 IF (dos_rebuild_list)
  CALL status("Building list of tables...  Please wait.")
  SET tbl_count = 0
  SET tbl_count = dos_build_table_list(0)
  IF ( NOT (tbl_count))
   IF (work->ocd)
    CALL message(concat("No tables found needing online schema changes for OCD ",trim(cnvtstring(work
        ->ocd)),". Press <RETURN> to exit..."))
   ELSE
    CALL message(concat("No tables found needing online schema changes for schema date ",format(work
       ->schema_date,"DD-MMM-YYYY;;D"),". Press <RETURN> to exit..."))
   ENDIF
   GO TO 9999_exit_program
  ENDIF
 ENDIF
 CALL status("")
 CALL text(4,3,"Table")
 CALL text(4,34,"Estimated Downtime")
 CALL text(4,58,"Operations")
 IF ((work->ocd > 0))
  SET work->text = concat("OCD: ",trim(cnvtstring(work->ocd)))
  CALL text(4,(131 - size(work->text)),"OCD: ")
  CALL video(l)
  CALL text(4,((131 - size(work->text))+ 5),trim(cnvtstring(work->ocd)))
  CALL video(n)
 ELSE
  SET work->text = concat("Schema Date: ",trim(format(work->schema_date,"DD-MMM-YYYY;;D")))
  CALL text(4,(131 - size(work->text)),"Schema Date: ")
  CALL video(l)
  CALL text(4,((131 - size(work->text))+ 13),trim(format(work->schema_date,"DD-MMM-YYYY;;D")))
  CALL video(n)
 ENDIF
 CALL line(5,2,130)
 CALL line(23,1,132)
 SET stat = alterlist(list->list,tbl_count)
 FOR (i = 1 TO tbl_count)
   SET work->text = ""
   CALL pad(2,tbls->tbl[i].name)
   CALL pad(36,trim(format(tbls->tbl[i].downtime,"DD.HH:MM:SS;3;z"),3))
   SET work->text2 = ""
   IF (tbls->tbl[i].create_index)
    SET work->text2 = concat("CREATE INDEX [",trim(cnvtstring(tbls->tbl[i].create_index),3),"]")
   ENDIF
   IF (tbls->tbl[i].add_not_null)
    IF (size(trim(work->text2,3)))
     SET work->text2 = concat(work->text2," / ADD NOT NULL CONSTRAINT [",trim(cnvtstring(tbls->tbl[i]
        .add_not_null),3),"]")
    ELSE
     SET work->text2 = concat("ADD NOT NULL CONSTRAINT [",trim(cnvtstring(tbls->tbl[i].add_not_null),
       3),"]")
    ENDIF
   ENDIF
   CALL pad(57,work->text2)
   SET list->list[i].text = work->text
 ENDFOR
 SET list_top = 6
 SET list_left = 2
 SET list_right = 131
 SET list_bottom = 22
 SET list_item = 0
 CALL list_init(0)
#2101_table_exit
#2105_accept
 CALL list_draw_item(1)
 CALL text(24,1," (S)elect a table, (V)iew table operation details, or (Q)uit: S")
 CALL accept(24,63,"P;CUS","S"
  WHERE curaccept IN ("S", "s", "V", "v", "Q",
  "q"))
 CASE (curscroll)
  OF creturn:
   CASE (cnvtupper(trim(curaccept,3)))
    OF "S":
     SET work->table_name = tbls->tbl[list_item].name
     SET work->run_id = tbls->tbl[list_item].run_id
     SET work->ocd = tbls->tbl[list_item].ocd
     IF ((tbls->tbl[list_item].ocd=0))
      SET work->schema_date = tbls->tbl[list_item].schema_date
     ENDIF
     GO TO 2120_table_options
    OF "V":
     SET work->table_name = tbls->tbl[list_item].name
     SET work->run_id = tbls->tbl[list_item].run_id
     SET work->ocd = tbls->tbl[list_item].ocd
     IF ((tbls->tbl[list_item].ocd=0))
      SET work->schema_date = tbls->tbl[list_item].schema_date
     ENDIF
     EXECUTE FROM 2110_details TO 2119_details_exit
     SET save_list_item = list_item
     CALL list_item_line(0)
     SET list_item = ((list_item - list_line)+ 1)
     CALL list_draw_page(0)
     SET list_item = save_list_item
     SET work->table_name = ""
    ELSE
     GO TO 9999_exit_program
   ENDCASE
  OF cdown_arrow:
   CALL list_down_arrow(0)
  OF cup_arrow:
   CALL list_up_arrow(0)
  OF cpage_down:
   CALL list_page_down(0)
  OF cpage_up:
   CALL list_page_up(0)
 ENDCASE
 GO TO 2105_accept
#2120_table_options
 CALL clear(24,1)
 IF (reorg_tspace_setup)
  CALL status("Checking for temporary reorg tablespaces...")
  SET dos_tbl_trt = 0
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE (u.table_name=work->table_name)
    AND (u.tablespace_name=work->reorg_data_tspace)
   WITH nocounter
  ;end select
  IF (curqual)
   SET dos_tbl_trt = 1
  ENDIF
  SET dos_ind_cnt = 0
  SET dos_ind_trt = 0
  SELECT INTO "nl:"
   FROM user_indexes u
   WHERE (u.table_name=work->table_name)
   DETAIL
    dos_ind_cnt = (dos_ind_cnt+ 1)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM user_indexes u
   WHERE (u.table_name=work->table_name)
    AND (u.tablespace_name=work->reorg_index_tspace)
   WITH nocounter
  ;end select
  IF (curqual=dos_ind_cnt)
   SET dos_ind_trt = 1
  ENDIF
  CALL status("Checking for temporary reorg tablespaces...done!")
  IF (((dos_tbl_trt) OR (dos_ind_trt)) )
   SET reorg_tspace_ind = 0
   SET work->text = concat(
    "The table or all its indexes are already in temporary reorg tablespace...",
    "  cannot use temporary reorg tablespaces option.")
   CALL status(work->text)
   CALL pause(4)
  ELSE
   SET work->text = concat(" Use temporary reorg tablespaces (",trim(work->reorg_data_tspace),", ",
    trim(work->reorg_index_tspace),") for this table ? (Y/N)")
   CALL text(24,1,work->text)
   SET nlen = (size(trim(work->text))+ 2)
   CALL accept(24,nlen,"P;CU","Y")
   IF (curaccept != "Y")
    SET reorg_tspace_ind = 0
   ELSE
    SET reorg_tspace_ind = 1
   ENDIF
  ENDIF
 ENDIF
 CALL status("Looking for old LOCK DAEMON session...")
 EXECUTE dm_online_kill_lock_mgr
 CALL status("Looking for old LOCK DAEMON session...done!")
#2199_table_exit
#2110_details
 CALL list_copy(0)
 FREE RECORD ops
 RECORD ops(
   1 op[*]
     2 operation = vc
     2 downtime = f8
     2 object = vc
 )
 SET op_count = 0
 SELECT INTO "nl:"
  o.op_type
  FROM dm_schema_op_log o,
   dm_schema_log l
  WHERE (o.table_name=work->table_name)
   AND (l.run_id=work->run_id)
   AND o.run_id=l.run_id
   AND o.begin_dt_tm = null
   AND o.op_type IN (cadd_not_null, ccreate_index)
  ORDER BY o.est_duration DESC, o.op_type, o.obj_name
  DETAIL
   op_count = (op_count+ 1), stat = alterlist(ops->op,op_count), ops->op[op_count].operation = o
   .op_type,
   ops->op[op_count].downtime = o.est_duration, ops->op[op_count].object = o.obj_name
  WITH nocounter
 ;end select
 CALL clear(24,1)
 CALL box(6,60,22,131)
 CALL clear(7,61,70)
 CALL text(7,62,"Operation")
 CALL text(7,88,"Object")
 CALL text(7,120,"Downtime")
 CALL line(8,60,72,xhorizontal)
 CALL line(20,60,72,xhorizontal)
 SET stat = alterlist(list->list,op_count)
 FOR (i = 1 TO op_count)
   SET work->text = ""
   CALL pad(2,ops->op[i].operation)
   CALL pad(28,ops->op[i].object)
   CALL pad(59,trim(format(ops->op[i].downtime,"DD.HH:MM:SS;3;z"),3))
   SET list->list[i].text = work->text
 ENDFOR
 SET list_top = 9
 SET list_left = 61
 SET list_right = 130
 SET list_bottom = 19
 SET list_item = 0
 CALL list_init(0)
 SET flag = 1
 WHILE (flag)
   CALL list_draw_item(1)
   CALL text(21,62,"Press <RETURN> to return to the main list...")
   CALL accept(21,107,"P;ECUS"," ")
   CASE (curscroll)
    OF creturn:
     SET flag = 0
    OF cdown_arrow:
     CALL list_down_arrow(0)
    OF cup_arrow:
     CALL list_up_arrow(0)
    OF cpage_down:
     CALL list_page_down(0)
    OF cpage_up:
     CALL list_page_up(0)
   ENDCASE
 ENDWHILE
 CALL list_restore(0)
#2119_details_exit
#2200_init
 IF (reorg_back_ind)
  CALL status("Initializing for reorg back to original tablespace.  Please wait...")
 ELSE
  CALL status("Initializing.  Please wait...")
 ENDIF
 SET prev_reorg_id = 0.0
 SET cleanup = 1
 SELECT INTO "nl:"
  o.table_name
  FROM reorg_objects o,
   reorg_log l
  PLAN (o
   WHERE o.owner="V500"
    AND (o.table_name=work->table_name)
    AND cnvtupper(o.status) != "REORG COMPLETE")
   JOIN (l
   WHERE l.reorg_id=o.reorg_id
    AND l.entry_id IN (
   (SELECT
    max(x.entry_id)
    FROM reorg_log x
    WHERE x.reorg_id=l.reorg_id)))
  DETAIL
   prev_reorg_id = o.reorg_id
   IF (cnvtupper(trim(l.procedure_name,3))="SWITCHOVER")
    cleanup = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (prev_reorg_id)
  IF (cleanup)
   CALL cleanup_aborted_reorg(prev_reorg_id)
  ELSE
   CALL kick(
    "Unable to continue.  This table is currently in a 'SwitchOver' status.  Call Cerner support.")
  ENDIF
 ENDIF
 CALL dos_check_session_id(session_id)
 CALL dos_fix_userlastupdt(0)
 CALL push("declare")
 CALL push("  id number;")
 CALL push("begin")
 CALL push(concat("  id := pkg_reorg.EnqueTable('V500', '",work->table_name,"');"))
 CALL push("end;")
 SET run_stat = run(0)
 IF (run_stat > 0)
  CALL status(dos_err_msg)
  CALL kick("Function EnqueTable() failed!")
 ENDIF
 SET reorg_id = 0.0
 SET reorg_id = reorg_id(work->table_name)
 CALL log(concat("REORG ID: ",trim(cnvtstring(reorg_id),3)))
 IF ( NOT (reorg_id))
  CALL kick("Unable to start reorg.  No new REORG_ID generated by PKG_REORG.ENQUETABLE.")
 ENDIF
 CALL proc("InitReorg",reorg_id)
 CALL status("")
#2299_init_exit
#2300_custom
 IF (reorg_back_ind)
  CALL status("Loading segments for reorg back to original tablespace.  Please wait...")
 ELSE
  CALL status("Loading segments...")
 ENDIF
 SET new_segments = 1
 FREE RECORD segments
 RECORD segments(
   1 segment[*]
     2 segment_name = vc
     2 object_type = vc
     2 initial_extent = f8
     2 next_extent = f8
     2 tablespace_name = vc
     2 max_extents = i4
     2 min_extents = i4
     2 pct_increase = i4
     2 pct_free = i4
     2 pct_used = i4
     2 freelists = i4
     2 freelist_groups = i4
     2 parallel_degree = c10
     2 instances = c10
     2 cash = c5
     2 ini_trans = i4
     2 max_trans = i4
     2 need_check = i2
     2 next_extent_cnt = i4
     2 total_space = f8
     2 used_space = f8
     2 day_space = f8
     2 valid = i2
     2 message1 = vc
     2 message2 = vc
     2 temp_reorg_tspace = i2
 )
 SET segment_count = 0
 CALL dos_load_segment_info(reorg_id)
 CALL status("Capturing segment sizing information...")
 SELECT INTO "nl:"
  o.total_space
  FROM space_objects o,
   (dummyt d  WITH seq = value(segment_count))
  PLAN (d)
   JOIN (o
   WHERE o.report_seq=summary_seq
    AND (o.segment_name=segments->segment[d.seq].segment_name))
  DETAIL
   segments->segment[d.seq].used_space = ((o.total_space - o.free_space) * block)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.total_space
  FROM space_objects o,
   (dummyt d  WITH seq = value(segment_count))
  PLAN (d)
   JOIN (o
   WHERE o.report_seq=prior_summary_seq
    AND (o.segment_name=segments->segment[d.seq].segment_name))
  HEAD REPORT
   prior_used = 0.0
  DETAIL
   prior_used = ((o.total_space - o.free_space) * block), segments->segment[d.seq].day_space =
   greatest(0.0,((segments->segment[d.seq].used_space - prior_used)/ summary_days))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.segment_name, tot_spc = sum(e.bytes)
  FROM dba_extents e,
   (dummyt d  WITH seq = value(segment_count))
  PLAN (d)
   JOIN (e
   WHERE (e.segment_name=segments->segment[d.seq].segment_name))
  GROUP BY e.segment_name
  DETAIL
   segments->segment[d.seq].used_space = tot_spc, segments->segment[d.seq].total_space = (tot_spc *
   1.2)
  WITH nocounter
 ;end select
 SET all_valid = 1
#2315_display
 SET stat = alterlist(list->list,segment_count)
 SET need_check = 0
 IF (reorg_tspace_ind
  AND reorg_back_ind
  AND all_valid)
  SET all_valid = dos_check_segment_size(reorg_id)
 ENDIF
 FOR (i = 1 TO segment_count)
   SET work->text = ""
   IF ((segments->segment[i].need_check=0))
    SET work->text = concat("   ",segments->segment[i].segment_name)
   ELSE
    SET need_check = 1
    SET work->text = concat(" ? ",segments->segment[i].segment_name)
   ENDIF
   IF ((segments->segment[i].valid=0))
    SET all_valid = 0
    SET work->text = concat(" * ",segments->segment[i].segment_name)
   ENDIF
   CALL pad(36,format(segments->segment[i].total_space,"##############;,RP "))
   CALL pad(52,format(segments->segment[i].day_space,"############;,RP "))
   CALL pad(66,segments->segment[i].tablespace_name)
   CALL pad(98,format(segments->segment[i].initial_extent,"##############;,RP "))
   CALL pad(114,format(segments->segment[i].next_extent,"##############;,RP "))
   SET list->list[i].text = work->text
 ENDFOR
 CALL draw_table_banner(0)
 CALL draw_segment_list_banner(0)
 IF (new_segments)
  SET new_segments = 0
  CALL line(23,1,132)
  SET list_top = 9
  SET list_left = 2
  SET list_right = 131
  SET list_bottom = 22
  SET list_item = 0
  CALL list_init(0)
 ELSE
  SET save_list_item = list_item
  CALL list_item_line(0)
  SET list_item = ((list_item - list_line)+ 1)
  CALL list_draw_page(0)
  SET list_item = save_list_item
 ENDIF
#2319_custom_exit
#2320_accept
 CALL list_draw_item(1)
 IF (reorg_tspace_ind
  AND reorg_back_ind)
  IF (all_valid)
   GO TO 2399_custom_exit
  ENDIF
 ENDIF
 CALL clear(24,1)
 IF (all_valid=1
  AND need_check=0)
  IF (reorg_tspace_ind
   AND reorg_back_ind)
   CALL text(24,1," (C)ontinue, (V)iew segment details: ")
  ELSE
   CALL text(24,1," (C)ontinue, (V)iew segment details, or (Q)uit: ")
  ENDIF
 ELSE
  IF (reorg_tspace_ind
   AND reorg_back_ind)
   CALL text(24,1," (C)heck segment sizing, (V)iew segment details: ")
  ELSE
   CALL text(24,1," (C)heck segment sizing, (V)iew segment details, or (Q)uit: ")
  ENDIF
 ENDIF
 IF (need_check)
  CALL video(l)
  CALL clear(24,95)
  CALL text(24,95,"(?) - Need to check segment sizing")
  CALL video(n)
 ENDIF
 IF (all_valid=0)
  CALL video(l)
  CALL clear(24,95)
  CALL text(24,104,"(*) - Segment sizing invalid")
  CALL video(n)
 ENDIF
 IF (reorg_tspace_ind
  AND reorg_back_ind)
  CALL accept(24,61,"P;CUS","V"
   WHERE curaccept IN ("C", "c", "V", "v"))
 ELSE
  CALL accept(24,61,"P;CUS","V"
   WHERE curaccept IN ("C", "c", "V", "v", "Q",
   "q"))
 ENDIF
 SET skip_edit = 1
 CASE (curscroll)
  OF creturn:
   CASE (cnvtupper(trim(curaccept,3)))
    OF "C":
     IF (all_valid=1
      AND need_check=0)
      IF (reorg_tspace_ind)
       IF (reorg_back_ind=0)
        CALL dos_save_segment_info(reorg_id)
       ENDIF
      ENDIF
      GO TO 2399_custom_exit
     ELSE
      SET all_valid = dos_check_segment_size(reorg_id)
      GO TO 2315_display
     ENDIF
    OF "V":
     SET skip_edit = 0
    OF "Q":
     IF (reorg_tspace_ind
      AND reorg_back_ind)
      GO TO 2315_display
     ELSE
      CALL dos_set_userlastupdt(work->userlastupdt)
      GO TO 2000_main
     ENDIF
    ELSE
     GO TO 9999_exit_program
   ENDCASE
  OF cdown_arrow:
   CALL list_down_arrow(0)
  OF cup_arrow:
   CALL list_up_arrow(0)
  OF cpage_down:
   CALL list_page_down(0)
  OF cpage_up:
   CALL list_page_up(0)
  ELSE
   GO TO 2320_accept
 ENDCASE
 SET recheck = 0
 EXECUTE FROM 2310_edit TO 2319_edit_exit
 GO TO 2315_display
 GO TO 2320_accept
#2310_edit
 IF (skip_edit)
  GO TO 2319_edit_exit
 ENDIF
 SET edit_index = list_item
 SET valid = segments->segment[edit_index].valid
 FREE RECORD new_info
 RECORD new_info(
   1 tablespace_name = vc
   1 initial_extent = f8
   1 next_extent = f8
   1 max_extents = i4
   1 min_extents = i4
   1 pct_increase = i4
   1 pct_free = i4
   1 pct_used = i4
   1 freelists = i4
   1 freelist_groups = i4
   1 parallel_degree = c10
   1 instances = c10
   1 cash = c5
   1 ini_trans = i4
   1 max_trans = i4
 )
 SET new_info->tablespace_name = segments->segment[edit_index].tablespace_name
 SET new_info->initial_extent = segments->segment[edit_index].initial_extent
 SET new_info->next_extent = segments->segment[edit_index].next_extent
 SET new_info->max_extents = segments->segment[edit_index].max_extents
 SET new_info->min_extents = segments->segment[edit_index].min_extents
 SET new_info->pct_increase = segments->segment[edit_index].pct_increase
 SET new_info->pct_free = segments->segment[edit_index].pct_free
 SET new_info->pct_used = segments->segment[edit_index].pct_used
 SET new_info->freelists = segments->segment[edit_index].freelists
 SET new_info->freelist_groups = segments->segment[edit_index].freelist_groups
 SET new_info->parallel_degree = segments->segment[edit_index].parallel_degree
 SET new_info->instances = segments->segment[edit_index].instances
 SET new_info->cash = segments->segment[edit_index].cash
 SET new_info->ini_trans = segments->segment[edit_index].ini_trans
 SET new_info->max_trans = segments->segment[edit_index].max_trans
 SET work->segment_name = segments->segment[edit_index].segment_name
 SET work->segment_type = segments->segment[edit_index].object_type
 CALL draw_segment_banner(edit_index)
 CALL draw_segment_fields(edit_index)
 CALL redisplay(0)
#2311_prompt
 CALL text(24,1,"(M)odify segment, (R)estore default values, or (C)ontinue? C")
 CALL accept(24,60,"P;CU","C"
  WHERE curaccept IN ("M", "m", "R", "r", "C",
  "c"))
 CASE (cnvtupper(trim(curaccept,3)))
  OF "M":
   SET recheck = 1
  OF "R":
   SELECT INTO "nl:"
    s.tablespace_name
    FROM reorg_segments s
    WHERE s.reorg_id=reorg_id
     AND cnvtupper(s.original_flag)="O"
     AND (cnvtupper(s.object_name)=segments->segment[edit_index].segment_name)
    DETAIL
     IF (reorg_tspace_ind=0)
      segments->segment[edit_index].tablespace_name = cnvtupper(trim(s.tablespace_name,3))
     ENDIF
     segments->segment[edit_index].initial_extent = s.initial_extent, segments->segment[edit_index].
     next_extent = s.next_extent, segments->segment[edit_index].min_extents = s.min_extents,
     segments->segment[edit_index].max_extents = s.max_extents, segments->segment[edit_index].
     pct_increase = s.pct_increase, segments->segment[edit_index].pct_free = s.pct_free,
     segments->segment[edit_index].pct_used = s.pct_used, segments->segment[edit_index].freelists = s
     .freelists, segments->segment[edit_index].freelist_groups = s.freelist_groups,
     segments->segment[edit_index].parallel_degree = s.degree, segments->segment[edit_index].
     instances = s.instances, segments->segment[edit_index].cash = s.cash,
     segments->segment[edit_index].ini_trans = s.ini_trans, segments->segment[edit_index].max_trans
      = s.max_trans
    WITH nocounter
   ;end select
   SET new_info->tablespace_name = segments->segment[edit_index].tablespace_name
   SET new_info->initial_extent = segments->segment[edit_index].initial_extent
   SET new_info->next_extent = segments->segment[edit_index].next_extent
   SET new_info->max_extents = segments->segment[edit_index].max_extents
   SET new_info->min_extents = segments->segment[edit_index].min_extents
   SET new_info->pct_increase = segments->segment[edit_index].pct_increase
   SET new_info->pct_free = segments->segment[edit_index].pct_free
   SET new_info->pct_used = segments->segment[edit_index].pct_used
   SET new_info->freelists = segments->segment[edit_index].freelists
   SET new_info->freelist_groups = segments->segment[edit_index].freelist_groups
   SET new_info->parallel_degree = segments->segment[edit_index].parallel_degree
   SET new_info->instances = segments->segment[edit_index].instances
   SET new_info->cash = segments->segment[edit_index].cash
   SET new_info->ini_trans = segments->segment[edit_index].ini_trans
   SET new_info->max_trans = segments->segment[edit_index].max_trans
   CALL redisplay(0)
   SET recheck = 1
   GO TO 2311_prompt
  OF "C":
   IF (recheck)
    UPDATE  FROM reorg_segments s
     SET s.initial_extent = segments->segment[edit_index].initial_extent, s.next_extent = segments->
      segment[edit_index].next_extent, s.tablespace_name = segments->segment[edit_index].
      tablespace_name,
      s.min_extents = segments->segment[edit_index].min_extents, s.max_extents = segments->segment[
      edit_index].max_extents, s.pct_increase = segments->segment[edit_index].pct_increase,
      s.pct_free = evaluate(segments->segment[edit_index].pct_free,0,null,segments->segment[
       edit_index].pct_free), s.pct_used = evaluate(segments->segment[edit_index].pct_used,0,null,
       segments->segment[edit_index].pct_used), s.freelists = segments->segment[edit_index].freelists,
      s.freelist_groups = segments->segment[edit_index].freelist_groups, s.degree = evaluate(segments
       ->segment[edit_index].parallel_degree," ",null,segments->segment[edit_index].parallel_degree),
      s.instances = evaluate(segments->segment[edit_index].instances," ",null,segments->segment[
       edit_index].instances),
      s.cash = evaluate(segments->segment[edit_index].cash," ",null,segments->segment[edit_index].
       cash), s.ini_trans = segments->segment[edit_index].ini_trans, s.max_trans = segments->segment[
      edit_index].max_trans
     WHERE s.reorg_id=reorg_id
      AND (cnvtupper(s.original_name)=segments->segment[edit_index].segment_name)
      AND cnvtupper(s.original_flag)="N"
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
   GO TO 2319_edit_exit
 ENDCASE
#2312a_tablespace
 IF (reorg_tspace_ind=0)
  CALL redisplay(0)
  CALL status("Enter tablespace name")
  CALL accept(9,18,"P(30);CUS",new_info->tablespace_name)
  CASE (curscroll)
   OF creturn:
    SELECT INTO "nl:"
     t.tablespace_name
     FROM user_tablespaces t
     WHERE t.tablespace_name=cnvtupper(trim(curaccept,3))
      AND t.status="ONLINE"
     WITH nocounter
    ;end select
    IF (curqual)
     SET new_info->tablespace_name = cnvtupper(trim(curaccept,3))
    ELSE
     GO TO 2312a_tablespace
    ENDIF
   ELSE
    GO TO 2312a_tablespace
  ENDCASE
 ENDIF
#2312b_initial_extent
 IF (reorg_tool_ind=0)
  GO TO 2312c_next_extent
 ENDIF
 CALL redisplay(0)
 CALL status("Enter initial extent (use 'K' for KiloBytes and 'M' for MegaBytes)")
 CALL accept(10,18,"P(11);CS",trim(cnvtstring(new_info->initial_extent),3))
 CASE (curscroll)
  OF creturn:
   SET nlen = findstring("K",cnvtupper(trim(curaccept,3)))
   IF (nlen=0)
    SET nlen = findstring("M",cnvtupper(trim(curaccept,3)))
   ENDIF
   IF (nlen=0)
    SET nlen = size(trim(curaccept,3))
   ENDIF
   SET nlast = cnvtupper(substring(nlen,1,trim(curaccept,3)))
   SET nvalue = 0.0
   IF (nlast="K")
    SET nvalue = (cnvtreal(substring(1,(nlen - 1),trim(curaccept,3))) * 1024.0)
   ELSEIF (nlast="M")
    SET nvalue = ((cnvtreal(substring(1,(nlen - 1),trim(curaccept,3))) * 1024.0) * 1024.0)
   ELSE
    SET nvalue = cnvtreal(curaccept)
   ENDIF
   IF (nvalue)
    SET new_info->initial_extent = nvalue
   ELSE
    GO TO 2312b_initial_extent
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312a_tablespace
  ELSE
   GO TO 2312b_initial_extent
 ENDCASE
#2312c_next_extent
 CALL redisplay(0)
 CALL status("Enter initial extent (use 'K' for KiloBytes and 'M' for MegaBytes)")
 CALL accept(11,18,"P(11);CS",trim(cnvtstring(new_info->next_extent),3))
 CASE (curscroll)
  OF creturn:
   SET nlen = findstring("K",cnvtupper(trim(curaccept,3)))
   IF (nlen=0)
    SET nlen = findstring("M",cnvtupper(trim(curaccept,3)))
   ENDIF
   IF (nlen=0)
    SET nlen = size(trim(curaccept,3))
   ENDIF
   SET nlast = cnvtupper(substring(nlen,1,trim(curaccept,3)))
   SET nvalue = 0.0
   IF (nlast="K")
    SET nvalue = (cnvtreal(substring(1,(nlen - 1),trim(curaccept,3))) * 1024.0)
   ELSEIF (nlast="M")
    SET nvalue = ((cnvtreal(substring(1,(nlen - 1),trim(curaccept,3))) * 1024.0) * 1024.0)
   ELSE
    SET nvalue = cnvtreal(curaccept)
   ENDIF
   IF (nvalue)
    SET new_info->next_extent = nvalue
   ELSE
    GO TO 2312c_next_extent
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312b_initial_extent
  ELSE
   GO TO 2312c_next_extent
 ENDCASE
#2312d_min_extents
 CALL redisplay(0)
 CALL status("Enter number of minimum extents")
 CALL accept(12,18,"9(11);S",trim(cnvtstring(new_info->min_extents),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept))
    SET new_info->min_extents = cnvtint(curaccept)
   ELSE
    GO TO 2312d_min_extents
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312c_next_extent
  ELSE
   GO TO 2312d_min_extents
 ENDCASE
#2312e_max_extents
 CALL redisplay(0)
 CALL status("Enter number of maximum extents")
 CALL accept(13,18,"9(11);S",trim(cnvtstring(new_info->max_extents),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept))
    SET new_info->max_extents = cnvtint(curaccept)
   ELSE
    GO TO 2312e_max_extents
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312d_min_extents
  ELSE
   GO TO 2312e_max_extents
 ENDCASE
#2312f_pct_increase
 IF (reorg_tool_ind=0)
  GO TO 2312z_end_prompt
 ENDIF
 CALL redisplay(0)
 CALL status("Enter value for pct_increase")
 CALL accept(14,18,"9(11);S",trim(cnvtstring(new_info->pct_increase),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->pct_increase = cnvtint(curaccept)
   ELSE
    GO TO 2312f_pct_increase
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312e_max_extents
  ELSE
   GO TO 2312f_pct_increase
 ENDCASE
#2312g_pct_free
 CALL redisplay(0)
 CALL status("Enter value for pct_free")
 CALL accept(15,18,"9(11);S",trim(cnvtstring(new_info->pct_free),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->pct_free = cnvtint(curaccept)
   ELSE
    GO TO 2312g_pct_free
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312f_pct_increase
  ELSE
   GO TO 2312g_pct_free
 ENDCASE
#2312h_pct_used
 CALL redisplay(0)
 CALL status("Enter value for pct_used")
 CALL accept(16,18,"9(11);S",trim(cnvtstring(new_info->pct_used),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->pct_used = cnvtint(curaccept)
   ELSE
    GO TO 2312h_pct_used
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312g_pct_free
  ELSE
   GO TO 2312h_pct_used
 ENDCASE
#2312i_freelists
 CALL redisplay(0)
 CALL status("Enter value for freelists")
 CALL accept(10,83,"9(11);S",trim(cnvtstring(new_info->freelists),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->freelists = cnvtint(curaccept)
   ELSE
    GO TO 2312i_freelists
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312h_pct_used
  ELSE
   GO TO 2312i_freelists
 ENDCASE
#2312j_freelist_groups
 CALL redisplay(0)
 CALL status("Enter value for freelist groups")
 CALL accept(11,83,"9(11);S",trim(cnvtstring(new_info->freelist_groups),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->freelist_groups = cnvtint(curaccept)
   ELSE
    GO TO 2312j_freelist_groups
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312i_freelists
  ELSE
   GO TO 2312j_freelist_groups
 ENDCASE
#2312k_parallel_degree
 CALL redisplay(0)
 CALL status("Enter degree of parallelism")
 CALL accept(12,83,"P(10);CS",trim(new_info->parallel_degree,3))
 CASE (curscroll)
  OF creturn:
   SET new_info->parallel_degree = trim(curaccept)
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312j_freelist_groups
  ELSE
   GO TO 2312k_parallel_degree
 ENDCASE
#2312l_instances
 CALL redisplay(0)
 CALL status("Enter value of instances")
 CALL accept(13,83,"P(10);CS",trim(new_info->instances,3))
 CASE (curscroll)
  OF creturn:
   SET new_info->instances = trim(curaccept)
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312k_parallel_degree
  ELSE
   GO TO 2312l_instances
 ENDCASE
#2312m_cash
 CALL redisplay(0)
 CALL status("Enter value for cache")
 CALL accept(14,83,"P(5);CS",trim(new_info->cash,3))
 CASE (curscroll)
  OF creturn:
   SET new_info->cash = trim(curaccept)
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312l_instances
  ELSE
   GO TO 2312m_cash
 ENDCASE
#2312n_ini_trans
 CALL redisplay(0)
 CALL status("Enter number of ini trans")
 CALL accept(15,83,"9(11);S",trim(cnvtstring(new_info->ini_trans),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->ini_trans = cnvtint(curaccept)
   ELSE
    GO TO 2312n_ini_trans
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312m_cash
  ELSE
   GO TO 2312n_ini_trans
 ENDCASE
#2312o_max_trans
 CALL redisplay(0)
 CALL status("Enter number of max trans")
 CALL accept(16,83,"9(11);S",trim(cnvtstring(new_info->max_trans),3))
 CASE (curscroll)
  OF creturn:
   IF (cnvtint(curaccept) >= 0)
    SET new_info->max_trans = cnvtint(curaccept)
   ELSE
    GO TO 2312o_max_trans
   ENDIF
  OF cup_arrow:
   CALL redisplay(0)
   GO TO 2312n_ini_trans
  ELSE
   GO TO 2312o_max_trans
 ENDCASE
#2312z_end_prompt
 CALL redisplay(0)
 IF ((new_info->tablespace_name != segments->segment[edit_index].tablespace_name))
  SET segments->segment[edit_index].tablespace_name = new_info->tablespace_name
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->initial_extent != segments->segment[edit_index].initial_extent))
  SET segments->segment[edit_index].initial_extent = new_info->initial_extent
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->next_extent != segments->segment[edit_index].next_extent))
  SET segments->segment[edit_index].next_extent = new_info->next_extent
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->min_extents != segments->segment[edit_index].min_extents))
  SET segments->segment[edit_index].min_extents = new_info->min_extents
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->max_extents != segments->segment[edit_index].max_extents))
  SET segments->segment[edit_index].max_extents = new_info->max_extents
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->pct_increase != segments->segment[edit_index].pct_increase))
  SET segments->segment[edit_index].pct_increase = new_info->pct_increase
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->pct_free != segments->segment[edit_index].pct_free))
  SET segments->segment[edit_index].pct_free = new_info->pct_free
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->pct_used != segments->segment[edit_index].pct_used))
  SET segments->segment[edit_index].pct_used = new_info->pct_used
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->freelists != segments->segment[edit_index].freelists))
  SET segments->segment[edit_index].freelists = new_info->freelists
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->freelist_groups != segments->segment[edit_index].freelist_groups))
  SET segments->segment[edit_index].freelist_groups = new_info->freelist_groups
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->parallel_degree != segments->segment[edit_index].parallel_degree))
  SET segments->segment[edit_index].parallel_degree = new_info->parallel_degree
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->instances != segments->segment[edit_index].instances))
  SET segments->segment[edit_index].instances = new_info->instances
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->cash != segments->segment[edit_index].cash))
  SET segments->segment[edit_index].cash = new_info->cash
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->ini_trans != segments->segment[edit_index].ini_trans))
  SET segments->segment[edit_index].ini_trans = new_info->ini_trans
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 IF ((new_info->max_trans != segments->segment[edit_index].max_trans))
  SET segments->segment[edit_index].max_trans = new_info->max_trans
  SET segments->segment[edit_index].need_check = 1
 ENDIF
 GO TO 2311_prompt
#2319_edit_exit
#2399_custom_exit
#2400_reorg
 IF ((work->lock_mgr_ind=1)
  AND ((reorg_tspace_ind=0) OR (reorg_back_ind=0)) )
  SET dos_lock_mgr = 0
  WHILE (dos_lock_mgr=0)
   CALL dos_prompt(
    "Please execute 'dm_online_start_lock_mgr go' in another CCL session. Then type C to continue ",
    "C")
   IF (cnvtupper(work->prompt_answer) != "C")
    CALL status("User selected not to run Lock Manager manually.")
    CALL kick("Lock Manager not started!")
   ELSE
    CALL status("Checking for Lock Manager...")
    SELECT INTO "nl:"
     FROM v$session v
     WHERE v.username="V500"
      AND v.client_info="LOCK DAEMON"
     WITH nocounter
    ;end select
    IF (curqual)
     SET dos_lock_mgr = 1
     CALL status("Lock Manager is running.")
    ELSE
     SET dos_lock_mgr = 0
     CALL status("Lock Manager not found running!")
    ENDIF
    CALL pause(2)
   ENDIF
  ENDWHILE
 ELSEIF ((work->alter_param_ind=1))
  SET work->text = build("rdb alter system set job_queue_processes=",cjob_que_process," go")
  CALL parser(work->text)
 ENDIF
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status("Reorg to temporary tablespace.  Please wait.  This process may take a long time...")
 ELSE
  CALL status("Preparing to modify schema.  Please wait.  This process may take a long time...")
 ENDIF
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (registering reorg process)"))
 ELSE
  CALL status(concat("Preparing to modify schema.  Please wait.  ",
    "This process may take a long time... (registering reorg process)"))
 ENDIF
 CALL proc("RegisterReorg",reorg_id)
 IF ((work->lock_mgr_ind=0))
  IF (reorg_tspace_ind=1
   AND reorg_back_ind=0)
   CALL status(concat("Reorg to temporary tablespace.  Please wait.  ",
     "This process may take a long time... (starting lock manager)"))
  ELSE
   CALL status(concat("Preparing to modify schema.  Please wait.  ",
     "This process may take a long time... (starting lock manager)"))
  ENDIF
  CALL proc("StartLockMgr",reorg_id)
 ENDIF
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (creating reorg objects)"))
 ELSE
  CALL status(concat("Preparing to modify schema.  Please wait.  ",
    "This process may take a long time... (creating reorg objects)"))
 ENDIF
 CALL proc("CreateReorgObjects",reorg_id)
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (creating copy table)"))
 ELSE
  CALL status(concat("Preparing to modify schema.  Please wait.  ",
    "This process may take a long time... (creating copy table)"))
 ENDIF
 CALL proc("CreateTableCopy",reorg_id)
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (creating copy indexes)"))
 ELSE
  CALL status(concat("Preparing to modify schema.  Please wait.  ",
    "This process may take a long time... (creating copy indexes)"))
 ENDIF
 CALL proc("CreateTableObjects",reorg_id)
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (analyzing copy table)"))
 ELSE
  CALL status(concat("Preparing to modify schema.  Please wait.  ",
    "This process may take a long time... (analyzing copy table)"))
 ENDIF
 IF (analyze)
  CALL proc("AnalyzeTable",reorg_id)
 ELSE
  SET work->text = build(substring(1,28,work->table_name),"$C")
  CALL parser(concat("rdb analyze table ",work->text," estimate statistics go"))
 ENDIF
 IF (((reorg_tspace_ind=0) OR (reorg_back_ind=1)) )
  CALL status(
   "Modifying schema.  Please wait.  This process may take a long time... (modifying schema of copy table)"
   )
  CALL dos_install_schema(work->table_name)
  CALL status(
   "Schema changes complete; and clean up tasks.  Please wait.  This process may take a long time..."
   )
 ENDIF
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Wrapping up reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (synch copy table)"))
 ELSE
  CALL status(concat("Wrapping up reorg with schema changes.  Please wait.  ",
    "This process may take a long time... (synch copy table)"))
 ENDIF
 CALL proc("SynchTableCopy",reorg_id)
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Wrapping up reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (switch over tables)"))
 ELSE
  CALL status(concat("Wrapping up reorg with schema changes.  Please wait.  ",
    "This process may take a long time... (switch over tables)"))
 ENDIF
 CALL proc("SwitchOver",reorg_id)
 IF ((((work->lock_mgr_ind=0)) OR (((reorg_tspace_ind=0) OR (reorg_back_ind=1)) )) )
  IF (reorg_tspace_ind=1
   AND reorg_back_ind=0)
   CALL status(concat("Wrapping up reorg to temporary tablespace.  Please wait.  ",
     "This process may take a long time... (kill lock manager)"))
  ELSE
   CALL status(concat("Wrapping up reorg with schema changes.  Please wait.  ",
     "This process may take a long time... (kill lock manager)"))
  ENDIF
  CALL proc("KillLockMgr",reorg_id)
 ENDIF
 IF (reorg_tspace_ind=1
  AND reorg_back_ind=0)
  CALL status(concat("Wrapping up reorg to temporary tablespace.  Please wait.  ",
    "This process may take a long time... (cleanup reorg objects)"))
 ELSE
  CALL status(concat("Wrapping up reorg with schema changes.  Please wait.  ",
    "This process may take a long time... (cleanup reorg objects)"))
 ENDIF
 CALL proc("Cleanup",reorg_id)
 CALL status("Wrapping up schema process.  Please wait.  This process may take a long time...")
 CALL dos_install_schema_util(0)
 IF ((work->alter_param_ind=1))
  SET work->text = build("rdb alter system set job_queue_processes=",work->job_que_process," go")
  CALL parser(work->text)
 ENDIF
 CALL status("")
#2499_reorg_exit
#2500_cleanup
 SET x = 0
 CALL dos_set_userlastupdt(0)
 CALL status(
  "Wrapping up schema process.  Please wait.  This process may take a long time... (clean up table list)"
  )
 IF ((work->ocd > 0))
  DELETE  FROM dm_schema_op_log d
   WHERE (d.table_name=work->table_name)
    AND d.begin_dt_tm = null
    AND d.run_id IN (
   (SELECT
    l.run_id
    FROM dm_schema_log l
    WHERE l.ocd > 0))
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM dm_schema_op_log d
   WHERE (d.run_id=work->run_id)
    AND (d.table_name=work->table_name)
    AND d.begin_dt_tm = null
   WITH nocounter
  ;end delete
 ENDIF
 SET dos_rebuild_list = 1
 COMMIT
#2590_cleanup_exit
 CALL message("Schema changes complete. Reorg process complete.  Press <RETURN> to continue...")
#2599_cleanup_exit
 SUBROUTINE clear_session(cs_dummy)
  DELETE  FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="REORG SESSION"
   WITH nocounter
  ;end delete
  IF (curqual)
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE drop_table(dt_table)
  SELECT INTO "nl:"
   t.table_name
   FROM user_tables t
   WHERE t.table_name=cnvtupper(trim(dt_table,3))
   WITH nocounter
  ;end select
  IF (curqual)
   CALL parser(concat("rdb drop table ",dt_table," go"),1)
  ENDIF
 END ;Subroutine
 SUBROUTINE drop_table_cascade(dt_table)
  SELECT INTO "nl:"
   t.table_name
   FROM user_tables t
   WHERE t.table_name=cnvtupper(trim(dt_table,3))
   WITH nocounter
  ;end select
  IF (curqual)
   CALL parser(concat("rdb drop table ",dt_table," cascade constraints go"),1)
  ENDIF
 END ;Subroutine
 SUBROUTINE drop_trigger(dt_trigger)
  SELECT INTO "nl:"
   t.trigger_name
   FROM user_triggers t
   WHERE t.trigger_name=cnvtupper(trim(dt_trigger,3))
   WITH nocounter
  ;end select
  IF (curqual)
   CALL parser(concat("rdb drop trigger ",dt_trigger," go"),1)
  ENDIF
 END ;Subroutine
 SUBROUTINE kick(k_message)
   SET k_height = 7
   SET k_top = 0
   SET k_top = ((24 - k_height)/ 2)
   SET k_width = (size(trim(k_message,3))+ 6)
   SET k_left = 0
   SET k_left = ((132 - k_width)/ 2)
   SET k_blank = fillstring(value((k_width - 2))," ")
   SET k_text = fillstring(value((k_width - 2))," ")
   CALL box(k_top,k_left,((k_top+ k_height) - 1),((k_left+ k_width) - 1))
   CALL video(r)
   SET k_text = " ERROR"
   CALL text((k_top+ 1),(k_left+ 1),k_text)
   CALL video(n)
   SET k_text = k_blank
   CALL text((k_top+ 2),(k_left+ 1),k_text)
   SET k_text = concat("  ",trim(k_message,3))
   CALL text((k_top+ 3),(k_left+ 1),k_text)
   SET k_text = k_blank
   CALL text((k_top+ 4),(k_left+ 1),k_text)
   CALL video(r)
   SET k_text = " Press <RETURN> to exit..."
   CALL text((k_top+ 5),(k_left+ 1),k_text)
   CALL accept(((k_top+ k_height) - 2),((k_left+ k_width) - 2),"P;C"," ")
   ROLLBACK
   GO TO 9999_exit_program
 END ;Subroutine
 SUBROUTINE list_copy(lc_dummy)
   SET lc_size = size(list->list,5)
   SET stat = alterlist(list2->list,lc_size)
   FOR (lc_i = 1 TO lc_size)
     SET list2->list[lc_i].text = list->list[lc_i].text
   ENDFOR
   SET list2_item = list_item
   SET list2_page = list_page
   SET list2_line = list_line
   SET list2_items = list_items
   SET list2_top = list_top
   SET list2_left = list_left
   SET list2_bottom = list_bottom
   SET list2_right = list_right
   SET list2_width = list_width
   SET list2_more = list_more
 END ;Subroutine
 SUBROUTINE list_down_arrow(da_dummy)
  CALL list_item_line(0)
  IF (list_line < list_page
   AND list_item < list_items)
   CALL list_draw_item(0)
   SET list_item = (list_item+ 1)
  ELSE
   SET da_temp_item = ((list_item - list_line)+ 1)
   IF (da_temp_item != list_item)
    CALL list_draw_item(0)
    SET list_item = da_temp_item
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE list_draw_item(di_highlight)
   FREE RECORD di_temp
   RECORD di_temp(
     1 text = vc
   )
   CALL list_item_line(0)
   IF (di_highlight)
    CALL video(r)
   ELSE
    CALL video(l)
   ENDIF
   IF (list_item <= list_items)
    SET di_temp->text = list->list[list_item].text
   ENDIF
   CALL text(((list_line+ list_top) - 1),list_left,substring(1,list_width,di_temp->text))
   CALL video(n)
 END ;Subroutine
 SUBROUTINE list_draw_page(d_dummy)
   SET dp_save_item = list_item
   CALL list_item_line(0)
   SET dp_temp_item = ((list_item+ list_page) - 1)
   FOR (list_item = list_item TO dp_temp_item)
     CALL list_draw_item(0)
   ENDFOR
   IF (list_more)
    FREE SET dp_text
    IF (dp_save_item > list_page)
     IF (list_item >= list_items)
      SET dp_text = "<< -*    "
     ELSE
      SET dp_text = "<< -*- >>"
     ENDIF
    ELSE
     SET dp_text = "    *- >>"
    ENDIF
    SET dp_size = size(dp_text)
    CALL text(list_bottom,(list_left+ ((list_width - dp_size)/ 2)),dp_text)
   ENDIF
   SET list_item = dp_save_item
 END ;Subroutine
 SUBROUTINE list_init(i_dummy)
   SET list_page = ((list_bottom - list_top)+ 1)
   SET list_width = ((list_right - list_left)+ 1)
   SET list_items = size(list->list,5)
   IF (list_items > list_page)
    SET list_page = (list_page - 1)
    SET list_more = 1
   ELSE
    SET list_more = 0
   ENDIF
   IF ( NOT (list_item))
    SET list_item = 1
   ENDIF
   SET i_save_item = list_item
   CALL list_item_line(0)
   SET list_item = ((list_item - list_line)+ 1)
   CALL list_draw_page(0)
   SET list_item = i_save_item
 END ;Subroutine
 SUBROUTINE list_item_line(il_dummy)
  SET list_line = mod(list_item,list_page)
  IF ( NOT (list_line))
   SET list_line = list_page
  ENDIF
 END ;Subroutine
 SUBROUTINE list_page_down(pd_dummy)
   CALL list_item_line(0)
   SET pd_temp_item = (((list_item - list_line)+ 1)+ list_page)
   IF (pd_temp_item <= list_items)
    SET list_item = pd_temp_item
    CALL list_draw_page(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE list_page_up(pu_dummy)
   IF (list_item > list_page)
    CALL list_item_line(0)
    SET list_item = (((list_item - list_line)+ 1) - list_page)
    CALL list_draw_page(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE list_restore(lr_dummy)
   SET lr_size = size(list2->list,5)
   SET stat = alterlist(list->list,lr_size)
   FOR (lr_i = 1 TO lr_size)
     SET list->list[lr_i].text = list2->list[lr_i].text
   ENDFOR
   SET stat = alterlist(list2->list,0)
   SET list_item = list2_item
   SET list_page = list2_page
   SET list_line = list2_line
   SET list_items = list2_items
   SET list_top = list2_top
   SET list_left = list2_left
   SET list_bottom = list2_bottom
   SET list_right = list2_right
   SET list_width = list2_width
   SET list_more = list2_more
 END ;Subroutine
 SUBROUTINE list_up_arrow(ua_dummy)
  CALL list_item_line(0)
  IF (list_line > 1)
   CALL list_draw_item(0)
   SET list_item = (list_item - 1)
  ELSE
   SET ua_temp_item = ((list_item+ list_page) - 1)
   SET ua_flag = 1
   WHILE (ua_flag)
     IF (((ua_temp_item <= list_item) OR (ua_temp_item <= list_items)) )
      SET ua_flag = 0
     ELSE
      SET ua_temp_item = (ua_temp_item - 1)
     ENDIF
   ENDWHILE
   IF (ua_temp_item != list_item)
    CALL list_draw_item(0)
    SET list_item = ua_temp_item
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE log(l_message)
   CALL echo(l_message)
 END ;Subroutine
 SUBROUTINE message(m_text)
   CALL status(m_text)
   SET m_col = (size(trim(m_text,3))+ 3)
   CALL accept(24,m_col,"P;C"," ")
   CALL clear(24,1)
 END ;Subroutine
 SUBROUTINE dos_prompt(dop_text,dop_default)
   CALL status(dop_text)
   SET dop_col = (size(trim(dop_text,3))+ 3)
   CALL accept(24,dop_col,"P3;C",dop_default)
   SET work->prompt_answer = curaccept
   CALL clear(24,1)
 END ;Subroutine
 SUBROUTINE pad(p_pos,p_text)
   SET p_size = size(trim(work->text))
   FREE SET p_spaces
   IF (((p_size+ 1) < p_pos))
    SET p_spaces = fillstring(value(((p_pos - p_size) - 1))," ")
   ELSE
    SET work->text = substring(1,(p_size - 3),work->text)
    SET p_spaces = "  "
   ENDIF
   IF (p_size)
    SET work->text = concat(work->text,p_spaces,p_text)
   ELSE
    SET work->text = concat(p_spaces,p_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE parameter(p_parm)
  SET work->parameter = ""
  SELECT INTO "nl:"
   p.value
   FROM v$parameter p
   WHERE cnvtupper(p.name)=cnvtupper(p_parm)
   DETAIL
    work->parameter = p.value
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE proc(p_name,p_reorg_id)
   CALL dos_check_session_id(session_id)
   CALL push("declare")
   CALL push("  flag number;")
   CALL push("begin")
   CALL push(concat("  pkg_reorg.",p_name,"(",trim(cnvtstring(p_reorg_id),3),");"))
   CALL push("  commit;")
   CALL push("end;")
   CALL run(0)
   SET p_code = 1
   SET p_mesg = fillstring(130," ")
   SELECT INTO "nl:"
    l.return_code
    FROM reorg_log l
    WHERE l.entry_id IN (
    (SELECT
     max(x.entry_id)
     FROM reorg_log x
     WHERE x.reorg_id=p_reorg_id
      AND cnvtupper(x.procedure_name)=cnvtupper(p_name)))
    DETAIL
     p_code = l.return_code, p_mesg = substring(1,130,l.text)
    WITH nocounter
   ;end select
   IF (p_code)
    CALL status(concat("The process ",cnvtupper(p_name)," returned an error... aborting reorg..."))
    CALL dos_release_lock(0)
    CALL dos_reorg_cleanup(p_reorg_id)
    CALL status(p_mesg)
    CALL kick(concat("The process ",cnvtupper(p_name)," returned an error (",trim(cnvtstring(p_code),
       3),")."))
   ENDIF
 END ;Subroutine
 SUBROUTINE cleanup_aborted_reorg(ar_reorg_id)
   CALL dos_drop_reorg_objects(work->table_name)
   CALL dos_reorg_cleanup(ar_reorg_id)
   CALL dos_deque_table(ar_reorg_id)
   CALL dos_set_userlastupdt(work->userlastupdt)
 END ;Subroutine
 SUBROUTINE dos_release_lock(drl_dummy)
   CALL push("declare")
   CALL push("  ret_flag number;")
   CALL push("begin")
   CALL push("  ret_flag := pkg_lock.ReleaseTableLock;")
   CALL push("  commit;")
   CALL push("end;")
   CALL run(0)
 END ;Subroutine
 SUBROUTINE dos_reorg_cleanup(drc_reorg_id)
   CALL push("declare")
   CALL push("begin")
   CALL push(concat("  pkg_reorg.KillLockMgr(",trim(cnvtstring(drc_reorg_id),3),");"))
   CALL push(concat("  pkg_reorg.CleanUp(",trim(cnvtstring(drc_reorg_id),3),");"))
   CALL push("  commit;")
   CALL push("end;")
   CALL run(0)
 END ;Subroutine
 SUBROUTINE dos_deque_table(ddt_reorg_id)
   CALL push("begin")
   CALL push(concat("  pkg_que.dequetable(",trim(cnvtstring(ddt_reorg_id),3),");"))
   CALL push("  commit;")
   CALL push("end;")
   CALL run(0)
 END ;Subroutine
 SUBROUTINE dos_drop_reorg_objects(dro_tbl_name)
   SET work->text = trim(substring(1,20,dro_tbl_name),3)
   CALL drop_trigger(concat(work->text,"$COPY_TRIG"))
   SET work->text = trim(substring(1,18,dro_tbl_name),3)
   CALL drop_trigger(concat(work->text,"$COPY_TRIG$C"))
   SET work->text = trim(substring(1,21,dro_tbl_name),3)
   CALL drop_trigger(concat(work->text,"$LOG_TRIG"))
   SET work->text = trim(substring(1,19,dro_tbl_name),3)
   CALL drop_trigger(concat(work->text,"$LOG_TRIG$C"))
   SET work->text = trim(substring(1,28,dro_tbl_name),3)
   CALL drop_table_cascade(concat(work->text,"$C"))
   SET work->text = trim(substring(1,20,dro_tbl_name),3)
   CALL drop_table(concat(work->text,"$REORG_LOG"))
 END ;Subroutine
 SUBROUTINE push(p_text)
   SET p_i = (size(work->buffer,5)+ 1)
   SET stat = alterlist(work->buffer,p_i)
   SET work->buffer[p_i].text = p_text
 END ;Subroutine
 SUBROUTINE redisplay(r_dummy)
   CALL video(l)
   CALL text(9,18,new_info->tablespace_name)
   CALL text(10,18,cnvtstring(new_info->initial_extent))
   CALL text(11,18,cnvtstring(new_info->next_extent))
   CALL text(12,18,cnvtstring(new_info->min_extents))
   CALL text(13,18,cnvtstring(new_info->max_extents))
   CALL text(14,18,cnvtstring(new_info->pct_increase))
   CALL text(15,18,cnvtstring(new_info->pct_free))
   CALL text(16,18,cnvtstring(new_info->pct_used))
   CALL text(10,83,cnvtstring(new_info->freelists))
   CALL text(11,83,cnvtstring(new_info->freelist_groups))
   CALL text(12,83,new_info->parallel_degree)
   CALL text(13,83,new_info->instances)
   CALL text(14,83,new_info->cash)
   CALL text(15,83,cnvtstring(new_info->ini_trans))
   CALL text(16,83,cnvtstring(new_info->max_trans))
   CALL video(n)
 END ;Subroutine
 SUBROUTINE reorg_id(ri_table)
   SET ri_id = 0.0
   SELECT INTO "nl:"
    ri_temp_id = max(o.reorg_id)
    FROM reorg_objects o
    WHERE o.table_name=ri_table
    DETAIL
     ri_id = ri_temp_id
    WITH nocounter
   ;end select
   RETURN(ri_id)
 END ;Subroutine
 SUBROUTINE run(r_dummy)
   FREE RECORD r_temp
   RECORD r_temp(
     1 text = vc
   )
   SET run_err_num = 0
   SET run_err_msg = fillstring(132," ")
   SET run_err_num = error(run_err_msg,1)
   FOR (r_i = 1 TO size(work->buffer,5))
     IF (r_i=1)
      SET r_temp->text = "rdb asis(^"
     ELSE
      SET r_temp->text = "asis(^"
     ENDIF
     SET r_temp->text = concat(r_temp->text,work->buffer[r_i].text,"^)")
     CALL parser(r_temp->text,1)
   ENDFOR
   CALL parser("end go",1)
   SET run_err_num = error(run_err_msg,0)
   IF (run_err_num > 0)
    SET dos_err_msg = substring((findstring("{}",run_err_msg)+ 2),130,run_err_msg)
   ENDIF
   SET dos_err_num = run_err_num
   SET stat = alterlist(work->buffer,0)
   RETURN(run_err_num)
 END ;Subroutine
 SUBROUTINE status(s_text)
  CALL clear(24,1)
  IF (size(trim(s_text,3)))
   CALL text(24,2,s_text)
  ENDIF
 END ;Subroutine
 SUBROUTINE draw_main_banner(dmb_env_id)
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL text(2,3,"O N L I N E   S C H E M A")
   IF (dmb_env_id > 0)
    SET work->text = ""
    SELECT INTO "nl:"
     e.environment_name
     FROM dm_environment e
     WHERE e.environment_id=dmb_env_id
      AND trim(e.environment_name,3) > " "
     DETAIL
      work->text = concat("Environment: ",cnvtupper(trim(e.environment_name,3)))
     WITH nocounter
    ;end select
    SET dmb_pos = size(work->text)
    IF (dmb_pos)
     SET dmb_pos = ((132 - dmb_pos) - 1)
     CALL text(2,dmb_pos,work->text)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE draw_table_banner(dm_dummy)
   CALL clear(4,1)
   IF ((work->table_name > " "))
    CALL text(4,3,"Table: ")
    CALL video(l)
    CALL text(4,10,work->table_name)
    CALL video(n)
    IF ((work->ocd > 0))
     CALL text(4,45,"OCD: ")
     CALL video(l)
     CALL text(4,50,trim(cnvtstring(work->ocd)))
     CALL video(n)
    ELSE
     CALL text(4,45,"Schema Date: ")
     CALL video(l)
     CALL text(4,58,trim(format(work->schema_date,"DD-MMM-YYYY;;D")))
     CALL video(n)
    ENDIF
   ENDIF
   IF (reorg_id > 0.0)
    SET work->text = concat("Reorg ID: ",trim(cnvtstring(reorg_id)))
    CALL text(4,(131 - size(work->text)),"Reorg ID: ")
    CALL video(l)
    CALL text(4,((131 - size(work->text))+ 10),cnvtstring(reorg_id))
    CALL video(n)
   ENDIF
   CALL line(5,2,130)
 END ;Subroutine
 SUBROUTINE dos_install_schema(dos_tbl_name)
   CALL dos_check_session_id(session_id)
   SET docd_reply->status = "F"
   SET work->text = build(substring(1,28,dos_tbl_name),"$C")
   CALL parser(concat("execute oragen3 '",trim(work->text),"' go"))
   IF ((work->ocd > 0))
    SET dos_tgt_schema_str = cnvtstring(work->ocd)
   ELSE
    SET dos_tgt_schema_str = format(work->schema_date,"DD-MMM-YYYY;;D")
   ENDIF
   EXECUTE dm_install_schema3 dos_tbl_name, dos_tgt_schema_str, "online"
   CALL draw_main_banner(environment_id)
   CALL draw_table_banner(0)
   IF ((docd_reply->status != "S"))
    CALL status("Schema changes were unsuccessful!  Please wait.  Aborting reorg process...")
    CALL cleanup_aborted_reorg(reorg_id)
    CALL status("Schema changes were unsuccessful!")
    CASE (docd_reply->status)
     OF "F":
      CALL kick(docd_reply->err_msg)
     OF "C":
      CALL kick(docd_reply->err_msg)
     ELSE
      CALL kick(build("Unknown return status (",docd_reply->status,") from dm_install_schema3!"))
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE dos_install_schema_util(dos_dummy)
   CALL status(
    "Wrapping up schema process.  Please wait.  This process may take a long time... (compile invalid objects)"
    )
   EXECUTE dm_compile_objects work->table_name, "TABLE"
   CALL parser(concat("oragen3 '",trim(work->table_name),"' go"))
 END ;Subroutine
 SUBROUTINE draw_segment_list_banner(dm_dummy)
   CALL clear(6,1)
   CALL text(6,60,"Daily")
   CALL text(6,106,"Initial")
   CALL text(6,125,"Next")
   CALL clear(7,1)
   CALL text(7,5,"Segment")
   CALL text(7,41,"Used Space")
   CALL text(7,59,"Growth")
   CALL text(7,67,"Tablespace")
   CALL text(7,107,"Extent")
   CALL text(7,123,"Extent")
   CALL clear(8,1)
   CALL line(8,2,130)
   CALL clear(9,1)
 END ;Subroutine
 SUBROUTINE draw_segment_banner(dsb_segment_idx)
   CALL clear(6,1)
   IF ((work->segment_name > " "))
    CALL text(6,3,"Segment: ")
    CALL video(l)
    CALL text(6,12,work->segment_name)
    CALL video(n)
   ENDIF
   IF ((work->segment_type > " "))
    CALL text(6,114,"Type: ")
    CALL video(l)
    CALL text(6,120,work->segment_type)
    CALL video(n)
   ENDIF
   CALL line(7,2,130)
 END ;Subroutine
 SUBROUTINE draw_segment_fields(dsf_segment_idx)
   CALL clear(8,1)
   IF (((reorg_tspace_ind) OR (segments->segment[dsf_segment_idx].temp_reorg_tspace)) )
    CALL text(9,2," >  Tablespace: ")
   ELSE
    CALL text(9,2,"    Tablespace: ")
   ENDIF
   CALL text(10,2,"Initial Extent: ")
   CALL text(10,40,"Bytes")
   CALL text(11,2,"   Next Extent: ")
   CALL text(11,40,"Bytes")
   CALL text(12,2,"   Min Extents: ")
   CALL text(13,2,"   Max Extents: ")
   CALL text(14,2,"  Pct Increase: ")
   CALL text(15,2,"      Pct Free: ")
   CALL text(16,2,"      Pct Used: ")
   CALL text(10,60,"            Freelists: ")
   CALL text(11,60,"      Freelist Groups: ")
   CALL text(12,60,"Degree of Parallelism: ")
   CALL text(13,60,"            Instances: ")
   CALL text(14,60,"                Cache: ")
   CALL text(15,60,"            Ini Trans: ")
   CALL text(16,60,"            Max Trans: ")
   CALL clear(17,1)
   CALL clear(18,1)
   CALL clear(19,1)
   IF (segments->segment[dsf_segment_idx].need_check
    AND (segments->segment[dsf_segment_idx].temp_reorg_tspace=0))
    CALL text(18,2,concat("(?) - ",segments->segment[dsf_segment_idx].message1))
    CALL text(19,2,concat("      ",segments->segment[dsf_segment_idx].message2))
   ELSEIF ((segments->segment[dsf_segment_idx].valid=0))
    CALL text(18,2,concat("(*) - ",segments->segment[dsf_segment_idx].message1))
    CALL text(19,2,concat("      ",segments->segment[dsf_segment_idx].message2))
   ENDIF
   IF (reorg_tspace_setup)
    IF (reorg_tspace_ind)
     CALL clear(20,1)
     CALL clear(21,1)
     CALL text(21,2,
      "(>) Cannot modify tablespace name when temporary reorg tablespaces are being used.")
    ELSE
     IF (segments->segment[dsf_segment_idx].temp_reorg_tspace)
      CALL clear(20,1)
      CALL clear(21,1)
      CALL text(21,2,"(>) Please modify tablespace name to original tablespace name.")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dos_load_segment_info(lsi_reorg_id)
   SET si = 0
   IF (reorg_tspace_ind)
    IF (reorg_back_ind)
     FOR (si = 1 TO orig_segments->segment_count)
       UPDATE  FROM reorg_segments s
        SET s.tablespace_name = orig_segments->segment[si].tablespace_name, s.initial_extent =
         orig_segments->segment[si].initial_extent, s.next_extent = orig_segments->segment[si].
         next_extent,
         s.min_extents = orig_segments->segment[si].min_extents, s.max_extents = orig_segments->
         segment[si].max_extents, s.pct_increase = orig_segments->segment[si].pct_increase,
         s.pct_free = evaluate(orig_segments->segment[si].pct_free,0,null,orig_segments->segment[si].
          pct_free), s.pct_used = evaluate(orig_segments->segment[si].pct_used,0,null,orig_segments->
          segment[si].pct_used), s.freelists = orig_segments->segment[si].freelists,
         s.freelist_groups = orig_segments->segment[si].freelist_groups, s.degree = evaluate(
          orig_segments->segment[si].parallel_degree," ",null,orig_segments->segment[si].
          parallel_degree), s.instances = evaluate(orig_segments->segment[si].instances," ",null,
          orig_segments->segment[si].instances),
         s.cash = evaluate(orig_segments->segment[si].cash," ",null,orig_segments->segment[si].cash),
         s.ini_trans = orig_segments->segment[si].ini_trans, s.max_trans = orig_segments->segment[si]
         .max_trans
        WHERE s.reorg_id=lsi_reorg_id
         AND (s.original_name=orig_segments->segment[si].new_segment_name)
         AND (s.object_type=orig_segments->segment[si].object_type)
         AND cnvtupper(s.original_flag)="N"
        WITH nocounter
       ;end update
       COMMIT
       SET work->text = " "
       IF ((orig_segments->segment[si].object_type="INDEX")
        AND (orig_segments->segment[si].tablespace_name != work->reorg_index_tspace))
        SET work->text = orig_segments->segment[si].tablespace_name
       ENDIF
     ENDFOR
     SELECT INTO "nl:"
      FROM reorg_segments s
      WHERE s.reorg_id=lsi_reorg_id
       AND s.object_type="INDEX"
       AND (s.tablespace_name=work->reorg_index_tspace)
       AND cnvtupper(s.original_flag)="N"
      WITH nocounter
     ;end select
     IF (curqual)
      UPDATE  FROM reorg_segments s
       SET s.tablespace_name = work->text
       WHERE s.reorg_id=lsi_reorg_id
        AND s.object_type="INDEX"
        AND (s.tablespace_name=work->reorg_index_tspace)
        AND cnvtupper(s.original_flag)="N"
       WITH nocounter
      ;end update
      COMMIT
     ENDIF
    ELSE
     UPDATE  FROM reorg_segments s
      SET s.tablespace_name = work->reorg_data_tspace
      WHERE s.reorg_id=lsi_reorg_id
       AND s.object_type="TABLE"
       AND cnvtupper(s.original_flag)="N"
      WITH nocounter
     ;end update
     UPDATE  FROM reorg_segments s
      SET s.tablespace_name = work->reorg_index_tspace
      WHERE s.reorg_id=lsi_reorg_id
       AND s.object_type="INDEX"
       AND cnvtupper(s.original_flag)="N"
      WITH nocounter
     ;end update
     COMMIT
    ENDIF
   ENDIF
   SELECT
    IF (reorg_tspace_ind)INTO "nl:"
     s.object_name, tspace = n.tablespace_name, init_ext = n.initial_extent,
     next_ext = n.next_extent, max_exts = n.max_extents, min_exts = n.min_extents,
     pct_increase = n.pct_increase, pct_free = n.pct_free, pct_used = n.pct_used,
     flists = n.freelists, fgroups = n.freelist_groups, degree = n.degree,
     inst = n.instances, cash = n.cash, ini_trans = n.ini_trans,
     max_trans = n.max_trans
     FROM reorg_segments s,
      reorg_segments n
     PLAN (s
      WHERE s.reorg_id=lsi_reorg_id
       AND (s.object_name=work->table_name)
       AND cnvtupper(s.original_flag)="O")
      JOIN (n
      WHERE n.reorg_id=s.reorg_id
       AND n.original_name=s.object_name
       AND cnvtupper(n.original_flag)="N")
    ELSE INTO "nl:"
     s.object_name, tspace = s.tablespace_name, init_ext = s.initial_extent,
     next_ext = s.next_extent, max_exts = s.max_extents, min_exts = s.min_extents,
     pct_increase = s.pct_increase, pct_free = s.pct_free, pct_used = s.pct_used,
     flists = s.freelists, fgroups = s.freelist_groups, degree = s.degree,
     inst = s.instances, cash = s.cash, ini_trans = s.ini_trans,
     max_trans = s.max_trans
     FROM reorg_segments s
     WHERE s.reorg_id=lsi_reorg_id
      AND (s.object_name=work->table_name)
      AND cnvtupper(s.original_flag)="O"
    ENDIF
    DETAIL
     segment_count = (segment_count+ 1), stat = alterlist(segments->segment,segment_count), segments
     ->segment[segment_count].segment_name = cnvtupper(trim(s.object_name,3)),
     segments->segment[segment_count].object_type = cnvtupper(trim(s.object_type,3)), segments->
     segment[segment_count].initial_extent = cnvtreal(init_ext), segments->segment[segment_count].
     next_extent = cnvtreal(next_ext),
     segments->segment[segment_count].tablespace_name = cnvtupper(trim(tspace,3)), segments->segment[
     segment_count].max_extents = max_exts, segments->segment[segment_count].next_extent_cnt = 0,
     segments->segment[segment_count].min_extents = min_exts, segments->segment[segment_count].
     pct_increase = pct_increase, segments->segment[segment_count].pct_free = pct_free,
     segments->segment[segment_count].pct_used = pct_used, segments->segment[segment_count].freelists
      = flists, segments->segment[segment_count].freelist_groups = fgroups,
     segments->segment[segment_count].parallel_degree = degree, segments->segment[segment_count].
     instances = inst, segments->segment[segment_count].cash = cash,
     segments->segment[segment_count].ini_trans = ini_trans, segments->segment[segment_count].
     max_trans = max_trans
    WITH nocounter
   ;end select
   SELECT
    IF (reorg_tspace_ind)INTO "nl:"
     s.object_name, tspace = n.tablespace_name, init_ext = n.initial_extent,
     next_ext = n.next_extent, max_exts = n.max_extents, min_exts = n.min_extents,
     pct_increase = n.pct_increase, pct_free = n.pct_free, pct_used = n.pct_used,
     flists = n.freelists, fgroups = n.freelist_groups, degree = n.degree,
     inst = n.instances, cash = n.cash, ini_trans = n.ini_trans,
     max_trans = n.max_trans
     FROM reorg_segments s,
      reorg_segments n
     PLAN (s
      WHERE s.reorg_id=lsi_reorg_id
       AND s.primary_key_flag="P"
       AND cnvtupper(s.original_flag)="O")
      JOIN (n
      WHERE n.reorg_id=s.reorg_id
       AND n.original_name=s.object_name
       AND cnvtupper(n.original_flag)="N")
    ELSE INTO "nl:"
     s.object_name, tspace = s.tablespace_name, init_ext = s.initial_extent,
     next_ext = s.next_extent, max_exts = s.max_extents, min_exts = s.min_extents,
     pct_increase = s.pct_increase, pct_free = s.pct_free, pct_used = s.pct_used,
     flists = s.freelists, fgroups = s.freelist_groups, degree = s.degree,
     inst = s.instances, cash = s.cash, ini_trans = s.ini_trans,
     max_trans = s.max_trans
     FROM reorg_segments s
     PLAN (s
      WHERE s.reorg_id=lsi_reorg_id
       AND s.primary_key_flag="P"
       AND cnvtupper(s.original_flag)="O")
    ENDIF
    DETAIL
     segment_count = (segment_count+ 1), stat = alterlist(segments->segment,segment_count), segments
     ->segment[segment_count].segment_name = cnvtupper(trim(s.object_name,3)),
     segments->segment[segment_count].object_type = cnvtupper(trim(s.object_type,3)), segments->
     segment[segment_count].initial_extent = cnvtreal(init_ext), segments->segment[segment_count].
     next_extent = cnvtreal(next_ext),
     segments->segment[segment_count].tablespace_name = cnvtupper(trim(tspace,3)), segments->segment[
     segment_count].max_extents = max_exts, segments->segment[segment_count].next_extent_cnt = 0,
     segments->segment[segment_count].min_extents = min_exts, segments->segment[segment_count].
     pct_increase = pct_increase, segments->segment[segment_count].pct_free = pct_free,
     segments->segment[segment_count].pct_used = pct_used, segments->segment[segment_count].freelists
      = flists, segments->segment[segment_count].freelist_groups = fgroups,
     segments->segment[segment_count].parallel_degree = degree, segments->segment[segment_count].
     instances = inst, segments->segment[segment_count].cash = cash,
     segments->segment[segment_count].ini_trans = ini_trans, segments->segment[segment_count].
     max_trans = max_trans
    WITH nocounter
   ;end select
   SELECT
    IF (reorg_tspace_ind)INTO "nl:"
     s.object_name, tspace = n.tablespace_name, init_ext = n.initial_extent,
     next_ext = n.next_extent, max_exts = n.max_extents, min_exts = n.min_extents,
     pct_increase = n.pct_increase, pct_free = n.pct_free, pct_used = n.pct_used,
     flists = n.freelists, fgroups = n.freelist_groups, degree = n.degree,
     inst = n.instances, cash = n.cash, ini_trans = n.ini_trans,
     max_trans = n.max_trans
     FROM reorg_segments s,
      reorg_segments n
     PLAN (s
      WHERE s.reorg_id=lsi_reorg_id
       AND (s.object_name != work->table_name)
       AND ((s.primary_key_flag != "P") OR (s.primary_key_flag = null))
       AND cnvtupper(s.original_flag)="O")
      JOIN (n
      WHERE n.reorg_id=s.reorg_id
       AND n.original_name=s.object_name
       AND cnvtupper(n.original_flag)="N")
    ELSE INTO "nl:"
     s.object_name, tspace = s.tablespace_name, init_ext = s.initial_extent,
     next_ext = s.next_extent, max_exts = s.max_extents, min_exts = s.min_extents,
     pct_increase = s.pct_increase, pct_free = s.pct_free, pct_used = s.pct_used,
     flists = s.freelists, fgroups = s.freelist_groups, degree = s.degree,
     inst = s.instances, cash = s.cash, ini_trans = s.ini_trans,
     max_trans = s.max_trans
     FROM reorg_segments s
     PLAN (s
      WHERE s.reorg_id=lsi_reorg_id
       AND (s.object_name != work->table_name)
       AND ((s.primary_key_flag != "P") OR (s.primary_key_flag = null))
       AND cnvtupper(s.original_flag)="O")
    ENDIF
    ORDER BY s.object_name
    DETAIL
     segment_count = (segment_count+ 1), stat = alterlist(segments->segment,segment_count), segments
     ->segment[segment_count].segment_name = cnvtupper(trim(s.object_name,3)),
     segments->segment[segment_count].object_type = cnvtupper(trim(s.object_type,3)), segments->
     segment[segment_count].initial_extent = cnvtreal(s.initial_extent), segments->segment[
     segment_count].next_extent = cnvtreal(s.next_extent),
     segments->segment[segment_count].initial_extent = cnvtreal(init_ext), segments->segment[
     segment_count].next_extent = cnvtreal(next_ext), segments->segment[segment_count].
     tablespace_name = cnvtupper(trim(tspace,3)),
     segments->segment[segment_count].max_extents = max_exts, segments->segment[segment_count].
     next_extent_cnt = 0, segments->segment[segment_count].min_extents = min_exts,
     segments->segment[segment_count].pct_increase = pct_increase, segments->segment[segment_count].
     pct_free = pct_free, segments->segment[segment_count].pct_used = pct_used,
     segments->segment[segment_count].freelists = flists, segments->segment[segment_count].
     freelist_groups = fgroups, segments->segment[segment_count].parallel_degree = degree,
     segments->segment[segment_count].instances = inst, segments->segment[segment_count].cash = cash,
     segments->segment[segment_count].ini_trans = ini_trans,
     segments->segment[segment_count].max_trans = max_trans
    WITH nocounter
   ;end select
   FOR (si = 1 TO segment_count)
     SET segments->segment[si].need_check = 1
     SET segments->segment[si].message1 =
     "Segment sizing parameters need to be checked against the free space"
     SET segments->segment[si].message2 = " currently available in the database."
     SET segments->segment[si].valid = 1
   ENDFOR
 END ;Subroutine
 SUBROUTINE dos_save_segment_info(ssi_reorg_id)
   SET orig_segments->segment_count = segment_count
   SET stat = alterlist(orig_segments->segment,orig_segments->segment_count)
   SELECT INTO "nl:"
    FROM reorg_segments s
    WHERE s.reorg_id=ssi_reorg_id
     AND s.original_flag="O"
    HEAD REPORT
     seg_cnt = 0
    DETAIL
     seg_cnt = (seg_cnt+ 1)
     IF ((seg_cnt > orig_segments->segment_count))
      orig_segments->segment_count = seg_cnt, stat = alterlist(orig_segments->segment,orig_segments->
       segment_count)
     ENDIF
     orig_segments->segment[seg_cnt].segment_name = s.object_name, orig_segments->segment[seg_cnt].
     object_type = s.object_type, orig_segments->segment[seg_cnt].tablespace_name = s.tablespace_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM reorg_segments s,
     (dummyt d  WITH seq = value(orig_segments->segment_count))
    PLAN (d)
     JOIN (s
     WHERE s.reorg_id=ssi_reorg_id
      AND s.original_flag="N"
      AND (s.original_name=orig_segments->segment[d.seq].segment_name))
    DETAIL
     orig_segments->segment[d.seq].new_segment_name = s.object_name, orig_segments->segment[d.seq].
     new_tablespace_name = s.tablespace_name, orig_segments->segment[d.seq].new_ind = 0,
     orig_segments->segment[d.seq].initial_extent = cnvtreal(s.initial_extent), orig_segments->
     segment[d.seq].next_extent = cnvtreal(s.next_extent), orig_segments->segment[d.seq].max_extents
      = s.max_extents,
     orig_segments->segment[d.seq].min_extents = s.min_extents, orig_segments->segment[d.seq].
     pct_increase = s.pct_increase, orig_segments->segment[d.seq].pct_free = s.pct_free,
     orig_segments->segment[d.seq].pct_used = s.pct_used, orig_segments->segment[d.seq].freelists = s
     .freelists, orig_segments->segment[d.seq].freelist_groups = s.freelist_groups,
     orig_segments->segment[d.seq].parallel_degree = s.degree, orig_segments->segment[d.seq].
     instances = s.instances, orig_segments->segment[d.seq].cash = s.cash,
     orig_segments->segment[d.seq].ini_trans = s.ini_trans, orig_segments->segment[d.seq].max_trans
      = s.max_trans
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dos_map_reorg_tspace(mrt_dummy)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(orig_segments->segment_count))
    HEAD REPORT
     tspace_fnd = 0, ti = 0, map_tspace->tspace_cnt = 0,
     stat = alterlist(map_tspace->tspace,0)
    DETAIL
     tspace_fnd = 0
     FOR (ti = 1 TO map_tspace->tspace_cnt)
       IF ((map_tspace->tspace[ti].tablespace_name=orig_segments->segment[d.seq].tablespace_name))
        tspace_fnd = ti, ti = map_tspace->tspace_cnt
       ENDIF
     ENDFOR
     IF ( NOT (tspace_fnd))
      map_tspace->tspace_cnt = (map_tspace->tspace_cnt+ 1), stat = alterlist(map_tspace->tspace,
       map_tspace->tspace_cnt), map_tspace->tspace[map_tspace->tspace_cnt].tablespace_name =
      orig_segments->segment[d.seq].tablespace_name,
      map_tspace->tspace[map_tspace->tspace_cnt].user_map_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info i,
     (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
    PLAN (d)
     JOIN (i
     WHERE i.info_domain="TABLESPACE MAPPING"
      AND (i.info_name=map_tspace->tspace[d.seq].tablespace_name))
    DETAIL
     map_tspace->tspace[d.seq].user_map_ind = 1, map_tspace->tspace[d.seq].user_map_tspace = trim(i
      .info_char,3)
    WITH nocounter
   ;end select
   DELETE  FROM dm_info i,
     (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
    SET i.seq = 1
    PLAN (d
     WHERE (map_tspace->tspace[d.seq].user_map_ind=1))
     JOIN (i
     WHERE i.info_domain="TABLESPACE MAPPING"
      AND (i.info_name=map_tspace->tspace[d.seq].tablespace_name))
    WITH nocounter
   ;end delete
   COMMIT
   INSERT  FROM dm_info i,
     (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
    SET i.seq = 1, i.info_domain = "TABLESPACE MAPPING", i.info_name = map_tspace->tspace[d.seq].
     tablespace_name,
     i.info_char = work->reorg_data_tspace
    PLAN (d
     WHERE substring(1,2,map_tspace->tspace[d.seq].tablespace_name)="D_")
     JOIN (i)
    WITH nocounter
   ;end insert
   INSERT  FROM dm_info i,
     (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
    SET i.seq = 1, i.info_domain = "TABLESPACE MAPPING", i.info_name = map_tspace->tspace[d.seq].
     tablespace_name,
     i.info_char = work->reorg_index_tspace
    PLAN (d
     WHERE substring(1,2,map_tspace->tspace[d.seq].tablespace_name)="I_")
     JOIN (i)
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE dos_unmap_reorg_tspace(mrt_dummy)
   SELECT INTO "nl:"
    FROM dm_info i,
     (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
    PLAN (d)
     JOIN (i
     WHERE i.info_domain="TABLESPACE MAPPING"
      AND (i.info_name=map_tspace->tspace[d.seq].tablespace_name)
      AND i.info_char IN (work->reorg_data_tspace, work->reorg_index_tspace))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    DELETE  FROM dm_info i,
      (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
     SET i.seq = 1
     PLAN (d)
      JOIN (i
      WHERE i.info_domain="TABLESPACE MAPPING"
       AND (i.info_name=map_tspace->tspace[d.seq].tablespace_name)
       AND i.info_char IN (work->reorg_data_tspace, work->reorg_index_tspace))
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
   INSERT  FROM dm_info i,
     (dummyt d  WITH seq = value(map_tspace->tspace_cnt))
    SET i.seq = 1, i.info_domain = "TABLESPACE MAPPING", i.info_name = map_tspace->tspace[d.seq].
     tablespace_name,
     i.info_char = map_tspace->tspace[d.seq].user_map_tspace
    PLAN (d
     WHERE (map_tspace->tspace[d.seq].user_map_ind=1))
     JOIN (i)
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE dos_check_segment_size(css_reorg_id)
   SET css_all_valid = 1
   CALL status("Checking segment sizes...")
   FREE RECORD temp_space
   RECORD temp_space(
     1 tablespace_name = vc
     1 initial_extent = f8
     1 next_extent = f8
     1 max_extents = f8
     1 contents = vc
     1 total_size = f8
     1 max_free = f8
     1 total_free = f8
     1 chunk[*]
       2 bytes = f8
     1 chunk_cnt = i4
   )
   SELECT INTO "nl:"
    u.tablespace_name
    FROM dba_users u
    WHERE u.username=currdbuser
    DETAIL
     temp_space->tablespace_name = u.temporary_tablespace
    WITH nocounter
   ;end select
   IF ( NOT (curqual))
    CALL kick("Unable to locate the temporary tablespace for the RDB user.")
   ENDIF
   SELECT INTO "nl:"
    t.initial_extent
    FROM dba_tablespaces t
    WHERE (t.tablespace_name=temp_space->tablespace_name)
    DETAIL
     temp_space->tablespace_name = t.tablespace_name, temp_space->initial_extent = t.initial_extent,
     temp_space->next_extent = t.next_extent,
     temp_space->max_extents = t.max_extents, temp_space->contents = t.contents
    WITH nocounter
   ;end select
   SET dm_sort_area = 0.0
   SET dm_sort_area = ((10.0 * 1024.0) * 1024.0)
   SELECT INTO "nl:"
    FROM v$parameter v
    WHERE v.name="sort_area_size"
    DETAIL
     dm_sort_area = cnvtreal(v.value)
    WITH nocounter
   ;end select
   IF ((dm_sort_area > temp_space->next_extent))
    SET work->text = concat("rdb alter tablespace ",trim(temp_space->tablespace_name),
     " default storage (next ",trim(cnvtstring(dm_sort_area)),") go")
    CALL parser(work->text,1)
   ENDIF
   SET work->text = concat("rdb alter tablespace ",trim(temp_space->tablespace_name)," coalesce go")
   CALL parser(work->text,1)
   SELECT INTO "nl:"
    f.bytes
    FROM dba_free_space f
    WHERE (f.tablespace_name=temp_space->tablespace_name)
    ORDER BY f.bytes
    HEAD REPORT
     temp_space->max_free = 0, temp_space->total_free = 0, stat = alterlist(temp_space->chunk,0),
     temp_space->chunk_cnt = 0
    DETAIL
     temp_space->chunk_cnt = (temp_space->chunk_cnt+ 1), stat = alterlist(temp_space->chunk,
      temp_space->chunk_cnt), temp_space->chunk[temp_space->chunk_cnt].bytes = f.bytes,
     temp_space->total_free = (temp_space->total_free+ f.bytes), temp_space->max_free = f.bytes
    WITH nocounter
   ;end select
   FOR (i = 1 TO segment_count)
     SET segments->segment[i].valid = 1
     SET segments->segment[i].message1 = ""
     SET segments->segment[i].message2 = ""
     SET segments->segment[i].temp_reorg_tspace = 0
   ENDFOR
   FREE RECORD spaces
   RECORD spaces(
     1 space[*]
       2 tablespace_name = vc
       2 max_free = f8
       2 total_free = f8
       2 chunk[*]
         3 bytes = f8
       2 chunk_cnt = i4
   )
   SET space_count = 0
   SELECT INTO "nl:"
    s.tablespace_name
    FROM reorg_segments s
    WHERE s.reorg_id=css_reorg_id
     AND cnvtupper(s.original_flag)="N"
    ORDER BY s.tablespace_name
    HEAD s.tablespace_name
     space_count = (space_count+ 1), stat = alterlist(spaces->space,space_count), spaces->space[
     space_count].tablespace_name = s.tablespace_name,
     spaces->space[space_count].chunk_cnt = 0, stat = alterlist(spaces->space[space_count].chunk,0)
    DETAIL
     spaces->space[space_count].total_free = 0.0
    WITH nocounter
   ;end select
   FOR (ti = 1 TO space_count)
    SET work->text = concat("rdb alter tablespace ",trim(spaces->space[ti].tablespace_name),
     " coalesce go")
    CALL parser(work->text,1)
   ENDFOR
   SELECT INTO "nl:"
    f.bytes
    FROM (dummyt d  WITH seq = value(space_count)),
     dba_free_space f
    PLAN (d)
     JOIN (f
     WHERE (f.tablespace_name=spaces->space[d.seq].tablespace_name))
    ORDER BY f.tablespace_name, f.bytes
    DETAIL
     spaces->space[d.seq].max_free = f.bytes, spaces->space[d.seq].total_free = (spaces->space[d.seq]
     .total_free+ f.bytes), spaces->space[d.seq].chunk_cnt = (spaces->space[d.seq].chunk_cnt+ 1),
     stat = alterlist(spaces->space[d.seq].chunk,spaces->space[d.seq].chunk_cnt), spaces->space[d.seq
     ].chunk[spaces->space[d.seq].chunk_cnt].bytes = f.bytes
    WITH nocounter
   ;end select
   FOR (i = 1 TO space_count)
     FOR (j = 1 TO segment_count)
       IF ((segments->segment[j].tablespace_name=spaces->space[i].tablespace_name))
        IF (reorg_tspace_setup
         AND reorg_tspace_ind=0)
         IF ((((segments->segment[j].tablespace_name=work->reorg_data_tspace)) OR ((segments->
         segment[j].tablespace_name=work->reorg_index_tspace))) )
          SET segments->segment[j].temp_reorg_tspace = 1
         ENDIF
        ENDIF
        SET seg_total_size = 0.0
        SET seg_total_size = segments->segment[j].total_space
        SET seg_init_extent = 0.0
        SET seg_init_extent = segments->segment[j].initial_extent
        SET seg_next_extent = 0.0
        SET seg_next_extent = segments->segment[j].next_extent
        SET rem_obj_size = 0.0
        SET max_chunk = 0.0
        SET max_ci = 0
        FOR (ci = 1 TO spaces->space[i].chunk_cnt)
          IF ((spaces->space[i].chunk[ci].bytes > max_chunk))
           SET max_chunk = spaces->space[i].chunk[ci].bytes
           SET max_ci = ci
          ENDIF
        ENDFOR
        IF (seg_init_extent > max_chunk)
         SET segments->segment[j].valid = 0
         SET segments->segment[j].message1 = concat("Space required to create initial extent (",trim(
           format(seg_init_extent,"##############;L,"),3)," bytes) in this tablespace")
         SET segments->segment[j].message2 = concat("exceeds the largest free chunk (",trim(format(
            max_chunk,"##############;L,"),3)," bytes).")
        ELSE
         SET spaces->space[i].chunk[max_ci].bytes = (spaces->space[i].chunk[max_ci].bytes -
         seg_init_extent)
         SET rem_obj_size = (seg_total_size - seg_init_extent)
        ENDIF
        IF (segments->segment[j].valid)
         SET next_ext_cnt = 0
         SET next_ext_rem = 0
         WHILE (rem_obj_size > 0)
           SET max_chunk = 0.0
           SET max_ci = 0
           FOR (ci = 1 TO spaces->space[i].chunk_cnt)
             IF ((spaces->space[i].chunk[ci].bytes > max_chunk))
              SET max_chunk = spaces->space[i].chunk[ci].bytes
              SET max_ci = ci
             ENDIF
           ENDFOR
           IF (seg_next_extent > max_chunk)
            SET next_ext_rem = (cnvtint((rem_obj_size/ seg_next_extent))+ 1)
            SET rem_obj_size = 0.0
            SET segments->segment[j].valid = 0
            SET segments->segment[j].message1 = concat("Space required to create (",trim(cnvtstring(
               next_ext_rem)),") next extents (",trim(format(seg_next_extent,"##############;L,"),3),
             " bytes) in this tablespace not found.")
            SET segments->segment[j].message2 = concat("After using (",trim(cnvtstring(next_ext_cnt)),
             ") next extents,"," largest free chunk available is ",trim(format(max_chunk,
               "##############;L,"),3),
             " bytes.")
           ELSE
            SET rem_obj_size = (rem_obj_size - seg_next_extent)
            SET spaces->space[i].chunk[max_ci].bytes = (spaces->space[i].chunk[max_ci].bytes -
            seg_next_extent)
            SET next_ext_cnt = (next_ext_cnt+ 1)
           ENDIF
         ENDWHILE
         IF ((segments->segment[j].max_extents > 0))
          IF (segments->segment[j].valid
           AND (next_ext_cnt > segments->segment[j].max_extents))
           SET segments->segment[j].valid = 0
           SET segments->segment[j].message1 = concat("Number of extents (",trim(cnvtstring(
              next_ext_cnt),3),") required to create object")
           SET segments->segment[j].message2 = concat("in this tablespace exceeds max extents (",trim
            (cnvtstring(segments->segment[j].max_extents),3),").")
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   FOR (i = 1 TO segment_count)
     IF (segments->segment[i].valid
      AND (segments->segment[i].object_type="INDEX"))
      FREE RECORD temp_spc
      RECORD temp_spc(
        1 chunk[*]
          2 bytes = f8
        1 chunk_cnt = i4
      )
      SET temp_spc->chunk_cnt = temp_space->chunk_cnt
      SET stat = alterlist(temp_spc->chunk,temp_spc->chunk_cnt)
      FOR (ti = 1 TO temp_spc->chunk_cnt)
        SET temp_spc->chunk[ti].bytes = temp_space->chunk[ti].bytes
      ENDFOR
      SET seg_total_size = 0.0
      SET seg_total_size = segments->segment[i].used_space
      SET seg_init_extent = 0.0
      SET seg_init_extent = segments->segment[i].initial_extent
      SET seg_next_extent = 0.0
      SET seg_next_extent = segments->segment[i].next_extent
      SET rem_obj_size = 0.0
      SET max_chunk = 0.0
      SET max_ci = 0
      FOR (ci = 1 TO temp_spc->chunk_cnt)
        IF ((temp_spc->chunk[ci].bytes > max_chunk))
         SET max_chunk = temp_spc->chunk[ci].bytes
         SET max_ci = ci
        ENDIF
      ENDFOR
      IF (segments->segment[i].valid
       AND (temp_space->initial_extent > max_chunk))
       SET segments->segment[i].valid = 0
       SET segments->segment[i].message1 = concat("Space required to create initial extent (",trim(
         format(temp_space->initial_extent,"##############;L,"),3)," bytes) in temporary tablespace")
       SET segments->segment[i].message2 = concat("exceeds the largest free chunk (",trim(format(
          max_chunk,"##############;L,"),3)," bytes).")
      ELSE
       SET temp_spc->chunk[max_ci].bytes = (temp_spc->chunk[max_ci].bytes - temp_space->
       initial_extent)
       SET rem_obj_size = (seg_total_size - temp_space->initial_extent)
      ENDIF
      IF (segments->segment[i].valid)
       SET next_ext_cnt = 0
       SET next_ext_rem = 0
       WHILE (rem_obj_size > 0)
         SET max_chunk = 0.0
         SET max_ci = 0
         FOR (ci = 1 TO temp_spc->chunk_cnt)
           IF ((temp_spc->chunk[ci].bytes > max_chunk))
            SET max_chunk = temp_spc->chunk[ci].bytes
            SET max_ci = ci
           ENDIF
         ENDFOR
         IF ((temp_space->next_extent > max_chunk))
          SET next_ext_rem = (cnvtint((rem_obj_size/ temp_space->next_extent))+ 1)
          SET rem_obj_size = 0.0
          SET segments->segment[i].valid = 0
          SET segments->segment[i].message1 = concat("Space required to create (",trim(cnvtstring(
             next_ext_rem)),") next extents (",trim(format(temp_space->next_extent,
             "##############;L,"),3)," bytes) in temporary tablespace not found.")
          SET segments->segment[i].message2 = concat("After using (",trims(cnvtstring(next_ext_cnt)),
           ") next extents,"," largest free chunk available is ",trim(format(max_chunk,
             "##############;L,"),3),
           " bytes.")
         ELSE
          SET rem_obj_size = (rem_obj_size - temp_space->next_extent)
          SET temp_spc->chunk[max_ci].bytes = (temp_spc->chunk[max_ci].bytes - temp_space->
          next_extent)
          SET next_ext_cnt = (next_ext_cnt+ 1)
         ENDIF
       ENDWHILE
       IF ((temp_space->max_extents > 0))
        IF (segments->segment[i].valid
         AND (next_ext_cnt > temp_space->max_extents))
         SET segments->segment[i].valid = 0
         SET segments->segment[i].message1 = concat("Number of extents (",trim(cnvtstring(
            next_ext_cnt),3),") required to create ","segment in temporary tablespace")
         SET segments->segment[i].message2 = concat("exceeds max extents (",trim(cnvtstring(
            temp_space->max_extents),3),").")
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (i = 1 TO segment_count)
     IF ((segments->segment[i].valid=0))
      SET css_all_valid = 0
     ENDIF
     SET segments->segment[i].need_check = 0
     IF ((segments->segment[i].temp_reorg_tspace=1))
      SET segments->segment[i].need_check = 1
     ENDIF
   ENDFOR
   RETURN(css_all_valid)
 END ;Subroutine
 SUBROUTINE dos_build_table_list(btl_dummy)
   SET btl_cnt = 0
   SET stat = alterlist(tbls->tbl,0)
   SELECT INTO "nl:"
    o.table_name, l.gen_dt_tm
    FROM dm_schema_op_log o,
     dm_schema_log l
    WHERE (l.run_id=work->run_id)
     AND o.run_id=l.run_id
     AND o.table_name > " "
     AND findstring("$C",o.table_name)=0
     AND o.begin_dt_tm = null
     AND o.op_type IN (cadd_not_null, ccreate_index)
     AND  NOT ( EXISTS (
    (SELECT
     x.table_name
     FROM dm_schema_op_log x
     WHERE x.table_name=o.table_name
      AND x.run_id=o.run_id
      AND x.end_dt_tm = null
      AND x.op_type IN (ccreate_table, ccreate_unique_index, cadd_primary_key))))
     AND  NOT (o.table_name IN (
    (SELECT
     x.table_name
     FROM user_tab_columns x
     WHERE x.data_type="LONG*")))
    ORDER BY o.table_name, l.gen_dt_tm DESC
    HEAD o.table_name
     fnd = 0
     FOR (ti = 1 TO btl_cnt)
       IF ((tbls->tbl[ti].name=cnvtupper(trim(o.table_name,3))))
        fnd = ti, ti = btl_cnt
       ENDIF
     ENDFOR
     IF (fnd=0)
      btl_cnt = (btl_cnt+ 1), stat = alterlist(tbls->tbl,btl_cnt), tbls->tbl[btl_cnt].name =
      cnvtupper(trim(o.table_name,3)),
      tbls->tbl[btl_cnt].run_id = l.run_id
      IF (l.ocd > 0)
       tbls->tbl[btl_cnt].ocd = l.ocd
      ELSE
       tbls->tbl[btl_cnt].ocd = 0, tbls->tbl[btl_cnt].schema_date = cnvtdatetime(l.schema_date)
      ENDIF
     ENDIF
    DETAIL
     IF ((tbls->tbl[btl_cnt].ocd=l.ocd))
      CASE (o.op_type)
       OF cadd_not_null:
        tbls->tbl[btl_cnt].add_not_null = (tbls->tbl[btl_cnt].add_not_null+ 1)
       OF ccreate_index:
        tbls->tbl[btl_cnt].create_index = (tbls->tbl[btl_cnt].create_index+ 1)
      ENDCASE
      tbls->tbl[btl_cnt].downtime = (tbls->tbl[btl_cnt].downtime+ o.est_duration)
      IF ((o.row_cnt > tbls->tbl[btl_cnt].rows))
       tbls->tbl[btl_cnt].rows = o.row_cnt
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF ((work->ocd > 0)
    AND btl_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(btl_cnt)),
      dm_afd_tables o
     PLAN (d
      WHERE d.seq > 0)
      JOIN (o
      WHERE (o.table_name=tbls->tbl[d.seq].name))
     ORDER BY o.schema_date
     DETAIL
      tbls->tbl[d.seq].schema_date = cnvtdatetime(o.schema_date)
     WITH nocounter
    ;end select
   ENDIF
   RETURN(btl_cnt)
 END ;Subroutine
 SUBROUTINE dos_check_session_id(csi_sid)
   SET csi_session_id = 0.0
   SET csi_session_id = dos_get_session_id(0)
   IF (csi_session_id > 0)
    IF (csi_session_id != csi_sid)
     CALL kick(concat("Unable to continue becuase session ID has changed! (",trim(cnvtstring(csi_sid)
        )," to ",trim(cnvtstring(csi_session_id)),")"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dos_get_session_id(gsi_dummy)
   SET gsi_session_id = 0.0
   SELECT INTO "nl:"
    s_id = sqlpassthru("userenv('sessionid')",0)
    FROM dual
    DETAIL
     gsi_session_id = s_id
    WITH nocounter
   ;end select
   RETURN(gsi_session_id)
 END ;Subroutine
 SUBROUTINE dos_fix_userlastupdt(dfu_dummy)
   SET work->userlastupdt = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="USERLASTUPDT"
    DETAIL
     work->userlastupdt = cnvtdatetime(d.info_date)
    WITH nocounter
   ;end select
   IF (curqual)
    UPDATE  FROM dm_info u
     SET u.info_date =
      (SELECT
       c.info_date
       FROM dm_info c
       WHERE c.info_domain="DATA MANAGEMENT"
        AND c.info_name="CMB_LAST_UPDT")
     PLAN (u
      WHERE u.info_domain="DATA MANAGEMENT"
       AND u.info_name="USERLASTUPDT")
     WITH nocounter
    ;end update
   ELSE
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CMB_LAST_UPDT"
     DETAIL
      work->userlastupdt = cnvtdatetime(d.info_date)
     WITH nocounter
    ;end select
    INSERT  FROM dm_info d
     SET info_domain = "DATA MANAGEMENT", info_name = "USERLASTUPDT", info_date = cnvtdatetime(work->
       userlastupdt)
     WITH nocounter
    ;end insert
    SET work->userlastupdt = cnvtdatetime(curdate,curtime3)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE dos_set_userlastupdt(dsu_date)
  IF (dsu_date=0)
   UPDATE  FROM dm_info d
    SET d.info_date = cnvtdatetime(curdate,curtime3)
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="USERLASTUPDT"
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM dm_info d
    SET d.info_date = cnvtdatetime(dsu_date)
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="USERLASTUPDT"
    WITH nocounter
   ;end update
  ENDIF
  COMMIT
 END ;Subroutine
 SUBROUTINE dos_check_ora_param(cop_dummy)
   CALL status("Checking init.ora parameters...")
   CALL parameter("JOB_QUEUE_PROCESSES")
   SET work->job_que_process = cnvtint(work->parameter)
   CALL parameter("JOB_QUEUE_INTERVAL")
   SET work->job_que_interval = cnvtint(work->parameter)
   CALL parameter("JOB_QUEUE_KEEP_CONNECTIONS")
   SET work->job_que_keep_con = cnvtupper(work->parameter)
   IF ((((work->ora_version=7)
    AND (((work->job_que_process < cjob_que_process)) OR ((((work->job_que_interval >
   cjob_que_interval)) OR ((work->job_que_keep_con="TRUE"))) )) ) OR ((work->ora_version=8)
    AND (work->job_que_interval > cjob_que_interval))) )
    CALL dos_ora_param_blurb(0)
    CALL dos_prompt(
     "INIT.ORA parameters are not setup correctly. Do you wish to use manual alternative? ","Y")
    IF (cnvtupper(work->prompt_answer)="Y")
     SET work->ora_param_ind = 1
     SET work->lock_mgr_ind = 1
     SET work->alter_param_ind = 0
    ELSE
     GO TO 9999_exit_program
    ENDIF
   ELSEIF ((work->ora_version=8)
    AND (work->job_que_process < cjob_que_process)
    AND (work->job_que_interval <= cjob_que_interval))
    CALL dos_ora_param_blurb(0)
    CALL dos_prompt(concat("INIT.ORA parameter JOB_QUEUE_PROCESSES must be ",trim(cnvtstring(
        cjob_que_process))," or higher. Alter parameter for this session? "),"Y")
    IF (cnvtupper(work->prompt_answer)="Y")
     SET work->ora_param_ind = 1
     SET work->lock_mgr_ind = 0
     SET work->alter_param_ind = 1
    ELSE
     GO TO 9999_exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dos_ora_param_blurb(opb_dummy)
   CALL clear(4,1)
   CALL text(5,2,"The reorg process requires the following init.ora parameters to be set up.")
   CALL text(6,7,concat("JOB_QUEUE_PROCESSES needs to be more than or equal to ",trim(cnvtstring(
       cjob_que_process))))
   CALL text(7,7,concat("JOB_QUEUE_INTERVAL needs to be less than or equal to ",trim(cnvtstring(
       cjob_que_interval))))
   IF ((work->ora_version=7))
    CALL text(8,7,concat("JOB_QUEUE_KEEP_CONNECTIONS needs to be ",trim(cjob_que_keep_con)))
   ENDIF
   CALL text(10,2,"The current values for these init.ora parameters are:")
   CALL text(11,7,concat("JOB_QUEUE_PROCESSES = ",trim(cnvtstring(work->job_que_process))))
   CALL text(12,7,concat("JOB_QUEUE_INTERVAL = ",trim(cnvtstring(work->job_que_interval))))
   IF ((work->ora_version=7))
    CALL text(13,7,concat("JOB_QUEUE_KEEP_CONNECTIONS = ",trim(work->job_que_keep_con)))
   ENDIF
 END ;Subroutine
#9999_exit_program
 IF ( NOT (validate(checking_session,0)))
  CALL clear_session(0)
 ENDIF
 CALL clear(1,1)
#exit_script
END GO

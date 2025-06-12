CREATE PROGRAM dba_manage_ref:dba
 PAINT
 SET message = noinformation
 SET trace = nocost
#initial_start
 SET env_id2 = 9999
 SET db_name2 = fillstring(10," ")
 SET db_sid = fillstring(10," ")
 SET db_link2 = fillstring(10," ")
 SET db_sid_temp = fillstring(10," ")
 SET old_env_id2 = 9999
 SET old_db_name2 = fillstring(10," ")
 SET old_db_sid2 = fillstring(10," ")
 SET old_db_link2 = fillstring(10," ")
 SET db_sid_temp = fillstring(10," ")
 SET instance_cd2 = 9999
 SET instance_name2 = fillstring(10," ")
 SET node_address2 = fillstring(10," ")
 SET max_inst_cd = 0
 SET db_inst_cd2 = 0
 SET del_env_id = fillstring(20," ")
 SET parser_buffer[3] = fillstring(100," ")
 SET db_link_check = "N"
 SET db_link_fail = "N"
 SET target_user = fillstring(20," ")
 SET target_pass = fillstring(20," ")
 SET target_tns = fillstring(20," ")
 SET cnt = 0
 SET inst_id[100] = 0
 SET xx = initarray(inst_id,0)
 FREE RECORD rep_seq
 RECORD rep_seq(
   1 qual[*]
     2 report_seq = f8
 )
#initial_stop
#main
 EXECUTE FROM initial_start TO initial_stop
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,25,"***   ADMIN Maintenance   ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(07,15,"1.  Ref_Instance_id Table Maintenance.")
 CALL text(08,15,"2.  Purge Report Data.")
 CALL text(21,22,"Your Selection (0 to Exit) ? ")
 CALL accept(21,53,"9;",0
  WHERE curaccept IN (1, 2, 0))
 SET option = curaccept
 IF (option=0)
  GO TO 999_end
 ENDIF
 CALL clear(1,1)
 CASE (option)
  OF 1:
   EXECUTE FROM main_admin_maint TO main_admin_maint_end
  OF 2:
   EXECUTE FROM main_purge TO main_purge_end
  ELSE
   GO TO main
 ENDCASE
#main_end
#main_admin_maint
 EXECUTE FROM initial_start TO initial_stop
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   Manage REF_INSTANCE_ID Table   ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(07,15,"1.  View Ref_Instance_Id table.")
 CALL text(08,15,"2.  Add new row to Ref_Instance_Id table.")
 CALL text(09,15,"3.  Modify Existing Ref_Instance_Id row.")
 CALL text(10,15,"4.  Delete Existing Ref_Instance_Id row.")
 CALL text(11,15,"5.  Verify Database Links.")
 CALL text(21,22,"Your Selection (0 to Exit) ? ")
 CALL accept(21,53,"9;",0
  WHERE curaccept IN (1, 2, 3, 4, 5,
  0))
 SET option = curaccept
 IF (option=0)
  GO TO 999_end
 ENDIF
 CALL clear(1,1)
 CASE (option)
  OF 1:
   EXECUTE FROM view_start TO view_end
  OF 2:
   EXECUTE FROM add_start TO add_end
  OF 3:
   EXECUTE FROM modify_start TO modify_end
  OF 4:
   EXECUTE FROM delete_start TO delete_end
  OF 5:
   EXECUTE FROM verify_links TO verify_links_end
  ELSE
   GO TO main_admin_maint
 ENDCASE
 GO TO main_admin_maint
#main_admin_maint_end
#main_purge
 EXECUTE FROM initial_start TO initial_stop
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,22,"***   PURGE DBA REPORT DATA   ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(07,15,"1.  Purge gathered Space Summary data.")
 CALL text(08,15,"2.  Purge gathered Performance data.")
 CALL text(09,15,"3.  Purge gathered Analyze data.")
 CALL text(12,15,"Purges will only delete data stored in the ADMIN database")
 CALL text(13,15,"for the corresponding Reports.")
 CALL text(21,22,"Your Selection (0 to Exit) ? ")
 CALL accept(21,53,"9;",0
  WHERE curaccept IN (1, 2, 3, 0))
 SET option = curaccept
 IF (option=0)
  GO TO 999_end
 ENDIF
 CALL clear(1,1)
 CASE (option)
  OF 1:
   EXECUTE FROM purge_space_start TO purge_space_end
  OF 2:
   EXECUTE FROM purge_perform_start TO purge_perform_end
  OF 3:
   EXECUTE FROM purge_analyze_start TO purge_analyze_end
  ELSE
   GO TO main_purge
 ENDCASE
 GO TO main_purge
#main_purge_end
#view_start
 SELECT INTO mine
  *
  FROM ref_instance_id
  ORDER BY instance_cd
 ;end select
 GO TO main_admin_maint
#view_end
#add_start
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   ADD ROW TO REF_INSTANCE_ID TABLE   ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(05,05,"PLEASE ENTER ENVIRONMENT_ID <HELP>:")
 CALL text(07,05,"DB_NAME:")
 CALL text(09,05,"DATABASE SID:")
 CALL text(11,05,"DB_LINK_NAME:")
 SELECT INTO "nl:"
  dm.environment_id, dm.database_name
  FROM dm_environment dm,
   dummyt d,
   ref_instance_id ref
  PLAN (dm
   WHERE dm.environment_id > 0)
   JOIN (d)
   JOIN (ref
   WHERE dm.environment_id=ref.environment_id)
  ORDER BY dm.database_name
  WITH outerjoin = d, dontexist, nocounter
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(08,20,"**************************************")
  CALL text(09,20,"* All Environments from DM_ENV_MAINT *")
  CALL text(10,20,"* have been Added!                   *")
  CALL text(11,20,"**************************************")
  CALL pause(10)
  CALL video(n)
  GO TO main_admin_maint
 ENDIF
 SET help = pos(7,25,15,40)
 SET help =
 SELECT INTO "nl:"
  dm.environment_id, dm.database_name
  FROM dm_environment dm,
   dummyt d,
   ref_instance_id ref
  PLAN (dm
   WHERE dm.environment_id > 0)
   JOIN (d)
   JOIN (ref
   WHERE dm.environment_id=ref.environment_id)
  ORDER BY dm.database_name
  WITH outerjoin = d, dontexist, nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  dm.environment_id
  FROM dm_environment dm
  WHERE dm.environment_id=curaccept
 ;end select
 SET validate = 2
 CALL accept(5,40,"99999999.99;f")
 SET env_id2 = curaccept
 SET help = off
 SET validate = off
 SELECT INTO "nl:"
  dm.environment_id, dm.database_name
  FROM dm_environment dm
  WHERE dm.environment_id=env_id2
  DETAIL
   db_name2 = cnvtupper(dm.database_name)
  WITH nocounter
 ;end select
 CALL text(07,15,db_name2)
 SET db_sid_temp = concat(trim(db_name2),"1")
 CALL accept(09,19,"XXXXXXXXXX;CU",db_sid_temp)
 SET db_sid = curaccept
 CALL accept(11,19,"XXXXXXXXXX;CU",db_sid)
 SET db_link2 = curaccept
#decision_add
 CALL text(19,45,"Correct (Y/N)? or X=Exit:")
 CALL accept(19,71,"A;CU")
 SET answer = curaccept
 IF (answer="N")
  GO TO add_start
 ELSEIF (answer="Y")
  CALL clear(23,01,80)
  CALL video(b)
  CALL text(23,1,"Working . . .")
  CALL video(n)
  GO TO add_body
 ELSEIF (answer="X")
  GO TO main_admin_maint
 ELSE
  GO TO decision_add
 ENDIF
#add_body
 SELECT INTO "nl:"
  large = max(instance_cd)
  FROM ref_instance_id
  DETAIL
   max_inst_cd = (large+ 1)
  WITH nocounter
 ;end select
 INSERT  FROM ref_instance_id
  SET instance_cd = max_inst_cd, instance_name = db_sid, db_name = db_name2,
   node_address = db_link2, environment_id = env_id2
 ;end insert
 COMMIT
#add_check_link
 SELECT INTO "nl:"
  db_link
  FROM dba_db_links
  WHERE db_link=concat(cnvtupper(db_link2),".WORLD")
 ;end select
 IF (curqual=0)
  SET db_link_check = "N"
 ELSE
  SET db_link_check = "Y"
 ENDIF
 IF (db_link_check="Y")
  SET parser_buffer[1] = 'Select into "nl:"'
  SET parser_buffer[2] = concat(" * from V$DATABASE@",trim(db_link2))
  SET parser_buffer[3] = " go"
  FOR (y = 1 TO 3)
    CALL parser(parser_buffer[y])
  ENDFOR
  IF (curqual=0)
   SET db_link_fail = "Y"
  ELSE
   SET db_link_fail = "N"
  ENDIF
 ENDIF
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   ADD ROW TO REF_INSTANCE_ID TABLE   ***")
 CALL clear(3,2,78)
 CALL video(n)
 IF (db_link_fail="Y"
  AND db_link_check="Y")
  CALL text(05,17,"The Database Link Exists, But Appears to Fail ....")
  CALL text(06,17,"        Check Listener Configuration")
 ENDIF
 IF (db_link_fail="N"
  AND db_link_check="Y")
  CALL text(05,05,"The Database Link Exists and is Functional!!")
 ENDIF
 IF (db_link_check="N")
  CALL text(05,05,"The Database Link Does NOT Exist.")
  CALL text(07,05,"Target Database Username:")
  CALL text(09,05,"Target Database Password:")
  CALL text(11,05,"Target Database TNS Name:")
  CALL accept(07,50,"P(20);CU","V500")
  SET target_user = curaccept
  CALL accept(09,50,"P(20);CU","V500")
  SET target_pass = curaccept
  CALL accept(11,50,"P(20);CU",db_link2)
  SET target_tns = curaccept
  SET parser_buffer[1] = "rdb create public database link "
  SET parser_buffer[2] = concat(trim(db_link2)," connect to ",trim(target_user))
  SET parser_buffer[3] = concat(" identified by ",trim(target_pass)," using '",trim(target_tns),
   "' go")
  FOR (y = 1 TO 3)
    CALL parser(parser_buffer[y])
  ENDFOR
  GO TO add_check_link
 ENDIF
 CALL text(19,45,"Hit Any Key to Continue")
 CALL accept(19,71,"P;CU"," ")
 SET answer = curaccept
 GO TO main_admin_maint
#add_body_end
#add_end
#modify_start
 CALL clear(1,1)
 CALL video(r)
 CALL clear(2,2,78)
 CALL clear(3,2,78)
 CALL clear(4,4,76)
 CALL box(4,1,18,40)
 CALL box(1,1,4,80)
 CALL text(2,14,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL text(5,3,"EXISTING REF_INSTANCE_ID VALUES:")
 CALL video(n)
 CALL text(07,03,"ENVIRONMENT_ID <HELP>:")
 CALL text(09,03,"DB_NAME:")
 CALL text(11,03,"DATABASE SID:")
 CALL text(13,03,"DB_LINK_NAME:")
 CALL video(r)
 CALL box(4,41,18,80)
 CALL text(5,43,"MODIFIED REF_INSTANCE_ID VALUES:")
 CALL video(n)
 CALL text(07,43,"ENVIRONMENT_ID <HELP>:")
 CALL text(09,43,"DB_NAME:")
 CALL text(11,43,"DATABASE SID:")
 CALL text(13,43,"DB_LINK_NAME:")
#mod_help
 SET curhelp = 0
 SET help = pos(9,25,15,40)
 SET help =
 SELECT INTO "nl:"
  ref.environment_id, ref.db_name
  FROM ref_instance_id ref
  ORDER BY ref.db_name
  HEAD REPORT
   help_cnt = 1
  DETAIL
   col 0, ref.environment_id, col 15,
   ref.db_name, inst_id[help_cnt] = ref.instance_cd, help_cnt = (help_cnt+ 1),
   row + 1
  WITH check, nocounter, maxrow = 1
 ;end select
 CALL accept(7,25,"99999999.99;f")
 SET old_env_id2 = curaccept
 IF (curhelp=0)
  GO TO mod_help
 ENDIF
 SET instance_cd2 = inst_id[curhelp]
 SET curhelp = 0
 SET help = off
 SELECT INTO "nl:"
  ref.db_name, ref.instance_name, ref.node_address
  FROM ref_instance_id ref
  WHERE ref.environment_id=old_env_id2
   AND ref.instance_cd=instance_cd2
  DETAIL
   old_db_name2 = cnvtupper(ref.db_name), old_db_link2 = cnvtupper(ref.node_address), old_db_sid2 =
   cnvtupper(ref.instance_name)
  WITH nocounter
 ;end select
 CALL text(9,25,old_db_name2)
 CALL text(11,25,old_db_sid2)
 CALL text(13,25,old_db_link2)
 SET help = pos(9,25,15,40)
 SET help =
 SELECT INTO "nl:"
  dm.environment_id, dm.database_name
  FROM dm_environment dm
  ORDER BY dm.database_name
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  dm.environment_id
  FROM dm_environment dm
  WHERE dm.environment_id=curaccept
 ;end select
 SET validate = 2
 CALL accept(7,66,"99999999.99",old_env_id2)
 SET env_id2 = curaccept
 SET help = off
 SET validate = off
 CALL accept(09,66,"XXXXXXXXXX;CU",old_db_name2)
 SET db_name2 = trim(curaccept)
 SET db_sid_temp = concat(trim(db_name2),"1")
 CALL accept(11,66,"XXXXXXXXXX;CU",old_db_sid2)
 SET db_sid = curaccept
 CALL accept(13,66,"XXXXXXXXXX;CU",old_db_link2)
 SET db_link2 = curaccept
#decision_modify
 CALL text(19,45,"Correct (Y/N)? or X=Exit:")
 CALL accept(19,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO modify_start
 ELSEIF (answer="X")
  GO TO main_admin_maint
 ELSE
  CALL clear(23,01,80)
  CALL video(b)
  CALL text(23,1,"Working . . .")
  CALL video(n)
  GO TO modify_body_start
 ENDIF
#modify_body_start
 UPDATE  FROM ref_instance_id
  SET environment_id = env_id2, db_name = db_name2, instance_name = db_sid,
   node_address = db_link2
  WHERE environment_id=old_env_id2
   AND cnvtupper(db_name)=cnvtupper(old_db_name2)
   AND cnvtupper(instance_name)=cnvtupper(old_db_sid2)
   AND cnvtupper(node_address)=cnvtupper(old_db_link2)
   AND instance_cd=instance_cd2
 ;end update
 COMMIT
#modify_check_link
 SELECT INTO "nl:"
  db_link
  FROM dba_db_links
  WHERE db_link=concat(cnvtupper(db_link2),".WORLD")
 ;end select
 IF (curqual=0)
  SET db_link_check = "N"
 ELSE
  SET db_link_check = "Y"
 ENDIF
 IF (db_link_check="Y")
  SET parser_buffer[1] = 'Select into "nl:"'
  SET parser_buffer[2] = concat(" * from V$DATABASE@",trim(db_link2))
  SET parser_buffer[3] = " go"
  FOR (y = 1 TO 3)
    CALL parser(parser_buffer[y])
  ENDFOR
  IF (curqual=0)
   SET db_link_fail = "Y"
  ELSE
   SET db_link_fail = "N"
  ENDIF
 ENDIF
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,14,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,78)
 CALL video(n)
 IF (db_link_fail="Y"
  AND db_link_check="Y")
  CALL text(05,05,"The Database Link Exists, But Appears to Fail ....")
  CALL text(06,05,"        Check Listener Configuration")
 ENDIF
 IF (db_link_fail="N"
  AND db_link_check="Y")
  CALL text(05,05,"The Database Link Exists and is Functional!!")
 ENDIF
 IF (db_link_check="N")
  CALL text(05,05,"The Database Link Does NOT Exist.")
  CALL text(07,05,"Target Database Username:")
  CALL text(09,05,"Target Database Password:")
  CALL text(11,05,"Target Database TNS Name:")
  CALL accept(07,50,"P(20);CU","V500")
  SET target_user = curaccept
  CALL accept(09,50,"P(20);CU","V500")
  SET target_pass = curaccept
  CALL accept(11,50,"P(20);CU",db_link2)
  SET target_tns = curaccept
  SET parser_buffer[1] = "rdb create public database link "
  SET parser_buffer[2] = concat(trim(db_link2)," connect to ",trim(target_user))
  SET parser_buffer[3] = concat(" identified by ",trim(target_pass)," using '",trim(target_tns),
   "' go")
  FOR (y = 1 TO 3)
    CALL parser(parser_buffer[y])
  ENDFOR
  GO TO modify_check_link
 ENDIF
 CALL text(19,45,"Hit Any Key to Continue")
 CALL accept(19,71,"P;CU"," ")
 SET answer = curaccept
#modify_body_end
 GO TO main_admin_maint
#modify_end
#delete_start
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,14,"***   DELETE A ROW FROM REF_INSTANCE_ID TABLE   ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(05,05,"PLEASE ENTER ENVIRONMENT_ID <HELP>:")
 CALL text(07,05,"DB_NAME:")
 CALL text(09,05,"DATABASE SID:")
 CALL text(11,05,"DB_LINK_NAME:")
#del_help
 SET xx = initarray(inst_id,0)
 SET curhelp = 0
 SET help = pos(7,25,15,40)
 SET help =
 SELECT INTO "nl:"
  ref.environment_id, ref.db_name
  FROM ref_instance_id ref
  ORDER BY ref.db_name
  HEAD REPORT
   help_cnt = 1
  DETAIL
   col 0, ref.environment_id, col 15,
   ref.db_name, inst_id[help_cnt] = ref.instance_cd, help_cnt = (help_cnt+ 1),
   row + 1
  WITH check, nocounter, maxrow = 1
 ;end select
 CALL accept(5,40,"99999999.99;f")
 SET env_id2 = curaccept
 SET del_env_id = cnvtstring(env_id2)
 IF (curhelp=0)
  GO TO del_help
 ENDIF
 SET instance_cd2 = inst_id[curhelp]
 SET curhelp = 0
 SET help = off
 SELECT INTO "nl:"
  ref.instance_cd, ref.db_name, ref.instance_name,
  ref.node_address
  FROM ref_instance_id ref
  WHERE ref.environment_id=env_id2
   AND ref.instance_cd=instance_cd2
  DETAIL
   db_name2 = ref.db_name, instance_name2 = ref.instance_name, node_address2 = ref.node_address
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ref.report_seq
  FROM ref_report_parms_log ref
  WHERE ref.parm_cd=1
   AND ref.parm_value=cnvtstring(instance_cd2)
 ;end select
 IF (curqual=0)
  SET exist_flag = "N"
 ELSE
  SET exist_flag = "Y"
 ENDIF
 CALL text(07,15,db_name2)
 CALL text(09,19,instance_name2)
 CALL text(11,19,node_address2)
#decision_delete
 IF (exist_flag="Y")
  CALL video(b)
  CALL text(14,25,"!!!!!      WARNING       !!!!!")
  CALL text(15,25,"DBA Reports exist for this row")
  CALL text(16,25,"on the Ref_Instance_Id  table!")
  CALL video(n)
 ENDIF
 CALL text(19,45,"Correct (Y/N)? or X=Exit:")
 CALL accept(19,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO delete_start
 ELSEIF (answer="X")
  GO TO main_admin_maint
 ELSE
  CALL clear(23,01,80)
  CALL video(b)
  CALL text(23,1,"Working . . .")
  CALL video(n)
  GO TO delete_body_start
 ENDIF
#delete_body_start
 SELECT INTO "nl:"
  ref.report_seq
  FROM ref_report_parms_log ref
  WHERE ref.parm_cd=1
   AND ref.value_seq=1
   AND ref.parm_value=cnvtstring(instance_cd2)
  HEAD REPORT
   cnt = 1
  DETAIL
   IF (cnt >= 1)
    stat = alterlist(rep_seq->qual,(cnt+ 1))
   ENDIF
   rep_seq->qual[cnt].report_seq = ref.report_seq, cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SET total = size(rep_seq->qual,5)
 FOR (cnt = 1 TO total)
   DELETE  FROM space_objects
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM space_files
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM space_log
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_stats
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_latches
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_event
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_files
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_lib
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_dc
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_roll
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_parameter
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_waitstat
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM perf_bckevent
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM ref_report_parms_log
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
   DELETE  FROM ref_report_log
    WHERE (report_seq=rep_seq->qual[cnt].report_seq)
   ;end delete
 ENDFOR
 DELETE  FROM ref_instance_id
  WHERE environment_id=env_id2
 ;end delete
 COMMIT
 GO TO main_admin_maint
#delete_body_end
#delete_end
#purge_space_start
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,22,"***   PURGE SPACE SUMMARY REPORTS   ***")
 CALL clear(3,2,78)
 CALL text(05,05,"PLEASE ENTER REPORT_SEQ <HELP>:")
 CALL text(07,05,"REPORT TYPE:")
 CALL text(09,05,"DATE REPORT ENDED:")
 CALL text(11,05,"USER NOTES:")
 SET report_seq2 = 9999
 SET report_cd2 = 9
 SET end_date2 = fillstring(20," ")
 SET user_notes2 = fillstring(240," ")
 SET distance = 0
 SET first_fourth = 0
 SET second_fourth = 0
 SET third_fourth = 0
 SET final_fourth = 0
 SET first_line = fillstring(60," ")
 SET second_line = fillstring(60," ")
 SET third_line = fillstring(60," ")
 SET final_line = fillstring(60," ")
 SET help = pos(7,10,15,75)
 SET help =
 SELECT INTO "nl:"
  report_seq, end_date, user_notes
  FROM ref_report_log
  WHERE report_cd=1
  ORDER BY report_seq
  WITH nocounter
 ;end select
 CALL accept(5,40,"99999999.99")
 SET report_seq2 = curaccept
 SET help = off
 SELECT INTO "nl:"
  a.report_seq, a.report_cd, a.end_date,
  a.user_notes
  FROM ref_report_log a
  WHERE a.report_seq=report_seq2
  DETAIL
   report_cd2 = a.report_cd, end_date2 = format(a.end_date,"MM/DD/YY;;D"), user_notes2 = a.user_notes
  WITH nocounter
 ;end select
 IF (report_cd2=1)
  CALL text(7,25,"SPACE SUMMARY REPORT")
 ELSEIF (report_cd2=2)
  CALL text(7,25,"SPACE TREND REPORT")
 ELSEIF (report_cd2=3)
  CALL text(7,25,"PERFORMANCE REPORT")
 ELSEIF (report_cd2=4)
  CALL text(7,25,"ANALYZE REPORT")
 ELSE
  CALL text(7,25,"UNKNOWN REPORT")
 ENDIF
 IF (end_date2=null)
  CALL text(9,25,"No End Date Captured--Report Failed or Is In Progress")
 ELSE
  CALL text(9,25,end_date2)
 ENDIF
 SET distance = size(user_notes2,1)
 SET first_fourth = findstring(" ",user_notes2,(distance/ 4))
 SET first_line = substring(1,first_fourth,user_notes2)
 SET second_fourth = findstring(" ",user_notes2,((distance/ 4)+ first_fourth))
 SET second_line = substring(first_fourth,(distance/ 4),user_notes2)
 SET third_fourth = findstring(" ",user_notes2,((distance/ 4)+ second_fourth))
 SET third_line = substring(second_fourth,(distance/ 4),user_notes2)
 SET final_fourth = findstring(" ",user_notes2,((distance/ 4)+ third_fourth))
 SET final_line = substring(third_fourth,final_fourth,user_notes2)
 CALL text(11,18,first_line)
 CALL text(12,17,second_line)
 CALL text(13,17,third_line)
 CALL text(14,17,final_line)
#decision_purge_space
 CALL text(19,45,"Correct (Y/N)? or X=Exit:")
 CALL accept(19,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO purge_space_start
 ELSEIF (answer="X")
  GO TO main_purge
 ENDIF
 CALL clear(23,01,80)
 CALL video(b)
 CALL text(23,1,"Working . . .")
 CALL video(n)
#purge_body_start
 DELETE  FROM space_objects
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM space_files
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM space_log
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM ref_report_parms_log
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM ref_report_log
  WHERE report_seq=report_seq2
 ;end delete
 COMMIT
#purge_space_end
#purge_perform_start
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,22,"***   PURGE PERFORMANCE REPORT DATA   ***")
 CALL clear(3,2,78)
 CALL text(05,05,"PLEASE ENTER REPORT_SEQ <HELP>:")
 CALL text(07,05,"REPORT TYPE:")
 CALL text(09,05,"DATE REPORT ENDED:")
 CALL text(11,05,"USER NOTES:")
 SET report_seq2 = 9999
 SET report_cd2 = 9
 SET end_date2 = fillstring(20," ")
 SET user_notes2 = fillstring(240," ")
 SET distance = 0
 SET first_fourth = 0
 SET second_fourth = 0
 SET third_fourth = 0
 SET final_fourth = 0
 SET first_line = fillstring(60," ")
 SET second_line = fillstring(60," ")
 SET third_line = fillstring(60," ")
 SET final_line = fillstring(60," ")
 SET help = pos(7,10,15,75)
 SET help =
 SELECT INTO "nl:"
  report_seq, end_date, user_notes
  FROM ref_report_log
  WHERE report_cd=3
  ORDER BY report_seq
  WITH nocounter
 ;end select
 CALL accept(5,40,"99999999.99")
 SET report_seq2 = curaccept
 SET help = off
 SELECT INTO "nl:"
  a.report_seq, a.report_cd, a.end_date,
  a.user_notes
  FROM ref_report_log a
  WHERE a.report_seq=report_seq2
  DETAIL
   report_cd2 = a.report_cd, end_date2 = format(a.end_date,"MM/DD/YY;;D"), user_notes2 = a.user_notes
  WITH nocounter
 ;end select
 IF (report_cd2=1)
  CALL text(7,25,"SPACE SUMMARY REPORT")
 ELSEIF (report_cd2=2)
  CALL text(7,25,"SPACE TREND REPORT")
 ELSEIF (report_cd2=3)
  CALL text(7,25,"PERFORMANCE REPORT")
 ELSEIF (report_cd2=4)
  CALL text(7,25,"ANALYZE REPORT")
 ELSE
  CALL text(7,25,"UNKNOWN REPORT")
 ENDIF
 IF (end_date2=null)
  CALL text(9,25,"No End Date Captured--Report failed or is in progress")
 ELSE
  CALL text(9,25,end_date2)
 ENDIF
 SET distance = size(user_notes2,1)
 SET first_fourth = findstring(" ",user_notes2,(distance/ 4))
 SET first_line = substring(1,first_fourth,user_notes2)
 SET second_fourth = findstring(" ",user_notes2,((distance/ 4)+ first_fourth))
 SET second_line = substring(first_fourth,(distance/ 4),user_notes2)
 SET third_fourth = findstring(" ",user_notes2,((distance/ 4)+ second_fourth))
 SET third_line = substring(second_fourth,(distance/ 4),user_notes2)
 SET final_fourth = findstring(" ",user_notes2,((distance/ 4)+ third_fourth))
 SET final_line = substring(third_fourth,final_fourth,user_notes2)
 CALL text(11,18,first_line)
 CALL text(12,17,second_line)
 CALL text(13,17,third_line)
 CALL text(14,17,final_line)
#decision_purge_perform
 CALL text(19,45,"Correct (Y/N)? or X=Exit:")
 CALL accept(19,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO purge_perform_start
 ELSEIF (answer="X")
  GO TO main_purge
 ELSE
  CALL clear(23,01,80)
  CALL video(b)
  CALL text(23,1,"Working . . .")
  CALL video(n)
 ENDIF
#purge_body_start_3
 DELETE  FROM perf_stats
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_latches
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_event
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_files
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_lib
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_dc
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_roll
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_parameter
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_waitstat
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM perf_bckevent
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM ref_report_parms_log
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM ref_report_log
  WHERE report_seq=report_seq2
 ;end delete
 COMMIT
#purge_perform_end
#purge_analyze_start
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,22,"***   PURGE ANALYZE REPORT DATA   ***")
 CALL clear(3,2,78)
 CALL text(05,05,"PLEASE ENTER REPORT_SEQ <HELP>:")
 CALL text(07,05,"REPORT TYPE:")
 CALL text(09,05,"DATE REPORT ENDED:")
 CALL text(11,05,"USER NOTES:")
 SET report_seq2 = 9999
 SET report_cd2 = 9
 SET end_date2 = fillstring(20," ")
 SET user_notes2 = fillstring(240," ")
 SET distance = 0
 SET first_fourth = 0
 SET second_fourth = 0
 SET third_fourth = 0
 SET final_fourth = 0
 SET first_line = fillstring(60," ")
 SET second_line = fillstring(60," ")
 SET third_line = fillstring(60," ")
 SET final_line = fillstring(60," ")
 SET help = pos(7,10,15,75)
 SET help =
 SELECT INTO "nl:"
  report_seq, end_date, user_notes
  FROM ref_report_log
  WHERE report_cd=4
  ORDER BY report_seq
  WITH nocounter
 ;end select
 CALL accept(5,40,"99999999.99")
 SET report_seq2 = curaccept
 SET help = off
 SELECT INTO "nl:"
  a.report_seq, a.report_cd, a.end_date,
  a.user_notes
  FROM ref_report_log a
  WHERE a.report_seq=report_seq2
  DETAIL
   report_cd2 = a.report_cd, end_date2 = format(a.end_date,"MM/DD/YY;;D"), user_notes2 = a.user_notes
  WITH nocounter
 ;end select
 IF (report_cd2=1)
  CALL text(7,25,"SPACE SUMMARY REPORT")
 ELSEIF (report_cd2=2)
  CALL text(7,25,"SPACE TREND REPORT")
 ELSEIF (report_cd2=3)
  CALL text(7,25,"PERFORMANCE REPORT")
 ELSEIF (report_cd2=4)
  CALL text(7,25,"ANALYZE REPORT")
 ELSE
  CALL text(7,25,"UNKNOWN REPORT")
 ENDIF
 IF (end_date2=null)
  CALL text(9,25,"No End Date Captured--Report failed or is in progress")
 ELSE
  CALL text(9,25,end_date2)
 ENDIF
 SET distance = size(user_notes2,1)
 SET first_fourth = findstring(" ",user_notes2,(distance/ 4))
 SET first_line = substring(1,first_fourth,user_notes2)
 SET second_fourth = findstring(" ",user_notes2,((distance/ 4)+ first_fourth))
 SET second_line = substring(first_fourth,(distance/ 4),user_notes2)
 SET third_fourth = findstring(" ",user_notes2,((distance/ 4)+ second_fourth))
 SET third_line = substring(second_fourth,(distance/ 4),user_notes2)
 SET final_fourth = findstring(" ",user_notes2,((distance/ 4)+ third_fourth))
 SET final_line = substring(third_fourth,final_fourth,user_notes2)
 CALL text(11,18,first_line)
 CALL text(12,17,second_line)
 CALL text(13,17,third_line)
 CALL text(14,17,final_line)
#decision_purge_analyze
 CALL text(19,45,"Correct (Y/N)? or X=Exit:")
 CALL accept(19,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO purge_analyze_start
 ELSEIF (answer="X")
  GO TO main_purge
 ELSE
  CALL clear(23,01,80)
  CALL video(b)
  CALL text(23,1,"Working . . .")
  CALL video(n)
 ENDIF
#purge_body_start_4
 DELETE  FROM space_objects
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM space_log
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM ref_report_parms_log
  WHERE report_seq=report_seq2
 ;end delete
 DELETE  FROM ref_report_log
  WHERE report_seq=report_seq2
 ;end delete
 COMMIT
#purge_analyze_end
#verify_links
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,77)
 CALL text(2,20,"*****   HNA MILLENNIUM   DATABASE TOOLKIT   *****")
 CALL clear(3,2,77)
 CALL text(7,25,"Now will check database links")
#decision_modify_7
 CALL text(21,45,"Continue (Y/N)?")
 CALL accept(21,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  GO TO main_admin_maint
 ENDIF
 CALL clear(23,01,80)
 CALL video(b)
 CALL text(23,1,"Working . . .")
 CALL video(n)
 FREE SET ref_id
 RECORD ref_id(
   1 qual[*]
     2 instance_cd = f8
     2 db_name = c32
     2 instance_name = c32
     2 node_address = c100
     2 delete_flag = c1
     2 env_id = f8
     2 link_fail = c1
 )
 SELECT INTO "nl:"
  ref.instance_cd, ref.db_name, ref.instance_name,
  ref.node_address, ref.environment_id
  FROM ref_instance_id ref
  HEAD REPORT
   cnt = 0, stat = alterlist(ref_id->qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(ref_id->qual,(cnt+ 10))
   ENDIF
   ref_id->qual[cnt].instance_cd = ref.instance_cd, ref_id->qual[cnt].db_name = ref.db_name, ref_id->
   qual[cnt].instance_name = ref.instance_name,
   ref_id->qual[cnt].node_address = ref.node_address, ref_id->qual[cnt].env_id = ref.environment_id
  FOOT REPORT
   stat = alterlist(ref_id->qual,cnt)
 ;end select
 SET total = size(ref_id->qual,5)
 FOR (x = 1 TO total)
   SET parser_buffer[1] = 'Select into "nl:"'
   SET parser_buffer[2] = concat(" * from V$DATABASE@",trim(ref_id->qual[x].node_address))
   SET parser_buffer[3] = " go"
   FOR (y = 1 TO 3)
     CALL parser(parser_buffer[y])
   ENDFOR
   IF (curqual=0)
    SET ref_id->qual[x].link_fail = "Y"
   ELSE
    SET ref_id->qual[x].link_fail = "N"
   ENDIF
 ENDFOR
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,131)
 CALL box(1,1,4,131)
 CALL clear(2,2,128)
 CALL text(2,42,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,130)
 CALL text(06,30,"ENVIRONMENT_ID")
 CALL line(07,30,15)
 CALL text(06,53,"INSTANCE_CD")
 CALL line(07,53,15)
 CALL text(06,73,"Db_Name")
 CALL line(07,73,7)
 CALL text(06,87,"Instance_Name")
 CALL line(07,87,13)
 CALL text(06,105,"Node_Address")
 CALL line(07,105,12)
 CALL text(06,06,"Action Taken")
 CALL line(07,06,12)
 FOR (x = 1 TO total)
   IF ((ref_id->qual[x].link_fail="Y"))
    CALL text((x+ 7),06,"Link Failed")
   ELSE
    CALL text((x+ 7),06,"Link OK")
   ENDIF
   CALL text((x+ 7),37,cnvtstring(ref_id->qual[x].env_id))
   CALL text((x+ 7),60,cnvtstring(ref_id->qual[x].instance_cd))
   CALL text((x+ 7),75,ref_id->qual[x].db_name)
   CALL text((x+ 7),91,ref_id->qual[x].instance_name)
   CALL text((x+ 7),108,trim(ref_id->qual[x].node_address))
 ENDFOR
 CALL text(18,25,"If any of the above links failed, you need to check the LISTENER configuration")
 CALL text(19,25,"and the database link from the ADMIN database to the target database.")
#decision_7
 CALL text(21,45,"Hit Any Key to Continue")
 CALL accept(21,71,"P;CU"," ")
 SET answer = curaccept
 GO TO main_admin_maint
#verify_links_end
#999_end
 CALL clear(1,1)
END GO

CREATE PROGRAM dm_get_dbsize:dba
 PAINT
#initialize
 SET answer = "Y"
 SET instance_cd = 0.0
 SET environment_id = 0.0
 SET owner = fillstring(30," ")
 SET environment_name = fillstring(20," ")
 SET db_name = fillstring(30," ")
 SET client_mnemonic = fillstring(15," ")
 SET prev_report_seq = 0
 SET prev_report_date = fillstring(11," ")
 SET prev_report_notes = fillstring(50," ")
 SET curr_report_seq = 0
 SET curr_report_date = fillstring(11," ")
 SET curr_report_notes = fillstring(50," ")
 SET prev_block_size = 8192
 SET curr_block_size = 8192
 SET new_report_seq = 0
 SET table_name = fillstring(81," ")
 SET status_str = fillstring(46," ")
 SET status_ln = 1
#main
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,22,132)
 CALL line(5,1,132,xhor)
 CALL text(3,46,"***  GET DATABASE SIZE INFORMATION  ***")
 CALL text(7,3,"CLIENT MNEMONIC:")
 CALL text(8,3,"ENVIRONMENT ID <HELP>:")
 CALL text(9,3,"CURRENT (LATEST) REPORT SEQ  <HELP>:")
 CALL text(10,3,"PREVIOUS (2nd LATEST) REPORT SEQ <HELP>:")
 CALL text(11,3,"OWNER <HELP>:")
 CALL box(15,7,20,55)
 CALL clear(16,8,47)
 CALL text(16,8,"Press <SHIFT> <F5> for <HELP>.")
#accept_client_mnemonic
 CALL clear(16,8,47)
 CALL clear(18,8,47)
 CALL text(18,8,"Enter client mnemonic (15 char max)")
 CALL accept(7,20,"P(15);CUF",client_mnemonic)
 IF (((curaccept="") OR (curaccept <= " ")) )
  CALL clear(18,8,47)
  CALL text(18,8,"Do you want to quit ? (Y/N)")
  CALL accept(18,36,"A;CU","N")
  IF (curaccept="Y")
   GO TO exit_program
  ENDIF
  GO TO accept_client_mnemonic
 ENDIF
 SET client_mnemonic = curaccept
 SET help = off
 CALL clear(18,8,47)
#accept_environment_id
 CALL clear(16,8,47)
 CALL text(16,8,"Press <SHIFT> <F5> for <HELP>.")
 SET help =
 SELECT INTO "nl:"
  de.environment_id, de.environment_name, ref.db_name
  FROM dm_environment de,
   ref_instance_id ref
  WHERE de.environment_id=ref.environment_id
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  de.environment_id
  FROM dm_environment de
  WHERE de.environment_id=curaccept
  WITH nocounter
 ;end select
 SET validate = 1
 CALL clear(18,8,47)
 CALL text(18,8,"Enter environment id from table")
 CALL text(8,39,"Choose value from table.")
 CALL accept(8,27,"99999999.99;FS",environment_id)
 IF (curscroll=2)
  GO TO accept_client_mnemonic
 ELSEIF (curscroll != 0)
  GO TO accept_environment_id
 ENDIF
 SET environment_id = curaccept
 CALL clear(18,8,47)
 SELECT INTO "nl:"
  FROM dm_environment de,
   ref_instance_id ref
  WHERE de.environment_id=environment_id
   AND ref.environment_id=de.environment_id
  DETAIL
   instance_cd = ref.instance_cd, environment_name = de.environment_name, db_name = ref.db_name
  WITH nocounter
 ;end select
 CALL clear(8,39,75)
 CALL text(8,39,concat("Environment: ",trim(environment_name),",   Database: ",trim(db_name)))
 SET help = off
 SET validate = off
 CALL clear(18,8,47)
 SET x = 0
 SELECT INTO "nl:"
  FROM ref_report_log rl,
   ref_report_parms_log rp
  WHERE rl.report_cd=1.0
   AND rl.report_seq=rp.report_seq
   AND rp.parm_cd=1
   AND rp.parm_value=cnvtstring(instance_cd)
  ORDER BY rl.begin_date DESC
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x=1)
    curr_report_seq = rl.report_seq, curr_report_date = format(rl.begin_date,"DD-MMM-YYYY;;D"),
    curr_report_notes = substring(1,50,rl.user_notes),
    new_report_seq = rl.report_seq
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL clear(16,8,47)
  CALL text(16,8,"No space summary reports found! Choose another")
  CALL clear(18,8,47)
  CALL text(18,8,"environment. Hit Enter or X to Exit:")
  CALL accept(18,45,"P;CU","")
  IF (curaccept="X")
   GO TO exit_program
  ENDIF
  GO TO accept_environment_id
 ENDIF
 IF (x=1)
  CALL clear(16,8,47)
  CALL text(16,8,"Found only one space summary report for this")
  CALL clear(17,8,47)
  CALL text(17,8,"environment; there must be at least two!")
  CALL clear(18,8,47)
  CALL text(18,8,"Hit Enter or X to Exit:")
  CALL accept(18,32,"P;CU","")
  IF (curaccept="X")
   GO TO exit_program
  ENDIF
  CALL clear(16,8,47)
  CALL clear(17,8,47)
  CALL clear(18,8,47)
  GO TO accept_environment_id
 ENDIF
#accept_curr_report_seq
 CALL text(16,8,"Press <SHIFT> <F5> for <HELP>.")
 SET help =
 SELECT INTO "nl:"
  rl.report_seq, date = format(rl.begin_date,"DD-MMM-YYYY;;D"), comments = substring(1,50,rl
   .user_notes)
  FROM ref_report_log rl,
   ref_report_parms_log rp
  WHERE rl.report_cd=1.0
   AND rl.report_seq=rp.report_seq
   AND rp.parm_cd=1
   AND rp.parm_value=cnvtstring(instance_cd)
  ORDER BY rl.begin_date DESC
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  rl.report_seq
  FROM ref_report_log rl
  WHERE rl.report_seq=curaccept
  WITH nocounter
 ;end select
 SET validate = 1
 CALL clear(9,52,62)
 CALL text(9,52,concat(trim(curr_report_date)," ",trim(curr_report_notes)))
 CALL text(18,8,"Use <HELP> to see more values")
 CALL accept(9,40,"N(11);S",curr_report_seq)
 IF (curscroll=2)
  GO TO accept_environment_id
 ELSEIF (curscroll != 0)
  GO TO accept_curr_report_seq
 ENDIF
 SET curr_report_seq = curaccept
 SELECT INTO "nl:"
  FROM ref_report_log ref
  WHERE ref.report_seq=curr_report_seq
  DETAIL
   curr_report_date = format(ref.begin_date,"DD-MMM-YYYY;;D"), curr_report_notes = substring(1,50,ref
    .user_notes)
  WITH nocounter
 ;end select
 CALL clear(9,52,62)
 CALL text(9,52,concat(trim(curr_report_date)," ",trim(curr_report_notes)))
 SET help = off
 SET validate = off
 CALL clear(18,8,47)
 SELECT INTO "nl:"
  FROM ref_report_log rl,
   ref_report_parms_log rp
  WHERE rl.report_cd=1.0
   AND rl.report_seq=rp.report_seq
   AND rp.parm_cd=1
   AND rp.parm_value=cnvtstring(instance_cd)
   AND rl.begin_date < cnvtdatetime(curr_report_date)
  ORDER BY rl.begin_date DESC
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x=1)
    prev_report_seq = rl.report_seq, prev_report_date = format(rl.begin_date,"DD-MMM-YYYY;;D"),
    prev_report_notes = substring(1,50,rl.user_notes)
   ENDIF
  WITH nocounter
 ;end select
#accept_prev_report_seq
 CALL text(16,8,"Press <SHIFT> <F5> for <HELP>.")
 SET help =
 SELECT INTO "nl:"
  rl.report_seq, date = format(rl.begin_date,"DD-MMM-YYYY;;D"), comments = substring(1,50,rl
   .user_notes)
  FROM ref_report_log rl,
   ref_report_parms_log rp
  WHERE rl.report_cd=1.0
   AND rl.report_seq=rp.report_seq
   AND rp.parm_cd=1
   AND rp.parm_value=cnvtstring(instance_cd)
   AND rl.report_seq != curr_report_seq
  ORDER BY rl.begin_date DESC
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  rl.report_seq
  FROM ref_report_log rl
  WHERE rl.report_seq=curaccept
  WITH nocounter
 ;end select
 SET validate = 1
 CALL clear(10,56,62)
 CALL text(10,56,concat(trim(prev_report_date)," ",trim(prev_report_notes)))
 CALL text(18,8,"Use <HELP> to see more values.")
 CALL accept(10,44,"N(11);S",prev_report_seq)
 IF (curscroll=2)
  GO TO accept_curr_report_seq
 ELSEIF (curscroll != 0)
  GO TO accept_prev_report_seq
 ENDIF
 SET prev_report_seq = curaccept
 SELECT INTO "nl:"
  FROM ref_report_log ref
  WHERE ref.report_seq=prev_report_seq
  DETAIL
   prev_report_date = format(ref.begin_date,"DD-MMM-YYYY;;D"), prev_report_notes = substring(1,50,ref
    .user_notes)
  WITH nocounter
 ;end select
 CALL clear(10,56,62)
 CALL text(10,56,concat(trim(prev_report_date)," ",trim(prev_report_notes)))
 SET help = off
 SET validate = off
 CALL clear(18,8,47)
 SELECT INTO "nl:"
  FROM ref_report_log rl,
   ref_report_parms_log rp
  WHERE rl.report_seq=rp.report_seq
   AND rp.parm_cd=1
   AND rp.parm_value=cnvtstring(instance_cd)
   AND rl.begin_date < cnvtdatetime(curr_report_date)
  ORDER BY rl.begin_date DESC
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x=1)
    prev_report_seq = rl.report_seq, prev_report_date = format(rl.begin_date,"DD-MMM-YYYY;;D"),
    prev_report_notes = substring(1,50,rl.user_notes)
   ENDIF
  WITH nocounter
 ;end select
#accept_owner
 CALL text(16,8,"Press <SHIFT> <F5> for <HELP>.")
 SET help =
 SELECT DISTINCT INTO "nl:"
  so.owner
  FROM space_objects so
  WHERE so.report_seq IN (prev_report_seq, curr_report_seq)
   AND so.instance_cd=instance_cd
  WITH nocounter
 ;end select
 SET validate =
 SELECT DISTINCT INTO "nl:"
  so.owner
  FROM space_objects so
  WHERE so.report_seq IN (prev_report_seq, curr_report_seq)
   AND so.instance_cd=instance_cd
  WITH nocounter
 ;end select
 SET validate = 1
 CALL text(18,8,"Use <HELP> to see more values.")
 CALL accept(11,17,"P(30);CUS","V500")
 IF (curscroll=2)
  GO TO accept_prev_report_seq
 ELSEIF (curscroll != 0)
  GO TO accept_owner
 ENDIF
 SET owner = curaccept
 SET help = off
 SET validate = off
 CALL clear(18,8,47)
 SELECT INTO "nl:"
  FROM ref_report_parms_log rp
  WHERE rp.report_seq=curr_report_seq
   AND rp.parm_cd=11
  DETAIL
   curr_block_size = cnvtint(rp.parm_value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_report_parms_log rp
  WHERE rp.report_seq=prev_report_seq
   AND rp.parm_cd=11
  DETAIL
   prev_block_size = cnvtint(rp.parm_value)
  WITH nocounter
 ;end select
#verify
 CALL box(15,80,20,105)
 CALL text(17,87,"Correct ?")
 CALL text(18,86,"Y, N, X=Exit")
 CALL accept(17,97,"A;CU","Y")
 SET answer = curaccept
 SET lines = 0
 WHILE (lines < 6)
  CALL clear((15+ lines),80,26)
  SET lines = (lines+ 1)
 ENDWHILE
 IF (answer="N")
  GO TO main
 ELSEIF (answer="Y")
  GO TO start
 ELSEIF (answer="X")
  GO TO exit_program
 ELSE
  GO TO verify
 ENDIF
#start
 FOR (line = 16 TO 19)
   CALL clear(line,8,46)
 ENDFOR
 FREE SET object_list
 RECORD object_list(
   1 client_mnemonic = c15
   1 environment_name = c20
   1 prev_report_date = c11
   1 curr_report_date = c11
   1 prev_block_size = i4
   1 curr_block_size = i4
   1 object_count = i4
   1 object[*]
     2 object_name = c81
     2 object_type = c17
     2 tablespace_name = c80
     2 prev_free_space = i4
     2 curr_free_space = i4
     2 prev_total_space = i4
     2 curr_total_space = i4
     2 prev_num_rows = i4
     2 curr_num_rows = i4
     2 new_flg = i2
     2 static_ind = i2
 )
 SET stat = alterlist(object_list->object,0)
 SET object_list->object_count = 0
 SET object_list->client_mnemonic = client_mnemonic
 SET object_list->environment_name = environment_name
 SET object_list->curr_report_date = curr_report_date
 SET object_list->prev_report_date = prev_report_date
 SET object_list->curr_block_size = curr_block_size
 SET object_list->prev_block_size = prev_block_size
 SET status_ln = 1
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = "Retrieving space data from previous report..."
 EXECUTE FROM update_status TO update_status_exit
 SET num_tables = 0
 SET num_old_objects = 0
 SELECT INTO "nl:"
  FROM space_objects so,
   dummyt d,
   dm_tables_doc doc
  PLAN (so
   WHERE so.instance_cd=instance_cd
    AND so.report_seq=prev_report_seq
    AND so.owner=owner)
   JOIN (d)
   JOIN (doc
   WHERE so.segment_name=doc.table_name)
  ORDER BY so.segment_type DESC
  DETAIL
   prev_used_space = 0, curr_used_space = 0, object_list->object_count = (object_list->object_count+
   1),
   stat = alterlist(object_list->object,object_list->object_count), object_list->object[object_list->
   object_count].object_name = so.segment_name, object_list->object[object_list->object_count].
   object_type = so.segment_type,
   object_list->object[object_list->object_count].tablespace_name = so.tablespace_name
   IF (so.segment_type="TABLE")
    object_list->object[object_list->object_count].static_ind = doc.reference_ind, num_tables = (
    num_tables+ 1)
   ELSE
    object_list->object[object_list->object_count].static_ind = 0
   ENDIF
   object_list->object[object_list->object_count].prev_free_space = so.free_space, object_list->
   object[object_list->object_count].prev_total_space = so.total_space, object_list->object[
   object_list->object_count].prev_num_rows = so.row_count,
   object_list->object[object_list->object_count].new_flg = 0
  WITH outerjoin = d
 ;end select
 IF ((object_list->object_count > 0))
  GO TO ok
 ELSE
  EXECUTE FROM error_1 TO error_1_end
  GO TO main
 ENDIF
 GO TO main
#error_1
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL line(5,1,132,xhor)
 CALL text(3,46,"***  GET DATABASE SIZE INFORMATION  ***")
 CALL text(7,5,
  "Error: No space summary was found on objects for that environment and report sequence.")
 CALL text(8,5,"       Hit any key to continue and then choose the correct parameters.")
 CALL accept(9,5,"P;CUS"," ")
#error_1_end
#update_status
 CALL clear(((16+ status_ln) - 1),8,46)
 CALL text(((16+ status_ln) - 1),8,status_str)
#update_status_exit
#ok
 SET num_old_objects = object_list->object_count
 SET status_ln = 1
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = concat("Found ",trim(cnvtstring(num_old_objects))," objects in previous report")
 EXECUTE FROM update_status TO update_status_exit
 SET status_ln = 2
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = "Checking for static indexes..."
 EXECUTE FROM update_status TO update_status_exit
 FOR (loop = 1 TO value(object_list->object_count))
   IF ((object_list->object[loop].object_type="INDEX"))
    SELECT INTO "nl:"
     FROM dm_indexes di
     WHERE (di.index_name=object_list->object[loop].object_name)
     ORDER BY di.schema_date DESC
     DETAIL
      table_name = di.table_name
     WITH maxqual(di,1)
    ;end select
    IF (curqual > 0)
     SET found = 0
     SET t = 1
     WHILE (found=0
      AND t <= num_tables)
      IF ((object_list->object[t].object_name=table_name))
       SET found = 1
       SET object_list->object[loop].static_ind = object_list->object[t].static_ind
      ENDIF
      SET t = (t+ 1)
     ENDWHILE
    ENDIF
   ENDIF
 ENDFOR
 SET status_ln = 2
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = "Retrieving space data from current report..."
 EXECUTE FROM update_status TO update_status_exit
 SET num_tables = 0
 SELECT INTO "nl:"
  FROM space_objects so,
   dummyt d,
   dm_tables_doc doc
  PLAN (so
   WHERE so.instance_cd=instance_cd
    AND so.report_seq=curr_report_seq
    AND so.owner=owner)
   JOIN (d)
   JOIN (doc
   WHERE so.segment_name=doc.table_name)
  ORDER BY so.segment_type DESC
  DETAIL
   found = 0, loop = 1
   WHILE (found=0
    AND loop <= num_old_objects)
     IF ((so.segment_name=object_list->object[loop].object_name)
      AND (so.segment_type=object_list->object[loop].object_type))
      found = 1, object_list->object[loop].curr_free_space = so.free_space, object_list->object[loop]
      .curr_total_space = so.total_space,
      object_list->object[loop].curr_num_rows = so.row_count, object_list->object[loop].new_flg = 0
     ELSE
      loop = (loop+ 1)
     ENDIF
   ENDWHILE
   IF (found=0)
    prev_used_space = 0, curr_used_space = 0, object_list->object_count = (object_list->object_count
    + 1),
    stat = alterlist(object_list->object,object_list->object_count), object_list->object[object_list
    ->object_count].object_name = so.segment_name, object_list->object[object_list->object_count].
    object_type = so.segment_type,
    object_list->object[object_list->object_count].tablespace_name = so.tablespace_name
    IF (so.segment_type="TABLE")
     object_list->object[object_list->object_count].static_ind = doc.reference_ind, num_tables = (
     num_tables+ 1)
    ELSE
     object_list->object[object_list->object_count].static_ind = 0
    ENDIF
    object_list->object[object_list->object_count].curr_free_space = so.free_space, object_list->
    object[object_list->object_count].curr_total_space = so.total_space, object_list->object[
    object_list->object_count].curr_num_rows = so.row_count,
    object_list->object[object_list->object_count].prev_free_space = 0.0, object_list->object[
    object_list->object_count].prev_total_space = 0.0, object_list->object[object_list->object_count]
    .prev_num_rows = 0.0,
    object_list->object[object_list->object_count].new_flg = 1
   ENDIF
  WITH outerjoin = d
 ;end select
 SET status_ln = 2
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = concat("Found ",trim(cnvtstring(object_list->object_count)),
  " objects in current report")
 EXECUTE FROM update_status TO update_status_exit
 SET status_ln = 3
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = "Checking for new static indexes..."
 EXECUTE FROM update_status TO update_status_exit
 FOR (loop = (num_old_objects+ 1) TO value(object_list->object_count))
   IF ((object_list->object[loop].object_type="INDEX"))
    SELECT INTO "nl:"
     FROM dm_indexes di
     WHERE (di.index_name=object_list->object[loop].object_name)
     ORDER BY di.schema_date DESC
     DETAIL
      table_name = di.table_name
     WITH maxqual(di,1)
    ;end select
    IF (curqual > 0)
     SET found = 0
     SET t = num_old_objects
     WHILE (found=0
      AND (t <= (num_old_objects+ num_tables)))
      IF ((object_list->object[t].object_name=table_name))
       SET found = 1
       SET object_list->object[loop].static_ind = object_list->object[t].static_ind
      ENDIF
      SET t = (t+ 1)
     ENDWHILE
    ENDIF
   ENDIF
 ENDFOR
 SET status_ln = 3
 SET status_str = "1234567890123456789012345678901234567890123456"
 SET status_str = "Writing data to output file..."
 EXECUTE FROM update_status TO update_status_exit
 SET filename = concat(trim(client_mnemonic),"_dbsize")
 SELECT INTO value(filename)
  FROM (dummyt d  WITH seq = value(object_list->object_count))
  PLAN (d)
  DETAIL
   col 0, object_list->client_mnemonic, object_list->environment_name,
   object_list->prev_report_date, object_list->curr_report_date, object_list->object[d.seq].
   object_name,
   object_list->object[d.seq].object_type, object_list->object[d.seq].tablespace_name, object_list->
   object[d.seq].static_ind,
   object_list->object[d.seq].prev_total_space, object_list->object[d.seq].curr_total_space,
   object_list->object[d.seq].prev_free_space,
   object_list->object[d.seq].curr_free_space, object_list->object[d.seq].prev_num_rows, object_list
   ->object[d.seq].curr_num_rows,
   object_list->object[d.seq].new_flg
   IF ((d.seq < object_list->object_count))
    row + 1
   ENDIF
  WITH nocounter, maxcol = 324, maxrow = 1,
   noformfeed, noheading, noformat
 ;end select
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL line(5,1,132,xhor)
 CALL text(3,46,"***  GET DATABASE SIZE INFORMATION  ***")
 SET line1 = concat("Space data for ",trim(cnvtstring(object_list->object_count)),
  " objects from the '",trim(object_list->environment_name),"' environment and '",
  trim(db_name),"' database")
 SET line2 = concat("has been written to file 'CCLUSERDIR:",trim(filename),".dat'")
 CALL text(7,5,line1)
 CALL text(8,5,line2)
 CALL text(10,5,"This file should be sent as an email attachment to John Kuckelman.")
 CALL text(11,5,"Please write the formal client name, client mnemonic, and the")
 CALL text(12,5,"products converted in the text of the email.")
 CALL accept(13,5,"P;CU","")
#exit_program
 CALL text(23,1,"Exiting from program...")
END GO

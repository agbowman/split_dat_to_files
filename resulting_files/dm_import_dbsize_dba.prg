CREATE PROGRAM dm_import_dbsize:dba
 PAINT
#start_program
 DECLARE msg_box(begin_row,begin_col,end_row,end_col,msg_line1,
  msg_line2,default) = i2 WITH persist
 DROP DATABASE dbsize WITH deps_deleted
 CREATE DATABASE dbsize
 ORGANIZATION(sequential)
 FORMAT(fixed)
 SIZE(324)
 CREATE DDLRECORD dbsize_record FROM DATABASE dbsize
 TABLE dbs WITH null = none
  1 dbs_client_mnemonic  = c15 CCL(client_mnemonic)
  1 dbs_environment_name  = c20 CCL(environment_name)
  1 dbs_prev_report_date  = c11 CCL(prev_report_date)
  1 dbs_curr_report_date  = c11 CCL(curr_report_date)
  1 dbs_object_name  = c81 CCL(object_name)
  1 dbs_object_type  = c17 CCL(object_type)
  1 dbs_tablespace_name  = c80 CCL(tablespace_name)
  1 dbs_static_ind  = c11 CCL(static_ind)
  1 dbs_prev_total_space  = c11 CCL(prev_total_space)
  1 dbs_curr_total_space  = c11 CCL(curr_total_space)
  1 dbs_prev_free_space  = c11 CCL(prev_free_space)
  1 dbs_curr_free_space  = c11 CCL(curr_free_space)
  1 dbs_prev_num_rows  = c11 CCL(prev_num_rows)
  1 dbs_curr_num_rows  = c11 CCL(curr_num_rows)
  1 dbs_new_flg  = c12 CCL(new_flg)
 END TABLE dbs
#initialize
 SET block_size = 8192
 SET num_objects = 0.0
 SET client_mnemonic = fillstring(15," ")
 SET client_name = fillstring(50," ")
 SET environment = fillstring(20," ")
 SET prev_date = fillstring(11," ")
 SET curr_date = fillstring(11," ")
 SET products = fillstring(105," ")
 SET old_client_name = fillstring(50," ")
 SET old_environment = fillstring(20," ")
 SET old_prev_date = fillstring(11," ")
 SET old_curr_date = fillstring(11," ")
 SET old_products = fillstring(105," ")
 SET activity_days = 0
 SET temp_days = 0
 SET temp_date = fillstring(11," ")
 SET flip_dates = 0
 SET filename = fillstring(75," ")
 SET products = fillstring(105," ")
 SET num_tables = 0.0
 SET table_name = fillstring(81," ")
 SET blank_line = fillstring(130," ")
 FREE SET object_list
 RECORD object_list(
   1 client_mnemonic = c15
   1 client_name = c50
   1 environment_name = c20
   1 products = c500
   1 object_prev_used_cnt = i2
   1 object[*]
     2 object_name = c81
     2 object_type = c17
     2 tablespace_name = c80
     2 static_ind = i2
     2 prev_total_space = f8
     2 curr_total_space = f8
     2 prev_free_space = f8
     2 curr_free_space = f8
     2 prev_used_space = f8
     2 curr_used_space = f8
     2 used_space_day = f8
     2 prev_num_rows = f8
     2 curr_num_rows = f8
     2 num_rows_day = f8
     2 bytes_per_row = f8
     2 new_object_ind = i2
     2 status = i4
     2 errnum = i4
     2 errmsg = c255
   1 object_count = i4
   1 prev_report_dt_tm = dq8
   1 curr_report_dt_tm = dq8
   1 activity_days = i4
   1 total_bytes = f8
   1 total_bytes_day = f8
   1 total_rows = f8
   1 total_rows_day = f8
 )
 SET stat = alterlist(object_list->object,0)
 SET object_list->object_count = 0
 SET object_list->object_prev_used_cnt = 0
#main
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,22,132)
 CALL line(5,1,132,xhor)
 CALL text(3,45,"***  IMPORT DATABASE SIZE INFORMATION  ***")
 CALL text(7,2,"DBSIZE DATA FILENAME (FULL PATH):")
 CALL text(10,2,"ACTIVITY DAYS:")
 CALL text(12,2,"COMPLETE CLIENT NAME (FORMAL):")
 CALL text(14,2,"PRODUCTS CONVERTED:")
#accept_filename
 CALL text(8,27,"example:  CCLUSERDIR:CLIENT_DBSIZE.DAT")
 CALL accept(7,37,"P(75);CU",filename)
 IF (((curaccept="") OR (curaccept=null)) )
  GO TO accept_filename
 ENDIF
 SET filename = curaccept
 SET help = off
 CALL text(23,1,blank_line)
 CALL text(23,1,"Checking for data file...")
 SET datafile = filename
 FREE DEFINE dbsize
 DEFINE dbsize datafile
 CALL text(23,1,blank_line)
 CALL text(23,1,"Reading from data file...")
 SET num_objects = 0
 SELECT INTO "nl:"
  FROM dbs
  DETAIL
   num_objects = (num_objects+ 1)
   IF (num_objects=1)
    client_mnemonic = dbs.client_mnemonic, environment = dbs.environment_name, prev_date = dbs
    .prev_report_date,
    curr_date = dbs.curr_report_date
   ENDIF
  WITH nocounter
 ;end select
 CALL text(23,1,blank_line)
 IF (num_objects < 1)
  CALL msg_box(16,2,20,35,"Missing data or file not found!",
   "Re-enter filename? (Y/N)","")
  IF (curaccept="Y")
   GO TO accept_filename
  ELSE
   GO TO exit_program
  ENDIF
 ELSE
  SET logfile = concat(trim(client_mnemonic),"_DBSIZE.LOG")
  SELECT INTO value(logfile)
   FROM dual
   DETAIL
    "/* LOG FILE FOR IMPORT_DBSIZE */", row + 2, "Data from client ",
    client_mnemonic, " for ", environment,
    " environment found in file.", row + 1, "Space report on ",
    num_objects, " objects, from ", prev_date,
    " to ", curr_date, ".",
    row + 2
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
  CALL text(23,1,blank_line)
  CALL text(23,1,"Checking if client profile already exists...")
  SELECT INTO "nl:"
   FROM dm_client_size dc
   WHERE dc.client_mnemonic=client_mnemonic
   DETAIL
    old_client_name = dc.client_name, old_environment = dc.environment_name, old_products = substring
    (1,105,dc.products),
    old_prev_date = format(dc.prev_report_dt_tm,"DD-MMM-YYYY;;D"), old_curr_date = format(dc
     .curr_report_dt_tm,"DD-MMM-YYYY;;D")
   WITH nocounter
  ;end select
  CALL text(23,1,blank_line)
  IF (curqual=1)
   SET tempstr = concat(trim(client_mnemonic)," client profile already exists! (",trim(
     old_environment),":",trim(old_prev_date),
    " to ",trim(old_curr_date),")")
   CALL msg_box(16,2,20,110,trim(tempstr),
    "Replace old client data? (Y/N)","")
   IF (curaccept != "Y")
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 SET client_name = old_client_name
 SET products = old_products
 SET activity_days = datetimecmp(cnvtdatetime(curr_date),cnvtdatetime(prev_date))
 IF (activity_days < 0)
  SET flip_dates = 1
  SET temp_date = curr_date
  SET curr_date = prev_date
  SET prev_date = temp_date
  SET activity_days = abs(activity_days)
 ENDIF
 SET temp_days = activity_days
#accept_activity_days
 SET help = off
 SET validate = off
 CALL clear(10,22,40)
 IF (activity_days=temp_days)
  CALL text(10,22,build("From '",prev_date,"' to '",curr_date,"'"))
 ELSE
  CALL text(10,22,build("(Default value: ",temp_days,")"))
 ENDIF
 CALL accept(10,17,"9(4);S",activity_days)
 IF (curscroll=2)
  GO TO accept_filename
 ELSEIF (curscroll != 0)
  GO TO accept_activity_days
 ENDIF
 IF (curaccept <= 0)
  GO TO accept_activity_days
 ENDIF
 SET activity_days = cnvtint(curaccept)
 SET help = off
 CALL clear(10,22,40)
 IF (activity_days=temp_days)
  CALL text(10,22,build("From '",prev_date,"' to '",curr_date,"'"))
 ELSE
  CALL text(10,22,"(User defined value)")
 ENDIF
#accept_client_name
 CALL accept(12,34,"P(50);CUS",client_name)
 IF (curscroll=2)
  GO TO accept_activity_days
 ELSEIF (curscroll != 0)
  GO TO accept_client_name
 ENDIF
 IF (((curaccept="") OR (curaccept=null)) )
  GO TO accept_client_name
 ENDIF
 SET client_name = curaccept
 SET help = off
#accept_products
 CALL text(15,13,"example:  ADT FEEDS,PROFILE,SCHEDULING")
 CALL accept(14,23,"P(105);CUS",products)
 IF (curscroll=2)
  GO TO accept_client_name
 ELSEIF (curscroll != 0)
  GO TO accept_products
 ENDIF
 IF (((curaccept="") OR (curaccept=null)) )
  GO TO accept_products
 ENDIF
 SET products = curaccept
 SET help = off
#verify
 CALL box(16,80,21,105)
 CALL text(18,87,"Correct ?")
 CALL text(19,86,"Y, N, X=Exit")
 CALL accept(18,97,"A;CU","Y")
 SET answer = curaccept
 SET lines = 0
 WHILE (lines < 6)
  CALL clear((16+ lines),80,26)
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
 SET object_list->client_name = client_name
 SET object_list->client_mnemonic = client_mnemonic
 SET object_list->environment_name = environment
 SET object_list->products = products
 SET object_list->prev_report_dt_tm = cnvtdatetime(prev_date)
 SET object_list->curr_report_dt_tm = cnvtdatetime(curr_date)
 SET object_list->activity_days = abs(activity_days)
 IF ((object_list->activity_days < 1))
  SET object_list->activity_days = 7
  SELECT INTO value(logfile)
   FROM dual
   DETAIL
    "Warning: Space summary reports are from same date! Growth rate values may be incorrect.", row +
    2
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  CALL msg_box(16,2,20,81,
   "Space summary reports are from same date! Growth rate values may be incorrect.",
   "A duration of 7 days will be assumed for calculations. Continue? (Y/N)","")
  IF (curaccept != "Y")
   GO TO exit_program
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_client_size dc
  WHERE (dc.client_mnemonic=object_list->client_mnemonic)
  WITH nocounter
 ;end select
#test
 IF (curqual < 1)
  CALL text(23,1,blank_line)
  CALL text(23,1,"Inserting new client profile...")
  SELECT INTO value(logfile)
   FROM dual
   DETAIL
    "Client mnemonic ", object_list->client_mnemonic, " not found in DM_CLIENT_SIZE table.",
    row + 1, "Inserting new client profile now!", row + 2
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  INSERT  FROM dm_client_size dc
   SET dc.client_mnemonic = object_list->client_mnemonic, dc.client_name = object_list->client_name,
    dc.environment_name = object_list->environment_name,
    dc.products = object_list->products, dc.prev_report_dt_tm = cnvtdatetime(prev_date), dc
    .curr_report_dt_tm = cnvtdatetime(curr_date),
    dc.activity_days = object_list->activity_days
   WITH nocounter
  ;end insert
 ELSE
  CALL text(23,1,blank_line)
  CALL text(23,1,"Updating/deleting old client profile...")
  SELECT INTO value(logfile)
   FROM dual
   DETAIL
    "Client mnemonic ", object_list->client_mnemonic, " found in DM_CLIENT_SIZE table.",
    row + 1, "Updating client profile now!", row + 2
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  UPDATE  FROM dm_client_size dc
   SET dc.client_name = object_list->client_name, dc.environment_name = object_list->environment_name,
    dc.products = object_list->products,
    dc.prev_report_dt_tm = cnvtdatetime(prev_date), dc.curr_report_dt_tm = cnvtdatetime(curr_date),
    dc.activity_days = object_list->activity_days
   WHERE (dc.client_mnemonic=object_list->client_mnemonic)
  ;end update
  DELETE  FROM dm_client_object_size dc
   WHERE (dc.client_mnemonic=object_list->client_mnemonic)
  ;end delete
 ENDIF
 CALL text(23,1,blank_line)
 CALL text(23,1,"Reading/Calculating new object space data...")
 SELECT INTO value(logfile)
  FROM dbs
  HEAD REPORT
   object_list->total_bytes = 0.0, object_list->total_bytes_day = 0.0, object_list->total_rows = 0.0,
   object_list->total_rows_day = 0.0
  DETAIL
   object_list->object_count = (object_list->object_count+ 1), count = object_list->object_count,
   stat = alterlist(object_list->object,object_list->object_count),
   object_list->object[count].object_name = dbs.object_name, object_list->object[count].object_type
    = dbs.object_type
   IF ((object_list->object[count].object_type="TABLE"))
    num_tables = count
   ENDIF
   object_list->object[count].tablespace_name = dbs.tablespace_name, object_list->object[count].
   static_ind = cnvtint(dbs.static_ind)
   IF (flip_dates=0)
    object_list->object[count].prev_total_space = (cnvtreal(dbs.prev_total_space) * block_size),
    object_list->object[count].curr_total_space = (cnvtreal(dbs.curr_total_space) * block_size),
    object_list->object[count].prev_free_space = (cnvtreal(dbs.prev_free_space) * block_size),
    object_list->object[count].curr_free_space = (cnvtreal(dbs.curr_free_space) * block_size),
    object_list->object[count].prev_num_rows = cnvtreal(dbs.prev_num_rows), object_list->object[count
    ].curr_num_rows = cnvtreal(dbs.curr_num_rows)
   ELSE
    object_list->object[count].prev_total_space = (cnvtreal(dbs.curr_total_space) * block_size),
    object_list->object[count].curr_total_space = (cnvtreal(dbs.prev_total_space) * block_size),
    object_list->object[count].prev_free_space = (cnvtreal(dbs.curr_free_space) * block_size),
    object_list->object[count].curr_free_space = (cnvtreal(dbs.prev_free_space) * block_size),
    object_list->object[count].prev_num_rows = cnvtreal(dbs.curr_num_rows), object_list->object[count
    ].curr_num_rows = cnvtreal(dbs.prev_num_rows)
   ENDIF
   object_list->object[count].new_object_ind = cnvtreal(dbs.new_flg), object_list->object[count].
   prev_used_space = (object_list->object[count].prev_total_space - object_list->object[count].
   prev_free_space)
   IF ((object_list->object[count].prev_used_space=0.0))
    object_list->object_prev_used_cnt = (object_list->object_prev_used_cnt+ 1)
   ENDIF
   object_list->object[count].curr_used_space = (object_list->object[count].curr_total_space -
   object_list->object[count].curr_free_space)
   IF ((object_list->object[count].curr_used_space > object_list->object[count].prev_used_space)
    AND (object_list->object[count].prev_used_space != 0.0))
    object_list->object[count].used_space_day = ((object_list->object[count].curr_used_space -
    object_list->object[count].prev_used_space)/ cnvtreal(object_list->activity_days))
   ELSE
    object_list->object[count].used_space_day = 0.0
   ENDIF
   IF ((object_list->object[count].curr_num_rows > object_list->object[count].prev_num_rows)
    AND (object_list->object[count].prev_num_rows != 0.0))
    object_list->object[count].num_rows_day = ((object_list->object[count].curr_num_rows -
    object_list->object[count].prev_num_rows)/ cnvtreal(object_list->activity_days))
   ELSE
    object_list->object[count].num_rows_day = 0.0
   ENDIF
   IF ((object_list->object[count].curr_used_space > 0.0)
    AND (object_list->object[count].curr_num_rows > 0.0))
    object_list->object[count].bytes_per_row = ceil((object_list->object[count].curr_used_space/
     object_list->object[count].curr_num_rows))
   ELSEIF ((object_list->object[count].prev_used_space > 0.0)
    AND (object_list->object[count].prev_num_rows > 0.0))
    object_list->object[count].bytes_per_row = ceil((object_list->object[count].prev_used_space/
     object_list->object[count].prev_num_rows))
   ELSE
    object_list->object[count].bytes_per_row = 0.0
   ENDIF
   object_list->total_bytes = (object_list->total_bytes+ object_list->object[count].curr_used_space),
   object_list->total_bytes_day = (object_list->total_bytes_day+ object_list->object[count].
   used_space_day), object_list->total_rows = (object_list->total_rows+ object_list->object[count].
   curr_num_rows),
   object_list->total_rows_day = (object_list->total_rows_day+ object_list->object[count].
   num_rows_day), row + 1, "Object: ",
   object_list->object[count].object_name, object_list->object[count].object_type, row + 1,
   "Tablespace: ", object_list->object[count].tablespace_name, row + 1,
   "Total:", object_list->object[count].prev_total_space, object_list->object[count].curr_total_space,
   row + 1, "Free: ", object_list->object[count].prev_free_space,
   object_list->object[count].curr_free_space, row + 1, "Used: ",
   object_list->object[count].prev_used_space, object_list->object[count].curr_used_space, row + 1,
   "Used per Day: ", object_list->object[count].used_space_day, row + 1,
   "Rows: ", object_list->object[count].prev_num_rows, object_list->object[count].curr_num_rows,
   row + 1, "Rows per Day: ", object_list->object[count].num_rows_day,
   row + 1, "Bytes per Row: ", object_list->object[count].bytes_per_row,
   row + 1
  FOOT REPORT
   "Total Bytes: ", object_list->total_bytes, row + 1,
   "    per day: ", object_list->total_bytes_day, row + 1,
   "Total Rows : ", object_list->total_rows, row + 1,
   "    per day: ", object_list->total_rows_day
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
 CALL text(23,1,blank_line)
 CALL text(23,1,"Inserting object space data in client profile table...")
 INSERT  FROM dm_client_object_size co,
   (dummyt d  WITH seq = value(size(object_list->object,5)))
  SET co.client_mnemonic = object_list->client_mnemonic, co.object_name = object_list->object[d.seq].
   object_name, co.object_type = object_list->object[d.seq].object_type,
   co.tablespace_name = object_list->object[d.seq].tablespace_name, co.static_ind = object_list->
   object[d.seq].static_ind, co.prev_total_space = object_list->object[d.seq].prev_total_space,
   co.curr_total_space = object_list->object[d.seq].curr_total_space, co.prev_free_space =
   object_list->object[d.seq].prev_free_space, co.curr_free_space = object_list->object[d.seq].
   curr_free_space,
   co.prev_used_space = object_list->object[d.seq].prev_used_space, co.curr_used_space = object_list
   ->object[d.seq].curr_used_space, co.used_space_day = object_list->object[d.seq].used_space_day,
   co.prev_num_rows = object_list->object[d.seq].prev_num_rows, co.curr_num_rows = object_list->
   object[d.seq].curr_num_rows, co.num_rows_day = object_list->object[d.seq].num_rows_day,
   co.bytes_per_row = object_list->object[d.seq].bytes_per_row, co.new_object_ind = object_list->
   object[d.seq].new_object_ind
  PLAN (d
   WHERE (object_list->object[d.seq].prev_used_space != 0.0)
    AND (object_list->object[d.seq].curr_total_space > 16384))
   JOIN (co)
  WITH counter, status(object_list->object[d.seq].status,object_list->object[d.seq].errnum,
   object_list->object[d.seq].errmsg)
 ;end insert
 SELECT INTO value("dbsize_insert.log")
  FROM (dummyt d  WITH seq = value(size(object_list->object,5)))
  WHERE (object_list->object[d.seq].status=0)
  DETAIL
   "Object = ", object_list->object[d.seq].object_name, row + 1,
   "  Type = ", object_list->object[d.seq].object_type, row + 1,
   " Error Number = ", object_list->object[d.seq].errnum, row + 1,
   "Error Message = ", object_list->object[d.seq].errmsg, row + 1,
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 CALL text(23,1,blank_line)
 CALL text(23,1,"Updating client profile...")
 UPDATE  FROM dm_client_size dc
  SET dc.total_objects = object_list->object_count, dc.total_bytes = object_list->total_bytes, dc
   .total_bytes_day = object_list->total_bytes_day,
   dc.total_rows = object_list->total_rows, dc.total_rows_day = object_list->total_rows_day
  WHERE (dc.client_mnemonic=object_list->client_mnemonic)
 ;end update
 COMMIT
 SET num_imp_objects = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_client_object_size dc
  WHERE (dc.client_mnemonic=object_list->client_mnemonic)
  DETAIL
   num_imp_objects = x
  WITH nocounter
 ;end select
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,22,132)
 CALL line(5,1,132,xhor)
 CALL text(3,45,"***  IMPORT DATABASE SIZE INFORMATION  ***")
 CALL text(7,5,concat("Number of objects in data file = ",trim(cnvtstring(num_objects))))
 CALL text(8,5,concat("    Number of objects imported = ",trim(cnvtstring(num_imp_objects))))
 CALL text(9,5,concat("              Number of errors = ",trim(cnvtstring(((num_objects -
     num_imp_objects) - object_list->object_prev_used_cnt)))))
 CALL text(10,5,concat("        Previous Used Space[0] = ",trim(cnvtstring(object_list->
     object_prev_used_cnt))))
 SET line1 = concat("Space data for ",trim(cnvtstring(num_imp_objects))," objects from the '",trim(
   object_list->environment_name),"' environment")
 SET line2 = concat("of client ",trim(object_list->client_mnemonic),
  " has been successfuly imported into the tables.")
 SET line3 = concat("A log of the client profile and objects found is stored in CCLUSERDIR:",logfile)
 CALL text(12,5,line1)
 CALL text(13,5,line2)
 CALL text(14,5,line3)
 CALL text(17,5,"Would you like to import more space data ? (Y/N)")
 CALL accept(18,5,"A;CU","N")
 IF (curaccept="Y")
  GO TO start_program
 ENDIF
 GO TO exit_program
 SUBROUTINE msg_box(begin_row,begin_col,end_row,end_col,msg_line1,msg_line2,default)
  IF ((((size(trim(msg_line1)) > (end_col - begin_col))) OR ((size(trim(msg_line2)) > (end_col -
  begin_col)))) )
   CALL text(22,1,"Error: msg_box(): text message too long for box!")
  ELSEIF (((end_row - begin_row) <= 3))
   CALL text(22,1,"Error: msg_box(): message box too short!")
  ELSE
   CALL box(begin_row,begin_col,end_row,end_col)
   CALL text((begin_row+ 1),(begin_col+ 1),trim(msg_line1))
   CALL text((begin_row+ 2),(begin_col+ 1),trim(msg_line2))
   IF (default != "")
    CALL accept((begin_row+ 3),(begin_col+ 1),"P;CU",default)
   ELSE
    CALL accept((begin_row+ 3),(begin_col+ 1),"P;CU")
   ENDIF
  ENDIF
  FOR (msg_box_row = begin_row TO end_row)
    CALL clear(msg_box_row,begin_col,((end_col - begin_col)+ 1))
  ENDFOR
 END ;Subroutine
#exit_program
 CALL text(23,1,"Exiting from program...")
END GO

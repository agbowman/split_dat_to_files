CREATE PROGRAM dm_database_resizing:dba
 PAINT
 RECORD dm_resize(
   1 mode = i4
   1 space_to_consume = f8
   1 days_to_last = f8
   1 show_allocation_report = i4
   1 s_rep_seq = i4
   1 e_rep_seq = i4
   1 actual_days_activity = f8
   1 env_id = f8
   1 testing_mode = i4
   1 modify_next_extent_size = i4
   1 next_extent_size_days = f8
   1 show_no_growth_objects = i4
 )
#mode
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,17,132)
 CALL text(2,40,"Database sizing calculation ")
 CALL text(5,3,"Please enter the mode:")
 CALL text(7,6,"1. Show Space Summary Reports from the target environment ")
 CALL text(8,10,"Select this option if you want to run database resizing process ")
 CALL text(9,10,"to monitor and re-size your database and are not adding a new product")
 CALL text(11,6,"2. Show Space Summary Reports from a source environment ")
 CALL text(12,10,"Select this option if you are live on a product and are about to ")
 CALL text(13,10,"go live on some new products ")
 CALL text(15,6,"3. Exit")
 CALL accept(05,26,"9",3
  WHERE curaccept IN (1, 2, 3))
 SET ans_mode = curaccept
 IF (ans_mode=1)
  GO TO main
 ELSEIF (ans_mode=2)
  GO TO sec_main
 ELSE
  GO TO end_script
 ENDIF
#sec_main
 SET environment_name = fillstring(20," ")
 SET src_id = 0.0
 CALL clear(1,1)
 CALL box(1,1,11,132)
 CALL text(3,05,"Please select the source environment id <help>:")
 CALL text(4,08,"Environment Name:")
 SET help =
 SELECT
  b.environment_id, b.database_name, b.environment_name
  FROM dm_environment b
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(3,53,"99999999.99;F",src_id)
 SET src_id = curaccept
 CALL clear(4,60,70)
 SET help = off
 SET validate = off
 SELECT INTO "nl:"
  b.environment_id, b.environment_name
  FROM dm_environment b
  WHERE b.environment_id=src_id
  DETAIL
   environment_name = b.environment_name
  WITH nocounter
 ;end select
 CALL text(4,27,environment_name)
 CALL text(10,20,"Correct(Y/N) ? or Exit(X):")
 CALL accept(10,48,"P;CU","N")
 IF (curaccept="Y")
  GO TO main
 ELSEIF (curaccept="X")
  GO TO end_script
 ELSE
  GO TO sec_main
 ENDIF
#main
 SET dm_resize->testing_mode = 0
 SET dm_resize->next_extent_size_days = 90.0
 SET dm_resize->show_no_growth_objects = 0
 SET env_id = 0.0
 SET environment_name = fillstring(20," ")
 SET db_name = fillstring(20," ")
 SET db_name_check = fillstring(20," ")
 SET start_rep = 0
 SET end_rep = 0
 SET begin_date = fillstring(11," ")
 SET end_date = fillstring(11," ")
 SET s_date = cnvtdatetime(curdate,curtime3)
 SET e_date = cnvtdatetime(curdate,curtime3)
 SET user_notes = fillstring(40," ")
 SET mode1 = fillstring(1," ")
 SET mode2 = fillstring(1," ")
 SET p1 = 0
 SET p2 = 0
 SET space_added = 0.0
 SET days_to_last = 0
 SET i_days_of_actual_activity = 0
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,23,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,40,"***   Database sizing calculation   ***")
 CALL clear(3,2,130)
 CALL text(05,05,"PLEASE ENTER ENVIRONMENT_ID <HELP>:")
 CALL text(06,08,"ENVIRONMENT NAME:")
 CALL text(08,05,"START REPORT SEQUENCE <HELP>:")
 CALL text(09,08,"BEGIN_DATE:")
 CALL text(10,08,"USER_COMMENTS:")
 CALL text(11,05,"END REPORT SEQUENCE <HELP>:")
 CALL text(12,08,"BEGIN DATE")
 CALL text(13,08,"USER_COMMENTS:")
 CALL text(14,05,"DAYS OF ACTIVITY:")
 CALL text(16,05,"SELECT A SIZING OPTION:")
 CALL text(17,09,
  "1) Calculates how many days the database will last with specified additional space.")
 CALL text(18,09,
  "2) Calculate how much space is needed for the database to last a specified number of days.")
 CALL text(20,05,"REPORT OVER ALLOCATED SPACE?")
 CALL text(21,05,"MODIFY NEXT EXTENT SIZE?")
 CALL text(22,05,"SHOW OBJECTS WITH NO GROWTH?")
 SET help =
 SELECT
  b.environment_id, b.database_name, b.environment_name
  FROM dm_environment b
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(5,40,"99999999.99;F",env_id)
 SET env_id = curaccept
 CALL clear(23,8,50)
 SET help = off
 SET validate = off
 SELECT INTO "nl:"
  b.environment_id, b.database_name, b.environment_name
  FROM dm_environment b
  WHERE b.environment_id=env_id
  DETAIL
   db_name = b.database_name, environment_name = b.environment_name
  WITH nocounter
 ;end select
 CALL text(6,40,environment_name)
 CALL text(23,8,"Please wait for the HELP box and select an item")
 SET cnt = 0
 SELECT
  IF (ans_mode=1)
   WHERE a.environment_id=env_id
    AND b.parm_cd=1
    AND cnvtstring(a.instance_cd)=b.parm_value
    AND b.report_seq=c.report_seq
    AND c.end_date != null
    AND c.report_cd=1
  ELSEIF (ans_mode=2)
   WHERE a.environment_id=src_id
    AND b.parm_cd=1
    AND cnvtstring(a.instance_cd)=b.parm_value
    AND b.report_seq=c.report_seq
    AND c.end_date != null
    AND c.report_cd=1
  ELSE
  ENDIF
  INTO "nl:"
  c.report_seq
  FROM ref_instance_id a,
   ref_report_parms_log b,
   ref_report_log c
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 IF (cnt=0)
  CALL clear(23,8,60)
  CALL text(23,8,"No space reports for the environment.")
  CALL pause(3)
  GO TO main
 ENDIF
 SET help =
 SELECT
  IF (ans_mode=1)
   WHERE a.environment_id=env_id
    AND b.parm_cd=1
    AND c.end_date != null
    AND c.report_cd=1
    AND cnvtstring(a.instance_cd)=b.parm_value
    AND b.report_seq=c.report_seq
  ELSEIF (ans_mode=2)
   WHERE a.environment_id=src_id
    AND b.parm_cd=1
    AND c.end_date != null
    AND c.report_cd=1
    AND cnvtstring(a.instance_cd)=b.parm_value
    AND b.report_seq=c.report_seq
  ELSE
  ENDIF
  DISTINCT INTO "nl:"
  c.report_seq, begin_date = format(c.begin_date,"DD-MMM-YYYY;;D"), user_notes = substring(1,40,c
   .user_notes)
  FROM ref_instance_id a,
   ref_report_parms_log b,
   ref_report_log c
  ORDER BY c.begin_date DESC
 ;end select
 CALL accept(8,40,"99999999.99;F",start_rep)
 SET start_rep = curaccept
 CALL clear(23,8,50)
 SET help = off
 SELECT INTO "nl:"
  c.report_seq, c.begin_date, c.user_notes
  FROM ref_report_log c
  WHERE c.report_seq=start_rep
  DETAIL
   begin_date = format(c.begin_date,"DD-MMM-YYYY;;D"), s_date = c.begin_date, user_notes = substring(
    1,40,c.user_notes)
  WITH nocounter
 ;end select
 CALL text(09,40,begin_date)
 CALL text(10,40,user_notes)
 CALL text(23,8,"Please wait for the HELP box and select an item")
 SET help =
 SELECT
  IF (ans_mode=1)
   WHERE a.environment_id=env_id
    AND b.parm_cd=1
    AND c.end_date != null
    AND c.report_cd=1
    AND cnvtstring(a.instance_cd)=b.parm_value
    AND b.report_seq=c.report_seq
  ELSEIF (ans_mode=2)
   WHERE a.environment_id=src_id
    AND b.parm_cd=1
    AND c.end_date != null
    AND c.report_cd=1
    AND cnvtstring(a.instance_cd)=b.parm_value
    AND b.report_seq=c.report_seq
  ELSE
  ENDIF
  DISTINCT INTO "nl:"
  c.report_seq, begin_date = format(c.begin_date,"DD-MMM-YYYY;;D"), user_notes = substring(1,30,c
   .user_notes)
  FROM ref_instance_id a,
   ref_report_parms_log b,
   ref_report_log c
  ORDER BY c.begin_date DESC
 ;end select
 CALL accept(11,40,"99999999.99;F",end_rep)
 SET end_rep = curaccept
 CALL clear(23,8,50)
 SET help = off
 SELECT DISTINCT INTO "nl:"
  c.report_seq, c.begin_date, c.user_notes
  FROM ref_report_log c
  WHERE c.report_seq=end_rep
  DETAIL
   end_date = format(c.begin_date,"DD-MMM-YYYY;;D"), e_date = c.begin_date, user_notes = substring(1,
    40,c.user_notes)
  WITH nocounter
 ;end select
 CALL text(12,40,end_date)
 CALL text(13,40,user_notes)
#accept_days_of_activity
 SET i_days_of_actual_activity = datetimecmp(e_date,s_date)
 SET temp_days = 0
 CALL text(14,40,cnvtstring(i_days_of_actual_activity))
 IF (i_days_of_actual_activity <= 0)
  CALL clear(15,05,90)
  CALL text(15,05,"Days of activity can not be negative or zero. Please re-start the process.")
  CALL pause(3)
  GO TO main
 ELSE
  SET temp_days = i_days_of_actual_activity
  CALL clear(15,05,90)
  CALL text(15,08,"Please override days_of_activity if necessary. Override? (Y/N)")
  CALL accept(15,80,"A;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  SET ans = curaccept
  IF (ans="Y")
   CALL accept(14,40,"99999999.99;F",i_days_of_actual_activity)
   SET i_days_of_actual_activity = curaccept
  ENDIF
  IF (i_days_of_actual_activity > temp_days)
   CALL clear(15,05,90)
   CALL text(15,05,
    "Days of activity can not be greater than the computed value. Please re-start the process.")
   CALL pause(3)
   GO TO accept_days_of_activity
  ENDIF
 ENDIF
 CALL accept(16,40,"P(1);CUS","1"
  WHERE curaccept IN ("1", "2"))
 SET mode1 = curaccept
 SET p1 = cnvtint(mode1)
 CALL accept(20,40,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET mode2 = curaccept
 IF (mode2="Y")
  SET p2 = 1
 ELSE
  SET p2 = 0
 ENDIF
 CALL accept(21,40,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET mode2 = curaccept
 IF (mode2="Y")
  SET dm_resize->modify_next_extent_size = 1
 ELSE
  SET dm_resize->modify_next_extent_size = 0
 ENDIF
 CALL accept(22,40,"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 SET mode2 = curaccept
 IF (mode2="Y")
  SET dm_resize->show_no_growth_objects = 1
 ELSE
  SET dm_resize->show_no_growth_objects = 0
 ENDIF
#continue
 CALL text(23,70,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,110,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO main
 ELSEIF (answer="Y")
  GO TO screen1
 ELSEIF (answer="X")
  GO TO end_script
 ELSE
  GO TO continue
 ENDIF
#screen1
 CALL video(r)
 CALL clear(1,1)
 CALL box(6,5,17,100)
 CALL video(n)
 IF ((dm_resize->modify_next_extent_size=1))
  CALL text(12,9,"Enter how many days each extent should last:")
 ENDIF
 IF (mode1="1")
  CALL text(10,09," Enter how much space you want to add:")
  CALL text(11,09," Enter measure unit (M(Meg), K(Kb):")
  CALL accept(10,80,"9(10)",space_added)
  SET space_added = cnvtreal(curaccept)
  CALL accept(11,80,"A;CU","M"
   WHERE curaccept IN ("M", "K"))
  SET unit = curaccept
  IF (unit="K")
   SET space_added = (space_added/ 1024.0)
  ENDIF
 ELSEIF (mode1="2")
  CALL text(10,09," Enter how many days you want the database to last:")
  CALL accept(10,80,"9(5)",days_to_last)
  SET days_to_last = cnvtreal(curaccept)
 ENDIF
 IF ((dm_resize->modify_next_extent_size=1))
  CALL accept(12,80,"9(10)",dm_resize->next_extent_size_days)
  SET dm_resize->next_extent_size_days = cnvtreal(curaccept)
 ENDIF
#finalize
 CALL text(23,70,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,110,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO screen1
 ELSEIF (answer="Y")
  SET dm_resize->mode = p1
  SET dm_resize->space_to_consume = space_added
  SET dm_resize->days_to_last = days_to_last
  SET dm_resize->actual_days_activity = i_days_of_actual_activity
  SET dm_resize->show_allocation_report = p2
  SET dm_resize->s_rep_seq = start_rep
  SET dm_resize->e_rep_seq = end_rep
  SET dm_resize->env_id = env_id
  EXECUTE dm_resizing
 ELSEIF (answer="X")
  GO TO end_script
 ELSE
  GO TO finalize
 ENDIF
#end_script
END GO

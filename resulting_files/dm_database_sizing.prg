CREATE PROGRAM dm_database_sizing
 PAINT
 SET env_id = 0.0
 SET environment_name = fillstring(20," ")
 SET db_name = fillstring(20," ")
 SET start_rep = 0
 SET end_rep = 0
 SET begin_date = fillstring(11," ")
 SET end_date = fillstring(11," ")
 SET s_date = cnvtdatetime(curdate,curtime3)
 SET e_date = cnvtdatetime(curdate,curtime3)
 SET max_size = 0.0
 SET mbyte = (1024.0 * 1024.0)
 SET partition_size = 0.0
 SET user_notes = fillstring(40," ")
 SET mode1 = fillstring(1," ")
 SET mode2 = fillstring(1," ")
 SET p1 = 0
 SET p2 = 0
 SET space_added = 0.0
 SET days_to_last = 0
 SET days_of_activity = 0
#main
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
 SET help =
 SELECT
  a.environment_id, a.db_name, b.environment_name
  FROM ref_instance_id a,
   dm_environment b
  WHERE a.environment_id=b.environment_id
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  a.environment_id
  FROM ref_instance_id a
  WHERE ref_instance_id=curaccept
 ;end select
 SET validate = 1
 CALL accept(5,40,"99999999.99;F",env_id)
 SET env_id = curaccept
 CALL clear(23,8,50)
 SET help = off
 SET validate = off
 SELECT INTO "nl:"
  a.environment_id, a.db_name, b.environment_name,
  b.data_file_partition_size, b.max_file_size
  FROM ref_instance_id a,
   dm_environment b
  WHERE a.environment_id=env_id
   AND a.environment_id=b.environment_id
  DETAIL
   environment_name = b.environment_name, db_name = a.db_name, partition_size = b
   .data_file_partition_size,
   max_size = (b.max_file_size * mbyte)
  WITH nocounter
 ;end select
 CALL text(6,40,environment_name)
 CALL text(23,8,"Please wait for the HELP box and select an item")
 SET cnt = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM ref_instance_id a,
   space_objects b,
   ref_report_log c
  WHERE a.environment_id=env_id
   AND a.instance_cd=b.instance_cd
   AND b.report_seq=c.report_seq
  DETAIL
   cnt = x
  WITH nocounter
 ;end select
 IF (cnt=0)
  CALL clear(23,8,60)
  CALL text(23,8,"No space reports for the environment.")
  GO TO end_script
 ENDIF
 SET help =
 SELECT DISTINCT INTO "nl:"
  c.report_seq, begin_date = format(c.begin_date,"DD-MMM-YYYY;;D"), user_notes = substring(1,40,c
   .user_notes)
  FROM ref_instance_id a,
   space_objects b,
   ref_report_log c
  WHERE a.environment_id=env_id
   AND a.instance_cd=b.instance_cd
   AND b.report_seq=c.report_seq
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
 SELECT DISTINCT INTO "nl:"
  c.report_seq, begin_date = format(c.begin_date,"DD-MMM-YYYY;;D"), user_notes = substring(1,30,c
   .user_notes)
  FROM ref_instance_id a,
   space_objects b,
   ref_report_log c
  WHERE a.environment_id=env_id
   AND a.instance_cd=b.instance_cd
   AND b.report_seq=c.report_seq
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
 SET days_of_activity = datetimecmp(e_date,s_date)
 CALL text(14,40,cnvtstring(days_of_activity))
 IF (days_of_activity <= 0)
  CALL text(15,05,"Days of activity can not be negative or zero. Please re-start the process.")
  CALL pause(5)
  GO TO main
 ELSE
  CALL text(15,08,"Please override days_of_activity if necessary. Override? (Y/N)")
  CALL accept(15,80,"A;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  SET ans = curaccept
  IF (ans="Y")
   CALL accept(14,40,"99999999.99;F",days_of_activity)
   SET days_of_activity = curaccept
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
#continue
 CALL text(23,70,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,110,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO main
 ELSEIF (answer="Y")
  EXECUTE FROM screen1 TO end_screen1
  GO TO end_script
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
 IF (mode1="1")
  CALL text(10,09," Enter how much space you want to add:")
  CALL text(11,09," Enter measure unit (M(Meg), K(Kb):")
  CALL accept(10,80,"9(10)",space_added)
  SET space_added = cnvtreal(curaccept)
  CALL accept(11,80,"A;CU","M"
   WHERE curaccept IN ("M", "K"))
  SET unit = curaccept
  IF (unit="M")
   SET space_added = ((space_added * 1024) * 1024)
  ELSE
   SET space_added = (space_added * 1024)
  ENDIF
  CALL text(09,110,"<EXECUTING>")
  EXECUTE dm_sizing value(p1), value(space_added), value(p2)
  CALL video(br)
  CALL text(09,110,"<COMPLETED>")
 ELSEIF (mode1="2")
  CALL text(10,09," Enter how many days you want the database to last:")
  CALL accept(10,80,"9(5)",days_to_last)
  SET days_to_last = curaccept
  CALL text(09,110,"<EXECUTING>")
  EXECUTE dm_sizing value(p1), value(days_to_last), value(p2)
  CALL video(br)
  CALL text(09,110,"<COMPLETED>")
 ENDIF
#end_screen1
#end_script
END GO

CREATE PROGRAM dba_migrate_2
 PAINT
#initail_start
 SET parser_buffer[3] = fillstring(100," ")
 SET first_check = "P"
 SET second_check = "P"
 SET third_check = "P"
 SET fourth_check = "P"
 SET env_id = 9999
 SET cnt = 0
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
     2 exist_flag = c1
 )
#initial_end
#main_1
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,42,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,130)
 CALL text(6,16,
  "First, will automatically check to see if ADMIN schema changes have been made for new Space Summary."
  )
 CALL pause(1)
 CALL text(16,50,"Are you ready to proceed?")
#decision_modify
 CALL text(21,53,"Continue (Y/N)?")
 CALL accept(21,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  GO TO end_99
 ELSEIF (answer="X")
  GO TO end_99
 ENDIF
#modify_end
#test_query_start
 SELECT INTO "nl:"
  column_name
  FROM dba_tab_columns
  WHERE table_name="SPACE_OBJECTS"
   AND column_name="FAILURE_FLAG"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET first_check = "F"
 ENDIF
 SELECT INTO "nl:"
  column_name
  FROM dba_tab_columns
  WHERE table_name="SPACE_OBJECTS"
   AND column_name="ANALYZE_FLAG"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET second_check = "F"
 ENDIF
 SELECT INTO "nl:"
  column_name
  FROM dba_tab_columns
  WHERE table_name="SPACE_OBJECTS"
   AND column_name="END_DT_TM"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET third_check = "F"
 ENDIF
 SELECT INTO "nl:"
  column_name
  FROM dba_tab_columns
  WHERE table_name="REF_INSTANCE_ID"
   AND column_name="ENVIRONMENT_ID"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET fourth_check = "F"
 ENDIF
#main_2
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,41,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,130)
 CALL text(6,20,"Alert")
 CALL text(6,39,"Notes")
 IF (first_check != "F")
  CALL text(7,21,
   " OK                The column Failure_Flag in table Space_Objects appears to be created.")
 ELSE
  CALL text(7,20,"FAILED             The column Failure_Flag in table Space_objects not created!")
 ENDIF
 IF (second_check != "F")
  CALL text(9,21,
   " OK               The column Analyze_Flag in table Space_Objects appears to be created.")
 ELSE
  CALL text(9,20,"FAILED             The column Analyze_Flag in table Space_objects not created!")
 ENDIF
 IF (third_check != "F")
  CALL text(11,21,
   " OK               The column End_Dt_Tm in table Space_Objects appears to be created.")
 ELSE
  CALL text(11,20,"FAILED          The column End_Dt_Tm in table Space_objects not created!")
 ENDIF
 IF (fourth_check != "F")
  CALL text(13,21,
   " OK               The column Environment_ID in table Ref_Instance_ID appears to be created.")
 ELSE
  CALL text(13,18,
   "FAILED              The column Environment_ID in table Ref_Instance_ID not created!")
 ENDIF
 IF (((first_check="F") OR (((second_check="F") OR (((third_check="F") OR (fourth_check="F")) )) )) )
  GO TO decision_error
 ELSE
  GO TO decision_modify_5
 ENDIF
#decision_error
 CALL text(18,30,"There are columns that have failed, press <ENTER> to exit this utility.")
 CALL text(19,35,"Schema changes must be made before this utility can continue!")
 CALL text(21,52,"Continue")
 CALL accept(21,70,"A;CU","Y"
  WHERE curaccept IN ("Y"))
 SET answer = curaccept
 IF (answer="Y")
  GO TO end_99
 ENDIF
#decision_modify_5
 CALL text(21,52,"Continue (Y/N)?")
 CALL accept(21,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  GO TO end_99
 ELSE
  GO TO main_4
 ENDIF
#main_4
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,42,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,130)
 CALL text(7,25,"Now will proceed with determining which rows in Ref_Instance_Id you would like")
 CALL text(8,25,"to delete or associate to a defined Environment from the table DM_ENV_MAINT")
 CALL text(11,18,
  "There will be an opportunity to modify rows after you have made your initial changes, therefore,")
 CALL text(12,21,
  "just proceed with making other changes even if you discover that you have made an error.")
#decision_modify_4
 CALL text(21,52,"Continue (Y/N)?")
 CALL accept(21,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  GO TO end_99
 ENDIF
#delete_or_add_env_id
 SELECT INTO "nl:"
  ref.instance_cd, ref.db_name, ref.instance_name,
  ref.node_address, ref.environment_id
  FROM ref_instance_id ref
  HEAD REPORT
   stat = alterlist(ref_id->qual,20)
  DETAIL
   cnt = (cnt+ 1), ref_id->qual[cnt].instance_cd = ref.instance_cd, ref_id->qual[cnt].db_name = ref
   .db_name,
   ref_id->qual[cnt].instance_name = ref.instance_name, ref_id->qual[cnt].node_address = ref
   .node_address, ref_id->qual[cnt].env_id = ref.environment_id
  FOOT REPORT
   stat = alterlist(ref_id->qual,cnt)
 ;end select
#delete_or_add_env_id_end
 SET cnt = 1
 SET total = size(ref_id->qual,5)
 FOR (cnt = 1 TO total)
  SELECT INTO "nl:"
   ref.report_seq
   FROM ref_report_parms_log ref
   WHERE ref.parm_cd=1
    AND ref.parm_value=cnvtstring(ref_id->qual[cnt].instance_cd)
  ;end select
  IF (curqual=0)
   SET ref_id->qual[cnt].exist_flag = "N"
  ELSE
   SET ref_id->qual[cnt].exist_flag = "Y"
  ENDIF
 ENDFOR
#new_cd_start
 FOR (cnt = 1 TO total)
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,18,132)
   CALL box(1,1,4,132)
   CALL clear(2,2,130)
   CALL text(2,33,"***   ASSOCIATE/DELETE ROWS FROM TABLE REF_INSTANCE_ID   ***")
   CALL clear(3,2,130)
   CALL text(14,06,"ENVIRONMENT_ID")
   CALL line(15,06,15)
   CALL text(14,28,"INSTANCE_CD")
   CALL line(15,28,15)
   CALL text(14,57,"Db_Name")
   CALL line(15,57,7)
   CALL text(14,73,"Instance_Name")
   CALL line(15,73,13)
   CALL text(14,90,"Node_Address")
   CALL line(15,90,12)
   CALL text(7,15,"Do you want to delete this row or")
   CALL text(8,15,"associate it with an environment?")
   CALL text(9,15,"Enter: A=Associate / D=Delete:")
   IF ((ref_id->qual[cnt].exist_flag="Y"))
    CALL video(b)
    CALL text(7,73,"!!!!!      WARNING       !!!!!")
    CALL text(8,73,"DBA Reports exist for this row")
    CALL text(9,73,"in the Ref_Instance_Id  table!")
    CALL video(n)
   ENDIF
   CALL text(16,33,cnvtstring(ref_id->qual[cnt].instance_cd))
   CALL text(16,58,ref_id->qual[cnt].db_name)
   CALL text(16,76,ref_id->qual[cnt].instance_name)
   CALL text(16,93,trim(ref_id->qual[cnt].node_address))
   CALL text(16,08,cnvtstring(ref_id->qual[cnt].env_id))
   CALL accept(9,46,"A;CU","A"
    WHERE curaccept IN ("A", "D"))
   SET answer = curaccept
   IF (answer="D")
    SET ref_id->qual[cnt].delete_flag = "D"
   ELSE
    SET help = pos(02,73,11,42)
    SET help =
    SELECT INTO "nl:"
     dm.environment_id, dm.database_name
     FROM dm_environment dm
     WITH nocounter
    ;end select
    SET validate =
    SELECT INTO "nl:"
     dm.environment_id
     WHERE dm.environment_id=curaccept
     WITH nocounter
    ;end select
    SET validate = 2
    CALL accept(16,08,"99999999.99;F",ref_id->qual[cnt].env_id)
    SET ref_id->qual[cnt].env_id = curaccept
    SET help = off
    SET validate = off
   ENDIF
 ENDFOR
#main_6
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,42,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,130)
 CALL text(06,33,"ENVIRONMENT_ID")
 CALL line(07,33,15)
 CALL text(06,56,"INSTANCE_CD")
 CALL line(07,56,11)
 CALL text(06,76,"Db_Name")
 CALL line(07,76,7)
 CALL text(06,90,"Instance_Name")
 CALL line(07,90,13)
 CALL text(06,108,"Node_Address")
 CALL line(07,108,12)
 CALL text(06,06,"Action Taken")
 CALL line(07,06,12)
 FOR (x = 1 TO total)
   CALL text((x+ 7),3,cnvtstring(x))
   IF ((ref_id->qual[x].delete_flag="D"))
    CALL text((x+ 7),09,"Deleted")
   ELSE
    CALL text((x+ 7),09,"Associated")
   ENDIF
   CALL text((x+ 7),40,cnvtstring(ref_id->qual[x].env_id))
   CALL text((x+ 7),63,cnvtstring(ref_id->qual[x].instance_cd))
   CALL text((x+ 7),78,ref_id->qual[x].db_name)
   CALL text((x+ 7),94,ref_id->qual[x].instance_name)
   CALL text((x+ 7),111,trim(ref_id->qual[x].node_address))
 ENDFOR
 CALL text(21,50,"Is this correct? Y/N?")
 CALL accept(21,92,"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  CALL clear(21,35,70)
  CALL text(21,35,"Enter the row number of the row you would like to modify:")
  CALL accept(21,95,"999",1
   WHERE curaccept <= total)
  SET choice = curaccept
  CALL clear(1,1)
  SET width = 132
  CALL box(1,1,18,132)
  CALL box(1,1,4,132)
  CALL clear(2,2,130)
  CALL text(2,45,"***   ASSOCIATE/DELETE ROWS FROM TABLE REF_INSTANCE_ID   ***")
  CALL clear(3,2,130)
  CALL text(14,06,"ENVIRONMENT_ID")
  CALL line(15,06,15)
  CALL text(14,28,"INSTANCE_CD")
  CALL line(15,28,15)
  CALL text(14,57,"Db_Name")
  CALL line(15,57,7)
  CALL text(14,73,"Instance_Name")
  CALL line(15,73,13)
  CALL text(14,90,"Node_Address")
  CALL line(15,90,12)
  CALL text(7,15,"Do you want to delete this row or")
  CALL text(8,15,"associate it with an environment?")
  CALL text(9,15,"Enter: A=Associate / D=Delete:")
  IF ((ref_id->qual[choice].exist_flag="Y"))
   CALL video(b)
   CALL text(7,73,"!!!!!      WARNING       !!!!!")
   CALL text(8,73,"DBA Reports exist for this row")
   CALL text(9,73,"in the Ref_Instance_Id  table!")
   CALL video(n)
  ENDIF
  CALL text(16,33,cnvtstring(ref_id->qual[choice].instance_cd))
  CALL text(16,58,ref_id->qual[choice].db_name)
  CALL text(16,76,ref_id->qual[choice].instance_name)
  CALL text(16,93,trim(ref_id->qual[choice].node_address))
  CALL text(16,08,cnvtstring(ref_id->qual[choice].env_id))
  CALL accept(9,46,"A;CU","A"
   WHERE curaccept IN ("A", "D"))
  SET answer = curaccept
  IF (answer="D")
   SET ref_id->qual[choice].delete_flag = "D"
  ELSE
   SET ref_id->qual[choice].delete_flag = "A"
   SET help = pos(02,73,11,42)
   SET help =
   SELECT INTO "nl:"
    dm.environment_id, dm.database_name
    FROM dm_environment dm
    WITH nocounter
   ;end select
   SET validate =
   SELECT INTO "nl:"
    dm.environment_id
    WHERE dm.environment_id=curaccept
    WITH nocounter
   ;end select
   SET validate = 2
   CALL accept(16,08,"99999999.99;F",ref_id->qual[choice].env_id)
   SET ref_id->qual[choice].env_id = curaccept
   SET help = off
   SET validate = off
  ENDIF
  GO TO main_6
 ENDIF
 FOR (x = 1 TO total)
   IF ((ref_id->qual[x].delete_flag="D"))
    DELETE  FROM ref_instance_id
     WHERE (instance_cd=ref_id->qual[x].instance_cd)
    ;end delete
   ELSE
    UPDATE  FROM ref_instance_id
     SET environment_id = ref_id->qual[x].env_id
     WHERE (instance_cd=ref_id->qual[x].instance_cd)
    ;end update
   ENDIF
 ENDFOR
#decision_modify_6
 CALL clear(21,36,75)
 CALL text(20,40,"Do you want to Commit or Rollback these changes?")
 CALL text(21,49,"Enter: C=Commit / R=Rollback")
 CALL accept(21,79,"A;CU","R"
  WHERE curaccept IN ("C", "R"))
 SET answer = curaccept
 IF (answer="R")
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
#main_7
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,40,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,130)
 CALL text(7,30,"The program will now check the Oracle database links that are used for the")
 CALL text(8,20,
  "Administrative database to connect to the target databases listed on the Ref_Instance_Id table")
#decision_modify_7
 CALL text(21,45,"Continue (Y/N)?")
 CALL accept(21,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  GO TO end_99
 ENDIF
 CALL clear(21,45,40)
 CALL text(21,61,"WORKING...")
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
 CALL clear(21,47,30)
 SET width = 132
 CALL clear(1,1)
 CALL box(1,1,22,131)
 CALL box(1,1,4,131)
 CALL clear(2,2,129)
 CALL text(2,40,"*****   HNA MILLENNIUM DATABASE TOOLKIT   *****")
 CALL clear(3,2,131)
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
 SET line_number = 8
 FOR (x = 1 TO total)
   IF ((ref_id->qual[x].delete_flag != "D"))
    CALL text(line_number,37,cnvtstring(ref_id->qual[x].env_id))
    CALL text(line_number,60,cnvtstring(ref_id->qual[x].instance_cd))
    CALL text(line_number,75,ref_id->qual[x].db_name)
    CALL text(line_number,91,ref_id->qual[x].instance_name)
    CALL text(line_number,108,trim(ref_id->qual[x].node_address))
    IF ((ref_id->qual[x].link_fail="Y"))
     CALL text(line_number,06,"Link Failed")
    ELSE
     CALL text(line_number,06,"Link OK")
    ENDIF
    SET line_number = (line_number+ 1)
   ENDIF
 ENDFOR
#decision_7
 CALL text(21,45,"Continue (Y/N)?")
 CALL accept(21,71,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET answer = curaccept
 IF (answer="N")
  GO TO end_99
 ENDIF
#end_99
 CALL clear(1,1)
END GO

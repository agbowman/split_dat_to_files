CREATE PROGRAM dm_create_schema:dba
 PAINT
 EXECUTE FROM initialize TO initialize_end
#main
 EXECUTE FROM paint_main_screen TO paint_main_screen_end
 CALL accept(23,110,"A;CU","X"
  WHERE curaccept IN ("G", "C", "X"))
 IF (curaccept="X")
  GO TO end_script
 ELSEIF (curaccept="C")
  EXECUTE FROM change_main_screen TO change_main_screen_end
  IF ((dm_create_schema->all_tablespaces=0))
   EXECUTE FROM tspace_screen_init TO tspace_screen_init_end
   SET tspace_answer = "X"
   WHILE (tspace_answer != "C")
    EXECUTE FROM tspace_screen_paint TO tspace_screen_paint_end
    IF (tspace_answer="A")
     EXECUTE FROM tspace_add TO tspace_add_end
    ELSEIF (tspace_answer="D")
     EXECUTE FROM tspace_del TO tspace_del_end
    ELSEIF (tspace_answer="N")
     SET current_top_tablespace = (current_top_tablespace+ max_tspace_per_screen)
     IF (((current_top_tablespace+ max_tspace_per_screen) > dm_create_schema->tspace_count))
      SET current_top_tablespace = ((dm_create_schema->tspace_count - max_tspace_per_screen)+ 1)
     ENDIF
    ELSEIF (tspace_answer="P")
     SET current_top_tablespace = (current_top_tablespace - max_tspace_per_screen)
     IF (current_top_tablespace < 1)
      SET current_top_tablespace = 1
     ENDIF
    ENDIF
   ENDWHILE
  ENDIF
 ELSEIF (curaccept="G")
  EXECUTE dm_create_schema_main
  SELECT
   *
   FROM dual
   DETAIL
    "**********  DM_CREATE_SCHEMA Summary *********", row + 3, "Target Environment Name ",
    environment_name, row + 1, "Target Environment ID ",
    dm_create_schema->environment_id, row + 2
    IF ((dm_create_schema->use_object_actual_size=1))
     "Objects sized based on actual space consumed", row + 1
    ELSE
     "Objects sized based on allocated space", row + 1
    ENDIF
    IF ((dm_create_schema->shrink_activity_objects=1))
     "Activity tables shrunk to 1 MByte or smaller", row + 1
    ELSE
     "Maintain the size of activity tables", row + 1
    ENDIF
    IF ((dm_create_schema->perform_analyze=1))
     "Objects analyzed", row + 1
    ELSE
     "Objects not analyzed", row + 1
    ENDIF
    "Tablespace size increase/decrease factor ", dm_create_schema->percent_tspace, row + 1
    IF ((dm_create_schema->preserve_source_iextent_size=1))
     "Initial extent sizes not modified", row + 2
    ELSE
     "Initial extent sizes modified to ", dm_create_schema->percent_initial_extent,
     " of object size.",
     row + 2
    ENDIF
    IF ((dm_create_schema->preserve_source_nextent_size=1))
     "Next extent sizes not modified", row + 2
    ELSE
     "Next extent sizes modified to ", dm_create_schema->percent_next_extent, " of object size.",
     row + 2
    ENDIF
    IF ((dm_create_schema->preserve_source_tspace_size=1))
     "Tablespace sizes not modified", row + 2
    ELSE
     "Tablespace sizes modified", row + 2
    ENDIF
    IF ((dm_create_schema->all_tablespaces=0))
     FOR (i = 1 TO dm_create_schema->tspace_count)
       "Tablespace ", dm_create_schema->tspace_list[i].tspace_name, " to ",
       dm_create_schema->tspace_list[i].new_tspace_name, row + 1
     ENDFOR
     row + 1
    ELSE
     "All tablespaces included", row + 1
    ENDIF
    "Space Used in Source Tablespaces ", dm_create_schema->source_tspace_allocated, row + 1,
    "Space Allocated in Source Environment = ", dm_create_schema->source_space_allocated, row + 1,
    "Space Used in Source Environment = ", dm_create_schema->source_space_used, row + 1,
    "Space Used in Target Tablespaces = ", dm_create_schema->target_tspace_allocated, row + 1,
    "Space Allocated in Target Environment = ", dm_create_schema->target_space_allocated, row + 1
   WITH nocounter
  ;end select
 ENDIF
 GO TO main
#top_main_screen
#initialize
 FREE DEFINE dm_create_schema
 RECORD dm_create_schema(
   1 use_object_actual_size = i4
   1 shrink_activity_objects = i4
   1 percent_tspace = f8
   1 perform_analyze = i4
   1 preserve_source_iextent_size = i4
   1 preserve_source_nextent_size = i4
   1 percent_initial_extent = f8
   1 percent_next_extent = f8
   1 preserve_source_tspace_size = i4
   1 environment_id = f8
   1 source_tspace_allocated = f8
   1 source_space_allocated = f8
   1 source_space_used = f8
   1 target_tspace_allocated = f8
   1 target_space_allocated = f8
   1 all_tablespaces = i4
   1 tspace_count = i4
   1 tspace_list[*]
     2 tspace_name = vc
     2 new_tspace_name = vc
 )
 SET dm_create_schema->tspace_count = 0
 SET environment_name = fillstring(30," ")
 SET dm_create_schema->use_object_actual_size = 1
 SET dm_create_schema->shrink_activity_objects = 1
 SET dm_create_schema->perform_analyze = 0
 SET dm_create_schema->preserve_source_iextent_size = 0
 SET dm_create_schema->preserve_source_nextent_size = 0
 SET dm_create_schema->preserve_source_tspace_size = 0
 SET dm_create_schema->percent_initial_extent = 0.10
 SET dm_create_schema->percent_next_extent = 0.10
 SET dm_create_schema->percent_tspace = 1.1
 SET dm_create_schema->all_tablespaces = 1
#initialize_end
#paint_main_screen
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,23,132)
 CALL clear(2,2,130)
 CALL text(2,40,"***   DM_CREATE_SCHEMA  ***")
 CALL clear(3,2,130)
 CALL text(5,2,"Size objects based on actual space consumed? ")
 IF ((dm_create_schema->use_object_actual_size=1))
  SET answer = "Y"
 ELSE
  SET answer = "N"
 ENDIF
 CALL text(5,50,answer)
 CALL text(7,2,"Shrink activity tables to 1 MByte or smaller? ")
 IF ((dm_create_schema->shrink_activity_objects=1))
  SET answer = "Y"
 ELSE
  SET answer = "N"
 ENDIF
 CALL text(7,50,answer)
 CALL text(9,2,"Perform analyze on all objects? ")
 IF ((dm_create_schema->perform_analyze=1))
  SET answer = "Y"
 ELSE
  SET answer = "N"
 ENDIF
 CALL text(9,50,answer)
 CALL text(11,2,"Tablespace size increase factor (1.10 = 10% growth) :")
 CALL text(11,55,format(dm_create_schema->percent_tspace,"##.##"))
 CALL text(13,2,"Modify initial extent sizes for objects? ")
 IF ((dm_create_schema->preserve_source_iextent_size=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL text(13,50,answer)
 CALL text(14,2,"Modify next extent sizes for objects? ")
 IF ((dm_create_schema->preserve_source_nextent_size=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL text(14,50,answer)
 CALL text(15,2,"Modify tablespace sizes? ")
 IF ((dm_create_schema->preserve_source_tspace_size=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL text(15,50,answer)
 CALL text(17,2,"Target Environment Name <HELP>:")
 CALL text(17,40,environment_name)
 CALL text(19,2,"Moving objects to new tablespaces? ")
 IF ((dm_create_schema->all_tablespaces=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL text(19,50,answer)
 CALL text(20,2,"Initial extent size of object size (0.10 = 10% of object size) :")
 CALL text(20,70,format(dm_create_schema->percent_initial_extent,"##.##"))
 CALL text(21,2,"Next extent size of object size (0.10 = 10% of object size) :")
 CALL text(21,70,format(dm_create_schema->percent_next_extent,"##.##"))
 CALL text(23,70,"Go, Change, eXit")
#paint_main_screen_end
#change_main_screen
 IF ((dm_create_schema->use_object_actual_size=1))
  SET answer = "Y"
 ELSE
  SET answer = "N"
 ENDIF
 CALL accept(5,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->use_object_actual_size = 1
 ELSE
  SET dm_create_schema->use_object_actual_size = 0
 ENDIF
 IF ((dm_create_schema->shrink_activity_objects=1))
  SET answer = "Y"
 ELSE
  SET answer = "N"
 ENDIF
 CALL accept(7,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->shrink_activity_objects = 1
 ELSE
  SET dm_create_schema->shrink_activity_objects = 0
 ENDIF
 IF ((dm_create_schema->perform_analyze=1))
  SET answer = "Y"
 ELSE
  SET answer = "N"
 ENDIF
 CALL accept(9,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->perform_analyze = 1
 ELSE
  SET dm_create_schema->perform_analyze = 0
 ENDIF
 CALL accept(11,55,"N(9)",dm_create_schema->percent_tspace)
 SET dm_create_schema->percent_tspace = cnvtreal(curaccept)
 IF ((dm_create_schema->preserve_source_iextent_size=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL accept(13,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->preserve_source_iextent_size = 0
 ELSE
  SET dm_create_schema->preserve_source_iextent_size = 1
 ENDIF
 IF ((dm_create_schema->preserve_source_nextent_size=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL accept(14,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->preserve_source_nextent_size = 0
 ELSE
  SET dm_create_schema->preserve_source_nextent_size = 1
 ENDIF
 IF ((dm_create_schema->preserve_source_tspace_size=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL accept(15,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->preserve_source_tspace_size = 0
 ELSE
  SET dm_create_schema->preserve_source_tspace_size = 1
 ENDIF
 SET help =
 SELECT
  b.environment_name, b.environment_id, b.database_name
  FROM dm_environment b
  ORDER BY b.environment_name
  WITH nocounter
 ;end select
 CALL accept(17,40,"P(20);CUF",environment_name)
 SET environment_name = curaccept
 SET help = off
 SET validate = off
 SELECT INTO "nl:"
  b.environment_id, b.database_name, b.environment_name
  FROM dm_environment b
  WHERE b.environment_name=environment_name
  DETAIL
   dm_create_schema->environment_id = b.environment_id
  WITH nocounter
 ;end select
 CALL text(17,80,build("Environment_id =",cnvtstring(dm_create_schema->environment_id)))
 IF ((dm_create_schema->all_tablespaces=1))
  SET answer = "N"
 ELSE
  SET answer = "Y"
 ENDIF
 CALL accept(19,50,"A;CU",answer
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET dm_create_schema->all_tablespaces = 0
 ELSE
  SET dm_create_schema->all_tablespaces = 1
 ENDIF
 CALL accept(20,70,"N(9)",dm_create_schema->percent_initial_extent)
 SET dm_create_schema->percent_initial_extent = cnvtreal(curaccept)
 CALL accept(21,70,"N(9)",dm_create_schema->percent_next_extent)
 SET dm_create_schema->percent_next_extent = cnvtreal(curaccept)
#change_main_screen_end
#tspace_screen_init
 SET current_top_tablespace = 1
 SET max_tspace_per_screen = 18
 SET current_bottom_tablespsace = 0
 SET tspace_list_top_row = 4
 SET answer = "X"
#tspace_screen_init_end
#top
#tspace_screen_paint
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,23,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(2,40,"***   Move Objects To New Tablespace  ***")
 CALL clear(3,2,130)
 CALL text(3,2,"Line #")
 CALL text(3,20,"From Tablespace")
 CALL text(3,60,"To Tablespace")
 IF ((dm_create_schema->tspace_count <= max_tspace_per_screen))
  SET current_bottom_tablespsace = dm_create_schema->tspace_count
 ELSEIF (((current_top_tablespace+ max_tspace_per_screen) > dm_create_schema->tspace_count))
  SET current_bottom_tablespsace = (current_top_tablespace+ max_tspace_per_screen)
 ELSE
  SET current_bottom_tablespsace = dm_create_schema->tspace_count
 ENDIF
 FOR (i = tspace_list_top_row TO (tspace_list_top_row+ max_tspace_per_screen))
   CALL clear(i,2,130)
   SET tablespace_index = (((current_top_tablespace - tspace_list_top_row) - 1)+ i)
   IF (tablespace_index >= current_top_tablespace
    AND tablespace_index <= current_bottom_tablespsace)
    CALL text(i,2,cnvtstring(tablespace_index))
    CALL text(i,20,dm_create_schema->tspace_list[tablespace_index].tspace_name)
    CALL text(i,60,dm_create_schema->tspace_list[tablespace_index].new_tspace_name)
   ENDIF
 ENDFOR
 IF (((current_top_tablespace+ max_tspace_per_screen) <= dm_create_schema->tspace_count)
  AND current_top_tablespace > 1)
  CALL text(23,70,"Next, Prev, Add, Delete, Continue")
  CALL accept(23,110,"A;CU","C"
   WHERE curaccept IN ("A", "D", "C", "P", "N"))
 ELSEIF (((current_top_tablespace+ max_tspace_per_screen) <= dm_create_schema->tspace_count))
  CALL text(23,70,"Next, Add, Delete, Continue")
  CALL accept(23,110,"A;CU","C"
   WHERE curaccept IN ("A", "D", "C", "N"))
 ELSEIF (current_top_tablespace > 1)
  CALL text(23,70,"Prev, Add, Delete, Continue")
  CALL accept(23,110,"A;CU","C"
   WHERE curaccept IN ("A", "D", "C", "P"))
 ELSEIF ((dm_create_schema->tspace_count > 0))
  CALL text(23,70,"Add, Delete, Continue")
  CALL accept(23,110,"A;CU","C"
   WHERE curaccept IN ("A", "D", "C"))
 ELSE
  CALL text(23,70,"Add, Continue")
  CALL accept(23,110,"A;CU","C"
   WHERE curaccept IN ("A", "C"))
 ENDIF
 SET tspace_answer = curaccept
#tspace_screen_paint_end
#tspace_del
 SET line_number = 0
 CALL video(r)
 CALL clear(1,1)
 CALL box(6,5,17,100)
 CALL video(n)
 CALL text(12,9,"Enter line # to delete:")
 CALL accept(12,60,"9(10)",line_number)
 SET line_number = cnvtint(curaccept)
 IF (line_number > 0
  AND (line_number <= dm_create_schema->tspace_count))
  FOR (i = line_number TO (dm_create_schema->tspace_count - 1))
   SET dm_create_schema->tspace_list[i].tspace_name = dm_create_schema->tspace_list[(i+ 1)].
   tspace_name
   SET dm_create_schema->tspace_list[i].new_tspace_name = dm_create_schema->tspace_list[(i+ 1)].
   new_tspace_name
  ENDFOR
  SET dm_create_schema->tspace_count = (dm_create_schema->tspace_count - 1)
  IF ((max_tspace_per_screen > dm_create_schema->tspace_count))
   SET current_top_tablespace = 1
  ELSEIF (((current_top_tablespace+ max_tspace_per_screen) > dm_create_schema->tspace_count))
   SET current_top_tablespace = ((dm_create_schema->tspace_count - max_tspace_per_screen)+ 1)
  ENDIF
 ENDIF
#tspace_del_end
#tspace_add
 CALL video(r)
 CALL clear(1,1)
 CALL box(6,5,17,100)
 CALL video(n)
 CALL text(10,9,"Enter old tablespace name (HELP):")
 CALL text(12,9,"Enter new tablespace name:")
 SET help =
 SELECT
  b.tablespace_name
  FROM dba_tablespaces b
  ORDER BY b.tablespace_name
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(10,50,"P(30);CUF")
 SET help = off
 SET validate = off
 SET dm_create_schema->tspace_count = (dm_create_schema->tspace_count+ 1)
 SET stat = alterlist(dm_create_schema->tspace_list,dm_create_schema->tspace_count)
 SET dm_create_schema->tspace_list[dm_create_schema->tspace_count].tspace_name = curaccept
 CALL accept(12,50,"P(30);CU")
 SET dm_create_schema->tspace_list[dm_create_schema->tspace_count].new_tspace_name = curaccept
#tspace_add_end
#tablespace_select_screen_end
#end_script
END GO

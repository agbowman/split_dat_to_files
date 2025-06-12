CREATE PROGRAM dm_product_list:dba
 PAINT
#0100_start
 CALL clear(1,1)
 SET env_id = 0
 SET invalid_env = 0
 WHILE (env_id=0)
   CALL clear(1,1)
   SET env_name = fillstring(6," ")
   IF (invalid_env=1)
    CALL text(8,1,"Invalid environment name.")
   ENDIF
   CALL text(10,1,"Enter the installation environment name (Q to quit):")
   CALL accept(11,1,"p(6);cu")
   SET env_name = curaccept
   IF (cnvtupper(trim(env_name))="Q")
    GO TO 10000_exit
   ENDIF
   SELECT INTO "nl:"
    de.environment_id
    FROM dm_environment de
    WHERE de.environment_name=cnvtupper(trim(env_name))
    DETAIL
     env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (env_id=0)
    SET invalid_env = 1
   ENDIF
 ENDWHILE
 FREE SET function_list
 RECORD function_list(
   1 function_name[*]
     2 fname = c255
     2 fid = i4
     2 installed = c1
   1 function_count = i4
   1 full_list[*]
     2 func_id = i4
     2 depend_ind = f8
   1 full_count = i4
 )
 SET stat = alterlist(function_list->function_name,10)
 SET function_list->function_count = 0
 SET function_list->full_count = 0
 SELECT INTO "nl:"
  dm.function_id, dm.description
  FROM dm_product_functions dm
  ORDER BY dm.description
  DETAIL
   function_list->function_count = (function_list->function_count+ 1)
   IF (mod(function_list->function_count,10)=1
    AND (function_list->function_count != 1))
    stat = alterlist(function_list->function_name,(function_list->function_count+ 9))
   ENDIF
   function_list->function_name[function_list->function_count].fname = dm.description, function_list
   ->function_name[function_list->function_count].fid = dm.function_id, function_list->function_name[
   function_list->function_count].installed = "N"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  def.function_id
  FROM dm_env_functions def
  WHERE environment_id=env_id
  DETAIL
   cnt = 0, found = 0
   WHILE ((cnt < function_list->function_count)
    AND found=0)
    cnt = (cnt+ 1),
    IF ((def.function_id=function_list->function_name[cnt].fid)
     AND def.dependency_ind != 1)
     function_list->function_name[cnt].installed = "Y", found = 1
    ENDIF
   ENDWHILE
  WITH nocounter
 ;end select
 SET top_displayed = 0
 SET number_per_column = 20
 SET number_per_screen = (number_per_column * 2)
 SET top_row = 2
#accept_screen_function
 SET tempstr = fillstring(40," ")
 CALL clear(24,1)
 FOR (cnt = (top_row - 1) TO number_per_column)
   CALL clear(cnt,1)
 ENDFOR
 SET finish = 0
 SET cnt = 0
 SET tempstr = "Line Product/Function     Installed"
 CALL text((top_row - 1),1,tempstr)
 CALL text((top_row - 1),41,tempstr)
 WHILE (finish=0
  AND cnt < number_per_screen
  AND (cnt < function_list->function_count))
   SET cnt = (cnt+ 1)
   SET tempstr = concat(substring(1,30,concat(cnvtstring((cnt+ top_displayed),2)," ",function_list->
      function_name[(cnt+ top_displayed)].fname))," ",function_list->function_name[(cnt+
    top_displayed)].installed)
   IF (cnt > number_per_column)
    CALL text(((top_row+ cnt) - number_per_column),41,tempstr)
   ELSE
    CALL text((top_row+ cnt),1,tempstr)
   ENDIF
 ENDWHILE
 SET screen_function = " "
 IF ((number_per_screen >= function_list->function_count))
  SET tempstr = "Change/Quit (C/Q)?"
  CALL text(24,1,tempstr)
  CALL accept(24,51,"p;cus","Q"
   WHERE curaccept IN ("C", "Q"))
 ELSEIF (top_displayed > 0
  AND ((top_displayed+ number_per_screen) < function_list->function_count))
  SET tempstr = "Change/Previous/Next/Quit (C/P/N/Q)?"
  CALL text(24,1,tempstr)
  CALL accept(24,51,"p;cus","Q"
   WHERE curaccept IN ("C", "P", "N", "Q"))
 ELSEIF (((top_displayed+ number_per_screen) < function_list->function_count))
  SET tempstr = "Change/Next/Quit (C/N/Q)?"
  CALL text(24,1,tempstr)
  CALL accept(24,51,"p;cus","Q"
   WHERE curaccept IN ("C", "N", "Q"))
 ELSE
  SET tempstr = "Change/Previous/Quit (C/P/Q)?"
  CALL text(24,1,tempstr)
  CALL accept(24,51,"p;cus","Q"
   WHERE curaccept IN ("C", "P", "Q"))
 ENDIF
 SET screen_function = curaccept
 CASE (curaccept)
  OF "C":
   CALL box(12,1,14,80)
   SET tempstr = "Enter the line number to change"
   CALL text(13,2,tempstr)
   CALL accept(13,40,"99;cs","0"
    WHERE cnvtint(curaccept) >= 0
     AND (cnvtint(curaccept) <= function_list->function_count))
   IF ((function_list->function_name[cnvtint(curaccept)].installed="N"))
    SET function_list->function_name[cnvtint(curaccept)].installed = "Y"
    SELECT DISTINCT INTO "nl:"
     dfd.required_function_id
     FROM dm_function_dependencies dfd
     WHERE (dfd.function_id=function_list->function_name[cnvtint(curaccept)].fid)
     DETAIL
      FOR (cnt = 1 TO function_list->function_count)
        IF ((function_list->function_name[cnt].fid=dfd.required_function_id))
         function_list->function_name[cnt].installed = "Y"
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
   ELSE
    SET function_list->function_name[cnvtint(curaccept)].installed = "N"
   ENDIF
  OF "P":
   SET top_displayed = (top_displayed - number_per_screen)
   IF (top_displayed < 0)
    SET top_displayed = 0
   ENDIF
  OF "N":
   SET top_displayed = (top_displayed+ number_per_screen)
   IF ((top_displayed > (function_list->function_count - number_per_screen)))
    SET top_displayed = (function_list->function_count - number_per_screen)
   ENDIF
  ELSE
   GO TO 9999_end
 ENDCASE
 CALL clear(24,1)
 GO TO accept_screen_function
#9999_end
 FOR (counter = 1 TO function_list->function_count)
   IF ((function_list->function_name[counter].installed="Y"))
    SET function_list->full_count = (function_list->full_count+ 1)
    SET stat = alterlist(function_list->full_list,function_list->full_count)
    SET function_list->full_list[function_list->full_count].func_id = function_list->function_name[
    counter].fid
    SET function_list->full_list[function_list->full_count].depend_ind = 0
   ENDIF
 ENDFOR
 FOR (counter2 = 1 TO function_list->full_count)
   SELECT INTO "nl:"
    fd.required_function_id
    FROM dm_function_dependencies fd
    WHERE (fd.function_id=function_list->full_list[counter2].func_id)
    DETAIL
     found = 0, counter3 = 1
     WHILE ((counter3 <= function_list->full_count)
      AND found != 1)
       IF ((function_list->full_list[counter3].func_id=fd.required_function_id))
        found = 1
       ELSE
        counter3 = (counter3+ 1)
       ENDIF
     ENDWHILE
     IF (found=0)
      function_list->full_count = (function_list->full_count+ 1), stat = alterlist(function_list->
       full_list,function_list->full_count), function_list->full_list[function_list->full_count].
      func_id = fd.required_function_id,
      function_list->full_list[function_list->full_count].depend_ind = 1
     ENDIF
   ;end select
 ENDFOR
 DELETE  FROM dm_env_functions def
  WHERE def.environment_id=env_id
  WITH nocounter
 ;end delete
 FOR (cnt = 1 TO function_list->full_count)
   IF ((function_list->full_list[cnt].depend_ind != 1))
    INSERT  FROM dm_env_functions def
     SET def.function_id = function_list->full_list[cnt].func_id, def.environment_id = env_id, def
      .dependency_ind = 0
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_env_functions def
     SET def.function_id = function_list->full_list[cnt].func_id, def.environment_id = env_id, def
      .dependency_ind = 1
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 COMMIT
 FOR (cnt = 1 TO 25)
   CALL clear(cnt,1)
 ENDFOR
#10000_exit
END GO

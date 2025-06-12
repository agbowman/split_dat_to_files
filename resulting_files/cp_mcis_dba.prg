CREATE PROGRAM cp_mcis:dba
 PAINT
 SET width = 132
 SET modify = system
 SET c1 = fillstring(100," ")
 SET c2 = fillstring(100," ")
 SET c3 = fillstring(100," ")
 SET where_clause = fillstring(300," ")
 SET dispdistdesc = 0
 SET dispdisttype = 0
 CALL clear(1,1)
 CALL box(2,1,23,109)
 CALL text(1,25,"CHARTING / MCIS_IND")
 CALL text(4,2,"  Enter Operation Batch Name")
 CALL text(5,2,"  Shift/F5 to see a list of Batch Names")
 SET help =
 SELECT DISTINCT INTO "nl:"
  co.batch_name
  FROM charting_operations co
  WHERE co.active_ind=1
  WITH nocounter
 ;end select
 CALL accept(6,6,"P(100);C"," ")
 SET help = off
 SET batchname = fillstring(100," ")
 SET batchname = trim(curaccept)
 SET found_it = 0
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  WHERE co.active_ind=1
   AND co.batch_name=batchname
  HEAD REPORT
   do_nothing = 0
  DETAIL
   found_it = 1
  WITH nocounter
 ;end select
 IF (found_it=1)
  SET do_nothing = 0
 ELSE
  EXECUTE FROM begin_clear TO end_clear
  GO TO end_program
 ENDIF
 SET action_type = 9
 CALL text(8,4,"Action: (1=View, 2=Modify, 9=Exit)")
 CALL accept(8,42,"p(1);c","1")
 SET action_type = cnvtint(curaccept)
 IF (action_type=1)
  EXECUTE FROM begin_clear TO end_clear
  EXECUTE FROM begin_view TO end_view
 ELSEIF (action_type=2)
  EXECUTE FROM begin_update TO end_update
  EXECUTE FROM begin_clear TO end_clear
  EXECUTE FROM begin_view TO end_view
 ELSEIF (action_type=9)
  EXECUTE FROM begin_clear TO end_clear
  GO TO end_program
 ELSE
  EXECUTE FROM begin_clear TO end_clear
  GO TO end_program
 ENDIF
#begin_view
 SET mcis_ind_value = 0
 SELECT INTO "nl:"
  co.param
  FROM charting_operations co
  WHERE co.batch_name=batchname
   AND co.active_ind=1
   AND co.param_type_flag=8
  HEAD REPORT
   do_nothing = 0
  DETAIL
   mcis_ind_value = cnvtint(co.param)
  WITH nocounter
 ;end select
 IF (mcis_ind_value=0)
  CALL text(3,2,"*************************************************************")
  CALL text(4,2,concat("*  MCIS VALUE FOR      ",trim(batchname),"      = 0 (Not Activated)"))
  CALL text(5,2,"*************************************************************")
 ELSEIF (mcis_ind_value=1)
  CALL text(3,2,"*************************************************************")
  CALL text(4,2,concat("*  MCIS VALUE FOR      ",trim(batchname),"      = 1 (Activated)"))
  CALL text(5,2,"*************************************************************")
 ELSE
  GO TO end_program
 ENDIF
 GO TO end_program
#end_view
#begin_update
 SET update_action = fillstring(1," ")
 CALL text(12,4,"Update Action: (A = Activate MCIS, I = Inactivate MCIS)")
 CALL accept(12,60,"p(1);c"," ")
 SET update_action = trim(cnvtupper(curaccept))
 IF (update_action="A")
  UPDATE  FROM charting_operations co
   SET co.param = "1"
   WHERE co.batch_name=batchname
    AND co.param_type_flag=8
  ;end update
  COMMIT
 ELSEIF (update_action="I")
  UPDATE  FROM charting_operations co
   SET co.param = "0"
   WHERE co.batch_name=batchname
    AND co.param_type_flag=8
  ;end update
  COMMIT
 ELSE
  EXECUTE FROM begin_clear TO end_clear
  GO TO end_program
 ENDIF
#end_update
 GO TO end_program
#begin_clear
 FOR (x = 1 TO 24)
   CALL clear(x,1,132)
 ENDFOR
#end_clear
#end_program
END GO

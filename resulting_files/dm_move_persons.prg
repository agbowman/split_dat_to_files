CREATE PROGRAM dm_move_persons
 PAINT
 SET sql_stmt_one = fillstring(132," ")
 CALL text(3,3,"Data Management -- Move Persons Program")
 CALL text(4,3,"-----------------------------------------")
 CALL text(5,3,"Input the number of persons to move:")
 CALL accept(5,40,"9999;C")
 SET number_to_move = curaccept
 CALL text(7,3,"Input the maximum number of children rows to move (0 for all children):")
 CALL accept(7,75,"9999;C","0")
 SET children_rows = curaccept
 CALL text(9,3,"Input the audit level (0 errors, 1 warnings, 2 inserts, 3 selects, 4 all):")
 CALL accept(9,79,"9999;C","0")
 SET audit_level = curaccept
 SET message = nowindow
 SET sql_stmt_one = concat('RDB ASIS(" begin cfp_move_persons(',number_to_move,",",children_rows,",",
  audit_level,'); end; ")'," GO")
 CALL parser(sql_stmt_one,1)
 SELECT
  dm.action, dm.text, dm.audit_dt_tm,
  dm.audit_id, dm.audit_level
  FROM dm_audit dm
  WHERE dm.audit_name="CFP_MOVE_PERSONS"
  ORDER BY dm.audit_id
  WITH nocounter
 ;end select
 CALL echo(number_to_move)
 CALL echo(children_rows)
 CALL echo(audit_level)
END GO

CREATE PROGRAM dm_online_schema_status
 SET v_reorg_id =  $1
 RECORD doss(
   1 v_proc_name = vc
   1 li_status = vc
   1 original_index_cnt = i4
   1 new_index_cnt = i4
   1 table_name = vc
   1 new_table_name = vc
   1 output_cnt = i4
   1 qual[*]
     2 str = vc
 )
 SUBROUTINE add_to_output(instr)
   SET doss->output_cnt = (doss->output_cnt+ 1)
   SET stat = alterlist(doss->qual,doss->output_cnt)
   SET doss->qual[doss->output_cnt].str = instr
 END ;Subroutine
 SUBROUTINE procinprog(v_reorg_id)
  SELECT INTO "nl:"
   FROM reorg_log rl
   WHERE rl.reorg_id=v_reorg_id
    AND (rl.cur_date=
   (SELECT
    max(rl2.cur_date)
    FROM reorg_log rl2
    WHERE rl2.reorg_id=v_reorg_id))
   DETAIL
    doss->v_proc_name = rl.procedure_name
   WITH nocounter
  ;end select
  IF ((((doss->v_proc_name="Cleanup")) OR ((doss->v_proc_name="Runreorg"))) )
   CALL add_to_output("Your reorg has completed")
  ELSE
   CALL add_to_output(concat(doss->v_proc_name," is currently executing."))
  ENDIF
 END ;Subroutine
 SUBROUTINE indexprog(v_reorg_id)
   SELECT INTO "nl:"
    y = count(*)
    FROM reorg_segments
    WHERE reorg_id=v_reorg_id
     AND object_type="INDEX"
     AND original_flag="N"
    DETAIL
     doss->original_index_cnt = y
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    y = count(*)
    FROM dba_indexes ui
    WHERE (ui.table_name=doss->new_table_name)
     AND ui.table_owner=currdbuser
    DETAIL
     doss->new_index_cnt = y
    WITH nocounter
   ;end select
   CALL add_to_output("------Index Information------")
   CALL add_to_output(concat(cnvtstring(doss->new_index_cnt)," out of ",cnvtstring(doss->
      original_index_cnt)," indexes have been built"))
   CALL add_to_output("-----------------------------")
 END ;Subroutine
 SUBROUTINE get_object_name(v_reorg_id)
   SELECT INTO "nl:"
    FROM reorg_segments rs
    WHERE rs.object_type="TABLE"
     AND rs.reorg_id=v_reorg_id
     AND rs.original_flag="N"
    DETAIL
     doss->new_table_name = build(rs.object_name,"$C"), doss->table_name = rs.object_name
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE reorgobjprog(v_reorg_id)
  SET objname = build(doss->table_name,"$REORG*")
  SELECT INTO "nl:"
   y = count(*)
   FROM dba_objects uo
   WHERE uo.object_name=patstring(objname)
    AND uo.owner=currdbuser
   HEAD REPORT
    SUBROUTINE add_to_output1(instr)
      doss->output_cnt = (doss->output_cnt+ 1), stat = alterlist(doss->qual,doss->output_cnt), doss->
      qual[doss->output_cnt].str = instr
    END ;Subroutine report
   DETAIL
    CALL add_to_output1("--Reorg Object Information---"),
    CALL add_to_output1(concat(cnvtstring(y)," reorg objects have been created.")),
    CALL add_to_output1("-----------------------------")
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE logctprog(v_reorg_id)
   SET log_table_name = build(doss->table_name,"$REORG_LOG")
   SET log_cnt = 0
   CALL parser(concat('execute oragen3 "',log_table_name,'" go'))
   CALL parser(concat('select into "nl:" y=count(*) from ',log_table_name,
     " detail log_cnt=y with nocounter go"))
   CALL add_to_output("----Log Count Information----")
   CALL add_to_output(concat("There have been ",cnvtstring(log_cnt),
     " updates made to the table since reorg began."))
   CALL add_to_output("-----------------------------")
 END ;Subroutine
 SELECT INTO "nl:"
  FROM reorg_objects ro
  WHERE ro.reorg_id=v_reorg_id
  DETAIL
   doss->li_status = ro.status
  WITH nocounter
 ;end select
 IF ((doss->li_status != "REORG FAILED"))
  CALL get_object_name(v_reorg_id)
  CALL procinprog(v_reorg_id)
  CALL indexprog(v_reorg_id)
  CALL reorgobjprog(v_reorg_id)
  CALL logctprog(v_reorg_id)
 ELSE
  CALL add_to_output("This reorg has failed - see log for details.")
 ENDIF
 CALL echo("***")
 FOR (oi = 1 TO doss->output_cnt)
   CALL echo(doss->qual[oi].str)
 ENDFOR
 CALL echo("***")
END GO

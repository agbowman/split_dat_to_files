CREATE PROGRAM dm_set_group_nbr:dba
 RECORD rsteps(
   1 step[*]
     2 process_id = f8
     2 group_nbr = i4
 )
 SET first_time = 1
 SET loop_nbr = 0
 SET step_cnt = 0
 WHILE (((first_time=1) OR (step_cnt=1)) )
   SET step_cnt = 0
   SET first_time = 0
   SET stat = alterlist(rsteps->step,1)
   SELECT INTO "nl:"
    p.process_id
    FROM dm_pkt_setup_process p,
     dm_pkt_setup_process p2
    WHERE p.run_after_process_id > 0
     AND p.run_after_process_id=p2.process_id
     AND p.active_ind=1
     AND p.from_rev=0
     AND p2.group_nbr > 0
     AND p2.active_ind=1
     AND p2.from_rev=0
     AND ((p.group_nbr != p2.group_nbr) OR (p.group_nbr = null))
     AND sqlpassthru(concat("(p.process_id, p.instance_nbr) in ",
      "(select p3.process_id, max(p3.instance_nbr) ","from dm_pkt_setup_process p3 ",
      "group by p3.process_id)"))
     AND sqlpassthru(concat("(p2.process_id, p2.instance_nbr) in ",
      "(select p4.process_id, max(p4.instance_nbr) ","from dm_pkt_setup_process p4 ",
      "group by p4.process_id)"))
    DETAIL
     IF (step_cnt=0)
      step_cnt = 1, rsteps->step[step_cnt].process_id = p.process_id, rsteps->step[step_cnt].
      group_nbr = p2.group_nbr
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_pkt_setup_process p
    SET p.group_nbr = rsteps->step[1].group_nbr
    WHERE (p.process_id=rsteps->step[1].process_id)
   ;end update
   SET loop_nbr = (loop_nbr+ 1)
   CALL echo(concat("Loop number = ",cnvtstring(loop_nbr)))
 ENDWHILE
 COMMIT
END GO

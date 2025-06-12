CREATE PROGRAM bhs_synch_ph_msg:dba
 SET c = 1
 SET x = 1000
 WHILE (x)
   CALL echo(build("x:",x))
   SET c = 0
   FREE RECORD temp
   RECORD temp(
     1 qual[*]
       2 task_id = f8
   )
   SELECT INTO "nl:"
    FROM task_activity t
    WHERE t.task_type_cd=2678
     AND t.task_status_cd=429
     AND  EXISTS (
    (SELECT
     ta.task_id
     FROM task_activity_assignment ta
     WHERE ta.task_id=t.task_id
      AND ((ta.task_status_cd+ 0)=420)))
     AND  NOT ( EXISTS (
    (SELECT
     ta2.task_id
     FROM task_activity_assignment ta2
     WHERE ta2.task_id=t.task_id
      AND ((ta2.task_status_cd+ 0) != 420))))
    HEAD REPORT
     c = 0, stat = alterlist(temp->qual,10)
    DETAIL
     c = (c+ 1)
     IF (mod(c,10)=1)
      stat = alterlist(temp->qual,(c+ 9))
     ENDIF
     temp->qual[c].task_id = t.task_id
    FOOT REPORT
     stat = alterlist(temp->qual,c)
    WITH maxread(t,100)
   ;end select
   SET c = size(temp->qual,5)
   CALL echo(build("if c:",c))
   IF (c > 0)
    UPDATE  FROM (dummyt d  WITH seq = value(c)),
      task_activity t
     SET t.task_status_cd = 420
     PLAN (d)
      JOIN (t
      WHERE (t.task_id=temp->qual[d.seq].task_id))
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
   SET x = (x - 1)
   IF (c=0)
    SET x = 0
   ENDIF
 ENDWHILE
#exit_prog
END GO

CREATE PROGRAM aps_end_ops_exception:dba
 SET orders_idx = 0
 FOR (orders_idx = 1 TO orders->qual_cnt)
   IF ((orders->qual[orders_idx].in_process_ind=1))
    SET orders->qual[orders_idx].in_process_ind = 0
    SET orders->ops_parent_id = orders->qual[orders_idx].id
    SET orders->type_ind = orders->qual[orders_idx].type_ind
    CALL echo(build("The order id:",orders->qual[orders_idx].id," has a status of failed = ",orders->
      qual[orders_idx].failed_ind))
    IF ((orders->qual[orders_idx].failed_ind=0))
     CALL deleteopsexception(0)
    ELSE
     CALL activateopsexception(0)
    ENDIF
   ENDIF
 ENDFOR
 IF ( NOT (validate(xxdebug)))
  COMMIT
 ENDIF
 SUBROUTINE activateopsexception(dummy15)
   UPDATE  FROM ap_ops_exception a
    SET a.active_ind = 1, a.updt_dt_tm = cnvtdatetime(curdate,curtime), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
     .updt_cnt+ 1)
    WHERE (orders->ops_parent_id=a.parent_id)
     AND (a.action_flag=orders->type_ind)
     AND a.active_ind=0
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo(build("Error activating in ap_ops_exception for parent_id = ",orders->ops_parent_id))
   ENDIF
   IF ((orders->type_ind=ot->specimen_order))
    CALL echo(build("Error processing order for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_order))
    CALL echo(build("Error processing order for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_order))
    CALL echo(build("Error processing order for processing_task_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->specimen_update))
    CALL echo(build("Error processing update for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_update))
    CALL echo(build("Error processing update for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_update))
    CALL echo(build("Error processing update for processing_task_id = ",orders->ops_parent_id))
   ELSE
    CALL echo(build("Unable to locate an order type of ",orders->type_ind,
      " in ap_ops_exception. Can't activate..."))
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteopsexception(dummy16)
   IF ((orders->type_ind=ot->specimen_order))
    CALL echo(build("Processing ops exception complete for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_order))
    CALL echo(build("Processing ops exception complete for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_order))
    CALL echo(build("Processing ops exception complete for processing_task_id = ",orders->
      ops_parent_id))
   ELSEIF ((orders->type_ind=ot->specimen_update))
    CALL echo(build("Processing ops exception complete for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_update))
    CALL echo(build("Processing ops exception complete for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_update))
    CALL echo(build("Processing ops exception complete for processing_task_id = ",orders->
      ops_parent_id))
   ELSE
    CALL echo(build("Unable to locate an order type of ",orders->type_ind,
      " in ap_ops_exception. Can't delete..."))
   ENDIF
   DELETE  FROM ap_ops_exception_detail opsd
    WHERE (orders->ops_parent_id=opsd.parent_id)
     AND (opsd.action_flag=orders->type_ind)
    WITH nocounter
   ;end delete
   DELETE  FROM ap_ops_exception ops
    WHERE (orders->ops_parent_id=ops.parent_id)
     AND (ops.action_flag=orders->type_ind)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    ROLLBACK
    CALL echo(build("Error deleting from ap_ops_exception for parent_id = ",orders->ops_parent_id))
   ELSE
    IF ( NOT (validate(xxdebug)))
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
END GO

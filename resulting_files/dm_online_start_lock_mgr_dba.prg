CREATE PROGRAM dm_online_start_lock_mgr:dba
 FREE RECORD dol_work
 RECORD dol_work(
   1 str = vc
   1 buffer[*]
     2 text = vc
 )
 SET stat = alterlist(dol_work->buffer,0)
 SET run_stat = 0
 SET dol_err_num = 0
 SET dol_err_msg = fillstring(132," ")
 CALL dol_push("declare")
 CALL dol_push("begin")
 CALL dol_push("  pkg_lock.lockdaemon;")
 CALL dol_push("end;")
 SET run_stat = dol_run(0)
 IF (run_stat > 0)
  CALL echo(dol_err_msg)
  CALL echo("Failed to start lockdaemon!")
  GO TO exit_script
 ENDIF
 SUBROUTINE dol_push(p_text)
   SET p_i = (size(dol_work->buffer,5)+ 1)
   SET stat = alterlist(dol_work->buffer,p_i)
   SET dol_work->buffer[p_i].text = p_text
 END ;Subroutine
 SUBROUTINE dol_run(r_dummy)
   FREE RECORD r_temp
   RECORD r_temp(
     1 text = vc
   )
   SET run_err_num = 0
   SET run_err_msg = fillstring(132," ")
   SET run_err_num = error(run_err_msg,1)
   FOR (r_i = 1 TO size(dol_work->buffer,5))
     IF (r_i=1)
      SET r_temp->text = "rdb asis(^"
     ELSE
      SET r_temp->text = "asis(^"
     ENDIF
     SET r_temp->text = concat(r_temp->text,dol_work->buffer[r_i].text,"^)")
     CALL parser(r_temp->text,1)
   ENDFOR
   CALL parser("end go",1)
   SET run_err_num = error(run_err_msg,0)
   IF (run_err_num > 0)
    SET dol_err_msg = substring((findstring("{}",run_err_msg)+ 2),130,run_err_msg)
   ENDIF
   SET dol_err_num = run_err_num
   SET stat = alterlist(dol_work->buffer,0)
   RETURN(run_err_num)
 END ;Subroutine
#exit_script
END GO

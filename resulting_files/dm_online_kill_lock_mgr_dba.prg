CREATE PROGRAM dm_online_kill_lock_mgr:dba
 FREE RECORD dok_work
 RECORD dok_work(
   1 str = vc
   1 buffer[*]
     2 text = vc
   1 sql[*]
     2 cmd = vc
 )
 SET stat = alterlist(dok_work->buffer,0)
 SET stat = alterlist(dok_work->sql,0)
 SET run_stat = 0
 SET dok_err_num = 0
 SET dok_err_msg = fillstring(132," ")
 SET last_reorg_id = 0.0
 SELECT INTO "nl:"
  xr = max(r.reorg_id)
  FROM reorg_log r
  DETAIL
   last_reorg_id = xr
  WITH nocounter
 ;end select
 IF (last_reorg_id > 0)
  CALL dok_push("declare")
  CALL dok_push("begin")
  CALL dok_push(concat("  pkg_reorg.KillLockMgr(",trim(cnvtstring(last_reorg_id),3),");"))
  CALL dok_push("end;")
  CALL dok_run(0)
 ENDIF
 SELECT INTO "nl:"
  FROM dba_jobs d
  WHERE d.schema_user="V500"
   AND d.what="pkg_lock.lockdaemon;"
  HEAD REPORT
   SUBROUTINE dok_push1(p_text)
     p_i = (size(dok_work->buffer,5)+ 1), stat = alterlist(dok_work->buffer,p_i), dok_work->buffer[
     p_i].text = p_text
   END ;Subroutine report
   ,
   CALL dok_push1("declare"),
   CALL dok_push1("  not_in_job_que   exception;"),
   CALL dok_push1("  pragma           exception_init(not_in_job_que, -23421);"),
   CALL dok_push1("begin")
  DETAIL
   CALL dok_push1(build("  dbms_job.remove(",cnvtint(d.job),");"))
  FOOT REPORT
   CALL dok_push1("exception"),
   CALL dok_push1("  when not_in_job_que"),
   CALL dok_push1("    then null;"),
   CALL dok_push1("end;")
  WITH nocounter
 ;end select
 IF (curqual)
  CALL dok_run(0)
 ENDIF
 SELECT INTO "nl:"
  FROM v$session v
  WHERE v.username="V500"
   AND v.client_info="LOCK DAEMON"
  HEAD REPORT
   SUBROUTINE dok_push2(p_text)
     p_i = (size(dok_work->buffer,5)+ 1), stat = alterlist(dok_work->buffer,p_i), dok_work->buffer[
     p_i].text = p_text
   END ;Subroutine report
   ,
   CALL dok_push2("declare"),
   CALL dok_push2("  kill_cur          integer;"),
   CALL dok_push2("  kill_ret          integer;"),
   CALL dok_push2("  marked_for_kill   exception;"),
   CALL dok_push2("  pragma            exception_init(marked_for_kill, -31);"),
   CALL dok_push2("begin")
  DETAIL
   dok_work->str = build("alter system kill session ''",cnvtint(v.sid),",",cnvtint(v.serial#),"''"),
   CALL dok_push2("  kill_cur := dbms_sql.open_cursor;"),
   CALL dok_push2(build("  dbms_sql.parse(kill_cur,'",dok_work->str,"', 1);")),
   CALL dok_push2("  kill_ret := dbms_sql.execute(kill_cur);"),
   CALL dok_push2("  dbms_sql.close_cursor(kill_cur);")
  FOOT REPORT
   CALL dok_push2("exception"),
   CALL dok_push2("  when marked_for_kill"),
   CALL dok_push2("    then null;"),
   CALL dok_push2("end;")
  WITH nocounter
 ;end select
 IF (curqual)
  CALL dok_run(0)
 ENDIF
 SUBROUTINE dok_push(p_text)
   SET p_i = (size(dok_work->buffer,5)+ 1)
   SET stat = alterlist(dok_work->buffer,p_i)
   SET dok_work->buffer[p_i].text = p_text
 END ;Subroutine
 SUBROUTINE dok_run(r_dummy)
   FREE RECORD r_temp
   RECORD r_temp(
     1 text = vc
   )
   SET run_err_num = 0
   SET run_err_msg = fillstring(132," ")
   SET run_err_num = error(run_err_msg,1)
   FOR (r_i = 1 TO size(dok_work->buffer,5))
     IF (r_i=1)
      SET r_temp->text = "rdb asis(^"
     ELSE
      SET r_temp->text = "asis(^"
     ENDIF
     SET r_temp->text = concat(r_temp->text,dok_work->buffer[r_i].text,"^)")
     CALL parser(r_temp->text,1)
   ENDFOR
   CALL parser(" end go",1)
   SET run_err_num = error(run_err_msg,0)
   IF (run_err_num > 0)
    SET dok_err_msg = substring((findstring("{}",run_err_msg)+ 2),130,run_err_msg)
   ENDIF
   SET dok_err_num = run_err_num
   SET stat = alterlist(dok_work->buffer,0)
   RETURN(run_err_num)
 END ;Subroutine
#exit_script
END GO

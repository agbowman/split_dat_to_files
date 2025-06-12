CREATE PROGRAM cv_upd_proc_act_subtype:dba
 PROMPT
  "Primary mnemonic of orders to update" = "*",
  "Update non-zero activity_subtypes?" = ""
  WITH prim_mnem, lock_nonzero
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply->status_data.status)=0)
  FREE SET reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE catalog_type_cardiovascul = f8 WITH constant(uar_get_code_by("MEANING",6000,"CARDIOVASCUL"))
 DECLARE block_sz = i4 WITH constant(100), protect
 DECLARE chunk_sz = i4 WITH constant(100), protect
 DECLARE block_start = i4 WITH noconstant(1), protect
 DECLARE procs_cnt = i4 WITH protect
 DECLARE proc_idx = i4 WITH protect
 DECLARE act_cnt = i4 WITH protect
 DECLARE act_idx = i4 WITH protect
 DECLARE lock_cnt = i4 WITH protect
 DECLARE lock_idx = i4 WITH protect
 DECLARE lock_pad = i4 WITH protect
 DECLARE modified_cnt = i4 WITH protect
 DECLARE no_lock_cnt = i4 WITH protect
 DECLARE chunk_cnt = i4 WITH protect
 DECLARE chunk_idx = i4 WITH protect
 DECLARE chunk_start = i4 WITH protect
 DECLARE chunk_offset = i4 WITH protect
 DECLARE block_cnt = i4 WITH protect
 DECLARE lock_nonzero_ind = i2 WITH protect
 IF (cnvtupper( $LOCK_NONZERO) IN ("Y", "YES"))
  SET lock_nonzero_ind = 1
 ENDIF
 CALL cv_log_msg(cv_info,build("lock_nonzero_ind=",lock_nonzero_ind))
 RECORD procs(
   1 activity_subtype[*]
     2 activity_subtype_cd = f8
     2 proc_cnt = i4
     2 cv_proc[*]
       3 cv_proc_id = f8
       3 updt_flag = i2
 )
 RECORD locks(
   1 lock[*]
     2 cv_proc_id = f8
 )
 SELECT
  IF (lock_nonzero_ind=1)
   PLAN (oc
    WHERE oc.catalog_type_cd=catalog_type_cardiovascul
     AND trim(oc.primary_mnemonic)=patstring( $PRIM_MNEM))
    JOIN (p
    WHERE p.catalog_cd=oc.catalog_cd
     AND p.activity_subtype_cd != oc.activity_subtype_cd)
  ELSE
  ENDIF
  INTO "nl:"
  FROM order_catalog oc,
   cv_proc p
  PLAN (oc
   WHERE oc.catalog_type_cd=catalog_type_cardiovascul
    AND oc.primary_mnemonic=patstring( $PRIM_MNEM)
    AND oc.activity_subtype_cd > 0.0)
   JOIN (p
   WHERE p.activity_subtype_cd=0.0
    AND p.catalog_cd=oc.catalog_cd)
  ORDER BY oc.activity_subtype_cd, p.cv_proc_id
  HEAD oc.activity_subtype_cd
   act_cnt += 1
   IF (mod(act_cnt,10)=1)
    stat = alterlist(procs->activity_subtype,(act_cnt+ 9))
   ENDIF
   procs->activity_subtype[act_cnt].activity_subtype_cd = oc.activity_subtype_cd, proc_cnt = 0,
   proc_pad = 0
  DETAIL
   proc_cnt += 1
   IF (proc_cnt > proc_pad)
    proc_pad += block_sz, stat = alterlist(procs->activity_subtype[act_cnt].cv_proc,proc_pad)
   ENDIF
   procs->activity_subtype[act_cnt].cv_proc[proc_cnt].cv_proc_id = p.cv_proc_id
  FOOT  oc.catalog_cd
   procs->activity_subtype[act_cnt].proc_cnt = proc_cnt
  FOOT REPORT
   stat = alterlist(procs->activity_subtype,act_cnt)
  WITH nocounter
 ;end select
 IF (act_cnt=0)
  CALL cv_log_stat(cv_audit,"SELECT","Z","CV_PROC","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (act_idx = 1 TO act_cnt)
   SET proc_cnt = procs->activity_subtype[act_idx].proc_cnt
   SET proc_pad = (proc_cnt+ ((block_sz - 1) - mod((proc_cnt - 1),block_sz)))
   FOR (proc_idx = (proc_cnt+ 1) TO proc_pad)
     SET procs->activity_subtype[act_idx].cv_proc[proc_idx].cv_proc_id = procs->activity_subtype[
     act_idx].cv_proc[proc_cnt].cv_proc_id
   ENDFOR
   CALL cv_log_msg(cv_info,build("proc_cnt=",proc_cnt,": for activity_subtype=",uar_get_code_display(
      procs->activity_subtype[act_idx].activity_subtype_cd)))
   SET block_cnt = (proc_pad/ block_sz)
   SET chunk_cnt = ceil((cnvtreal(block_cnt)/ chunk_sz))
   SET chunk_start = 1
   FOR (chunk_idx = 1 TO chunk_cnt)
     SET stat = initrec(locks)
     SET lock_cnt = 0
     SET lock_pad = 0
     SET lock_idx = 0
     SET chunk_offset = ((chunk_idx - 1) * chunk_sz)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(minval((block_cnt - chunk_offset),chunk_sz))),
       cv_proc p
      PLAN (d
       WHERE assign(block_start,evaluate(d.seq,1,((chunk_offset * block_sz)+ 1),(block_start+
         block_sz))))
       JOIN (p
       WHERE expand(proc_idx,block_start,((block_start+ block_sz) - 1),p.cv_proc_id,procs->
        activity_subtype[act_idx].cv_proc[proc_idx].cv_proc_id))
      DETAIL
       proc_idx = locateval(proc_idx,(1+ (((chunk_offset+ d.seq) - 1) * block_sz)),proc_cnt,p
        .cv_proc_id,procs->activity_subtype[act_idx].cv_proc[proc_idx].cv_proc_id), lock_cnt += 1
       IF (lock_cnt > lock_pad)
        lock_pad += block_sz, stat = alterlist(locks->lock,lock_pad)
       ENDIF
       locks->lock[lock_cnt].cv_proc_id = procs->activity_subtype[act_idx].cv_proc[proc_idx].
       cv_proc_id, procs->activity_subtype[act_idx].cv_proc[proc_idx].updt_flag = 1
      WITH forupdate(p)
     ;end select
     IF (lock_cnt > 0)
      FOR (lock_idx = (lock_cnt+ 1) TO lock_pad)
        SET locks->lock[lock_idx].cv_proc_id = locks->lock[lock_cnt].cv_proc_id
      ENDFOR
      UPDATE  FROM (dummyt d  WITH seq = value((lock_pad/ block_sz))),
        cv_proc p
       SET p.activity_subtype_cd = procs->activity_subtype[act_idx].activity_subtype_cd, p.updt_cnt
         = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
        p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
        cnvtdatetime(curdate,curtime)
       PLAN (d
        WHERE assign(block_start,evaluate(d.seq,1,1,(block_start+ block_sz))))
        JOIN (p
        WHERE expand(lock_idx,block_start,((block_start+ block_sz) - 1),p.cv_proc_id,locks->lock[
         lock_idx].cv_proc_id))
       WITH nocounter
      ;end update
      COMMIT
      CALL cv_log_msg(cv_audit,"Commited")
     ENDIF
   ENDFOR
   SET no_upd_cnt = 0
   SET proc_idx = locateval(proc_idx,1,proc_cnt,0,procs->activity_subtype[act_idx].cv_proc[proc_idx].
    updt_flag)
   WHILE (proc_idx > 0)
    SET no_upd_cnt += 1
    SET proc_idx = locateval(proc_idx,(proc_idx+ 1),proc_cnt,0,procs->activity_subtype[act_idx].
     cv_proc[proc_idx].updt_flag)
   ENDWHILE
   IF (no_upd_cnt > 0)
    CALL cv_log_msg(cv_audit,build2(no_upd_cnt," cv_proc rows could not be locked for update"))
   ENDIF
   SET stat = alterlist(procs->activity_subtype[act_idx].cv_proc,proc_cnt)
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL echo("Nothing to update")
 ELSEIF ((reply->status_data.status != "S"))
  CALL echorecord(reply)
  CALL echo("Failed")
 ENDIF
END GO

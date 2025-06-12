CREATE PROGRAM dm_stat_fix_memory_size:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE pgsize = f8 WITH noconstant(0.0)
 DECLARE failed = c1
 DECLARE errmsg = c132
 DECLARE errcode = i4 WITH noconstant(0)
 DECLARE mystat = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE batch_num = i4 WITH noconstant(0)
 DECLARE actual_size = i4 WITH noconstant(0)
 DECLARE expand_size = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE dclsetlogical(cmd=vc,cmdlog=vc) = null
 DECLARE updaterealmem(z=vc) = null
 DECLARE updatevirtmem(z=vc) = null
 DECLARE cleanupstats(z=vc) = null
 DECLARE getpgsize(z=vc) = null
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,0)
 SET failed = "F"
 SET num = 0
 RECORD temp(
   1 list[*]
     2 dm_stat_snap_id = f8
 )
 IF (cursys="AXP")
  CALL getpgsize("x")
  CALL updaterealmem("x")
  CALL updatevirtmem("x")
  CALL cleanupstats("x")
 ENDIF
 IF (cursys="AIX")
  CALL cleanupstats("x")
 ENDIF
 GO TO exit_program
 SUBROUTINE getpgsize(z)
  CALL dclsetlogical('write sys$output f$getsyi("page_size")',"PAGESIZE")
  SET pgsize = cnvtreal(logical("PAGESIZE"))
 END ;Subroutine
 SUBROUTINE updaterealmem(z)
   UPDATE  FROM dm_stat_snaps_values
    SET stat_number_val = ((stat_number_val * pgsize)/ (1024** 2)), stat_name = "MEM_REAL_TOTAL_MB",
     updt_task = reqinfo->updt_task
    WHERE stat_name="MEM_PHYS_SIZE"
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    GO TO real_update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE updatevirtmem(z)
   UPDATE  FROM dm_stat_snaps_values
    SET stat_number_val = ((stat_number_val * pgsize)/ (1024** 2)), stat_name = "MEM_VIRT_TOTAL_MB",
     updt_task = reqinfo->updt_task
    WHERE stat_name="MEM_VIRT_SIZE"
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    GO TO virt_update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE cleanupstats(z)
   SELECT INTO "nl:"
    a.dm_stat_snap_id
    FROM dm_stat_snaps a
    WHERE ((a.snapshot_type="RADIOLOGY_VOLUMES*") OR (a.snapshot_type=
    "ORDER_VOLUMES - BY CATALOG BY CARE SET"))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(temp->list,cnt), temp->list[cnt].dm_stat_snap_id = a
     .dm_stat_snap_id
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    GO TO select_child_error
   ENDIF
   IF (size(temp->list,5) < 500)
    SET batch_num = 50
   ELSE
    SET batch_num = 100
   ENDIF
   SET actual_size = size(temp->list,5)
   SET expand_size = (ceil((cnvtreal(actual_size)/ batch_num)) * batch_num)
   SET nstart = 1
   SET mystat = alterlist(temp->list,expand_size)
   FOR (idx = (actual_size+ 1) TO expand_size)
     SET temp->list[idx].dm_stat_snap_id = temp->list[actual_size].dm_stat_snap_id
   ENDFOR
   SET num = 0
   DELETE  FROM dm_stat_snaps_values b,
     (dummyt d  WITH seq = value((1+ ((expand_size - 1)/ batch_num))))
    SET b.seq = 1
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_num))))
     JOIN (b
     WHERE expand(num,nstart,(nstart+ (batch_num - 1)),b.dm_stat_snap_id,temp->list[num].
      dm_stat_snap_id))
    WITH maxcommit = 1000
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    GO TO cleanup_child_error
   ENDIF
   DELETE  FROM dm_stat_snaps a
    WHERE ((a.snapshot_type="RADIOLOGY_VOLUMES*") OR (a.snapshot_type=
    "ORDER_VOLUMES - BY CATALOG BY CARE SET"))
    WITH maxcommit = 1000
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    GO TO cleanup_parent_error
   ENDIF
   DELETE  FROM dm_stat_snaps_values b
    WHERE b.dm_stat_snap_id IN (
    (SELECT
     a.dm_stat_snap_id
     FROM dm_stat_snaps a
     WHERE ((a.snapshot_type="FIRSTNET VOLUMES"
      AND b.stat_name="PATIENT CHECKINS") OR (a.snapshot_type="ESM_MILLCONFIG"
      AND b.stat_name="ORACLE_VERSION")) ))
    WITH maxcommit = 1000
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    GO TO remaining_child_error
   ENDIF
 END ;Subroutine
 SUBROUTINE dclsetlogical(cmd,cmdlog)
   SET dclcmd = concat("pipe ",trim(cmd)," | ","( read sys$input Line1 ; define/job/nolog ",trim(
     cmdlog),
    " &Line1 )")
   SET mystat = 0
   SET dcllen = size(trim(dclcmd))
   SET myrc = dcl(trim(dclcmd),dcllen,mystat)
   IF (mystat=0)
    GO TO page_size_error
   ENDIF
 END ;Subroutine
#page_size_error
 SET readme_data->message = build("ERROR: retrieving PageSize, file missing or invalid rc[",myrc,
  "] cmd[",trim(dclcmd),"]")
 SET failed = "T"
 GO TO exit_program
#real_update_error
 SET readme_data->message = errmsg
 SET failed = "T"
 ROLLBACK
 GO TO exit_program
#virt_update_error
 SET readme_data->message = errmsg
 SET failed = "T"
 ROLLBACK
 GO TO exit_program
#select_child_error
 SET readme_data->message = errmsg
 SET failed = "T"
 GO TO exit_program
#cleanup_child_error
 SET readme_data->message = errmsg
 SET failed = "T"
 GO TO exit_program
#cleanup_parent_error
 SET readme_data->message = errmsg
 SET failed = "T"
 GO TO exit_program
#remaining_child_error
 SET readme_data->message = errmsg
 SET failed = "T"
 GO TO exit_program
#exit_program
 IF (failed="F")
  COMMIT
  SET readme_data->message = "Finished:  DM_STAT_FIX_MEMORY_SIZE.PRG finish successfully."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

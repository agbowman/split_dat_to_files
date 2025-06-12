CREATE PROGRAM dba_assign_db_disks:dba
 SET message = window
 SET dba_env_id = 0.0
 SET dba_db_version = 0
 SET dba_blank_line = fillstring(78," ")
 SET dba_op_sys = fillstring(3," ")
 SET dba_partition_size = 4
 SET dba_db_name = fillstring(6," ")
 SELECT INTO "nl:"
  e.environment_id, e.db_version, e.target_operating_system,
  e.database_name
  FROM dm_environment e
  WHERE e.environment_name=cnvtupper( $1)
  DETAIL
   dba_env_id = e.environment_id, dba_db_version = e.db_version, dba_op_sys = e
   .target_operating_system,
   dba_db_name = e.database_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO end_program
 ENDIF
 IF (dba_op_sys="AIX")
  UPDATE  FROM dm_env_files
   SET file_name = concat("temp_",file_name)
   WHERE environment_id=dba_env_id
   WITH nocounter
  ;end update
 ENDIF
 DELETE  FROM dm_env_files def
  WHERE def.environment_id=dba_env_id
   AND def.file_type IN ("SYSTEM", "ROLLBACK", "TEMP", "DEFAULT", "UNDO",
  "SYSAUX")
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_rollback_segments def
  WHERE def.environment_id=dba_env_id
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_db_config def
  WHERE def.environment_id=dba_env_id
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_control_files def
  WHERE def.environment_id=dba_env_id
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_redo_logs def
  WHERE def.environment_id=dba_env_id
  WITH nocounter
 ;end delete
 FREE SET temp
 RECORD temp(
   1 num = i4
   1 list[*]
     2 tablespace_name = vc
     2 file_name = vc
     2 file_size = f8
     2 ts_type = vc
 )
 SET temp->num = 0
 SELECT INTO "nl:"
  *
  FROM dm_size_db_ts dsdt
  WHERE dsdt.db_version=dba_db_version
  DETAIL
   temp->num = (temp->num+ 1)
   IF (mod(temp->num,10)=1)
    stat = alterlist(temp->list,(temp->num+ 9))
   ENDIF
   temp->list[temp->num].tablespace_name = dsdt.tablespace_name, temp->list[temp->num].file_name =
   dsdt.file_name, temp->list[temp->num].file_size = dsdt.file_size,
   temp->list[temp->num].ts_type = dsdt.ts_type
  WITH nocounter
 ;end select
 SET kount = 0
 SET answer = fillstring(30," ")
 SET help =
 SELECT
  ded.disk_name
  FROM dm_env_disk_farm ded
  WHERE ded.environment_id=dba_env_id
  WITH nocounter
 ;end select
 FOR (kount = 1 TO temp->num)
  SET valid_flag = 0
  IF ((((dm_env_import_request->target_undo_ind=1)
   AND (temp->list[kount].ts_type != "ROLLBACK")) OR ((dm_env_import_request->target_undo_ind=0)
   AND (temp->list[kount].ts_type != "UNDO"))) )
   WHILE (valid_flag=0)
     CALL text(24,01,dba_blank_line)
     CALL text(24,02,concat("Enter a disk for ",trim(temp->list[kount].file_name),"."))
     CALL text(22,03,"Disk:       ")
     CALL accept(22,8,"P(30);C",answer)
     SET answer = curaccept
     SELECT INTO "nl:"
      *
      FROM dm_env_disk_farm ded
      WHERE ded.environment_id=dba_env_id
       AND ded.disk_name=answer
      WITH nocounter
     ;end select
     IF (curqual != 0)
      SET valid_flag = 1
     ENDIF
   ENDWHILE
   INSERT  FROM dm_env_files def
    SET def.environment_id = dba_env_id, def.disk_name = answer, def.file_name = temp->list[kount].
     file_name,
     def.file_type = temp->list[kount].ts_type, def.file_size = temp->list[kount].file_size, def
     .tablespace_name = temp->list[kount].tablespace_name,
     def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
     def.updt_id = 0, def.updt_task = 0
    WITH nocounter
   ;end insert
   UPDATE  FROM dm_disk_farm ddf
    SET ddf.free_bytes = (ddf.free_bytes - temp->list[kount].file_size)
    WHERE ddf.disk_name=answer
   ;end update
   COMMIT
  ENDIF
 ENDFOR
 FREE SET temp
 RECORD temp(
   1 num = i4
   1 list[*]
     2 rollback_seg_name = c32
     2 tablespace_name = c32
     2 initial_extent = f8
     2 next_extent = f8
     2 min_extents = f8
     2 max_extents = f8
     2 optimal = f8
 )
 SET temp->num = 0
 SELECT INTO "nl:"
  *
  FROM dm_size_db_rollback_segs dsd
  WHERE dsd.db_version=dba_db_version
  DETAIL
   temp->num = (temp->num+ 1)
   IF (mod(temp->num,10)=1)
    stat = alterlist(temp->list,(temp->num+ 9))
   ENDIF
   temp->list[temp->num].rollback_seg_name = dsd.rollback_seg_name, temp->list[temp->num].
   tablespace_name = dsd.tablespace_name, temp->list[temp->num].initial_extent = dsd.initial_extent,
   temp->list[temp->num].next_extent = dsd.next_extent, temp->list[temp->num].min_extents = dsd
   .min_extents, temp->list[temp->num].max_extents = dsd.max_extents,
   temp->list[temp->num].optimal = dsd.optimal
  WITH nocounter
 ;end select
 SET kount = 0
 FOR (kount = 1 TO temp->num)
   INSERT  FROM dm_env_rollback_segments ders
    SET ders.environment_id = dba_env_id, ders.disk_name = null, ders.rollback_seg_name = temp->list[
     kount].rollback_seg_name,
     ders.initial_extent = temp->list[kount].initial_extent, ders.next_extent = temp->list[kount].
     next_extent, ders.min_extents = temp->list[kount].min_extents,
     ders.max_extents = temp->list[kount].max_extents, ders.optimal = temp->list[kount].optimal, ders
     .tablespace_name = temp->list[kount].tablespace_name,
     ders.updt_applctx = 0, ders.updt_dt_tm = cnvtdatetime(curdate,curtime3), ders.updt_cnt = 0,
     ders.updt_id = 0, ders.updt_task = 0
    WITH nocounter
   ;end insert
 ENDFOR
 FREE SET temp
 RECORD temp(
   1 file_name = c80
   1 decimal_pos = i4
   1 file_prefix = c80
   1 file_prefix_len = i4
   1 file_ext = c10
   1 file_ext_len = i4
   1 cntl_file_num = i4
   1 file_size = i4
   1 num = i4
   1 list[*]
     2 cntl_file_num = i4
     2 file_name = c80
     2 file_size = i4
 )
 SET temp->num = 0
 SELECT INTO "nl:"
  *
  FROM dm_size_db_cntl_files dsd
  WHERE dsd.db_version=dba_db_version
  DETAIL
   temp->num = dsd.cntl_file_num, stat = alterlist(temp->list,temp->num), temp->cntl_file_num = dsd
   .cntl_file_num,
   temp->file_name = dsd.file_name, temp->file_size = dsd.file_size
  WITH nocounter
 ;end select
 SET temp->decimal_pos = findstring(".",temp->file_name)
 IF ((temp->decimal_pos=0))
  SET temp->file_prefix_len = 80
  SET temp->file_ext_len = 0
 ELSE
  SET temp->file_prefix_len = (temp->decimal_pos - 1)
  SET temp->file_ext_len = (80 - temp->decimal_pos)
 ENDIF
 SET temp->file_prefix = substring(1,temp->file_prefix_len,temp->file_name)
 IF ((temp->file_ext_len=0))
  SET temp->file_ext = fillstring(80," ")
 ELSE
  SET temp->file_ext = substring((temp->decimal_pos+ 1),temp->file_ext_len,temp->file_name)
 ENDIF
 FOR (kount = 1 TO temp->num)
   SET temp->list[kount].cntl_file_num = kount
   SET kount_string = cnvtstring(kount,2,0,l)
   SET temp->list[kount].file_name = concat(trim(temp->file_prefix),kount_string,".",trim(temp->
     file_ext))
   SET temp->list[kount].file_size = temp->file_size
 ENDFOR
 UPDATE  FROM dm_environment de
  SET de.control_file_count = temp->num
  WHERE de.environment_id=dba_env_id
  WITH nocounter
 ;end update
 SET kount = 0
 FOR (kount = 1 TO temp->num)
   SET valid_flag = 0
   WHILE (valid_flag=0)
     CALL text(24,01,dba_blank_line)
     SET text_line = concat("Enter a disk for ",trim(temp->list[kount].file_name)," number ",trim(
       cnvtstring(temp->list[kount].cntl_file_num)),".")
     CALL text(24,02,text_line)
     CALL text(22,03,"Disk:       ")
     CALL accept(22,8,"P(30);C",answer)
     SET answer = curaccept
     SELECT INTO "nl:"
      *
      FROM dm_env_disk_farm ded
      WHERE ded.environment_id=dba_env_id
       AND ded.disk_name=answer
      WITH nocounter
     ;end select
     IF (curqual != 0)
      SET valid_flag = 1
     ENDIF
   ENDWHILE
   INSERT  FROM dm_env_control_files de
    SET de.environment_id = dba_env_id, de.disk_name = answer, de.cntl_file_num = temp->list[kount].
     cntl_file_num,
     de.file_name = temp->list[kount].file_name, de.file_size = temp->list[kount].file_size, de
     .updt_applctx = 0,
     de.updt_dt_tm = cnvtdatetime(curdate,curtime3), de.updt_cnt = 0, de.updt_id = 0,
     de.updt_task = 0
    WITH nocounter
   ;end insert
   UPDATE  FROM dm_disk_farm ddf
    SET ddf.free_bytes = (ddf.free_bytes - temp->list[kount].file_size)
    WHERE ddf.disk_name=answer
   ;end update
   COMMIT
 ENDFOR
 FREE SET temp
 RECORD temp(
   1 num = i4
   1 list[*]
     2 config_parm = c255
     2 parm_type = c30
     2 value = c255
 )
 SET temp->num = 0
 SELECT INTO "nl:"
  *
  FROM dm_size_db_config dsd
  WHERE dsd.db_version=dba_db_version
  DETAIL
   temp->num = (temp->num+ 1)
   IF (mod(temp->num,10)=1)
    stat = alterlist(temp->list,(temp->num+ 9))
   ENDIF
   temp->list[temp->num].config_parm = dsd.config_parm, temp->list[temp->num].parm_type = dsd
   .parm_type, temp->list[temp->num].value = dsd.value
  WITH nocounter
 ;end select
 SET kount = 0
 FOR (kount = 1 TO temp->num)
   INSERT  FROM dm_env_db_config de
    SET de.environment_id = dba_env_id, de.config_parm = temp->list[kount].config_parm, de.parm_type
      = temp->list[kount].parm_type,
     de.value = temp->list[kount].value, de.updt_applctx = 0, de.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     de.updt_cnt = 0, de.updt_id = 0, de.updt_task = 0
    WITH nocounter
   ;end insert
 ENDFOR
 FREE SET temp
 RECORD temp(
   1 file_name = c80
   1 decimal_pos = i4
   1 file_prefix = c80
   1 file_prefix_len = i4
   1 file_ext = c10
   1 file_ext_len = i4
   1 log_size = f8
   1 num = i4
   1 list[*]
     2 groups_num = f8
     2 members_num = f8
     2 file_name = c80
     2 log_size = f8
 )
 SET temp->num = 0
 SET groups_num = 0
 SET members_num = 0
 SELECT INTO "nl:"
  *
  FROM dm_size_db_redo_logs dsd
  WHERE dsd.db_version=dba_db_version
  DETAIL
   temp->num = (dsd.groups_num * dsd.members_num), stat = alterlist(temp->list,(temp->num+ 9)),
   groups_num = dsd.groups_num,
   members_num = dsd.members_num, temp->file_name = dsd.file_name, temp->log_size = dsd.log_size
  WITH nocounter
 ;end select
 UPDATE  FROM dm_environment de
  SET de.redo_log_groups = groups_num, de.redo_log_members = members_num
  WHERE de.environment_id=dba_env_id
  WITH nocounter
 ;end update
 SET count = 0
 SET place = 0
 SET temp->decimal_pos = findstring(".",temp->file_name)
 IF ((temp->decimal_pos=0))
  SET temp->file_prefix_len = 80
  SET temp->file_ext_len = 0
 ELSE
  SET temp->file_prefix_len = (temp->decimal_pos - 1)
  SET temp->file_ext_len = (80 - temp->decimal_pos)
 ENDIF
 SET temp->file_prefix = substring(1,temp->file_prefix_len,temp->file_name)
 IF ((temp->file_ext_len=0))
  SET temp->file_ext = fillstring(80," ")
 ELSE
  SET temp->file_ext = substring((temp->decimal_pos+ 1),temp->file_ext_len,temp->file_name)
 ENDIF
 FOR (count = 1 TO groups_num)
   FOR (kount = 1 TO members_num)
     SET place = (place+ 1)
     SET temp->list[place].groups_num = count
     SET temp->list[place].members_num = kount
     SET count_string = cnvtstring(count,2,0,l)
     SET kount_string = cnvtstring(kount,2,0,l)
     SET temp->list[place].file_name = concat(trim(temp->file_prefix),count_string,"_",kount_string,
      ".",
      trim(temp->file_ext))
     SET temp->list[place].log_size = temp->log_size
   ENDFOR
 ENDFOR
 SET kount = 0
 FOR (kount = 1 TO temp->num)
   SET valid_flag = 0
   WHILE (valid_flag=0)
     CALL text(24,01,dba_blank_line)
     SET group_line = concat(" Group: ",trim(cnvtstring(temp->list[kount].groups_num)))
     SET member_line = concat(" Member: ",trim(cnvtstring(temp->list[kount].members_num)))
     SET text_line = concat("Enter a disk for ",trim(temp->list[kount].file_name),group_line,
      member_line)
     CALL text(24,02,text_line)
     CALL text(22,03,"Disk:       ")
     CALL accept(22,8,"P(30);C",answer)
     SET answer = curaccept
     SELECT INTO "nl:"
      *
      FROM dm_env_disk_farm ded
      WHERE ded.environment_id=dba_env_id
       AND ded.disk_name=answer
      WITH nocounter
     ;end select
     IF (curqual != 0)
      SET valid_flag = 1
     ENDIF
   ENDWHILE
   INSERT  FROM dm_env_redo_logs de
    SET de.environment_id = dba_env_id, de.disk_name = answer, de.group_number = temp->list[kount].
     groups_num,
     de.file_name = temp->list[kount].file_name, de.log_size = temp->list[kount].log_size, de
     .member_number = temp->list[kount].members_num,
     de.updt_applctx = 0, de.updt_dt_tm = cnvtdatetime(curdate,curtime3), de.updt_cnt = 0,
     de.updt_id = 0, de.updt_task = 0
    WITH nocounter
   ;end insert
   UPDATE  FROM dm_disk_farm ddf
    SET ddf.free_bytes = (ddf.free_bytes - temp->list[kount].log_size)
    WHERE ddf.disk_name=answer
   ;end update
   COMMIT
 ENDFOR
 COMMIT
 IF (dba_op_sys="AIX")
  CALL aix_fix_file_name(1)
  CALL aix_fix_file_size(1)
 ENDIF
 CALL text(24,01,dba_blank_line)
 CALL text(24,02,"Database shell tablespace disk assignments are complete !")
 CALL pause(3)
 SUBROUTINE aix_fix_file_name(x)
   SET largest_pp = 0
   SET returned_value = 0
   SELECT INTO "nl:"
    a.file_size
    FROM dm_env_files a
    WHERE a.environment_id=dba_env_id
    DETAIL
     returned_value = ceil((a.file_size/ ((dba_partition_size * 1024) * 1024)))
     IF (returned_value > largest_pp)
      largest_pp = returned_value
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    a.file_size
    FROM dm_env_control_files a
    WHERE a.environment_id=dba_env_id
    DETAIL
     returned_value = (a.file_size/ ((dba_partition_size * 1024) * 1024))
     IF (returned_value > largest_pp)
      largest_pp = returned_value
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    a.log_size
    FROM dm_env_redo_logs a
    WHERE a.environment_id=dba_env_id
    DETAIL
     returned_value = (a.log_size/ ((dba_partition_size * 1024) * 1024))
     IF (returned_value > largest_pp)
      largest_pp = returned_value
     ENDIF
    WITH nocounter
   ;end select
   SET stat = memalloc(sequence_arr,largest_pp,"I4")
   SET indx = 1
   WHILE (indx <= largest_pp)
    SET sequence_arr[indx] = 0
    SET indx = (indx+ 1)
   ENDWHILE
   SET prefix_string = fillstring(80," ")
   SELECT INTO "aix_fix_name.ccl"
    a.file_name, a.file_size
    FROM dm_env_files a
    WHERE a.environment_id=dba_env_id
    HEAD REPORT
     pp = 0, t_seq = 0, t_size = 0
    DETAIL
     prefix_string = concat(trim(cnvtlower(dba_db_name)),"_"), t_size = 0, pp = ceil((a.file_size/ ((
      dba_partition_size * 1024) * 1024))),
     t_seq = sequence_arr[pp], t_size = (pp * dba_partition_size), col 0,
     "rdb update dm_env_files", row + 1, col 0,
     "set file_name = ",
     CALL print('"'),
     CALL print(trim(prefix_string)),
     t_size"####;p0", "_", t_seq"###;p0",
     CALL print('"'), row + 1, col 0,
     ", size_sequence = ", t_seq, row + 1,
     col 0, "where environment_id = ",
     CALL print(trim(cnvtstring(dba_env_id))),
     row + 1, col 0, "and file_name = ",
     CALL print('"'),
     CALL print(trim(a.file_name)),
     CALL print('"'),
     row + 1, col 0, "go",
     row + 1, sequence_arr[pp] = (t_seq+ 1)
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO "aix_fix_name.ccl"
    a.file_name, a.file_size, a.cntl_file_num
    FROM dm_env_control_files a
    WHERE a.environment_id=dba_env_id
    HEAD REPORT
     pp = 0, t_seq = 0, t_size = 0
    DETAIL
     prefix_string = concat(trim(cnvtlower(dba_db_name)),"_"), t_size = 0, pp = (a.file_size/ ((
     dba_partition_size * 1024) * 1024)),
     t_seq = sequence_arr[pp], t_size = (pp * dba_partition_size), col 0,
     "rdb update dm_env_control_files", row + 1, col 0,
     "set file_name = ",
     CALL print('"'),
     CALL print(trim(prefix_string)),
     t_size"####;p0", "_", t_seq"###;p0",
     CALL print('"'), row + 1, col 0,
     "where environment_id = ",
     CALL print(trim(cnvtstring(dba_env_id))), row + 1,
     col 0, "and file_name = ",
     CALL print('"'),
     CALL print(trim(a.file_name)),
     CALL print('"'), row + 1,
     col 0, "and cntl_file_num = ",
     CALL print(trim(cnvtstring(a.cntl_file_num))),
     row + 1, col 0, "go",
     row + 1, sequence_arr[pp] = (t_seq+ 1)
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
   SELECT INTO "aix_fix_name.ccl"
    a.log_size, a.file_name, a.group_number,
    a.member_number
    FROM dm_env_redo_logs a
    WHERE a.environment_id=dba_env_id
    HEAD REPORT
     pp = 0, t_seq = 0, t_size = 0
    DETAIL
     prefix_string = concat(trim(cnvtlower(dba_db_name)),"_"), t_size = 0, pp = (a.log_size/ ((
     dba_partition_size * 1024) * 1024)),
     t_seq = sequence_arr[pp], t_size = (pp * dba_partition_size), col 0,
     "rdb update dm_env_redo_logs", row + 1, col 0,
     "set file_name = ",
     CALL print('"'),
     CALL print(trim(prefix_string)),
     t_size"####;p0", "_", t_seq"###;p0",
     CALL print('"'), row + 1, col 0,
     "where environment_id = ",
     CALL print(trim(cnvtstring(dba_env_id))), row + 1,
     col 0, "and file_name = ",
     CALL print('"'),
     CALL print(trim(a.file_name)),
     CALL print('"'), row + 1,
     col 0, "and group_number = ",
     CALL print(trim(cnvtstring(a.group_number))),
     row + 1, col 0, "and member_number = ",
     CALL print(trim(cnvtstring(a.member_number))), row + 1, col 0,
     "go", row + 1, sequence_arr[pp] = (t_seq+ 1)
    FOOT REPORT
     col 0, "rdb commit go", row + 1
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
   CALL compile("aix_fix_name.ccl","aix_fix_name.log")
 END ;Subroutine
 SUBROUTINE aix_fix_file_size(x)
   UPDATE  FROM dm_env_files a
    SET a.file_size = (a.file_size - (1024 * 1024))
    WHERE a.environment_id=dba_env_id
     AND a.file_type IN ("SYSTEM", "ROLLBACK", "TEMP", "MISC", "DEFAULT",
    "OTHER", "UNDO", "SYSAUX")
   ;end update
   COMMIT
   UPDATE  FROM dm_env_control_files a
    SET a.file_size = (a.file_size - (1024 * 1024))
    WHERE a.environment_id=dba_env_id
   ;end update
   COMMIT
   UPDATE  FROM dm_env_redo_logs a
    SET a.log_size = (a.log_size - (1024 * 1024))
    WHERE a.environment_id=dba_env_id
   ;end update
   COMMIT
 END ;Subroutine
#end_program
 CALL clear(1,1)
END GO

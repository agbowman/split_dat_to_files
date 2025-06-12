CREATE PROGRAM dm_gen_fs_file_names2:dba
 SET max_short_table_name_len = 14
 SET max_routine_row_count = 10000
 SET fprefix = cnvtlower(fs_proc->file_prefix)
 SET rfiles->fcnt = 0
 SET routine_file_idx = 0
 SET stat = alterlist(rfiles->qual,0)
 IF ((((fs_proc->inhouse_ind=1)) OR ((fs_proc->online_ind=1))) )
  IF ((fs_proc->online_ind=1))
   SET max_short_table_name_len = 18
   SET fprefix = dgf_get_table_key(fs_proc->online_table_name,max_short_table_name_len)
  ENDIF
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
   HEAD REPORT
    rfiles->fcnt = 1, stat = alterlist(rfiles->qual,rfiles->fcnt), rfiles->qual[rfiles->fcnt].fname
     = fprefix,
    rfiles->qual[rfiles->fcnt].file2 = build(fprefix,"_2.dat"), rfiles->qual[rfiles->fcnt].file2d =
    build(fprefix,"_2.dat"), rfiles->qual[rfiles->fcnt].file3 = build(fprefix,"_3.dat"),
    rfiles->qual[rfiles->fcnt].file3d = build(fprefix,"_3.dat"), rfiles->qual[rfiles->fcnt].file4 =
    build(fprefix,"_4.dat"), rfiles->qual[rfiles->fcnt].file4 = build(fprefix,"_4.dat"),
    rfiles->qual[rfiles->fcnt].ddl_up_ind = 0, rfiles->qual[rfiles->fcnt].ddl_dn_ind = 0, rfiles->
    qual[rfiles->fcnt].compile_ind = 0,
    rfiles->qual[rfiles->fcnt].init_up_ind = 0, rfiles->qual[rfiles->fcnt].init_dn_ind = 0
   DETAIL
    tgtdb->tbl[d.seq].fname = fprefix, tgtdb->tbl[d.seq].file_idx = rfiles->fcnt
   WITH nocounter
  ;end select
 ELSE
  FOR (tti = 1 TO tgtdb->tbl_cnt)
    SET tgtdb->tbl[tti].fname = dgf_get_short_filename(fprefix,tgtdb->tbl[tti].tbl_name)
    SET found_ind = 0
    IF ((rfiles->fcnt > 0))
     SET file_cntr = 1
     WHILE (found_ind=0
      AND (file_cntr <= rfiles->fcnt))
      IF ((rfiles->qual[file_cntr].fname=tgtdb->tbl[tti].fname))
       SET found_ind = 1
       SET tgtdb->tbl[tti].file_idx = file_cntr
      ENDIF
      SET file_cntr = (file_cntr+ 1)
     ENDWHILE
    ENDIF
    IF (found_ind=0)
     CALL dgf_add_file(tgtdb->tbl[tti].fname)
     SET tgtdb->tbl[tti].file_idx = rfiles->fcnt
     IF (findstring("routine",rfiles->qual[rfiles->fcnt].fname) > 0)
      SET routine_file_idx = rfiles->fcnt
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((fs_proc->ocd_ind=0)
  AND (fs_proc->online_ind=0))
  IF ((tgtdb->sequence_cnt > 0)
   AND routine_file_idx=0)
   CALL dgf_add_file(build(fprefix,"_routine"))
  ENDIF
  CALL dgf_add_file(build(fprefix,"_dmsteps"))
 ENDIF
 SUBROUTINE dgf_add_file(daf_fname)
   SET rfiles->fcnt = (rfiles->fcnt+ 1)
   SET stat = alterlist(rfiles->qual,rfiles->fcnt)
   SET rfiles->qual[rfiles->fcnt].fname = cnvtlower(daf_fname)
   SET rfiles->qual[rfiles->fcnt].file2 = build(rfiles->qual[rfiles->fcnt].fname,"_2.dat")
   SET rfiles->qual[rfiles->fcnt].file2d = build(rfiles->qual[rfiles->fcnt].fname,"_2d.dat")
   SET rfiles->qual[rfiles->fcnt].file3 = build(rfiles->qual[rfiles->fcnt].fname,"_3.dat")
   SET rfiles->qual[rfiles->fcnt].file3d = build(rfiles->qual[rfiles->fcnt].fname,"_3d.dat")
   SET rfiles->qual[rfiles->fcnt].file4 = build(rfiles->qual[rfiles->fcnt].fname,"_4.dat")
   SET rfiles->qual[rfiles->fcnt].file4d = build(rfiles->qual[rfiles->fcnt].fname,"_4d.dat")
   IF ((fs_proc->env[1].oper_sys="VMS"))
    SET rfiles->qual[rfiles->fcnt].file1com = build(rfiles->qual[rfiles->fcnt].fname,"_1.com")
    SET rfiles->qual[rfiles->fcnt].file1log = build(rfiles->qual[rfiles->fcnt].fname,"_1.log")
    SET rfiles->qual[rfiles->fcnt].file1dcom = build(rfiles->qual[rfiles->fcnt].fname,"_1d.com")
    SET rfiles->qual[rfiles->fcnt].file1dlog = build(rfiles->qual[rfiles->fcnt].fname,"_1d.log")
   ELSE
    SET rfiles->qual[rfiles->fcnt].file1com = build(rfiles->qual[rfiles->fcnt].fname,"_1.ksh")
    SET rfiles->qual[rfiles->fcnt].file1dcom = build(rfiles->qual[rfiles->fcnt].fname,"_1d.ksh")
   ENDIF
   SET rfiles->qual[rfiles->fcnt].ddl_up_ind = 0
   SET rfiles->qual[rfiles->fcnt].ddl_dn_ind = 0
   SET rfiles->qual[rfiles->fcnt].compile_ind = 0
   SET rfiles->qual[rfiles->fcnt].init_up_ind = 0
   SET rfiles->qual[rfiles->fcnt].init_dn_ind = 0
 END ;Subroutine
 SUBROUTINE dgf_get_short_filename(dgf_prefix,dgf_tbl_name)
   SET dgf_total_len = ((max_file_prefix_len+ max_short_table_name_len)+ 1)
   SET dgf_short_fname = fillstring(value(dgf_total_len)," ")
   SET dgf_temp_fname = fillstring(value(dgf_total_len)," ")
   SET dgf_short_fname = build(dgf_prefix,"_",dgf_get_table_key(dgf_tbl_name,max_short_table_name_len
     ))
   SET dgf_fnd = 0
   FOR (fi = 1 TO rfiles->fcnt)
     IF ((dgf_short_fname=rfiles->qual[fi].fname))
      SET dgf_fnd = fi
      SET fi = rfiles->fcnt
     ENDIF
   ENDFOR
   IF (dgf_fnd=0)
    RETURN(trim(dgf_short_fname))
   ENDIF
   SET dgf_temp_fname = dgf_short_fname
   SET suffix_cnt = 1
   SET suffix_str = "2x"
   WHILE (dgf_fnd > 0)
     SET suffix_cnt = (suffix_cnt+ 1)
     SET suffix_str = trim(cnvtstring(suffix_cnt))
     SET dgf_short_fname = build(substring(1,(dgf_total_len - textlen(trim(suffix_str))),
       dgf_temp_fname),suffix_str)
     SET dgf_fnd = 0
     FOR (fi = 1 TO rfiles->fcnt)
       IF ((dgf_short_fname=rfiles->qual[fi].fname))
        SET dgf_fnd = fi
        SET fi = rfiles->fcnt
       ENDIF
     ENDFOR
   ENDWHILE
   RETURN(trim(dgf_short_fname))
 END ;Subroutine
 SUBROUTINE dgf_get_table_key(dgt_tbl_name,dgt_length)
   SET dgt_table_key = fillstring(value(dgt_length)," ")
   SET dgt_temp_key = fillstring(35," ")
   SET dgt_temp_key = cnvtalphanum(cnvtlower(dgt_tbl_name))
   IF (textlen(trim(dgt_temp_key)) <= dgt_length)
    RETURN(trim(dgt_temp_key))
   ENDIF
   SET underscore_cnt = 0
   SET last_underscore_pos = 0
   SET next_underscore_pos = 0
   SET next_underscore_pos = findstring("_",dgt_tbl_name,1)
   WHILE (next_underscore_pos > 0)
     SET underscore_cnt = (underscore_cnt+ 1)
     IF (underscore_cnt=1)
      IF (next_underscore_pos <= 3)
       SET dgt_temp_key = cnvtlower(substring(1,(next_underscore_pos - 1),dgt_tbl_name))
      ELSE
       SET dgt_temp_key = cnvtlower(substring(1,3,dgt_tbl_name))
      ENDIF
     ELSEIF (underscore_cnt <= 3)
      IF (((next_underscore_pos - last_underscore_pos) <= 3))
       SET dgt_temp_key = build(dgt_temp_key,cnvtlower(substring((last_underscore_pos+ 1),((
          next_underscore_pos - last_underscore_pos) - 1),dgt_tbl_name)))
      ELSE
       SET dgt_temp_key = build(dgt_temp_key,cnvtlower(substring((last_underscore_pos+ 1),3,
          dgt_tbl_name)))
      ENDIF
     ENDIF
     SET last_underscore_pos = next_underscore_pos
     SET next_underscore_pos = findstring("_",dgt_tbl_name,(last_underscore_pos+ 1))
   ENDWHILE
   IF (underscore_cnt > 0)
    SET cur_len = 0
    SET cur_len = textlen(trim(dgt_temp_key))
    SET dgt_table_key = build(dgt_temp_key,cnvtlower(substring((last_underscore_pos+ 1),(dgt_length
        - cur_len),dgt_tbl_name)))
   ELSE
    SET dgt_table_key = substring(1,dgt_length,cnvtlower(cnvtalphanum(dgt_tbl_name)))
   ENDIF
   RETURN(trim(dgt_table_key))
 END ;Subroutine
END GO

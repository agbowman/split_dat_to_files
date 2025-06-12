CREATE PROGRAM dm_gen_fs_file_names:dba
 SET fprefix = cnvtlower(fs_proc->file_prefix)
 SET rfiles->fcnt = 0
 IF ((((fs_proc->ocd_ind=1)) OR ((fs_proc->inhouse_ind=1))) )
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
    qual[rfiles->fcnt].compile_ind = 0
   DETAIL
    tgtdb->tbl[d.seq].fname = fprefix, tgtdb->tbl[d.seq].file_idx = rfiles->fcnt
   WITH nocounter
  ;end select
 ELSEIF ((fs_proc->ocd_ind=0))
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
    dm_tables_doc dtd
   PLAN (d)
    JOIN (dtd
    WHERE (dtd.table_name=tgtdb->tbl[d.seq].tbl_name))
   DETAIL
    IF ((tgtdb->tbl[d.seq].row_cnt > 100000))
     IF (dtd.data_model_section=null)
      tgtdb->tbl[d.seq].fname = build(fprefix,"_routine")
     ELSE
      tgtdb->tbl[d.seq].fname = build(fprefix,"_",substring(1,12,cnvtlower(cnvtalphanum(dtd
          .data_model_section))))
     ENDIF
    ELSE
     tgtdb->tbl[d.seq].fname = build(fprefix,"_routine")
    ENDIF
    found_ind = 0
    IF ((rfiles->fcnt > 0))
     file_cntr = 1
     WHILE (found_ind=0
      AND (file_cntr <= rfiles->fcnt))
      IF ((rfiles->qual[file_cntr].fname=tgtdb->tbl[d.seq].fname))
       found_ind = 1, tgtdb->tbl[d.seq].file_idx = file_cntr
      ENDIF
      ,file_cntr = (file_cntr+ 1)
     ENDWHILE
    ENDIF
    IF (found_ind=0)
     rfiles->fcnt = (rfiles->fcnt+ 1), stat = alterlist(rfiles->qual,rfiles->fcnt), rfiles->qual[
     rfiles->fcnt].fname = tgtdb->tbl[d.seq].fname,
     rfiles->qual[rfiles->fcnt].file2 = build(tgtdb->tbl[d.seq].fname,"_2.dat"), rfiles->qual[rfiles
     ->fcnt].file2d = build(tgtdb->tbl[d.seq].fname,"_2d.dat"), rfiles->qual[rfiles->fcnt].file3 =
     build(tgtdb->tbl[d.seq].fname,"_3.dat"),
     rfiles->qual[rfiles->fcnt].file3d = build(tgtdb->tbl[d.seq].fname,"_3d.dat"), rfiles->qual[
     rfiles->fcnt].file4 = build(tgtdb->tbl[d.seq].fname,"_4.dat"), rfiles->qual[rfiles->fcnt].file4d
      = build(tgtdb->tbl[d.seq].fname,"_4d.dat")
     IF ((fs_proc->env[1].oper_sys="VMS"))
      rfiles->qual[rfiles->fcnt].file1com = build(tgtdb->tbl[d.seq].fname,"_1.com"), rfiles->qual[
      rfiles->fcnt].file1log = build(tgtdb->tbl[d.seq].fname,"_1.log"), rfiles->qual[rfiles->fcnt].
      file1dcom = build(tgtdb->tbl[d.seq].fname,"_1d.com"),
      rfiles->qual[rfiles->fcnt].file1dlog = build(tgtdb->tbl[d.seq].fname,"_1d.log")
     ELSE
      rfiles->qual[rfiles->fcnt].file1com = build(tgtdb->tbl[d.seq].fname,"_1.ksh"), rfiles->qual[
      rfiles->fcnt].file1dcom = build(tgtdb->tbl[d.seq].fname,"_1d.ksh")
     ENDIF
     rfiles->qual[rfiles->fcnt].ddl_up_ind = 0, rfiles->qual[rfiles->fcnt].ddl_dn_ind = 0, rfiles->
     qual[rfiles->fcnt].compile_ind = 0,
     tgtdb->tbl[d.seq].file_idx = rfiles->fcnt
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
 IF ((fs_proc->ocd_ind=0)
  AND (fs_proc->inhouse_ind=0))
  SET rfiles->fcnt = (rfiles->fcnt+ 1)
  SET stat = alterlist(rfiles->qual,rfiles->fcnt)
  SET rfiles->qual[rfiles->fcnt].fname = build(fprefix,"_dmsteps")
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
 ENDIF
END GO

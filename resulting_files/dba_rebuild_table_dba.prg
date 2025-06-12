CREATE PROGRAM dba_rebuild_table:dba
 PAINT
 RECORD rebuild_table_req(
   1 database_name = vc
   1 oracle_version = i4
   1 owner = vc
   1 table_name = vc
   1 column_name = vc
   1 file_name = vc
   1 tablespace_name = vc
   1 initial_size = i4
   1 initial_units = c1
   1 next_size = i4
   1 next_units = c1
   1 pctincrease = i4
   1 minextents = i4
   1 maxextents = vc
   1 pct_used = i4
   1 pct_free = i4
   1 ini_trans = i4
   1 max_trans = i4
   1 freelists = i4
   1 freelist_groups = i4
   1 degree = vc
   1 instances = vc
   1 cache = vc
   1 continue = c1
   1 original_ts = vc
   1 valid_table = i4
   1 not_null_cons = c1
   1 nullable = c1
   1 extent_management = vc
   1 storage_parm_ind = i2
 )
 CALL get_oracle_version(1)
 RECORD misc(
   1 user_name = vc
   1 pwd = vc
   1 up = vc
 )
 RECORD lob_col(
   1 lob_ind = i2
   1 column_name = vc
   1 chunk = f8
   1 pctversion = f8
   1 cache = vc
   1 logging = vc
   1 in_row = vc
   1 pct_increase = f8
   1 buffer_pool = vc
 )
 SET lob_col->lob_ind = 0
 DECLARE col_list[255] = c30
 DECLARE drt_debug_ind = i4 WITH public, noconstant(0)
 DECLARE debug_file = vc
 DECLARE errmsg = c132
 DECLARE errcode = i4
 IF (validate(dm2_debug_flag,0) > 0)
  SET drt_debug_ind = 1
 ENDIF
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SET debug_file = "rebuild_debug.log"
 IF (drt_debug_ind=1)
  SELECT INTO value(debug_file)
   " "
   FROM dual
   DETAIL
    "DEBUGGING STARTS....."
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
 ENDIF
 CALL accept_userid_pwd(13)
 SET rebuild_table_req->database_name = "     "
 SET rebuild_table_req->valid_table = 0
 SELECT INTO "nl:"
  a.name
  FROM v$database a
  DETAIL
   rebuild_table_req->database_name = a.name
  WITH nocounter
 ;end select
#start
 CALL clear(1,1)
 CALL display_screen(1)
 IF ((rebuild_table_req->valid_table=0))
  SET rebuild_table_req->table_name = fillstring(30," ")
  SET rebuild_table_req->column_name = fillstring(30," ")
  SET rebuild_table_req->file_name = fillstring(22," ")
  SET rebuild_table_req->tablespace_name = fillstring(30," ")
  SET rebuild_table_req->original_ts = fillstring(30," ")
  SET rebuild_table_req->initial_units = fillstring(1," ")
  SET rebuild_table_req->next_units = fillstring(1," ")
  SET rebuild_table_req->initial_size = 0
  SET rebuild_table_req->next_size = 0
  SET rebuild_table_req->pctincrease = 0
  SET rebuild_table_req->minextents = 0
  SET rebuild_table_req->maxextents = fillstring(9," ")
  SET rebuild_table_req->pct_used = 0
  SET rebuild_table_req->pct_free = 0
  SET rebuild_table_req->ini_trans = 0
  SET rebuild_table_req->max_trans = 0
  SET rebuild_table_req->freelists = 0
  SET rebuild_table_req->freelist_groups = 0
  SET rebuild_table_req->degree = fillstring(10," ")
  SET rebuild_table_req->instances = fillstring(10," ")
  SET rebuild_table_req->cache = fillstring(5," ")
  IF ((rebuild_table_req->oracle_version=7))
   SET rebuild_table_req->not_null_cons = fillstring(1," ")
  ELSE
   SET rebuild_table_req->not_null_cons = "Y"
  ENDIF
  SET rebuild_table_req->nullable = fillstring(1," ")
  SET rebuild_table_req->storage_parm_ind = 0
 ENDIF
#entertablename
 IF ((rebuild_table_req->valid_table=0))
  CALL clear(23,05,74)
  CALL clear(24,05,74)
  SET table_count = 0
  SET init_loop = 1
  SET lob_col->lob_ind = 0
  WHILE (((table_count=0) OR (init_loop=1)) )
    IF (init_loop=1)
     SET init_loop = 0
    ENDIF
    CALL clear(23,05,74)
    CALL text(23,05,"HELP: Press <SHIFT><F5> ")
    SET help =
    SELECT INTO "nl:"
     a.table_name
     FROM user_tables a
     WITH nocounter
    ;end select
    CALL accept(08,17,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS","                              ")
    SET rebuild_table_req->table_name = curaccept
    SET help = off
    CALL clear(23,01,74)
    SELECT INTO "nl:"
     a.tablespace_name, a.initial_extent, a.next_extent,
     a.pct_increase, a.min_extents, a.max_extents,
     a.pct_free, a.pct_used, a.ini_trans,
     a.max_trans, a.freelists, a.freelist_groups,
     a.degree, a.instances, a.cache
     FROM user_tables a
     WHERE a.table_name=patstring(rebuild_table_req->table_name)
     DETAIL
      rebuild_table_req->tablespace_name = a.tablespace_name, rebuild_table_req->initial_size = a
      .initial_extent, rebuild_table_req->next_size = a.next_extent,
      rebuild_table_req->pctincrease = a.pct_increase, rebuild_table_req->original_ts = a
      .tablespace_name, rebuild_table_req->minextents = a.min_extents,
      rebuild_table_req->maxextents = cnvtstring(a.max_extents), rebuild_table_req->pct_used = a
      .pct_used, rebuild_table_req->pct_free = a.pct_free,
      rebuild_table_req->ini_trans = a.ini_trans, rebuild_table_req->max_trans = a.max_trans,
      rebuild_table_req->freelists = a.freelists,
      rebuild_table_req->freelist_groups = a.freelist_groups, rebuild_table_req->degree = a.degree,
      rebuild_table_req->instances = a.instances,
      rebuild_table_req->cache = a.cache
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
    SET table_count = curqual
    IF (table_count=0)
     CALL clear(23,05,74)
     CALL clear(24,05,74)
     IF ((rebuild_table_req->table_name="                              "))
      CALL text(23,05,"Table name required...")
     ELSE
      CALL text(23,05,"Table not found...")
     ENDIF
     CALL ask_continue(1)
     IF ((rebuild_table_req->continue="Y"))
      GO TO entertablename
     ELSE
      GO TO endprogram
     ENDIF
    ELSE
     SET rebuild_table_req->valid_table = 1
    ENDIF
    IF (check_for_lobs(0)=0)
     CALL clear(23,05,74)
     CALL text(14,05,"LOB columns in this table are stored in a separate tablespace.")
     CALL text(15,05,"This is not currently supported by DBA Toolkit.")
     CALL ask_continue(1)
     IF ((rebuild_table_req->continue="Y"))
      SET rebuild_table_req->valid_table = 0
      GO TO entertablename
     ELSE
      GO TO endprogram
     ENDIF
    ENDIF
  ENDWHILE
  CALL accept(10,17,"PPPPPPPPPPPPPPPPPPPPPP;cus","                              ")
  SET rebuild_table_req->file_name = curaccept
  CALL clear(23,05,74)
  CALL clear(24,05,74)
  IF ((rebuild_table_req->file_name="                              "))
   SET rebuild_table_req->valid_table = 0
   CALL text(23,05,"File name required...")
   CALL ask_continue(1)
   IF ((rebuild_table_req->continue="Y"))
    GO TO entertablename
   ELSE
    GO TO endprogram
   ENDIF
  ENDIF
  IF ((rebuild_table_req->oracle_version=7))
   SET rebuild_table_req->not_null_cons = "N"
   CALL accept(12,69,"P;CUS",rebuild_table_req->not_null_cons)
   SET rebuild_table_req->not_null_cons = curaccept
   CALL clear(23,05,74)
   CALL clear(24,05,74)
   IF ( NOT ((rebuild_table_req->not_null_cons IN ("N", "Y"))))
    SET rebuild_table_req->valid_table = 0
    CALL text(23,05,"Not Null Constraint must be N or Y")
    CALL ask_continue(1)
    IF ((rebuild_table_req->continue="Y"))
     GO TO entertablename
    ELSE
     GO TO endprogram
    ENDIF
   ENDIF
  ENDIF
  CALL clear(10,03,70)
 ENDIF
#selectoption
 CALL clear(08,17,40)
 CALL clear(10,3,60)
 CALL clear(12,3,70)
 CALL text(08,17,rebuild_table_req->table_name)
 CALL text(16,05,"1.  View extents information.")
 CALL text(17,05,"2.  Modify parameters and rebuild table.")
 CALL text(19,09,"Your selection: ")
 CALL accept(19,25,"9",0)
 CASE (curaccept)
  OF 1:
   CALL show_extent_info(1)
  OF 2:
   GO TO assignvalues
  OF 0:
   GO TO endprogram
  ELSE
   CALL clear(23,05,74)
   CALL text(23,05,"Invalid selection...")
   GO TO selectoption
 ENDCASE
 GO TO start
#assignvalues
 SET x = 9
 WHILE (x < 20)
  CALL clear(x,05,70)
  SET x = (x+ 1)
 ENDWHILE
 CALL text(09,05,"Enter values for the new table:")
 CALL text(11,3,"TABLESPACE: ")
 CALL text(12,3,"INITIAL: ")
 CALL text(12,24,"B/K/M")
 CALL text(12,45,"NEXT: ")
 CALL text(12,63,"B/K/M")
 CALL text(13,3,"MIN EXTENTS: ")
 CALL text(13,24,"MAX EXTENTS: ")
 CALL text(14,3,"PCTINCREASE: ")
 CALL text(14,24,"PCT FREE: ")
 CALL text(14,45,"PCT USED: ")
 CALL text(15,3,"FREELISTS: ")
 CALL text(15,24,"FREELIST GROUPS: ")
 CALL text(16,3,"DEGREE: ")
 CALL text(16,24,"INSTANCES: ")
 CALL text(16,45,"CACHE: ")
 CALL text(17,3,"INI TRANS: ")
 CALL text(17,24,"MAX TRANS: ")
#entertablespacename
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 SET ts_count = 0
 SET init_loop = 1
 WHILE (((ts_count=0) OR (init_loop=1)) )
   IF (init_loop=1)
    SET init_loop = 0
   ENDIF
   CALL clear(23,05,74)
   CALL text(23,05,"HELP: Press <SHIFT><F5> ")
   SET help =
   SELECT INTO "nl:"
    a.tablespace_name
    FROM dba_tablespaces a
    WITH nocounter
   ;end select
   CALL accept(11,15,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS",rebuild_table_req->tablespace_name)
   SET rebuild_table_req->tablespace_name = curaccept
   SET help = off
   CALL clear(23,01,74)
   SELECT INTO "nl:"
    cnt = count(*)
    FROM dba_tablespaces
    WHERE tablespace_name=patstring(rebuild_table_req->tablespace_name)
    DETAIL
     ts_count = cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (ts_count=0)
    CALL clear(23,05,74)
    CALL clear(24,05,74)
    IF (nullterm(rebuild_table_req->tablespace_name)="")
     CALL text(23,05,"Tablespace name required...")
    ELSE
     CALL text(23,05,"Tablespace not found...")
    ENDIF
    CALL ask_continue(1)
    IF ((rebuild_table_req->continue="Y"))
     GO TO entertablespacename
    ELSE
     GO TO endprogram
    ENDIF
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  d.extent_management
  FROM dba_tablespaces d
  WHERE d.tablespace_name=patstring(rebuild_table_req->tablespace_name)
  DETAIL
   rebuild_table_req->extent_management = d.extent_management
  WITH nocounter
 ;end select
#enterinitial
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(12,12,"99999999999",rebuild_table_req->initial_size)
 SET rebuild_table_req->initial_size = curaccept
 IF ((((rebuild_table_req->initial_size < 0)) OR ((rebuild_table_req->initial_size=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"Initial extent size required...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterinitial
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_table_req->initial_size > 0))
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
 SET rebuild_table_req->initial_units = "B"
 CALL accept(12,30,"P;CUS",rebuild_table_req->initial_units)
 SET rebuild_table_req->initial_units = curaccept
 IF ( NOT ((rebuild_table_req->initial_units IN ("B", "M", "K"))))
  CALL text(23,05,"Initial Units must be B, K, or M")
  CALL ask_continue(2)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterinitial
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
 IF ((rebuild_table_req->initial_units="B"))
  SET rebuild_table_req->initial_units = " "
 ENDIF
#enternext
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(12,51,"99999999999",rebuild_table_req->next_size)
 SET rebuild_table_req->next_size = curaccept
 IF ((((rebuild_table_req->next_size < 0)) OR ((rebuild_table_req->next_size=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"Next extend size required...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enternext
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_table_req->next_size > 0))
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
 SET rebuild_table_req->next_units = "B"
 CALL accept(12,69,"P;CUS",rebuild_table_req->next_units)
 SET rebuild_table_req->next_units = curaccept
 IF ( NOT ((rebuild_table_req->next_units IN ("B", "M", "K"))))
  CALL text(23,05,"Next Units must be B, K, or M")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enternext
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
 IF ((rebuild_table_req->next_units="B"))
  SET rebuild_table_req->next_units = " "
 ENDIF
#enterminextents
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(13,16,"999",rebuild_table_req->minextents)
 SET rebuild_table_req->minextents = curaccept
 IF ((((rebuild_table_req->minextents < 0)) OR ((rebuild_table_req->initial_size=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterminextents
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_table_req->minextents > 0))
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
#entermaxextents
 CALL accept(13,37,"PPPPPPPPPPP;CUS",rebuild_table_req->maxextents)
 SET rebuild_table_req->maxextents = curaccept
 SET max = cnvtint(rebuild_table_req->maxextents)
 IF (max <= 0)
  IF ((rebuild_table_req->maxextents="UNLIMITED"))
   SET rebuild_table_req->storage_parm_ind = 1
  ELSEIF ((rebuild_table_req->extent_management="LOCAL")
   AND isnumeric(rebuild_table_req->maxextents) > 0
   AND cnvtint(rebuild_table_req->maxextents)=0)
   SET rebuild_table_req->storage_parm_ind = 0
  ELSE
   IF ((rebuild_table_req->extent_management="LOCAL"))
    CALL text(23,05,"This value should be 0 or greater, or UNLIMITED")
   ELSE
    CALL text(23,05,"This value should be greater than 0, or UNLIMITED")
   ENDIF
  ENDIF
 ELSEIF (max > 0)
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
#enterpctincrease
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(14,16,"99",rebuild_table_req->pctincrease)
 SET rebuild_table_req->pctincrease = curaccept
 IF ((rebuild_table_req->pctincrease < 0))
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterpctincrease
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_table_req->pctincrease >= 0))
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
#enterpctfree
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(14,34,"999",rebuild_table_req->pct_free)
 SET rebuild_table_req->pct_free = curaccept
 IF ((((rebuild_table_req->pct_free < 0)) OR ((rebuild_table_req->pct_free=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterpctfree
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterpctused
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(14,55,"999",rebuild_table_req->pct_used)
 SET rebuild_table_req->pct_used = curaccept
 IF ((((rebuild_table_req->pct_used < 0)) OR ((rebuild_table_req->pct_used=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterpctused
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterfreelists
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(15,14,"999",rebuild_table_req->freelists)
 SET rebuild_table_req->freelists = curaccept
 IF ((((rebuild_table_req->freelists < 0)) OR ((rebuild_table_req->freelists=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterfreelists
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_table_req->freelists > 0))
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
#enterfreelist_groups
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(15,41,"999",rebuild_table_req->freelist_groups)
 SET rebuild_table_req->freelist_groups = curaccept
 IF ((((rebuild_table_req->freelist_groups < 0)) OR ((rebuild_table_req->freelist_groups=0)
  AND (rebuild_table_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterfreelist_groups
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_table_req->freelist_groups > 0))
  SET rebuild_table_req->storage_parm_ind = 1
 ENDIF
 CALL accept(16,11,"PPPPPPPPP;CUS",trim(rebuild_table_req->degree,2))
 CALL accept(16,35,"PPPPPPPPP;CUS",trim(rebuild_table_req->instances,2))
 CALL accept(16,52,"PPPPP;CUS",trim(rebuild_table_req->cache,2))
#enterinitrans
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(17,14,"999",rebuild_table_req->ini_trans)
 SET rebuild_table_req->ini_trans = curaccept
 IF ((rebuild_table_req->ini_trans <= 0))
  CALL text(23,05,"This value should be greater than 0...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO enterinitrans
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#entermaxtrans
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL accept(17,35,"999",rebuild_table_req->max_trans)
 SET rebuild_table_req->max_trans = curaccept
 IF ((rebuild_table_req->max_trans <= 0))
  CALL text(23,05,"This value should be greater than 0...")
  CALL ask_continue(1)
  IF ((rebuild_table_req->continue="Y"))
   GO TO entermaxtrans
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#confirmvalues
 CALL clear(23,05,74)
 CALL text(23,05,"Please confirm the above information before continue. Continue(Y/N)?")
 CALL accept(23,74,"P;CUS","N")
 IF (curaccept="Y")
  CALL build_script(1)
 ELSE
  GO TO endprogram
 ENDIF
 SET rebuild_table_req->valid_table = 0
 GO TO start
 SUBROUTINE build_script(y)
   SET filename1 = concat(cnvtlower(rebuild_table_req->file_name),"1.ccl")
   SET filename2 = concat(cnvtlower(rebuild_table_req->file_name),"2.ccl")
   SET filename3 = concat(cnvtlower(rebuild_table_req->file_name),"3.ccl")
   SET exp_pfile = concat(cnvtlower(rebuild_table_req->file_name),"_exp.prm")
   SET imp_pfile = concat(cnvtlower(rebuild_table_req->file_name),"_imp.prm")
   CALL build_exp_parm(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running build_exp_parm....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL export_table(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running export_table....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL drop_child_foreign_keys(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running drop_child_foreign_keys....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL drop_and_create_table(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running drop_and_create_table....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL import_table(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running import_table....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL create_idx(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running create_idx....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL create_pk(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running create_pk....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL create_ak(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running create_ak....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL create_fk(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running create_fk....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL create_disabled_constr(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running create_disabled_constr....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL build_imp_parm(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running build_imp_parm....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   CALL create_child_fk(1)
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running create_child_fk....", row + 1, errmsg
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   SELECT INTO value(filename3)
    " "
    FROM dual
    HEAD REPORT
     row + 1, "reset"
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE build_exp_parm(bep)
  SET fn = cnvtlower(rebuild_table_req->file_name)
  SELECT INTO value(exp_pfile)
   " "
   FROM dual
   FOOT REPORT
    col 0, "USERID=", misc->up,
    row + 1, "buffer=1000000", row + 1,
    "file=", fn, ".dmp",
    row + 1, "compress=n", row + 1,
    "constraints=n", row + 1, "tables=(",
    rebuild_table_req->table_name, ")", row + 1,
    "log=", fn, "_exp.log"
   WITH nocounter, format = stream, noheading,
    formfeed = none, maxcol = 512, maxrow = 1
  ;end select
 END ;Subroutine
 SUBROUTINE export_table(et)
   SELECT INTO value(filename1)
    " "
    FROM dual
    HEAD REPORT
     ";***************************************************************************************", row
      + 1, "; Export the table and verify that the export worked successfully ",
     row + 1,
     ";***************************************************************************************", row
      + 1
     IF (cursys="AIX")
      "set com = '$ORACLE_HOME/bin/exp parfile=", exp_pfile, "'"
     ELSE
      "set com = 'exp parfile=", exp_pfile, "'"
     ENDIF
     row + 1, "go", row + 1,
     "call dcl(com,size(com),0)", row + 1, "go"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drop_child_foreign_keys(dcf)
   SELECT INTO value(filename2)
    b.table_name, b.constraint_name, " GO"
    FROM user_constraints a,
     user_constraints b
    WHERE b.constraint_type="R"
     AND b.r_constraint_name=a.constraint_name
     AND a.table_name=cnvtupper(rebuild_table_req->table_name)
     AND b.table_name != cnvtupper(rebuild_table_req->table_name)
     AND a.owner=b.owner
     AND a.owner=currdbuser
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section deletes the foreign keys on child tables",
     row + 1, ";****************************************************************************", row +
     1
    DETAIL
     "RDB ALTER TABLE ", b.table_name, row + 1,
     col 20, "DROP CONSTRAINT ", b.constraint_name,
     row + 1, "GO", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drop_and_create_table(dct)
   DECLARE dct_tmp_str = vc WITH public, noconstant("NOT_SET")
   SET x1 = 0
   SET x1 = initarray(col_list," ")
   IF (x1=0)
    GO TO endprogram
   ENDIF
   IF ((rebuild_table_req->oracle_version=8))
    SET k = 0
    SELECT INTO "nl:"
     ucc.column_name, condition = replace(replace(cdef.condition,'"',"",0),"'","",0)
     FROM (sys.cdef$ cdef),
      (sys.con$ con),
      user_cons_columns ucc
     WHERE ucc.table_name=patstring(rebuild_table_req->table_name)
      AND ucc.constraint_name=con.name
      AND con.con#=cdef.con#
      AND ((cdef.type#=7) OR (cdef.type#=1))
     DETAIL
      pos = findstring("NULL",condition), pos1 = findstring("NOT",condition)
      IF (pos > 0
       AND pos1 > 0)
       k = (k+ 1), col_list[k] = ucc.column_name
      ENDIF
     WITH nocounter, maxrec = 100
    ;end select
   ELSE
    SET k = 0
    SELECT INTO "nl:"
     ucc.column_name, cdef.condition
     FROM (sys.cdef$ cdef),
      (sys.con$ con),
      user_cons_columns ucc
     WHERE ucc.table_name=patstring(rebuild_table_req->table_name)
      AND ucc.constraint_name=con.name
      AND con.con#=cdef.con#
      AND ((cdef.type=7) OR (cdef.type=1))
     DETAIL
      pos = findstring("NULL",cdef.condition), pos1 = findstring("NOT",cdef.condition)
      IF (pos > 0
       AND pos1 > 0)
       k = (k+ 1), col_list[k] = ucc.column_name
      ENDIF
     WITH nocounter, maxrec = 100
    ;end select
   ENDIF
   SELECT INTO value(filename2)
    uic.column_name, dg_data_type = substring(1,10,uic.data_type), uic.data_length,
    uic.nullable, uic.column_id, uc.tablespace_name,
    uc.table_name, default_value = substring(1,110,trim(uic.data_default))
    FROM user_tab_columns uic,
     user_tables uc
    WHERE uc.table_name=cnvtupper(rebuild_table_req->table_name)
     AND uc.table_name=uic.table_name
    ORDER BY uc.table_name, uic.column_id
    HEAD uc.table_name
     ";****************************************************************************", row + 1,
     ";this section drops the target table",
     row + 1, ";****************************************************************************", row +
     1,
     "rdb DROP TABLE ", uc.table_name, " CASCADE CONSTRAINTS",
     row + 1, "GO", row + 1,
     row + 1, ";****************************************************************************", row +
     1,
     ";this section coalesces the tablespace the target table was in", row + 1,
     ";****************************************************************************",
     row + 1, "rdb ALTER TABLESPACE ", rebuild_table_req->original_ts,
     " COALESCE", row + 1, "GO",
     row + 1, row + 1,
     ";****************************************************************************",
     row + 1, ";this section recreates the target table", row + 1,
     ";****************************************************************************", row + 1,
     "rdb CREATE TABLE ",
     uc.table_name, row + 1, col 2,
     "("
    DETAIL
     IF (uic.column_id > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,uic.column_name),
     col 2, col_name, rebuild_table_req->column_name = col_name,
     rebuild_table_req->nullable = "Y", col 42, dg_data_type
     IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
      col 60, "(", col 61,
      uic.data_length"####;;I", col 66, ")"
     ENDIF
     IF (default_value != " ")
      row + 1, " DEFAULT ", tempstr = build(default_value),
      tempstr, row + 1
     ENDIF
     IF ((rebuild_table_req->not_null_cons="Y"))
      CALL search_not_null(1)
     ENDIF
     IF (((uic.nullable="N") OR ((rebuild_table_req->nullable="N")
      AND (rebuild_table_req->not_null_cons="Y"))) )
      " NOT NULL"
     ENDIF
    FOOT  uc.table_name
     row + 1, col 2, ")",
     row + 1, col 2, "TABLESPACE ",
     rebuild_table_req->tablespace_name, row + 1
     IF ((rebuild_table_req->storage_parm_ind=1))
      col 2, "STORAGE (", row + 1
     ENDIF
     IF ((rebuild_table_req->initial_size != null)
      AND (rebuild_table_req->initial_size > 0))
      dct_tmp_str = concat("INITIAL ",trim(cnvtstring(rebuild_table_req->initial_size),3),
       rebuild_table_req->initial_units), col 11, dct_tmp_str,
      row + 1
     ENDIF
     IF ((rebuild_table_req->next_size != null)
      AND (rebuild_table_req->next_size > 0))
      dct_tmp_str = concat("NEXT ",trim(cnvtstring(rebuild_table_req->next_size),3),rebuild_table_req
       ->next_units), col 11, dct_tmp_str,
      row + 1
     ENDIF
     row + 1
     IF ((rebuild_table_req->minextents != null)
      AND (rebuild_table_req->minextents > 0))
      dct_tmp_str = concat("MINEXTENTS ",trim(cnvtstring(rebuild_table_req->minextents),3)), col 11,
      dct_tmp_str,
      row + 1
     ENDIF
     IF ((rebuild_table_req->maxextents != null)
      AND cnvtint(rebuild_table_req->maxextents) > 0)
      dct_tmp_str = concat("MAXEXTENTS ",trim(rebuild_table_req->maxextents,3)), col 11, dct_tmp_str,
      row + 1
     ENDIF
     IF ((rebuild_table_req->pctincrease != null)
      AND (rebuild_table_req->pctincrease >= 0))
      dct_tmp_str = concat("PCTINCREASE ",trim(cnvtstring(rebuild_table_req->pctincrease),3)), col 11,
      dct_tmp_str,
      row + 1
     ENDIF
     IF ((rebuild_table_req->freelists != null)
      AND (rebuild_table_req->freelists > 0))
      dct_tmp_str = concat("FREELISTS ",trim(cnvtstring(rebuild_table_req->freelists),3)), col 11,
      dct_tmp_str,
      row + 1
     ENDIF
     IF ((rebuild_table_req->freelist_groups != null)
      AND (rebuild_table_req->freelist_groups > 0))
      dct_tmp_str = concat("FREELIST GROUPS ",trim(cnvtstring(rebuild_table_req->freelist_groups),3)),
      col 11, dct_tmp_str,
      row + 1
     ENDIF
     IF ((rebuild_table_req->storage_parm_ind=1))
      col 2, ")", row + 1
     ENDIF
     col 2, "PCTFREE ", col 11,
     rebuild_table_req->pct_free, col 29, "PCTUSED ",
     col 38, rebuild_table_req->pct_used, row + 1,
     col 2, "INITRANS ", col 11,
     rebuild_table_req->ini_trans, col 29, "MAXTRANS ",
     col 38, rebuild_table_req->max_trans, row + 1
     IF ((lob_col->lob_ind=1))
      col 2, "LOB (", lob_col->column_name,
      ") STORE AS (TABLESPACE ", rebuild_table_req->tablespace_name
      IF ((lob_col->in_row="YES"))
       col + 2, " ENABLE STORAGE IN ROW"
      ELSE
       col + 2, " DISABLE STORAGE IN ROW"
      ENDIF
      row + 1, col 2, "STORAGE(PCTINCREASE ",
      lob_col->pct_increase, " BUFFER_POOL ", lob_col->buffer_pool,
      ")", row + 1, col 2,
      "CHUNK ", lob_col->chunk, " PCTVERSION ",
      lob_col->pctversion, " "
      IF ((lob_col->cache="YES"))
       col + 2, "CACHE"
      ELSE
       col + 2, "NOCACHE"
       IF ((lob_col->logging="YES"))
        col + 2, "LOGGING"
       ENDIF
      ENDIF
      col + 2, ")", row + 1
     ENDIF
     "go", row + 2, "execute oragen3 '",
     rebuild_table_req->table_name, "' GO"
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_pk(cpk)
   SELECT INTO value(filename3)
    uc.constraint_name, uc.table_name, ucc.column_name,
    ucc.position, uc.status
    FROM user_cons_columns ucc,
     user_constraints uc
    WHERE uc.owner=ucc.owner
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.table_name=uc.table_name
     AND uc.table_name=cnvtupper(rebuild_table_req->table_name)
     AND uc.constraint_type="P"
    ORDER BY uc.table_name, ucc.position
    HEAD REPORT
     row + 1, ";****************************************************************************", row +
     1,
     ";this section recreates the primary key on the target table", row + 1,
     ";****************************************************************************",
     row + 1
    HEAD uc.table_name
     "RDB ALTER TABLE ", col 20, uc.table_name,
     row + 1, col 20, " ADD CONSTRAINT ",
     uc.constraint_name, row + 1, col 30,
     " PRIMARY KEY ("
    DETAIL
     IF (ucc.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,ucc.column_name),
     col 10, col_name
    FOOT  uc.table_name
     row + 1, col 10, ")",
     row + 1, row + 1, "go",
     row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_ak(cak)
   SELECT INTO value(filename3)
    uc.constraint_name, uc.table_name, ucc.column_name,
    ucc.position, uc.status
    FROM user_cons_columns ucc,
     user_constraints uc
    WHERE uc.owner=ucc.owner
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.table_name=uc.table_name
     AND uc.table_name=cnvtupper(rebuild_table_req->table_name)
     AND uc.constraint_type="U"
    ORDER BY uc.table_name, ucc.position
    HEAD REPORT
     row + 1, ";****************************************************************************", row +
     1,
     ";this section recreates the unique constraints on the target table", row + 1,
     ";****************************************************************************",
     row + 1
    HEAD uc.constraint_name
     "RDB ALTER TABLE ", col 20, uc.table_name,
     row + 1, col 20, " ADD CONSTRAINT ",
     uc.constraint_name, row + 1, col 30,
     " UNIQUE ("
    DETAIL
     IF (ucc.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,ucc.column_name),
     col 10, col_name
    FOOT  uc.constraint_name
     row + 1, col 10, ")",
     row + 1, row + 1, "go",
     row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_fk(cfk)
   SELECT INTO value(filename3)
    c.column_name, c.position, b.table_name,
    c.constraint_name, a.table_name, b.status
    FROM user_cons_columns c,
     user_constraints a,
     user_constraints b
    WHERE b.constraint_type="R"
     AND b.r_constraint_name=a.constraint_name
     AND b.owner=a.owner
     AND b.constraint_name=c.constraint_name
     AND b.owner=c.owner
     AND b.table_name=cnvtupper(rebuild_table_req->table_name)
    ORDER BY c.constraint_name, c.position
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section recreates the foreign key constraints on the target table",
     row + 1, ";****************************************************************************", row +
     1
    HEAD c.constraint_name
     "RDB ALTER TABLE ", col 20, b.table_name,
     row + 1, col 20, " ADD CONSTRAINT ",
     c.constraint_name, row + 1, col 30,
     " FOREIGN KEY ("
    DETAIL
     IF (c.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,c.column_name),
     col 10, col_name
    FOOT  c.constraint_name
     row + 1, col 10, ")",
     row + 1, col 10, " REFERENCES ",
     a.table_name, " "
     IF (b.status="DISABLED")
      "DISABLE"
     ENDIF
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_disabled_constr(cdc)
   SELECT INTO value(filename3)
    c.column_name, c.position, a.table_name,
    c.constraint_name, a.status, a.constraint_type
    FROM user_cons_columns c,
     user_constraints a
    WHERE ((a.constraint_type="P") OR (a.constraint_type="U"))
     AND a.status="DISABLED"
     AND a.constraint_name=c.constraint_name
     AND a.owner=c.owner
     AND a.table_name=cnvtupper(rebuild_table_req->table_name)
    ORDER BY c.constraint_name, c.position
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section recreates disabled pk and unique constraints on the target table",
     row + 1, ";****************************************************************************", row +
     1
    HEAD c.constraint_name
     "RDB ALTER TABLE ", col 20, a.table_name,
     row + 1, col 20, " ADD CONSTRAINT ",
     c.constraint_name, row + 1
     IF (a.constraint_type="P")
      col 30, " PRIMARY KEY ("
     ENDIF
     IF (a.constraint_type="U")
      col 30, " UNIQUE ("
     ENDIF
    DETAIL
     IF (c.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,c.column_name),
     col 10, col_name
    FOOT  c.constraint_name
     row + 1, col 10, ")",
     row + 1
     IF (a.status="DISABLED")
      "DISABLE"
     ENDIF
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_idx(cidx)
   DECLARE cidx_tmp_str = vc WITH public, noconstant("NOT_SET")
   DECLARE cidx_storage_ind = i2 WITH public, noconstant(0)
   SELECT INTO value(filename3)
    uic.column_name, uic.column_position, ui.table_name,
    ui.index_name, ui.tablespace_name, ui.uniqueness,
    ui.initial_extent, ui.next_extent, ui.min_extents,
    ui.max_extents, ui.pct_increase
    FROM user_ind_columns uic,
     user_indexes ui
    PLAN (ui
     WHERE ui.table_name=cnvtupper(rebuild_table_req->table_name)
      AND ui.index_type != "LOB")
     JOIN (uic
     WHERE uic.index_name=ui.index_name)
    ORDER BY ui.index_name, uic.column_position
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section recreates the indexes on the target table",
     row + 1, ";****************************************************************************", row +
     1
    HEAD ui.index_name
     cidx_storage_ind = 0
     IF (((ui.initial_extent != null
      AND ui.initial_extent != 0) OR (((ui.next_extent != null
      AND ui.next_extent != 0) OR (((ui.min_extents != null
      AND ui.min_extents != 0) OR (((ui.max_extents != null
      AND ui.max_extents != 0) OR (ui.pct_increase != null
      AND ui.pct_increase >= 0)) )) )) )) )
      cidx_storage_ind = 1
     ENDIF
     row + 1, "RDB CREATE "
     IF (ui.uniqueness="UNIQUE")
      ui.uniqueness
     ENDIF
     " INDEX ", ui.index_name, row + 1,
     col 20, "ON ", ui.table_name,
     row + 1, col 30, "("
    DETAIL
     IF (uic.column_position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,uic.column_name),
     col 30, col_name
    FOOT  ui.index_name
     row + 1, col 30, ")",
     row + 1, col 20, " TABLESPACE ",
     ui.tablespace_name, row + 1
     IF (cidx_storage_ind=1)
      col 2, "STORAGE ("
     ENDIF
     IF (ui.initial_extent != null
      AND ui.initial_extent != 0)
      col 11, "INITIAL ", ui.initial_extent";;i",
      row + 1
     ENDIF
     IF (ui.next_extent != null
      AND ui.next_extent != 0)
      col 11, "NEXT ", ui.next_extent";;i",
      row + 1
     ENDIF
     IF (ui.min_extents != null
      AND ui.min_extents != 0)
      col 11, "MINEXTENTS ", ui.min_extents";;i",
      row + 1
     ENDIF
     IF (ui.max_extents != null
      AND ui.max_extents != 0)
      col 11, "MAXEXTENTS ", ui.max_extents";;i",
      row + 1
     ENDIF
     IF (ui.pct_increase != null
      AND ui.pct_increase >= 0)
      col 11, "PCTINCREASE ", ui.pct_increase";;i",
      row + 1
     ENDIF
     IF (cidx_storage_ind=1)
      col 2, ")", row + 1
     ENDIF
     "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE build_imp_parm(bip)
  SET fn = cnvtlower(rebuild_table_req->file_name)
  SELECT INTO value(imp_pfile)
   " "
   FROM dual
   FOOT REPORT
    col 0, "USERID=", misc->up,
    row + 1, "buffer=1000000", row + 1,
    "file=", fn, ".dmp",
    row + 1, "ignore=y", row + 1,
    "indexes=n", row + 1, "tables=(",
    rebuild_table_req->table_name, ")", row + 1,
    "commit=y", row + 1, "log=",
    fn, "_imp.log"
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
 END ;Subroutine
 SUBROUTINE import_table(it)
   SET tn = rebuild_table_req->table_name
   SET fn = cnvtlower(rebuild_table_req->file_name)
   SELECT INTO value(filename3)
    " "
    FROM dual
    HEAD REPORT
     ";***************************************************************************************", row
      + 1, "; Import the table ",
     row + 1,
     ";***************************************************************************************", row
      + 1
     IF (cursys="AIX")
      "set com = '$ORACLE_HOME/bin/imp parfile=", imp_pfile, "'"
     ELSE
      "set com = 'imp parfile=", imp_pfile, "'"
     ENDIF
     row + 1, "go", row + 1,
     "call dcl(com,size(com),0)", row + 1, "go"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_child_fk(chfk)
   SELECT INTO value(filename3)
    c.column_name, c.position, b.table_name,
    c.constraint_name, a.table_name, b.status
    FROM user_cons_columns c,
     user_constraints a,
     user_constraints b
    WHERE b.constraint_type="R"
     AND b.r_constraint_name=a.constraint_name
     AND b.owner=a.owner
     AND b.constraint_name=c.constraint_name
     AND b.owner=c.owner
     AND a.table_name=cnvtupper(rebuild_table_req->table_name)
     AND b.table_name != cnvtupper(rebuild_table_req->table_name)
    ORDER BY c.constraint_name, c.position
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section rebuilds the foreign key constraint referencing the target table",
     row + 1, ";****************************************************************************", row +
     1
    HEAD c.constraint_name
     "RDB ALTER TABLE ", col 20, b.table_name,
     row + 1, col 20, " ADD CONSTRAINT ",
     c.constraint_name, row + 1, col 30,
     " FOREIGN KEY ("
    DETAIL
     IF (c.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,c.column_name),
     col 10, col_name
    FOOT  c.constraint_name
     row + 1, col 10, ")",
     row + 1, col 10, " REFERENCES ",
     a.table_name, " "
     IF (b.status="DISABLED")
      "DISABLE"
     ENDIF
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_check_7(chk)
   SELECT INTO value(filename3)
    t.name, u.name, con.name,
    cdef.condition
    FROM (sys.obj$ t),
     (sys.user$ u),
     (sys.con$ con),
     (sys.cdef$ cdef)
    WHERE (t.name=rebuild_table_req->table_name)
     AND cdef.type=1
     AND cdef.obj#=t.obj#
     AND con.con#=cdef.con#
     AND u.user#=t.owner#
    ORDER BY con.name
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section rebuilds the check constraints",
     row + 1, ";****************************************************************************", row +
     1,
     namet = concat(trim(u.name),".",trim(t.name))
    HEAD con.name
     pos = findstring("NULL",cdef.condition), pos1 = findstring("NOT",cdef.condition)
     IF (pos=0
      AND pos1=0)
      "RDB ALTER TABLE ", namet, row + 1,
      " ADD CONSTRAINT ", con.name, row + 1,
      " CHECK ", row + 1, "(",
      row + 1, cdef.condition, row + 1,
      ")", row + 1, "go",
      row + 1
     ENDIF
    WITH format = stream, noheading, formfeed = none,
     maxcol = 32010, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE create_check_8(chk)
   SELECT INTO value(filename3)
    t.name, u.name, con.name,
    condition = replace(replace(cdef.condition,'"',"",0),"'","",0)
    FROM (sys.obj$ t),
     (sys.user$ u),
     (sys.con$ con),
     (sys.cdef$ cdef)
    WHERE (t.name=rebuild_table_req->table_name)
     AND cdef.type#=1
     AND cdef.obj#=t.obj#
     AND con.con#=cdef.con#
     AND u.user#=t.owner#
    ORDER BY con.name
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section rebuilds the check constraints",
     row + 1, ";****************************************************************************", row +
     1,
     namet = concat(trim(u.name),".",trim(t.name))
    HEAD con.name
     pos = findstring("NULL",condition), pos1 = findstring("NOT",condition)
     IF (pos=0
      AND pos1=0)
      "RDB ALTER TABLE ", namet, row + 1,
      " ADD CONSTRAINT ", con.name, row + 1,
      " CHECK ", row + 1, "(",
      row + 1, condition, row + 1,
      ")", row + 1, "go",
      row + 1
     ENDIF
    WITH format = stream, noheading, formfeed = none,
     maxcol = 32010, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE show_extent_info(p)
   SELECT INTO "mine"
    extent_id, bytes, blocks,
    tablespace_name
    FROM user_extents u
    WHERE (segment_name=rebuild_table_req->table_name)
    HEAD REPORT
     line = fillstring(80,"=")
    HEAD PAGE
     col 6, "Extent", col 18,
     "KBytes", col 30, "Blocks",
     col 42, "Tablespace", row + 1,
     line, row + 2
    DETAIL
     kbytes = (u.bytes/ 1024), col 0, u.extent_id"############",
     col 12, kbytes"############", col 24,
     u.blocks"############", col 42, u.tablespace_name,
     row + 1
   ;end select
 END ;Subroutine
 SUBROUTINE show_table_info(z)
   CALL text(09,07,"Tablespace Name:")
   CALL text(09,24,nullterm(rebuild_table_req->tablespace_name))
   CALL text(10,07,"Initial Extent Size:")
   CALL text(10,29,nullterm(cnvtstring((rebuild_table_req->initial_size/ 1024))))
   CALL text(10,41,"KBytes")
   CALL text(11,07,"Next Extent Size:")
   CALL text(11,25,nullterm(cnvtstring((rebuild_table_req->next_size/ 1024))))
   CALL text(11,38,"KBytes")
   CALL text(12,07,"Minextents:")
   CALL text(12,22,nullterm(cnvtstring(rebuild_table_req->minextents)))
   CALL text(12,26,"Maxextents:")
   CALL text(12,39,nullterm(cnvtstring(rebuild_table_req->maxextents)))
   CALL text(13,07,"Pctincrease:")
   CALL text(13,22,nullterm(cnvtstring(rebuild_table_req->pctincrease)))
 END ;Subroutine
 SUBROUTINE display_screen(m)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,4,80)
   CALL clear(2,2,78)
   CALL text(02,25," ***  DBA  REBUILD TABLE  *** ")
   CALL clear(3,2,78)
   CALL video(n)
   CALL text(06,05,"DATABASE: ")
   CALL text(06,16,trim(rebuild_table_req->database_name))
   CALL text(08,05,"Table Name:")
   CALL text(10,05,"File Name:")
   IF ((rebuild_table_req->oracle_version < 8))
    CALL text(12,05,"Build NOT NULL check constraints from any defined constraints :")
   ENDIF
 END ;Subroutine
 SUBROUTINE accept_userid_pwd(aup)
   CALL clear(1,1)
   CALL display_screen(12)
   CALL clear(06,05,50)
   CALL clear(08,05,50)
   CALL clear(10,05,50)
   CALL clear(12,05,63)
   CALL text(08,10,"USERNAME: ")
   CALL text(10,10,"PASSWORD: ")
   CALL text(15,5,"Username and password are used for the export and import process")
   CALL accept(08,21,"P(30);C","   ")
   SET misc->user_name = curaccept
   CALL accept(10,21,"P(30);C","   ")
   SET misc->pwd = curaccept
   SET misc->up = concat(misc->user_name,"/",misc->pwd)
   CALL ask_continue(13)
   IF ((rebuild_table_req->continue="N"))
    GO TO endprogram
   ENDIF
 END ;Subroutine
 SUBROUTINE search_not_null(g)
   SET j = 1
   SET found = 0
   WHILE ((col_list[j] != " ")
    AND j < 255
    AND found=0)
    IF ((col_list[j]=rebuild_table_req->column_name))
     SET rebuild_table_req->nullable = "N"
     SET found = 1
    ENDIF
    SET j = (j+ 1)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE get_oracle_version(g)
   SELECT INTO "nl:"
    *
    FROM product_component_version
    WHERE product="Oracle7 Server*"
   ;end select
   IF (curqual=0)
    SET rebuild_table_req->oracle_version = 8
   ENDIF
   SET errcode = error(errmsg,0)
   IF (drt_debug_ind=1)
    SELECT INTO value(debug_file)
     " "
     FROM dual
     DETAIL
      "after running get_oracle_version....", row + 1, errmsg
     WITH format = stream, append, noheading,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE ask_continue(g)
   CALL text(23,60,"Continue(Y/N)?")
   CALL accept(23,75,"P;CUS","N")
   SET rebuild_table_req->continue = curaccept
 END ;Subroutine
 SUBROUTINE display_text(dt)
   CALL clear(23,2,120)
   CALL text(23,2,dt)
   CALL pause(5)
   CALL clear(23,2,100)
 END ;Subroutine
 SUBROUTINE check_for_lobs(cfl)
   DECLARE cfl_return_val = i2 WITH public, noconstant(1)
   SELECT INTO "nl:"
    utc.data_type
    FROM user_tab_columns utc
    WHERE (utc.table_name=rebuild_table_req->table_name)
     AND utc.data_type IN ("BLOB", "CLOB")
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(cfl_return_val)
   ENDIF
   SELECT INTO "nl:"
    ul.column_name, ul.chunk, ul.pctversion,
    ul.cache, ul.logging, ul.in_row,
    us.pct_increase, us.buffer_pool
    FROM user_lobs ul,
     user_segments us
    PLAN (ul
     WHERE (ul.table_name=rebuild_table_req->table_name))
     JOIN (us
     WHERE us.segment_type="LOBSEGMENT"
      AND us.segment_name=ul.segment_name)
    DETAIL
     IF ((us.tablespace_name != rebuild_table_req->tablespace_name))
      cfl_return_val = 0
     ELSE
      lob_col->lob_ind = 1, lob_col->column_name = ul.column_name, lob_col->chunk = ul.chunk,
      lob_col->pctversion = ul.pctversion, lob_col->cache = ul.cache, lob_col->logging = ul.logging,
      lob_col->in_row = ul.in_row, lob_col->pct_increase = us.pct_increase, lob_col->buffer_pool = us
      .buffer_pool
     ENDIF
    WITH nocounter
   ;end select
   RETURN(cfl_return_val)
 END ;Subroutine
#endprogram
 SELECT INTO value(debug_file)
  " "
  FROM dual
  DETAIL
   "DEBUGGING STARTS.....", row + 1, " "
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 CALL clear(23,05,74)
 CALL clear(24,05,74)
END GO

CREATE PROGRAM dba_rebuild_index:dba
 PAINT
 RECORD rebuild_index_req(
   1 database_name = vc
   1 owner = vc
   1 index_name = vc
   1 tablespace_name = vc
   1 initial_size = i4
   1 initial_units = c1
   1 next_size = i4
   1 next_units = c1
   1 pctincrease = i4
   1 minextents = i4
   1 maxextents = vc
   1 pct_free = i4
   1 ini_trans = i4
   1 max_trans = i4
   1 freelists = i4
   1 freelist_groups = i4
   1 instances = vc
   1 cache = vc
   1 continue = c1
   1 original_ts = vc
   1 valid_index = i4
   1 unrecoverable = c1
   1 parallel = c1
   1 degree = i4
   1 storage_parm_ind = i2
   1 extent_management = vc
 )
 RECORD misc(
   1 user_name = vc
   1 pwd = vc
   1 up = vc
   1 initial = i4
   1 next = i4
   1 maxextents = i4
   1 sql_text = vc
 )
 SET rebuild_index_req->database_name = "     "
 SET rebuild_index_req->valid_index = 0
 SELECT INTO "nl:"
  a.name
  FROM v$database a
  DETAIL
   rebuild_index_req->database_name = a.name
  WITH nocounter
 ;end select
#start
 CALL clear(1,1)
 CALL display_screen(1)
 IF ((rebuild_index_req->valid_index=0))
  SET rebuild_index_req->index_name = fillstring(30," ")
  SET rebuild_index_req->tablespace_name = fillstring(30," ")
  SET rebuild_index_req->original_ts = fillstring(30," ")
  SET rebuild_index_req->initial_units = fillstring(1," ")
  SET rebuild_index_req->next_units = fillstring(1," ")
  SET rebuild_index_req->initial_size = 0
  SET rebuild_index_req->next_size = 0
  SET rebuild_index_req->pctincrease = 0
  SET rebuild_index_req->minextents = 0
  SET rebuild_index_req->maxextents = fillstring(9," ")
  SET rebuild_index_req->pct_free = 0
  SET rebuild_index_req->ini_trans = 0
  SET rebuild_index_req->max_trans = 0
  SET rebuild_index_req->freelists = 0
  SET rebuild_index_req->freelist_groups = 0
  SET rebuild_index_req->instances = fillstring(10," ")
  SET rebuild_index_req->cache = fillstring(5," ")
  SET rebuild_index_req->unrecoverable = "N"
  SET rebuild_index_req->parallel = "N"
  SET rebuild_index_req->degree = 2
  SET misc->sql_text = fillstring(500," ")
  SET rebuild_index_req->storage_parm_ind = 0
 ENDIF
#enterindexname
 IF ((rebuild_index_req->valid_index=0))
  CALL clear(23,05,74)
  CALL clear(24,01,80)
  SET index_count = 0
  SET init_loop = 1
  WHILE (((index_count=0) OR (init_loop=1)) )
    IF (init_loop=1)
     SET init_loop = 0
    ENDIF
    CALL clear(23,05,74)
    CALL text(23,05,"HELP: Press <SHIFT><F5> ")
    SET help =
    SELECT INTO "nl:"
     a.index_name
     FROM user_indexes a
     WITH nocounter
    ;end select
    CALL accept(08,17,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS","                              ")
    SET rebuild_index_req->index_name = curaccept
    SELECT INTO "nl:"
     a.tablespace_name, a.initial_extent, a.next_extent,
     a.pct_increase, a.min_extents, a.max_extents,
     a.pct_free, a.ini_trans, a.max_trans,
     a.freelists, a.freelist_groups
     FROM user_indexes a
     WHERE a.index_name=patstring(rebuild_index_req->index_name)
     DETAIL
      rebuild_index_req->tablespace_name = a.tablespace_name, rebuild_index_req->initial_size = a
      .initial_extent, rebuild_index_req->next_size = a.next_extent,
      rebuild_index_req->pctincrease = a.pct_increase, rebuild_index_req->original_ts = a
      .tablespace_name, rebuild_index_req->minextents = a.min_extents,
      rebuild_index_req->maxextents = cnvtstring(a.max_extents), rebuild_index_req->pct_free = a
      .pct_free, rebuild_index_req->ini_trans = a.ini_trans,
      rebuild_index_req->max_trans = a.max_trans, rebuild_index_req->freelists = a.freelists,
      rebuild_index_req->freelist_groups = a.freelist_groups
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
    SET index_count = curqual
    IF (index_count=0)
     CALL clear(23,05,74)
     CALL clear(24,01,80)
     IF ((rebuild_index_req->index_name="                              "))
      CALL text(23,05,"Index name required...")
     ELSE
      CALL text(23,05,"Index not found...")
     ENDIF
     CALL ask_continue(1)
     IF ((rebuild_index_req->continue="Y"))
      GO TO enterindexname
     ELSE
      GO TO endprogram
     ENDIF
    ELSE
     SET rebuild_index_req->valid_index = 1
    ENDIF
  ENDWHILE
 ENDIF
#selectoption
 CALL clear(08,17,40)
 CALL text(08,17,rebuild_index_req->index_name)
 CALL text(16,05,"1.  View extent information.")
 CALL text(17,05,"2.  Modify parameters and rebuild index.")
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
 CALL text(09,05,"Enter values for the new index:")
 CALL text(11,3,"TABLESPACE: ")
 CALL text(12,3,"INITIAL: ")
 CALL text(12,24,"B/K/M")
 CALL text(12,45,"NEXT: ")
 CALL text(12,63,"B/K/M")
 CALL text(13,3,"MIN EXTENTS: ")
 CALL text(13,24,"MAX EXTENTS: ")
 CALL text(14,3,"PCTINCREASE: ")
 CALL text(14,24,"PCT FREE: ")
 CALL text(15,3,"FREELISTS: ")
 CALL text(15,24,"FREELIST GROUPS: ")
 CALL text(16,3,"INI TRANS: ")
 CALL text(16,24,"MAX TRANS: ")
 CALL text(17,3,"UNRECOVERABLE Y/N: ")
 CALL text(17,24,"PARALLEL Y/N: ")
 CALL text(17,40,"DEGREE: ")
#entertablespacename
 CALL clear(23,05,74)
 CALL clear(24,01,80)
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
   CALL accept(11,15,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS",rebuild_index_req->tablespace_name)
   SET rebuild_index_req->tablespace_name = curaccept
   SELECT INTO "nl:"
    cnt = count(*)
    FROM dba_tablespaces
    WHERE tablespace_name=patstring(rebuild_index_req->tablespace_name)
    DETAIL
     ts_count = cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (ts_count=0)
    CALL clear(23,05,74)
    CALL clear(24,01,80)
    IF (nullterm(rebuild_index_req->tablespace_name)="")
     CALL text(23,05,"Tablespace name required...")
    ELSE
     CALL text(23,05,"Tablespace not found...")
    ENDIF
    CALL ask_continue(1)
    IF ((rebuild_index_req->continue="Y"))
     GO TO entertablespacename
    ELSE
     GO TO endprogram
    ENDIF
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  ts.extent_management
  FROM dba_tablespaces ts
  WHERE (ts.tablespace_name=rebuild_index_req->tablespace_name)
  DETAIL
   rebuild_index_req->extent_management = ts.extent_management
  WITH nocounter
 ;end select
#enterinitial
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(12,12,"99999999999",rebuild_index_req->initial_size)
 SET rebuild_index_req->initial_size = curaccept
 IF ((((rebuild_index_req->initial_size < 0)) OR ((rebuild_index_req->initial_size=0)
  AND (rebuild_index_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"Initial extent must be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterinitial
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_index_req->initial_size > 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
 SET rebuild_index_req->initial_units = "B"
 CALL accept(12,30,"P;CUS",rebuild_index_req->initial_units)
 SET rebuild_index_req->initial_units = curaccept
 IF ( NOT ((rebuild_index_req->initial_units IN ("B", "M", "K"))))
  CALL text(23,05,"Initial Units must be B, K, or M")
  CALL ask_continue(2)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterinitial
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enternext
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(12,51,"99999999999",rebuild_index_req->next_size)
 SET rebuild_index_req->next_size = curaccept
 IF ((((rebuild_index_req->next_size < 0)) OR ((rebuild_index_req->next_size=0)
  AND (rebuild_index_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"Next extend size must be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enternext
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_index_req->next_size > 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
 SET rebuild_index_req->next_units = "B"
 CALL accept(12,69,"P;CUS",rebuild_index_req->next_units)
 SET rebuild_index_req->next_units = curaccept
 IF ( NOT ((rebuild_index_req->next_units IN ("B", "M", "K"))))
  CALL text(23,05,"Next Units must be B, K, or M")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enternext
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterminextents
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(13,16,"999",rebuild_index_req->minextents)
 SET rebuild_index_req->minextents = curaccept
 IF ((((rebuild_index_req->minextents < 0)) OR ((rebuild_index_req->minextents=0)
  AND (rebuild_index_req->extent_management != "LOCAL"))) )
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterminextents
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_index_req->minextents > 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
#entermaxextents
 CALL accept(13,37,"PPPPPPPPPPP;CUS",rebuild_index_req->maxextents)
 SET rebuild_index_req->maxextents = curaccept
 SET misc->maxextents = cnvtint(rebuild_index_req->maxextents)
 IF ((misc->maxextents <= 0))
  IF ((rebuild_index_req->maxextents="UNLIMITED"))
   SET misc->maxextents = 2147483645
   SET rebuild_index_req->storage_parm_ind = 1
  ELSEIF ((rebuild_index_req->extent_management="LOCAL")
   AND isnumeric(rebuild_index_req->maxextents) > 0
   AND cnvtint(rebuild_index_req->maxextents)=0)
   SET rebuild_index_req->storage_parm_ind = 0
  ELSE
   IF ((rebuild_index_req->extent_management="LOCAL"))
    CALL text(23,05,"This value should be 0 or greater, or UNLIMITED")
   ELSE
    CALL text(23,05,"This value should be greater than 0 or UNLIMITED")
   ENDIF
   CALL ask_continue(1)
   IF ((rebuild_index_req->continue="Y"))
    GO TO entermaxextents
   ELSE
    GO TO endprogram
   ENDIF
  ENDIF
 ELSEIF ((misc->maxextents > 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
#enterpctincrease
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(14,16,"99",rebuild_index_req->pctincrease)
 SET rebuild_index_req->pctincrease = curaccept
 IF ((rebuild_index_req->pctincrease < 0))
  CALL text(23,05,"This value should be 0 or greater...")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterpctincrease
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_index_req->pctincrease >= 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
#enterpctfree
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(14,34,"999",rebuild_index_req->pct_free)
 SET rebuild_index_req->pct_free = curaccept
 IF ((((rebuild_index_req->pct_free < 0)) OR ((rebuild_index_req->pct_free=0)
  AND (rebuild_index_req->extent_management != "LOCAL"))) )
  IF ((rebuild_index_req->extent_management="LOCAL"))
   CALL text(23,05,"This value should be 0 or greater...")
  ELSE
   CALL text(23,05,"This value should be greater than 0...")
  ENDIF
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterpctfree
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterfreelists
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(15,14,"999",rebuild_index_req->freelists)
 SET rebuild_index_req->freelists = curaccept
 IF ((((rebuild_index_req->freelists < 0)) OR ((rebuild_index_req->freelists=0)
  AND (rebuild_index_req->extent_management != "LOCAL"))) )
  IF ((rebuild_index_req->extent_management="LOCAL"))
   CALL text(23,05,"This value should be 0 or greater...")
  ELSE
   CALL text(23,05,"This value should be greater than 0...")
  ENDIF
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterfreelists
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_index_req->freelists > 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
#enterfreelist_groups
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(15,41,"999",rebuild_index_req->freelist_groups)
 SET rebuild_index_req->freelist_groups = curaccept
 IF ((((rebuild_index_req->freelist_groups < 0)) OR ((rebuild_index_req->freelist_groups=0)
  AND (rebuild_index_req->extent_management != "LOCAL"))) )
  IF ((rebuild_index_req->extent_management="LOCAL"))
   CALL text(23,05,"This value should be 0 or greater...")
  ELSE
   CALL text(23,05,"This value should be greater than 0...")
  ENDIF
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterfreelist_groups
  ELSE
   GO TO endprogram
  ENDIF
 ELSEIF ((rebuild_index_req->freelist_groups > 0))
  SET rebuild_index_req->storage_parm_ind = 1
 ENDIF
#enterinitrans
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(16,14,"999",rebuild_index_req->ini_trans)
 SET rebuild_index_req->ini_trans = curaccept
 IF ((rebuild_index_req->ini_trans <= 0))
  CALL text(23,05,"This value should be greater than 0...")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterinitrans
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#entermaxtrans
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(16,35,"999",rebuild_index_req->max_trans)
 SET rebuild_index_req->max_trans = curaccept
 IF ((rebuild_index_req->max_trans <= 0))
  CALL text(23,05,"This value should be greater than 0...")
  CALL ask_continue(1)
  IF ((rebuild_index_req->continue="Y"))
   GO TO entermaxtrans
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterunrecoverable
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(17,22,"P;CUS",rebuild_index_req->unrecoverable)
 SET rebuild_index_req->unrecoverable = curaccept
 IF ( NOT ((rebuild_index_req->unrecoverable IN ("Y", "y", "N", "n"))))
  CALL text(23,05,"Unrecoverable must be Y or N")
  CALL ask_continue(2)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterunrecoverable
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterparallel
 CALL clear(23,05,74)
 CALL clear(24,01,80)
 CALL accept(17,38,"P;CUS",rebuild_index_req->parallel)
 SET rebuild_index_req->parallel = curaccept
 IF ( NOT ((rebuild_index_req->parallel IN ("Y", "y", "N", "n"))))
  CALL text(23,05,"Parallel must be Y or N")
  CALL ask_continue(2)
  IF ((rebuild_index_req->continue="Y"))
   GO TO enterparallel
  ELSE
   GO TO endprogram
  ENDIF
 ENDIF
#enterdegree
 IF ((rebuild_index_req->parallel IN ("Y", "y")))
  CALL clear(23,05,74)
  CALL clear(24,01,80)
  CALL accept(17,48,"999",rebuild_index_req->degree)
  SET rebuild_index_req->degree = curaccept
  IF ((rebuild_index_req->degree <= 0))
   CALL text(23,05,"This value should be greater than 0...")
   CALL ask_continue(1)
   IF ((rebuild_index_req->continue="Y"))
    GO TO enterdegree
   ELSE
    GO TO endprogram
   ENDIF
  ENDIF
 ENDIF
#confirmvalues
 CALL clear(23,05,74)
 CALL text(23,05,"Please confirm the above information before continue. Continue(Y/N)?")
 CALL accept(23,74,"P;CUS","N")
 IF (curaccept="Y")
  CALL rebuildindex(1)
 ELSE
  GO TO endprogram
 ENDIF
 SET rebuild_index_req->valid_index = 0
 GO TO start
 SUBROUTINE show_extent_info(p)
   SELECT INTO "mine"
    extent_id, bytes, blocks,
    tablespace_name
    FROM user_extents u
    WHERE (segment_name=rebuild_index_req->index_name)
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
 SUBROUTINE rebuildindex(ri)
   IF ((rebuild_index_req->initial_units IN ("K", "k")))
    SET misc->initial = (rebuild_index_req->initial_size * 1024)
   ENDIF
   IF ((rebuild_index_req->initial_units IN ("M", "m")))
    SET misc->initial = ((rebuild_index_req->initial_size * 1024) * 1024)
   ENDIF
   IF ((rebuild_index_req->initial_units IN ("B", "b")))
    SET misc->initial = rebuild_index_req->initial_size
   ENDIF
   IF ((rebuild_index_req->next_units IN ("K", "k")))
    SET misc->next = (rebuild_index_req->next_size * 1024)
   ENDIF
   IF ((rebuild_index_req->next_units IN ("M", "m")))
    SET misc->next = ((rebuild_index_req->next_size * 1024) * 1024)
   ENDIF
   IF ((rebuild_index_req->next_units IN ("B", "b")))
    SET misc->next = rebuild_index_req->next_size
   ENDIF
   CALL clear(23,5,74)
   CALL text(23,5,"Rebuild index...")
   CALL pause(1)
   SET misc->sql_text = fillstring(200," ")
   SET misc->sql_text = concat("rdb alter index ",nullterm(rebuild_index_req->index_name),
    " rebuild  tablespace ",nullterm(rebuild_index_req->tablespace_name)," pctfree ",
    nullterm(cnvtstring(rebuild_index_req->pct_free))," initrans ",nullterm(cnvtstring(
      rebuild_index_req->ini_trans))," maxtrans ",nullterm(cnvtstring(rebuild_index_req->max_trans)))
   IF ((rebuild_index_req->storage_parm_ind=1))
    SET misc->sql_text = concat(misc->sql_text," storage (")
   ENDIF
   IF ((rebuild_index_req->initial_size != null)
    AND (rebuild_index_req->initial_size > 0))
    SET misc->sql_text = concat(misc->sql_text," initial ",nullterm(cnvtstring(misc->initial)))
   ENDIF
   IF ((rebuild_index_req->next_size != null)
    AND (rebuild_index_req->next_size > 0))
    SET misc->sql_text = concat(misc->sql_text," next ",nullterm(cnvtstring(misc->next)))
   ENDIF
   IF ((rebuild_index_req->pctincrease != null)
    AND (rebuild_index_req->pctincrease >= 0))
    SET misc->sql_text = concat(misc->sql_text," pctincrease ",nullterm(cnvtstring(rebuild_index_req
       ->pctincrease)))
   ENDIF
   IF ((rebuild_index_req->freelists != null)
    AND (rebuild_index_req->freelists > 0))
    SET misc->sql_text = concat(misc->sql_text," freelists ",nullterm(cnvtstring(rebuild_index_req->
       freelists)))
   ENDIF
   IF ((rebuild_index_req->freelist_groups != null)
    AND (rebuild_index_req->freelist_groups > 0))
    SET misc->sql_text = concat(misc->sql_text," freelist groups ",nullterm(cnvtstring(
       rebuild_index_req->freelist_groups)))
   ENDIF
   IF ((rebuild_index_req->minextents != null)
    AND (rebuild_index_req->minextents > 0))
    SET misc->sql_text = concat(misc->sql_text," minextents ",nullterm(cnvtstring(rebuild_index_req->
       minextents)))
   ENDIF
   IF ((misc->maxextents != null)
    AND (misc->maxextents > 0))
    SET misc->sql_text = concat(misc->sql_text," maxextents ",nullterm(cnvtstring(misc->maxextents)))
   ENDIF
   IF ((rebuild_index_req->storage_parm_ind=1))
    SET misc->sql_text = concat(misc->sql_text,")")
   ENDIF
   IF ((rebuild_index_req->unrecoverable="Y"))
    SET misc->sql_text = concat(nullterm(misc->sql_text)," unrecoverable")
   ENDIF
   IF ((rebuild_index_req->parallel="Y"))
    SET misc->sql_text = concat(nullterm(misc->sql_text)," parallel ",nullterm(cnvtstring(
       rebuild_index_req->degree)))
   ENDIF
   SET misc->sql_text = concat(nullterm(misc->sql_text)," go")
   CALL parser(concat("rdb alter tablespace ",nullterm(rebuild_index_req->tablespace_name),
     " coalesce go"))
   CALL parser(misc->sql_text)
   IF ((rebuild_index_req->original_ts != rebuild_index_req->tablespace_name))
    CALL parser(concat("rdb alter tablespace ",nullterm(rebuild_index_req->original_ts),
      " coalesce go"))
   ENDIF
   CALL text(23,70,"Complete.")
   CALL pause(1)
 END ;Subroutine
 SUBROUTINE display_screen(m)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,4,80)
   CALL clear(2,2,78)
   CALL text(02,25," ***  DBA  REBUILD INDEX  *** ")
   CALL clear(3,2,78)
   CALL video(n)
   CALL text(06,05,"DATABASE: ")
   CALL text(06,16,trim(rebuild_index_req->database_name))
   CALL text(08,05,"Index Name:")
 END ;Subroutine
 SUBROUTINE accept_userid_pwd(aup)
   CALL clear(1,1)
   CALL display_screen(12)
   CALL clear(06,05,50)
   CALL clear(08,05,50)
   CALL clear(10,05,50)
   CALL text(08,10,"USERNAME: ")
   CALL text(10,10,"PASSWORD: ")
   CALL accept(08,21,"P(30);C","   ")
   SET misc->user_name = curaccept
   CALL accept(10,21,"X(30);C","   ")
   SET misc->pwd = curaccept
   SET misc->up = concat(misc->user_name,"/",misc->pwd)
   CALL ask_continue(13)
   IF ((rebuild_index_req->continue="N"))
    GO TO endprogram
   ENDIF
 END ;Subroutine
 SUBROUTINE ask_continue(g)
   CALL text(23,60,"Continue(Y/N)?")
   CALL accept(23,75,"P;CUS","N")
   SET rebuild_index_req->continue = curaccept
 END ;Subroutine
 SUBROUTINE display_text(dt)
   CALL clear(23,2,132)
   CALL text(23,2,dt)
   CALL pause(10)
   CALL clear(23,2,132)
 END ;Subroutine
#endprogram
 CALL clear(23,05,74)
 CALL clear(24,01,80)
END GO

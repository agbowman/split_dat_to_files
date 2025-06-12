CREATE PROGRAM dba_mod5_db_ver:dba
#start_rollback
 RECORD roll_rec1(
   1 sname = c80
   1 tname = c80
   1 iniext = f8
   1 nexext = f8
   1 minext = f8
   1 maxext = f8
   1 opt = f8
 )
 RECORD rec2(
   1 qual[1]
     2 sname = c80
 )
 SET old_dbver = request->old_dbver
 SET on_line_opt = "Y"
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18," ***   V 5 0 0    M O D I F Y    D B V E R S I O N   *** ")
 CALL text(3,18,"R O L L B A C K    S E G M E N T S    P A R A M E T E R S")
 CALL video(n)
 CALL text(05,05,"Insert or Change rollback segments information (I,-C-): ")
 CALL accept(05,60,"P;CU","C"
  WHERE curaccept IN ("C", "I"))
 IF (curaccept="I")
  SET create_ts = "Y"
  GO TO getinfo
 ELSE
  GO TO getcnfo
 ENDIF
#getinfo
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18," ***   V 5 0 0    M O D I F Y    D B V E R S I O N   *** ")
 CALL text(3,18,"R O L L B A C K    S E G M E N T S    P A R A M E T E R S")
 CALL video(n)
 CALL text(07,05,"Enter tablespace for new rollback segment(s): ")
 CALL text(09,05,"Enter new rollback segment name: ")
 CALL text(11,05,"Enter initial extent: ")
 CALL text(12,05,"Enter next extent: ")
 CALL text(13,05,"Enter min extents: ")
 CALL text(14,05,"Enter max extents: ")
 CALL text(15,05,"Enter optimal: ")
 CALL clear(23,1)
 CALL text(23,1,"Help available on <HLP> key.")
 SET help =
 SELECT DISTINCT
  d.tablespace_name";l"
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
  ORDER BY d.tablespace_name
  WITH nocounter
 ;end select
 CALL accept(08,05,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU")
 SET roll_rec1->tname = curaccept
 CALL clear(23,1)
#roll_input
 CALL accept(10,05,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU")
 SET roll_rec1->sname = curaccept
 SET rcnt_rollseg = 0
 SELECT INTO "nl:"
  cnt_rollseg = count(d.rollback_seg_name)
  FROM dm_size_db_rollback_segs d
  WHERE d.db_version=old_dbver
   AND (d.rollback_seg_name=roll_rec1->sname)
  DETAIL
   rcnt_rollseg = cnt_rollseg
  WITH nocounter
 ;end select
 IF (rcnt_rollseg > 0)
  CALL text(23,1,"Rollback segment already exists !!!")
  GO TO roll_input
 ENDIF
 CALL clear(23,1)
 CALL accept(11,30,"##########",0)
 SET roll_rec1->iniext = curaccept
 CALL accept(12,30,"##########",0)
 SET roll_rec1->nexext = curaccept
 CALL accept(13,30,"########",2)
 SET roll_rec1->minext = curaccept
 CALL accept(14,30,"########",0)
 SET roll_rec1->maxext = curaccept
 CALL accept(15,30,"########;h",0)
 SET roll_rec1->opt = curaccept
 CALL text(17,05,"Get online at startup (Y/N) : ")
 CALL accept(17,40,"P;CU",on_line_opt)
 SET on_line_opt = curaccept
 SET num_tspaces = 0
 SELECT INTO "nl:"
  cnt_tspace = count(d.tablespace_name)
  FROM dm_size_db_ts d
  WHERE (d.tablespace_name=roll_rec1->tname)
  DETAIL
   num_tspaces = cnt_tspace
  WITH nocounter
 ;end select
 IF (num_tspaces < 1)
  CALL text(17,5,"Tablespace does not exist. Do you want to create a new one? ")
  CALL accept(17,67,"p;cu","Y"
   WHERE curaccept IN ("Y", "N"))
  SET create_ts = curaccept
  IF (create_ts="Y")
   SET roll_tname = roll_rec1->tname
   EXECUTE dba_mod2_db_ver
  ELSE
   GO TO getinfo
  ENDIF
 ENDIF
 INSERT  FROM dm_size_db_rollback_segs d
  SET d.db_version = old_dbver, d.tablespace_name = roll_rec1->tname, d.rollback_seg_name = roll_rec1
   ->sname,
   d.initial_extent = roll_rec1->iniext, d.next_extent = roll_rec1->nexext, d.min_extents = roll_rec1
   ->minext,
   d.max_extents = roll_rec1->maxext, d.updt_applctx = 0, d.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   d.updt_cnt = 0, d.updt_id = 0, d.updt_task = 0,
   d.optimal =
   IF ((roll_rec1->opt=0)) null
   ELSE roll_rec1->opt
   ENDIF
  WITH nocounter
 ;end insert
 IF (on_line_opt="Y")
  SET config_roll = fillstring(100," ")
  SELECT INTO "nl:"
   d.*
   FROM dm_size_db_config d
   WHERE d.db_version=old_dbver
    AND d.config_parm="rollback_segments"
   DETAIL
    fs = findstring(")",d.value), config_roll = substring(1,(fs - 1),d.value)
   WITH nocounter
  ;end select
  SET config_roll = concat(trim(config_roll),",")
  SET config_roll = concat(trim(config_roll),roll_rec1->sname)
  SET config_roll = concat(trim(config_roll),")")
  UPDATE  FROM dm_size_db_config d
   SET d.value = trim(config_roll)
   WHERE d.config_parm="rollback_segments"
    AND d.db_version=old_dbver
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
 GO TO continue
 SET opt_rbs = "A"
#getcnfo
 SET iniext = 0.0
 SET nexext = 0.0
 SET minext = 0.0
 SET maxext = 0.0
 SET opt = 0.0
 CALL text(07,05,"All or One (A/O) : ")
 CALL accept(07,30,"P;CU","A"
  WHERE curaccept IN ("A", "O"))
 SET opt_rbs = curaccept
 IF (opt_rbs="O")
  CALL text(09,05,"Enter rollback segment name: ")
  CALL clear(23,1)
  CALL text(23,1,"Help available on <HLP> key.")
  SET help =
  SELECT
   d.rollback_seg_name";l"
   FROM dm_size_db_rollback_segs d
   WHERE d.db_version=old_dbver
   ORDER BY d.rollback_seg_name
   WITH nocounter
  ;end select
  SET validate =
  SELECT INTO "nl:"
   d.rollback_seg_name
   FROM dm_size_db_rollback_segs d
   WHERE d.db_version=old_dbver
    AND d.rollback_seg_name=curaccept
  ;end select
  SET validate = 1
  CALL accept(10,05,"P(20);CU")
  SET rec2->qual[1].sname = curaccept
  SET help = off
  SET validate = off
  CALL clear(23,1)
  SELECT INTO "nl:"
   d.*
   FROM dm_size_db_rollback_segs d
   WHERE (d.rollback_seg_name=rec2->qual[1].sname)
    AND d.db_version=old_dbver
   DETAIL
    iniext = d.initial_extent, nexext = d.next_extent, minext = d.min_extents,
    maxext = d.max_extents, opt = d.optimal
   WITH nocounter
  ;end select
 ENDIF
 CALL text(12,05,"Enter initial extent: ")
 CALL text(13,05,"Enter next extent: ")
 CALL text(14,05,"Enter min extents: ")
 CALL text(15,05,"Enter max extents: ")
 CALL text(16,05,"Enter optimal: ")
 CALL accept(12,30,"##########",iniext)
 SET iniext = curaccept
 CALL accept(13,30,"##########",nexext)
 SET nexext = curaccept
 CALL accept(14,30,"##########",minext)
 SET minext = curaccept
 CALL accept(15,30,"##########",maxext)
 SET maxext = curaccept
 CALL accept(16,30,"##########",opt)
 SET opt = curaccept
 IF (opt_rbs="A")
  UPDATE  FROM dm_size_db_rollback_segs d
   SET d.initial_extent = iniext, d.next_extent = nexext, d.min_extents = minext,
    d.max_extents = maxext, d.optimal =
    IF (opt=0) null
    ELSE opt
    ENDIF
   WHERE db_version=old_dbver
   WITH nocounter
  ;end update
 ENDIF
 IF (opt_rbs="O")
  UPDATE  FROM dm_size_db_rollback_segs d
   SET d.initial_extent = iniext, d.next_extent = nexext, d.min_extents = minext,
    d.max_extents = maxext, d.optimal =
    IF (opt=0) null
    ELSE opt
    ENDIF
   WHERE db_version=old_dbver
    AND (rollback_seg_name=rec2->qual[1].sname)
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
#continue
 CALL clear(17,3,65)
 CALL text(17,05,"Do you want to continue")
 CALL accept(17,50,"p;cu","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO start_rollback
 ENDIF
#endprogram
END GO

CREATE PROGRAM dba_mod2_db_ver:dba
 SET old_dbver = request->old_dbver
 RECORD tstype_rec(
   1 qual[5]
     2 tstype = c20
 )
 SET tstype_rec->qual[1].tstype = "DEFAULT"
 SET tstype_rec->qual[2].tstype = "OTHER"
 SET tstype_rec->qual[3].tstype = "ROLLBACK"
 SET tstype_rec->qual[4].tstype = "TEMP"
 SET tstype_rec->qual[5].tstype = "SYSTEM"
#start_ts
 SET tcnt_file = 0
 SET tname = fillstring(50," ")
 SET fname = fillstring(50," ")
 SET fsize = 0.0
 SET tstype = fillstring(20," ")
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,12,"-  V 5 0 0    D B V E R S I O N    S U B R O U T I N E  -")
 CALL clear(3,2,78)
 CALL text(03,12,"    D B    T A B L E S P A C E S    P A R A M E T E R")
 CALL video(n)
 IF (create_ts="Y")
  SET option = "I"
  GO TO start
 ENDIF
 CALL text(05,05,"Insert or Change Tablespace Information (I/C) : ")
 CALL accept(05,70,"P;CU","I"
  WHERE curaccept IN ("I", "C"))
 SET option = curaccept
 CALL clear(5,5,70)
 CALL text(05,05,"NOTE:  Hit <enter> on question below will indicate that this")
 CALL text(06,05,"       subroutine is completed...")
#start
 CALL text(08,05,"Enter Tablespace name      : ")
 CALL text(10,05,"Enter new file name        : ")
 CALL text(12,05,"Enter value for file size in bytes: ")
 CALL text(14,05,"Enter Tablespace type : ")
 IF (option="I")
  GO TO getinfo
 ENDIF
#getcnfo
 CALL text(23,1,"Help available on <HLP> KEY.")
 SET help =
 SELECT
  d.tablespace_name";l", file_name = substring(1,30,d.file_name)
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  d.tablespace_name
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
   AND d.tablespace_name=curaccept
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(09,05,"p(30);cu")
 SET validate = off
 SET help = off
 SET tname = curaccept
 CALL clear(23,1)
 SELECT INTO "nl:"
  d.*
  FROM dm_size_db_ts d
  WHERE d.tablespace_name=tname
  DETAIL
   fname = d.file_name, fsize = d.file_size, tstype = d.ts_type
  WITH nocounter
 ;end select
 SET temp_name = fname
#fname_update
 CALL accept(11,05,"P(30);CU",fname)
 SET fname = curaccept
 IF (trim(temp_name) != trim(fname))
  SET tcnt_file = 0
  SELECT INTO "nl:"
   cnt_file = count(d.file_name)
   FROM dm_size_db_ts d
   WHERE d.db_version=old_dbver
    AND d.file_name=fname
   DETAIL
    tcnt_file = cnt_file
   WITH nocounter
  ;end select
  IF (tcnt_file > 0)
   CALL text(23,1,"File Name exists !!!")
   GO TO fname_update
  ENDIF
 ENDIF
 CALL clear(23,1)
 CALL accept(13,05,"##########",fsize)
 SET fsize = curaccept
 SET help =
 SELECT INTO "nl:"
  tablespace_type = tstype_rec->qual[d.seq].tstype
  FROM (dummyt d  WITH seq = 5)
  WITH nocounter
 ;end select
 CALL accept(15,5,"P(20);CUf")
 SET tstype = curaccept
 SET help = off
 UPDATE  FROM dm_size_db_ts d
  SET d.file_size = fsize, d.file_name = fname, d.ts_type = tstype
  WHERE d.db_version=old_dbver
   AND d.tablespace_name=tname
  WITH nocounter
 ;end update
 COMMIT
 GO TO continue
#getinfo
 IF (create_ts="Y")
  GO TO create_roll_ts
 ENDIF
 CALL accept(9,5,"P(50);CU")
 SET tname = curaccept
 SET tcnt_ts = 0
 SELECT INTO "nl:"
  cnt_ts = count(d.tablespace_name)
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
   AND d.tablespace_name=tname
  DETAIL
   tcnt_ts = cnt_ts
  WITH nocounter
 ;end select
 IF (tcnt_ts > 0)
  CALL text(23,1,"Tablespace already  exists ")
  GO TO start
 ENDIF
 CALL clear(23,1)
 SET fname = fillstring(50," ")
 SET fname = concat(trim(tname),"_01.DBS")
 CALL accept(11,05,"P(50);CU",fname)
 SET fname = curaccept
#fname_insert
 CALL accept(11,05,"P(30);CU",fname)
 SET fname = curaccept
 SET tcnt_file = 0
 SELECT INTO "nl:"
  cnt_file = count(d.file_name)
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
   AND d.file_name=fname
  DETAIL
   tcnt_file = cnt_file
  WITH nocounter
 ;end select
 IF (tcnt_file > 0)
  CALL text(23,1,"File Name exists !!!")
  GO TO fname_insert
 ENDIF
 CALL accept(13,05,"##########")
 SET fsize = curaccept
 SET help =
 SELECT INTO "nl:"
  tablespace_type = tstype_rec->qual[d.seq].tstype
  FROM (dummyt d  WITH seq = 5)
  WITH nocounter
 ;end select
 CALL accept(15,5,"P(20);CUf")
 SET tstype = curaccept
 SET help = off
 GO TO just
#create_roll_ts
 SET bilang = 1
 SET tname = trim(roll_tname)
 CALL clear(8,4,60)
 CALL text(8,05,"Tablespace Name : ")
 CALL text(8,25,trim(tname))
 SET fname = fillstring(50," ")
 SET fname = concat(trim(tname),"_01.DBS")
 CALL accept(11,05,"P(60);CU",fname)
 SET fname = curaccept
#fname_roll
 CALL accept(11,05,"P(30);CU",fname)
 SET fname = curaccept
 SET tcnt_file = 0
 SELECT INTO "nl:"
  cnt_file = count(d.file_name)
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
   AND d.file_name=fname
  DETAIL
   tcnt_file = cnt_file
  WITH nocounter
 ;end select
 IF (tcnt_file > 0)
  CALL text(23,1,"File Name exists !!!")
  GO TO fname_roll
 ENDIF
 CALL accept(13,05,"##########")
 SET fsize = curaccept
 CALL clear(14,3,65)
 CALL text(15,05,"Tablespace type : ROLLBACK ")
 SET tstype = "ROLLBACK"
#just
 INSERT  FROM dm_size_db_ts d
  SET d.db_version = old_dbver, d.tablespace_name = trim(tname), d.file_name = trim(fname),
   d.file_size = fsize, d.ts_type = trim(tstype), d.updt_applctx = 0,
   d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0, d.updt_id = 0,
   d.updt_task = 0
  WITH nocounter
 ;end insert
 COMMIT
 IF (create_ts="Y")
  GO TO endprog
 ENDIF
#continue
 CALL text(17,05,"Do you want to continue ? ")
 CALL accept(17,50,"p;cu","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO start_ts
 ENDIF
#endprog
END GO

CREATE PROGRAM db_backup_stats:dba
 FREE SET temp
 FREE SET cdate
 FREE SET ctime
 FREE SET edate
 FREE SET etime
 FREE SET filestat_cnt
 FREE SET emin
 FREE SET cmin
 FREE SET elapsed_time
 FREE SET dummy
 FREE SET dblink
 FREE SET dbl
 FREE SET check_dblink
 FREE SET check_sid
 FREE SET filestat_sid
 FREE SET error_msg
 SET error_msg = fillstring(100," ")
 SET check_sid = fillstring(100," ")
 SET filestat_sid = fillstring(100," ")
 SET check_dblink = 0
 SET dblink =  $1
 SET dbl = concat(dblink,".WORLD")
 SET dummy = 0
 SET etime = 0
 SET edate = cnvtdate2("01011995","mmddyyyy")
 SET cmin = 0
 SET emin = 0
 SET elapsed_time = 0
 SET temp = fillstring(100," ")
 SET filestat_cnt = 0
 SET temp = format(curdate,"mmddyyyy;;d")
 SET cdate = cnvtdate2(temp,"mmddyyyy")
 SET temp = format(curtime,"hhmm;;m")
 SET ctime = cnvtint(temp)
 SELECT INTO "nl:"
  FROM all_db_links a
  WHERE a.db_link=value(cnvtupper(dbl))
  FOOT REPORT
   check_dblink = count(a.db_link)
  WITH nocounter
 ;end select
 IF (check_dblink=0)
  SET error_msg = concat("ERROR Invalid Database Link Name -- ",dblink)
  CALL error_sub(dummy)
 ENDIF
 SELECT INTO "nl:"
  FROM dba_bkup_stats_beg f
  WHERE f.tablespace_name="SYSTEM"
  ORDER BY f.cur_date
  DETAIL
   filestat_cnt = (filestat_cnt+ 1), edatetime = f.cur_date
  FOOT REPORT
   temp = format(edatetime,"mmddyyyy;;d"), edate = cnvtdate2(temp,"mmddyyyy"), temp = format(
    edatetime,"hhmm;;m"),
   etime = cnvtint(temp), cmin = cnvtmin2(cdate,ctime,1), emin = cnvtmin2(edate,etime,1),
   elapsed_time = (cmin - emin)
  WITH nocounter
 ;end select
 CALL echo(concat("all_db_links.db_link = ",cnvtstring(check_dblink)))
 CALL echo(concat("dblink = ",dblink))
 CALL echo(concat("cdate = ",format(cdate,"mmddyyyy;;d"),"   ctime = ",cnvtstring(ctime)))
 CALL echo(concat("edate = ",format(edate,"mmddyyyy;;d"),"   etime = ",cnvtstring(etime)))
 CALL echo(concat("filestat_cnt = ",cnvtstring(filestat_cnt)))
 CALL echo(concat("cmin = ",cnvtstring(cmin),"   emin = ",cnvtstring(emin)))
 CALL echo(concat("elapsed time in min = ",cnvtstring(elapsed_time)))
 IF (((filestat_cnt=0) OR (elapsed_time > 90)) )
  CALL echo("inside count = 0 or elapsed time > 90")
  CALL trunc_db_bkup_stats(dummy)
  CALL ins_filestats_beg(dummy)
 ELSE
  CALL echo("inside else count > 0 and elapsed time <= 90")
  CALL ins_filestats_end(dummy)
  CALL ins_filestats(dummy)
  CALL ins_filestats_beg(dummy)
 ENDIF
 SUBROUTINE trunc_db_bkup_stats(d1)
   SET parser_buffer = fillstring(100," ")
   SET parser_buffer = "rdb truncate table dba_bkup_stats go "
   CALL parser(parser_buffer,1)
 END ;Subroutine
 SUBROUTINE ins_filestats_beg(d1)
   DELETE  FROM dba_bkup_stats_beg
    WHERE 1=1
   ;end delete
   COMMIT
   SET cnt = 0
   SET parser_buffer[100] = fillstring(100," ")
   SET parser_buffer[1] = "rdb insert into dba_bkup_stats_beg "
   SET parser_buffer[2] = "  select ts.name, "
   SET parser_buffer[3] = "         i.name, "
   SET parser_buffer[4] = "         sysdate, "
   SET parser_buffer[5] = "         x.phyrds, "
   SET parser_buffer[6] = "         x.phyblkrd, "
   SET parser_buffer[7] = "         x.readtim, "
   SET parser_buffer[8] = "         x.phywrts, "
   SET parser_buffer[9] = "         x.phyblkwrt, "
   SET parser_buffer[10] = "        x.writetim, "
   SET parser_buffer[11] = "        round(i.bytes/1000000) "
   SET parser_buffer[12] = concat(" from v$filestat@",dblink," x, ")
   SET parser_buffer[13] = concat("      sys.ts$@",dblink," ts, ")
   SET parser_buffer[14] = concat("      v$datafile@",dblink," i, ")
   SET parser_buffer[15] = concat("      sys.file$@",dblink," f ")
   SET parser_buffer[16] = " where i.file# = f.file# "
   SET parser_buffer[17] = "   and ts.ts# = f.ts# "
   SET parser_buffer[18] = "   and x.file# = f.file# go "
   SET parser_buffer[19] = " commit go "
   FOR (cnt = 1 TO 19)
     CALL parser(parser_buffer[cnt],1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE ins_filestats_end(d1)
   DELETE  FROM dba_bkup_stats_end
    WHERE 1=1
   ;end delete
   COMMIT
   SET cnt = 0
   SET parser_buffer[100] = fillstring(100," ")
   SET parser_buffer[1] = "rdb insert into dba_bkup_stats_end "
   SET parser_buffer[2] = "  select ts.name, "
   SET parser_buffer[3] = "         i.name, "
   SET parser_buffer[4] = "         sysdate, "
   SET parser_buffer[5] = "         'dummy', "
   SET parser_buffer[6] = "         'dummy', "
   SET parser_buffer[7] = "         x.phyrds, "
   SET parser_buffer[8] = "         x.phyblkrd, "
   SET parser_buffer[9] = "         x.readtim, "
   SET parser_buffer[10] = "        x.phywrts, "
   SET parser_buffer[11] = "        x.phyblkwrt, "
   SET parser_buffer[12] = "        x.writetim, "
   SET parser_buffer[13] = "        round(i.bytes/1000000) "
   SET parser_buffer[14] = concat(" from v$filestat@",dblink," x, ")
   SET parser_buffer[15] = concat("      sys.ts$@",dblink," ts, ")
   SET parser_buffer[16] = concat("      v$datafile@",dblink," i, ")
   SET parser_buffer[17] = concat("      sys.file$@",dblink," f ")
   SET parser_buffer[18] = " where i.file# = f.file# "
   SET parser_buffer[19] = "   and ts.ts# = f.ts# "
   SET parser_buffer[20] = "   and x.file# = f.file# go "
   SET parser_buffer[21] = " commit go "
   FOR (cnt = 1 TO 21)
     CALL parser(parser_buffer[cnt],1)
   ENDFOR
   SET parser_buffer[100] = fillstring(100," ")
   SET parser_buffer[1] = "rdb update dba_bkup_stats_end "
   SET parser_buffer[2] = concat("set db_name = (select name from v$database@",dblink,"), ")
   SET parser_buffer[3] = concat("    sid = (select instance from v$thread@",dblink,") go")
   SET parser_buffer[4] = "commit go "
   FOR (cnt = 1 TO 4)
     CALL parser(parser_buffer[cnt],1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE ins_filestats(d1)
   SET cnt = 0
   SET parser_buffer[100] = fillstring(100," ")
   SET parser_buffer[1] = "rdb insert into dba_bkup_stats "
   SET parser_buffer[2] = "  select b.tablespace_name, "
   SET parser_buffer[3] = "         b.file_name, "
   SET parser_buffer[4] = "         b.cur_date, "
   SET parser_buffer[5] = "         e.cur_date, "
   SET parser_buffer[6] = "         e.db_name, "
   SET parser_buffer[7] = "         e.sid, "
   SET parser_buffer[8] = "         e.phys_reads-b.phys_reads, "
   SET parser_buffer[9] = "         e.phys_blks_rd-b.phys_blks_rd, "
   SET parser_buffer[10] = "        e.phys_rd_time-b.phys_rd_time, "
   SET parser_buffer[11] = "        e.phys_writes-b.phys_writes, "
   SET parser_buffer[12] = "        e.phys_blks_wr-b.phys_blks_wr, "
   SET parser_buffer[13] = "        e.phys_wrt_tim-b.phys_wrt_tim, "
   SET parser_buffer[14] = "        e.megabytes_size "
   SET parser_buffer[15] = "  from dba_bkup_stats_beg b, dba_bkup_stats_end e "
   SET parser_buffer[16] = "  where b.tablespace_name = e.tablespace_name "
   SET parser_buffer[17] = "        and b.file_name = e.file_name go"
   SET parser_buffer[18] = " commit go "
   FOR (cnt = 1 TO 18)
     CALL parser(parser_buffer[cnt],1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE error_sub(d1)
  CALL echo(error_msg)
  GO TO endprogram
 END ;Subroutine
#endprogram
END GO

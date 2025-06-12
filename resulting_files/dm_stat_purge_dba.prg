CREATE PROGRAM dm_stat_purge:dba
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
 DECLARE dsp_del_more = i4
 RECORD rdm_err(
   1 rdm_errmsg = vc
   1 rdm_errcode = i4
 )
 RECORD purge(
   1 qual[*]
     2 snapshot_type = vc
     2 retention_days = i4
 )
 SELECT INTO "nl:"
  i.info_number, i.info_name
  FROM dm_info i
  WHERE i.info_domain="DM_STAT_PURGE"
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(purge->qual,5))
    stat = alterlist(purge->qual,(count+ 9))
   ENDIF
   purge->qual[count].snapshot_type = trim(i.info_name,3), purge->qual[count].retention_days = i
   .info_number
  FOOT REPORT
   stat = alterlist(purge->qual,count)
  WITH nocounter
 ;end select
 SET rdm_err->rdm_errcode = error(rdm_err->rdm_errmsg,1)
 IF ((rdm_err->rdm_errcode != 0))
  CALL echo(rdm_err->rdm_errmsg)
  CALL esmerror(rdm_err->rdm_errmsg,esmexit)
 ENDIF
 FOR (dsp_cnt = 1 TO value(size(purge->qual,5)))
   SET dsp_del_more = 1
   WHILE (dsp_del_more > 0)
     DELETE  FROM dm_stat_snaps_values dv
      WHERE dm_stat_snap_id IN (
      (SELECT
       d.dm_stat_snap_id
       FROM dm_stat_snaps d
       WHERE d.snapshot_type=patstring(purge->qual[dsp_cnt].snapshot_type)
        AND d.stat_snap_dt_tm < cnvtdatetime((curdate - purge->qual[dsp_cnt].retention_days),0)))
      WITH nocounter, maxqual(dv,10000)
     ;end delete
     SET rdm_err->rdm_errcode = error(rdm_err->rdm_errmsg,0)
     IF ((rdm_err->rdm_errcode != 0))
      ROLLBACK
      SET dsp_cnt = (value(size(purge->qual,5))+ 1)
      CALL echo(rdm_err->rdm_errmsg)
      CALL esmerror(rdm_err->rdm_errmsg,esmexit)
     ELSE
      COMMIT
      SET dsp_del_more = curqual
      CALL echo(build("nbr of rows deleted from dm_stat_snaps_values =",dsp_del_more," for type=",
        purge->qual[dsp_cnt].snapshot_type))
     ENDIF
   ENDWHILE
   SET dsp_del_more = 1
   WHILE (dsp_del_more > 0)
     DELETE  FROM dm_stat_snaps d
      WHERE d.snapshot_type=patstring(purge->qual[dsp_cnt].snapshot_type)
       AND d.stat_snap_dt_tm < datetimeadd(cnvtdatetime(curdate,0),(purge->qual[dsp_cnt].
       retention_days * - (1)))
      WITH nocounter, maxqual(d,10000)
     ;end delete
     SET rdm_err->rdm_errcode = error(rdm_err->rdm_errmsg,0)
     IF ((rdm_err->rdm_errcode != 0))
      ROLLBACK
      SET dsp_cnt = (value(size(purge->qual,5))+ 1)
      CALL echo(rdm_err->rdm_errmsg)
      CALL esmerror(rdm_err->rdm_errmsg,esmexit)
     ELSE
      COMMIT
      SET dsp_del_more = curqual
      CALL echo(build("nbr of rows deleted from dm_stat_snaps =",dsp_del_more," for type=",purge->
        qual[dsp_cnt].snapshot_type))
     ENDIF
   ENDWHILE
 ENDFOR
#exit_program
END GO

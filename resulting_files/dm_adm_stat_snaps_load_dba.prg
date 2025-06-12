CREATE PROGRAM dm_adm_stat_snaps_load:dba
 FREE RECORD snaps_info
 RECORD snaps_info(
   1 dss_id = f8
   1 err_msg = vc
   1 fail_flag = i2
   1 utc_ind = i2
   1 mnemonic = vc
 )
 SET snaps_info->utc_ind = validate(curutc,- (1))
 FOR (x_cnt = 1 TO size(dsr->qual,5))
   SET snaps_info->dss_id = 0
   SELECT INTO "nl:"
    FROM dm_adm_stat_snaps ds
    WHERE ds.stat_snap_dt_tm=cnvtdatetimeutc(cnvtdatetime(dsr->qual[x_cnt].stat_snap_dt_tm))
     AND (ds.client_mnemonic=dsr->qual[x_cnt].client_mnemonic)
     AND (ds.domain_name=dsr->qual[x_cnt].domain_name)
     AND (ds.node_name=dsr->qual[x_cnt].node_name)
     AND (ds.snapshot_type=dsr->qual[x_cnt].snapshot_type)
    DETAIL
     snaps_info->dss_id = ds.dm_stat_snap_id
    WITH nocounter
   ;end select
   IF (error(snaps_info->err_msg,0) > 0)
    ROLLBACK
    SET snaps_info->fail_flag = 1
    GO TO exit_script
   ENDIF
   IF ((snaps_info->dss_id=0))
    SELECT INTO "nl:"
     y = seq(dm_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      snaps_info->dss_id = cnvtreal(y)
     WITH format, counter
    ;end select
    INSERT  FROM dm_adm_stat_snaps ds
     SET ds.dm_stat_snap_id = snaps_info->dss_id, ds.stat_snap_dt_tm = cnvtdatetime(dsr->qual[x_cnt].
       stat_snap_dt_tm), ds.client_mnemonic = dsr->qual[x_cnt].client_mnemonic,
      ds.domain_name = dsr->qual[x_cnt].domain_name, ds.node_name = dsr->qual[x_cnt].node_name, ds
      .snapshot_type = dsr->qual[x_cnt].snapshot_type,
      ds.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (error(snaps_info->err_msg,0) > 0)
     ROLLBACK
     SET snaps_info->fail_flag = 1
     GO TO exit_script
    ENDIF
    COMMIT
   ENDIF
   FOR (y_cnt = 1 TO size(dsr->qual[x_cnt].qual,5))
     UPDATE  FROM dm_adm_stat_snaps_values ssv
      SET ssv.stat_str_val = dsr->qual[x_cnt].qual[y_cnt].stat_str_val, ssv.stat_type = dsr->qual[
       x_cnt].qual[y_cnt].stat_type, ssv.stat_number_val = dsr->qual[x_cnt].qual[y_cnt].
       stat_number_val,
       ssv.stat_date_dt_tm = cnvtdatetime(dsr->qual[x_cnt].qual[y_cnt].stat_date_val), ssv.updt_dt_tm
        = cnvtdatetime(curdate,curtime3), ssv.updt_cnt = (ssv.updt_cnt+ 1)
      WHERE (ssv.dm_stat_snap_id=snaps_info->dss_id)
       AND (ssv.stat_name=dsr->qual[x_cnt].qual[y_cnt].stat_name)
       AND (ssv.stat_seq=dsr->qual[x_cnt].qual[y_cnt].stat_seq)
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM dm_adm_stat_snaps_values ssv
       SET ssv.dm_stat_snap_id = snaps_info->dss_id, ssv.stat_name = dsr->qual[x_cnt].qual[y_cnt].
        stat_name, ssv.stat_seq = dsr->qual[x_cnt].qual[y_cnt].stat_seq,
        ssv.stat_str_val = dsr->qual[x_cnt].qual[y_cnt].stat_str_val, ssv.stat_type = dsr->qual[x_cnt
        ].qual[y_cnt].stat_type, ssv.stat_number_val = dsr->qual[x_cnt].qual[y_cnt].stat_number_val,
        ssv.stat_date_dt_tm = cnvtdatetime(dsr->qual[x_cnt].qual[y_cnt].stat_date_val), ssv
        .updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
     ENDIF
     IF (error(snaps_info->err_msg,0) > 0)
      ROLLBACK
      SET snaps_info->fail_flag = 1
      GO TO exit_script
     ENDIF
     COMMIT
   ENDFOR
 ENDFOR
#exit_script
 IF ((snaps_info->fail_flag=1))
  CALL echo("*************************************************")
  CALL echo(snaps_info->err_msg)
  CALL echo("*************************************************")
 ENDIF
 FREE RECORD snaps_info
END GO

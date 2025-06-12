CREATE PROGRAM dm2_increase_seq_cache:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD dm_seqs
 RECORD dm_seqs(
   1 list[*]
     2 dm_seq_name = vc
     2 dm_cycle_flag = c1
     2 dm_max_value = f8
 )
 DECLARE dm_seq_cnt = i4
 SET dm_seq_cnt = 0
 SET dm_errcode = 0
 SET dm_errmsg = fillstring(132," ")
 SELECT INTO "nl:"
  FROM user_tab_columns
  WHERE table_name="DM2_USER_SEQUENCES"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->message = concat(
   "FAILED: sequence can not be created because dm2_user_sequences view does not exist")
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm2_user_sequences u
  DETAIL
   dm_seq_cnt = (dm_seq_cnt+ 1)
   IF (mod(dm_seq_cnt,10)=1)
    stata = alterlist(dm_seqs->list,(dm_seq_cnt+ 9))
   ENDIF
   dm_seqs->list[dm_seq_cnt].dm_seq_name = u.sequence_name, dm_seqs->list[dm_seq_cnt].dm_cycle_flag
    = u.cycle_flag, dm_seqs->list[dm_seq_cnt].dm_max_value = u.max_value
  WITH nocounter
 ;end select
 SET dm_errcode = error(dm_errmsg,1)
 FOR (dm_loop = 1 TO dm_seq_cnt)
   IF ((dm_seqs->list[dm_loop].dm_cycle_flag="N")
    AND (dm_seqs->list[dm_loop].dm_max_value >= 999999999))
    SET dm_errcode = 0
    SET dm_errmsg = fillstring(132," ")
    CALL parser(concat("rdb alter sequence ",dm_seqs->list[dm_loop].dm_seq_name," cache 2000 go"))
    CALL echo(concat("rdb alter sequence ",dm_seqs->list[dm_loop].dm_seq_name," cache 2000 go"))
    SET dm_errcode = error(dm_errmsg,0)
    IF (dm_errcode != 0)
     SET readme_data->message = concat("FAIL: Could not alter sequence ",dm_seqs->list[dm_loop].
      dm_seq_name,": ",dm_errmsg)
     SET readme_data->status = "F"
     GO TO exit_script
    ELSE
     SET readme_data->status = "S"
     IF (currdb != "ORACLE")
      COMMIT
     ENDIF
    ENDIF
    IF ((readme_data->status="S"))
     SELECT INTO "nl:"
      FROM dm_sequences ds
      WHERE ds.sequence_name=cnvtupper(dm_seqs->list[dm_loop].dm_seq_name)
      WITH nocounter
     ;end select
     SET dm_errcode = 0
     SET dm_errmsg = fillstring(132," ")
     IF (curqual=0)
      INSERT  FROM dm_sequences ds
       (ds.sequence_name, ds.min_value, ds.max_value,
       ds.increment_by, ds.cycle)(SELECT
        d2s.sequence_name, d2s.min_value, d2s.max_value,
        d2s.increment_by, d2s.cycle_flag
        FROM dm2_user_sequences d2s
        WHERE d2s.sequence_name=cnvtupper(dm_seqs->list[dm_loop].dm_seq_name))
       WITH nocounter
      ;end insert
     ELSE
      UPDATE  FROM dm_sequences ds
       SET ds.cache = 2000
       WHERE ds.sequence_name=cnvtupper(dm_seqs->list[dm_loop].dm_seq_name)
       WITH nocounter
      ;end update
     ENDIF
     SET dm_errcode = error(dm_errmsg,0)
     IF (dm_errcode != 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = "Error: could not update dm_sequences table"
      GO TO exit_script
     ELSE
      COMMIT
      SET readme_data->status = "S"
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF ((readme_data->status="S"))
  SET readme_data->message = "Success: all sequences updated correctly"
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO

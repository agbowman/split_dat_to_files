CREATE PROGRAM dm_stat_dminfo_insert:dba
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
 DECLARE first_ind = i2
 DECLARE errmsg = c132
 SET readme_data->status = "F"
 SET first_ind = 1
 FREE RECORD info_rec
 RECORD info_rec(
   1 list[5]
     2 info_domain = vc
     2 info_name = vc
     2 info_number = i4
     2 info_char = vc
     2 info_date = dq8
     2 status = i2
 )
 SET info_rec->list[1].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[1].info_name = "DM_UI_GET_SQL_STMTS"
 SET info_rec->list[1].info_number = 240
 SET info_rec->list[1].info_char = "ROUTINE"
 SET info_rec->list[1].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[2].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[2].info_name = "DM_GET_USED_INDEXES"
 SET info_rec->list[2].info_number = 1
 SET info_rec->list[2].info_char = "EOM 1 NODE"
 SET info_rec->list[2].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[3].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[3].info_name = "INDEX_USAGE"
 SET info_rec->list[3].info_number = 1
 SET info_rec->list[4].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[4].info_name = "INDEX_USAGE"
 SET info_rec->list[4].info_number = 60
 SET info_rec->list[5].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[5].info_name = "INDEX_USAGE_SQL_TEXT"
 SET info_rec->list[5].info_number = 60
 UPDATE  FROM dm_info di,
   (dummyt d  WITH seq = value(size(info_rec->list,5)))
  SET di.info_char = info_rec->list[d.seq].info_char, di.info_date = cnvtdatetime(info_rec->list[d
    .seq].info_date)
  PLAN (d)
   JOIN (di
   WHERE (di.info_domain=info_rec->list[d.seq].info_domain)
    AND (di.info_name=info_rec->list[d.seq].info_name)
    AND (di.info_number=info_rec->list[d.seq].info_number))
  WITH status(info_rec->list[d.seq].status)
 ;end update
 INSERT  FROM dm_info di,
   (dummyt d  WITH seq = value(size(info_rec->list,5)))
  SET di.info_domain = info_rec->list[d.seq].info_domain, di.info_name = info_rec->list[d.seq].
   info_name, di.info_number = info_rec->list[d.seq].info_number,
   di.info_char = info_rec->list[d.seq].info_char, di.info_date = cnvtdatetime(info_rec->list[d.seq].
    info_date)
  PLAN (d
   WHERE (info_rec->list[d.seq].status=0))
   JOIN (di)
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  FROM dm_info di,
   (dummyt d  WITH seq = value(size(info_rec->list,5)))
  PLAN (d)
   JOIN (di
   WHERE (di.info_domain=info_rec->list[d.seq].info_domain)
    AND (di.info_name=info_rec->list[d.seq].info_name)
    AND (di.info_number=info_rec->list[d.seq].info_number))
  DETAIL
   IF (first_ind=1)
    readme_data->message = concat("Missing info_name(s): ",trim(info_rec->list[d.seq].info_name,3))
   ELSE
    readme_data->message = concat(readme_data->message,", ",trim(info_rec->list[d.seq].info_name,3))
   ENDIF
   first_ind = 0
  WITH outerjoin = d, dontexist
 ;end select
 IF (first_ind=1)
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->message = errmsg
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "All dm_info rows inserted successfully."
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
 COMMIT
 FREE RECORD info_rec
END GO

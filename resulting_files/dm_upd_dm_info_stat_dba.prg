CREATE PROGRAM dm_upd_dm_info_stat:dba
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
   1 list[39]
     2 info_domain = vc
     2 info_name = vc
     2 info_number = i4
     2 info_char = vc
     2 info_date = dq8
     2 status = i2
 )
 SET info_rec->list[1].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[1].info_name = "DM_STAT_GATHER_SIZING"
 SET info_rec->list[1].info_number = 2
 SET info_rec->list[1].info_char = "EOM 1 NODE"
 SET info_rec->list[1].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[2].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[2].info_name = "TABLE_SIZE_BYTES"
 SET info_rec->list[2].info_number = 1
 SET info_rec->list[3].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[3].info_name = "TABLE_SIZE_BYTES"
 SET info_rec->list[3].info_number = 90
 SET info_rec->list[4].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[4].info_name = "TABLE_SIZE_ROWS"
 SET info_rec->list[4].info_number = 2
 SET info_rec->list[5].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[5].info_name = "TABLE_SIZE_ROWS"
 SET info_rec->list[5].info_number = 90
 SET info_rec->list[6].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[6].info_name = "INDEX_SIZE_LEAF_BYTES"
 SET info_rec->list[6].info_number = 3
 SET info_rec->list[7].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[7].info_name = "INDEX_SIZE_LEAF_BYTES"
 SET info_rec->list[7].info_number = 90
 SET info_rec->list[8].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[8].info_name = "INDEX_SIZE_DISTINCT_KEYS"
 SET info_rec->list[8].info_number = 4
 SET info_rec->list[9].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[9].info_name = "INDEX_SIZE_DISTINCT_KEYS"
 SET info_rec->list[9].info_number = 90
 SET info_rec->list[10].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[10].info_name = "DM_STAT_GATHER_TOP_SQL"
 SET info_rec->list[10].info_number = 60
 SET info_rec->list[10].info_char = "ROUTINE"
 SET info_rec->list[10].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[11].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[11].info_name = "TOP_SQL"
 SET info_rec->list[11].info_number = 30
 SET info_rec->list[12].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[12].info_name = "DM_STAT_GATHER_SQL_SMRY"
 SET info_rec->list[12].info_number = 1
 SET info_rec->list[12].info_char = "EOD 1 NODE"
 SET info_rec->list[12].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[13].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[13].info_name = "TOP_SQL_SMRY"
 SET info_rec->list[13].info_number = 1
 SET info_rec->list[14].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[14].info_name = "TOP_SQL_SMRY"
 SET info_rec->list[14].info_number = 30
 SET info_rec->list[15].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[15].info_name = "DB SCORE"
 SET info_rec->list[15].info_number = 1
 SET info_rec->list[16].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[16].info_name = "DB SCORE"
 SET info_rec->list[16].info_number = 60
 SET info_rec->list[17].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[17].info_name = "ESM_GATHER_HNAMAGENT"
 SET info_rec->list[17].info_number = 1
 SET info_rec->list[17].info_char = "EOD ALL NODES"
 SET info_rec->list[17].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[18].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[18].info_name = "ESM_SMON_SMRY"
 SET info_rec->list[18].info_number = 1
 SET info_rec->list[19].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[19].info_name = "ESM_SMON_DTL"
 SET info_rec->list[19].info_number = 40
 SET info_rec->list[20].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[20].info_name = "ESM_SMON_SMRY"
 SET info_rec->list[20].info_number = 120
 SET info_rec->list[21].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[21].info_name = "ESM_GATHER_OSSTAT"
 SET info_rec->list[21].info_number = 1
 SET info_rec->list[21].info_char = "EOD ALL NODES"
 SET info_rec->list[21].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[22].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[22].info_name = "ESM_OSSTAT_SMRY"
 SET info_rec->list[22].info_number = 1
 SET info_rec->list[23].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[23].info_name = "ESM_OSSTAT_DTL"
 SET info_rec->list[23].info_number = 40
 SET info_rec->list[24].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[24].info_name = "ESM_OSSTAT_SMRY"
 SET info_rec->list[24].info_number = 120
 SET info_rec->list[25].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[25].info_name = "ESM_GATHER_OSCONFIG"
 SET info_rec->list[25].info_number = 1
 SET info_rec->list[25].info_char = "EOM ALL NODES"
 SET info_rec->list[25].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[26].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[26].info_name = "ESM_OSCONFIG"
 SET info_rec->list[26].info_number = 1
 SET info_rec->list[27].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[27].info_name = "ESM_OSCONFIG"
 SET info_rec->list[27].info_number = 210
 SET info_rec->list[28].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[28].info_name = "ESM_GATHER_MILLCONFIG"
 SET info_rec->list[28].info_number = 1
 SET info_rec->list[28].info_char = "EOM ALL NODES"
 SET info_rec->list[28].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[29].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[29].info_name = "ESM_MILLCONFIG"
 SET info_rec->list[29].info_number = 1
 SET info_rec->list[30].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[30].info_name = "ESM_MILLCONFIG"
 SET info_rec->list[30].info_number = 210
 SET info_rec->list[31].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[31].info_name = "ESM_GATHER_OSSTAT_DTL"
 SET info_rec->list[31].info_number = 0
 SET info_rec->list[31].info_char = "ROUTINE"
 SET info_rec->list[31].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[32].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[32].info_name = "ESM_GATHER_MSGLOG"
 SET info_rec->list[32].info_number = 1
 IF (cursys="AIX")
  SET info_rec->list[32].info_char = "EOD ALL NODES"
 ELSE
  SET info_rec->list[32].info_char = "EOD 1 NODE"
 ENDIF
 SET info_rec->list[32].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[33].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[33].info_name = "ESM_MSGLOG_SMRY"
 SET info_rec->list[33].info_number = 1
 SET info_rec->list[34].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[34].info_name = "ESM_MSGLOG_DTL"
 SET info_rec->list[34].info_number = 40
 SET info_rec->list[35].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[35].info_name = "ESM_MSGLOG_SMRY"
 SET info_rec->list[35].info_number = 120
 SET info_rec->list[36].info_domain = "DM_STAT_GATHER"
 SET info_rec->list[36].info_name = "ESM_GATHER_RRD"
 SET info_rec->list[36].info_number = 1
 SET info_rec->list[36].info_char = "EOD 1 NODE"
 SET info_rec->list[36].info_date = cnvtdatetime(sysdate)
 SET info_rec->list[37].info_domain = "DM_STAT_EXPORT"
 SET info_rec->list[37].info_name = "ESM_RRD_SMRY"
 SET info_rec->list[37].info_number = 1
 SET info_rec->list[38].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[38].info_name = "ESM_RRD_DTL"
 SET info_rec->list[38].info_number = 40
 SET info_rec->list[39].info_domain = "DM_STAT_PURGE"
 SET info_rec->list[39].info_name = "ESM_RRD_SMRY"
 SET info_rec->list[39].info_number = 120
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
 FREE RECORD info_rec
END GO

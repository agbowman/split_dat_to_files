CREATE PROGRAM dm_drop_sched_index1:dba
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
#drop_start
 SET readme_data->status = "F"
 FREE SET t_drop
 RECORD t_drop(
   1 qual_cnt = i4
   1 qual[*]
     2 index_name = vc
     2 exist_ind = i2
 )
 SET t_drop->qual_cnt = 14
 SET stat = alterlist(t_drop->qual,t_drop->qual_cnt)
 SET t_drop->qual[1].index_name = "XIE1SCH_NOTIFY"
 SET t_drop->qual[2].index_name = "XIE2SCH_NOTIFY"
 SET t_drop->qual[3].index_name = "XIE2SCH_TEXT_LINK"
 SET t_drop->qual[4].index_name = "XIE3SCH_TEXT_LINK"
 SET t_drop->qual[5].index_name = "XIE4SCH_TEXT_LINK"
 SET t_drop->qual[6].index_name = "XIE5SCH_TEXT_LINK"
 SET t_drop->qual[7].index_name = "XIE6SCH_TEXT_LINK"
 SET t_drop->qual[8].index_name = "XIE7SCH_TEXT_LINK"
 SET t_drop->qual[9].index_name = "XAK2SCH_TEXT_LINK"
 SET t_drop->qual[10].index_name = "XIE2SCH_ACTION_LOC"
 SET t_drop->qual[11].index_name = "XIE1SCH_APPT"
 SET t_drop->qual[12].index_name = "XIE2SCH_BOOKING"
 SET t_drop->qual[13].index_name = "XAK2SCH_LIST_ROLE"
 SET t_drop->qual[14].index_name = "XIE4SCH_DATE_COMMENT"
 FOR (i = 1 TO t_drop->qual_cnt)
   SET t_drop->qual[i].exist_ind = 0
 ENDFOR
 CALL echo("select indexes...")
 SELECT INTO "nl:"
  d.seq, c.index_name
  FROM (dummyt d  WITH seq = value(t_drop->qual_cnt)),
   user_indexes c
  PLAN (d)
   JOIN (c
   WHERE (c.index_name=t_drop->qual[d.seq].index_name)
    AND c.table_owner="V500")
  DETAIL
   t_drop->qual[d.seq].exist_ind = 1,
   CALL echo(build(c.index_name," - exists and need to be dropped..."))
  WITH nocounter
 ;end select
 CALL echo("update indexes...")
 UPDATE  FROM (dummyt d  WITH seq = value(t_drop->qual_cnt)),
   dm_indexes_doc did
  SET did.drop_ind = 1
  PLAN (d)
   JOIN (did
   WHERE (did.index_name=t_drop->qual[d.seq].index_name)
    AND did.drop_ind=0)
  WITH nocounter
 ;end update
 FOR (i = 1 TO t_drop->qual_cnt)
   IF ((t_drop->qual[i].exist_ind=1))
    EXECUTE dm_drop_obsolete_objects t_drop->qual[i].index_name, "INDEX", 1
   ENDIF
 ENDFOR
 DECLARE exist_count = i4 WITH public, noconstant(0)
 CALL echo("check indexes deleted...")
 SELECT INTO "nl:"
  d.seq, did.index_name
  FROM (dummyt d  WITH seq = value(t_drop->qual_cnt)),
   dm_indexes_doc did
  PLAN (d)
   JOIN (did
   WHERE (did.index_name=t_drop->qual[d.seq].index_name)
    AND did.drop_ind=0)
  DETAIL
   exist_count = (exist_count+ 1),
   CALL echo(build(did.index_name," - drop_ind is still 0 in dm_indexes_doc"))
  WITH nocounter
 ;end select
 CALL echo(build("exist_count = ",exist_count))
 IF (exist_count=0)
  CALL echo("dm_drop_sched_index1 successful...")
  SET readme_data->message = "dm_drop_sched_index1 successful"
  SET readme_data->status = "S"
  COMMIT
 ELSE
  CALL echo("dm_drop_sched_index1 failed...")
  SET readme_data->message = "dm_drop_sched_index1 failed"
  SET readme_data->status = "F"
 ENDIF
 EXECUTE dm_readme_status
#drop_end
END GO

CREATE PROGRAM dm_drop_xie3encounter:dba
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
 DECLARE icount = i4 WITH public, noconstant(0)
 DECLARE drpcount = i4 WITH public, noconstant(0)
#drop_start
 SET readme_data->status = "F"
 EXECUTE dm_drop_obsolete_objects "XIE3ENCOUNTER", "INDEX", 1
 SET icount = 0
 CALL echo("select indexes...")
 SELECT INTO "nl:"
  c.*
  FROM user_indexes c
  WHERE c.index_name IN ("XIE3ENCOUNTER")
   AND c.table_owner="V500"
  DETAIL
   icount = (icount+ 1)
  WITH nocounter
 ;end select
 CALL echo(build("iCount = ",icount))
 CALL echo("update indexes...")
 UPDATE  FROM dm_indexes_doc d
  SET d.drop_ind = 1
  WHERE d.index_name IN ("XIE3ENCOUNTER")
  WITH nocounter
 ;end update
 SET drpcount = 0
 CALL echo("check indexes deleted...")
 SELECT INTO "nl:"
  d.seq
  FROM dm_indexes_doc d
  WHERE d.index_name IN ("XIE3ENCOUNTER")
   AND d.drop_ind=0
  DETAIL
   drpcount = (drpcount+ 1)
  WITH nocounter
 ;end select
 CALL echo(build("drpCount = ",drpcount))
 IF (icount=0
  AND drpcount=0)
  CALL echo("dm_drop_XIE3ENCOUNTER successful...")
  SET readme_data->message = "dm_drop_XIE3ENCOUNTER successful"
  SET readme_data->status = "S"
  COMMIT
 ELSE
  CALL echo("dm_drop_XIE3ENCOUNTER failed...")
  SET readme_data->message = "dm_drop_XIE3ENCOUNTER failed"
  SET readme_data->status = "F"
 ENDIF
 EXECUTE dm_readme_status
#drop_end
END GO

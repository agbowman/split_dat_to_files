CREATE PROGRAM dm_drop_afc_xie2charge:dba
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
 EXECUTE dm_drop_obsolete_objects "XIE2CHARGE", "INDEX", 1
 SET icount = 0
 SELECT INTO "nl:"
  c.seq
  FROM user_indexes c
  WHERE index_name="XIE2CHARGE"
  DETAIL
   icount = (icount+ 1)
  WITH nocounter
 ;end select
 UPDATE  FROM dm_indexes_doc d
  SET drop_ind = 1
  WHERE d.index_name="XIE2CHARGE"
  WITH nocounter
 ;end update
 IF (curqual=1)
  COMMIT
 ENDIF
 SET drpind = 0
 SELECT INTO "nl:"
  d.seq
  FROM dm_indexes_doc d
  WHERE d.index_name="XIE2CHARGE"
   AND d.drop_ind=1
  DETAIL
   drpind = 1
  WITH nocounter
 ;end select
 IF (icount=0
  AND drpind=1)
  SET readme_data->status = "S"
  SET readme_data->message = "dm_drop_afc_xie2charge successful"
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "dm_drop_afc_xie2charge failed"
 ENDIF
 EXECUTE dm_readme_status
#drop_end
END GO

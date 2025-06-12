CREATE PROGRAM batch_test01:dba
 DECLARE rec_size = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
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
 SET rec_size = size(requestin->list_0,5)
 INSERT  FROM dm_table_list tl,
   (dummyt d  WITH seq = value(rec_size))
  SET tl.table_name = requestin->list_0[d.seq].table_name, tl.process_flg = cnvtint(requestin->
    list_0[d.seq].process_flg), tl.updt_applctx = cnvtint(requestin->list_0[d.seq].updt_applctx),
   tl.updt_dt_tm = cnvtdatetime(curdate,curtime3), tl.updt_cnt = cnvtint(requestin->list_0[d.seq].
    updt_cnt), tl.updt_id = cnvtreal(requestin->list_0[d.seq].updt_id),
   tl.updt_task = cnvtint(requestin->list_0[d.seq].updt_task)
  PLAN (d)
   JOIN (tl)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0)=0)
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "IT WORKED.  IT REALLY WORKED!"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("IT BROKE: ",trim(errmsg,3))
 ENDIF
 EXECUTE dm_readme_status
END GO

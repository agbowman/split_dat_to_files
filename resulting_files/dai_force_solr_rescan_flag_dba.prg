CREATE PROGRAM dai_force_solr_rescan_flag:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dai_force_solr_rescan_flag..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE serverexistsind = i2 WITH public, noconstant(0)
 DECLARE queueexistsind = i2 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="ICD9 Interrogator"
   AND di.info_name="Server Name Lock"
  DETAIL
   serverexistsind = 1
  WITH nocounter
 ;end select
 IF (serverexistsind=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "ICD9 Interrogator", di.info_name = "Server Name Lock", di.info_date =
    cnvtdatetime(curdate,curtime3),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Insert Server Name Lock Row Failed: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="ICD9 Interrogator"
   AND di.info_name="Queue Lock"
  DETAIL
   queueexistsind = 1
  WITH nocounter
 ;end select
 IF (queueexistsind=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "ICD9 Interrogator", di.info_name = "Queue Lock", di.info_date = cnvtdatetime
    (curdate,curtime3),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Insert Queue Lock Row Failed: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM dm_info
  (info_domain, info_name, info_long_id,
  info_number, info_date, updt_applctx,
  updt_cnt, updt_dt_tm, updt_id,
  updt_task)(SELECT
   "ICD9 Interrogator", concat("Force SolR Rescan ",trim(dtfd.detail_meaning,3)), dtfd
   .dm_text_find_detail_id,
   1, cnvtdatetime(curdate,curtime3), reqinfo->updt_applctx,
   0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
   reqinfo->updt_task
   FROM dm_text_find_detail dtfd
   WHERE dtfd.detail_type_flag IN (2, 4)
    AND dtfd.multi_node_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM dm_info di
    WHERE di.info_domain="ICD9 Interrogator"
     AND di.info_name=concat("Force SolR Rescan ",trim(dtfd.detail_meaning,3))
     AND di.info_long_id=dtfd.dm_text_find_detail_id
     AND di.info_number=1))))
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("SolR Rescan Row Insert Failed: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
 COMMIT
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

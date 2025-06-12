CREATE PROGRAM br_app_cat_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_app_cat_config.prg> script"
 FREE SET requestin2
 RECORD requestin2(
   1 item[*]
     2 display_group_category = vc
     2 sequence = i4
     2 category = vc
     2 cat_sequence = i4
     2 cat_exists = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET cat_cnt = size(requestin->list_0,5)
 SET stat = alterlist(requestin2->item,cat_cnt)
 SELECT INTO "NL:"
  FROM br_app_category bac
  WHERE cnvtupper(bac.description)="MEDICAL RECORDS"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "NL:"
   FROM br_app_category bac
   WHERE cnvtupper(bac.description)="HEALTH INFORMATION MANAGEMENT"
   WITH nocounter
  ;end select
  IF (curqual=0)
   UPDATE  FROM br_app_category bac
    SET bac.active_ind = 1, bac.description = "Health Information Management", bac.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     bac.updt_id = reqinfo->updt_id, bac.updt_task = reqinfo->updt_task, bac.updt_applctx = reqinfo->
     updt_applctx,
     bac.updt_cnt = (bac.updt_cnt+ 1)
    WHERE cnvtupper(bac.description)="MEDICAL RECORDS"
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed: Updating br_app_category for Medical Records:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ELSE
   DELETE  FROM br_app_category bac
    WHERE cnvtupper(bac.description)="MEDICAL RECORDS"
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed: Deleting br_app_category for Medical Records:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  DETAIL
   requestin2->item[d.seq].display_group_category = requestin->list_0[d.seq].display_group_category,
   requestin2->item[d.seq].sequence = cnvtint(requestin->list_0[d.seq].sequence), requestin2->item[d
   .seq].category = requestin->list_0[d.seq].category,
   requestin2->item[d.seq].cat_sequence = cnvtint(requestin->list_0[d.seq].cat_sequence)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure loading requestin records:",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_app_category bac,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  SET bac.active_ind = 1, bac.sequence = requestin2->item[d.seq].cat_sequence, bac.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   bac.updt_id = reqinfo->updt_id, bac.updt_task = reqinfo->updt_task, bac.updt_applctx = reqinfo->
   updt_applctx,
   bac.updt_cnt = (bac.updt_cnt+ 1)
  PLAN (d)
   JOIN (bac
   WHERE cnvtupper(bac.description)=cnvtupper(requestin2->item[d.seq].category)
    AND (bac.sequence != requestin2->item[d.seq].cat_sequence))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Updating br_app_category sequence:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "NL:"
  FROM br_app_category bac,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  PLAN (d)
   JOIN (bac
   WHERE cnvtupper(bac.description)=cnvtupper(requestin2->item[d.seq].category))
  DETAIL
   requestin2->item[d.seq].cat_exists = "Y"
  WITH nocounter
 ;end select
 INSERT  FROM br_app_category bac,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  SET bac.active_ind = 1, bac.category_id = seq(reference_seq,nextval), bac.description = requestin2
   ->item[d.seq].category,
   bac.sequence = requestin2->item[d.seq].cat_sequence, bac.display_group_desc = requestin2->item[d
   .seq].display_group_category, bac.display_group_seq = requestin2->item[d.seq].sequence,
   bac.updt_dt_tm = cnvtdatetime(curdate,curtime3), bac.updt_id = reqinfo->updt_id, bac.updt_task =
   reqinfo->updt_task,
   bac.updt_applctx = reqinfo->updt_applctx, bac.updt_cnt = 0
  PLAN (d
   WHERE cnvtupper(requestin2->item[d.seq].category) != "HEALTH INFORMATION MANAGEMENT"
    AND (requestin2->item[d.seq].cat_exists != "Y"))
   JOIN (bac)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed: Inserting into br_app_category:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_app_cat_config.prg> script"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE SET requestin2
END GO

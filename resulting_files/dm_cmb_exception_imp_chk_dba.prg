CREATE PROGRAM dm_cmb_exception_imp_chk:dba
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
 DECLARE dceic_cnt = i4 WITH public, noconstant(size(requestin->list_0,5))
 DECLARE dceic_i = i4 WITH public, noconstant(0)
 DECLARE dceic_fail_ind = i2 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_cmb_exception_imp_chk.prg script"
 FREE RECORD dceic_check_rs
 RECORD dceic_check_rs(
   1 qual[*]
     2 not_exists_ind = i2
     2 dm_info_ind = i2
     2 info_dom = vc
 )
 FOR (dceic_for_cnt = 1 TO dceic_cnt)
   SET requestin->list_0[dceic_for_cnt].operation_type = cnvtupper(requestin->list_0[dceic_for_cnt].
    operation_type)
   SET requestin->list_0[dceic_for_cnt].parent_entity = cnvtupper(requestin->list_0[dceic_for_cnt].
    parent_entity)
   SET requestin->list_0[dceic_for_cnt].child_entity = cnvtupper(requestin->list_0[dceic_for_cnt].
    child_entity)
   SET requestin->list_0[dceic_for_cnt].script_name = cnvtupper(requestin->list_0[dceic_for_cnt].
    script_name)
 ENDFOR
 SET stat = alterlist(dceic_check_rs->qual,dceic_cnt)
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = dceic_cnt)
  PLAN (d
   WHERE (requestin->list_0[d.seq].delete_row_ind=cnvtstring(0)))
   JOIN (dce
   WHERE (dce.operation_type=requestin->list_0[d.seq].operation_type)
    AND (dce.parent_entity=requestin->list_0[d.seq].parent_entity)
    AND (dce.child_entity=requestin->list_0[d.seq].child_entity))
  DETAIL
   dceic_check_rs->qual[d.seq].not_exists_ind = 1
  WITH outerjoin = d, dontexist
 ;end select
 IF (curqual > 0)
  FOR (dceic_i = 1 TO dceic_cnt)
    IF ((dceic_check_rs->qual[dceic_i].not_exists_ind=1))
     SET dceic_check_rs->qual[dceic_i].info_dom = cnvtupper(build(requestin->list_0[dceic_i].
       operation_type,"_EXCEPTION:",requestin->list_0[dceic_i].parent_entity))
     CALL echo(concat("CHECK FOR TBL ",requestin->list_0[dceic_i].child_entity,"; INFO_DOM=",
       dceic_check_rs->qual[dceic_i].info_dom))
     SELECT INTO "nl:"
      i.info_name
      FROM dm_info i
      WHERE (i.info_domain=dceic_check_rs->qual[dceic_i].info_dom)
       AND (i.info_name=requestin->list_0[dceic_i].child_entity)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET readme_data->status = "F"
      SET readme_data->message = build("dm_cmb_exception row not found for operation_type=",requestin
       ->list_0[dceic_i].operation_type,", parent_entity=",requestin->list_0[dceic_i].parent_entity,
       ", child_entity=",
       requestin->list_0[dceic_i].child_entity)
      SET dceic_fail_ind = 1
      CALL echo("row from csv is missing from db")
     ENDIF
    ENDIF
  ENDFOR
  IF (dceic_fail_ind != 1)
   SET readme_data->status = "S"
   SET readme_data->message = "SUCCESS: all rows imported into dm_cmb_exception"
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: all rows imported into dm_cmb_exception"
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
#dceic_exit
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSEIF ((readme_data->status="S"))
  COMMIT
 ENDIF
 FREE RECORD dceic_check_rs
END GO

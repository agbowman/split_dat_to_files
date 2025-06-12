CREATE PROGRAM dm_rdm_upd_favs_active_gdpr:dba
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
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt += 1, drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt += 1
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: Starting dm_rdm_upd_favs_active_gdpr.."
 DECLARE error_cd = f8 WITH protected, noconstant(0.0)
 DECLARE error_msg = c132 WITH protected, noconstant("")
 SET readme_data->message = "Readme failed..."
 DECLARE range_inc = f8 WITH protect, noconstant(250000.0)
 DECLARE min_range = f8 WITH protect, noconstant(1.0)
 DECLARE max_range = f8 WITH protect, noconstant(range_inc)
 DECLARE min_id = f8 WITH protect, noconstant(0.0)
 DECLARE max_id = f8 WITH protect, noconstant(0.0)
 DECLARE column_exists(stable,scolumn) = i4
 SET stat = alterlist(drr_validate_table->list,2)
 SET drr_validate_table->list[1].table_name = "messaging_favorite2008drr"
 SET nshadowtablecount = drr_table_and_ccldef_exists(null)
 IF (nshadowtablecount != 0
  AND nshadowtablecount != 1)
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ELSEIF (nshadowtablecount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Shadow table(s) not found"
  GO TO exit_program
 ENDIF
 IF (column_exists("messaging_favorite2008drr","ACTIVE_IND")=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Column - Active_ind not found in messaging_favorite2008drr schema"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  min_val = min(mf.favorite_id), max_val = max(mf.favorite_id)
  FROM messaging_favorite2008drr mf
  WHERE mf.favorite_id > 1.0
  DETAIL
   min_id = min_val, max_id = max_val
  WITH nocounter
 ;end select
 CALL echo(build("minimum_favorite_id---->>",min_id))
 CALL echo(build("maximum_favorite_id--->>",max_id))
 SET max_range = (min_id+ range_inc)
 SET min_range = min_id
 SET error_cd = error(error_msg,0)
 IF (error_cd != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Min and Max Favorite_Ids retrieval from Messaging_Favorites: ",
   error_msg)
  GO TO exit_program
 ENDIF
 SET readme_data->message =
 "Readme failed: Updating messaging_favorite2008drr with active_ind = 1..."
 DECLARE total_updt_cnt = f8 WITH protect, noconstant(0.0)
 CALL echo("*******************************************************")
 CALL echo("Updating Messaging_Favorites with Active_Ind value 1..")
 CALL echo(concat("-> Process started at: ",format(sysdate,";;q")))
 CALL echo("*******************************************************")
 WHILE (min_range <= max_id)
   CALL echo(build("max_range--> ",max_range))
   UPDATE  FROM messaging_favorite2008drr mf
    SET mf.active_ind = 1, mf.updt_cnt = (mf.updt_cnt+ 1), mf.updt_id = reqinfo->updt_id,
     mf.updt_task = reqinfo->updt_task, mf.updt_applctx = reqinfo->updt_applctx
    WHERE mf.favorite_id BETWEEN min_range AND max_range
     AND mf.active_ind=null
    WITH nocounter
   ;end update
   SET total_updt_cnt = (curqual+ total_updt_cnt)
   IF (error(error_msg,0) != 0)
    CALL echo("Processing FAILED...")
    CALL echo(concat("Failure during update of messaging_favorite2008drr table:",error_msg))
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during messaging_favorite2008drr update:",error_msg)
    GO TO exit_program
   ELSE
    COMMIT
   ENDIF
   SET min_range = (max_range+ 1)
   SET max_range += range_inc
   CALL echo(build("min_range --> ",min_range))
   CALL echo(build("max_range --> ",max_range))
   CALL echo(build("max_id --> ",max_id))
   CALL echo(build("total_updt_cnt --> ",total_updt_cnt))
 ENDWHILE
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
    IF (error(ms_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error finding column existence: ",ms_errmsg)
     GO TO exit_program
    ENDIF
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = concat("Readme updated ",trim(cnvtstring(total_updt_cnt)),
  " record(s) successfully.")
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

CREATE PROGRAM dcp_pl_transformation:dba
 RECORD temp1(
   1 cust_cols[*]
     2 caption = c40
     2 custom_column_cd = f8
     2 custom_column_meaning = c12
     2 position_cd = f8
     2 prsnl_id = f8
     2 spread_type_cd = f8
     2 sequence_ind = i2
 )
 RECORD temp2(
   1 cols_sort[*]
     2 column_cd = f8
     2 column_description = c12
     2 position_cd = f8
     2 prsnl_id = f8
     2 spread_type_cd = f8
     2 sort_direction_ind = i2
     2 sort_level_flag = i2
     2 sort_type_flag = i2
 )
 RECORD temp3(
   1 pl[*]
     2 patient_list_id = f8
 )
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
 DECLARE customcolscopy(x) = null WITH private
 DECLARE sortcopy(x) = null WITH private
 DECLARE removelagminutes(x) = null WITH private
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE visitreltncd = f8 WITH noconstant(0.0)
 DECLARE reltncd = f8 WITH noconstant(0.0)
 DECLARE assigncd = f8 WITH noconstant(0.0)
 DECLARE ancassigncd = f8 WITH noconstant(0.0)
 DECLARE rdm_errcode = i4 WITH public, noconstant(0)
 DECLARE rdm_errmsg = c132 WITH public, noconstant(fillstring(132," "))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6022
  DETAIL
   IF (cv.cdf_meaning="PTVRELTNLST")
    visitreltncd = cv.code_value
   ELSEIF (cv.cdf_meaning="PTRELTNLST")
    reltncd = cv.code_value
   ENDIF
  WITH constant
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=27360
  DETAIL
   IF (cv.cdf_meaning="ASSIGNMENT")
    assigncd = cv.code_value
   ELSEIF (cv.cdf_meaning="ANC_ASGMT")
    ancassigncd = cv.code_value
   ENDIF
  WITH constant
 ;end select
 CALL echo(visitreltncd)
 CALL echo(reltncd)
 IF (visitreltncd > 0
  AND reltncd > 0)
  CALL customcolscopy(1)
  CALL sortcopy(1)
 ENDIF
 CALL removelagminutes(1)
 FREE RECORD temp1
 FREE RECORD temp2
 FREE RECORD temp3
 SET readme_data->message = "Transformation complete"
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 SUBROUTINE customcolscopy(x)
   SET count1 = 0
   SELECT INTO "nl:"
    FROM dcp_custom_columns d
    WHERE d.spread_type_cd=visitreltncd
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(temp1->cust_cols,(count1+ 9))
     ENDIF
     temp1->cust_cols[count1].caption = d.caption, temp1->cust_cols[count1].custom_column_cd = d
     .custom_column_cd, temp1->cust_cols[count1].custom_column_meaning = d.custom_column_meaning,
     temp1->cust_cols[count1].position_cd = d.position_cd, temp1->cust_cols[count1].prsnl_id = d
     .prsnl_id, temp1->cust_cols[count1].sequence_ind = d.sequence_ind,
     temp1->cust_cols[count1].spread_type_cd = reltncd
    FOOT REPORT
     stat = alterlist(temp1->cust_cols,count1)
    WITH nocounter
   ;end select
   FOR (x = 1 TO count1)
     SELECT INTO "nl:"
      FROM dcp_custom_columns d
      WHERE d.spread_type_cd=reltncd
       AND (d.caption=temp1->cust_cols[x].caption)
       AND (d.custom_column_cd=temp1->cust_cols[x].custom_column_cd)
       AND (d.custom_column_meaning=temp1->cust_cols[x].custom_column_meaning)
       AND (d.position_cd=temp1->cust_cols[x].position_cd)
       AND (d.prsnl_id=temp1->cust_cols[x].prsnl_id)
       AND (d.sequence_ind=temp1->cust_cols[x].sequence_ind)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM dcp_custom_columns d
       SET d.spread_column_id = cnvtint(seq(reference_seq,nextval)), d.caption = temp1->cust_cols[x].
        caption, d.custom_column_cd = temp1->cust_cols[x].custom_column_cd,
        d.custom_column_meaning = temp1->cust_cols[x].custom_column_meaning, d.position_cd = temp1->
        cust_cols[x].position_cd, d.prsnl_id = temp1->cust_cols[x].prsnl_id,
        d.sequence_ind = temp1->cust_cols[x].sequence_ind, d.spread_type_cd = temp1->cust_cols[x].
        spread_type_cd, d.updt_applctx = reqinfo->updt_applctx,
        d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
        d.updt_task = reqinfo->updt_task
       WITH counter
      ;end insert
     ENDIF
     IF (mod(x,1000)=0)
      SET readme_status = "S"
      SET readme_data->message = "Commit part of the custom column copy loop."
      COMMIT
      EXECUTE dm_readme_status
     ELSEIF (x=count1)
      SET readme_status = "S"
      SET readme_data->message = "Commit the final custom column copy."
      COMMIT
      EXECUTE dm_readme_status
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE sortcopy(x)
   SET count1 = 0
   SELECT INTO "nl:"
    FROM dcp_custom_cols_sort d
    WHERE d.spread_type_cd=visitreltncd
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(temp2->cols_sort,(count1+ 9))
     ENDIF
     temp2->cols_sort[count1].column_cd = d.column_cd, temp2->cols_sort[count1].column_description =
     d.column_description, temp2->cols_sort[count1].position_cd = d.position_cd,
     temp2->cols_sort[count1].prsnl_id = d.prsnl_id, temp2->cols_sort[count1].sort_direction_ind = d
     .sort_direction_ind, temp2->cols_sort[count1].sort_level_flag = d.sort_level_flag,
     temp2->cols_sort[count1].sort_type_flag = d.sort_type_flag, temp2->cols_sort[count1].
     spread_type_cd = reltncd
    FOOT REPORT
     stat = alterlist(temp2->cols_sort,count1)
    WITH nocounter
   ;end select
   FOR (x = 1 TO count1)
     SELECT INTO "nl:"
      FROM dcp_custom_cols_sort d
      WHERE d.spread_type_cd=reltncd
       AND (d.column_cd=temp2->cols_sort[x].column_cd)
       AND (d.column_description=temp2->cols_sort[x].column_description)
       AND (d.position_cd=temp2->cols_sort[x].position_cd)
       AND (d.prsnl_id=temp2->cols_sort[x].prsnl_id)
       AND (d.sort_direction_ind=temp2->cols_sort[x].sort_direction_ind)
       AND (d.sort_level_flag=temp2->cols_sort[x].sort_level_flag)
       AND (d.sort_type_flag=temp2->cols_sort[x].sort_type_flag)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM dcp_custom_cols_sort d
       SET d.column_sort_id = cnvtint(seq(carenet_seq,nextval)), d.column_cd = temp2->cols_sort[x].
        column_cd, d.column_description = temp2->cols_sort[x].column_description,
        d.position_cd = temp2->cols_sort[x].position_cd, d.prsnl_id = temp2->cols_sort[x].prsnl_id, d
        .sort_direction_ind = temp2->cols_sort[x].sort_direction_ind,
        d.sort_level_flag = temp2->cols_sort[x].sort_level_flag, d.sort_type_flag = temp2->cols_sort[
        x].sort_type_flag, d.spread_type_cd = temp2->cols_sort[x].spread_type_cd,
        d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task
       WITH counter
      ;end insert
     ENDIF
     IF (mod(x,1000)=0)
      SET readme_status = "S"
      SET readme_data->message = "Commit part of sort column copy loop."
      COMMIT
      EXECUTE dm_readme_status
     ELSEIF (x=count1)
      SET readme_status = "S"
      SET readme_data->message = "Commit the final sort column copy."
      COMMIT
      EXECUTE dm_readme_status
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE removelagminutes(x)
  DECLARE continue = i2 WITH noconstant(1)
  WHILE (continue > 0)
   DELETE  FROM dcp_pl_argument a,
     dcp_patient_list p,
     dummyt d
    SET a.seq = 1
    PLAN (a
     WHERE a.argument_name="lag_minutes")
     JOIN (d)
     JOIN (p
     WHERE p.patient_list_id=a.patient_list_id)
    WITH maxqual(dcp_pl_argument,1000)
   ;end delete
   IF (curqual < 1000)
    SET readme_status = "S"
    SET readme_data->message = "Commit part of the lag minute deletion loop."
    COMMIT
    EXECUTE dm_readme_status
    SET continue = 0
   ENDIF
  ENDWHILE
 END ;Subroutine
END GO

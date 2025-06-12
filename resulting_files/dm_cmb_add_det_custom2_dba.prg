CREATE PROGRAM dm_cmb_add_det_custom2:dba
 CALL echo("...")
 CALL echo("ADD_CMB_DET_CUSTOM2")
 CALL echo("...")
 DECLARE cmb_det_size = i4
 SET cmb_det_size = size(request->xxx_combine_det,5)
 IF (cmb_det_size > 0)
  FOR (dcadc_lpcnt = 1 TO cmb_det_size)
   SET request->xxx_combine_det[dcadc_lpcnt].xxx_combine_id = request->xxx_combine[icombine].
   xxx_combine_id
   SELECT INTO "nl:"
    y = seq(combine_seq,nextval)
    FROM dual
    DETAIL
     request->xxx_combine_det[dcadc_lpcnt].entity_id = cnvtreal(y)
    WITH nocounter
   ;end select
  ENDFOR
  SET ecode = error(emsg,1)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO det_cust2_err
  ENDIF
  SET pknum = size(request->xxx_combine_det[1].entity_pk,5)
  SET error_table = request->xxx_combine_det[1].entity_name
  INSERT  FROM combine_detail cd,
    (dummyt d  WITH seq = value(cmb_det_size))
   SET cd.combine_detail_id = request->xxx_combine_det[d.seq].entity_id, cd.combine_id = request->
    xxx_combine[icombine].xxx_combine_id, cd.entity_name = request->xxx_combine_det[d.seq].
    entity_name,
    cd.entity_id = request->xxx_combine_det[d.seq].entity_id, cd.combine_action_cd = request->
    xxx_combine_det[d.seq].combine_action_cd, cd.attribute_name = request->xxx_combine_det[d.seq].
    attribute_name,
    cd.active_ind = active_active_ind, cd.active_status_cd = reqdata->active_status_cd, cd
    .active_status_dt_tm = cnvtdatetime(sysdate),
    cd.active_status_prsnl_id = reqinfo->updt_id, cd.updt_cnt = init_updt_cnt, cd.updt_dt_tm =
    cnvtdatetime(sysdate),
    cd.updt_id = reqinfo->updt_id, cd.updt_task = reqinfo->updt_task, cd.updt_applctx = reqinfo->
    updt_applctx,
    cd.prev_active_ind = request->xxx_combine_det[d.seq].prev_active_ind, cd.prev_active_status_cd =
    request->xxx_combine_det[d.seq].prev_active_status_cd, cd.prev_end_eff_dt_tm = cnvtdatetime(
     request->xxx_combine_det[d.seq].prev_end_eff_dt_tm),
    cd.to_record_ind = request->xxx_combine_det[d.seq].to_record_ind
   PLAN (d)
    JOIN (cd)
   WITH nocounter
  ;end insert
  SET ecode = error(emsg,1)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO det_cust2_err
  ENDIF
  SET count_of_inserts += cmb_det_size
  FOR (dcdc_cmb_det_cnt = 1 TO icombinedet)
    FOR (dcdc_cnt3 = 1 TO pknum)
      IF ((request->xxx_combine_det[dcdc_cmb_det_cnt].entity_pk[dcdc_cnt3].data_type != patstring(
       "TIMESTAMP*")))
       SET p_buf[1] = "insert into ENTITY_DETAIL ED"
       SET p_buf[2] = "set ed.entity_id = request->xxx_combine_det[dcdc_cmb_det_cnt]->entity_id,"
       SET p_buf[3] =
       "ed.column_name = request->xxx_combine_det[dcdc_cmb_det_cnt]->entity_pk[dcdc_cnt3]->col_name,"
       SET p_buf[4] =
       "ed.data_type = request->xxx_combine_det[dcdc_cmb_det_cnt]->entity_pk[dcdc_cnt3]->data_type,"
       CASE (request->xxx_combine_det[dcdc_cmb_det_cnt].entity_pk[dcdc_cnt3].data_type)
        OF "VARCHAR":
        OF "CHAR":
        OF "VARCHAR2":
         SET p_buf[5] =
         "ed.data_char = request->xxx_combine_det[dcdc_cmb_det_cnt]->entity_pk[dcdc_cnt3]->data_char"
        OF "TIME":
        OF "DATE":
         SET p_buf[5] =
         "ed.data_date = cnvtdatetime(request->xxx_combine_det[dcdc_cmb_det_cnt]->entity_pk[dcdc_cnt3]->data_date)"
        OF "INTEGER":
        OF "DOUBLE":
        OF "BIGINT":
        OF "NUMBER":
        OF "FLOAT":
         SET p_buf[5] =
         "ed.data_number = request->xxx_combine_det[dcdc_cmb_det_cnt]->entity_pk[dcdc_cnt3]->data_number"
       ENDCASE
       SET p_buf[6] = "with nocounter go"
       FOR (buf_cnt = 1 TO 6)
         IF (dm_debug_cmb=1)
          CALL echo(p_buf[buf_cnt])
         ENDIF
         CALL parser(p_buf[buf_cnt],1)
         SET p_buf[buf_cnt] = fillstring(132," ")
       ENDFOR
       SET ecode = error(emsg,1)
       IF (ecode != 0)
        SET failed = ccl_error
        GO TO det_cust2_err
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#det_cust2_err
END GO

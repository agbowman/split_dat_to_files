CREATE PROGRAM cp_insert_provider_route:dba
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
 DECLARE newchart_route_id = f8
 DECLARE error_holder = i4
 DECLARE prov_seq_cd = f8
 DECLARE count = i4
 DECLARE result = f8
 DECLARE error_code = i4
 DECLARE errmsg = vc
 DECLARE constantname = vc
 DECLARE constantnamekey = vc
 DECLARE provider_route_type = i2 WITH constant(1)
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 SET constantname = "Converted Provider Route Sequence" WITH constant
 SET constantnamekey = "CONVERTEDPROVIDERROUTESEQUENCE" WITH constant
 SET count = 0
 SET error_holder = 0
 FREE RECORD temp_co
 RECORD temp_co(
   1 qual[*]
     2 charting_operations_id = f8
     2 sequence = i4
     2 batch_name = vc
     2 batch_name_key = vc
     2 param_type_flag = i2
     2 param = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 update_ind = i2
     2 rowid = c18
 )
 FREE RECORD temp_seq_group_id
 RECORD temp_seq_group_id(
   1 qual[*]
     2 sequence_group_id = f8
 )
 SELECT INTO "nl:"
  FROM chart_route cr
  WHERE cr.route_name_key="CONVERTEDPROVIDERROUTESEQUENCE"
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM chart_sequence_group csg
  WHERE csg.group_type_flag=1
   AND csg.active_ind=1
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  newid = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   newchart_route_id = newid
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_holder = ngen_nbr_error
  GO TO exit_script
 ENDIF
 INSERT  FROM chart_route cr
  SET cr.chart_route_id = newchart_route_id, cr.route_name = constantname, cr.route_name_key =
   constantnamekey,
   cr.active_ind = 1, cr.route_type_flag = provider_route_type
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_holder = nupdate_cnt_error
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  csg.sequence_group_id
  FROM chart_sequence_group csg
  WHERE csg.group_type_flag=provider_route_type
   AND csg.active_ind=1
  DETAIL
   count += 1
   IF (count > size(temp_seq_group_id->qual,5))
    stat = alterlist(temp_seq_group_id->qual,(count+ 9))
   ENDIF
   temp_seq_group_id->qual[count].sequence_group_id = csg.sequence_group_id
  FOOT REPORT
   stat = alterlist(temp_seq_group_id->qual,count)
  WITH nocounter
 ;end select
 UPDATE  FROM chart_sequence_group csg
  SET csg.chart_route_id = newchart_route_id
  WHERE csg.group_type_flag=provider_route_type
   AND csg.active_ind=1
  WITH nocounter
 ;end update
 FOR (i = 1 TO size(temp_seq_group_id->qual,5))
   UPDATE  FROM chart_seq_group_reltn csgr
    SET csgr.sequence_nbr = (csgr.sequence_nbr+ 1)
    WHERE (csgr.sequence_group_id=temp_seq_group_id->qual[i].sequence_group_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=22011
    AND c.cdf_meaning="19")
  DETAIL
   prov_seq_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_holder = ngen_nbr_error
  GO TO exit_script
 ENDIF
 SET count = 0
 SELECT INTO "nl:"
  FROM charting_operations cr
  WHERE param_type_flag=15
   AND param=trim(cnvtstring(prov_seq_cd))
   AND active_ind=1
  DETAIL
   count += 1
   IF (count > size(temp_co->qual,5))
    stat = alterlist(temp_co->qual,(count+ 9))
   ENDIF
   temp_co->qual[count].charting_operations_id = cr.charting_operations_id, temp_co->qual[count].
   sequence = cr.sequence, temp_co->qual[count].batch_name = cr.batch_name,
   temp_co->qual[count].batch_name_key = cr.batch_name_key, temp_co->qual[count].param_type_flag = 21,
   temp_co->qual[count].param = trim(cnvtstring(newchart_route_id)),
   temp_co->qual[count].active_ind = cr.active_ind, temp_co->qual[count].active_status_cd = cr
   .active_status_cd, temp_co->qual[count].active_status_dt_tm = cr.active_status_dt_tm,
   temp_co->qual[count].active_status_prsnl_id = cr.active_status_prsnl_id, temp_co->qual[count].
   updt_cnt = cr.updt_cnt, temp_co->qual[count].updt_dt_tm = cr.updt_dt_tm,
   temp_co->qual[count].updt_id = cr.updt_id, temp_co->qual[count].updt_task = cr.updt_task, temp_co
   ->qual[count].updt_applctx = cr.updt_applctx,
   temp_co->qual[count].update_ind = cr.update_ind
  FOOT REPORT
   stat = alterlist(temp_co->qual,count)
  WITH counter
 ;end select
 FOR (i = 1 TO size(temp_co->qual,5))
   SET result = 0
   CALL echo("****ERROR***")
   SELECT INTO "nl:"
    sequence = co2.sequence
    FROM charting_operations co2
    WHERE (co2.charting_operations_id=temp_co->qual[count].charting_operations_id)
    FOOT REPORT
     result = max(sequence)
    WITH nocounter
   ;end select
   SET result += 1
   INSERT  FROM charting_operations co
    SET co.charting_operations_id = temp_co->qual[i].charting_operations_id, co.sequence = result, co
     .batch_name = temp_co->qual[i].batch_name,
     co.batch_name_key = temp_co->qual[i].batch_name_key, co.param_type_flag = temp_co->qual[i].
     param_type_flag, co.param = temp_co->qual[i].param,
     co.active_ind = temp_co->qual[i].active_ind, co.active_status_cd = temp_co->qual[i].
     active_status_cd, co.active_status_dt_tm = cnvtdatetime(temp_co->qual[i].active_status_dt_tm),
     co.active_status_prsnl_id = temp_co->qual[i].active_status_prsnl_id, co.updt_cnt = temp_co->
     qual[i].updt_cnt, co.updt_dt_tm = cnvtdatetime(temp_co->qual[i].updt_dt_tm),
     co.updt_id = temp_co->qual[i].updt_id, co.updt_task = temp_co->qual[i].updt_task, co
     .updt_applctx = temp_co->qual[i].updt_applctx,
     co.update_ind = temp_co->qual[i].update_ind
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_holder = nupdate_cnt_error
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 SET error_code = error(errmsg,0)
 IF (((error_code != 0) OR (error_holder != 0)) )
  SET readme_data->status = "F"
  SET readme_data->message = errmsg
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success"
 ENDIF
 IF ((readme_data->message != "F"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echo(build("STATUS_README = ",readme_data->status))
 CALL echo(build("STATUS_MESSAGE = ",readme_data->message))
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

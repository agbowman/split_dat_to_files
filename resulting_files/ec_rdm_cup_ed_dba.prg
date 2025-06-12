CREATE PROGRAM ec_rdm_cup_ed:dba
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
 SET readme_data->message = "Readme Failed: Starting script ec_rdm_cup_ed.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE measurementnbr = i4 WITH constant(122), protect
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE icur_list_size = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE inew_list_size = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 DECLARE pos = i4 WITH noconstant(0)
 FREE RECORD measurement
 RECORD measurement(
   1 qualcnt = i4
   1 qual[*]
     2 inumber = i4
     2 sprogramname = vc
     2 bexists = i2
     2 bon = i2
 )
 SET stat = alterlist(measurement->qual,measurementnbr)
 SET measurement->qualcnt = measurementnbr
 FOR (idx = 1 TO measurementnbr)
   SET measurement->qual[idx].inumber = idx
   SET measurement->qual[idx].sprogramname = build("EC_PROFILER_M",idx)
   IF ( NOT (idx IN (13, 15, 26, 29, 30,
   34, 38, 39, 40, 42,
   55, 65, 89, 101, 111,
   112, 113, 118, 120)))
    SET measurement->qual[idx].bon = 1
   ENDIF
 ENDFOR
 SET icur_list_size = size(measurement->qual,5)
 SET iloop_cnt = ceil((cnvtreal(icur_list_size)/ ibatch_size))
 SET inew_list_size = (iloop_cnt * ibatch_size)
 SET stat = alterlist(measurement->qual,inew_list_size)
 FOR (ifor_idx = (icur_list_size+ 1) TO inew_list_size)
   SET measurement->qual[ifor_idx].inumber = measurement->qual[icur_list_size].inumber
 ENDFOR
 SET istart = 1
 SET iexpandidx = 0
 SELECT INTO "nl"
  FROM ec_measurement em,
   (dummyt d  WITH seq = value(iloop_cnt))
  PLAN (d
   WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
   JOIN (em
   WHERE expand(iexpandidx,istart,(istart+ (ibatch_size - 1)),em.measurement_nbr,measurement->qual[
    iexpandidx].inumber))
  DETAIL
   pos = locateval(idx,1,measurement->qualcnt,em.measurement_nbr,measurement->qual[idx].inumber)
   IF (pos > 0)
    measurement->qual[pos].bexists = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(measurement->qual,icur_list_size)
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error identifying existence of measurements: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM ec_measurement em,
   (dummyt d  WITH seq = value(measurement->qualcnt))
  SET em.ec_measurement_id = seq(ec_seq,nextval), em.measurement_nbr = measurement->qual[d.seq].
   inumber, em.days_of_week_bit = 127,
   em.program_name = measurement->qual[d.seq].sprogramname, em.active_ind = measurement->qual[d.seq].
   bon, em.updt_cnt = 0,
   em.updt_task = reqinfo->updt_task, em.updt_applctx = reqinfo->updt_applctx, em.updt_id = reqinfo->
   updt_id,
   em.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (measurement->qual[d.seq].bexists=0)
    AND (measurement->qual[d.seq].bon=1))
   JOIN (em)
  WITH nocounter
 ;end insert
 UPDATE  FROM ec_measurement em,
   (dummyt d  WITH seq = value(measurement->qualcnt))
  SET em.active_ind = measurement->qual[d.seq].bon, em.updt_cnt = (em.updt_cnt+ 1), em.updt_task =
   reqinfo->updt_task,
   em.updt_applctx = reqinfo->updt_applctx, em.updt_id = reqinfo->updt_id, em.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (measurement->qual[d.seq].bexists=1))
   JOIN (em
   WHERE (em.measurement_nbr=measurement->qual[d.seq].inumber))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error creating measurements: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

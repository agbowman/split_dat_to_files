CREATE PROGRAM bbd_add_ship_container:dba
 RECORD reply(
   1 container_id = f8
   1 container_nbr = i4
   1 temperature = f8
   1 temperature_degree_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE update_ship_status = c1 WITH protect, noconstant("F")
 DECLARE new_container_id = f8 WITH protect, noconstant(0.0)
 DECLARE max_container_nbr = i4 WITH protect, noconstant(0)
 DECLARE celsius_cd = f8 WITH protect, noconstant(0.0)
 DECLARE unit_of_measure_cs = i4 WITH protect, constant(54)
 DECLARE celsius_cdf = c12 WITH protect, constant("CELSIUS")
 SET celsius_cd = uar_get_code_by("MEANING",unit_of_measure_cs,nullterm(celsius_cdf))
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_container_id = seqn
  WITH format, nocounter
 ;end select
 SET reply->container_id = new_container_id
 SELECT INTO "nl:"
  c.container_id
  FROM bb_ship_container c
  WHERE (c.shipment_id=request->shipment_id)
   AND c.active_ind=1
  DETAIL
   IF (c.container_nbr > max_container_nbr)
    max_container_nbr = c.container_nbr
   ENDIF
  WITH nocounter
 ;end select
 SET reply->container_nbr = (max_container_nbr+ 1)
 SET reply->temperature = 0
 SET reply->temperature_degree_cd = celsius_cd
 SELECT INTO "nl:"
  FROM container_condition_r ccr
  WHERE (ccr.container_type_cd=request->container_type_cd)
   AND (ccr.condition_cd=request->container_condition_cd)
  DETAIL
   reply->temperature = ccr.cntnr_temperature_value
   IF (ccr.cntnr_temperature_degree_cd > 0.0)
    reply->temperature_degree_cd = ccr.cntnr_temperature_degree_cd
   ENDIF
  WITH nocounter
 ;end select
 INSERT  FROM bb_ship_container c
  SET c.container_id = new_container_id, c.container_nbr = reply->container_nbr, c.shipment_id =
   request->shipment_id,
   c.container_type_cd = request->container_type_cd, c.container_condition_cd = request->
   container_condition_cd, c.total_weight = 0,
   c.unit_of_meas_cd = 0.0, c.temperature_value = reply->temperature, c.temperature_degree_cd = reply
   ->temperature_degree_cd,
   c.active_ind = 1, c.active_status_cd = reqdata->active_status_cd, c.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   c.active_status_prsnl_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_add_ship_container.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_add_ship_container"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error on inserting new container information."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((reply->container_nbr=1))
  UPDATE  FROM bb_shipment s
   SET s.shipment_status_flag = 1, s.updt_applctx = reqinfo->updt_applctx, s.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_cnt = (s.updt_cnt+ 1)
   WHERE (s.shipment_id=request->shipment_id)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_add_ship_container.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_add_ship_container"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error on updating the shipment status flag to 'In Progress'."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

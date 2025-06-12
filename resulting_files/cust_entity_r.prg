CREATE PROGRAM cust_entity_r
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD record_data(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stableowner = vc WITH protect, noconstant("V500_BHS")
 IF (substring(1,2,stableowner)="$$")
  SET stableowner = "V500_BHS"
 ENDIF
 IF (curgroup != 0)
  SET record_data->status_data.status = "F"
  SET record_data->status_data.subeventstatus.targetobjectvalue =
  "User does not have group 0 privileges"
  RETURN
 ENDIF
 IF (checkdic("CUST_ENTITY_R","T",0)=0)
  SELECT INTO TABLE cust_entity_r
   cust_entity_r_id = type("f8"), entity1_name = type("vc"), entity1_id = type("f8"),
   entity2_name = type("vc"), entity2_id = type("f8"), entity_reltn_mean = type("vc"),
   beg_effective_dt_tm = type("dq8"), end_effective_dt_tm = type("dq8"), updt_id = type("f8"),
   updt_dt_tm = type("dq8"), updt_cnt = type("i4"), updt_task = type("i4"),
   updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_entity_r_id), index(entity1_name,entity1_id), owner = value(stableowner),
    synonym = "CUST_ENTITY_R", organization = p
  ;end select
  DROP TABLE cust_entity_r
  EXECUTE oragen3 "V500_BHS.CUST_ENTITY_R"
  IF (checkdic("CUST_ENTITY_R","T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Table CUST_ENTITY_R created successfully"
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus.targetobjectvalue = "Error creating CUST_ENTITY_R"
  ENDIF
 ELSE
  SET record_data->status_data.status = "S"
  SET record_data->status_data.subeventstatus.targetobjectvalue =
  "No changes are necessary to CUST_ENTITY_R"
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
 CALL echorecord(record_data)
END GO

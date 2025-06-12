CREATE PROGRAM cust_physician_cc_stage
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
 DECLARE stablename = vc WITH protect, noconstant("CUST_PHYSICIAN_CC_STAGE")
 DECLARE stableowner = vc WITH protect, noconstant("$$CUSTTABLEOWNER$$")
 IF (substring(1,2,stableowner)="$$")
  SET stableowner = "V500"
 ENDIF
 IF (curgroup != 0)
  SET record_data->status_data.status = "F"
  SET record_data->status_data.subeventstatus.targetobjectvalue =
  "User does not have group 0 privileges"
  RETURN
 ENDIF
 IF (checkdic(stablename,"T",0)=0)
  SELECT INTO TABLE cust_physician_cc_stage
   cust_physician_cc_stage_id = type("f8"), report_request_id = type("f8"), comm_json = type(
    "zvc32000"),
   status = type("vc"), updt_dt_tm = type("dq8"), updt_id = type("f8"),
   updt_cnt = type("i4"), updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_physician_cc_stage_id), index(cust_physician_cc_stage_id,status,updt_dt_tm),
    index(updt_dt_tm),
    owner = value("V500_BHS"), synonym = value(stablename), organization = p
  ;end select
  DROP TABLE cust_physician_cc_stage
  EXECUTE oragen3 stablename
  IF (checkdic(stablename,"T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue = concat("Table ",stablename,
    " created successfully")
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus.targetobjectvalue = concat("Error creating ",
    stablename)
  ENDIF
 ELSE
  SET record_data->status_data.status = "S"
  SET record_data->status_data.subeventstatus.targetobjectvalue = concat(
   "No changes are necessary to ",stablename)
 ENDIF
 CALL echorecord(record_data)
 SET _memory_reply_string = cnvtrectojson(record_data)
END GO

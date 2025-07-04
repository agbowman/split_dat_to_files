CREATE PROGRAM cust_user_groups
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
 IF (checkdic("CUST_USER_GROUPS","T",0)=0)
  SELECT INTO TABLE cust_user_groups
   cust_user_group_id = type("f8"), group_display = type("vc"), group_key = type("vc"),
   group_description = type("vc"), beg_effective_dt_tm = type("dq8"), end_effective_dt_tm = type(
    "dq8"),
   active_ind = type("i4"), updt_id = type("f8"), updt_dt_tm = type("dq8"),
   updt_cnt = type("i4"), updt_task = type("i4"), updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_user_group_id), index(group_key), index(updt_dt_tm),
    owner = value(stableowner), synonym = "CUST_USER_GROUPS", organization = p
  ;end select
  DROP TABLE cust_user_groups
  EXECUTE oragen3 "V500_BHS.CUST_USER_GROUPS"
  IF (checkdic("CUST_USER_GROUPS","T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Table CUST_USER_GROUPS created successfully"
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus.targetobjectvalue = "Error creating CUST_USER_GROUPS"
  ENDIF
 ELSE
  SET record_data->status_data.status = "S"
  SET record_data->status_data.subeventstatus.targetobjectvalue =
  "No changes are necessary to CUST_USER_GROUPS"
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
 CALL echorecord(record_data)
END GO

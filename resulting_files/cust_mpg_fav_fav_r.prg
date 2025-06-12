CREATE PROGRAM cust_mpg_fav_fav_r
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
 IF (checkdic("CUST_MPG_FAV_FAV_R","T",0)=0)
  SELECT INTO TABLE cust_mpg_fav_fav_r
   cust_mpg_fav_fav_r_id = type("f8"), parent_id = type("f8"), child_id = type("f8"),
   sequence = type("i4"), updt_id = type("f8"), updt_dt_tm = type("dq8"),
   updt_task = type("i4"), updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_mpg_fav_fav_r_id), index(parent_id), index(child_id),
    index(updt_dt_tm), owner = value(stableowner), synonym = "CUST_MPG_FAV_FAV_R",
    organization = p
  ;end select
  DROP TABLE cust_mpg_fav_fav_r
  EXECUTE oragen3 "V500_BHS.CUST_MPG_FAV_FAV_R"
  IF (checkdic("CUST_MPG_FAV_FAV_R","T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Table CUST_MPG_FAV_FAV_R created successfully"
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Error creating CUST_MPG_FAV_FAV_R"
  ENDIF
 ELSE
  IF (checkdic("CUST_MPG_FAV_FAV_R.SEQUENCE","A",0)=0)
   RDB alter table cust_mpg_fav_fav_r add sequence number
   END ;Rdb
   DROP TABLE cust_mpg_fav_fav_r
   EXECUTE oragen3 "V500_BHS.CUST_MPG_FAV_FAV_R"
   IF (checkdic("CUST_MPG_FAV_FAV_R.SEQUENCE","A",0)=2)
    SET record_data->status_data.status = "S"
    SET record_data->status_data.subeventstatus.targetobjectvalue =
    "Field CUST_MPG_FAV_FAV_R.SEQUENCE added successfully"
   ELSE
    SET record_data->status_data.status = "F"
    SET record_data->status_data.subeventstatus.targetobjectvalue =
    "Error updating CUST_MPG_FAV_FAV_R.SEQUENCE"
   ENDIF
  ELSE
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "No changes are necessary to CUST_MPG_FAV_FAV_R"
  ENDIF
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
END GO

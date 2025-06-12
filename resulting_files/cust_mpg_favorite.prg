CREATE PROGRAM cust_mpg_favorite
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
 IF (checkdic("CUST_MPG_FAVORITE","T",0)=0)
  SELECT INTO TABLE cust_mpg_favorite
   cust_mpg_favorite_id = type("f8"), fav_key = type("vc100"), owner_id = type("f8"),
   label = type("vc"), item_type = type("vc100"), item_detail = type("zvc32000"),
   entity_id = type("f8"), entity_name = type("vc100"), updt_id = type("f8"),
   updt_dt_tm = type("dq8"), updt_task = type("i4"), updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_mpg_favorite_id), index(fav_key,item_type,owner_id), index(updt_dt_tm),
    index(fav_key,entity_id,entity_name,owner_id), owner = value(stableowner), synonym =
    "CUST_MPG_FAVORITE",
    organization = p
  ;end select
  DROP TABLE cust_mpg_favorite
  EXECUTE oragen3 "V500_BHS.CUST_MPG_FAVORITE"
  IF (checkdic("CUST_MPG_FAVORITE","T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Table CUST_MPG_FAVORITE created successfully"
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus.targetobjectvalue = "Error creating CUST_MPG_FAVORITE"
  ENDIF
 ELSE
  IF (checkdic("CUST_MPG_FAVORITE.ENTITY_ID","A",0)=0)
   RDB alter table cust_mpg_favorite add entity_id number
   END ;Rdb
   RDB alter table cust_mpg_favorite add entity_name varchar2 ( 100 )
   END ;Rdb
   RDB create index xie4_cust_mpg_favorite on cust_mpg_favorite ( fav_key , entity_id , entity_name ,
    owner_id )
   END ;Rdb
   DROP TABLE cust_mpg_favorite
   EXECUTE oragen3 "V500_BHS.CUST_MPG_FAVORITE"
   IF (checkdic("CUST_MPG_FAVORITE.ENTITY_ID","A",0)=2)
    SET record_data->status_data.status = "S"
    SET record_data->status_data.subeventstatus.targetobjectvalue =
    "Field CUST_MPG_FAVORITE.ENTITY_ID and CUST_MPG_FAVORITE.ENTITY_NAME added successfully"
   ELSE
    SET record_data->status_data.status = "F"
    SET record_data->status_data.subeventstatus.targetobjectvalue =
    "Error updating CUST_MPG_FAVORITE.ENTITY_ID"
   ENDIF
  ELSE
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "No changes are necessary to CUST_MPG_FAVORITE"
  ENDIF
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
END GO

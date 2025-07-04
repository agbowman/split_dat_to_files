CREATE PROGRAM cust_concept_prsn_r_attr
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
 DECLARE stablename = vc WITH protect, constant("CUST_CONCEPT_PRSN_R_ATTR")
 DECLARE sdefaultmessage = vc WITH protect, constant(build2("No changes are necessary to ",trim(
    stablename),"."))
 DECLARE stableowner = vc WITH protect, noconstant("$$CUSTTABLEOWNER$$")
 DECLARE sjson = vc WITH protect, noconstant(" ")
 DECLARE ssynonymstatus = vc WITH protect, noconstant(" ")
 DECLARE bhassynonym = i4 WITH protect, noconstant(0)
 DECLARE bneedssynonym = i4 WITH protect, noconstant(0)
 DECLARE lstatuscnt = i4 WITH protect, noconstant(1)
 IF (substring(1,2,stableowner)="$$")
  SET stableowner = "V500_BHS"
 ENDIF
 IF (curgroup != 0)
  SET record_data->status_data.status = "F"
  SET record_data->status_data.subeventstatus.targetobjectvalue =
  "User does not have group 0 privileges"
  RETURN
 ENDIF
 SET record_data->status_data.status = "Z"
 SET record_data->status_data.subeventstatus[lstatuscnt].operationname = "Default Status Block"
 SET record_data->status_data.subeventstatus[lstatuscnt].operationstatus = "Z"
 SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectname = stablename
 SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectvalue = sdefaultmessage
 IF (checkdic(stablename,"T",0)=0)
  SELECT INTO TABLE cust_concept_prsn_r_attr
   active_ind = type("i4"), attr_id = type("f8"), attr_name = type("vc"),
   attr_name_id = type("f8"), attr_value = type("vc"), attr_value_id = type("f8"),
   beg_effective_dt_tm = type("dq8"), cust_concept_person_r_id = type("f8"), updt_id = type("f8"),
   updt_dt_tm = type("dq8"), updt_cnt = type("i4"), updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(attr_id), owner = value(stableowner), index(attr_name_id),
    index(attr_name), index(attr_value_id), index(attr_value),
    index(updt_dt_tm), index(cust_concept_person_r_id), synonym = "CUST_CONCEPT_PRSN_R_ATTR",
    organization = p
  ;end select
  DROP TABLE cust_concept_prsn_r_attr
  EXECUTE oragen3 "V500_BHS.CUST_CONCEPT_PRSN_R_ATTR"
  IF (checkdic(stablename,"T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus[lstatuscnt].operationname = "Create Table"
   SET record_data->status_data.subeventstatus[lstatuscnt].operationstatus = "S"
   SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectname = stablename
   SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectvalue = build2("Table ",
    stablename," created successfully.")
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus[lstatuscnt].operationname = "Create Table"
   SET record_data->status_data.subeventstatus[lstatuscnt].operationstatus = "F"
   SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectname = stablename
   SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectvalue = build2(
    "Error creating ",stablename,".")
  ENDIF
 ELSE
  SET record_data->status_data.subeventstatus[lstatuscnt].operationname = "Create Table"
  SET record_data->status_data.subeventstatus[lstatuscnt].operationstatus = "Z"
  SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectname = stablename
  SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectvalue = "Table already exists."
  EXECUTE uhs_lib_schema
  EXECUTE uhs_lib_status_block
  SET bneedssynonym = evaluate(findtablesynonym(stablename,stableowner),0,1,1,0)
  IF (bneedssynonym=1)
   SET sjson = build2('{"TABLE_NAME":"',stablename,'"',',"TABLE_OWNER":"',stableowner,
    '"}')
   SET ssynonymstatus = createtablesynonym(sjson)
  ENDIF
  IF (bneedssynonym=1)
   EXECUTE oragen3 "V500_BHS.CUST_CONCEPT_PRSN_R_ATTR"
   SET bhassynonym = findtablesynonym(stablename,stableowner)
   SET ssynonymstatus = build2("Synonym ",stablename)
   IF (bhassynonym=1)
    SET ssynonymstatus = build2(ssynonymstatus," was successfully added for owner ",stableowner,".")
    SET stat = addtostatusblock("Add Synonym","S",stablename,ssynonymstatus,record_data)
    SET record_data->status_data.status = "S"
   ELSE
    SET ssynonymstatus = build2(ssynonymstatus," was not added for owner ",stableowner,".")
    SET stat = addtostatusblock("Add Synonym","F",stablename,ssynonymstatus,record_data)
    SET record_data->status_data.status = "F"
   ENDIF
  ENDIF
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
 CALL echorecord(record_data)
END GO

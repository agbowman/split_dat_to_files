CREATE PROGRAM cust_concept_attr
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
 DECLARE stablename = vc WITH protect, constant("CUST_CONCEPT_ATTR")
 DECLARE sdefaultmessage = vc WITH protect, constant(build2("No changes are necessary to ",trim(
    stablename),"."))
 DECLARE stableowner = vc WITH protect, noconstant("V500_BHS")
 DECLARE sjson = vc WITH protect, noconstant(" ")
 DECLARE ssynonymstatus = vc WITH protect, noconstant(" ")
 DECLARE scolumnstatus = vc WITH protect, noconstant(" ")
 DECLARE scolumnsexisting = vc WITH protect, noconstant(" ")
 DECLARE scolumnsadded = vc WITH protect, noconstant(" ")
 DECLARE scolumnsnotadded = vc WITH protect, noconstant(" ")
 DECLARE bneedssynonym = i4 WITH protect, noconstant(0)
 DECLARE bmissingcolumn = i4 WITH protect, noconstant(0)
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
  SELECT INTO TABLE cust_concept_attr
   cust_concept_attr_id = type("f8"), cust_concept_id = type("f8"), json = type("vc32000"),
   beg_effective_dt_tm = type("dq8"), end_effective_dt_tm = type("dq8"), updt_id = type("f8"),
   updt_dt_tm = type("dq8"), updt_cnt = type("i4"), updt_applctx = type("f8")
   WITH indexunique(cust_concept_attr_id), owner = value(stableowner), index(cust_concept_id),
    index(updt_dt_tm), synonym = "CUST_CONCEPT_ATTR", organization = p
  ;end select
  DROP TABLE cust_concept_attr
  EXECUTE oragen3 "V500_BHS.CUST_CONCEPT_ATTR"
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
  SET bneedssynonym = findtablesynonym(stablename,stableowner)
  IF (bneedssynonym=1)
   SET sjson = build2('{"TABLE_NAME":"',stablename,'"',',"TABLE_OWNER":"',stableowner,
    '"}')
   SET ssynonymstatus = createtablesynonym(sjson)
  ENDIF
  IF (1 IN (bneedssynonym, bmissingcolumn))
   DROP TABLE cust_concept_attr
   EXECUTE oragen3 stablename
   IF (bneedssynonym=1)
    SET bneedssynonym = findtablesynonym(stablename,stableowner)
    SET ssynonymstatus = build2("Synonym ",stablename," was not added for owner ",stableowner,".")
    IF (bneedssynonym=1)
     SET stat = addtostatusblock("Add Synonym","F",stablename,ssynonymstatus,record_data)
    ELSE
     SET stat = addtostatusblock("Add Synonym","Z",stablename,ssynonymstatus,record_data)
     SET bneedssynonym = 0
    ENDIF
   ENDIF
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2("The following columns already exist: ",scolumnsexisting,".")
    SET stat = addtostatusblock("Existing Columns","S",stablename,scolumnsexisting,record_data)
   ENDIF
   IF (size(trim(scolumnsadded,3)) > 0)
    SET scolumnsadded = build2("The following columns were added: ",scolumnsadded,".")
    SET stat = addtostatusblock("Add Columns","S",stablename,scolumnsadded,record_data)
   ENDIF
   IF (size(trim(scolumnsnotadded,3)) > 0)
    SET scolumnsnotadded = build2("The following columns were NOT added: ",scolumnsnotadded,".")
    SET stat = addtostatusblock("Columns Not Added","S",stablename,scolumnsnotadded,record_data)
   ENDIF
   IF (1 IN (bneedssynonym, bmissingcolumn))
    SET record_data->status_data.status = "F"
   ELSE
    SET record_data->status_data.status = "S"
   ENDIF
  ELSE
   SET record_data->status_data.status = "Z"
   SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectname = stablename
   SET record_data->status_data.subeventstatus[lstatuscnt].targetobjectvalue = sdefaultmessage
  ENDIF
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
 CALL echorecord(record_data)
END GO

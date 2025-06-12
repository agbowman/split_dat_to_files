CREATE PROGRAM cust_concept
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
 DECLARE stablename = vc WITH protect, constant("CUST_CONCEPT")
 DECLARE sdefaultmessage = vc WITH protect, constant(build2("No changes are necessary to ",trim(
    stablename),"."))
 DECLARE stableowner = vc WITH protect, noconstant("$$CUSTTABLEOWNER$$")
 DECLARE sjson = vc WITH protect, noconstant(" ")
 DECLARE ssynonymstatus = vc WITH protect, noconstant(" ")
 DECLARE scolumnstatus = vc WITH protect, noconstant(" ")
 DECLARE scolumnsexisting = vc WITH protect, noconstant(" ")
 DECLARE scolumnsadded = vc WITH protect, noconstant(" ")
 DECLARE scolumnsnotadded = vc WITH protect, noconstant(" ")
 DECLARE bhassynonym = i4 WITH protect, noconstant(0)
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
  SELECT INTO TABLE cust_concept
   cust_concept_id = type("f8"), concept_name = type("vc"), concept_name_key = type("vc"),
   concept_desc = type("vc32000"), concept_type_flag = type("i2"), concept_reltn = type("vc2000"),
   expire_lookahead = type("vc"), expire_on_discharge = type("i2"), multiple_entry_ind = type("i2"),
   active_ind = type("i2"), beg_effective_dt_tm = type("dq8"), end_effective_dt_tm = type("dq8"),
   parent_entity = type("vc100"), parent_entity_id = type("f8"), parent_status = type("vc1000"),
   updt_id = type("f8"), updt_dt_tm = type("dq8"), updt_cnt = type("i4"),
   updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_concept_id), owner = value(stableowner), indexunique(concept_name_key),
    index(concept_type_flag), index(updt_dt_tm), index(cust_concept_id,end_effective_dt_tm,
     beg_effective_dt_tm),
    index(cust_concept_id,active_ind), index(parent_entity,parent_entity_id,parent_status_cd),
    synonym = "CUST_CONCEPT",
    organization = p
  ;end select
  DROP TABLE cust_concept
  EXECUTE oragen3 "V500_BHS.CUST_CONCEPT"
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
  IF (checkdic("CUST_CONCEPT.ACTIVE_IND","A",0)=0)
   SET bmissingcolumn = 1
   RDB alter table cust_concept add active_ind number ( 1 )
   END ;Rdb
  ELSE
   SET scolumnsexisting = "ACTIVE_IND"
  ENDIF
  IF (checkdic("CUST_CONCEPT.BEG_EFFECTIVE_DT_TM","A",0)=0)
   SET bmissingcolumn = 1
   RDB alter table cust_concept add beg_effective_dt_tm date
   END ;Rdb
  ELSE
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2(scolumnsexisting,", BEG_EFFECTIVE_DT_TM")
   ELSE
    SET scolumnsexisting = "BEG_EFFECTIVE_DT_TM"
   ENDIF
  ENDIF
  IF (checkdic("CUST_CONCEPT.END_EFFECTIVE_DT_TM","A",0)=0)
   SET bmissingcolumn = 1
   RDB alter table cust_concept add end_effective_dt_tm date
   END ;Rdb
  ELSE
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2(scolumnsexisting,", END_EFFECTIVE_DT_TM")
   ELSE
    SET scolumnsexisting = "END_EFFECTIVE_DT_TM"
   ENDIF
  ENDIF
  IF (checkdic("CUST_CONCEPT.PARENT_ENTITY","A",0)=0)
   SET bmissingcolumn = 1
   RDB alter table cust_concept add parent_entity varchar2 ( 100 )
   END ;Rdb
  ELSE
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2(scolumnsexisting,", PARENT_ENTITY")
   ELSE
    SET scolumnsexisting = "PARENT_ENTITY"
   ENDIF
  ENDIF
  IF (checkdic("CUST_CONCEPT.PARENT_ENTITY_ID","A",0)=0)
   SET bmissingcolumn = 1
   RDB alter table cust_concept add parent_entity_id number
   END ;Rdb
  ELSE
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2(scolumnsexisting,", PARENT_ENTITY_ID")
   ELSE
    SET scolumnsexisting = "PARENT_ENTITY_ID"
   ENDIF
  ENDIF
  IF (checkdic("CUST_CONCEPT.PARENT_STATUS","A",0)=0)
   SET bmissingcolumn = 1
   RDB alter table cust_concept add parent_status varchar2 ( 1000 )
   END ;Rdb
  ELSE
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2(scolumnsexisting,", PARENT_STATUS")
   ELSE
    SET scolumnsexisting = "PARENT_STATUS"
   ENDIF
  ENDIF
  IF (checkdic("CUST_CONCEPT.PARENT_STATUS_CD","A",0)=1)
   RDB alter table cust_concept drop column parent_status_cd
   END ;Rdb
   SET bmissingcolumn = 1
  ENDIF
  IF (1 IN (bneedssynonym, bmissingcolumn))
   DROP TABLE cust_concept
   EXECUTE oragen3 "V500_BHS.CUST_CONCEPT"
   IF (bneedssynonym=1)
    SET bhassynonym = findtablesynonym(stablename,stableowner)
    SET ssynonymstatus = build2("Synonym ",stablename)
    IF (bhassynonym=1)
     SET ssynonymstatus = build2(ssynonymstatus," was successfully added for owner ",stableowner,".")
     SET stat = addtostatusblock("Add Synonym","S",stablename,ssynonymstatus,record_data)
     SET bneedssynonym = 0
    ELSE
     SET ssynonymstatus = build2(ssynonymstatus," was not added for owner ",stableowner,".")
     SET stat = addtostatusblock("Add Synonym","F",stablename,ssynonymstatus,record_data)
    ENDIF
   ENDIF
   IF (bmissingcolumn=1)
    IF (checkdic("CUST_CONCEPT.ACTIVE_IND","A",0)=2)
     SET scolumnsadded = "ACTIVE_IND"
     SET bmissingcolumn = 0
    ELSE
     SET scolumnsnotadded = "ACTIVE_IND"
     SET bmissingcolumn = 1
    ENDIF
    IF (checkdic("CUST_CONCEPT.BEG_EFFECTIVE_DT_TM","A",0)=2)
     IF (size(trim(scolumnsadded,3)) > 0)
      SET scolumnsadded = build2(scolumnsadded,", BEG_EFFECTIVE_DT_TM")
     ELSE
      SET scolumnsadded = "BEG_EFFECTIVE_DT_TM"
     ENDIF
     SET bmissingcolumn = 0
    ELSE
     IF (size(trim(scolumnsnotadded,3)) > 0)
      SET scolumnsnotadded = build2(scolumnsnotadded,", BEG_EFFECTIVE_DT_TM")
     ELSE
      SET scolumnsnotadded = "BEG_EFFECTIVE_DT_TM"
     ENDIF
     SET bmissingcolumn = 1
    ENDIF
    IF (checkdic("CUST_CONCEPT.END_EFFECTIVE_DT_TM","A",0)=2)
     IF (size(trim(scolumnsadded,3)) > 0)
      SET scolumnsadded = build2(scolumnsadded,", END_EFFECTIVE_DT_TM")
     ELSE
      SET scolumnsadded = "END_EFFECTIVE_DT_TM"
     ENDIF
     SET bmissingcolumn = 0
    ELSE
     IF (size(trim(scolumnsnotadded,3)) > 0)
      SET scolumnsnotadded = build2(scolumnsnotadded,", END_EFFECTIVE_DT_TM")
     ELSE
      SET scolumnsnotadded = "END_EFFECTIVE_DT_TM"
     ENDIF
     SET bmissingcolumn = 1
    ENDIF
    IF (checkdic("CUST_CONCEPT.PARENT_ENTITY","A",0)=2)
     IF (size(trim(scolumnsadded,3)) > 0)
      SET scolumnsadded = build2(scolumnsadded,", PARENT_ENTITY")
     ELSE
      SET scolumnsadded = "PARENT_ENTITY"
     ENDIF
     SET bmissingcolumn = 0
    ELSE
     IF (size(trim(scolumnsnotadded,3)) > 0)
      SET scolumnsnotadded = build2(scolumnsnotadded,", PARENT_ENTITY")
     ELSE
      SET scolumnsnotadded = "PARENT_ENTITY"
     ENDIF
     SET bmissingcolumn = 1
    ENDIF
    IF (checkdic("CUST_CONCEPT.PARENT_ENTITY_ID","A",0)=2)
     IF (size(trim(scolumnsadded,3)) > 0)
      SET scolumnsadded = build2(scolumnsadded,", PARENT_ENTITY_ID")
     ELSE
      SET scolumnsadded = "PARENT_ENTITY_ID"
     ENDIF
     SET bmissingcolumn = 0
    ELSE
     IF (size(trim(scolumnsnotadded,3)) > 0)
      SET scolumnsnotadded = build2(scolumnsnotadded,", PARENT_ENTITY_ID")
     ELSE
      SET scolumnsnotadded = "PARENT_ENTITY_ID"
     ENDIF
     SET bmissingcolumn = 1
    ENDIF
    IF (checkdic("CUST_CONCEPT.PARENT_STATUS","A",0)=2)
     IF (size(trim(scolumnsadded,3)) > 0)
      SET scolumnsadded = build2(scolumnsadded,", PARENT_STATUS")
     ELSE
      SET scolumnsadded = "PARENT_STATUS"
     ENDIF
     SET bmissingcolumn = 0
    ELSE
     IF (size(trim(scolumnsnotadded,3)) > 0)
      SET scolumnsnotadded = build2(scolumnsnotadded,", PARENT_STATUS")
     ELSE
      SET scolumnsnotadded = "PARENT_STATUS"
     ENDIF
     SET bmissingcolumn = 1
    ENDIF
   ENDIF
   IF (size(trim(scolumnsexisting,3)) > 0)
    SET scolumnsexisting = build2("The following columns already exist: ",scolumnsexisting,".")
    SET stat = addtostatusblock("Existing Columns","Z",stablename,scolumnsexisting,record_data)
   ENDIF
   IF (size(trim(scolumnsadded,3)) > 0)
    SET scolumnsadded = build2("The following columns were added: ",scolumnsadded,".")
    SET stat = addtostatusblock("Add Columns","S",stablename,scolumnsadded,record_data)
   ENDIF
   IF (size(trim(scolumnsnotadded,3)) > 0)
    SET scolumnsnotadded = build2("The following columns were NOT added: ",scolumnsnotadded,".")
    SET stat = addtostatusblock("Columns Not Added","F",stablename,scolumnsnotadded,record_data)
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

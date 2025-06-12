CREATE PROGRAM cust_concept_atomic_future
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
 IF (checkdic("CUST_CONCEPT_ATOMIC_FUTURE","T",0)=0)
  SELECT INTO TABLE cust_concept_atomic_future
   cust_concept_person_r_id = type("f8"), cust_concept_id = type("f8"), process_flag = type("i4"),
   beg_effective_dt_tm = type("dq8"), end_effective_dt_tm = type("dq8"), updt_id = type("f8"),
   updt_dt_tm = type("dq8"), updt_cnt = type("i4"), updt_task = type("i4"),
   updt_applctx = type("f8")
   FROM dummyt d1
   WITH indexunique(cust_concept_person_r_id), indexunique(cust_concept_person_r_id,cust_concept_id),
    index(cust_concept_id,end_effective_dt_tm),
    index(beg_effective_dt_tm,end_effective_dt_tm), index(beg_effective_dt_tm,end_effective_dt_tm,
     process_flag), owner = value(stableowner),
    synonym = "CUST_CONCEPT_ATOMIC_FUTURE", organization = p
  ;end select
  DROP TABLE cust_concept_atomic_future
  EXECUTE oragen3 "V500_BHS.CUST_CONCEPT_ATOMIC_FUTURE"
  IF (checkdic("CUST_CONCEPT_ATOMIC_FUTURE","T",0)=2)
   SET record_data->status_data.status = "S"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Table cust_concept_atomic_future created successfully"
  ELSE
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus.targetobjectvalue =
   "Error creating cust_concept_atomic_future"
  ENDIF
 ELSE
  SET record_data->status_data.status = "S"
  SET record_data->status_data.subeventstatus.targetobjectvalue =
  "No changes are necessary to cust_concept_atomic_future"
 ENDIF
 SET _memory_reply_string = cnvtrectojson(record_data)
 CALL echorecord(record_data)
END GO

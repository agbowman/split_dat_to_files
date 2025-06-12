CREATE PROGRAM cernadminadtfailover
 RECORD reply(
   1 status = vc
   1 movementid = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->movementid = "0"
 SET errmsg = fillstring(132," ")
 SET errorcode = error(errmsg,1)
 SET vtransaction_id = format(request->transaction_id,";;")
 SET sizeval = size(vtransaction_id,1)
 IF (sizeval=0)
  SET vtransaction_id = "null"
 ENDIF
 SET vperson_id = format(request->person_id,";;")
 SET sizeval = size(vperson_id,1)
 IF (sizeval=0)
  SET vperson_id = "null"
 ENDIF
 SET vencntr_id = format(request->encntr_id,";;")
 SET sizeval = size(vencntr_id,1)
 IF (sizeval=0)
  SET vencntr_id = "null"
 ENDIF
 SET vreason = format(request->reason,";;")
 SET sizeval = size(vreason,1)
 IF (sizeval=0)
  SET vreason = "null"
 ENDIF
 SET vhl7task = format(request->hl7task,";;")
 SET sizeval = size(vhl7task,1)
 IF (sizeval=0)
  SET vhl7task = "null"
 ENDIF
 SET vtransaction = format(request->transaction,";;")
 SET sizeval = size(vtransaction,1)
 IF (sizeval=0)
  SET vtransaction = "null"
 ENDIF
 SET vpm_hist_tracking_id = format(request->pm_hist_tracking_id,";;")
 SET sizeval = size(vpm_hist_tracking_id,1)
 IF (sizeval=0)
  SET vpm_hist_tracking_id = "null"
 ENDIF
 SET vtransaction_dt_tm = format(request->transaction_dt_tm,";;Q")
 SET sizeval = size(vtransaction_dt_tm,1)
 IF (sizeval=0)
  SET sqldatepart = "null"
 ELSE
  SET vtransaction_dt_tm = substring(1,20,vtransaction_dt_tm)
  SET sqldatepart = concat("TO_DATE('",vtransaction_dt_tm,"','DD-MM-YYYY HH24:MI:SS' )")
 ENDIF
 SET fra_query = concat(
  " insert into fra.request_4600000 (transaction_id, n_encntr_id, n_person_id ,",
  "reason, hl7task, transaction, pm_hist_tracking_id, transaction_dt_tm )"," values (",
  vtransaction_id,",",
  vencntr_id,",",vperson_id,",'",vreason,
  "','",vhl7task,"','",vtransaction,"',",
  vpm_hist_tracking_id,",",sqldatepart," )")
 CALL parser(concat("rdb asis (^",fra_query,"^) go"))
 SET errorcode = error(errmsg,1)
 IF (errorcode != 0)
  SET reply->status = "F"
 ELSE
  SET reply->status = "S"
  COMMIT
 ENDIF
END GO

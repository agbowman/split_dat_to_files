CREATE PROGRAM bed_get_br_fsi:dba
 FREE SET reply
 RECORD reply(
   1 fsi_list[*]
     2 fsi_id = f8
     2 fsi_type = vc
     2 fsi_name = vc
     2 active_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 DECLARE error_msg = vc
 DECLARE error_flag = vc
 DECLARE max_cnt = i4
 DECLARE fsicnt = i4
 SET tcnt = 0
 DECLARE loadparse = vc
 DECLARE loadcnt = i2
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET error_flag = "F"
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 1000000
 ENDIF
 IF ((request->load.adt_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.order_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.transcription_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.result_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.charge_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.document_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.dictation_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.rli_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.schedule_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.phys_mfn_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.problem_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.allergy_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.immun_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.claims_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.supply_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF ((request->load.misc_type_ind=1))
  SET loadcnt = (loadcnt+ 1)
 ENDIF
 IF (loadcnt=0)
  SET error_flag = "T"
  SET error_msg = "No load indicators specified"
  GO TO exit_script
 ENDIF
 SET loadparse = "b.fsi_id > 0 and ("
 IF ((request->load.adt_ind=1))
  SET loadparse = concat(loadparse," b.adt_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.order_ind=1))
  SET loadparse = concat(loadparse," b.order_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.transcription_ind=1))
  SET loadparse = concat(loadparse," b.transcription_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.result_ind=1))
  SET loadparse = concat(loadparse," b.result_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.charge_ind=1))
  SET loadparse = concat(loadparse," b.charge_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.document_ind=1))
  SET loadparse = concat(loadparse," b.document_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.dictation_ind=1))
  SET loadparse = concat(loadparse," b.dictation_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.rli_ind=1))
  SET loadparse = concat(loadparse," b.rli_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.schedule_ind=1))
  SET loadparse = concat(loadparse," b.schedule_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.phys_mfn_ind=1))
  SET loadparse = concat(loadparse," b.phys_mfn_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.problem_ind=1))
  SET loadparse = concat(loadparse," b.problem_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.allergy_ind=1))
  SET loadparse = concat(loadparse," b.allergy_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.immun_ind=1))
  SET loadparse = concat(loadparse," b.immun_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.claims_ind=1))
  SET loadparse = concat(loadparse," b.claims_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.supply_ind=1))
  SET loadparse = concat(loadparse," b.supply_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->load.misc_type_ind=1))
  SET loadparse = concat(loadparse," b.misc_type_ind = 1")
  SET loadcnt = (loadcnt - 1)
  IF (loadcnt > 0)
   SET loadparse = concat(loadparse," or")
  ELSE
   SET loadparse = concat(loadparse,")")
  ENDIF
 ENDIF
 IF ((request->inc_inactive_ind=0))
  SET loadparse = concat(loadparse," and b.active_ind = 1")
 ENDIF
 CALL echo(build("loadparse: ",loadparse))
 SELECT DISTINCT INTO "nl:"
  FROM br_fsi b
  PLAN (b
   WHERE parser(loadparse))
  ORDER BY b.fsi_supplier_name, b.fsi_system_name
  HEAD REPORT
   fsicnt = 0, tcnt = 0, stat = alterlist(reply->fsi_list,10)
  DETAIL
   fsicnt = (fsicnt+ 1), tcnt = (tcnt+ 1)
   IF (tcnt > 10)
    tcnt = 1, stat = alterlist(reply->fsi_list,(fsicnt+ 10))
   ENDIF
   reply->fsi_list[fsicnt].fsi_id = b.fsi_id, reply->fsi_list[fsicnt].fsi_name = concat(trim(b
     .fsi_supplier_name),":",trim(b.fsi_system_name)), reply->fsi_list[fsicnt].active_ind = b
   .active_ind
   IF ((request->load.adt_ind=1)
    AND b.adt_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type,"ADT "))
   ENDIF
   IF ((request->load.order_ind=1)
    AND b.order_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," ORDER"))
   ENDIF
   IF ((request->load.transcription_ind=1)
    AND b.transcription_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," TRANSCRIPTION "
      ))
   ENDIF
   IF ((request->load.result_ind=1)
    AND b.result_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," RESULT "))
   ENDIF
   IF ((request->load.document_ind=1)
    AND b.document_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," DOCUMENT "))
   ENDIF
   IF ((request->load.dictation_ind=1)
    AND b.dictation_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," DICTATION "))
   ENDIF
   IF ((request->load.rli_ind=1)
    AND b.rli_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," RLI "))
   ENDIF
   IF ((request->load.schedule_ind=1)
    AND b.schedule_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," SCHEDULE "))
   ENDIF
   IF ((request->load.phys_mfn_ind=1)
    AND b.phys_mfn_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," MFN "))
   ENDIF
   IF ((request->load.problem_ind=1)
    AND b.problem_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," PROBLEM "))
   ENDIF
   IF ((request->load.allergy_ind=1)
    AND b.allergy_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," ALLERGY "))
   ENDIF
   IF ((request->load.immun_ind=1)
    AND b.immun_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," IMMUN "))
   ENDIF
   IF ((request->load.claims_ind=1)
    AND b.claims_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," CLAIMS "))
   ENDIF
   IF ((request->load.supply_ind=1)
    AND b.supply_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," SUPPLY "))
   ENDIF
   IF ((request->load.misc_type_ind=1)
    AND b.misc_type_ind=1)
    reply->fsi_list[fsicnt].fsi_type = trim(concat(reply->fsi_list[fsicnt].fsi_type," ",b
      .misc_type_desc," "))
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->fsi_list,fsicnt)
  WITH maxqual(b,value((max_cnt+ 2))), nocounter
 ;end select
 IF (fsicnt > max_cnt)
  SET stat = alterlist(reply->fsi_list,max_cnt)
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_GET_BR_FSI   ERROR MESSAGE: ",error_msg)
 ELSE
  IF (fsicnt > 0)
   IF (fsicnt > max_cnt)
    SET stat = alterlist(reply->fsi_list,0)
    SET reply->too_many_results_ind = 1
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echo(build("fsicnt = ",fsicnt))
 CALL echo(build("max_cnt = ",max_cnt))
 CALL echorecord(reply)
END GO

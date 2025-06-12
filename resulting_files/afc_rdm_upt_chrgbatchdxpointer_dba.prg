CREATE PROGRAM afc_rdm_upt_chrgbatchdxpointer:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme afc_rdm_upt_chrgbatchdxpointer failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE run_status = i4
 DECLARE min_id = f8
 DECLARE max_id = f8
 DECLARE batch_start = f8
 DECLARE batch_end = f8
 DECLARE checkrunstatus() = i4
 DECLARE getminmaxids() = null
 DECLARE formatandupdatedxpointer(b_start=f8,b_end=f8) = null
 SET run_status = checkrunstatus(null)
 IF (run_status=1)
  SET readme_data->status = "S"
  SET readme_data->message = "DIAGNOSIS_POINTER_TXT and DIAGNOSIS_POINTER_TXT already updated"
  GO TO end_program
 ELSE
  CALL getminmaxids(null)
 ENDIF
 SET batch_start = min_id
 SET batch_end = (min_id+ 10000)
 WHILE (batch_start <= max_id)
   CALL echo(build("minID : ",batch_start))
   CALL echo(build("maxID : ",batch_end))
   CALL formatandupdatedxpointer(batch_start,batch_end)
   SET batch_start = (batch_start+ 10000)
   SET batch_end = (batch_end+ 10000)
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: Readme updated DIAGNOSIS_POINTER_TXT and  DIAGNOSIS_POINTER_TXT on CHARGE_BATCH_DETAIL."
 SUBROUTINE checkrunstatus(null)
   SELECT INTO "nl:"
    FROM charge_batch_detail cb
    WHERE cb.charge_batch_detail_id > 0.0
     AND cb.diagnosis_pointer_nbr > 0
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = build("Failed while executing checkRunStatus():",errmsg)
    GO TO end_program
   ENDIF
   IF (curqual > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE getminmaxids(null)
   SELECT INTO "nl:"
    minidval = min(cb.charge_batch_detail_id)
    FROM charge_batch_detail cb
    WHERE cb.charge_batch_detail_id > 0.0
     AND cb.diagnosis_pointer_nbr > 0
    DETAIL
     min_id = maxval(minidval,1.0)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->status = concat("Failed to get minimum ID: ",errmsg)
    GO TO end_program
   ENDIF
   SELECT INTO "nl:"
    maxidval = max(cb.charge_batch_detail_id)
    FROM charge_batch_detail cb
    WHERE cb.charge_batch_detail_id > 0.0
     AND cb.diagnosis_pointer_nbr > 0
    DETAIL
     max_id = maxidval
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->status = concat("Failed to get maximum ID: ",errmsg)
    GO TO end_program
   ENDIF
 END ;Subroutine
 SUBROUTINE formatandupdatedxpointer(b_start,b_end)
   DECLARE icnt = i4
   FREE RECORD tempreq
   RECORD tempreq(
     1 objarray[*]
       2 chargedetailid = f8
       2 newdxpointertxt = vc
   )
   SELECT INTO "nl:"
    FROM charge_batch_detail cb
    WHERE cb.charge_batch_detail_id >= b_start
     AND cb.charge_batch_detail_id <= b_end
    HEAD REPORT
     icnt = 0
    DETAIL
     icnt = (icnt+ 1)
     IF (mod(icnt,50)=1)
      stat = alterlist(tempreq->objarray,(icnt+ 49))
     ENDIF
     tempreq->objarray[icnt].chargedetailid = cb.charge_batch_detail_id, tempreq->objarray[icnt].
     newdxpointertxt = evaluate(size(trim(cnvtstring(cb.diagnosis_pointer_nbr),1),3),1,cnvtstring(cb
       .diagnosis_pointer_nbr),2,format(cnvtstring(cb.diagnosis_pointer_nbr),"#.#"),
      3,format(cnvtstring(cb.diagnosis_pointer_nbr),"#.#.#"),4,format(cnvtstring(cb
        .diagnosis_pointer_nbr),"#.#.#.#"),5,
      format(cnvtstring(cb.diagnosis_pointer_nbr),"#.#.#.#.#"),6,format(cnvtstring(cb
        .diagnosis_pointer_nbr),"#.#.#.#.#.#"),7,format(cnvtstring(cb.diagnosis_pointer_nbr),
       "#.#.#.#.#.#.#"),
      8,format(cnvtstring(cb.diagnosis_pointer_nbr),"#.#.#.#.#.#.#.#"))
    FOOT REPORT
     stat = alterlist(tempreq->objarray,icnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->status = concat("Failed to format existing data:",errmsg)
    GO TO end_program
   ENDIF
   IF (size(tempreq->objarray,5) > 0)
    UPDATE  FROM charge_batch_detail cb,
      (dummyt dt  WITH seq = value(size(tempreq->objarray,5)))
     SET cb.diagnosis_pointer_txt = tempreq->objarray[dt.seq].newdxpointertxt, cb
      .diagnosis_pointer_nbr = 0, cb.updt_applctx = reqinfo->updt_applctx,
      cb.updt_cnt = (cb.updt_cnt+ 1), cb.updt_dt_tm = cnvtdatetime(curdate,curtime3), cb.updt_id =
      reqinfo->updt_id,
      cb.updt_task = reqinfo->updt_task
     PLAN (dt)
      JOIN (cb
      WHERE (cb.charge_batch_detail_id=tempreq->objarray[dt.seq].chargedetailid))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->status = concat(
      "Failed updating DIAGNOSIS_POINTER_TXT and DIAGNOSIS_POINTER_TXT",errmsg)
     ROLLBACK
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
    FREE RECORD tempreq
   ENDIF
 END ;Subroutine
#end_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

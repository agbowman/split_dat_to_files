CREATE PROGRAM do_not_use:dba
 SET start_time = curtime3
 SET last_mod = "000"
 SET sprogram = "rxa_upd_serv_res_ext"
 SET bdebug = 1
 CALL echo("==============================================")
 CALL echo("==============================================")
 CALL echo(build("Start of <",sprogram,"> MOD ",last_mod))
 SET ndate = cnvtdatetime(curdate,curtime3)
 CALL echo(build("Started script at: ",format(ndate,"mm/dd/yy  hh:mm:ss ;;q")))
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SET ncount = 0
 SET cur_cnt = 0
 SET ncount = size(request->upd_qual,5)
 SET noutofsync = 0
 IF (ncount > 0)
  SELECT INTO "nl:"
   FROM serv_res_ext_pharm sp1,
    (dummyt d1  WITH seq = value(ncount))
   PLAN (d1)
    JOIN (sp1
    WHERE (request->upd_qual[d1.seq].serv_res_cd=sp1.service_resource_cd))
   DETAIL
    IF ((request->upd_qual[d1.seq].updt_cnt != sp1.updt_cnt))
     noutofsync = 1
    ENDIF
    cur_cnt = (cur_cnt+ 1)
   WITH nocounter, forupdate(sp1)
  ;end select
  IF (((cur_cnt < ncount) OR (noutofsync=1)) )
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SERV_RES_EXT_PHARM"
   IF (noutofsync=0)
    GO TO lock_failed
   ELSE
    GO TO record_changed
   ENDIF
  ENDIF
  UPDATE  FROM serv_res_ext_pharm sp2,
    (dummyt d2  WITH seq = value(ncount))
   SET sp2.state_control_number = request->upd_qual[d2.seq].state_control_nbr, sp2.dea_number =
    request->upd_qual[d2.seq].dea_number, sp2.disp_priority_cd = request->upd_qual[d2.seq].
    disp_priority_cd,
    sp2.downtime_range_id = request->upd_qual[d2.seq].downtime_range_id, sp2.nabp_number = request->
    upd_qual[d2.seq].nabp_number, sp2.otc_sales_tax = request->upd_qual[d2.seq].otc_sales_tax,
    sp2.rxnbr_cd = request->upd_qual[d2.seq].rxnbr_cd, sp2.rx_in_charge_id = request->upd_qual[d2.seq
    ].rx_in_charge_id, sp2.sales_tax = request->upd_qual[d2.seq].sales_tax,
    sp2.state_license_number = request->upd_qual[d2.seq].state_license_number, sp2.tax_number =
    request->upd_qual[d2.seq].tax_number, sp2.track_nbr_cd = request->upd_qual[d2.seq].track_nbr_cd,
    sp2.updt_cnt = (request->upd_qual[d2.seq].updt_cnt+ 1), sp2.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), sp2.updt_id = reqinfo->updt_id,
    sp2.updt_task = reqinfo->updt_task, sp2.updt_applctx = reqinfo->updt_applctx
   PLAN (d2)
    JOIN (sp2
    WHERE (request->upd_qual[d2.seq].serv_res_cd=sp2.service_resource_cd))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SERV_RES_EXT_PHARM"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET ncount = size(request->add_qual,5)
 IF (ncount > 0)
  INSERT  FROM serv_res_ext_pharm sp2,
    (dummyt d2  WITH seq = value(ncount))
   SET sp2.state_control_number = request->add_qual[d2.seq].state_control_nbr, sp2
    .service_resource_cd = request->add_qual[d2.seq].serv_res_cd, sp2.dea_number = request->add_qual[
    d2.seq].dea_number,
    sp2.disp_priority_cd = request->add_qual[d2.seq].disp_priority_cd, sp2.downtime_range_id =
    request->add_qual[d2.seq].downtime_range_id, sp2.nabp_number = request->add_qual[d2.seq].
    nabp_number,
    sp2.otc_sales_tax = request->add_qual[d2.seq].otc_sales_tax, sp2.rxnbr_cd = request->add_qual[d2
    .seq].rxnbr_cd, sp2.rx_in_charge_id = request->add_qual[d2.seq].rx_in_charge_id,
    sp2.sales_tax = request->add_qual[d2.seq].sales_tax, sp2.state_license_number = request->
    add_qual[d2.seq].state_license_number, sp2.tax_number = request->add_qual[d2.seq].tax_number,
    sp2.track_nbr_cd = request->add_qual[d2.seq].track_nbr_cd, sp2.updt_cnt = 0, sp2.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    sp2.updt_id = reqinfo->updt_id, sp2.updt_task = reqinfo->updt_task, sp2.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d2)
    JOIN (sp2)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SERV_RES_EXT_PHARM"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#error_checking
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   SET stat = alterlist(errors->err,errcnt)
   SET errors->err_cnt = errcnt
   CALL echo(build("Error Cnt: ",errors->err_cnt))
   SET errors->err[errcnt].err_code = errcode
   CALL echo(build("Error code:",errors->err[errcnt].err_code))
   SET errors->err[errcnt].err_msg = errmsg
   CALL echo(build("Error Msg:",errors->err[errcnt].err_msg))
 ENDWHILE
 GO TO exit_script
#script_error
 CALL echo("-->Script Problem!!")
 CALL echo(concat("-->Status:         <",reply->status_data.status,">"))
 CALL echo(concat("-->Op Name:        <",reply->status_data.subeventstatus[1].operationname,">"))
 CALL echo(concat("-->Op Status:      <",reply->status_data.subeventstatus[1].operationstatus,">"))
 CALL echo(concat("-->Target Name:    <",reply->status_data.subeventstatus[1].targetobjectname,">"))
 CALL echo(concat("-->Target Value:   <",reply->status_data.subeventstatus[1].targetobjectvalue,">"))
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 GO TO exit_script
#record_changed
 SET reply->status_data.subeventstatus[1].operationname = "COMPARE UPDTCNT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 GO TO exit_script
#exit_script
 CALL echo(build("Elapsed time: ",((curtime3 - start_time)/ 100)))
 CALL echo(build("End of <",sprogram,">"))
 CALL echo("==============================================")
 CALL echo("==============================================")
 SET last_mod = "000"
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO

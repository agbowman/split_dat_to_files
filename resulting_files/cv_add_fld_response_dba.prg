CREATE PROGRAM cv_add_fld_response:dba
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 DECLARE logfile = vc WITH protect, constant("LogFile.dat")
 DECLARE cv_log_to_file(string_param=vc) = null WITH protect
 SUBROUTINE cv_log_to_file(string_param)
   SELECT INTO logfile
    FROM dual d
    DETAIL
     string_param, row + 1
    WITH append
   ;end select
 END ;Subroutine
 IF (validate(reply->status_data.status,"Z")="Z")
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
 DECLARE struct_size = i4 WITH protect, noconstant(size(request->response_rec,5))
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE xref_id = f8 WITH protect
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(request->response_rec,5)))
  PLAN (d1
   WHERE (request->response_rec[d1.seq].field_type="S"))
   JOIN (x
   WHERE x.xref_internal_name=trim(request->response_rec[d1.seq].a4))
  DETAIL
   request->response_rec[d1.seq].a4 = cnvtstring(x.xref_id)
  WITH nocounter
 ;end select
 CALL echorecord(request,"cer_Temp:cv_response_Addrequest.dat")
 INSERT  FROM cv_response resp,
   (dummyt t  WITH seq = value(size(request->response_rec,5)))
  SET resp.response_id = seq(card_vas_seq,nextval), resp.xref_id = request->response_rec[t.seq].
   xref_id, resp.field_type = request->response_rec[t.seq].field_type,
   resp.response_internal_name = request->response_rec[t.seq].response_internal_name, resp.a1 =
   request->response_rec[t.seq].a1, resp.a2 = request->response_rec[t.seq].a2,
   resp.a3 = request->response_rec[t.seq].a3, resp.a4 = request->response_rec[t.seq].a4, resp.a5 =
   request->response_rec[t.seq].a5,
   resp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), resp.beg_effective_dt_tm = cnvtdatetime
   (curdate,curtime3), resp.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"),
   resp.updt_dt_tm = cnvtdatetime(curdate,curtime3), resp.updt_task = reqinfo->updt_task, resp
   .updt_app = reqinfo->updt_app,
   resp.updt_applctx = reqinfo->updt_applctx, resp.updt_req = reqinfo->updt_req, resp.updt_cnt = 0,
   resp.updt_id = reqinfo->updt_id, resp.active_ind = 1, resp.active_status_cd = reqdata->
   active_status_cd,
   resp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), resp.data_status_prsnl_id = reqinfo->
   updt_id, resp.data_status_cd = reqdata->data_status_cd,
   resp.data_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (t
   WHERE (request->response_rec[t.seq].transaction=cv_trns_add))
   JOIN (resp)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply,"cer_Temp:cv_response_Addreply.dat")
 EXECUTE cv_updt_response_with_nomen
 DECLARE cv_add_fld_response_vrsn = vc WITH private, constant("005 BM9013 05/08/2007")
END GO

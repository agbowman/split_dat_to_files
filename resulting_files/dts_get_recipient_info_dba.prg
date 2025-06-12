CREATE PROGRAM dts_get_recipient_info:dba
 FREE RECORD reply
 RECORD reply(
   1 prsnl_info[*]
     2 event_prsnl_id = f8
     2 primary_ind = i2
     2 address_hist_id = f8
     2 address_id = f8
     2 address_type_cd = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 state_disp = c40
     2 state_mean = c12
     2 zipcode = c25
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(errors,0)))
  FREE RECORD errors
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nsuccess = i2 WITH private, constant(0)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(1)
 DECLARE request_size = i4 WITH constant(size(request->personnel_list,5))
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE iindex = i4 WITH protect, noconstant(0)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nfailed_ccl_error)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dts_recipient dr,
   address_hist ah
  PLAN (dr
   WHERE expand(iindex,1,size(request->personnel_list,5),dr.event_prsnl_id,request->personnel_list[
    iindex].event_prsnl_id))
   JOIN (ah
   WHERE dr.address_hist_id=ah.address_hist_id)
  HEAD REPORT
   icnt = 0, stat = alterlist(reply->prsnl_info,10)
  DETAIL
   icnt = (icnt+ 1)
   IF (mod(icnt,10)=0)
    stat = alterlist(reply->prsnl_info,10)
   ENDIF
   reply->prsnl_info[icnt].event_prsnl_id = dr.event_prsnl_id, reply->prsnl_info[icnt].primary_ind =
   dr.primary_ind, reply->prsnl_info[icnt].address_hist_id = ah.address_hist_id,
   reply->prsnl_info[icnt].address_id = ah.address_id, reply->prsnl_info[icnt].address_type_cd = ah
   .address_type_cd, reply->prsnl_info[icnt].city = ah.city,
   reply->prsnl_info[icnt].state_cd = ah.state_cd
   IF (ah.state_cd > 0)
    reply->prsnl_info[icnt].state = uar_get_code_display(ah.state_cd)
   ELSE
    reply->prsnl_info[icnt].state = ah.state
   ENDIF
   reply->prsnl_info[icnt].street_addr = ah.street_addr, reply->prsnl_info[icnt].street_addr2 = ah
   .street_addr2, reply->prsnl_info[icnt].street_addr3 = ah.street_addr3,
   reply->prsnl_info[icnt].street_addr4 = ah.street_addr4, reply->prsnl_info[icnt].zipcode = ah
   .zipcode
  FOOT REPORT
   stat = alterlist(reply->prsnl_info,icnt)
  WITH nocounter
 ;end select
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ELSE
  SET nscriptstatus = nsuccess
 ENDIF
 CALL echo("*************************************")
 CALL echo("***   Start of error processing   ***")
 CALL echo("*************************************")
 IF (nscriptstatus != nsuccess)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "dts_get_recipient_info"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF (size(reply->prsnl_info,5)=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Prsnl_info is not valid"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dts_get_recipient_info"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD errors
 CALL echorecord(reply)
END GO

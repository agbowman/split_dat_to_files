CREATE PROGRAM bb_get_qc_troubleshooting:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 troubleshootinglist[*]
      2 troubleshooting_id = f8
      2 troubleshooting_text_id = f8
      2 active_ind = i2
      2 updt_cnt = i4
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 long_text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM bb_qc_troubleshooting bbqct,
   long_text_reference lt
  PLAN (bbqct
   WHERE (((bbqct.troubleshooting_id=request->troubleshooting_id)
    AND (request->troubleshooting_id > 0)) OR ((request->troubleshooting_id=0)
    AND bbqct.troubleshooting_id > 0)) )
   JOIN (lt
   WHERE lt.long_text_id=bbqct.troubleshooting_text_id)
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->troubleshootinglist,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->troubleshootinglist,(count1+ 9))
   ENDIF
   reply->troubleshootinglist[count1].troubleshooting_id = bbqct.troubleshooting_id, reply->
   troubleshootinglist[count1].troubleshooting_text_id = bbqct.troubleshooting_text_id, reply->
   troubleshootinglist[count1].long_text = lt.long_text,
   reply->troubleshootinglist[count1].active_ind = bbqct.active_ind, reply->troubleshootinglist[
   count1].updt_cnt = bbqct.updt_cnt, reply->troubleshootinglist[count1].end_effective_dt_tm = bbqct
   .end_effective_dt_tm,
   reply->troubleshootinglist[count1].beg_effective_dt_tm = bbqct.beg_effective_dt_tm
  FOOT REPORT
   stat = alterlist(reply->troubleshootinglist,count1)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_get_qc_troubleshooting",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(reply->troubleshootinglist,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","bb_get_qc_troubleshooting","No troubleshooting steps found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO

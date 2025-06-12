CREATE PROGRAM aps_upd_netting:dba
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
 EXECUTE accrtl
 DECLARE oidx = i2 WITH noconstant(0), protect
#begin_script
 FOR (oidx = 1 TO ol_sze)
   IF ((req1050047->order_list[oidx].activity_type_mean="AP"))
    IF ((req1050047->order_list[oidx].processing_flag != enpf_accession)
     AND uar_accisjulian(nullterm(req1050047->order_list[oidx].accession),0)=1)
     INSERT  FROM ap_login_order_list l
      SET l.encntr_id = req1050047->order_list[oidx].encntr_id, l.accession_id = req1050047->
       order_list[oidx].accession_id, l.order_id = req1050047->order_list[oidx].order_id,
       l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_task =
       reqinfo->updt_task,
       l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL subevent_add("INSERT","F","TABLE","AP_LOGIN_ORDER_LIST")
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 COMMIT
 RETURN(1)
END GO

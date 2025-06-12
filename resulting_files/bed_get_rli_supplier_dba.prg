CREATE PROGRAM bed_get_rli_supplier:dba
 FREE SET reply
 RECORD reply(
   1 supplier_list[*]
     2 supplier_flag = i4
     2 supplier_meaning = vc
     2 supplier_name = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE suppliercnt = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 IF ((request->supplier_flag > 0))
  SELECT INTO "nl:"
   FROM br_rli_supplier brs
   PLAN (brs
    WHERE (brs.supplier_flag=request->supplier_flag)
     AND brs.default_selected_ind=1)
   DETAIL
    stat = alterlist(reply->supplier_list,1), reply->supplier_list[1].supplier_flag = brs
    .supplier_flag, reply->supplier_list[1].supplier_meaning = brs.supplier_meaning,
    reply->supplier_list[1].supplier_name = brs.supplier_name
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET error_flag = "T"
   SET error_msg = concat("Unable to read br_rli_supplier table for supplier flag"," ",cnvtstring(
     request->supplier_flag))
   GO TO exit_script
  ENDIF
 ELSEIF ((request->supplier_meaning > " "))
  SELECT INTO "nl:"
   FROM br_rli_supplier brs
   PLAN (brs
    WHERE cnvtupper(brs.supplier_meaning)=cnvtupper(request->supplier_meaning)
     AND brs.default_selected_ind=1)
   DETAIL
    stat = alterlist(reply->supplier_list,1), reply->supplier_list[1].supplier_flag = brs
    .supplier_flag, reply->supplier_list[1].supplier_meaning = brs.supplier_meaning,
    reply->supplier_list[1].supplier_name = brs.supplier_name
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET error_flag = "T"
   SET error_msg = concat("Unable to read br_rli_supplier table for supplier meaning ",request->
    supplier_meaning)
   GO TO exit_script
  ENDIF
 ELSE
  SET suppliercnt = 0
  SELECT INTO "nl:"
   FROM br_rli_supplier brs
   PLAN (brs
    WHERE brs.supplier_flag > 0
     AND brs.default_selected_ind=1)
   DETAIL
    suppliercnt = (suppliercnt+ 1), stat = alterlist(reply->supplier_list,suppliercnt), reply->
    supplier_list[suppliercnt].supplier_flag = brs.supplier_flag,
    reply->supplier_list[suppliercnt].supplier_meaning = brs.supplier_meaning, reply->supplier_list[
    suppliercnt].supplier_name = brs.supplier_name
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_RLI_SUPPLIER  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

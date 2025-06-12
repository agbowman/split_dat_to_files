CREATE PROGRAM bed_imp_rli_client_orders
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET client_order_request
 RECORD client_order_request(
   1 supplier_flag = i4
   1 order_list[*]
     2 action_flag = i4
     2 alias = vc
     2 catalog_cd = f8
     2 status_flag = i4
 )
 FREE SET client_order_reply
 RECORD client_order_reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET numrows = size(requestin->list_0,5)
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE cnvtupper(brs.supplier_meaning)=cnvtupper(trim(requestin->list_0[1].supplier)))
  DETAIL
   client_order_request->supplier_flag = brs.supplier_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Invalid supplier code: ",requestin->list_0[1].supplier,
   "  Load program terminating.")
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO numrows)
   SET stat = alterlist(client_order_request->order_list,x)
   SET client_order_request->order_list[x].action_flag = 1
   SET client_order_request->order_list[x].alias = requestin->list_0[x].alias
   SET client_order_request->order_list[x].catalog_cd = 0.0
   SET client_order_request->order_list[x].status_flag = 1
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_rli_client_orders  WITH replace("REQUEST",client_order_request), replace("REPLY",
  client_order_reply)
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_RLI_CLIENT_ORDERS","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

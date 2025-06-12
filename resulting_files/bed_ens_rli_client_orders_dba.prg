CREATE PROGRAM bed_ens_rli_client_orders:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc WITH private
 DECLARE error_msg = vc WITH private
 DECLARE numorders = i4
 DECLARE supplier_meaning = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET numorders = size(request->order_list,5)
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE (brs.supplier_flag=request->supplier_flag))
  DETAIL
   supplier_meaning = brs.supplier_meaning
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = concat(error_msg,"Invalid supplier flag.")
  SET error_flag = "T"
  GO TO exit_program
 ENDIF
 FOR (i = 1 TO numorders)
   IF ((request->order_list[i].action_flag=1))
    INSERT  FROM br_rli_client_orders b
     SET b.supplier_flag = request->supplier_flag, b.supplier_meaning = supplier_meaning, b.alias =
      trim(request->order_list[i].alias),
      b.status_flag = request->order_list[i].status_flag, b.catalog_cd = 0.0, b.active_ind = 1
     WITH nocounter
    ;end insert
   ELSEIF ((request->order_list[i].action_flag=2))
    UPDATE  FROM br_rli_client_orders b
     SET b.status_flag = request->order_list[i].status_flag, b.catalog_cd = request->order_list[i].
      catalog_cd
     WHERE (b.supplier_flag=request->supplier_flag)
      AND (b.alias=request->order_list[i].alias)
     WITH nocounter
    ;end update
   ELSEIF ((request->order_list[i].action_flag=3))
    UPDATE  FROM br_rli_client_orders b
     SET b.active_ind = 0
     WHERE (b.supplier_flag=request->supplier_flag)
      AND (b.alias=request->order_list[i].alias)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = error_msg
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

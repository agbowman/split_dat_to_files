CREATE PROGRAM bed_get_dup_oc_check:dba
 RECORD reply(
   1 code_list[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 active_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = " "
 SET reply->status_data.status = "F"
 SET code = 0
 SET i = 0
 SET jj = 0
 SET y = 0
 SET total_start = 0
 SET sze = size(request->search_list,5)
 DECLARE oc_parse = vc
 IF (sze=0)
  SET error_flag = "F"
  SET error_msg = "Request for Order Catalog search is empty."
  GO TO exit_program
 ENDIF
 FOR (y = 1 TO sze)
  SELECT INTO "nl:"
   FROM order_catalog oc
   WHERE cnvtupper(oc.primary_mnemonic)=trim(cnvtupper(request->search_list[y].display))
    AND ((oc.active_ind=1) OR ((request->load.inactive_ind=1)))
   ORDER BY oc.catalog_cd
   DETAIL
    jj = (jj+ 1), stat = alterlist(reply->code_list,jj), code = oc.catalog_cd,
    reply->code_list[jj].code_value = oc.catalog_cd, reply->code_list[jj].display = trim(oc
     .primary_mnemonic,3), reply->code_list[jj].active_ind = oc.active_ind,
    reply->code_list[jj].description = trim(oc.description,3)
   WITH nocounter
  ;end select
  SET total_start = jj
 ENDFOR
 IF (jj=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
 IF (error_flag="F")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME:  bed_get_dup_oc_check  >> ERROR MESSAGE: ",
   error_msg)
 ENDIF
 CALL echorecord(reply)
END GO

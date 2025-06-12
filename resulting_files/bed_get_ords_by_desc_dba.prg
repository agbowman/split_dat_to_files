CREATE PROGRAM bed_get_ords_by_desc:dba
 FREE SET reply
 RECORD reply(
   1 searches[*]
     2 orderables[*]
       3 code_value = f8
       3 description = c100
       3 primary_mnemonic = c100
       3 careset_ind = i2
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_txt = vc
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SET tot_cnt = size(request->searches,5)
 IF (tot_cnt > 0)
  SET stat = alterlist(reply->searches,tot_cnt)
 ENDIF
 FOR (x = 1 TO tot_cnt)
  SET parse_txt = concat("cnvtupper(oc.description) = ",'"',trim(cnvtupper(request->searches[x].
     search_string)),'"')
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE parser(parse_txt)
   HEAD REPORT
    cnt = 0, list_cnt = 0, stat = alterlist(reply->searches[x].orderables,100)
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->searches[x].orderables,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->searches[x].orderables[cnt].code_value = oc.catalog_cd, reply->searches[x].orderables[cnt]
    .description = oc.description, reply->searches[x].orderables[cnt].primary_mnemonic = oc
    .primary_mnemonic,
    reply->searches[x].orderables[cnt].active_ind = oc.active_ind
    IF (oc.orderable_type_flag IN (2, 6))
     reply->searches[x].orderables[cnt].careset_ind = 1
    ELSE
     reply->searches[x].orderables[cnt].careset_ind = 0
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->searches[x].orderables,cnt)
   WITH nocounter
  ;end select
 ENDFOR
#exit_script
 IF (tot_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

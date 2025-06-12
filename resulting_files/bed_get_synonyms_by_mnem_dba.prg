CREATE PROGRAM bed_get_synonyms_by_mnem:dba
 FREE SET reply
 RECORD reply(
   1 searches[*]
     2 synonyms[*]
       3 id = f8
       3 mnemonic = c100
       3 mnemonic_type
         4 code_value = f8
         4 display = c40
         4 mean = c12
       3 catalog_code_value = f8
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
   SELECT INTO "NL:"
    FROM order_catalog_synonym ocs,
     code_value cv
    PLAN (ocs
     WHERE ocs.mnemonic_key_cap=trim(cnvtupper(request->searches[x].search_string)))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd)
    HEAD REPORT
     cnt = 0, list_cnt = 0, stat = alterlist(reply->searches[x].synonyms,100)
    DETAIL
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->searches[x].synonyms,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->searches[x].synonyms[cnt].id = ocs.synonym_id, reply->searches[x].synonyms[cnt].mnemonic
      = ocs.mnemonic, reply->searches[x].synonyms[cnt].catalog_code_value = ocs.catalog_cd,
     reply->searches[x].synonyms[cnt].active_ind = ocs.active_ind, reply->searches[x].synonyms[cnt].
     mnemonic_type.code_value = cv.code_value, reply->searches[x].synonyms[cnt].mnemonic_type.display
      = cv.display,
     reply->searches[x].synonyms[cnt].mnemonic_type.mean = cv.cdf_meaning
    FOOT REPORT
     stat = alterlist(reply->searches[x].synonyms,cnt)
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

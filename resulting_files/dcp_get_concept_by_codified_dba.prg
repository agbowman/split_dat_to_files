CREATE PROGRAM dcp_get_concept_by_codified:dba
 RECORD reply(
   1 nomenclatures[*]
     2 concept_cki = vc
     2 nomenclature_id = f8
   1 codevalues[*]
     2 concept_cki = vc
     2 code_value_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getconceptsbynomenclatureid(null) = null
 DECLARE getconceptsbycodevalueid(null) = null
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant((loop_cnt * batch_size))
 DECLARE idx = i4 WITH noconstant(1), protected
 SET reply->status_data.status = "F"
 CALL getconceptsbynomenclatureid(null)
 CALL getconceptsbycodevalueid(null)
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE getconceptsbynomenclatureid(null)
   SET curr_list_size = size(request->nomenclatures,5)
   IF (curr_list_size=0)
    RETURN
   ENDIF
   SET loop_cnt = ceil((cnvtreal(curr_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(request->nomenclatures,new_list_size)
   FOR (idx = (curr_list_size+ 1) TO new_list_size)
     SET request->nomenclatures[idx].nomenclature_id = request->nomenclatures[curr_list_size].
     nomenclature_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     nomenclature n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (n
     WHERE expand(idx,nstart,((nstart+ batch_size) - 1),n.nomenclature_id,request->nomenclatures[idx]
      .nomenclature_id))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->nomenclatures,(cnt+ 9))
     ENDIF
     reply->nomenclatures[cnt].concept_cki = n.concept_cki, reply->nomenclatures[cnt].nomenclature_id
      = n.nomenclature_id
    FOOT REPORT
     stat = alterlist(reply->nomenclatures,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getconceptsbycodevalueid(null)
   SET curr_list_size = size(request->codevalues,5)
   IF (curr_list_size=0)
    RETURN
   ENDIF
   SET loop_cnt = ceil((cnvtreal(curr_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(request->codevalues,new_list_size)
   FOR (idx = (curr_list_size+ 1) TO new_list_size)
     SET request->codevalues[idx].code_value_id = request->codevalues[curr_list_size].code_value_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     code_value cv
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (cv
     WHERE expand(idx,nstart,((nstart+ batch_size) - 1),cv.code_value,request->codevalues[idx].
      code_value_id))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->codevalues,(cnt+ 9))
     ENDIF
     reply->codevalues[cnt].concept_cki = cv.concept_cki, reply->codevalues[cnt].code_value_id = cv
     .code_value
    FOOT REPORT
     stat = alterlist(reply->codevalues,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (size(reply->codevalues,5)=0
  AND size(reply->nomenclatures,5)=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO

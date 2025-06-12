CREATE PROGRAM bed_ens_pharm_mmdc:dba
 FREE SET temp_nomen
 RECORD temp_nomen(
   1 nomen[*]
     2 id = f8
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->products,5)
 SET mul_code_value = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=400
   AND c.cdf_meaning="MUL.MMDC"
  DETAIL
   mul_code_value = c.code_value
  WITH nocounter
 ;end select
 SET cnt = size(request->products,5)
 IF (cnt > 0)
  SET stat = alterlist(temp_nomen->nomen,cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    nomenclature n
   PLAN (d)
    JOIN (n
    WHERE (n.source_identifier=request->products[d.seq].mmdc)
     AND n.active_ind=1
     AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.source_vocabulary_cd=mul_code_value)
   ORDER BY d.seq
   DETAIL
    temp_nomen->nomen[d.seq].id = n.nomenclature_id
   WITH nocoutner
  ;end select
 ENDIF
 FOR (x = 1 TO cnt)
   UPDATE  FROM medication_definition m
    SET m.cki = concat("MUL.FRMLTN!",request->products[x].mmdc), m.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), m.updt_id = reqinfo->updt_id,
     m.updt_task = reqinfo->updt_task, m.updt_cnt = (m.updt_cnt+ 1), m.updt_applctx = reqinfo->
     updt_applctx,
     m.mdx_gfc_nomen_id = temp_nomen->nomen[x].id
    WHERE (m.item_id=request->products[x].item_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update item_id: ",trim(cnvtstring(request->products[x].
       item_id))," with mmdc: ",trim(request->products[x].mmdc)," on the medication_definition table"
     )
    GO TO exit_script
   ENDIF
   DELETE  FROM br_name_value b
    WHERE b.br_nv_key1="MLTM_MMDC_IGN"
     AND b.br_name="MEDICATION_DEFINITION"
     AND (cnvtreal(trim(b.br_value))=request->products[x].item_id)
    WITH nocounter
   ;end delete
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

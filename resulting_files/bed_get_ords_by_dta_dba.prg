CREATE PROGRAM bed_get_ords_by_dta:dba
 FREE SET reply
 RECORD reply(
   1 dtas[*]
     2 task_assay_code_value = f8
     2 orders[*]
       3 catalog_code_value = f8
       3 description = vc
       3 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->dtas,5)
 IF (req_cnt <= 0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->dtas,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->dtas[x].task_assay_code_value = request->dtas[x].task_assay_code_value
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   profile_task_r ptr,
   order_catalog oc,
   code_value cv
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.task_assay_cd=reply->dtas[d.seq].task_assay_code_value)
    AND ptr.active_ind=1
    AND ptr.catalog_cd > 0)
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=oc.catalog_cd
    AND cv.active_ind=1)
  ORDER BY d.seq, oc.catalog_cd
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->dtas[d.seq].orders,10)
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->dtas[d.seq].orders,(tcnt+ 10)), cnt = 1
   ENDIF
   reply->dtas[d.seq].orders[tcnt].catalog_code_value = oc.catalog_cd, reply->dtas[d.seq].orders[tcnt
   ].description = oc.description, reply->dtas[d.seq].orders[tcnt].primary_mnemonic = oc
   .primary_mnemonic
  FOOT  d.seq
   stat = alterlist(reply->dtas[d.seq].orders,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

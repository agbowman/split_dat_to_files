CREATE PROGRAM bed_get_mos_mltm_codeset:dba
 FREE SET reply
 RECORD reply(
   1 code_sets[*]
     2 codeset = i4
     2 values[*]
       3 mltm_display = vc
       3 mill_code = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_mean
 RECORD temp_mean(
   1 means[*]
     2 meaning = vc
 )
 FREE SET treply
 RECORD treply(
   1 values[*]
     2 mltm_display = vc
     2 mill_code = f8
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET req_size = size(request->code_sets,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->code_sets,req_size)
 FOR (x = 1 TO req_size)
   SET reply->code_sets[x].codeset = request->code_sets[x].codeset
   SET mtcnt = 0
   SET stat = initrec(temp_mean)
   SELECT INTO "nl:"
    FROM order_entry_fields oef,
     oe_field_meaning ofm
    PLAN (oef
     WHERE (oef.codeset=request->code_sets[x].codeset))
     JOIN (ofm
     WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
    ORDER BY ofm.oe_field_meaning
    HEAD REPORT
     mcnt = 0, mtcnt = 0, stat = alterlist(temp_mean->means,100)
    HEAD ofm.oe_field_meaning
     mcnt = (mcnt+ 1), mtcnt = (mtcnt+ 1)
     IF (mcnt > 100)
      stat = alterlist(temp_mean->means,(mtcnt+ 100)), mcnt = 1
     ENDIF
     temp_mean->means[mcnt].meaning = ofm.oe_field_meaning
    FOOT REPORT
     stat = alterlist(temp_mean->means,mtcnt)
    WITH nocounter
   ;end select
   IF (mtcnt > 0)
    SET stat = initrec(treply)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(mtcnt)),
      mltm_order_sent_detail m,
      br_med_ordsent_map b
     PLAN (d)
      JOIN (m
      WHERE (m.oe_field_meaning=temp_mean->means[d.seq].meaning))
      JOIN (b
      WHERE b.field_value=outerjoin(cnvtupper(m.oe_field_value))
       AND b.codeset=outerjoin(request->code_sets[x].codeset))
     ORDER BY m.oe_field_value
     HEAD REPORT
      cnt = 0, tot_cnt = 0, stat = alterlist(treply->values,100)
     HEAD m.oe_field_value
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(treply->values,(tot_cnt+ 100)), cnt = 1
      ENDIF
      treply->values[tot_cnt].mltm_display = m.oe_field_value, treply->values[tot_cnt].mill_code = b
      .parent_entity_id
     FOOT REPORT
      stat = alterlist(treply->values,tot_cnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(mtcnt)),
      br_ordsent_detail m,
      br_med_ordsent_map b
     PLAN (d)
      JOIN (m
      WHERE (m.oe_field_meaning=temp_mean->means[d.seq].meaning))
      JOIN (b
      WHERE b.field_value=outerjoin(cnvtupper(m.oe_field_value))
       AND b.codeset=outerjoin(request->code_sets[x].codeset))
     ORDER BY m.oe_field_value
     HEAD REPORT
      cnt = 0, tot_cnt = size(treply->values,5), stat = alterlist(treply->values,(tot_cnt+ 100))
     HEAD m.oe_field_value
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(treply->values,(tot_cnt+ 100)), cnt = 1
      ENDIF
      treply->values[tot_cnt].mltm_display = m.oe_field_value, treply->values[tot_cnt].mill_code = b
      .parent_entity_id
     FOOT REPORT
      stat = alterlist(treply->values,tot_cnt)
     WITH nocounter
    ;end select
    SET tsize = size(treply->values,5)
    IF (tsize > 0)
     DECLARE prev_disp = vc
     SELECT INTO "nl:"
      temp_d = cnvtupper(substring(1,255,treply->values[d.seq].mltm_display))
      FROM (dummyt d  WITH seq = value(tsize))
      PLAN (d)
      ORDER BY temp_d
      HEAD REPORT
       cnt = 0, tot_cnt = 0, stat = alterlist(reply->code_sets[x].values,100)
      DETAIL
       IF (prev_disp != cnvtupper(treply->values[d.seq].mltm_display))
        cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
        IF (cnt > 100)
         stat = alterlist(reply->code_sets[x].values,(tot_cnt+ 100)), cnt = 1
        ENDIF
        reply->code_sets[x].values[tot_cnt].mltm_display = treply->values[d.seq].mltm_display, reply
        ->code_sets[x].values[tot_cnt].mill_code = treply->values[d.seq].mill_code, prev_disp =
        cnvtupper(treply->values[d.seq].mltm_display)
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->code_sets[x].values,tot_cnt)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

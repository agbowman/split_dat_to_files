CREATE PROGRAM dcp_get_pw_order_dta:dba
 RECORD reply(
   1 catalog_cnt = i2
   1 catalog[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_desc = c60
     2 catalog_type_mean = vc
     2 activity_type_cd = f8
     2 cont_order_method_flag = i2
     2 primary_mnemonic = vc
     2 event_cd = f8
     2 ref_text_mask = i4
     2 task_cnt = i2
     2 tasks[*]
       3 task_seq = i4
       3 task_type_flag = i2
       3 prim_task_ind = i2
       3 ref_task_id = f8
       3 task_description = vc
       3 task_description_key = vc
       3 task_type_cd = f8
       3 task_type_disp = c40
       3 task_type_desc = c60
       3 task_type_mean = vc
       3 assay_cnt = i2
       3 assay[*]
         4 task_assay_cd = f8
         4 sequence = i4
         4 pend_req_ind = i2
         4 mnemonic = vc
         4 mnemonic_key = vc
         4 activity_type_cd = f8
         4 event_cd = f8
         4 desc = vc
         4 event_set_cd = f8
         4 event_set_name = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pharmacy_cd = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET temp_es_name = fillstring(40," ")
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET count1 = 0
 SET count2 = 0
 SELECT INTO "nl:"
  oc.seq
  FROM order_catalog oc
  WHERE (oc.catalog_cd=request->catalog_cd)
  ORDER BY oc.catalog_cd
  HEAD REPORT
   count1 = 0, count2 = 0
  HEAD oc.catalog_cd
   count1 = (count1+ 1)
   IF (count1 > size(reply->catalog,5))
    stat = alterlist(reply->catalog,(count1+ 20))
   ENDIF
   reply->catalog[count1].catalog_cd = oc.catalog_cd, reply->catalog[count1].catalog_type_cd = oc
   .catalog_type_cd, reply->catalog[count1].activity_type_cd = oc.activity_type_cd,
   reply->catalog[count1].cont_order_method_flag = oc.cont_order_method_flag, reply->catalog[count1].
   primary_mnemonic = oc.primary_mnemonic, reply->catalog[count1].ref_text_mask = oc.ref_text_mask
  DETAIL
   count2 = (count2+ 1)
  FOOT REPORT
   reply->catalog_cnt = count1, stat = alterlist(reply->catalog,count1)
  WITH check
 ;end select
 CALL echo("past first select")
 FOR (x = 1 TO count1)
   SET stat = alterlist(reply->catalog[x].tasks,1)
   SET reply->catalog[x].task_cnt = 1
   SET reply->catalog[x].tasks[1].task_seq = 0
   SET reply->catalog[x].tasks[1].task_type_flag = 0
   SET reply->catalog[x].tasks[1].prim_task_ind = 0
   SET reply->catalog[x].tasks[1].ref_task_id = 0
   SET reply->catalog[x].tasks[1].task_description = " "
   SET reply->catalog[x].tasks[1].task_description_key = " "
   SET reply->catalog[x].tasks[1].task_type_cd = 0
   SELECT INTO "nl:"
    otx.catalog_cd, otx.order_task_seq, ot.task_type_cd
    FROM order_task_xref otx,
     order_task ot
    PLAN (otx
     WHERE (otx.catalog_cd=reply->catalog[x].catalog_cd))
     JOIN (ot
     WHERE ot.reference_task_id=otx.reference_task_id)
    ORDER BY otx.order_task_seq
    HEAD otx.catalog_cd
     count2 = 0
    DETAIL
     count2 = (count2+ 1)
     IF (count2 > size(reply->catalog[x].tasks,5))
      stat = alterlist(reply->catalog[x].tasks,(count2+ 5))
     ENDIF
     reply->catalog[x].tasks[count2].task_seq = otx.order_task_seq, reply->catalog[x].tasks[count2].
     task_type_flag = otx.order_task_type_flag, reply->catalog[x].tasks[count2].prim_task_ind = otx
     .primary_task_ind,
     reply->catalog[x].tasks[count2].ref_task_id = otx.reference_task_id, reply->catalog[x].tasks[
     count2].task_description = ot.task_description, reply->catalog[x].tasks[count2].
     task_description_key = ot.task_description_key,
     reply->catalog[x].tasks[count2].task_type_cd = ot.task_type_cd
    FOOT  otx.catalog_cd
     reply->catalog[x].task_cnt = count2, stat = alterlist(reply->catalog[x].tasks,count2)
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO reply->catalog_cnt)
   FOR (y = 1 TO reply->catalog[x].task_cnt)
     SET reply->catalog[x].tasks[y].assay_cnt = 0
     IF ((reply->catalog[x].tasks[y].task_type_flag=0))
      SELECT INTO "nl:"
       ptr.sequence, dta.task_assay_cd
       FROM profile_task_r ptr,
        discrete_task_assay dta,
        v500_event_code e
       PLAN (ptr
        WHERE (ptr.catalog_cd=reply->catalog[x].catalog_cd)
         AND ptr.active_ind=1)
        JOIN (dta
        WHERE dta.task_assay_cd=ptr.task_assay_cd
         AND dta.active_ind=1)
        JOIN (e
        WHERE dta.event_cd=e.event_cd)
       ORDER BY ptr.sequence
       HEAD REPORT
        count3 = 0
       DETAIL
        count3 = (count3+ 1)
        IF (count3 > size(reply->catalog[x].tasks[y].assay,5))
         stat = alterlist(reply->catalog[x].tasks[y].assay,(count3+ 5))
        ENDIF
        reply->catalog[x].tasks[y].assay[count3].pend_req_ind = ptr.pending_ind, reply->catalog[x].
        tasks[y].assay[count3].sequence = ptr.sequence, reply->catalog[x].tasks[y].assay[count3].
        task_assay_cd = dta.task_assay_cd,
        reply->catalog[x].tasks[y].assay[count3].mnemonic_key = dta.mnemonic_key_cap, reply->catalog[
        x].tasks[y].assay[count3].mnemonic = dta.mnemonic, reply->catalog[x].tasks[y].assay[count3].
        activity_type_cd = dta.activity_type_cd,
        reply->catalog[x].tasks[y].assay[count3].desc = dta.description, reply->catalog[x].tasks[y].
        assay[count3].event_cd = dta.event_cd, reply->catalog[x].tasks[y].assay[count3].
        event_set_name = e.event_set_name
       FOOT REPORT
        reply->catalog[x].tasks[y].assay_cnt = count3, stat = alterlist(reply->catalog[x].tasks[y].
         assay,count3)
       WITH nocounter
      ;end select
     ENDIF
     IF ((reply->catalog[x].tasks[y].task_type_flag=1))
      SELECT INTO "nl:"
       ptr.sequence, dta.task_assay_cd
       FROM profile_task_r ptr,
        discrete_task_assay dta,
        v500_event_code e
       PLAN (ptr
        WHERE (ptr.reference_task_id=reply->catalog[x].tasks[y].ref_task_id)
         AND (ptr.catalog_cd=reply->catalog[x].catalog_cd)
         AND ptr.active_ind=1)
        JOIN (dta
        WHERE dta.task_assay_cd=ptr.task_assay_cd
         AND dta.active_ind=1)
        JOIN (e
        WHERE dta.event_cd=e.event_cd)
       ORDER BY ptr.sequence
       HEAD REPORT
        count3 = 0
       DETAIL
        count3 = (count3+ 1)
        IF (count3 > size(reply->catalog[x].tasks[y].assay,5))
         stat = alterlist(reply->catalog[x].tasks[y].assay,(count3+ 5))
        ENDIF
        reply->catalog[x].tasks[y].assay[count3].pend_req_ind = ptr.pending_ind, reply->catalog[x].
        tasks[y].assay[count3].sequence = ptr.sequence, reply->catalog[x].tasks[y].assay[count3].
        task_assay_cd = dta.task_assay_cd,
        reply->catalog[x].tasks[y].assay[count3].mnemonic_key = dta.mnemonic_key_cap, reply->catalog[
        x].tasks[y].assay[count3].mnemonic = dta.mnemonic, reply->catalog[x].tasks[y].assay[count3].
        activity_type_cd = dta.activity_type_cd,
        reply->catalog[x].tasks[y].assay[count3].desc = dta.description, reply->catalog[x].tasks[y].
        assay[count3].event_cd = dta.event_cd, reply->catalog[x].tasks[y].assay[count3].
        event_set_name = e.event_set_name
       FOOT REPORT
        reply->catalog[x].tasks[y].assay_cnt = count3, stat = alterlist(reply->catalog[x].tasks[y].
         assay,count3)
       WITH nocounter
      ;end select
     ELSE
      IF ((reply->catalog[x].tasks[y].task_type_flag=2))
       SELECT INTO "nl:"
        tdr.sequence, dta.task_assay_cd
        FROM task_discrete_r tdr,
         discrete_task_assay dta,
         v500_event_code e
        PLAN (tdr
         WHERE (tdr.reference_task_id=reply->catalog[x].tasks[y].ref_task_id)
          AND tdr.active_ind=1)
         JOIN (dta
         WHERE dta.task_assay_cd=tdr.task_assay_cd
          AND dta.active_ind=1)
         JOIN (e
         WHERE dta.event_cd=e.event_cd)
        ORDER BY tdr.sequence
        HEAD REPORT
         count3 = 0
        DETAIL
         count3 = (count3+ 1)
         IF (count3 > size(reply->catalog[x].tasks[y].assay,5))
          stat = alterlist(reply->catalog[x].tasks[y].assay,(count3+ 5))
         ENDIF
         reply->catalog[x].tasks[y].assay[count3].pend_req_ind = tdr.required_ind, reply->catalog[x].
         tasks[y].assay[count3].sequence = tdr.sequence, reply->catalog[x].tasks[y].assay[count3].
         task_assay_cd = dta.task_assay_cd,
         reply->catalog[x].tasks[y].assay[count3].mnemonic_key = dta.mnemonic_key_cap, reply->
         catalog[x].tasks[y].assay[count3].mnemonic = dta.mnemonic, reply->catalog[x].tasks[y].assay[
         count3].activity_type_cd = dta.activity_type_cd,
         reply->catalog[x].tasks[y].assay[count3].desc = dta.description, reply->catalog[x].tasks[y].
         assay[count3].event_cd = dta.event_cd, reply->catalog[x].tasks[y].assay[count3].
         event_set_name = e.event_set_name
        FOOT REPORT
         reply->catalog[x].tasks[y].assay_cnt = count3, stat = alterlist(reply->catalog[x].tasks[y].
          assay,count3)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
     FOR (z = 1 TO reply->catalog[x].tasks[y].assay_cnt)
      SET temp_es_name = cnvtupper(cnvtalphanum(reply->catalog[x].tasks[y].assay[z].event_set_name))
      SELECT INTO "nl:"
       esc.event_set_cd
       FROM v500_event_set_code esc
       WHERE esc.event_set_name_key=temp_es_name
       DETAIL
        reply->catalog[x].tasks[y].assay[z].event_set_cd = esc.event_set_cd
       WITH nocounter
      ;end select
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

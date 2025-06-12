CREATE PROGRAM cp_get_child_event_list:dba
 RECORD reply(
   1 rb_list[1]
     2 event_list[*]
       3 event_id = f8
       3 cp_entry = i2
       3 cep_entry = i2
       3 cen_entry = i2
       3 cbr_entry = i2
       3 ccr_entry = i2
       3 cbs_entry = i2
       3 csc_entry = i2
       3 child_event_list[*]
         4 event_id = f8
         4 order_id = f8
         4 clinical_event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 view_level = i4
         4 event_cd = f8
         4 event_cd_disp = vc
         4 event_class_cd = f8
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 cp_entry = i2
         4 cep_entry = i2
         4 cen_entry = i2
         4 cbr_entry = i2
         4 ccr_entry = i2
         4 cbs_entry = i2
         4 csc_entry = i2
         4 subtable_bit_map = i4
         4 result_status_cd = f8
         4 result_status_cd_disp = vc
         4 normalcy_cd = f8
         4 normalcy_cd_disp = vc
         4 result_val = vc
         4 result_units_cd = f8
         4 result_units_cd_disp = vc
         4 verified_dt_tm = dq8
         4 verified_tz = i4
         4 verified_prsnl_id = f8
         4 normal_high = vc
         4 normal_low = vc
         4 resource_cd = f8
         4 ref_lab_ind = i2
         4 ref_lab_desc = vc
         4 encntr_id = f8
         4 product[*]
           5 product_nbr = vc
           5 product_cd = f8
           5 product_status_cd = f8
           5 product_status_cd_disp = vc
         4 event_note_list[*]
           5 note_type_cd = f8
           5 note_type_cd_disp = vc
           5 note_type_cd_mean = vc
           5 note_format_cd = f8
           5 note_format_cd_disp = vc
           5 note_format_mean = vc
           5 note_dt_tm = dq8
           5 note_tz = i4
           5 blob_length = i4
           5 long_blob = gc32000
         4 event_prsnl_list[*]
           5 action_type_cd = f8
           5 action_dt_tm = dq8
           5 action_tz = i4
           5 action_type_cd_disp = vc
           5 action_prsnl_id = f8
         4 blob_result[*]
           5 format_cd = f8
           5 format_cd_disp = vc
           5 format_cd_mean = c12
           5 blob_length = i4
           5 is_compressed = i2
           5 blob[*]
             6 blob_seq_num = i4
             6 blob_contents = vc
             6 blob_contents_as_bytes = vgc
           5 storage_cd = f8
           5 storage_cd_disp = vc
           5 storage_cd_mean = c12
         4 coded_result_list[*]
           5 short_string = c60
         4 blob_summary_list[*]
           5 blob_length = i4
           5 long_blob = vgc
           5 format_cd = f8
           5 format_cd_disp = vc
           5 format_cd_mean = vc
         4 specimen_coll_list[*]
           5 collected_dt_tm = dq8
           5 collected_tz = i4
           5 received_dt_tm = dq8
           5 received_tz = i4
           5 specimen_type = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cp_entry_skip = 0
 SET cep_entry_skip = 0
 SET cen_entry_skip = 0
 SET cbr_entry_skip = 0
 SET ccr_entry_skip = 0
 SET cbs_entry_skip = 0
 SET csc_entry_skip = 0
 SET parent_cp_entry_skip = 0
 SET parent_cep_entry_skip = 0
 SET parent_cen_entry_skip = 0
 SET parent_cbr_entry_skip = 0
 SET parent_ccr_entry_skip = 0
 SET parent_cbs_entry_skip = 0
 SET parent_csc_entry_skip = 0
 SET x1 = 0
 SET x2 = 0
 SET max_event_list = 0
 DECLARE ocfcomp_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,ocfcomp_cd)
 DECLARE ascii_cd = f8
 DECLARE rtf_cd = f8
 SET stat = uar_get_meaning_by_codeset(23,"AH",1,ascii_cd)
 SET stat = uar_get_meaning_by_codeset(23,"RTF",1,rtf_cd)
 SET event_id_cnt = size(request->event_id_list,5)
 SET stat = alterlist(reply->rb_list[1].event_list,event_id_cnt)
 FOR (x1 = 1 TO event_id_cnt)
   SET reply->rb_list[1].event_list[x1].event_id = request->event_id_list[x1].event_id
 ENDFOR
 CALL echo(concat("event_id_cnt ",cnvtstring(event_id_cnt)))
 DECLARE where_clause = vc
 DECLARE date_clause = vc
 DECLARE date_clause1 = vc
 DECLARE date_clause2 = vc
 DECLARE c1 = vc
 DECLARE c2 = vc
 DECLARE c3 = vc
 DECLARE c4 = vc
 DECLARE c5 = vc
 DECLARE conwc1 = vc
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE z = i4 WITH protect, noconstant(0)
 DECLARE xmax = i4 WITH protect, noconstant(0)
 DECLARE ymax = i4 WITH protect, noconstant(0)
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 DECLARE auth_cd = f8
 DECLARE unauth_cd = f8
 DECLARE mod_cd = f8
 DECLARE alt_cd = f8
 DECLARE super_cd = f8
 DECLARE inlab_cd = f8
 DECLARE inprog_cd = f8
 DECLARE trans_cd = f8
 DECLARE del_stat_cd = f8
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE url_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"URL")), protect
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,del_stat_cd)
 SET v_until_dt = cnvtdatetime("31-Dec-2100 00:00:00.00")
 SET date_clause = " and ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
 CALL echo(concat("REQUEST->PENDING_FLAG ",cnvtstring(request->pending_flag)))
 SET c1 = " ce.parent_event_id = request->event_id_list[d1.seq].event_id "
 SET c2 = " and ce.event_id != request->event_id_list[d1.seq].event_id "
 IF ((request->pending_flag=0))
  SET c3 = " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)"
 ELSE
  IF ((request->pending_flag=1))
   SET c3 = " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
  ELSE
   SET c3 =
   " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
  ENDIF
 ENDIF
 SET c4 = "and ce.event_class_cd != placehold_class_cd and ce.record_status_cd != del_stat_cd"
 SET conwc1 = concat(trim(c1)," ",trim(c2)," ",trim(c3),
  " ",trim(c4))
 SET where_clause = concat(conwc1," ",trim(date_clause)," and ce.publish_flag = 1")
 CALL echo(where_clause)
 SELECT INTO "nl:"
  ce.clinical_event_id, ce.event_id, ce.result_val,
  ce.view_level, ce.collating_seq
  FROM (dummyt d1  WITH seq = value(event_id_cnt)),
   clinical_event ce
  PLAN (d1)
   JOIN (ce
   WHERE parser(where_clause))
  ORDER BY ce.parent_event_id, ce.collating_seq, ce.event_id,
   cnvtdatetime(ce.valid_until_dt_tm)
  HEAD d1.seq
   x1 = 0, parent_cp_entry_skip = 0, parent_cep_entry_skip = 0,
   parent_cen_entry_skip = 0, parent_cbr_entry_skip = 0, parent_ccr_entry_skip = 0,
   parent_cbs_entry_skip = 0, parent_csc_entry_skip = 0
  HEAD ce.event_id
   do_nothing = 0
  DETAIL
   do_nothing = 0
  FOOT  ce.event_id
   x1 = (x1+ 1)
   IF (x1 > max_event_list)
    max_event_list = x1
   ENDIF
   IF (mod(x1,10)=1)
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list,(x1+ 9))
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].event_id = ce.event_id, reply->rb_list[1
   ].event_list[d1.seq].child_event_list[x1].order_id = ce.order_id, reply->rb_list[1].event_list[d1
   .seq].child_event_list[x1].clinical_event_id = ce.clinical_event_id,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].valid_from_dt_tm = ce.valid_from_dt_tm,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].valid_until_dt_tm = ce.valid_until_dt_tm,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].view_level = ce.view_level,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].event_cd = ce.event_cd, reply->rb_list[1
   ].event_list[d1.seq].child_event_list[x1].event_class_cd = ce.event_class_cd, reply->rb_list[1].
   event_list[d1.seq].child_event_list[x1].event_end_dt_tm = ce.event_end_dt_tm,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].event_end_tz = validate(ce.event_end_tz,
    0), reply->rb_list[1].event_list[d1.seq].child_event_list[x1].subtable_bit_map = ce
   .subtable_bit_map, reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cp_entry = btest(ce
    .subtable_bit_map,20)
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cp_entry=1))
    cp_entry_skip = 1, parent_cp_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cep_entry = btest(ce.subtable_bit_map,0)
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cep_entry=1))
    cep_entry_skip = 1, parent_cep_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cen_entry = btest(ce.subtable_bit_map,1)
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cen_entry=1))
    cen_entry_skip = 1, parent_cen_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cbr_entry = btest(ce.subtable_bit_map,8)
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cbr_entry=1))
    cbr_entry_skip = 1, parent_cbr_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].ccr_entry = btest(ce.subtable_bit_map,15
    )
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].ccr_entry=1))
    ccr_entry_skip = 1, parent_ccr_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cbs_entry = btest(ce.subtable_bit_map,11
    )
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].cbs_entry=1))
    cbs_entry_skip = 1, parent_cbs_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].csc_entry = btest(ce.subtable_bit_map,4)
   IF ((reply->rb_list[1].event_list[d1.seq].child_event_list[x1].csc_entry=1))
    csc_entry_skip = 1, parent_csc_entry_skip = 1
   ENDIF
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].result_status_cd = ce.result_status_cd,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].normalcy_cd = ce.normalcy_cd, reply->
   rb_list[1].event_list[d1.seq].child_event_list[x1].result_val = ce.result_val,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].result_units_cd = ce.result_units_cd,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].verified_dt_tm = ce.verified_dt_tm,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].verified_tz = validate(ce.verified_tz,0),
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].verified_prsnl_id = ce.verified_prsnl_id,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].normal_high = ce.normal_high, reply->
   rb_list[1].event_list[d1.seq].child_event_list[x1].normal_low = ce.normal_low,
   reply->rb_list[1].event_list[d1.seq].child_event_list[x1].resource_cd = ce.resource_cd, reply->
   rb_list[1].event_list[d1.seq].child_event_list[x1].encntr_id = ce.encntr_id
  FOOT  d1.seq
   reply->rb_list[1].event_list[d1.seq].cp_entry = parent_cp_entry_skip, reply->rb_list[1].
   event_list[d1.seq].cep_entry = parent_cep_entry_skip, reply->rb_list[1].event_list[d1.seq].
   cen_entry = parent_cen_entry_skip,
   reply->rb_list[1].event_list[d1.seq].cbr_entry = parent_cbr_entry_skip, reply->rb_list[1].
   event_list[d1.seq].ccr_entry = parent_ccr_entry_skip, reply->rb_list[1].event_list[d1.seq].
   cbs_entry = parent_cbs_entry_skip,
   reply->rb_list[1].event_list[d1.seq].csc_entry = parent_csc_entry_skip, stat = alterlist(reply->
    rb_list[1].event_list[d1.seq].child_event_list,x1)
  WITH nocounter
 ;end select
 IF (max_event_list=0)
  GO TO exit_script
 ENDIF
 IF (cp_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = " cp.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = "  and cp.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   cp.seq, cp.product_id
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_product cp
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].cp_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)
     AND (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].cp_entry=1))
    JOIN (cp
    WHERE parser(date_clause1))
   ORDER BY d1.seq, d2.seq, cp.product_id,
    cnvtdatetime(cp.valid_until_dt_tm)
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD cp.product_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  cp.product_id
    x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].product,(x1+ 4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].product[x1].product_nbr = cp
    .product_nbr, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].product[x1].
    product_cd = cp.product_cd, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].
    product[x1].product_status_cd = cp.product_status_cd
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].product,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (cep_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "cep.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = " and cep.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   cep.seq, cep.event_prsnl_id
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_event_prsnl cep
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].cep_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)
     AND (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].cep_entry=1))
    JOIN (cep
    WHERE parser(date_clause1))
   ORDER BY d1.seq, d2.seq, cep.event_prsnl_id,
    cnvtdatetime(cep.valid_until_dt_tm)
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD cep.event_prsnl_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  cep.event_prsnl_id
    x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_prsnl_list,
      (x1+ 4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_prsnl_list[x1].action_type_cd
     = cep.action_type_cd, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].
    event_prsnl_list[x1].action_dt_tm = cep.action_dt_tm, reply->rb_list[1].event_list[d1.seq].
    child_event_list[d2.seq].event_prsnl_list[x1].action_tz = validate(cep.action_tz,0),
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_prsnl_list[x1].
    action_prsnl_id = cep.action_prsnl_id
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_prsnl_list,
     x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (cen_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "cen.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = " and cen.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   blength = textlen(lb.long_blob), cen.event_note_id, cen.compression_cd,
   lb.seq
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_event_note cen,
    long_blob lb
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].cen_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)
     AND (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].cen_entry=1))
    JOIN (cen
    WHERE parser(date_clause1)
     AND ((cen.non_chartable_flag=0) OR (cen.updt_task=csm_request_viewer_task)) )
    JOIN (lb
    WHERE lb.parent_entity_name="CE_EVENT_NOTE"
     AND lb.parent_entity_id=cen.ce_event_note_id)
   ORDER BY d1.seq, d2.seq, cen.event_note_id,
    cnvtdatetime(cen.valid_until_dt_tm)
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD cen.event_note_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  cen.event_note_id
    x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list,(
      x1+ 4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list[x1].note_type_cd =
    cen.note_type_cd, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list[
    x1].note_format_cd = cen.note_format_cd, reply->rb_list[1].event_list[d1.seq].child_event_list[d2
    .seq].event_note_list[x1].note_dt_tm = cen.note_dt_tm,
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list[x1].note_tz =
    validate(cen.note_tz,0), blob_out = fillstring(32000," ")
    IF (cen.compression_cd=ocfcomp_cd)
     blob_ret_len = 0,
     CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,32000,blob_ret_len), y1 = size(trim(
       blob_out)),
     reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list[x1].long_blob =
     blob_out, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list[x1].
     blob_length = y1
    ELSE
     y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),lb.long_blob), reply->rb_list[1].
     event_list[d1.seq].child_event_list[d2.seq].event_note_list[x1].long_blob = blob_out,
     reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list[x1].blob_length =
     (y1 - 8)
    ENDIF
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_note_list,x1
     )
   FOOT  d1.seq
    do_nothing = 0
   WITH memsort, nocounter
  ;end select
 ENDIF
 IF (cbr_entry_skip=1)
  SET date_clause1 = " "
  SET date_clause2 = " "
  SET c1 = "cbr.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = " and cbr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SET c1 = "cb.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = "and cb.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause2 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   blength = textlen(cb.blob_contents), cbr.event_id, cb.seq
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = 1),
    ce_blob_result cbr,
    ce_blob cb,
    dummyt d3
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].cbr_entry=1)
     AND maxrec(d2,size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)))
    JOIN (d2
    WHERE (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].cbr_entry=1))
    JOIN (cbr
    WHERE parser(date_clause1))
    JOIN (d3)
    JOIN (cb
    WHERE parser(date_clause2))
   ORDER BY d1.seq, d2.seq, cbr.event_id,
    cb.blob_seq_num
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD cbr.event_id
    x2 = 0, x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result,(x1+
      4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].format_cd = cbr
    .format_cd, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].
    storage_cd = cbr.storage_cd
   DETAIL
    IF (cbr.format_cd IN (rtf_cd, ascii_cd))
     x2 = (x2+ 1)
     IF (mod(x2,5)=1)
      stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].
       blob,(x2+ 4))
     ENDIF
     blob_out = fillstring(65536," ")
     IF (cb.compression_cd=ocfcomp_cd)
      reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].blob_length = cb
      .blob_length, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].
      is_compressed = 1, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1
      ].blob[x2].blob_contents_as_bytes = cb.blob_contents
     ELSE
      y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1 - 8),cb.blob_contents), reply->
      rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].blob[x2].blob_contents
       = blob_out,
      reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].blob_length = (y1
       - 8)
     ENDIF
     reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].blob[x2].
     blob_seq_num = cb.blob_seq_num
    ELSE
     IF (cbr.storage_cd=url_cd)
      x2 = (x2+ 1)
      IF (mod(x2,5)=1)
       stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1]
        .blob,(x2+ 4))
      ENDIF
      reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].blob[x2].
      blob_contents = trim(cbr.blob_handle), reply->rb_list[1].event_list[d1.seq].child_event_list[d2
      .seq].blob_result[x1].blob_length = size(trim(cbr.blob_handle)), reply->rb_list[1].event_list[
      d1.seq].child_event_list[d2.seq].blob_result[x1].blob[x2].blob_seq_num = 1
     ENDIF
    ENDIF
   FOOT  cbr.event_id
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result[x1].
     blob,x2)
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_result,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH memsort, nocounter, outerjoin = d3
  ;end select
 ENDIF
 IF (ccr_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "ccr.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = " and ccr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   ccr.seq, ccr.sequence_nbr, n.nomenclature_id
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_coded_result ccr,
    nomenclature n
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].ccr_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)
     AND (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].ccr_entry=1))
    JOIN (ccr
    WHERE parser(date_clause1))
    JOIN (n
    WHERE ccr.nomenclature_id=n.nomenclature_id)
   ORDER BY d1.seq, d2.seq, ccr.sequence_nbr,
    cnvtdatetime(ccr.valid_until_dt_tm)
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD ccr.sequence_nbr
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  ccr.sequence_nbr
    x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].coded_result_list,
      (x1+ 4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].coded_result_list[x1].short_string
     = n.short_string
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].coded_result_list,
     x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (cbs_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "cbs.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = " and cbs.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   blength = textlen(lb.long_blob), cbs.blob_summary_id, cbs.compression_cd,
   lb.seq
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_blob_summary cbs,
    long_blob lb
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].cbs_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)
     AND (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].cbs_entry=1))
    JOIN (cbs
    WHERE parser(date_clause1))
    JOIN (lb
    WHERE lb.parent_entity_name="CE_BLOB_SUMMARY"
     AND lb.parent_entity_id=cbs.ce_blob_summary_id)
   ORDER BY d1.seq, d2.seq, cbs.blob_summary_id,
    cnvtdatetime(cbs.valid_until_dt_tm)
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD cbs.blob_summary_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  cbs.blob_summary_id
    x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_summary_list,
      (x1+ 4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_summary_list[x1].format_cd =
    cbs.format_cd, blob_out = fillstring(32768," ")
    IF (cbs.compression_cd=ocfcomp_cd)
     blob_ret_len = 0,
     CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,32768,blob_ret_len), y1 = size(trim(
       blob_out)),
     reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_summary_list[x1].long_blob =
     blob_out, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_summary_list[x1].
     blob_length = y1
    ELSE
     y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),lb.long_blob), reply->rb_list[1].
     event_list[d1.seq].child_event_list[d2.seq].blob_summary_list[x1].long_blob = blob_out,
     reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_summary_list[x1].blob_length
      = (y1 - 8)
    ENDIF
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].blob_summary_list,
     x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH memsort, nocounter
  ;end select
 ENDIF
 IF (csc_entry_skip=1)
  SET do_nothing = 0
  SET date_clause1 = " "
  SET c1 = "csc.event_id = reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].event_id"
  SET c2 = " and csc.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   csc.collect_dt_tm, csc.collect_tz, csc.recvd_dt_tm,
   csc.recvd_tz, csc.source_type_cd
   FROM (dummyt d1  WITH seq = value(event_id_cnt)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_specimen_coll csc
   PLAN (d1
    WHERE (reply->rb_list[1].event_list[d1.seq].csc_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)
     AND (reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].csc_entry=1))
    JOIN (csc
    WHERE parser(date_clause1))
   ORDER BY d1.seq, d2.seq, csc.collect_dt_tm,
    csc.recvd_dt_tm
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   DETAIL
    x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].
      specimen_coll_list,(x1+ 4))
    ENDIF
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].specimen_coll_list[x1].
    collected_dt_tm = csc.collect_dt_tm, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq
    ].specimen_coll_list[x1].collected_tz = csc.collect_tz, reply->rb_list[1].event_list[d1.seq].
    child_event_list[d2.seq].specimen_coll_list[x1].received_dt_tm = csc.recvd_dt_tm,
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].specimen_coll_list[x1].received_tz
     = csc.recvd_tz, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].
    specimen_coll_list[x1].specimen_type = csc.source_type_cd
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].specimen_coll_list,
     x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD temp_request
 RECORD temp_request(
   1 debug_ind = i2
   1 qual[*]
     2 encntr_id = f8
     2 resource_cd = f8
 )
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 resource_cd = f8
     2 ref_lab_description = vc
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET z = 0
 SET xmax = value(size(reply->rb_list[1].event_list,5))
 FOR (x = 1 TO xmax)
  SET ymax = value(size(reply->rb_list[1].event_list[x].child_event_list,5))
  FOR (y = 1 TO ymax)
    SET z = (z+ 1)
    IF (z > value(size(temp_request->qual,5)))
     SET stat = alterlist(temp_request->qual,(z+ 5))
    ENDIF
    SET temp_request->qual[z].encntr_id = reply->rb_list[1].event_list[x].child_event_list[y].
    encntr_id
    SET temp_request->qual[z].resource_cd = reply->rb_list[1].event_list[x].child_event_list[y].
    resource_cd
  ENDFOR
 ENDFOR
 SET stat = alterlist(temp_request->qual,z)
 EXECUTE cr_get_reflab_footnote  WITH replace(request,temp_request), replace(reply,temp_reply)
 IF (0 < value(size(temp_reply->qual,5))
  AND 0 < value(size(reply->rb_list[1].event_list,5)))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(reply->rb_list[1].event_list,5))),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = value(size(temp_reply->qual,5)))
   PLAN (d1
    WHERE maxrec(d2,size(reply->rb_list[1].event_list[d1.seq].child_event_list,5)))
    JOIN (d2)
    JOIN (d3
    WHERE (temp_reply->qual[d3.seq].resource_cd=reply->rb_list[1].event_list[d1.seq].
    child_event_list[d2.seq].resource_cd)
     AND (temp_reply->qual[d3.seq].encntr_id=reply->rb_list[1].event_list[d1.seq].child_event_list[d2
    .seq].encntr_id))
   DETAIL
    reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].ref_lab_desc = temp_reply->qual[d3
    .seq].ref_lab_description, reply->rb_list[1].event_list[d1.seq].child_event_list[d2.seq].
    ref_lab_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (max_event_list=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

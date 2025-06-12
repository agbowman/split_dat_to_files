CREATE PROGRAM cp_get_event_list_rad:dba
 DECLARE uar_fmt_accession(p1,p2) = c25
 RECORD reply(
   1 rb_list[1]
     2 order_list[*]
       3 order_id = f8
       3 long_text = gc32000
       3 order_mnemonic = vc
       3 comment_dt_tm = dq8
       3 comment_tz = i4
     2 code_list[*]
       3 cp_entry = i2
       3 cep_entry = i2
       3 cen_entry = i2
       3 cbr_entry = i2
       3 ccr_entry = i2
       3 event_list[*]
         4 event_id = f8
         4 order_id = f8
         4 accession_nbr = vc
         4 frmt_accession_nbr = vc
         4 clinical_event_id = f8
         4 parent_event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 view_level = i4
         4 event_cd = f8
         4 event_cd_disp = vc
         4 catalog_cd = f8
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 cp_entry = i2
         4 cep_entry = i2
         4 cen_entry = i2
         4 cbr_entry = i2
         4 ccr_entry = i2
         4 clr_entry = i2
         4 subtable_bit_map = i4
         4 result_status_cd = f8
         4 result_status_cd_disp = vc
         4 normalcy_cd = f8
         4 normalcy_cd_disp = vc
         4 result_val = vc
         4 result_units_cd = f8
         4 result_units_cd_disp = vc
         4 task_assay_cd = f8
         4 verified_dt_tm = dq8
         4 verified_tz = i4
         4 verified_prsnl_id = f8
         4 normal_high = vc
         4 normal_low = vc
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
           5 note_format_cd_mean = vc
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
           5 format_cd_mean = vc
           5 blob[*]
             6 blob_length = i4
             6 blob_contents = gc32768
         4 linked_result[*]
           5 event_id = f8
           5 event_cd = f8
           5 linked_event_id = f8
           5 accession_nbr = vc
         4 coded_result_list[*]
           5 short_string = c60
           5 source_identifier = vc
           5 source_string = vc
         4 child_event_list[*]
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET max_event_list = 0
 SET cp_entry_skip = 0
 SET cep_entry_skip = 0
 SET cen_entry_skip = 0
 SET cbr_entry_skip = 0
 SET ccr_entry_skip = 0
 SET parent_cp_entry_skip = 0
 SET parent_cep_entry_skip = 0
 SET parent_cen_entry_skip = 0
 SET parent_cbr_entry_skip = 0
 SET parent_ccr_entry_skip = 0
 SET x1 = 0
 SET x2 = 0
 DECLARE ocfcomp_cd = f8
 DECLARE ordcomm_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,ocfcomp_cd)
 SET stat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,ordcomm_cd)
 DECLARE where_clause = vc
 DECLARE person_clause = vc
 DECLARE date_clause = vc
 DECLARE date_clause1 = vc
 DECLARE date_clause2 = vc
 DECLARE other_clause = vc
 DECLARE c1 = vc
 DECLARE c2 = vc
 DECLARE c3 = vc
 DECLARE c4 = vc
 DECLARE tempeventcnt = i4
 RECORD temp_events(
   1 qual[*]
     2 event_id = f8
 )
 DECLARE auth_cd = f8
 DECLARE unauth_cd = f8
 DECLARE mod_cd = f8
 DECLARE alt_cd = f8
 DECLARE super_cd = f8
 DECLARE inlab_cd = f8
 DECLARE inprog_cd = f8
 DECLARE trans_cd = f8
 DECLARE del_stat_cd = f8
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,del_stat_cd)
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 CASE (request->scope_flag)
  OF 1:
   SET c1 = build("ce.person_id = ",request->person_id)
  OF 2:
   SET c1 = build("ce.person_id = ",request->person_id)
   SET c2 = build(" and ce.encntr_id = ",request->encntr_id)
  OF 3:
   SET c1 = build("ce.person_id+0 = ",request->person_id)
   SET c2 = build(" and ce.encntr_id+0 = ",request->encntr_id)
   SET c3 =
   " and ce.order_id in (select order_id from chart_request_order where chart_request_id =request->request_id)"
  OF 4:
   SET c1 = build("ce.person_id+0 = ",request->person_id)
   SET c2 = build(" and ce.encntr_id+0 = ",request->encntr_id)
   SET c3 = build(" and ce.accession_nbr = ","request->accession_nbr")
  OF 5:
   SET c1 = build(" ce.person_id = ",request->person_id)
   SET c2 =
   " and ce.encntr_id in (select encntr_id from chart_request_encntr where chart_request_id =request->request_id)"
  OF 6:
   SET c1 = build(" ce.person_id = ",request->person_id)
   SET c2 =
   "  and ce.event_id in (select event_id from chart_request_event where chart_request_id =  request->request_id)"
 ENDCASE
 IF ((request->chart_section_id > 0)
  AND (request->event_ind=1))
  SELECT INTO "nl:"
   chart_section_id
   FROM chart_request_section
   WHERE (chart_request_id=request->request_id)
    AND (chart_section_id=request->chart_section_id)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET c4 =
   "  and ce.event_id in (select event_id from chart_request_event where chart_request_id =  request->request_id)"
  ENDIF
 ENDIF
 SET person_clause = concat(trim(c1)," ",trim(c2)," ",trim(c3),
  " ",trim(c4))
 CALL echo(concat("person clause = ",trim(person_clause)))
 SET c1 = " "
 SET c2 = " "
 SET c3 = " "
 SET c4 = " "
 SET v_until_dt = cnvtdatetime("31-Dec-2100 00:00:00.00")
 IF ((request->date_range_ind=1))
  IF ((request->begin_dt_tm > 0))
   SET s_date = cnvtdatetime(request->begin_dt_tm)
  ELSE
   SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
  ENDIF
  IF ((request->end_dt_tm > 0))
   SET e_date = cnvtdatetime(request->end_dt_tm)
  ELSE
   SET e_date = cnvtdatetime("31-dec-2100 23:59:59.99")
  ENDIF
  IF ((request->request_type=2)
   AND (request->mcis_ind=0))
   SET c2 = " and (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
   IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
    SET c3 = " or ce.performed_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
   ENDIF
   IF ((request->pending_flag=2))
    SET c4 = " or ce.event_end_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
   ELSE
    SET c3 = concat(trim(c3),")")
   ENDIF
  ELSE
   IF ((request->result_lookup_ind=1))
    SET c2 = " and (ce.event_end_dt_tm+0 between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
   ELSE
    SET c2 = " and (ce.clinsig_updt_dt_tm+0 between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
   ENDIF
  ENDIF
  SET date_clause = concat(trim(c2)," ",trim(c3)," ",trim(c4))
 ELSE
  SET date_clause = " and 1=1"
 ENDIF
 CALL echo(concat("date clause = ",date_clause))
 SET c1 = concat(" ce.view_level = 1 and ce.publish_flag = 1",
  " and ce.event_class_cd != placehold_class_cd"," and ce.record_status_cd != del_stat_cd ")
 IF ((request->pending_flag=0))
  SET c2 = " and ce.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd)"
 ELSE
  IF ((request->pending_flag=1))
   SET c2 = " and ce.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd, inlab_cd, inprog_cd)"
  ELSE
   SET c2 =
   " and ce.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
  ENDIF
 ENDIF
 SET other_clause = concat(trim(c1)," ",trim(c2))
 SET where_clause = concat(trim(person_clause)," ",trim(date_clause)," and ",trim(other_clause))
 CALL echo(concat("where clause = ",trim(where_clause)))
 SET code_nbr = size(request->code_list,5)
 SET stat = alterlist(reply->rb_list[1].code_list,code_nbr)
 SET x1 = 0
 IF ((request->request_type=4))
  FREE SET acc_record
  RECORD acc_record(
    1 qual[*]
      2 accession_nbr = vc
      2 event_id = f8
      2 linked_event_id = f8
  )
  SELECT DISTINCT INTO "nl:"
   lr2.accession_nbr
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    clinical_event ce,
    v500_event_set_explode ese,
    ce_linked_result lr,
    ce_linked_result lr2
   PLAN (d1
    WHERE (request->code_list[d1.seq].procedure_type_flag=0))
    JOIN (ce
    WHERE parser(where_clause))
    JOIN (ese
    WHERE ce.event_cd=ese.event_cd
     AND (ese.event_set_cd=request->code_list[d1.seq].code))
    JOIN (lr
    WHERE lr.event_id=ce.event_id
     AND lr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    JOIN (lr2
    WHERE lr2.linked_event_id=lr.linked_event_id
     AND lr2.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
   ORDER BY lr2.accession_nbr
   HEAD REPORT
    x2 = 0
   DETAIL
    x2 = (x2+ 1), stat = alterlist(acc_record->qual,x2), acc_record->qual[x2].accession_nbr = lr2
    .accession_nbr,
    acc_record->qual[x2].event_id = lr2.event_id, acc_record->qual[x2].linked_event_id = lr2
    .linked_event_id
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   lr2.accession_nbr
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    clinical_event ce,
    ce_linked_result lr,
    ce_linked_result lr2
   PLAN (d1
    WHERE (request->code_list[d1.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE parser(where_clause)
     AND (ce.catalog_cd=request->code_list[d1.seq].code))
    JOIN (lr
    WHERE lr.event_id=ce.event_id
     AND lr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    JOIN (lr2
    WHERE lr2.linked_event_id=lr.linked_event_id
     AND lr2.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
   ORDER BY lr2.accession_nbr
   HEAD REPORT
    x2 = size(acc_record->qual,5)
   DETAIL
    x2 = (x2+ 1), stat = alterlist(acc_record->qual,x2), acc_record->qual[x2].accession_nbr = lr2
    .accession_nbr,
    acc_record->qual[x2].event_id = lr2.event_id, acc_record->qual[x2].linked_event_id = lr2
    .linked_event_id
   WITH nocounter
  ;end select
  FOR (x1 = 1 TO x2)
    IF (x1=1)
     SET person_clause = "ce.accession_nbr in ("
    ENDIF
    SET person_clause = build(person_clause,'"',acc_record->qual[x1].accession_nbr,'"')
    IF (x1=x2)
     SET person_clause = build(person_clause,")")
    ELSE
     SET person_clause = build(person_clause,",")
    ENDIF
  ENDFOR
  CALL echo(concat("2nd person_clause = ",trim(person_clause)))
  SET where_clause = concat(trim(person_clause)," ",trim(date_clause)," and ",trim(other_clause))
  CALL echo(concat("2nd where clause = ",trim(where_clause)))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  ce.event_id
  FROM clinical_event ce
  WHERE parser(where_clause)
  ORDER BY ce.event_id
  DETAIL
   tempeventcnt = (tempeventcnt+ 1)
   IF (mod(tempeventcnt,15)=1)
    stat = alterlist(temp_events->qual,(tempeventcnt+ 14))
   ENDIF
   temp_events->qual[tempeventcnt].event_id = ce.event_id
  WITH nocounter
 ;end select
 IF (tempeventcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ce.clinical_event_id, ce.event_id, ce.result_val,
  ce.view_level
  FROM (dummyt d1  WITH seq = value(code_nbr)),
   (dummyt d2  WITH seq = value(size(temp_events->qual,5))),
   clinical_event ce,
   v500_event_set_explode ese
  PLAN (d1
   WHERE (request->code_list[d1.seq].procedure_type_flag=0))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.event_id=temp_events->qual[d2.seq].event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
    AND parser(other_clause))
   JOIN (ese
   WHERE ce.event_cd=ese.event_cd
    AND (ese.event_set_cd=request->code_list[d1.seq].code))
  ORDER BY d1.seq, ce.event_id, cnvtdatetime(ce.valid_until_dt_tm)
  HEAD d1.seq
   x1 = 0, parent_cp_entry_skip = 0, parent_cep_entry_skip = 0,
   parent_cen_entry_skip = 0, parent_cbr_entry_skip = 0, parent_ccr_entry_skip = 0
  HEAD ce.event_id
   x1 = (x1+ 1)
   IF (x1 > max_event_list)
    max_event_list = x1
   ENDIF
   IF (mod(x1,10)=1)
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list,(x1+ 9))
   ENDIF
  DETAIL
   do_nothing = 0
  FOOT  ce.event_id
   reply->rb_list[1].code_list[d1.seq].event_list[x1].event_id = ce.event_id, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].order_id = ce.order_id, reply->rb_list[1].code_list[d1.seq].
   event_list[x1].accession_nbr = ce.accession_nbr,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].frmt_accession_nbr =
   IF ((request->format_acc_ind=1)) uar_fmt_accession(ce.accession_nbr,size(ce.accession_nbr,1))
   ELSE null
   ENDIF
   , reply->rb_list[1].code_list[d1.seq].event_list[x1].clinical_event_id = ce.clinical_event_id,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].parent_event_id = ce.parent_event_id,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].valid_from_dt_tm = ce.valid_from_dt_tm, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].valid_until_dt_tm = ce.valid_until_dt_tm, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].view_level = ce.view_level,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].catalog_cd = ce.catalog_cd, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].event_cd = ce.event_cd, reply->rb_list[1].code_list[d1.seq].
   event_list[x1].event_end_dt_tm = ce.event_end_dt_tm,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].event_end_tz = validate(ce.event_end_tz,0),
   reply->rb_list[1].code_list[d1.seq].event_list[x1].subtable_bit_map = ce.subtable_bit_map, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].cp_entry = btest(ce.subtable_bit_map,20)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cp_entry=1))
    cp_entry_skip = 1, parent_cp_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].cep_entry = btest(ce.subtable_bit_map,0)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cep_entry=1))
    cep_entry_skip = 1, parent_cep_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].cen_entry = btest(ce.subtable_bit_map,1)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cen_entry=1))
    cen_entry_skip = 1, parent_cen_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].cbr_entry = btest(ce.subtable_bit_map,8)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cbr_entry=1))
    cbr_entry_skip = 1, parent_cbr_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].ccr_entry = btest(ce.subtable_bit_map,15)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].ccr_entry=1))
    ccr_entry_skip = 1, parent_ccr_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].clr_entry = btest(ce.subtable_bit_map,10),
   reply->rb_list[1].code_list[d1.seq].event_list[x1].result_status_cd = ce.result_status_cd, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].normalcy_cd = ce.normalcy_cd,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].result_val = ce.result_val, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].result_units_cd = ce.result_units_cd, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].task_assay_cd = ce.task_assay_cd,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].verified_dt_tm = ce.verified_dt_tm, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].verified_tz = validate(ce.verified_tz,0), reply->
   rb_list[1].code_list[d1.seq].event_list[x1].verified_prsnl_id = ce.verified_prsnl_id,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].normal_high = ce.normal_high, reply->rb_list[1]
   .code_list[d1.seq].event_list[x1].normal_low = ce.normal_low
  FOOT  d1.seq
   stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list,x1), reply->rb_list[1].code_list[
   d1.seq].cp_entry = parent_cp_entry_skip, reply->rb_list[1].code_list[d1.seq].cep_entry =
   parent_cep_entry_skip,
   reply->rb_list[1].code_list[d1.seq].cen_entry = parent_cen_entry_skip, reply->rb_list[1].
   code_list[d1.seq].cbr_entry = parent_cbr_entry_skip, reply->rb_list[1].code_list[d1.seq].ccr_entry
    = parent_ccr_entry_skip
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.clinical_event_id, ce.event_id, ce.result_val,
  ce.view_level
  FROM (dummyt d1  WITH seq = value(code_nbr)),
   (dummyt d2  WITH seq = value(size(temp_events->qual,5))),
   clinical_event ce
  PLAN (d1
   WHERE (request->code_list[d1.seq].procedure_type_flag=1))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.event_id=temp_events->qual[d2.seq].event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
    AND parser(other_clause)
    AND (ce.catalog_cd=request->code_list[d1.seq].code))
  ORDER BY d1.seq, ce.event_id, cnvtdatetime(ce.valid_until_dt_tm)
  HEAD d1.seq
   x1 = 0, parent_cp_entry_skip = 0, parent_cep_entry_skip = 0,
   parent_cen_entry_skip = 0, parent_cbr_entry_skip = 0, parent_ccr_entry_skip = 0
  HEAD ce.event_id
   x1 = (x1+ 1)
   IF (x1 > max_event_list)
    max_event_list = x1
   ENDIF
   IF (mod(x1,10)=1)
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list,(x1+ 9))
   ENDIF
  DETAIL
   do_nothing = 0
  FOOT  ce.event_id
   reply->rb_list[1].code_list[d1.seq].event_list[x1].event_id = ce.event_id, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].order_id = ce.order_id, reply->rb_list[1].code_list[d1.seq].
   event_list[x1].accession_nbr = ce.accession_nbr,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].frmt_accession_nbr =
   IF ((request->format_acc_ind=1)) uar_fmt_accession(ce.accession_nbr,size(ce.accession_nbr,1))
   ELSE null
   ENDIF
   , reply->rb_list[1].code_list[d1.seq].event_list[x1].clinical_event_id = ce.clinical_event_id,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].parent_event_id = ce.parent_event_id,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].valid_from_dt_tm = ce.valid_from_dt_tm, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].valid_until_dt_tm = ce.valid_until_dt_tm, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].view_level = ce.view_level,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].catalog_cd = ce.catalog_cd, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].event_cd = ce.event_cd, reply->rb_list[1].code_list[d1.seq].
   event_list[x1].event_end_dt_tm = ce.event_end_dt_tm,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].event_end_tz = validate(ce.event_end_tz,0),
   reply->rb_list[1].code_list[d1.seq].event_list[x1].subtable_bit_map = ce.subtable_bit_map, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].cp_entry = btest(ce.subtable_bit_map,20)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cp_entry=1))
    cp_entry_skip = 1, parent_cp_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].cep_entry = btest(ce.subtable_bit_map,0)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cep_entry=1))
    cep_entry_skip = 1, parent_cep_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].cen_entry = btest(ce.subtable_bit_map,1)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cen_entry=1))
    cen_entry_skip = 1, parent_cen_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].cbr_entry = btest(ce.subtable_bit_map,8)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].cbr_entry=1))
    cbr_entry_skip = 1, parent_cbr_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].ccr_entry = btest(ce.subtable_bit_map,15)
   IF ((reply->rb_list[1].code_list[d1.seq].event_list[x1].ccr_entry=1))
    ccr_entry_skip = 1, parent_ccr_entry_skip = 1
   ENDIF
   reply->rb_list[1].code_list[d1.seq].event_list[x1].clr_entry = btest(ce.subtable_bit_map,10),
   reply->rb_list[1].code_list[d1.seq].event_list[x1].result_status_cd = ce.result_status_cd, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].normalcy_cd = ce.normalcy_cd,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].result_val = ce.result_val, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].result_units_cd = ce.result_units_cd, reply->rb_list[1].
   code_list[d1.seq].event_list[x1].task_assay_cd = ce.task_assay_cd,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].verified_dt_tm = ce.verified_dt_tm, reply->
   rb_list[1].code_list[d1.seq].event_list[x1].verified_tz = validate(ce.verified_tz,0), reply->
   rb_list[1].code_list[d1.seq].event_list[x1].verified_prsnl_id = ce.verified_prsnl_id,
   reply->rb_list[1].code_list[d1.seq].event_list[x1].normal_high = ce.normal_high, reply->rb_list[1]
   .code_list[d1.seq].event_list[x1].normal_low = ce.normal_low
  FOOT  d1.seq
   reply->rb_list[1].code_list[d1.seq].cp_entry = parent_cp_entry_skip, reply->rb_list[1].code_list[
   d1.seq].cep_entry = parent_cep_entry_skip, reply->rb_list[1].code_list[d1.seq].cen_entry =
   parent_cen_entry_skip,
   reply->rb_list[1].code_list[d1.seq].cbr_entry = parent_cbr_entry_skip, reply->rb_list[1].
   code_list[d1.seq].ccr_entry = parent_ccr_entry_skip, stat = alterlist(reply->rb_list[1].code_list[
    d1.seq].event_list,x1)
  WITH nocounter
 ;end select
 IF (max_event_list=0)
  GO TO exit_script
 ENDIF
 CALL echo(build("max_event_list = ",max_event_list))
 SELECT INTO "nl:"
  ce.event_end_dt_tm, lr.*, lr2.*
  FROM (dummyt d1  WITH seq = value(code_nbr)),
   (dummyt d2  WITH seq = value(max_event_list)),
   ce_linked_result lr,
   ce_linked_result lr2,
   clinical_event ce
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5))
   JOIN (lr
   WHERE (lr.event_id=reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id)
    AND lr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
   JOIN (lr2
   WHERE lr2.linked_event_id=lr.linked_event_id
    AND lr2.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
   JOIN (ce
   WHERE lr2.event_id=ce.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
  ORDER BY d1.seq, d2.seq, cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD d1.seq
   do_nothing = 0
  HEAD d2.seq
   x1 = 0
  DETAIL
   x1 = (x1+ 1), stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].
    linked_result,x1), reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].linked_result[x1].
   linked_event_id = lr2.linked_event_id,
   reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].linked_result[x1].event_cd = ce.event_cd,
   reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].linked_result[x1].event_id = lr2.event_id,
   reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].linked_result[x1].accession_nbr = lr2
   .accession_nbr
  FOOT  d2.seq
   do_nothing = 0
  FOOT  d1.seq
   do_nothing = 0
  WITH nocounter
 ;end select
 IF (cp_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = " cp.event_id = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id"
  SET c2 = "  and cp.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   cp.seq, cp.product_id
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_product cp
   PLAN (d1
    WHERE (reply->rb_list[1].code_list[d1.seq].cp_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5)
     AND (reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].cp_entry=1))
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
     stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].product,(x1+ 4))
    ENDIF
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].product[x1].product_nbr = cp.product_nbr,
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].product[x1].product_cd = cp.product_cd,
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].product[x1].product_status_cd = cp
    .product_status_cd
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].product,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (cep_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "cep.event_id = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id"
  SET c2 = " and cep.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   cep.seq, cep.event_prsnl_id
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_event_prsnl cep
   PLAN (d1
    WHERE (reply->rb_list[1].code_list[d1.seq].cep_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5)
     AND (reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].cep_entry=1))
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
     stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_prsnl_list,(x1+ 4)
      )
    ENDIF
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_prsnl_list[x1].action_type_cd = cep
    .action_type_cd, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_prsnl_list[x1].
    action_dt_tm = cep.action_dt_tm, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].
    event_prsnl_list[x1].action_tz = validate(cep.action_tz,0),
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_prsnl_list[x1].action_prsnl_id = cep
    .action_prsnl_id
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_prsnl_list,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (cen_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "cen.event_id = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id"
  SET c2 = " and cen.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   blength = textlen(lb.long_blob), cen.event_note_id, lb.seq
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_event_note cen,
    long_blob lb
   PLAN (d1
    WHERE (reply->rb_list[1].code_list[d1.seq].cen_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5)
     AND (reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].cen_entry=1))
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
     stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list,(x1+ 4))
    ENDIF
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list[x1].note_type_cd = cen
    .note_type_cd, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list[x1].
    note_format_cd = cen.note_format_cd, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].
    event_note_list[x1].note_dt_tm = cen.note_dt_tm,
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list[x1].note_tz = validate(cen
     .note_tz,0), blob_out = fillstring(32000," ")
    IF (cen.compression_cd=ocfcomp_cd)
     blob_ret_len = 0,
     CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,32000,blob_ret_len), y1 = size(trim(
       blob_out)),
     reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list[x1].long_blob = blob_out,
     reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list[x1].blob_length = y1
    ELSE
     y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),lb.long_blob), reply->rb_list[1].
     code_list[d1.seq].event_list[d2.seq].event_note_list[x1].long_blob = blob_out,
     reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list[x1].blob_length = (y1 - 8
     )
    ENDIF
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_note_list,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH memsort, nocounter
  ;end select
 ENDIF
 IF (cbr_entry_skip=1)
  SET date_clause1 = " "
  SET date_clause2 = " "
  SET c1 = "cbr.event_id = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id"
  SET c2 = " and cbr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SET c1 = "cb.event_id = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id"
  SET c2 = "and cb.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause2 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   blength = textlen(cb.blob_contents), cbr.event_id, cb.seq
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_blob_result cbr,
    ce_blob cb
   PLAN (d1
    WHERE (reply->rb_list[1].code_list[d1.seq].cbr_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5)
     AND (reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].cbr_entry=1))
    JOIN (cbr
    WHERE parser(date_clause1))
    JOIN (cb
    WHERE parser(date_clause2))
   ORDER BY d1.seq, d2.seq, cbr.event_id,
    cnvtdatetime(cbr.valid_until_dt_tm), cb.event_id, cnvtdatetime(cb.valid_until_dt_tm)
   HEAD d1.seq
    do_nothing = 0
   HEAD d2.seq
    x1 = 0
   HEAD cbr.event_id
    x2 = 0, x1 = (x1+ 1)
    IF (mod(x1,5)=1)
     stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result,(x1+ 4))
    ENDIF
   HEAD cb.event_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  cb.event_id
    x2 = (x2+ 1)
    IF (mod(x2,5)=1)
     stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].blob,(x2
      + 4))
    ENDIF
    blob_out = fillstring(32768," ")
    IF (cb.compression_cd=ocfcomp_cd)
     blob_ret_len = 0,
     CALL uar_ocf_uncompress(cb.blob_contents,blength,blob_out,32768,blob_ret_len), y1 = size(trim(
       blob_out)),
     reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].blob[x2].blob_contents =
     blob_out, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].blob[x2].
     blob_length = y1
    ELSE
     y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1 - 8),cb.blob_contents), reply->
     rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].blob[x2].blob_contents =
     blob_out,
     reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].blob[x2].blob_length = (
     y1 - 8)
    ENDIF
   FOOT  cbr.event_id
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].format_cd = cbr.format_cd,
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result[x1].blob,x2)
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].blob_result,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH memsort, nocounter
  ;end select
 ENDIF
 IF (ccr_entry_skip=1)
  SET date_clause1 = " "
  SET c1 = "ccr.event_id = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].event_id"
  SET c2 = " and ccr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
  SET date_clause1 = concat(trim(c1)," ",trim(c2))
  SELECT INTO "nl:"
   ccr.seq, ccr.sequence_nbr, n.nomenclature_id
   FROM (dummyt d1  WITH seq = value(code_nbr)),
    (dummyt d2  WITH seq = value(max_event_list)),
    ce_coded_result ccr,
    nomenclature n
   PLAN (d1
    WHERE (reply->rb_list[1].code_list[d1.seq].ccr_entry=1))
    JOIN (d2
    WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5)
     AND (reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].ccr_entry=1))
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
     stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].coded_result_list,(x1+ 4
      ))
    ENDIF
    reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].coded_result_list[x1].short_string = n
    .short_string, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].coded_result_list[x1].
    source_string = n.source_string, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].
    coded_result_list[x1].source_identifier = n.source_identifier
   FOOT  d2.seq
    stat = alterlist(reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].coded_result_list,x1)
   FOOT  d1.seq
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(code_nbr)),
   (dummyt d2  WITH seq = value(max_event_list)),
   order_comment oc,
   long_text lt,
   orders o
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->rb_list[1].code_list[d1.seq].event_list,5))
   JOIN (oc
   WHERE (oc.order_id=reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].order_id)
    AND oc.comment_type_cd=ordcomm_cd)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
   JOIN (o
   WHERE o.order_id=oc.order_id)
  ORDER BY oc.order_id, oc.action_sequence
  HEAD REPORT
   x = 0
  FOOT  oc.order_id
   x = (x+ 1), stat = alterlist(reply->rb_list[1].order_list,x), reply->rb_list[1].order_list[x].
   order_id = oc.order_id,
   reply->rb_list[1].order_list[x].long_text = lt.long_text, reply->rb_list[1].order_list[x].
   order_mnemonic = o.order_mnemonic, reply->rb_list[1].order_list[x].comment_dt_tm = reply->rb_list[
   1].code_list[d1.seq].event_list[d2.seq].event_end_dt_tm,
   reply->rb_list[1].order_list[x].comment_tz = reply->rb_list[1].code_list[d1.seq].event_list[d2.seq
   ].event_end_tz
  WITH nocounter
 ;end select
#exit_script
 IF (max_event_list=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

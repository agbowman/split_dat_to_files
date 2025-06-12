CREATE PROGRAM cp_iso_micro_chart:dba
 FREE DEFINE rtl2
 SET numlines = 0
 IF ( NOT ((request->scope_flag IN (1, 2, 4, 5))))
  CALL echo(build("invalid scope of ",request->scope_flag))
  GO TO exit_script
 ENDIF
 RECORD report_data(
   1 num_amends = i2
   1 num_finals = i2
   1 num_prelims = i2
   1 num_stains = i2
   1 qual[*]
     2 event_cd = f8
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = c16
     2 rep_type = vc
 )
 RECORD interp_data(
   1 qual[*]
     2 text_id = f8
     2 catalog_cd = f8
     2 report_text = vc
     2 ver_name = vc
     2 ver_dt_tm = c16
 )
 RECORD order_comment(
   1 qual[*]
     2 text_id = f8
     2 report_text = vc
     2 order_id = f8
     2 action_sequence = f8
 )
 RECORD kb_row(
   1 qual[*]
     2 rownum = i4
     2 pagenum = i4
 )
 RECORD mic_row(
   1 qual[*]
     2 rownum = i4
     2 pagenum = i4
 )
 RECORD other_row(
   1 qual[*]
     2 rownum = i4
     2 pagenum = i4
 )
 RECORD cor_data(
   1 qual[*]
     2 drug = c30
     2 data_type = c1
     2 old_interp_type = c30
     2 old_result = vc
     2 old_interp = vc
     2 old_v_dt_tm = dq8
     2 new_v_dt_tm = dq8
 )
 RECORD foot_data(
   1 qual[*]
     2 qualx[*]
       3 drug = c30
       3 antibiotic_cd = f8
     2 text = vc
     2 text_id = f8
 )
 RECORD out_rec(
   1 outval = vc
 )
 RECORD suscep_rec(
   1 qual[*]
     2 suscep_seq_nbr = i4
 )
 RECORD print_rec(
   1 susceptible[*]
     2 drug = vc
     2 corrected = vc
     2 fns[*]
       3 marker = vc
   1 intermediate[*]
     2 drug = vc
     2 corrected = vc
     2 fns[*]
       3 marker = vc
   1 resistant[*]
     2 drug = vc
     2 corrected = vc
     2 fns[*]
       3 marker = vc
 )
 SET numevents = size(request->code_list,5)
 DECLARE comment_type_cd = f8
 DECLARE n_type = f8
 DECLARE vernum = f8
 DECLARE cornum = f8
 DECLARE auth_cd = f8
 DECLARE mod_cd = f8
 DECLARE alt_cd = f8
 DECLARE super_cd = f8
 DECLARE inlab_cd = f8
 DECLARE inprog_cd = f8
 DECLARE trans_cd = f8
 DECLARE unauth_cd = f8
 DECLARE deleted_cd = f8
 DECLARE interp_cd = f8
 DECLARE nordcommentflag = i2 WITH noconstant(0)
 SET stat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,comment_type_cd)
 SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,n_type)
 SET stat = uar_get_meaning_by_codeset(1901,"VERIFIED",1,vernum)
 SET stat = uar_get_meaning_by_codeset(1901,"CORRECTED",1,cornum)
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,deleted_cd)
 SET stat = uar_get_meaning_by_codeset(14,"INTERPDATA",1,interp_cd)
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 IF ((request->start_dt_tm > 0))
  SET s_date = cnvtdatetime(request->start_dt_tm)
 ELSE
  SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
 ENDIF
 IF ((request->end_dt_tm > 0))
  SET e_date = cnvtdatetime(request->end_dt_tm)
 ELSE
  SET e_date = cnvtdatetime("31-dec-2100 00:00:00.00")
 ENDIF
 DECLARE ce_date_clause1 = vc
 DECLARE ce_date_clause2 = vc
 IF ((request->request_type=2)
  AND (request->mcis_ind=0))
  SET ce_date_clause1 = " (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
  SET ce_date_clause2 = " (ce2.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
 ELSE
  SET ce_date_clause1 =
  " (ce.clinsig_updt_dt_tm+0 between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
  SET ce_date_clause2 =
  " (ce2.clinsig_updt_dt_tm+0 between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
 ENDIF
 CALL echo(build("ce_date_clause1 = ",ce_date_clause1))
 CALL echo(build("ce_date_clause2 = ",ce_date_clause2))
 DECLARE ce_status_clause1 = vc
 DECLARE ce_status_clause2 = vc
 IF ((request->pending_flag=0))
  SET ce_status_clause1 = " (ce.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd)"
  SET ce_status_clause2 = " (ce2.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd)"
 ELSEIF ((request->pending_flag=1))
  SET ce_status_clause1 =
  " (ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
  SET ce_status_clause2 =
  " (ce2.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
 ELSE
  SET ce_status_clause1 = concat(
   " (ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd,",
   " inprog_cd, trans_cd, unauth_cd)")
  SET ce_status_clause2 = concat(
   " (ce2.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd,",
   " inprog_cd, trans_cd, unauth_cd)")
 ENDIF
 SET ce_status_clause1 = concat(ce_status_clause1," and ce.event_class_cd != placehold_class_cd ",
  " and ce.record_status_cd != deleted_cd)")
 SET ce_status_clause2 = concat(ce_status_clause2," and ce2.event_class_cd != placehold_class_cd ",
  " and ce2.record_status_cd != deleted_cd)")
 CALL echo(build("ce_status_clause1 = ",ce_status_clause1))
 CALL echo(build("ce_status_clause2 = ",ce_status_clause2))
 SELECT INTO "nl:"
  cf.ord_comment_flag
  FROM chart_format cf
  WHERE (cf.chart_format_id=request->chart_format_id)
  HEAD REPORT
   nordcommentflag = cf.ord_comment_flag
  WITH nocounter
 ;end select
 SET numqual = 0
 SET with_add = " counter"
 SELECT
  IF ((request->scope_flag=1))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    ce_specimen_coll v500,
    mic_order_lab m,
    ce_specimen_coll v5002,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    clinical_event ce2,
    code_value va,
    code_value_event_r cva
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND (e.event_cd=(ce.event_cd+ 0))
     AND parser(ce_date_clause1)
     AND parser(ce_status_clause1))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0)
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (cva
    WHERE ce2.event_cd=cva.event_cd)
    JOIN (va
    WHERE cva.parent_cd=va.code_value
     AND va.code_set=1000)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v5002.event_id
     AND v5002.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v5002.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = v500, dontcare = d2, parser(with_add)
  ELSEIF ((request->scope_flag=2))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    ce_specimen_coll v500,
    ce_specimen_coll v5002,
    clinical_event ce,
    mic_order_lab m,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    clinical_event ce2,
    code_value va,
    code_value_event_r cva
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND (request->encntr_id=(ce.encntr_id+ 0))
     AND (e.event_cd=(ce.event_cd+ 0))
     AND parser(ce_date_clause1)
     AND parser(ce_status_clause1))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd)
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (cva
    WHERE ce2.event_cd=cva.event_cd)
    JOIN (va
    WHERE cva.parent_cd=va.code_value
     AND va.code_set=1000)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v5002.event_id
     AND v5002.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v5002.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm, has_source
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = d2, parser(with_add)
  ELSEIF ((request->scope_flag=4))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    ce_specimen_coll v500,
    ce_specimen_coll v5002,
    mic_order_lab m,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    clinical_event ce2,
    code_value va,
    code_value_event_r cva
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->accession_nbr=ce.accession_nbr)
     AND (e.event_cd=(ce.event_cd+ 0))
     AND parser(ce_date_clause1)
     AND parser(ce_status_clause1))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0)
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (cva
    WHERE ce2.event_cd=cva.event_cd)
    JOIN (va
    WHERE cva.parent_cd=va.code_value
     AND va.code_set=1000)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v5002.event_id
     AND v5002.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v5002.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = v500, dontcare = d2, parser(with_add)
  ELSEIF ((request->scope_flag=5))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    ce_specimen_coll v500,
    ce_specimen_coll v5002,
    clinical_event ce,
    mic_order_lab m,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    clinical_event ce2,
    code_value va,
    code_value_event_r cva
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND ((ce.encntr_id+ 0) IN (
    (SELECT
     encntr_id
     FROM chart_request_encntr
     WHERE (chart_request_id=request->chart_request_id))))
     AND (e.event_cd=(ce.event_cd+ 0))
     AND parser(ce_date_clause1)
     AND parser(ce_status_clause1))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd)
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (cva
    WHERE ce2.event_cd=cva.event_cd)
    JOIN (va
    WHERE cva.parent_cd=va.code_value
     AND va.code_set=1000)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v5002.event_id
     AND v5002.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v5002.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm, has_source
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = d2, parser(with_add)
  ELSE
  ENDIF
  DISTINCT INTO TABLE cp_mic_1
  has_source = decode(v500.seq,1,v5002.seq,1,2), specimen_id = decode(v500.seq,v500.specimen_id,v5002
   .seq,v5002.specimen_id), source_cd = decode(v500.seq,v500.source_type_cd,v5002.seq,v5002
   .source_type_cd,0.0),
  specimen_src_text = decode(v500.seq,substring(1,100,v500.source_text),v5002.seq,substring(1,100,
    v5002.source_text)), body_site_cd = decode(v500.seq,v500.body_site_cd,v5002.seq,v5002
   .body_site_cd,0.0), drawn_dt_tm = decode(v500.seq,v500.collect_dt_tm,v5002.seq,v5002.collect_dt_tm
   ),
  m.culture_start_dt_tm, ce2.clinical_event_id, va.display,
  ce2.catalog_cd, ce2.order_id, ce2.verified_dt_tm,
  ce2.event_start_dt_tm, ce2.valid_from_dt_tm, ce2.verified_prsnl_id,
  stain_type = substring(1,60,va.description), has_interp = btest(ce2.subtable_bit_map,1), text_order
   =
  IF (btest(ce2.subtable_bit_map,1)=1) 5
  ELSEIF ( NOT (cnvtupper(va.display) IN ("*COR*", "*PRE*", "*AMEND*", "*FINAL*"))) 1
  ELSEIF (cnvtupper(va.display)="*PRE*") 2
  ELSEIF (cnvtupper(va.display)="*FINAL*") 3
  ELSEIF (cnvtupper(va.display) IN ("*COR*", "*AMEND*")) 4
  ELSE 0
  ENDIF
  ,
  text_typex =
  IF (btest(ce2.subtable_bit_map,1)=1) 5
  ELSEIF ( NOT (cnvtupper(va.display) IN ("*COR*", "*PRE*", "*AMEND*", "*FINAL*"))) 1
  ELSEIF (cnvtupper(va.display)="*PRE*") 2
  ELSEIF (cnvtupper(va.display)="*FINAL*") 3
  ELSEIF (cnvtupper(va.display) IN ("*COR*", "*AMEND*")) 4
  ELSE 0
  ENDIF
  , ce2.event_cd, ce2.accession_nbr,
  ce2.event_id, side =
  IF (btest(ce2.subtable_bit_map,9)=1) 0
  ELSEIF (btest(ce2.subtable_bit_map,17)=1) 1
  ELSE 2
  ENDIF
  , blob_entry = decode(ce2.seq,btest(ce2.subtable_bit_map,9),0),
  sus_entry = btest(ce2.subtable_bit_map,17), ce2.person_id, ce2.encntr_id
 ;end select
 SET numqual = (numqual+ curqual)
 IF (numqual > 0)
  SET with_add = " append"
 ELSE
  SET with_add = " counter"
 ENDIF
 SELECT
  IF ((request->scope_flag=1))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    mic_order_lab m,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND (request->code_list[d.seq].code=ce.catalog_cd))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND parser(ce_date_clause2)
     AND parser(ce_status_clause2))
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (va
    WHERE ce2.event_cd=va.code_value)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v500.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, parser(with_add),
    dontcare = va, outerjoin = d3
  ELSEIF ((request->scope_flag=2))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    mic_order_lab m,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND (request->encntr_id=(ce.encntr_id+ 0))
     AND (request->code_list[d.seq].code=ce.catalog_cd))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND parser(ce_date_clause2)
     AND parser(ce_status_clause2))
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (va
    WHERE ce2.event_cd=va.code_value)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v500.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = d2, parser(with_add)
  ELSEIF ((request->scope_flag=4))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    mic_order_lab m,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE (request->accession_nbr=ce.accession_nbr)
     AND (request->code_list[d.seq].code=ce.catalog_cd))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND parser(ce_date_clause2)
     AND parser(ce_status_clause2))
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (va
    WHERE ce2.event_cd=va.code_value)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v500.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, parser(with_add),
    dontcare = v500
  ELSEIF ((request->scope_flag=5))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    mic_order_lab m,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND ((ce.encntr_id+ 0) IN (
    (SELECT
     encntr_id
     FROM chart_request_encntr
     WHERE (chart_request_id=request->chart_request_id))))
     AND (request->code_list[d.seq].code=ce.catalog_cd))
    JOIN (m
    WHERE ce.order_id=m.order_id)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND parser(ce_date_clause2)
     AND parser(ce_status_clause2))
    JOIN (v500
    WHERE ce2.parent_event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (va
    WHERE ce2.event_cd=va.code_value)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v500.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = d2, parser(with_add)
  ELSE
  ENDIF
  DISTINCT INTO TABLE cp_mic_1
  has_source = decode(v500.seq,1,v5002.seq,1,2), specimen_id = decode(v500.seq,v500.specimen_id,v5002
   .seq,v5002.specimen_id), source_cd = decode(v500.seq,v500.source_type_cd,v5002.seq,v5002
   .source_type_cd,0.0),
  specimen_src_text = decode(v500.seq,substring(1,100,v500.source_text),v5002.seq,substring(1,100,
    v5002.source_text)), body_site_cd = decode(v500.seq,v500.body_site_cd,v5002.seq,v5002
   .body_site_cd,0.0), drawn_dt_tm = decode(v500.seq,v500.collect_dt_tm,v5002.seq,v5002.collect_dt_tm
   ),
  culture_start_dt_tm = ce2.event_start_dt_tm, ce2.clinical_event_id, va.display,
  ce2.catalog_cd, ce2.order_id, ce2.verified_dt_tm,
  ce2.event_start_dt_tm, ce2.valid_from_dt_tm, ce2.verified_prsnl_id,
  stain_type = substring(1,60,va.description), has_interp = btest(ce2.subtable_bit_map,1), text_order
   =
  IF (btest(ce2.subtable_bit_map,1)=1) 5
  ELSEIF ( NOT (cnvtupper(va.display) IN ("*COR*", "*PRE*", "*AMEND*", "*FINAL*"))) 1
  ELSEIF (cnvtupper(va.display)="*PRE*") 2
  ELSEIF (cnvtupper(va.display)="*FINAL*") 3
  ELSEIF (cnvtupper(va.display) IN ("*COR*", "*AMEND*")) 4
  ELSE 0
  ENDIF
  ,
  text_typex =
  IF (btest(ce2.subtable_bit_map,1)=1) 5
  ELSEIF ( NOT (cnvtupper(va.display) IN ("*COR*", "*PRE*", "*AMEND*", "*FINAL*"))) 1
  ELSEIF (cnvtupper(va.display)="*PRE*") 2
  ELSEIF (cnvtupper(va.display)="*FINAL*") 3
  ELSEIF (cnvtupper(va.display) IN ("*COR*", "*AMEND*")) 4
  ELSE 0
  ENDIF
  , ce2.event_cd, ce2.accession_nbr,
  ce2.event_id, side =
  IF (btest(ce2.subtable_bit_map,9)=1) 0
  ELSEIF (btest(ce2.subtable_bit_map,17)=1) 1
  ELSE 2
  ENDIF
  , blob_entry = decode(ce2.seq,btest(ce2.subtable_bit_map,9),0),
  sus_entry = btest(ce2.subtable_bit_map,17), ce2.person_id, ce2.encntr_id
 ;end select
 SET numqual = (numqual+ curqual)
 IF (numqual > 0)
  SELECT DISTINCT INTO TABLE cp_mic_2
   display = uar_get_code_display(m9.detail_susceptibility_cd), e.has_interp, m9.chartable_flag,
   sort_text_order =
   IF (e.has_interp=1) build(5,e.event_cd)
   ELSE build(e.text_order,e.event_cd)
   ENDIF
   , text_order =
   IF (e.has_interp=1) 5
   ELSE e.text_order
   ENDIF
   , text_typex =
   IF (e.has_interp=1) 5
   ELSE e.text_typex
   ENDIF
   ,
   description = uar_get_code_description(e.catalog_cd), old_chartable_flag = decode(m97.seq,m97
    .chartable_flag,m9.chartable_flag), m9.susceptibility_status_cd,
   m9.suscep_seq_nbr, m7.micro_seq_nbr, b.compression_cd,
   blob_id = b.event_id, b.valid_until_dt_tm, b.blob_seq_num,
   e.event_cd, e.event_id, e.blob_entry,
   e.verified_dt_tm, stain = e.display, e.order_id,
   accession_nbr = substring(6,13,e.accession_nbr), sort_accession_nbr = decode(m7.seq,build(
     substring(6,13,e.accession_nbr),e.has_interp,m7.micro_seq_nbr,m7.organism_occurrence_nbr),build(
     substring(6,13,e.accession_nbr),e.has_interp,0,0)), m9.antibiotic_cd,
   e.side, ord2 = concat(format(m7.micro_seq_nbr,"##;rp0"),format(m7.organism_occurrence_nbr,"##;rp0"
     )), e.sus_entry,
   e.valid_from_dt_tm, e.clinical_event_id, e.verified_prsnl_id,
   e.catalog_cd, text_type = e.stain_type, o1 = decode(dx.seq,cnvtreal(e.event_cd)),
   e.body_site_cd, m9.suscep_seq_nbr, m9.result_cd,
   status = decode(m97.seq,"C","V"), sort_status = decode(m97.seq,ichar("C"),ichar("V")), res_type =
   decode(v4.seq,"INTERP","ZZZZZZ"),
   e.source_cd, cor_type = decode(m99.seq,"I","X"), old_interp = decode(m99.seq,m99.display," "),
   interp = substring(1,1,v4.description), ord_int2 =
   IF (substring(1,1,v4.description)="S") concat(substring(1,10,uar_get_code_display(m9
       .detail_susceptibility_cd)),"1")
   ELSEIF (substring(1,1,v4.description)="I") concat(substring(1,10,uar_get_code_display(m9
       .detail_susceptibility_cd)),"2")
   ELSE concat(substring(1,10,uar_get_code_display(m9.detail_susceptibility_cd)),"3")
   ENDIF
   , sort_ord_int =
   IF (substring(1,1,v4.description)="S") 1
   ELSEIF (substring(1,1,v4.description)="I") 2
   ELSE 3
   ENDIF
   ,
   ord_int =
   IF (substring(1,1,v4.description)="S") "1"
   ELSEIF (substring(1,1,v4.description)="I") "2"
   ELSE "3"
   ENDIF
   , result_dt_tm = decode(m9.seq,m9.result_dt_tm,e.verified_dt_tm), sort_result_dt_tm = decode(m9
    .seq,m9.result_dt_tm,e.verified_dt_tm),
   sort_corrected_date = decode(m97.seq,cnvtdatetime(m97.result_dt_tm),cnvtdatetime(
     "01-jan-1800 00:00:00.00")), corrected_date = decode(m97.seq,cnvtdatetime(m97.result_dt_tm),
    cnvtdatetime("01-jan-1800 00:00:00.00")), m7.organism_occurrence_nbr,
   bug = substring(1,60,uar_get_code_description(m7.organism_cd)), sort_bug = concat(substring(1,60,
     uar_get_code_description(m7.organism_cd)),cnvtstring(m7.organism_occurrence_nbr)), drug =
   substring(1,50,uar_get_code_description(m9.antibiotic_cd)),
   sort_drug = substring(1,10,cnvtupper(cnvtalphanum(uar_get_code_display(m9.antibiotic_cd)))),
   drugtest = concat(substring(1,10,cnvtupper(cnvtalphanum(uar_get_code_display(m9.antibiotic_cd)))),
    cnvtupper(cnvtalphanum(substring(1,10,uar_get_code_display(m9.detail_susceptibility_cd))))), test
    = substring(1,30,uar_get_code_display(m9.detail_susceptibility_cd)),
   pn2.name_initials, m7.organism_cd, pn2.name_full,
   e.culture_start_dt_tm, specimen_src_text = substring(1,100,lt.long_text), e.drawn_dt_tm,
   sort_drawn_dt_tm = e.drawn_dt_tm
   FROM cp_mic_1 e,
    (dummyt d6  WITH seq = 1),
    ce_blob_result br,
    ce_blob b,
    (dummyt dx  WITH seq = 1),
    person_name pn2,
    ce_microbiology m7,
    ce_susceptibility m9,
    (dummyt d4  WITH seq = 1),
    (dummyt dxx  WITH seq = 1),
    code_value v4,
    (dummyt dx2  WITH seq = 1),
    v500_specimen v500,
    long_text lt,
    ce_susceptibility m97,
    code_value m99
   PLAN (e
    WHERE ((e.sus_entry > 0) OR (((e.blob_entry > 0) OR (e.has_interp > 0)) )) )
    JOIN (v500
    WHERE e.specimen_id=v500.specimen_id)
    JOIN (lt
    WHERE v500.long_text_id=lt.long_text_id)
    JOIN (d6
    WHERE 1=d6.seq)
    JOIN (((br
    WHERE e.event_id=br.event_id
     AND e.blob_entry=1)
    JOIN (b
    WHERE br.event_id=b.event_id)
    JOIN (dx
    WHERE 1=dx.seq)
    JOIN (pn2
    WHERE e.verified_prsnl_id=pn2.person_id
     AND pn2.name_full > " ")
    ) ORJOIN ((m7
    WHERE e.event_id=m7.event_id
     AND e.sus_entry=1)
    JOIN (m9
    WHERE m7.event_id=m9.event_id
     AND m7.valid_until_dt_tm=m9.valid_until_dt_tm
     AND m7.micro_seq_nbr=m9.micro_seq_nbr
     AND (m9.result_cd != - (1)))
    JOIN (d4
    WHERE 1=d4.seq)
    JOIN (v4
    WHERE m9.result_cd=v4.code_value
     AND v4.code_set=64)
    JOIN (dxx
    WHERE 1=dxx.seq)
    JOIN (dx2
    WHERE 1=dx2.seq
     AND cornum=m9.susceptibility_status_cd)
    JOIN (m97
    WHERE m9.event_id=m97.event_id
     AND m9.micro_seq_nbr=m97.micro_seq_nbr
     AND m9.antibiotic_cd=m97.antibiotic_cd
     AND m9.susceptibility_test_cd=m97.susceptibility_test_cd
     AND cnvtdatetime(m9.result_dt_tm) > m97.result_dt_tm)
    JOIN (m99
    WHERE m97.result_cd=m99.code_value
     AND m99.code_set=64)
    ))
   ORDER BY description, sort_drawn_dt_tm DESC, sort_accession_nbr,
    m9.suscep_seq_nbr, sort_status, sort_text_order,
    sort_result_dt_tm DESC, sort_corrected_date DESC
   WITH organization = work, outerjoin = dx2, outerjoin = d4,
    outerjoin = e, counter, outerjoin = dxx,
    dontcare = pn2
  ;end select
 ENDIF
 SET kb_header = "F"
 SET kb_rownum = 0
 SET kb_count = 0
 SET mic_header = "F"
 SET mic_rownum = 0
 SET mic_count = 0
 IF (curqual > 0)
  SELECT INTO "nl:"
   l.long_text_id, c.*, note = decode(b.seq,"BLOB",l.seq,"TEXT",lx.seq,
    "ORDC",lb.seq,"INTP","NONE"),
   m.task_log_id, r.long_text_id, m.organism_qual,
   m.catalog_cd, m.task_display_order, n.compression_cd,
   oc.order_id, oc.action_sequence, lx.long_text_id,
   text_contents = decode(l.seq,substring(1,10000,l.long_text),lx.seq,substring(1,10000,lx.long_text)
    ), s.long_text_id, blob_contents = decode(b.seq,substring(1,20000,b.blob_contents),lb.seq,
    substring(1,20000,lb.long_blob))
   FROM cp_mic_2 c,
    ce_blob b,
    (dummyt d  WITH seq = 1),
    mic_task_log m,
    mic_result_footnote_r r,
    long_text l,
    long_text lx,
    order_comment oc,
    mic_long_text_subtype s,
    ce_event_note n,
    long_blob lb
   PLAN (c)
    JOIN (d
    WHERE 1=d.seq)
    JOIN (((b
    WHERE c.blob_entry=1
     AND c.blob_id=b.event_id
     AND c.valid_until_dt_tm=b.valid_until_dt_tm
     AND c.blob_seq_num=b.blob_seq_num)
    ) ORJOIN ((((m
    WHERE c.order_id=m.order_id
     AND c.res_type="INTERP"
     AND c.organism_cd=m.organism_cd)
    JOIN (r
    WHERE m.task_log_id=r.task_log_id
     AND c.antibiotic_cd=r.antibiotic_cd)
    JOIN (l
    WHERE r.long_text_id=l.long_text_id)
    JOIN (s
    WHERE l.long_text_id=s.long_text_id
     AND s.chartable_ind=1)
    ) ORJOIN ((((n
    WHERE c.event_id=n.event_id)
    JOIN (lb
    WHERE n.ce_event_note_id=lb.parent_entity_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
    ) ORJOIN ((oc
    WHERE c.order_id=oc.order_id
     AND oc.comment_type_cd=comment_type_cd
     AND (oc.action_sequence=
    (SELECT
     max(co2.action_sequence)
     FROM order_comment co2
     WHERE oc.order_id=co2.order_id
      AND oc.comment_type_cd=co2.comment_type_cd)))
    JOIN (lx
    WHERE oc.long_text_id=lx.long_text_id)
    )) )) ))
   HEAD REPORT
    kb_header = "F", kb_rownum = 0, kb_count = 0,
    mic_header = "F", mic_rownum = 0, mic_count = 0,
    other_count = 0, other_rownum = 0, other_page = 0,
    v_from = cnvtdatetime((curdate - 1000),curtime), e_code = 0.0, numlines = 0,
    under = fillstring(131,"-"), u20 = fillstring(20,"_"), u12 = fillstring(12,"_"),
    u10 = fillstring(10,"_"), u9 = fillstring(9,"_"), u2 = fillstring(2,"_"),
    u48 = fillstring(48,"_"), u60 = fillstring(50,"_"), u3 = fillstring(7,"_")
   HEAD PAGE
    row + 0, sus1 = "F"
   HEAD c.catalog_cd
    row + 0
   HEAD c.accession_nbr
    numnotes = 0, num_interps = 0, stat = alterlist(interp_data->qual,num_interps),
    stat = alterlist(foot_data->qual,numnotes), printed2 = "F", acc = concat(substring(3,2,c
      .accession_nbr),"-",substring(5,3,c.accession_nbr),"-",substring(8,8,c.accession_nbr)),
    v_from = cnvtdatetime((curdate - 1000),curtime), e_code = 0.0, sup_footer_needed = "F",
    report_data->num_stains = 0, report_data->num_prelims = 0, report_data->num_finals = 0,
    report_data->num_amends = 0, total_rows = 0, stat = alterlist(report_data->qual,1),
    col 0, ">>>", firstbug = "T",
    ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description = fillstring(
     60," "),
    CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), row + 1, col 0,
    "       PROCEDURE: ", ret_description, row + 1,
    col 0, "          SOURCE: ", ret_meaning = fillstring(12," "),
    ret_display = fillstring(40," "), ret_description = fillstring(60," "),
    CALL uar_get_code(c.source_cd,ret_display,ret_meaning,ret_description),
    ret_description, col 73, "COLLECTED: ",
    c.drawn_dt_tm"mm/dd/yy  hhmm;;q", row + 1, col 0,
    "       BODY SITE: "
    IF (c.body_site_cd > 0)
     CALL uar_get_code(c.body_site_cd,ret_display,ret_meaning,ret_description), ret_description
    ENDIF
    col 73, "  STARTED: ", c.culture_start_dt_tm"mm/dd/yy  hhmm;;q",
    row + 1, col 0, "FREE TEXT SOURCE: ",
    CALL print(trim(c.specimen_src_text)), col 73, "ACCESSION: ",
    acc, row + 1, col 0,
    "<<<", row + 1
   HEAD c.side
    IF (c.side=1)
     row + 0
    ENDIF
    v_from = cnvtdatetime((curdate - 1000),curtime)
   HEAD c.event_id
    IF (((c.side=0) OR (((c.text_order=5) OR (c.text_typex=5)) )) )
     printed = "F", firstbug = "T", reject = "F",
     replace = "F"
     IF (((c.text_order=1) OR (c.text_typex=1)) )
      IF (c.event_cd != e_code)
       e_code = c.event_cd, v_from = c.verified_dt_tm, report_data->num_stains = (report_data->
       num_stains+ 1)
      ELSEIF (c.event_cd=e_code
       AND c.verified_dt_tm > v_from)
       v_from = c.verified_dt_tm, replace = "T", reject = "F"
      ELSE
       reject = "T"
      ENDIF
     ELSEIF (((c.text_order=2) OR (c.text_typex=2)) )
      IF ((report_data->num_prelims=1)
       AND c.verified_dt_tm < v_from)
       reject = "T"
      ELSE
       report_data->num_prelims = 1, v_from = c.verified_dt_tm
      ENDIF
     ELSEIF (((c.text_order=3) OR (c.text_typex=3)) )
      IF ((report_data->num_finals=1)
       AND c.verified_dt_tm < v_from)
       reject = "T"
      ELSE
       report_data->num_finals = 1, v_from = c.verified_dt_tm
      ENDIF
     ELSEIF (((c.text_order=4) OR (c.text_typex=4)) )
      IF ((report_data->num_amends=1)
       AND c.verified_dt_tm < v_from)
       reject = "T"
      ELSE
       report_data->num_amends = 1, v_from = c.verified_dt_tm
      ENDIF
     ELSEIF (((c.text_order=5) OR (c.text_typex=5)) )
      foundint = "F"
      FOR (intcheckvar = 1 TO num_interps)
        IF ((interp_data->qual[intcheckvar].text_id=s.long_text_id))
         foundint = "T"
        ENDIF
      ENDFOR
      IF (foundint="F"
       AND n.note_type_cd=interp_cd)
       num_interps = (num_interps+ 1), stat = alterlist(interp_data->qual,num_interps), interp_data->
       qual[num_interps].text_id = s.long_text_id,
       interp_data->qual[num_interps].catalog_cd = c.catalog_cd, interp_data->qual[num_interps].
       ver_name = c.name_initials, interp_data->qual[num_interps].ver_dt_tm = format(c.verified_dt_tm,
        "dd-mmm-yyyy hhmm;;q"),
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(n.compression_cd,ret_display,ret_meaning,ret_description)
       IF (trim(ret_meaning)="OCFCOMP")
        blob_out = fillstring(30000," "), blob_out2 = fillstring(30000," "), blob_out3 = fillstring(
         30000," "),
        blob_ret_len = 0,
        CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len),
        CALL uar_rtf(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1),
        x1 = size(trim(blob_out2)), blob_out3 = substring(1,x1,blob_out2), interp_data->qual[
        num_interps].report_text = blob_out3
       ELSE
        blob_out2 = fillstring(30000," "), x1 = size(trim(blob_contents)), blob_out2 = substring(1,(
         x1 - 8),blob_contents),
        interp_data->qual[num_interps].report_text = blob_out2
       ENDIF
       reject = "T"
      ENDIF
     ENDIF
     IF (reject="F"
      AND c.text_order != 5
      AND c.text_typex != 5)
      total_rows = (((report_data->num_amends+ report_data->num_finals)+ report_data->num_prelims)+
      report_data->num_stains), stat = alterlist(report_data->qual,total_rows)
      IF (total_rows > 0)
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.compression_cd,ret_display,ret_meaning,ret_description)
       IF (trim(ret_meaning)="OCFCOMP")
        blob_out = fillstring(30000," "), blob_out2 = fillstring(30000," "), blob_out3 = fillstring(
         30000," "),
        blob_ret_len = 0,
        CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len),
        CALL uar_rtf(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1),
        x1 = size(trim(blob_out2)), blob_out3 = substring(1,x1,blob_out2), report_data->qual[
        total_rows].report_text = blob_out3
       ELSE
        blob_out2 = fillstring(30000," "), x1 = size(trim(blob_contents)), blob_out2 = substring(1,(
         x1 - 8),blob_contents),
        report_data->qual[total_rows].report_text = blob_out2
       ENDIF
       report_data->qual[total_rows].event_cd = c.event_cd, report_data->qual[total_rows].stain_name
        = " ", report_data->qual[total_rows].stain_name = c.text_type,
       report_data->qual[total_rows].report_type = c.text_order, report_data->qual[total_rows].
       ver_name = c.name_initials, report_data->qual[total_rows].ver_dt_time = format(c
        .verified_dt_tm,"mm/dd/yy hhmm;;q"),
       report_data->qual[total_rows].rep_type = c.text_type, report_data->qual[total_rows].report_seq
        =
       IF (((c.text_order=1) OR (c.text_typex=1)) ) report_data->num_stains
       ELSEIF (((c.text_order=2) OR (c.text_typex=2)) ) report_data->num_prelims
       ELSEIF (((c.text_order=3) OR (c.text_typex=3)) ) report_data->num_finals
       ELSEIF (((c.text_order=4) OR (c.text_typex=4)) ) report_data->num_amends
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   HEAD c.sort_accession_nbr
    numcoms = 0, stat = alterlist(order_comment->qual,numcoms), head_o2 = "T"
    IF (c.side=1)
     IF (firstbug="T")
      printed = "T", printed2 = "T", firstbug = "F",
      num_lines = 0, end_par = 0, line_len = 0
      IF ((report_data->num_stains > 0))
       IF (row > 57)
        BREAK
       ENDIF
       row + 1, col 0, ">>",
       row + 1, col 0, "*** DIRECT SPECIMEN EXAMINATION ***             ",
       row + 1, col 0, "<<"
       FOR (lvar = 1 TO total_rows)
        text_line = fillstring(65," "),
        IF ((report_data->qual[lvar].report_type=1))
         row + 1, col 0, ">>",
         row + 1, col 0, report_data->qual[lvar].stain_name,
         col 72, "  REPORTED: "
         IF ((report_data->qual[lvar].ver_dt_time > " "))
          report_data->qual[lvar].ver_dt_time
         ELSE
          "**Unknown**"
         ENDIF
         mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(65," "),
         startpos = 1,
         endpos = 65, done = "F"
         WHILE (done="F")
           endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,((mysize - startpos)+ 1)),
           text_line = substring(startpos,numchars,report_data->qual[lvar].report_text),
           doneit = "F", curpos = numchars, new_pos = findstring("->",text_line)
           IF (new_pos=0)
            new_pos = findstring(build(char(13),char(10)),text_line)
           ENDIF
           IF (new_pos > 0)
            curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data->
             qual[lvar].report_text),
            numchars = (curpos+ 2), endpos = numchars
           ENDIF
           WHILE (doneit="F"
            AND endpos < mysize)
             IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
              IF (curpos=0)
               curpos = 65
              ENDIF
              doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
               qual[lvar].report_text)
             ELSE
              curpos = (curpos - 1)
             ENDIF
           ENDWHILE
           startpos = (startpos+ numchars)
           IF (text_line > " ")
            row + 1, col 0,
            CALL print(trim(text_line,2))
           ENDIF
           IF (endpos >= mysize)
            done = "T"
           ENDIF
         ENDWHILE
         row + 1, col 0, "<<",
         row + 1, col 0, " "
        ENDIF
       ENDFOR
      ENDIF
      report_type = 0
      IF ((report_data->num_amends > 0))
       report_type = 4, row + 1, col 0,
       ">>", row + 1, col 0,
       "*** AMENDED REPORT ***            "
      ELSEIF ((report_data->num_finals > 0))
       report_type = 3, row + 1, col 0,
       ">>", row + 1, col 0,
       "*** FINAL REPORT ***"
      ELSEIF ((report_data->num_prelims > 0))
       report_type = 2, row + 1, col 0,
       ">>", row + 1, col 0,
       "*** PRELIMINARY REPORT ***"
      ENDIF
      IF (report_type > 0)
       FOR (lvar = 1 TO total_rows)
         IF ((report_data->qual[lvar].report_type=report_type))
          col 72, "  REPORTED: "
          IF ((report_data->qual[lvar].ver_dt_time > " "))
           report_data->qual[lvar].ver_dt_time
          ELSE
           "**Unknown**"
          ENDIF
          mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(65," "),
          startpos = 1,
          endpos = 65, done = "F", numlines2 = 0
          WHILE (done="F"
           AND numlines2 < 100)
            numlines2 = (numlines2+ 1), endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,
             ((mysize - startpos)+ 1)),
            text_line = substring(startpos,numchars,report_data->qual[lvar].report_text), doneit =
            "F", curpos = numchars,
            new_pos = findstring("->",text_line)
            IF (new_pos=0)
             new_pos = findstring(build(char(13),char(10)),text_line)
            ENDIF
            IF (new_pos > 0)
             curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data
              ->qual[lvar].report_text),
             numchars = (curpos+ 2), endpos = numchars
            ENDIF
            WHILE (doneit="F"
             AND endpos < mysize)
              IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
               IF (curpos=0)
                curpos = 65
               ENDIF
               doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
                qual[lvar].report_text)
              ELSE
               curpos = (curpos - 1)
              ENDIF
            ENDWHILE
            startpos = (startpos+ numchars)
            IF (text_line > " ")
             row + 1, col 0,
             CALL print(trim(text_line,2))
            ENDIF
            IF (endpos >= mysize)
             done = "T"
            ENDIF
          ENDWHILE
          row + 1, col 0, "<<",
          row + 1, col 0, " "
         ENDIF
       ENDFOR
      ENDIF
      row + 1, col 0, ">>",
      row + 1, col 0, "*** SUSCEPTIBILITY RESULTS ***            ",
      row + 1, col 0, "<<",
      may_print = "T", sus1 = "T"
     ENDIF
     mic_rownum = row, mic_page = curpage, kb_rownum = row,
     kb_page = curpage, other_rownum = row, other_page = curpage,
     numcors = 0, numdrugs = 0, stat = alterlist(cor_data->qual,numcors),
     numtests = 0
    ENDIF
   HEAD c.ord2
    row + 0, suscep_no = 0, stat = alterlist(suscep_rec->qual,suscep_no),
    susceptible_no = 0, sfn = 0, intermediate_no = 0,
    ifn = 0, resistant_no = 0, rfn = 0,
    stat = alterlist(print_rec->susceptible,susceptible_no), stat = alterlist(print_rec->intermediate,
     intermediate_no), stat = alterlist(print_rec->resistant,resistant_no)
    IF (c.side=1)
     head_o2 = "F", row + 1, col 0,
     ">>", row + 2, col 0,
     CALL print(trim(c.bug))
     IF (c.organism_occurrence_nbr > 1)
      col + 1, "# ", c.organism_occurrence_nbr"##"
     ENDIF
     row + 1
    ENDIF
    IF (numdrugs > 0)
     row + 1
    ENDIF
    printed = "F"
   HEAD c.suscep_seq_nbr
    is_cor = 0
    IF (c.side=1
     AND c.bug > " ")
     printed = "F"
     IF (c.chartable_flag=0)
      may_print = "F"
     ELSE
      IF (printed="F"
       AND c.interp > " ")
       doitagain = "T"
       FOR (suscepvar = 1 TO suscep_no)
         IF ((suscep_rec->qual[suscepvar].suscep_seq_nbr=c.suscep_seq_nbr))
          doitagain = "F"
         ENDIF
       ENDFOR
       IF (doitagain="T")
        IF (substring(1,1,c.interp)="S")
         susceptible_no = (susceptible_no+ 1), stat = alterlist(print_rec->susceptible,susceptible_no
          ), print_rec->susceptible[susceptible_no].drug = c.drug
         IF (c.status="C")
          print_rec->susceptible[susceptible_no].corrected = "^ "
         ELSE
          print_rec->susceptible[susceptible_no].corrected = " "
         ENDIF
        ELSEIF (substring(1,1,c.interp)="I")
         intermediate_no = (intermediate_no+ 1), stat = alterlist(print_rec->intermediate,
          intermediate_no), print_rec->intermediate[intermediate_no].drug = c.drug
         IF (c.status="C")
          print_rec->intermediate[intermediate_no].corrected = "^ "
         ELSE
          print_rec->intermediate[intermediate_no].corrected = " "
         ENDIF
        ELSEIF (substring(1,1,c.interp)="R")
         resistant_no = (resistant_no+ 1), stat = alterlist(print_rec->resistant,resistant_no),
         print_rec->resistant[resistant_no].drug = c.drug
         IF (c.status="C")
          print_rec->resistant[resistant_no].corrected = "^ "
         ELSE
          print_rec->resistant[resistant_no].corrected = " "
         ENDIF
        ENDIF
        suscep_no = (suscep_no+ 1), stat = alterlist(suscep_rec->qual,suscep_no), suscep_rec->qual[
        suscep_no].suscep_seq_nbr = c.suscep_seq_nbr,
        printed = "T"
       ENDIF
      ENDIF
      is_cor = 0, may_print = "T", printed = "T",
      last_dt_mic = cnvtdatetime((curdate - 1000),curtime), last_dt_kb = cnvtdatetime((curdate - 1000
       ),curtime)
     ENDIF
    ENDIF
   HEAD r.long_text_id
    IF (note="TEXT"
     AND printed="T"
     AND c.interp > " "
     AND c.chartable_flag=1)
     found_note = "F"
     FOR (kbgvar = 1 TO numnotes)
       IF ((foot_data->qual[kbgvar].text_id=r.long_text_id))
        found_note = "T", found_drug = "F", out_rec->outval = build("(",kbgvar,")"),
        k2 = size(foot_data->qual[kbgvar].qualx,5)
        IF (k2 > 0)
         FOR (kbhvar = 1 TO k2)
           IF ((foot_data->qual[kbgvar].qualx[kbhvar].antibiotic_cd=c.antibiotic_cd))
            found_drug = "T", kbhvar = k2
           ENDIF
         ENDFOR
        ENDIF
        IF (found_drug="F")
         IF (substring(1,1,c.interp)="S")
          sfn = (sfn+ 1), stat = alterlist(print_rec->susceptible[susceptible_no].fns,sfn), print_rec
          ->susceptible[susceptible_no].fns[sfn].marker = out_rec->outval
         ELSEIF (substring(1,1,c.interp)="I")
          ifn = (ifn+ 1), stat = alterlist(print_rec->intermediate[intermediate_no].fns,ifn),
          print_rec->intermediate[intermediate_no].fns[ifn].marker = out_rec->outval
         ELSEIF (substring(1,1,c.interp)="R")
          rfn = (rfn+ 1), stat = alterlist(print_rec->resistant[resistant_no].fns,rfn), print_rec->
          resistant[resistant_no].fns[rfn].marker = out_rec->outval
         ENDIF
         k2 = (k2+ 1), stat = alterlist(foot_data->qual[kbgvar].qualx,k2), foot_data->qual[kbgvar].
         qualx[k2].drug = c.drug,
         foot_data->qual[kbgvar].qualx[k2].antibiotic_cd = c.antibiotic_cd
        ENDIF
        kbgvar = numnotes
       ENDIF
     ENDFOR
     IF (found_note="F")
      numnotes = (numnotes+ 1), out_rec->outval = build("(",numnotes,")")
      IF (substring(1,1,c.interp)="S"
       AND susceptible_no > 0)
       sfn = (sfn+ 1), stat = alterlist(print_rec->susceptible[susceptible_no].fns,sfn), print_rec->
       susceptible[susceptible_no].fns[sfn].marker = out_rec->outval
      ELSEIF (substring(1,1,c.interp)="I"
       AND intermediate_no > 0)
       ifn = (ifn+ 1), stat = alterlist(print_rec->intermediate[intermediate_no].fns,ifn), print_rec
       ->intermediate[intermediate_no].fns[ifn].marker = out_rec->outval
      ELSEIF (substring(1,1,c.interp)="R"
       AND resistant_no > 0)
       rfn = (rfn+ 1), stat = alterlist(print_rec->resistant[resistant_no].fns,rfn), print_rec->
       resistant[resistant_no].fns[rfn].marker = out_rec->outval
      ENDIF
      stat = alterlist(foot_data->qual,numnotes), stat = alterlist(foot_data->qual[numnotes].qualx,1),
      foot_data->qual[numnotes].qualx[1].drug = c.drug,
      foot_data->qual[numnotes].qualx[1].antibiotic_cd = c.antibiotic_cd, foot_data->qual[numnotes].
      text = text_contents, foot_data->qual[numnotes].text_id = r.long_text_id
     ENDIF
    ENDIF
   DETAIL
    IF (((c.text_order=5) OR (c.text_typex=5)) )
     foundint = "F"
     FOR (intcheckvar = 1 TO num_interps)
       IF ((interp_data->qual[intcheckvar].text_id=s.long_text_id))
        foundint = "T"
       ENDIF
     ENDFOR
     IF (foundint="F"
      AND n.note_type_cd=interp_cd)
      num_interps = (num_interps+ 1), stat = alterlist(interp_data->qual,num_interps), interp_data->
      qual[num_interps].text_id = s.long_text_id,
      interp_data->qual[num_interps].catalog_cd = c.catalog_cd, interp_data->qual[num_interps].
      ver_name = c.name_initials, interp_data->qual[num_interps].ver_dt_tm = format(c.verified_dt_tm,
       "dd-mmm-yyyy hhmm;;q"),
      ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
      fillstring(60," "),
      CALL uar_get_code(n.compression_cd,ret_display,ret_meaning,ret_description)
      IF (trim(ret_meaning)="OCFCOMP")
       blob_out = fillstring(30000," "), blob_out2 = fillstring(30000," "), blob_out3 = fillstring(
        30000," "),
       blob_ret_len = 0,
       CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len),
       CALL uar_rtf(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1),
       x1 = size(trim(blob_out2)), blob_out3 = substring(1,x1,blob_out2), interp_data->qual[
       num_interps].report_text = blob_out3
      ELSE
       blob_out2 = fillstring(30000," "), x1 = size(trim(blob_contents)), blob_out2 = substring(1,(x1
         - 8),blob_contents),
       interp_data->qual[num_interps].report_text = blob_out2
      ENDIF
      reject = "T"
     ENDIF
    ENDIF
    IF (note="ORDC"
     AND nordcommentflag=0)
     addit = "T"
     IF (numcoms > 0)
      FOR (comvar = 1 TO numcoms)
        IF ((order_comment->qual[comvar].order_id=oc.order_id)
         AND (order_comment->qual[comvar].action_sequence=oc.action_sequence))
         addit = "F"
        ENDIF
      ENDFOR
     ENDIF
     IF (addit="T")
      numcoms = (numcoms+ 1), stat = alterlist(order_comment->qual,numcoms), order_comment->qual[
      numcoms].text_id = lx.long_text_id,
      order_comment->qual[numcoms].order_id = oc.order_id, order_comment->qual[numcoms].
      action_sequence = oc.action_sequence, order_comment->qual[numcoms].report_text = text_contents
     ENDIF
    ENDIF
    IF (c.side=0)
     row + 0
    ELSEIF (c.side=1
     AND may_print="T")
     is_cor = (is_cor+ 1), sup_footer_needed = "T"
     IF (c.status="C"
      AND c.cor_type != "X")
      IF (((datetimediff(cnvtdatetime(c.corrected_date),cnvtdatetime(cor_data->qual[numcors].
        new_v_dt_tm)) != 0
       AND (c.cor_type=cor_data->qual[numcors].data_type)) OR (((numcors=0) OR ((((c.cor_type !=
      cor_data->qual[numcors].data_type)
       AND c.cor_type != "X") OR (trim(substring(1,30,c.drug)) != trim(substring(1,30,cor_data->qual[
        numcors].drug)))) )) )) )
       numcors = (numcors+ 1), stat = alterlist(cor_data->qual,numcors), cor_data->qual[numcors].
       data_type = c.cor_type,
       cor_data->qual[numcors].old_interp_type = c.display, cor_data->qual[numcors].drug = c.drug,
       cor_data->qual[numcors].old_interp_type = c.test
       IF (c.cor_type="I")
        cor_data->qual[numcors].old_interp = trim(c.old_interp)
       ENDIF
       cor_data->qual[numcors].new_v_dt_tm = cnvtdatetime(c.corrected_date), cor_data->qual[numcors].
       old_v_dt_tm = cnvtdatetime(c.verified_dt_tm)
      ENDIF
     ENDIF
    ENDIF
   FOOT  c.ord2
    IF (susceptible_no > 0)
     col 20, " SUSCEPTIBLE: "
     FOR (numdrugs = 1 TO susceptible_no)
       sfn = size(print_rec->susceptible[numdrugs].fns,5), curcol = col
       IF (((curcol+ size(trim(print_rec->susceptible[numdrugs].drug))) > 65)
        AND numdrugs > 1)
        ",", row + 1, col 34
       ELSEIF (numdrugs=1)
        col 34
       ENDIF
       IF (numdrugs > 1
        AND ((curcol+ size(trim(print_rec->susceptible[numdrugs].drug))) <= 65))
        ","
       ENDIF
       CALL print(trim(print_rec->susceptible[numdrugs].drug)),
       CALL print(print_rec->susceptible[numdrugs].corrected)
       IF (sfn > 0)
        FOR (fnvar = 1 TO sfn)
          CALL print(trim(print_rec->susceptible[numdrugs].fns[fnvar].marker))
        ENDFOR
       ENDIF
     ENDFOR
     row + 1
    ENDIF
    IF (intermediate_no > 0)
     col 20, "INTERMEDIATE: "
     FOR (numdrugs = 1 TO intermediate_no)
       ifn = size(print_rec->intermediate[numdrugs].fns,5), curcol = col
       IF (((curcol+ size(trim(print_rec->intermediate[numdrugs].drug))) > 65)
        AND numdrugs > 1)
        ",", row + 1, col 34
       ELSEIF (numdrugs=1)
        col 34
       ENDIF
       IF (numdrugs > 1
        AND ((curcol+ size(trim(print_rec->intermediate[numdrugs].drug))) <= 65))
        ","
       ENDIF
       CALL print(trim(print_rec->intermediate[numdrugs].drug)),
       CALL print(print_rec->intermediate[numdrugs].corrected)
       IF (ifn > 0)
        FOR (fnvar = 1 TO ifn)
          CALL print(trim(print_rec->intermediate[numdrugs].fns[fnvar].marker))
        ENDFOR
       ENDIF
     ENDFOR
     row + 1
    ENDIF
    IF (resistant_no > 0)
     col 20, "   RESISTANT: "
     FOR (numdrugs = 1 TO resistant_no)
       rfn = size(print_rec->resistant[numdrugs].fns,5), curcol = col
       IF (((curcol+ size(trim(print_rec->resistant[numdrugs].drug))) > 65)
        AND numdrugs > 1)
        ",", row + 1, col 34
       ELSEIF (numdrugs=1)
        col 34
       ENDIF
       IF (numdrugs > 1
        AND ((curcol+ size(trim(print_rec->resistant[numdrugs].drug))) <= 65))
        ","
       ENDIF
       CALL print(trim(print_rec->resistant[numdrugs].drug)),
       CALL print(print_rec->resistant[numdrugs].corrected)
       IF (rfn > 0)
        FOR (fnvar = 1 TO rfn)
          CALL print(trim(print_rec->resistant[numdrugs].fns[fnvar].marker))
        ENDFOR
       ENDIF
     ENDFOR
     row + 1
    ENDIF
    IF (numcors <= 0
     AND ((susceptible_no > 0) OR (((resistant_no > 0) OR (intermediate_no > 0)) )) )
     row + 1, col 0, "<<",
     row + 1
    ENDIF
    IF (c.side=1)
     IF (numcors > 0)
      row + 1
      FOR (dvar = 1 TO numcors)
        row + 1, col 0,
        CALL print(trim(cor_data->qual[dvar].drug)),
        " ", " corrected from ",
        CALL print(trim(cor_data->qual[dvar].old_interp,3)),
        " on ",
        CALL print(format(cor_data->qual[dvar].new_v_dt_tm,"mm/dd/yy hhmm;;q"))
      ENDFOR
      row + 3, col 0, "<<"
     ENDIF
    ENDIF
   FOOT  c.accession_nbr
    IF (printed="F"
     AND printed2="F")
     printed = "T", firstbug = "F", num_lines = 0,
     end_par = 0, line_len = 0
     IF ((report_data->num_stains > 0))
      row + 1, col 0, ">>",
      row + 1, col 0, "*** DIRECT SPECIMEN EXAMINATION ***            ",
      row + 1, col 0, "<<"
      FOR (lvar = 1 TO total_rows)
        IF ((report_data->qual[lvar].report_type=1))
         row + 1, col 0, ">>",
         row + 1, col 0, report_data->qual[lvar].stain_name,
         col 72, "REPORTED: "
         IF ((report_data->qual[lvar].ver_dt_time > " "))
          report_data->qual[lvar].ver_dt_time
         ELSE
          "**Unknown**"
         ENDIF
         mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(65," "),
         startpos = 1,
         endpos = 65, done = "F", numlines2 = 0
         WHILE (done="F"
          AND numlines2 <= 100)
           numlines2 = (numlines2+ 1), endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,(
            (mysize - startpos)+ 1)),
           text_line = substring(startpos,numchars,report_data->qual[lvar].report_text), doneit = "F",
           curpos = numchars,
           new_pos = findstring("->",text_line)
           IF (new_pos=0)
            new_pos = findstring(build(char(13),char(10)),text_line)
           ENDIF
           IF (new_pos > 0)
            curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data->
             qual[lvar].report_text),
            numchars = (curpos+ 2), endpos = numchars
           ENDIF
           WHILE (doneit="F"
            AND endpos < mysize)
             IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
              IF (curpos=0)
               curpos = 65
              ENDIF
              doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
               qual[lvar].report_text)
             ELSE
              curpos = (curpos - 1)
             ENDIF
           ENDWHILE
           startpos = (startpos+ numchars)
           IF (text_line > " ")
            row + 1, col 0,
            CALL print(trim(text_line,2))
           ENDIF
           IF (endpos >= mysize)
            done = "T"
           ENDIF
         ENDWHILE
         row + 1, col 0, "<<",
         row + 1, col 0, " "
        ENDIF
      ENDFOR
     ENDIF
     report_type = 0
     IF ((report_data->num_amends > 0))
      report_type = 4, row + 1, col 0,
      ">>", row + 1, col 0,
      "*** AMENDED REPORT ***            "
     ELSEIF ((report_data->num_finals > 0))
      report_type = 3, row + 1, col 0,
      ">>", row + 1, col 0,
      "*** FINAL REPORT***"
     ELSEIF ((report_data->num_prelims > 0))
      report_type = 2, row + 1, col 0,
      ">>", row + 1, col 0,
      "*** PRELIMINARY REPORT***"
     ENDIF
     IF (report_type > 0)
      FOR (lvar = 1 TO total_rows)
        IF ((report_data->qual[lvar].report_type=report_type))
         col 72, "  REPORTED: "
         IF ((report_data->qual[lvar].ver_dt_time > " "))
          report_data->qual[lvar].ver_dt_time
         ELSE
          "**Unknown**"
         ENDIF
         mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(65," "),
         startpos = 1,
         endpos = 65, done = "F"
         WHILE (done="F")
           endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,((mysize - startpos)+ 1)),
           text_line = substring(startpos,numchars,report_data->qual[lvar].report_text),
           doneit = "F", curpos = numchars, new_pos = findstring("->",text_line)
           IF (new_pos=0)
            new_pos = findstring(build(char(13),char(10)),text_line)
           ENDIF
           IF (new_pos > 0)
            curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data->
             qual[lvar].report_text),
            numchars = (curpos+ 2), endpos = numchars
           ENDIF
           WHILE (doneit="F"
            AND endpos < mysize)
             IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
              IF (curpos=0)
               curpos = 65
              ENDIF
              doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
               qual[lvar].report_text)
             ELSE
              curpos = (curpos - 1)
             ENDIF
           ENDWHILE
           startpos = (startpos+ numchars)
           IF (text_line > " ")
            row + 1, col 0,
            CALL print(trim(text_line,2))
           ENDIF
           IF (endpos >= mysize)
            done = "T"
           ENDIF
         ENDWHILE
         row + 1, col 0, "<<"
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    IF (numcoms > 0)
     row + 1, col 0, ">>",
     row + 2, col 0, "*** ORDER COMMENTS ***"
     FOR (comvar2 = 1 TO numcoms)
       mysize = size(trim(order_comment->qual[comvar2].report_text)), text_line = fillstring(65," "),
       startpos = 1,
       endpos = 65, done = "F"
       WHILE (done="F")
         endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,((mysize - startpos)+ 1)),
         text_line = substring(startpos,numchars,order_comment->qual[comvar2].report_text),
         doneit = "F", curpos = numchars, new_pos = findstring("->",text_line)
         IF (new_pos=0)
          new_pos = findstring(build(char(13),char(10)),text_line)
         ENDIF
         IF (new_pos > 0)
          curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,order_comment->
           qual[comvar2].report_text),
          numchars = (curpos+ 2), endpos = numchars
         ENDIF
         WHILE (doneit="F"
          AND endpos < mysize)
           IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
            IF (curpos=0)
             curpos = 65
            ENDIF
            doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,order_comment->
             qual[comvar2].report_text)
           ELSE
            curpos = (curpos - 1)
           ENDIF
         ENDWHILE
         startpos = (startpos+ numchars)
         IF (trim(text_line,2) > " ")
          row + 1, col 0
          IF (((startpos - numchars)=1))
           CALL print(build("(",comvar2,")"))
          ENDIF
          CALL print(trim(text_line,2))
         ENDIF
         IF (endpos >= mysize)
          done = "T"
         ENDIF
       ENDWHILE
     ENDFOR
     row + 2, col 0, "<<",
     row + 1
    ENDIF
    IF (((printed != "F") OR (printed2 != "F")) )
     IF (numnotes > 0)
      row + 2, col 0, ">>",
      row + 2, col 0, "***FOOTNOTES ***"
      FOR (oivar = 1 TO numnotes)
        mysize = size(trim(foot_data->qual[oivar].text)), text_line = fillstring(65," "), startpos =
        1,
        endpos = 65, done = "F"
        WHILE (done="F")
          endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,((mysize - startpos)+ 1)),
          text_line = substring(startpos,numchars,foot_data->qual[oivar].text),
          doneit = "F", curpos = numchars, new_pos = findstring("->",text_line)
          IF (new_pos=0)
           new_pos = findstring(build(char(13),char(10)),text_line)
          ENDIF
          IF (new_pos > 0)
           curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,foot_data->
            qual[oivar].text),
           numchars = (curpos+ 2), endpos = numchars
          ENDIF
          WHILE (doneit="F"
           AND endpos < mysize)
            IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
             IF (curpos=0)
              curpos = 65
             ENDIF
             doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,foot_data->
              qual[oivar].text)
            ELSE
             curpos = (curpos - 1)
            ENDIF
          ENDWHILE
          startpos = (startpos+ numchars)
          IF (trim(text_line,2) > " ")
           row + 1, col 0
           IF (((startpos - numchars)=1))
            CALL print(build("(",oivar,")"))
           ENDIF
           CALL print(trim(text_line,2))
          ENDIF
          IF (endpos >= mysize)
           done = "T"
          ENDIF
        ENDWHILE
      ENDFOR
      row + 2, col 0, "<<",
      row + 1
     ENDIF
    ENDIF
    IF (num_interps > 0)
     row + 1, col 0, ">>",
     row + 1, row + 1, col 0,
     " * * *  Interpretive Results  * * *"
     FOR (oivar = 1 TO num_interps)
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), mysize = size(trim(
         interp_data->qual[oivar].report_text)), text_line = fillstring(65," "),
       startpos = 1, endpos = 65, done = "F",
       numlines2 = 0
       WHILE (done="F"
        AND numlines2 < 100)
         numlines2 = (numlines2+ 1), endpos = minval(mysize,(startpos+ 65)), numchars = minval(65,((
          mysize - startpos)+ 1)),
         text_line = substring(startpos,numchars,interp_data->qual[oivar].report_text), doneit = "F",
         curpos = numchars,
         new_pos = findstring("->",text_line)
         IF (new_pos=0)
          new_pos = findstring(build(char(13),char(10)),text_line)
         ENDIF
         IF (new_pos > 0)
          curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,interp_data->
           qual[oivar].report_text),
          numchars = (curpos+ 2), endpos = numchars
         ENDIF
         WHILE (doneit="F"
          AND endpos < mysize)
           IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
            IF (curpos=0)
             curpos = 65
            ENDIF
            doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,interp_data->
             qual[oivar].report_text)
           ELSE
            curpos = (curpos - 1)
           ENDIF
         ENDWHILE
         startpos = (startpos+ numchars)
         IF (trim(text_line,2) > " ")
          row + 1, col 0
          IF (((startpos - numchars)=1))
           CALL print(build("(",oivar,")"))
          ENDIF
          CALL print(trim(text_line,2))
         ENDIF
         IF (endpos >= mysize)
          done = "T"
         ENDIF
       ENDWHILE
       row + 1
     ENDFOR
     row + 2, col 0, "<<",
     row + 1
    ENDIF
    row + 1, col 0, ">>",
    row + 1, col 0, u60,
    u60, row + 1, col 0,
    "<<", row + 1
   FOOT PAGE
    numrows = row
    IF (numrows > 60)
     numrows = 60
    ENDIF
    FOR (pagevar = 0 TO numrows)
      numlines = (numlines+ 1), stat = alterlist(reply->qual,numlines), reply->qual[numlines].line =
      reportrow((pagevar+ 1)),
      donep = "F"
      WHILE (donep="F")
       nullpos = findstring(char(0),reply->qual[numlines].line),
       IF (nullpos > 0)
        stat = movestring(" ",1,reply->qual[numlines].line,nullpos,1)
       ELSE
        donep = "T"
       ENDIF
      ENDWHILE
    ENDFOR
   WITH outerjoin = c, maxrow = 60, noformfeed,
    maxcol = 600
  ;end select
 ELSE
  SET numlines = 0
 ENDIF
#exit_script
 IF (numlines > 1)
  SELECT
   line = reply->qual[d.seq].line
   FROM (dummyt d  WITH seq = value(numlines))
   PLAN (d)
   WITH counter, maxrow = 1, noformfeed
  ;end select
 ENDIF
 SET reply->num_lines = numlines
 IF (numlines > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(reply->status_data.status)
 CALL echo("CP_ISO_MICRO_CHART - END")
END GO

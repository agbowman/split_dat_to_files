CREATE PROGRAM cp_micro_chart:dba
 FREE DEFINE rtl2
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD interp_data(
   1 qual[*]
     2 text_id = f8
     2 catalog_cd = f8
     2 report_text = vc
     2 ver_name = vc
     2 ver_dt_tm = c16
 )
 RECORD report_data(
   1 num_amends = i2
   1 num_finals = i2
   1 num_prelims = i2
   1 num_stains = i2
   1 qual[*]
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = c16
     2 rep_type = vc
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
     2 old_result = c10
     2 old_interp = c5
     2 old_v_dt_tm = dq8
     2 new_v_dt_tm = dq8
 )
 RECORD foot_data(
   1 qual[*]
     2 qualx[*]
       3 drug = c30
       3 antibiotic_cd = f8
       3 suscep_seq_no = f8
       3 bug = vc
       3 org_occur_num = f8
     2 text = vc
     2 text_id = f8
 )
 RECORD out_rec(
   1 outval = vc
 )
 RECORD order_comment(
   1 qual[*]
     2 text_id = f8
     2 report_text = vc
     2 order_id = f8
     2 action_sequence = f8
 )
 SET numevents = size(request->code_list,5)
 SET comment_type_cd = 0.0
 SET n_type = 0.0
 SET vernum = 0.0
 SET cornum = 0.0
 SET stat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,comment_type_cd)
 SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,n_type)
 SET stat = uar_get_meaning_by_codeset(1901,"VERIFIED",1,vernum)
 SET stat = uar_get_meaning_by_codeset(1901,"CORRECTED",1,cornum)
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
 FREE SELECT cp_microx
 FREE SELECT cp_microx_2
 SET numlines = 0
 SET numqual = 0
 SELECT INTO "nl:"
  d.object_name
  FROM dprotect d
  PLAN (d
   WHERE d.object="D"
    AND d.object_name="CP_MICROX")
  WITH nocounter
 ;end select
 SET hasvar = curqual
 SELECT INTO "nl:"
  d.object_name
  FROM dprotect d
  PLAN (d
   WHERE d.object="D"
    AND d.object_name="CP_MICROX_2")
  WITH nocounter
 ;end select
 SET hasvar2 = curqual
 IF (hasvar >= 1)
  SET with_add = "  append"
 ELSE
  SET with_add = " counter"
 ENDIF
 SELECT
  IF ((request->scope_flag=1))
   FROM (dummyt d  WITH seq = value(numevents)),
    v500_event_set_explode e,
    clinical_event ce,
    clinical_event cex,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value_event_r cva,
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND e.event_cd=ce.event_cd)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
    dontcare = d2, parser(with_add)
  ELSEIF ((request->scope_flag=2))
   FROM (dummyt d  WITH seq = value(numevents)),
    v500_event_set_explode e,
    clinical_event ce,
    clinical_event cex,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value_event_r cva,
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND (request->encntr_id=ce.encntr_id)
     AND e.event_cd=ce.event_cd)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
  ELSEIF ((request->scope_flag=3))
   FROM (dummyt d  WITH seq = value(numevents)),
    v500_event_set_explode e,
    clinical_event ce,
    clinical_event cex,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value_event_r cva,
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->person_id=ce.person_id)
     AND (request->encntr_id=ce.encntr_id)
     AND (request->order_id=ce.order_id)
     AND e.event_cd=ce.event_cd)
    JOIN (ce2
    WHERE ce.person_id=ce2.person_id
     AND ce.encntr_id=ce2.encntr_id
     AND ce.order_id=ce2.order_id
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date)
     AND ce2.publish_flag > 0)
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
  ELSEIF ((request->scope_flag=4))
   FROM (dummyt d  WITH seq = value(numevents)),
    v500_event_set_explode e,
    clinical_event ce,
    clinical_event cex,
    clinical_event ce2,
    ce_specimen_coll v500,
    (dummyt d2  WITH seq = 1),
    code_value_event_r cva,
    code_value va,
    (dummyt d3  WITH seq = 1),
    ce_specimen_coll v5002
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (request->accession_nbr=ce.accession_nbr)
     AND e.event_cd=ce.event_cd)
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
  ELSE
  ENDIF
  DISTINCT INTO TABLE cp_microx
  ce.view_level, has_source = decode(v500.seq,1,v5002.seq,1,2), source_cd = decode(v500.seq,v500
   .source_type_cd,v5002.seq,v5002.source_type_cd,0.0),
  specimen_src_text = decode(v500.seq,substring(1,100,v500.source_text),v5002.seq,substring(1,100,
    v5002.source_text)), body_site_cd = decode(v500.seq,v500.body_site_cd,v5002.seq,v5002
   .body_site_cd,0.0), drawn_dt_tm = decode(v500.seq,v500.collect_dt_tm,v5002.seq,v5002.collect_dt_tm
   ),
  culture_start_dt_tm = cex.event_start_dt_tm, ce2.clinical_event_id, va.display,
  ce2.catalog_cd, ce2.order_id, ce2.verified_dt_tm,
  ce2.event_start_dt_tm, ce2.valid_from_dt_tm, ce2.verified_prsnl_id,
  stain_type = substring(1,30,va.description), has_interp = btest(ce2.subtable_bit_map,1), text_order
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
 SET numqual = maxval(curqual,numqual)
 SELECT INTO "nl:"
  d.object_name
  FROM dprotect d
  PLAN (d
   WHERE d.object="D"
    AND d.object_name="CP_MICROX")
  WITH nocounter
 ;end select
 SET hasvar = curqual
 IF (hasvar >= 1)
  SET with_add = "  append"
 ELSE
  SET with_add = " counter"
 ENDIF
 SELECT
  IF ((request->scope_flag=1))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    clinical_event cex,
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
     AND (request->code_list[d.seq].code=ce.catalog_cd)
     AND ce.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
    WHERE ce2.event_id=v5002.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, parser(with_add),
    dontcare = va, outerjoin = d3
  ELSEIF ((request->scope_flag=2))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    clinical_event cex,
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
     AND (request->encntr_id=ce.encntr_id)
     AND (request->code_list[d.seq].code=ce.catalog_cd))
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
    JOIN (v500
    WHERE cex.event_id=v500.event_id
     AND v500.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v500.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (va
    WHERE ce2.event_cd=va.code_value)
    JOIN (d3
    WHERE 1=d3.seq)
    JOIN (v5002
    WHERE ce2.event_id=v5002.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, outerjoin = d3,
    dontcare = d2, parser(with_add)
  ELSEIF ((request->scope_flag=3))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    clinical_event cex,
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
     AND (request->encntr_id=ce.encntr_id)
     AND (request->order_id=ce.order_id)
     AND (request->code_list[d.seq].code=ce.catalog_cd))
    JOIN (ce2
    WHERE ce.person_id=ce2.person_id
     AND ce.encntr_id=ce2.encntr_id
     AND ce.order_id=ce2.order_id
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
    WHERE ce2.event_id=v5002.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, parser(with_add),
    dontcare = v500
  ELSEIF ((request->scope_flag=4))
   FROM (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    clinical_event cex,
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
     AND (request->code_list[d.seq].code=ce.catalog_cd)
     AND ce.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (ce2
    WHERE ce.accession_nbr=ce2.accession_nbr
     AND ce.catalog_cd=ce2.catalog_cd
     AND ce2.publish_flag > 0
     AND ce2.verified_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    JOIN (cex
    WHERE ce2.parent_event_id=cex.event_id)
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
    WHERE ce2.event_id=v5002.event_id
     AND ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.accession_nbr, side, text_order,
    ce2.clinical_event_id, ce2.verified_dt_tm
   WITH organization = work, outerjoin = d2, parser(with_add),
    dontcare = v500
  ELSE
  ENDIF
  DISTINCT INTO TABLE cp_microx
  ce.view_level, has_source = decode(v500.seq,1,v5002.seq,1,2), source_cd = decode(v500.seq,v500
   .source_type_cd,v5002.seq,v5002.source_type_cd,0.0),
  specimen_src_text = decode(v500.seq,substring(1,100,v500.source_text),v5002.seq,substring(1,100,
    v5002.source_text)), body_site_cd = decode(v500.seq,v500.body_site_cd,v5002.seq,v5002
   .body_site_cd,0.0), drawn_dt_tm = decode(v500.seq,v500.collect_dt_tm,v5002.seq,v5002.collect_dt_tm
   ),
  culture_start_dt_tm = cex.event_start_dt_tm, ce2.clinical_event_id, va.display,
  ce2.catalog_cd, ce2.order_id, ce2.verified_dt_tm,
  ce2.event_start_dt_tm, ce2.valid_from_dt_tm, ce2.verified_prsnl_id,
  stain_type = substring(1,30,va.description), has_interp = btest(ce2.subtable_bit_map,1), text_order
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
 SET numqual = maxval(curqual,numqual)
 IF (numqual > 0)
  IF (hasvar2 >= 1)
   SET with_add = "  append"
  ELSE
   SET with_add = " counter"
  ENDIF
  SELECT DISTINCT INTO TABLE cp_microx_2
   e.event_start_dt_tm, e.source_cd, e.specimen_src_text,
   e.body_site_cd, m9.chartable_flag, e.has_interp,
   old_chartable_flag = decode(m97.seq,m97.chartable_flag,mm97.seq,mm97.chartable_flag,m9
    .chartable_flag), m9.susceptibility_status_cd, m7.micro_seq_nbr,
   m9.suscep_seq_nbr, m97.suscep_seq_nbr, mm97.suscep_seq_nbr,
   b.compression_cd, blob_id = decode(b.seq,cnvtreal(b.event_id),0.0), b.valid_until_dt_tm,
   b.blob_seq_num, e.event_cd, e.event_id,
   e.blob_entry, e.verified_dt_tm, stain = e.display,
   e.order_id, accession_nbr = substring(6,13,e.accession_nbr), text_order =
   IF (e.has_interp=1) 5
   ELSE e.text_order
   ENDIF
   ,
   text_typex =
   IF (e.has_interp=1) 5
   ELSE e.text_typex
   ENDIF
   , longacc = e.accession_nbr, sort_accession_nbr =
   IF (e.has_interp=1) concat(substring(6,13,e.accession_nbr),format(e.catalog_cd,"###########;rp0"),
     format(e.view_level,"#"),format(e.side,"#####;rp0"),format(5,"#####;rp0"),
     e.stain_type)
   ELSE concat(substring(6,13,e.accession_nbr),format(e.catalog_cd,"###########;rp0"),format(e
      .view_level,"#"),format(e.side,"#####;rp0"),format(e.text_order,"#####;rp0"),
     e.stain_type)
   ENDIF
   ,
   ord0 =
   IF (e.has_interp=1) concat(format(e.side,"#####;rp0"),format(5,"#####;rp0"),e.stain_type)
   ELSE concat(format(e.side,"#####;rp0"),format(e.text_order,"#####;rp0"),e.stain_type)
   ENDIF
   , e.side, e.sus_entry,
   e.valid_from_dt_tm, e.clinical_event_id, e.verified_prsnl_id,
   e.catalog_cd, text_type = e.stain_type, o1 = decode(dx.seq,cnvtreal(e.event_cd)),
   display = uar_get_code_display(m9.detail_susceptibility_cd), m9.suscep_seq_nbr, status = decode(
    m97.seq,"C",mm97.seq,"C","V"),
   sort_status = decode(m97.seq,ichar("C"),mm97.seq,ichar("C"),ichar("V")), res_type = decode(v5.seq,
    "RESULT",v4.seq,"INTERP","ZZZZZZ"), cpd = decode(trade.seq,cnvtreal(trim(trade.cost_per_dose,3)),
    0.0),
   cor_type = decode(m97.seq,"I",mm97.seq,"R","X"), old_result = decode(mm97.seq,uar_get_code_display
    (mm97.result_cd)," "), old_interp = decode(m97.seq,uar_get_code_display(m97.result_cd)," "),
   interp = substring(1,4,v4.description), m9.antibiotic_cd, result = substring(1,20,v5.description),
   result_dt_tm = decode(m9.seq,m9.result_dt_tm,e.verified_dt_tm), corrected_date = decode(m97.seq,
    cnvtdatetime(m97.result_dt_tm),mm97.seq,cnvtdatetime(mm97.result_dt_tm),cnvtdatetime(
     "01-jan-1800 00:00:00.00")), sort_result_dt_tm = decode(m9.seq,m9.result_dt_tm,e.verified_dt_tm),
   sort_corrected_date = decode(m97.seq,cnvtdatetime(m97.result_dt_tm),mm97.seq,cnvtdatetime(mm97
     .result_dt_tm),cnvtdatetime("01-jan-1800 00:00:00.00")), m7.organism_occurrence_nbr, ord2 =
   concat(format(m7.micro_seq_nbr,"####;rp0"),format(m7.organism_occurrence_nbr,"####;rp0")),
   bug = uar_get_code_description(m7.organism_cd), drug = substring(1,30,uar_get_code_description(m9
     .antibiotic_cd)), sort_drug = substring(1,10,cnvtupper(cnvtalphanum(uar_get_code_display(m9
       .antibiotic_cd)))),
   drugtest = concat(substring(1,10,cnvtupper(cnvtalphanum(uar_get_code_display(m9.antibiotic_cd)))),
    cnvtupper(cnvtalphanum(substring(1,10,uar_get_code_display(m9.detail_susceptibility_cd))))), pn2
   .name_initials, pn2.name_full,
   m7.organism_cd, e.culture_start_dt_tm, e.drawn_dt_tm,
   trade.dosage, has_trade = decode(trade.seq,1,0)
   FROM cp_microx e,
    (dummyt d6  WITH seq = 1),
    ce_blob_result br,
    ce_blob b,
    (dummyt dx  WITH seq = 1),
    person_name pn2,
    ce_microbiology m7,
    ce_susceptibility m9,
    (dummyt d4  WITH seq = 1),
    mic_med_trade_name trade,
    (dummyt dxx  WITH seq = 1),
    (dummyt dx2  WITH seq = 1),
    ce_susceptibility m97,
    (dummyt ddx  WITH seq = 1),
    ce_susceptibility mm97,
    code_value v4,
    code_value v5
   PLAN (e
    WHERE ((e.sus_entry > 0) OR (((e.blob_entry > 0) OR (e.has_interp > 0)) )) )
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
     AND m7.micro_seq_nbr=m9.micro_seq_nbr)
    JOIN (d4
    WHERE 1=d4.seq)
    JOIN (trade
    WHERE m9.antibiotic_cd=trade.task_component_cd)
    JOIN (dxx
    WHERE 1=dxx.seq)
    JOIN (((v4
    WHERE m9.result_cd=v4.code_value
     AND v4.code_set=64)
    JOIN (dx2
    WHERE 1=dx2.seq
     AND cornum=m9.susceptibility_status_cd)
    JOIN (m97
    WHERE m9.event_id=m97.event_id
     AND m9.micro_seq_nbr=m97.micro_seq_nbr
     AND m9.antibiotic_cd=m97.antibiotic_cd
     AND m9.susceptibility_test_cd=m97.susceptibility_test_cd
     AND cnvtdatetime(m9.result_dt_tm) > m97.result_dt_tm)
    ) ORJOIN ((v5
    WHERE m9.result_cd=v5.code_value
     AND v5.code_set=1025)
    JOIN (ddx
    WHERE 1=ddx.seq
     AND cornum=m9.susceptibility_status_cd)
    JOIN (mm97
    WHERE m9.event_id=mm97.event_id
     AND m9.micro_seq_nbr=mm97.micro_seq_nbr
     AND m9.antibiotic_cd=mm97.antibiotic_cd
     AND m9.susceptibility_test_cd=mm97.susceptibility_test_cd
     AND cnvtdatetime(m9.result_dt_tm) > mm97.result_dt_tm)
    )) ))
   ORDER BY sort_accession_nbr, m7.micro_seq_nbr, m7.organism_occurrence_nbr,
    sort_drug, drugtest DESC, status,
    sort_result_dt_tm DESC, sort_corrected_date DESC
   WITH outerjoin = dx, outerjoin = d4, outerjoin = dx2,
    outerjoin = ddx, organization = work, counter,
    outerjoin = d4, dontcare = trade, outerjoin = e,
    parser(with_add), dontcare = d9, outerjoin = d9,
    outerjoin = d6
  ;end select
 ENDIF
 SET kb_header = "F"
 SET kb_rownum = 0
 SET kb_count = 0
 SET mic_header = "F"
 SET mic_count = 0
 SET mic_rownum = 0
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
   FROM cp_microx_2 c,
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
     AND c.event_id=b.event_id
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
      AND co2.comment_type_cd=comment_type_cd)))
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
    u46 = fillstring(46,"_"), u60 = fillstring(50,"_"), u3 = fillstring(7,"_")
   HEAD PAGE
    row + 0, sus1 = "F"
   HEAD c.accession_nbr
    row + 0
   HEAD c.catalog_cd
    bsite = c.body_site_cd, ftsource = c.specimen_src_text, num_interps = 0,
    stat = alterlist(interp_data->qual,num_interps), numnotes = 0, stat = alterlist(foot_data->qual,
     numnotes),
    numcoms = 0, stat = alterlist(order_comment->qual,numcoms), v_from = cnvtdatetime((curdate - 1000
     ),curtime),
    e_code = 0.0, sup_footer_needed = "F", report_data->num_stains = 0,
    report_data->num_prelims = 0, report_data->num_finals = 0, report_data->num_amends = 0,
    total_rows = 0, stat = alterlist(report_data->qual,1), col 0,
    ">>>", firstbug = "T", ret_meaning = fillstring(12," "),
    ret_display = fillstring(40," "), ret_description = fillstring(60," "),
    CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description),
    row + 1, col 0, "       PROCEDURE: ",
    ret_description, col 70, "COLLECTED: ",
    c.drawn_dt_tm"dd-mmm-yyyy  hhmm;;q", row + 1, col 0,
    "          SOURCE: ", ret_meaning = fillstring(12," "), ret_display = fillstring(40," "),
    ret_description = fillstring(60," "),
    CALL uar_get_code(c.source_cd,ret_display,ret_meaning,ret_description), ret_description,
    started_row = row, started_page = curpage, col 70,
    "  STARTED: ", c.culture_start_dt_tm"dd-mmm-yyyy  hhmm;;q", row + 1,
    col 0, "       BODY SITE: "
    IF (bsite > 0)
     CALL uar_get_code(c.body_site_cd,ret_display,ret_meaning,ret_description), ret_description
    ENDIF
    row + 1, col 0, "FREE TEXT SOURCE: ",
    ftsource, col 70, "ACCESSION: ",
    myacc = fillstring(20," "), myacc = uar_fmt_accession(c.longacc,20), acc = concat(substring(3,2,c
      .accession_nbr),"-",substring(5,3,c.accession_nbr),"-",substring(8,8,c.accession_nbr)),
    myacc, row + 1, col 0,
    "<<<", row + 1
   HEAD c.side
    IF (c.side=1)
     row + 0
    ENDIF
    v_from = cnvtdatetime((curdate - 1000),curtime)
   HEAD c.event_id
    IF (((c.side=0) OR (c.text_typex=5)) )
     printed = "F", firstbug = "T", reject = "F"
     IF (((c.text_order=1) OR (c.text_typex=1)) )
      IF (c.event_cd != e_code)
       e_code = c.event_cd, v_from = cnvtdatetime(c.verified_dt_tm), report_data->num_stains = (
       report_data->num_stains+ 1)
      ELSEIF (c.event_cd=e_code
       AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) > 0)
       v_from = cnvtdatetime(c.verified_dt_tm), reject = "F"
      ELSE
       reject = "T"
      ENDIF
     ELSEIF (((c.text_order=2) OR (c.text_typex=2)) )
      IF ((report_data->num_prelims=1)
       AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0)
       reject = "T"
      ELSE
       report_data->num_prelims = 1, v_from = cnvtdatetime(c.verified_dt_tm)
      ENDIF
     ELSEIF (((c.text_order=3) OR (c.text_typex=3)) )
      IF ((report_data->num_finals=1)
       AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0)
       reject = "T"
      ELSE
       report_data->num_finals = 1, v_from = cnvtdatetime(c.verified_dt_tm)
      ENDIF
     ELSEIF (((c.text_order=4) OR (c.text_typex=4)) )
      IF ((report_data->num_amends=1)
       AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0)
       reject = "T"
      ELSE
       report_data->num_amends = 1, v_from = cnvtdatetime(c.verified_dt_tm)
      ENDIF
     ELSEIF (((c.text_order=5) OR (c.text_typex=5)) )
      foundint = "F"
      FOR (intcheckvar = 1 TO num_interps)
        IF ((interp_data->qual[intcheckvar].text_id=s.long_text_id))
         foundint = "T"
        ENDIF
      ENDFOR
      IF (foundint="F")
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
      report_data->num_stains)
      IF (total_rows > 0)
       stat = alterlist(report_data->qual,total_rows), ret_meaning = fillstring(12," "), ret_display
        = fillstring(40," "),
       ret_description = fillstring(60," "),
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
       report_data->qual[total_rows].stain_name = c.text_type, report_data->qual[total_rows].
       report_type = c.text_typex, report_data->qual[total_rows].ver_name = c.name_initials,
       report_data->qual[total_rows].ver_dt_time = format(c.verified_dt_tm,"dd-mmm-yyyy hhmm;;q"),
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
   HEAD c.ord2
    IF (c.side=1)
     IF (firstbug="T")
      printed = "T", firstbug = "F", num_lines = 0,
      end_par = 0, line_len = 0
      IF ((report_data->num_stains > 0))
       IF (row > 57)
        BREAK
       ENDIF
       row + 1, col 0, ">>",
       row + 1, col 0, "*** STAINS / PREPARATIONS ***             ",
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 43,
       ret_description
       FOR (lvar = 1 TO total_rows)
        text_line = fillstring(105," "),
        IF ((report_data->qual[lvar].report_type=1))
         row + 2, col 0, report_data->qual[lvar].stain_name,
         row + 1, col 0, "Verified: "
         IF ((report_data->qual[lvar].ver_dt_time > " "))
          report_data->qual[lvar].ver_dt_time
         ELSE
          "**Unknown**"
         ENDIF
         mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(105," "),
         startpos = 1,
         endpos = 105, done = "F"
         WHILE (done="F")
           endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,((mysize - startpos)+ 1)),
           text_line = substring(startpos,numchars,report_data->qual[lvar].report_text),
           doneit = "F", curpos = numchars, new_pos = findstring(build(char(13),char(10)),text_line)
           IF (new_pos > 0)
            curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data->
             qual[lvar].report_text),
            numchars = (curpos+ 2), endpos = numchars
           ELSE
            WHILE (doneit="F"
             AND endpos < mysize)
              IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
               IF (curpos=0)
                curpos = 105
               ENDIF
               doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
                qual[lvar].report_text)
              ELSE
               curpos = (curpos - 1)
              ENDIF
            ENDWHILE
           ENDIF
           startpos = (startpos+ numchars)
           IF (size(trim(text_line)) > 0)
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
      report_type = 0,
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description)
      IF ((report_data->num_amends > 0))
       report_type = 4, row + 1, col 0,
       ">>", row + 1, col 0,
       "*** AMENDED REPORT ***            ", col 43, ret_description
      ELSEIF ((report_data->num_finals > 0))
       report_type = 3, row + 1, col 0,
       ">>", row + 1, col 0,
       "*** FINAL REPORT ***            ", col 43, ret_description
      ELSEIF ((report_data->num_prelims > 0))
       report_type = 2, row + 1, col 0,
       ">>", row + 1, col 0,
       "*** PRELIMINARY REPORT ***            ", col 43, ret_description
      ENDIF
      IF (report_type > 0)
       FOR (lvar = 1 TO total_rows)
         IF ((report_data->qual[lvar].report_type=report_type))
          row + 2, col 0, "Verified: "
          IF ((report_data->qual[lvar].ver_dt_time > " "))
           report_data->qual[lvar].ver_dt_time
          ELSE
           "**Unknown**"
          ENDIF
          mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(105," "),
          startpos = 1,
          endpos = 105, done = "F"
          WHILE (done="F")
            endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,((mysize - startpos)+ 1)),
            text_line = substring(startpos,numchars,report_data->qual[lvar].report_text),
            doneit = "F", curpos = numchars, new_pos = findstring(build(char(13),char(10)),text_line)
            IF (new_pos > 0)
             curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data
              ->qual[lvar].report_text),
             numchars = (curpos+ 2), endpos = numchars
            ENDIF
            WHILE (doneit="F"
             AND endpos < mysize)
              IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
               IF (curpos=0)
                curpos = 105
               ENDIF
               doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
                qual[lvar].report_text)
              ELSE
               curpos = (curpos - 1)
              ENDIF
            ENDWHILE
            startpos = (startpos+ numchars)
            IF (size(trim(text_line)) > 0)
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
      may_print = "T",
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 43,
      ret_description, row + 1, sus1 = "T"
     ENDIF
     IF (sus1="F")
      row + 1, col 0, ">>",
      row + 1
     ENDIF
     row + 2, col 0,
     CALL print(trim(c.bug)),
     sus1 = "F", mic_rownum = row, mic_page = curpage,
     kb_rownum = row, kb_page = curpage, other_rownum = row,
     other_page = curpage, numcors = 0, stat = alterlist(cor_data->qual,numcors)
     IF (c.organism_occurrence_nbr > 1)
      col + 1, "# ", c.organism_occurrence_nbr"##"
     ENDIF
     col 65, "USUAL ADULT DOSE                  RVU COST/DAY", row + 1,
     col 0, u20, col 65,
     u46
    ENDIF
   HEAD c.drug
    printed = "F"
   HEAD c.drugtest
    is_cor = 0
    IF (c.side=1)
     IF (c.chartable_flag=0)
      may_print = "F"
     ELSE
      IF (printed="F")
       row + 1, col 2,
       CALL print(trim(c.drug)),
       printed = "T"
      ENDIF
      is_cor = 0, may_print = "T", last_dt_mic = cnvtdatetime((curdate - 1000),curtime),
      last_dt_kb = cnvtdatetime((curdate - 1000),curtime)
     ENDIF
    ENDIF
   HEAD l.long_text_id
    IF (note="TEXT"
     AND printed="T"
     AND c.interp > " "
     AND c.chartable_flag=1)
     found_note = "F"
     FOR (kbgvar = 1 TO numnotes)
       IF (trim(foot_data->qual[kbgvar].text)=trim(text_contents))
        found_note = "T", found_drug = "F", out_rec->outval = build("(",kbgvar,")"),
        k2 = size(foot_data->qual[kbgvar].qualx,5)
        IF (k2 > 0)
         FOR (kbhvar = 1 TO k2)
           IF ((foot_data->qual[kbgvar].qualx[kbhvar].antibiotic_cd=c.antibiotic_cd)
            AND (foot_data->qual[kbgvar].qualx[kbhvar].suscep_seq_no=c.suscep_seq_nbr)
            AND (foot_data->qual[kbgvar].qualx[kbhvar].bug=c.bug)
            AND (foot_data->qual[kbgvar].qualx[kbhvar].org_occur_num=c.organism_occurrence_nbr))
            found_drug = "T", kbhvar = k2
           ENDIF
         ENDFOR
        ENDIF
        IF (found_drug="F")
         out_rec->outval, k2 = (k2+ 1), stat = alterlist(foot_data->qual[kbgvar].qualx,k2),
         foot_data->qual[kbgvar].qualx[k2].drug = c.drug, foot_data->qual[kbgvar].qualx[k2].
         antibiotic_cd = c.antibiotic_cd, foot_data->qual[kbgvar].qualx[k2].suscep_seq_no = c
         .suscep_seq_nbr,
         foot_data->qual[kbgvar].qualx[k2].bug = c.bug, foot_data->qual[kbgvar].qualx[k2].
         org_occur_num = c.organism_occurrence_nbr
        ENDIF
        kbgvar = numnotes
       ENDIF
     ENDFOR
     IF (found_note="F")
      numnotes = (numnotes+ 1), out_rec->outval = build("(",numnotes,")"), out_rec->outval,
      stat = alterlist(foot_data->qual,numnotes), stat = alterlist(foot_data->qual[numnotes].qualx,1),
      foot_data->qual[numnotes].qualx[1].drug = c.drug,
      foot_data->qual[numnotes].qualx[1].antibiotic_cd = c.antibiotic_cd, foot_data->qual[numnotes].
      text = text_contents, foot_data->qual[numnotes].text_id = l.long_text_id
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
     IF (foundint="F")
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
    IF (note="ORDC")
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
       cor_data->qual[numcors].old_interp_type = c.display, cor_data->qual[numcors].drug = c.drug
       IF (c.cor_type="I")
        cor_data->qual[numcors].old_interp_type = c.display, cor_data->qual[numcors].old_interp =
        trim(c.old_interp)
       ELSEIF (c.cor_type="R")
        cor_data->qual[numcors].old_interp_type = trim(c.display), cor_data->qual[numcors].old_result
         = trim(c.old_result)
       ENDIF
       cor_data->qual[numcors].new_v_dt_tm = cnvtdatetime(c.corrected_date), cor_data->qual[numcors].
       old_v_dt_tm = cnvtdatetime(c.verified_dt_tm)
      ENDIF
     ENDIF
     IF (is_cor IN (0, 1))
      IF (c.res_type="RESULT")
       IF (cnvtupper(c.display) != "*KB*")
        col 30,
        CALL print(trim(format(c.result,"#########;c")))
       ENDIF
      ELSEIF (c.res_type="INTERP ")
       IF (cnvtupper(c.display) != "*KB*")
        col 40,
        CALL print(trim(substring(1,1,c.interp))), mic_count = (mic_count+ 1),
        new_mic = "F"
        IF (mic_count=1)
         new_mic = "T"
        ELSE
         IF ((((mic_row->qual[(mic_count - 1)].rownum != mic_rownum)) OR ((mic_row->qual[(mic_count
          - 1)].pagenum != mic_page))) )
          new_mic = "T"
         ENDIF
        ENDIF
        IF (new_mic="T")
         stat = alterlist(mic_row->qual,mic_count), mic_row->qual[mic_count].rownum = mic_rownum,
         mic_row->qual[mic_count].pagenum = mic_page,
         new_mic = "F"
        ELSE
         mic_count = (mic_count - 1)
        ENDIF
       ELSEIF (cnvtupper(c.display)="*KB*INTERP*")
        col 47,
        CALL print(trim(substring(1,1,c.interp))), kb_count = (kb_count+ 1),
        new_kb = "F"
        IF (kb_count=1)
         new_kb = "T"
        ELSE
         IF ((((kb_row->qual[(kb_count - 1)].rownum != kb_rownum)) OR ((kb_row->qual[(kb_count - 1)].
         pagenum != kb_page))) )
          new_kb = "T"
         ENDIF
        ENDIF
        IF (new_kb="T")
         stat = alterlist(kb_row->qual,kb_count), kb_row->qual[kb_count].rownum = kb_rownum, kb_row->
         qual[kb_count].pagenum = kb_page,
         new_kb = "F"
        ELSE
         kb_count = (kb_count - 1)
        ENDIF
       ELSE
        col 54,
        CALL print(trim(substring(1,1,c.interp))), other_count = (other_count+ 1),
        new_other = "F"
        IF (other_count=1)
         new_other = "T"
        ELSE
         IF ((((other_row->qual[(other_count - 1)].rownum != other_rownum)) OR ((other_row->qual[(
         other_count - 1)].pagenum != other_page))) )
          new_other = "T"
         ENDIF
        ENDIF
        IF (new_other="T")
         stat = alterlist(other_row->qual,other_count), other_row->qual[other_count].rownum =
         other_rownum, other_row->qual[other_count].pagenum = other_page,
         new_other = "F"
        ELSE
         other_count = (other_count - 1)
        ENDIF
       ENDIF
      ENDIF
      IF (c.status="C")
       "c"
      ENDIF
      col 65, c.dosage
      IF (c.has_trade > 0)
       col 99, c.cpd"#########.##"
      ELSE
       col 107, "N/A"
      ENDIF
     ENDIF
    ENDIF
   FOOT  c.ord2
    IF (c.side=1)
     IF (numcors > 0)
      row + 1
      FOR (dvar = 1 TO numcors)
        row + 1, col 0,
        CALL print(trim(cor_data->qual[dvar].drug)),
        " ",
        CALL print(trim(cor_data->qual[dvar].old_interp_type)), " corrected from "
        IF ((cor_data->qual[dvar].old_result > " "))
         CALL print(trim(cor_data->qual[dvar].old_result))
        ELSE
         CALL print(trim(cor_data->qual[dvar].old_interp))
        ENDIF
        " on ",
        CALL print(format(cor_data->qual[dvar].new_v_dt_tm,"dd-mmm-yyyy hhmm;;q"))
      ENDFOR
     ENDIF
     row + 1, col 0, "<<"
    ENDIF
   FOOT  c.catalog_cd
    IF (sup_footer_needed="T")
     row + 1, col 0, ">>",
     printed = "T", row + 2, col 0,
     "Dose listed is the average adult dose which may vary according to clinical conditions such as Renal",
     row + 1, col 0,
     "functions, etc.  Drug interactions and allergic reactions should be ",
     "considered prior to antibiotic therapy.", row + 1,
     col 0, "RVU cost/day includes acquisition cost and hospital operating expenses.", row + 1,
     col 0, "<<"
    ENDIF
    IF (printed="F")
     printed = "T", firstbug = "F", num_lines = 0,
     end_par = 0, line_len = 0
     IF ((report_data->num_stains > 0))
      row + 1, col 0, ">>",
      row + 1, col 0, "*** STAINS / PREPARATIONS ***            ",
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 43,
      ret_description,
      row + 1, col 0, "<<"
      FOR (lvar = 1 TO total_rows)
        IF ((report_data->qual[lvar].report_type=1))
         row + 2, col 0, ">>",
         row + 1, col 0, report_data->qual[lvar].stain_name,
         row + 1, col 0, "Verified: "
         IF ((report_data->qual[lvar].ver_dt_time > " "))
          report_data->qual[lvar].ver_dt_time
         ELSE
          "Unknown"
         ENDIF
         mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(105," "),
         startpos = 1,
         endpos = 105, done = "F"
         WHILE (done="F")
           endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,((mysize - startpos)+ 1)),
           text_line = substring(startpos,numchars,report_data->qual[lvar].report_text),
           doneit = "F", curpos = numchars, new_pos = findstring(build(char(13),char(10)),text_line)
           IF (new_pos > 0)
            curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data->
             qual[lvar].report_text),
            numchars = (curpos+ 2), endpos = numchars
           ENDIF
           WHILE (doneit="F"
            AND endpos < mysize)
             IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
              IF (curpos=0)
               curpos = 105
              ENDIF
              doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
               qual[lvar].report_text)
             ELSE
              curpos = (curpos - 1)
             ENDIF
           ENDWHILE
           startpos = (startpos+ numchars)
           IF (size(trim(text_line)) > 0)
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
     report_type = 0,
     CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description)
     IF ((report_data->num_amends > 0))
      report_type = 4, row + 1, col 0,
      ">>", row + 1, col 0,
      "*** AMENDED REPORT ***            ", col 43, ret_description
     ELSEIF ((report_data->num_finals > 0))
      report_type = 3, row + 1, col 0,
      ">>", row + 1, col 0,
      "*** FINAL REPORT***            ", col 43, ret_description
     ELSEIF ((report_data->num_prelims > 0))
      report_type = 2, row + 1, col 0,
      ">>", row + 1, col 0,
      "*** PRELIMINARY REPORT***            ", col 43, ret_description
     ENDIF
     IF (report_type > 0)
      FOR (lvar = 1 TO total_rows)
        IF ((report_data->qual[lvar].report_type=report_type))
         row + 2, col 0, "Verified: "
         IF ((report_data->qual[lvar].ver_dt_time > " "))
          report_data->qual[lvar].ver_dt_time
         ELSE
          "**Unknown**"
         ENDIF
         mysize = size(trim(report_data->qual[lvar].report_text)), text_line = fillstring(105," "),
         startpos = 1,
         endpos = 105, done = "F"
         WHILE (done="F")
           endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,((mysize - startpos)+ 1)),
           text_line = substring(startpos,numchars,report_data->qual[lvar].report_text),
           doneit = "F", curpos = numchars, new_pos = findstring(build(char(13),char(10)),text_line)
           IF (new_pos > 0)
            curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,report_data->
             qual[lvar].report_text),
            numchars = (curpos+ 2), endpos = numchars
           ENDIF
           WHILE (doneit="F"
            AND endpos < mysize)
             IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
              IF (curpos=0)
               curpos = 105
              ENDIF
              doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,report_data->
               qual[lvar].report_text)
             ELSE
              curpos = (curpos - 1)
             ENDIF
           ENDWHILE
           startpos = (startpos+ numchars)
           IF (size(trim(text_line)) > 0)
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
       mysize = size(trim(order_comment->qual[comvar2].report_text)), text_line = fillstring(105," "),
       startpos = 1,
       endpos = 105, done = "F"
       WHILE (done="F")
         endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,((mysize - startpos)+ 1)),
         text_line = substring(startpos,numchars,order_comment->qual[comvar2].report_text),
         doneit = "F", curpos = numchars, new_pos = findstring(build(char(13),char(10)),text_line)
         IF (new_pos > 0)
          curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,order_comment->
           qual[comvar2].report_text),
          numchars = (curpos+ 2), endpos = numchars
         ENDIF
         WHILE (doneit="F"
          AND endpos < mysize)
           IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
            IF (curpos=0)
             curpos = 105
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
    IF (numnotes > 0)
     row + 2, col 0, ">>",
     row + 1, col 0, "***FOOTNOTES ***"
     FOR (oivar = 1 TO numnotes)
       row + 1, col 0,
       CALL print(build("(",oivar,")")),
       mysize = size(trim(foot_data->qual[oivar].text)), text_line = fillstring(105," "), startpos =
       1,
       endpos = 105, done = "F"
       WHILE (done="F")
         endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,((mysize - startpos)+ 1)),
         text_line = substring(startpos,numchars,foot_data->qual[oivar].text),
         doneit = "F", curpos = numchars, new_pos = findstring(build(char(13),char(10)),text_line)
         IF (new_pos > 0)
          curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,foot_data->
           qual[oivar].text),
          numchars = (curpos+ 2), endpos = numchars
         ENDIF
         WHILE (doneit="F"
          AND endpos < mysize)
           IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
            IF (curpos=0)
             curpos = 105
            ENDIF
            doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,foot_data->qual[
             oivar].text)
           ELSE
            curpos = (curpos - 1)
           ENDIF
         ENDWHILE
         startpos = (startpos+ numchars)
         IF (trim(text_line,2) > " ")
          CALL print(trim(text_line,2)), row + 1
         ENDIF
         IF (endpos >= mysize)
          done = "T"
         ENDIF
       ENDWHILE
     ENDFOR
     row + 1, col 0, "<<"
    ENDIF
    IF (num_interps > 0)
     row + 1, col 0, ">>",
     row + 1, col 0, "*** ",
     ret_display, " Interpretive Results"
     FOR (oivar = 1 TO num_interps)
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), mysize = size(trim(
         interp_data->qual[oivar].report_text)), row + 1,
       col 0, "Verified: ", interp_data->qual[oivar].ver_dt_tm,
       " By: ", interp_data->qual[oivar].ver_name, row + 1,
       text_line = fillstring(105," "), startpos = 1, endpos = 105,
       done = "F", numlines2 = 0
       WHILE (done="F")
         numlines2 = (numlines2+ 1), endpos = minval(mysize,(startpos+ 105)), numchars = minval(105,(
          (mysize - startpos)+ 1)),
         text_line = substring(startpos,numchars,interp_data->qual[oivar].report_text), doneit = "F",
         curpos = numchars,
         new_pos = findstring(build(char(13),char(10)),text_line)
         IF (new_pos > 0)
          curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,interp_data->
           qual[oivar].report_text),
          numchars = (curpos+ 2), endpos = numchars
         ENDIF
         WHILE (doneit="F"
          AND endpos < mysize)
           IF (((substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";")) OR (curpos=0)) )
            IF (curpos=0)
             curpos = 105
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
    row + 2, col 0, u60,
    u60, row + 2, col 0,
    "<<", row + 1
   FOOT PAGE
    numrows = row
    IF (numrows > 60)
     numrows = 60
    ENDIF
    stat = alterlist(reply->qual,((numlines+ numrows)+ 1))
    FOR (pagevar = 0 TO numrows)
      numlines = (numlines+ 1), reply->qual[numlines].line = reportrow((pagevar+ 1)), done = "F"
      WHILE (done="F")
       nullpos = findstring(char(0),reply->qual[numlines].line),
       IF (nullpos > 0)
        stat = movestring(" ",1,reply->qual[numlines].line,nullpos,1)
       ELSE
        done = "T"
       ENDIF
      ENDWHILE
    ENDFOR
   FOOT REPORT
    IF (other_count > 0)
     FOR (mylvar = 1 TO other_count)
       mq1 = ((60 * (other_row->qual[mylvar].pagenum - 1))+ other_row->qual[mylvar].rownum), stat =
       movestring("KB",1,reply->qual[mq1].line,54,2), stat = movestring("PRELIM",1,reply->qual[(mq1+
        1)].line,54,6),
       stat = movestring(u9,1,reply->qual[(mq1+ 2)].line,54,6)
     ENDFOR
    ENDIF
    IF (kb_count > 0)
     FOR (mylvar = 1 TO kb_count)
       mq1 = ((60 * (kb_row->qual[mylvar].pagenum - 1))+ kb_row->qual[mylvar].rownum), stat =
       movestring("KB",1,reply->qual[mq1].line,47,2), stat = movestring("INTERP",1,reply->qual[(mq1+
        1)].line,47,6),
       stat = movestring(u9,1,reply->qual[(mq1+ 2)].line,47,6)
     ENDFOR
    ENDIF
    IF (mic_count > 0)
     FOR (mylvar = 1 TO mic_count)
       mq1 = ((60 * (mic_row->qual[mylvar].pagenum - 1))+ mic_row->qual[mylvar].rownum), stat =
       movestring("MIC",1,reply->qual[mq1].line,34,3), stat = movestring("DILTN",1,reply->qual[(mq1+
        1)].line,34,5),
       stat = movestring(u10,1,reply->qual[(mq1+ 2)].line,34,4), stat = movestring("MIC",1,reply->
        qual[mq1].line,40,3), stat = movestring("INTERP",1,reply->qual[(mq1+ 1)].line,40,6),
       stat = movestring(u10,1,reply->qual[(mq1+ 2)].line,40,6)
     ENDFOR
    ENDIF
   WITH outerjoin = c, maxrow = 60, noformfeed,
    maxcol = 8000
  ;end select
 ELSE
  SET numlines = 0
 ENDIF
 SET d1 = size(reply->qual,5)
 IF (size(reply->qual,5) > 1)
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
END GO

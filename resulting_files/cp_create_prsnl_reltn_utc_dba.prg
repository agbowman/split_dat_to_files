CREATE PROGRAM cp_create_prsnl_reltn_utc:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE x = i4
 SET x = 0
 FREE RECORD parser_rec
 RECORD parser_rec(
   1 qual[*]
     2 statement = vc
 )
 FREE RECORD parser_rec2
 RECORD parser_rec2(
   1 qual[*]
     2 statement = vc
 )
 SET stat = alterlist(parser_rec->qual,11)
 SET parser_rec->qual[1].statement = "rdb create or replace view chart_prsnl_reltn2"
 SET parser_rec->qual[2].statement = build(
  "( person_id, encntr_id, prsnl_person_id, chart_prsnl_r_type_cd, ",
  " r_beg_effective_dt_tm, r_end_effective_dt_tm, expiration_ind) as ")
 SET parser_rec->qual[3].statement = build(
  "select distinct ppr.person_id, e.encntr_id, ppr.prsnl_person_id, ",
  " ppr.person_prsnl_r_cd, ppr.beg_effective_dt_tm, ppr.end_effective_dt_tm,0")
 SET parser_rec->qual[4].statement =
 "from person_prsnl_reltn ppr,encounter e where ppr.active_ind = 1"
 SET parser_rec->qual[5].statement = " and e.person_id = ppr.person_id and e.active_ind = 1"
 SET parser_rec->qual[6].statement = "union all"
 SET parser_rec->qual[7].statement = build(
  "select distinct e.person_id, epr.encntr_id, epr.prsnl_person_id, ",
  " epr.encntr_prsnl_r_cd, epr.beg_effective_dt_tm, epr.end_effective_dt_tm,epr.expiration_ind")
 SET parser_rec->qual[8].statement = "from encntr_prsnl_reltn epr, encounter e"
 SET parser_rec->qual[9].statement = "where epr.active_ind = 1 and e.active_ind = 1"
 SET parser_rec->qual[10].statement = "and e.encntr_id = epr.encntr_id go"
 SET parser_rec->qual[11].statement = " oragen3 'chart_prsnl_reltn2' go"
 FOR (x = 1 TO 11)
   CALL echo(parser_rec->qual[x].statement)
 ENDFOR
 FOR (x = 1 TO 11)
   CALL parser(parser_rec->qual[x].statement)
 ENDFOR
 SET stat = alterlist(parser_rec2->qual,18)
 SET parser_rec2->qual[1].statement = "rdb create or replace view order_prsnl_reltn"
 SET parser_rec2->qual[2].statement =
 "(person_id, encntr_id, prsnl_person_id, chart_prsnl_r_type_cd) as"
 SET parser_rec2->qual[3].statement =
 "select distinct o.person_id, o.encntr_id, oa.order_provider_id, cv.code_value"
 SET parser_rec2->qual[4].statement = "from code_value cv, order_action oa, orders o"
 SET parser_rec2->qual[5].statement =
 "where cv.cdf_meaning = 'ORDERDOC' and cv.code_set = 333 and cv.active_ind = 1"
 SET parser_rec2->qual[6].statement = "and oa.order_id = o.order_id and oa.action_rejected_ind = 0"
 SET parser_rec2->qual[7].statement = "union all"
 SET parser_rec2->qual[8].statement =
 "select distinct o.person_id, o.encntr_id, od.oe_field_value, cv.code_value"
 SET parser_rec2->qual[9].statement =
 "from code_value cv, order_entry_fields oef, oe_format_fields oeff, order_action oa,"
 SET parser_rec2->qual[10].statement = "order_detail od, orders o"
 SET parser_rec2->qual[11].statement =
 "where cv.cdf_meaning = 'CONSULTDOC' and cv.code_set = 333 and cv.active_ind = 1"
 SET parser_rec2->qual[12].statement = "and oeff.oe_format_id = o.oe_format_id"
 SET parser_rec2->qual[13].statement = "and oeff.oe_field_id = oef.oe_field_id"
 SET parser_rec2->qual[14].statement = "and oef.oe_field_meaning_id = 2"
 SET parser_rec2->qual[15].statement = "and od.oe_field_id = oeff.oe_field_id"
 SET parser_rec2->qual[16].statement =
 "and oa.action_sequence = od.action_sequence and oa.order_id = od.order_id"
 SET parser_rec2->qual[17].statement = "and od.order_id = o.order_id go"
 SET parser_rec2->qual[18].statement = " oragen3 'order_prsnl_reltn' go"
 SET x = 0
 FOR (x = 1 TO 18)
   CALL echo(parser_rec2->qual[x].statement)
 ENDFOR
 FOR (x = 1 TO 18)
   CALL parser(parser_rec2->qual[x].statement)
 ENDFOR
 SET readme_data->message =
 "UTC-Compliant Oracles views created:  chart_prsnl_reltn2, order_prsnl_reltn"
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
END GO

CREATE PROGRAM cp_create_prsnl_reltn:dba
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
 FREE RECORD parser_rec
 RECORD parser_rec(
   1 qual[*]
     2 statement = vc
 )
 SET cnt = 0
 SET stat = alterlist(parser_rec->qual,35)
 SET parser_rec->qual[1].statement = "rdb create or replace view chart_prsnl_reltn"
 SET parser_rec->qual[2].statement =
 "( person_id, encntr_id, prsnl_person_id, chart_prsnl_r_type_cd,last_event_updt_dt_tm,scope)"
 SET parser_rec->qual[3].statement = " as "
 SET parser_rec->qual[4].statement = concat(
  " select distinct e.person_id, epr.encntr_id, epr.prsnl_person_id",
  " , epr.encntr_prsnl_r_cd, pp.last_event_updt_dt_tm, 2")
 SET parser_rec->qual[5].statement = " from encntr_prsnl_reltn epr, encounter e, person_patient pp"
 SET parser_rec->qual[6].statement = " where epr.active_ind = 1 "
 SET parser_rec->qual[7].statement =
 " and epr.beg_effective_dt_tm <= sysdate and epr.end_effective_dt_tm >= sysdate"
 SET parser_rec->qual[8].statement = concat(
  " and pp.active_ind = 1 and pp.beg_effective_dt_tm <= sysdate",
  " and pp.end_effective_dt_tm >= sysdate")
 SET parser_rec->qual[9].statement = concat(
  " and e.active_ind = 1 and e.beg_effective_dt_tm <= sysdate",
  " and e.end_effective_dt_tm >= sysdate")
 SET parser_rec->qual[10].statement =
 " and e.encntr_id+0 = epr.encntr_id and pp.person_id+0 = e.person_id"
 SET parser_rec->qual[11].statement = " union all "
 SET parser_rec->qual[12].statement = concat(
  " select distinct pp.person_id,0,ppr.prsnl_person_id,ppr.person_prsnl_r_cd",
  " ,pp.last_event_updt_dt_tm,1")
 SET parser_rec->qual[13].statement = " from person_prsnl_reltn ppr, person_patient pp"
 SET parser_rec->qual[14].statement = concat(
  " where ppr.active_ind = 1 and ppr.beg_effective_dt_tm <= sysdate",
  " and ppr.end_effective_dt_tm >= sysdate and pp.active_ind = 1")
 SET parser_rec->qual[15].statement = concat(
  " and pp.beg_effective_dt_tm <= sysdate and pp.end_effective_dt_tm >= sysdate",
  " and pp.person_id+0 = ppr.person_id")
 SET parser_rec->qual[16].statement = " union all "
 SET parser_rec->qual[17].statement = concat(
  " select distinct o.person_id, o.encntr_id, oa.order_provider_id,cv.code_value",
  " , pp.last_event_updt_dt_tm, 4")
 SET parser_rec->qual[18].statement =
 " from code_value cv, order_action oa, orders o, person_patient pp"
 SET parser_rec->qual[19].statement =
 " where cv.cdf_meaning = 'ORDERDOC' and cv.code_set = 333 and cv.active_ind = 1"
 SET parser_rec->qual[20].statement =
 " and oa.order_id = o.order_id and oa.action_rejected_ind = 0 and o.person_id = pp.person_id"
 SET parser_rec->qual[21].statement = concat(
  " and pp.active_ind = 1 and pp.beg_effective_dt_tm <= sysdate",
  " and pp.end_effective_dt_tm >= sysdate")
 SET parser_rec->qual[22].statement = " union all"
 SET parser_rec->qual[23].statement = concat(
  " select distinct o.person_id, o.encntr_id, od.oe_field_value, cv.code_value",
  " , pp.last_event_updt_dt_tm, 4")
 SET parser_rec->qual[24].statement =
 " from code_value cv, order_entry_fields oef, oe_format_fields oeff, orders o"
 SET parser_rec->qual[25].statement = " , order_action oa, order_detail od, person_patient pp"
 SET parser_rec->qual[26].statement =
 " where cv.cdf_meaning = 'CONSULTDOC' and cv.code_set = 333 and cv.active_ind = 1"
 SET parser_rec->qual[27].statement =
 " and oeff.oe_format_id = o.oe_format_id and oeff.oe_field_id = oef.oe_field_id"
 SET parser_rec->qual[28].statement =
 " and oef.oe_field_meaning_id = 2 and od.oe_field_id = oeff.oe_field_id"
 SET parser_rec->qual[29].statement =
 " and oa.action_rejected_ind = 0 and oa.action_sequence = od.action_sequence"
 SET parser_rec->qual[30].statement =
 " and oa.order_id = od.order_id and od.order_id = o.order_id and o.person_id = pp.person_id"
 SET parser_rec->qual[31].statement = concat(
  " and pp.active_ind = 1 and pp.beg_effective_dt_tm <= sysdate",
  " and pp.end_effective_dt_tm >= sysdate")
 SET parser_rec->qual[32].statement = " go"
 SET parser_rec->qual[33].statement = " oragen3 'chart_prsnl_reltn' go"
 SET x = 0
 FOR (x = 1 TO 33)
   CALL parser(parser_rec->qual[x].statement)
 ENDFOR
 FREE RECORD parser_rec3
 RECORD parser_rec3(
   1 qual[*]
     2 statement = vc
 )
 SET stat = alterlist(parser_rec3->qual,15)
 SET parser_rec3->qual[1].statement = "rdb create or replace view chart_prsnl_reltn2"
 SET parser_rec3->qual[2].statement =
 "( person_id, encntr_id, prsnl_person_id, chart_prsnl_r_type_cd) as"
 SET parser_rec3->qual[3].statement =
 "select distinct ppr.person_id, e.encntr_id, ppr.prsnl_person_id, ppr.person_prsnl_r_cd"
 SET parser_rec3->qual[4].statement =
 "from person_prsnl_reltn ppr,encounter e where ppr.active_ind = 1"
 SET parser_rec3->qual[5].statement =
 "and ppr.beg_effective_dt_tm <= sysdate and ppr.end_effective_dt_tm >= sysdate"
 SET parser_rec3->qual[6].statement = " and e.person_id = ppr.person_id"
 SET parser_rec3->qual[7].statement = "union all"
 SET parser_rec3->qual[8].statement =
 "select distinct e.person_id, epr.encntr_id, epr.prsnl_person_id, epr.encntr_prsnl_r_cd"
 SET parser_rec3->qual[9].statement = "from encntr_prsnl_reltn epr, encounter e"
 SET parser_rec3->qual[10].statement =
 "where epr.active_ind = 1 and epr.beg_effective_dt_tm <= sysdate"
 SET parser_rec3->qual[11].statement = "and epr.end_effective_dt_tm >= sysdate and e.active_ind = 1"
 SET parser_rec3->qual[12].statement =
 "and e.beg_effective_dt_tm <= sysdate and e.end_effective_dt_tm >= sysdate"
 SET parser_rec3->qual[13].statement = "and e.encntr_id = epr.encntr_id"
 SET parser_rec3->qual[14].statement = " go"
 SET parser_rec3->qual[15].statement = " oragen3 'chart_prsnl_reltn2' go"
 SET x = 0
 FOR (x = 1 TO 15)
   CALL parser(parser_rec3->qual[x].statement)
 ENDFOR
 FREE RECORD parser_rec4
 RECORD parser_rec4(
   1 qual[*]
     2 statement = vc
 )
 SET stat = alterlist(parser_rec4->qual,19)
 SET parser_rec4->qual[1].statement = "rdb create or replace view order_prsnl_reltn"
 SET parser_rec4->qual[2].statement =
 "(person_id, encntr_id, prsnl_person_id, chart_prsnl_r_type_cd) as"
 SET parser_rec4->qual[3].statement =
 "select distinct o.person_id, o.encntr_id, oa.order_provider_id, cv.code_value"
 SET parser_rec4->qual[4].statement = "from code_value cv, order_action oa, orders o"
 SET parser_rec4->qual[5].statement =
 "where cv.cdf_meaning = 'ORDERDOC' and cv.code_set = 333 and cv.active_ind = 1"
 SET parser_rec4->qual[6].statement = "and oa.order_id = o.order_id and oa.action_rejected_ind = 0"
 SET parser_rec4->qual[7].statement = "union all"
 SET parser_rec4->qual[8].statement =
 "select distinct o.person_id, o.encntr_id, od.oe_field_value, cv.code_value"
 SET parser_rec4->qual[9].statement =
 "from code_value cv, order_entry_fields oef, oe_format_fields oeff, order_action oa,"
 SET parser_rec4->qual[10].statement = "order_detail od, orders o"
 SET parser_rec4->qual[11].statement =
 "where cv.cdf_meaning = 'CONSULTDOC' and cv.code_set = 333 and cv.active_ind = 1"
 SET parser_rec4->qual[12].statement = "and oeff.oe_format_id = o.oe_format_id"
 SET parser_rec4->qual[13].statement = "and oeff.oe_field_id = oef.oe_field_id"
 SET parser_rec4->qual[14].statement = "and oef.oe_field_meaning_id = 2"
 SET parser_rec4->qual[15].statement = "and od.oe_field_id = oeff.oe_field_id"
 SET parser_rec4->qual[16].statement =
 "and oa.action_sequence = od.action_sequence and oa.order_id = od.order_id"
 SET parser_rec4->qual[17].statement = "and od.order_id = o.order_id"
 SET parser_rec4->qual[18].statement = "go"
 SET parser_rec4->qual[19].statement = " oragen3 'order_prsnl_reltn' go"
 SET x = 0
 FOR (x = 1 TO 19)
   CALL parser(parser_rec4->qual[x].statement)
 ENDFOR
 SET readme_data->message =
 "Oracles views created:  chart_prsnl_reltn, chart_prsnl_reltn2, order_prsnl_reltn"
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
END GO

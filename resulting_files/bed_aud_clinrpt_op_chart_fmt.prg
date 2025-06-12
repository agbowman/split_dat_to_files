CREATE PROGRAM bed_aud_clinrpt_op_chart_fmt
 DECLARE param_distid = i4 WITH constant(2)
 DECLARE param_chart_format = i4 WITH constant(4)
 DECLARE param_law = i4 WITH constant(18)
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 string_value = vc
  )
 ENDIF
 FREE RECORD operations
 RECORD operations(
   1 ops[*]
     2 operation_id = f8
     2 operation_name = vc
     2 chart_format_name = vc
     2 distribution_name = vc
     2 law_name = vc
 )
 SET ops_cnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM charting_operations co,
   chart_format cf
  PLAN (co
   WHERE co.active_ind=1
    AND co.param_type_flag=param_chart_format
    AND co.charting_operations_id > 0)
   JOIN (cf
   WHERE cf.chart_format_id=cnvtreal(co.param))
  ORDER BY co.batch_name_key
  DETAIL
   ops_cnt = (ops_cnt+ 1), stat = alterlist(operations->ops,ops_cnt), operations->ops[ops_cnt].
   operation_id = co.charting_operations_id,
   operations->ops[ops_cnt].operation_name = co.batch_name, operations->ops[ops_cnt].
   chart_format_name = cf.chart_format_desc
  WITH nocounter
 ;end select
 IF (ops_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_cnt),
    chart_distribution cd,
    charting_operations co
   PLAN (d)
    JOIN (co
    WHERE (co.charting_operations_id=operations->ops[d.seq].operation_id)
     AND co.param_type_flag=param_distid)
    JOIN (cd
    WHERE cd.distribution_id=cnvtreal(co.param)
     AND cd.active_ind=1)
   DETAIL
    operations->ops[d.seq].distribution_name = cd.dist_descr
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_cnt),
    chart_law cl,
    charting_operations co
   PLAN (d)
    JOIN (co
    WHERE (co.charting_operations_id=operations->ops[d.seq].operation_id)
     AND co.param_type_flag=param_law)
    JOIN (cl
    WHERE cl.law_id=cnvtreal(co.param)
     AND cl.active_ind=1)
   DETAIL
    operations->ops[d.seq].law_name = cl.law_descr
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Operation Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Chart Format"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Distribution Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Cross-Encounter Law Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (ops_cnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (o = 1 TO ops_cnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
   SET reply->rowlist[row_nbr].celllist[1].string_value = operations->ops[o].operation_name
   SET reply->rowlist[row_nbr].celllist[2].string_value = operations->ops[o].chart_format_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = operations->ops[o].distribution_name
   SET reply->rowlist[row_nbr].celllist[4].string_value = operations->ops[o].law_name
 ENDFOR
#exit_script
END GO

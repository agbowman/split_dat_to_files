CREATE PROGRAM bed_aud_ord_rel_results:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 orders[*]
      2 order_catalog_code_value = f8
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
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET ocnt = 0
 IF (validate(request->orders[1].order_catalog_code_value))
  SET ocnt = size(request->orders,5)
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT
   IF (ocnt > 0)
    FROM (dummyt d  WITH seq = value(ocnt)),
     catalog_event_sets c
    PLAN (c)
     JOIN (d
     WHERE (c.catalog_cd=request->orders[d.seq].order_catalog_code_value))
   ELSE
   ENDIF
   INTO "nl:"
   FROM catalog_event_sets c
   PLAN (c)
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1)
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE lastmnemonic = vc
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Orderable Item"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Related Result Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Related Results Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Sequence"
 SET reply->collist[4].data_type = 3
 SET reply->collist[4].hide_ind = 0
 SELECT
  IF (ocnt > 0)
   FROM (dummyt d  WITH seq = value(ocnt)),
    catalog_event_sets c,
    order_catalog o,
    v500_event_set_code e
   PLAN (c)
    JOIN (d
    WHERE (c.catalog_cd=request->orders[d.seq].order_catalog_code_value))
    JOIN (o
    WHERE o.catalog_cd=c.catalog_cd)
    JOIN (e
    WHERE e.event_set_name=c.event_set_name)
  ELSE
  ENDIF
  INTO "nl:"
  FROM catalog_event_sets c,
   order_catalog o,
   v500_event_set_code e
  PLAN (c)
   JOIN (o
   WHERE o.catalog_cd=c.catalog_cd)
   JOIN (e
   WHERE e.event_set_name=c.event_set_name)
  ORDER BY cnvtupper(o.primary_mnemonic), c.sequence
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
    celllist,4),
   reply->rowlist[cnt].celllist[1].string_value = o.primary_mnemonic, reply->rowlist[cnt].celllist[2]
   .string_value = e.event_set_cd_disp, reply->rowlist[cnt].celllist[3].string_value = e
   .event_set_cd_descr,
   reply->rowlist[cnt].celllist[4].nbr_value = c.sequence
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("related_results_orderables.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO

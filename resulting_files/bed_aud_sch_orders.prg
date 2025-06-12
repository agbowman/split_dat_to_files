CREATE PROGRAM bed_aud_sch_orders
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.active_ind=1
     AND oc.schedule_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Orderable Item"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Encounter Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET count = 0
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   dcp_entity_reltn der,
   code_value c
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.schedule_ind=1)
   JOIN (der
   WHERE der.entity1_id=outerjoin(oc.catalog_cd)
    AND der.entity_reltn_mean=outerjoin("ORC/SCHENCTP"))
   JOIN (c
   WHERE c.code_value=outerjoin(der.entity2_id))
  ORDER BY oc.description, c.display
  DETAIL
   count = (count+ 1), stat = alterlist(reply->rowlist,count), stat = alterlist(reply->rowlist[count]
    .celllist,2),
   reply->rowlist[count].celllist[1].string_value = oc.description
   IF (c.display > " ")
    reply->rowlist[count].celllist[2].string_value = c.display
   ELSE
    IF (der.dcp_entity_reltn_id=0)
     reply->rowlist[count].celllist[2].string_value = "None Defined"
    ELSEIF (der.entity2_id=0)
     reply->rowlist[count].celllist[2].string_value = "Future Visit"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("scheduling_orders.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO

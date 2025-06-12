CREATE PROGRAM bed_aud_fn_order_event_assn:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 tracking_group_code_value = f8
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
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 tracking_group = vc
     2 order_catalog = vc
     2 orderable = vc
     2 tracking_event = vc
     2 update_name = vc
 )
 IF ((request->tracking_group_code_value=0))
  GO TO exit_script
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM track_ord_event_reltn toer
   PLAN (toer
    WHERE toer.association_type_cd=0)
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
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM track_ord_event_reltn toer,
   track_event te,
   code_value cv1,
   code_value cv2,
   order_catalog oc,
   code_value cv3,
   person p
  PLAN (toer
   WHERE toer.association_type_cd=0
    AND (toer.track_group_cd=request->tracking_group_code_value))
   JOIN (te
   WHERE te.track_event_id=toer.track_event_id
    AND te.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=toer.track_group_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=toer.cat_or_cattype_cd
    AND cv2.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(cv2.code_value)
    AND oc.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(oc.catalog_type_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(toer.updt_id))
  ORDER BY cv1.display, cv2.code_set
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].tracking_group = cv1
   .display,
   temp->tqual[tcnt].tracking_event = te.display, temp->tqual[tcnt].update_name = p
   .name_full_formatted
   IF (cv2.code_set=6000)
    temp->tqual[tcnt].order_catalog = cv2.display, temp->tqual[tcnt].orderable =
    "linked at the catalog type"
   ELSEIF (cv2.code_set=200)
    temp->tqual[tcnt].order_catalog = cv3.display, temp->tqual[tcnt].orderable = cv2.display
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Tracking Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Catalog Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Tracking Event"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Last Update By"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].tracking_group
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].order_catalog
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].orderable
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].tracking_event
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].update_name
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("fn_order_event_association_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

CREATE PROGRAM bed_aud_sch_interactions
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
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Affecting Order (first)"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Order (second)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Duration Between Order and Affecting Order"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Last updated by "
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SELECT INTO "nl:"
  affecting_order_appt = sg3.description, order_appt = sg1.description, duration_between = sl
  .duration_units,
  units = sl.duration_units_meaning
  FROM sch_seq_list sl,
   sch_seq_group sg1,
   sch_seq_group sg2,
   sch_seq_list sl2,
   sch_seq_group sg3,
   prsnl p
  PLAN (sl
   WHERE sl.active_ind=1
    AND sl.duration_units > 0)
   JOIN (sg1
   WHERE sl.seq_group_id=sg1.seq_group_id
    AND sg1.active_ind=1)
   JOIN (sg2
   WHERE sl.child_seq_group_id=sg2.seq_group_id)
   JOIN (sl2
   WHERE sg2.seq_group_id=sl2.child_seq_group_id
    AND sl2.contain_ind=1)
   JOIN (sg3
   WHERE sl2.seq_group_id=sg3.seq_group_id)
   JOIN (p
   WHERE sl.updt_id=p.person_id)
  ORDER BY sg1.description, sl.duration_units DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,15)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,15)=0)
    stat = alterlist(reply->rowlist,(15+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].string_value =
   sg3.description, reply->rowlist[cnt].celllist[2].string_value = sg1.description
   CASE (sl.duration_units_meaning)
    OF "HOURS":
     reply->rowlist[cnt].celllist[3].string_value = concat(trim(cnvtstring(sl.duration_units)),
      " Hours")
    OF "DAYS":
     reply->rowlist[cnt].celllist[3].string_value = concat(trim(cnvtstring(sl.duration_units)),
      " Days")
    OF "WEEKS":
     reply->rowlist[cnt].celllist[3].string_value = concat(trim(cnvtstring(sl.duration_units)),
      " Weeks")
    ELSE
     reply->rowlist[cnt].celllist[3].string_value = sl.duration_units_meaning
   ENDCASE
   reply->rowlist[cnt].celllist[4].string_value = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
END GO

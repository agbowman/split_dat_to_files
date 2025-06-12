CREATE PROGRAM bhs_athn_order_history
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 FREE RECORD orequest
 RECORD orequest(
   1 order_id = f8
 )
 FREE RECORD out_rec
 RECORD out_rec(
   1 action_qual[*]
     2 action_sequence = vc
     2 action_type_cd = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_rejected_ind = vc
     2 communication_type_cd = vc
     2 order_type_disp = vc
     2 order_type_mean = vc
     2 order_provider_id = vc
     2 order_provider_name = vc
     2 order_dt_tm = vc
     2 order_tz = vc
     2 effective_dt_tm = vc
     2 effective_tz = vc
     2 contributor_system_cd = vc
     2 contributor_system_disp = vc
     2 contributor_system_mean = vc
     2 order_locn_cd = vc
     2 order_locn_disp = vc
     2 order_locn_mean = vc
     2 action_dt_tm = vc
     2 action_tz = vc
     2 action_personnel_id = vc
     2 action_personnel = vc
     2 order_status_cd = vc
     2 order_status_disp = vc
     2 order_status_mean = vc
     2 dept_status_cd = vc
     2 dept_status_disp = vc
     2 dept_status_mean = vc
     2 detail_qual[*]
       3 detail_sequence = vc
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = vc
       3 oe_field_tz = vc
       3 oe_field_id = vc
       3 oe_field_meaning = vc
       3 oe_field_meaning_id = vc
       3 oe_field_value = vc
     2 review_qual[*]
       3 review_sequence = vc
       3 review_type_flag = vc
       3 review_reqd_ind = vc
       3 provider_id = vc
       3 provider_name = vc
       3 location_cd = vc
       3 location_disp = vc
       3 location_mean = vc
       3 dept_cd = vc
       3 dept_disp = vc
       3 dept_mean = vc
       3 reviewed_status_flag = vc
       3 review_personnel_id = vc
       3 review_personnel = vc
       3 review_dt_tm = vc
       3 review_tz = vc
       3 proxy_personnel_id = vc
       3 proxy_personnel = vc
       3 proxy_reason_cd = vc
       3 proxy_reason_disp = vc
       3 proxy_reason_mean = vc
     2 comment_qual[*]
       3 comment_type_cd = vc
       3 comment_type_disp = vc
       3 comment_type_mean = vc
       3 comment_text = vc
 )
 SET orequest->order_id = cnvtreal( $2)
 SET stat = tdbexecute(560250,500195,500078,"REC",orequest,
  "REC",oreply)
 CALL echorecord(oreply)
 IF ((oreply->status_data.status != "S"))
  GO TO end_prog
 ENDIF
 SET stat = alterlist(out_rec->action_qual,size(oreply->action_qual,5))
 FOR (i = 1 TO size(oreply->action_qual,5))
   SET out_rec->action_qual[i].action_sequence = cnvtstring(oreply->action_qual[i].action_sequence)
   SET out_rec->action_qual[i].action_type_cd = cnvtstring(oreply->action_qual[i].action_type_cd)
   SET out_rec->action_qual[i].action_type_disp = oreply->action_qual[i].action_type_disp
   SET out_rec->action_qual[i].action_type_mean = oreply->action_qual[i].action_type_mean
   SET out_rec->action_qual[i].action_rejected_ind = cnvtstring(oreply->action_qual[i].
    action_rejected_ind)
   SET out_rec->action_qual[i].communication_type_cd = cnvtstring(oreply->action_qual[i].
    communication_type_cd)
   SET out_rec->action_qual[i].order_type_disp = oreply->action_qual[i].order_type_disp
   SET out_rec->action_qual[i].order_type_mean = oreply->action_qual[i].order_type_mean
   SET out_rec->action_qual[i].order_provider_id = cnvtstring(oreply->action_qual[i].
    order_provider_id)
   IF ((oreply->action_qual[i].order_provider_id > 0.0))
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=oreply->action_qual[i].order_provider_id))
     HEAD p.person_id
      out_rec->action_qual[i].order_provider_name = p.name_full_formatted
     WITH nocounter, time = 10
    ;end select
   ENDIF
   SET out_rec->action_qual[i].order_dt_tm = format(oreply->action_qual[i].order_dt_tm,
    "yyyy-MM-dd HH:mm:ss;;D")
   SET out_rec->action_qual[i].order_tz = cnvtstring(oreply->action_qual[i].order_tz)
   SET out_rec->action_qual[i].effective_dt_tm = format(oreply->action_qual[i].effective_dt_tm,
    "yyyy-MM-dd HH:mm:ss;;D")
   SET out_rec->action_qual[i].effective_tz = cnvtstring(oreply->action_qual[i].effective_tz)
   SET out_rec->action_qual[i].contributor_system_cd = cnvtstring(oreply->action_qual[i].
    contributor_system_cd)
   SET out_rec->action_qual[i].contributor_system_disp = oreply->action_qual[i].
   contributor_system_disp
   SET out_rec->action_qual[i].contributor_system_mean = oreply->action_qual[i].
   contributor_system_mean
   SET out_rec->action_qual[i].order_locn_cd = cnvtstring(oreply->action_qual[i].order_locn_cd)
   SET out_rec->action_qual[i].order_locn_disp = oreply->action_qual[i].order_locn_disp
   SET out_rec->action_qual[i].order_locn_mean = oreply->action_qual[i].order_locn_mean
   SET out_rec->action_qual[i].action_dt_tm = format(oreply->action_qual[i].action_dt_tm,
    "yyyy-MM-dd HH:mm:ss;;D")
   SET out_rec->action_qual[i].action_tz = cnvtstring(oreply->action_qual[i].action_tz)
   SET out_rec->action_qual[i].action_personnel_id = cnvtstring(oreply->action_qual[i].
    action_personnel_id)
   IF ((oreply->action_qual[i].action_personnel_id > 0.0))
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=oreply->action_qual[i].action_personnel_id))
     HEAD p.person_id
      out_rec->action_qual[i].action_personnel = p.name_full_formatted
     WITH nocounter, time = 10
    ;end select
   ENDIF
   IF ((oreply->action_qual[i].action_sequence > 0.0))
    SELECT INTO "nl:"
     FROM order_action oa
     PLAN (oa
      WHERE oa.order_id=cnvtreal( $2)
       AND (oa.action_sequence=oreply->action_qual[i].action_sequence)
       AND (oa.action_type_cd=oreply->action_qual[i].action_type_cd))
     HEAD oa.order_action_id
      out_rec->action_qual[i].order_status_cd = cnvtstring(oa.order_status_cd), out_rec->action_qual[
      i].order_status_disp = uar_get_code_display(oa.order_status_cd), out_rec->action_qual[i].
      order_status_mean = uar_get_code_meaning(oa.order_status_cd),
      out_rec->action_qual[i].dept_status_cd = cnvtstring(oa.dept_status_cd), out_rec->action_qual[i]
      .dept_status_disp = uar_get_code_display(oa.dept_status_cd), out_rec->action_qual[i].
      dept_status_mean = uar_get_code_meaning(oa.dept_status_cd)
     WITH nocounter, time = 10, maxrec = 1
    ;end select
   ENDIF
   IF ((oreply->action_qual[i].detail_qual_cnt > 0))
    SET stat = alterlist(out_rec->action_qual[i].detail_qual,oreply->action_qual[i].detail_qual_cnt)
    FOR (j = 0 TO oreply->action_qual[i].detail_qual_cnt)
      SET out_rec->action_qual[i].detail_qual[j].detail_sequence = cnvtstring(oreply->action_qual[i].
       detail_qual[j].detail_sequence)
      SET out_rec->action_qual[i].detail_qual[j].oe_field_display_value = oreply->action_qual[i].
      detail_qual[j].oe_field_display_value
      SET out_rec->action_qual[i].detail_qual[j].oe_field_dt_tm_value = format(oreply->action_qual[i]
       .detail_qual[j].oe_field_dt_tm_value,"yyyy-MM-dd HH:mm:ss;;D")
      SET out_rec->action_qual[i].detail_qual[j].oe_field_tz = cnvtstring(oreply->action_qual[i].
       detail_qual[j].oe_field_tz)
      SET out_rec->action_qual[i].detail_qual[j].oe_field_id = cnvtstring(oreply->action_qual[i].
       detail_qual[j].oe_field_id)
      SET out_rec->action_qual[i].detail_qual[j].oe_field_meaning = oreply->action_qual[i].
      detail_qual[j].oe_field_meaning
      SET out_rec->action_qual[i].detail_qual[j].oe_field_meaning_id = cnvtstring(oreply->
       action_qual[i].detail_qual[j].oe_field_meaning_id)
      SET out_rec->action_qual[i].detail_qual[j].oe_field_value = cnvtstring(oreply->action_qual[i].
       detail_qual[j].oe_field_value)
    ENDFOR
   ENDIF
   IF ((oreply->action_qual[i].review_qual_cnt > 0))
    SET stat = alterlist(out_rec->action_qual[i].review_qual,oreply->action_qual[i].review_qual_cnt)
    FOR (k = 0 TO oreply->action_qual[i].review_qual_cnt)
      SET out_rec->action_qual[i].review_qual[k].review_sequence = cnvtstring(oreply->action_qual[i].
       review_qual[k].review_sequence)
      IF ((oreply->action_qual[i].review_qual[k].review_type_flag=1))
       SET out_rec->action_qual[i].review_qual[k].review_type_flag = "Nurse Review"
      ELSEIF ((oreply->action_qual[i].review_qual[k].review_type_flag=2))
       SET out_rec->action_qual[i].review_qual[k].review_type_flag = "Doctor Cosign"
      ELSEIF ((oreply->action_qual[i].review_qual[k].review_type_flag=3))
       SET out_rec->action_qual[i].review_qual[k].review_type_flag = "Pharmacist Verify"
      ELSEIF ((oreply->action_qual[i].review_qual[k].review_type_flag=4))
       SET out_rec->action_qual[i].review_qual[k].review_type_flag = "Physician Activate"
      ELSE
       SET out_rec->action_qual[i].review_qual[k].review_type_flag = cnvtstring(oreply->action_qual[i
        ].review_qual[k].review_type_flag)
      ENDIF
      SET out_rec->action_qual[i].review_qual[k].review_reqd_ind = cnvtstring(oreply->action_qual[i].
       review_qual[k].review_reqd_ind)
      SET out_rec->action_qual[i].review_qual[k].provider_id = cnvtstring(oreply->action_qual[i].
       review_qual[k].provider_id)
      IF ((oreply->action_qual[i].review_qual[k].provider_id > 0.0))
       SELECT INTO "nl:"
        FROM prsnl p
        PLAN (p
         WHERE (p.person_id=oreply->action_qual[i].review_qual[k].provider_id))
        HEAD p.person_id
         out_rec->action_qual[i].review_qual[k].provider_name = p.name_full_formatted
        WITH nocounter, time = 10
       ;end select
      ENDIF
      SET out_rec->action_qual[i].review_qual[k].location_cd = cnvtstring(oreply->action_qual[i].
       review_qual[k].location_cd)
      SET out_rec->action_qual[i].review_qual[k].location_disp = oreply->action_qual[i].review_qual[k
      ].location_disp
      SET out_rec->action_qual[i].review_qual[k].location_mean = oreply->action_qual[i].review_qual[k
      ].location_mean
      SET out_rec->action_qual[i].review_qual[k].dept_cd = cnvtstring(oreply->action_qual[i].
       review_qual[k].dept_cd)
      SET out_rec->action_qual[i].review_qual[k].dept_disp = oreply->action_qual[i].review_qual[k].
      dept_disp
      SET out_rec->action_qual[i].review_qual[k].dept_mean = oreply->action_qual[i].review_qual[k].
      dept_mean
      IF ((oreply->action_qual[i].review_qual[k].reviewed_status_flag=0))
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = "Not Reviewed"
      ELSEIF ((oreply->action_qual[i].review_qual[k].reviewed_status_flag=1))
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = "Accepted"
      ELSEIF ((oreply->action_qual[i].review_qual[k].reviewed_status_flag=2))
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = "Rejected"
      ELSEIF ((oreply->action_qual[i].review_qual[k].reviewed_status_flag=3))
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = "No Longer Needing Review"
      ELSEIF ((oreply->action_qual[i].review_qual[k].reviewed_status_flag=4))
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = "Superceded"
      ELSEIF ((oreply->action_qual[i].review_qual[k].reviewed_status_flag=5))
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = "Reviewed"
      ELSE
       SET out_rec->action_qual[i].review_qual[k].reviewed_status_flag = cnvtstring(oreply->
        action_qual[i].review_qual[k].reviewed_status_flag)
      ENDIF
      SET out_rec->action_qual[i].review_qual[k].review_personnel_id = cnvtstring(oreply->
       action_qual[i].review_qual[k].review_personnel_id)
      IF ((oreply->action_qual[i].review_qual[k].review_personnel_id > 0.0))
       SELECT INTO "nl:"
        FROM prsnl p
        PLAN (p
         WHERE (p.person_id=oreply->action_qual[i].review_qual[k].review_personnel_id))
        HEAD p.person_id
         out_rec->action_qual[i].review_qual[k].review_personnel_id = p.name_full_formatted
        WITH nocounter, time = 10
       ;end select
      ENDIF
      SET out_rec->action_qual[i].review_qual[k].review_dt_tm = format(oreply->action_qual[i].
       review_qual[k].review_dt_tm,"yyyy-MM-dd HH:mm:ss;;D")
      SET out_rec->action_qual[i].review_qual[k].review_tz = cnvtstring(oreply->action_qual[i].
       review_qual[k].review_tz)
      SET out_rec->action_qual[i].review_qual[k].proxy_personnel_id = cnvtstring(oreply->action_qual[
       i].review_qual[k].proxy_personnel_id)
      IF ((oreply->action_qual[i].review_qual[k].proxy_personnel_id > 0.0))
       SELECT INTO "nl:"
        FROM prsnl p
        PLAN (p
         WHERE (p.person_id=oreply->action_qual[i].review_qual[k].proxy_personnel_id))
        HEAD p.person_id
         out_rec->action_qual[i].review_qual[k].proxy_personnel = p.name_full_formatted
        WITH nocounter, time = 10
       ;end select
      ENDIF
      SET out_rec->action_qual[i].review_qual[k].proxy_reason_cd = cnvtstring(oreply->action_qual[i].
       review_qual[k].proxy_reason_cd)
      SET out_rec->action_qual[i].review_qual[k].proxy_reason_disp = oreply->action_qual[i].
      review_qual[k].proxy_reason_disp
      SET out_rec->action_qual[i].review_qual[k].proxy_reason_mean = oreply->action_qual[i].
      review_qual[k].proxy_reason_mean
    ENDFOR
   ENDIF
   IF ((oreply->action_qual[i].comment_qual_cnt > 0))
    SET stat = alterlist(out_rec->action_qual[i].comment_qual,oreply->action_qual[i].comment_qual_cnt
     )
    FOR (l = 0 TO oreply->action_qual[i].comment_qual_cnt)
      SET out_rec->action_qual[i].comment_qual[l].comment_type_cd = cnvtstring(oreply->action_qual[i]
       .comment_qual[l].comment_type_cd)
      SET out_rec->action_qual[i].comment_qual[l].comment_type_disp = oreply->action_qual[i].
      comment_qual[l].comment_type_disp
      SET out_rec->action_qual[i].comment_qual[l].comment_type_mean = oreply->action_qual[i].
      comment_qual[l].comment_type_mean
      SET out_rec->action_qual[i].comment_qual[l].comment_text = oreply->action_qual[i].comment_qual[
      l].comment_text
    ENDFOR
   ENDIF
 ENDFOR
#end_prog
 CALL echorecord(out_rec)
 EXECUTE bhs_athn_write_json_output
END GO

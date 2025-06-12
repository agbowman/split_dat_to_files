CREATE PROGRAM bed_aud_reg_code_sets
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
  )
 ENDIF
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM pm_flx_conversation pc,
    pm_flx_prompt pf
   PLAN (pc
    WHERE pc.active_ind=1)
    JOIN (pf
    WHERE pf.parent_entity_id=pc.conversation_id
     AND pf.codeset != null
     AND  NOT (pf.codeset IN (0, 220, 333)))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Code Set"
 SET reply->collist[1].data_type = 3
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Code Set Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Code Value Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Last Updated By"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Last Updated Date and Time"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SELECT DISTINCT INTO "nl:"
  cv.code_set, cs.display, cv.display,
  p.name_full_formatted, cv.updt_dt_tm
  FROM pm_flx_conversation pc,
   pm_flx_prompt pf,
   code_value cv,
   code_value_set cs,
   person p
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pf
   WHERE pf.parent_entity_id=pc.conversation_id
    AND pf.codeset != null
    AND  NOT (pf.codeset IN (0, 220, 333)))
   JOIN (cv
   WHERE cv.code_set=pf.codeset
    AND cv.active_ind=1)
   JOIN (cs
   WHERE cv.code_set=cs.code_set)
   JOIN (p
   WHERE p.person_id=outerjoin(cv.updt_id))
  ORDER BY cv.code_set, cv.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,100)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(reply->rowlist,(100+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].nbr_value = cv
   .code_set, reply->rowlist[cnt].celllist[2].string_value = cs.display,
   reply->rowlist[cnt].celllist[3].string_value = cv.display, reply->rowlist[cnt].celllist[4].
   string_value = p.name_full_formatted, reply->rowlist[cnt].celllist[5].string_value = format(cv
    .updt_dt_tm,";;Q")
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("erm_code_sets.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

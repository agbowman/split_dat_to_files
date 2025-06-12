CREATE PROGRAM bed_aud_user_wizard_assn:dba
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
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 name = vc
     2 username = vc
     2 solution = vc
     2 wizard = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM br_name_value b,
    prsnl p,
    br_client_sol_step ss,
    br_client_item_reltn cir1,
    br_client_item_reltn cir2
   PLAN (b
    WHERE b.br_nv_key1="WIZARDSECURITY")
    JOIN (p
    WHERE p.person_id=cnvtreal(b.br_name)
     AND p.active_ind=1)
    JOIN (ss
    WHERE ss.step_mean=b.br_value)
    JOIN (cir1
    WHERE cir1.item_type="STEP"
     AND cir1.item_mean=b.br_value)
    JOIN (cir2
    WHERE cir2.item_type="SOLUTION"
     AND cir2.item_mean=ss.solution_mean)
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
  FROM br_name_value b,
   prsnl p,
   br_client_sol_step ss,
   br_client_item_reltn cir1,
   br_client_item_reltn cir2
  PLAN (b
   WHERE b.br_nv_key1="WIZARDSECURITY")
   JOIN (p
   WHERE p.person_id=cnvtreal(b.br_name)
    AND p.active_ind=1)
   JOIN (ss
   WHERE ss.step_mean=b.br_value)
   JOIN (cir1
   WHERE cir1.item_type="STEP"
    AND cir1.item_mean=b.br_value)
   JOIN (cir2
   WHERE cir2.item_type="SOLUTION"
    AND cir2.item_mean=ss.solution_mean)
  ORDER BY p.name_full_formatted, cir2.item_display, cir1.item_display
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].name = p.name_full_formatted, temp->tqual[tcnt].username = p.username, temp->
   tqual[tcnt].solution = cir2.item_display,
   temp->tqual[tcnt].wizard = cir1.item_display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Name Full Formatted"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Username"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Solution Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Wizard Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].username
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].solution
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].wizard
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("user_wizard_assn.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

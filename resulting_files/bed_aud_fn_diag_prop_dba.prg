CREATE PROGRAM bed_aud_fn_diag_prop:dba
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
   1 xlist[*]
     2 comp_name_unq = vc
     2 tracking_group_cd = f8
     2 folder = vc
     2 updt_name = vc
     2 default_ind = i2
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM nomen_category nc
   PLAN (nc
    WHERE nc.parent_entity_name="GENERAL")
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
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Tracking Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Diagnosis Folder"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Last Update By"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET row_nbr = 0
 SET xcnt = 0
 SELECT INTO "nl:"
  FROM nomen_category nc,
   code_value cv1,
   track_prefs tp,
   code_value cv2,
   person p
  PLAN (nc
   WHERE nc.parent_entity_name="GENERAL")
   JOIN (cv1
   WHERE cv1.code_value=nc.category_type_cd
    AND cv1.cdf_meaning="DIAGNOSIS")
   JOIN (tp
   WHERE tp.comp_pref=trim(cnvtstring(nc.nomen_category_id),3))
   JOIN (cv2
   WHERE cv2.code_value=tp.comp_type_cd)
   JOIN (p
   WHERE p.person_id=outerjoin(tp.updt_id))
  HEAD REPORT
   xcnt = 0
  DETAIL
   xcnt = (xcnt+ 1), stat = alterlist(temp->xlist,xcnt), temp->xlist[xcnt].comp_name_unq = tp
   .comp_name_unq,
   temp->xlist[xcnt].tracking_group_cd = cnvtreal(substring((findstring(";",tp.comp_name_unq,1,1)+ 1),
     15,tp.comp_name_unq)), temp->xlist[xcnt].folder = nc.category_name, temp->xlist[xcnt].updt_name
    = p.name_full_formatted
   IF (cv2.code_value > 0
    AND cv2.display > " ")
    temp->xlist[xcnt].default_ind = 1
   ELSE
    temp->xlist[xcnt].default_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (xcnt=0)
  GO TO exit_script
 ENDIF
 CALL echorecord(temp)
 SELECT INTO "nl:"
  folder = cnvtupper(temp->xlist[d.seq].folder)
  FROM (dummyt d  WITH seq = xcnt),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=temp->xlist[d.seq].tracking_group_cd))
  ORDER BY cv.display_key, folder
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,3),
   reply->rowlist[row_nbr].celllist[1].string_value = cv.display, reply->rowlist[row_nbr].celllist[2]
   .string_value = temp->xlist[d.seq].folder, reply->rowlist[row_nbr].celllist[3].string_value = temp
   ->xlist[d.seq].updt_name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_diag_prop_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

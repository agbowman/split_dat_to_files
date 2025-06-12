CREATE PROGRAM bed_aud_bb_work_rtg:dba
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
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 dept_display_name = vc
     2 resource_route_lvl = i2
     2 r_cnt = i4
     2 rlist[*]
       3 service_resource_cd = f8
       3 service_resource_disp = vc
       3 sequence = i4
       3 primary_ind = i2
       3 instr_bench_status = vc
 )
 DECLARE genlab = f8 WITH public, noconstant(0.0)
 DECLARE bb_cd = f8 WITH protect, noconstant(0.0)
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   genlab = cv.code_value
  WITH nocounter
 ;end select
 SET bb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="BB"
    AND cv.active_ind=1)
  DETAIL
   bb_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=genlab
     AND oc.activity_type_cd=bb_cd
     AND oc.active_ind=1)
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
 SET temp->o_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog o,
   code_value cv1,
   code_value cv2,
   orc_resource_list r
  PLAN (o
   WHERE o.catalog_type_cd=genlab
    AND o.activity_type_cd=bb_cd
    AND o.active_ind=1
    AND o.orderable_type_flag != 6
    AND o.orderable_type_flag != 2
    AND o.bill_only_ind IN (0, null))
   JOIN (cv1
   WHERE cv1.code_value=o.activity_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_subtype_cd)
   JOIN (r
   WHERE r.catalog_cd=outerjoin(o.catalog_cd))
  ORDER BY cv1.display_key, cnvtupper(o.primary_mnemonic), r.sequence
  HEAD REPORT
   o_cnt = 0, r_cnt = 0
  HEAD o.catalog_cd
   r_cnt = 0, o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt,
   stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[
   o_cnt].primary_mnemonic = o.primary_mnemonic,
   temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp =
   cv1.display, temp->olist[o_cnt].dept_display_name = o.dept_display_name
   IF (o.activity_subtype_cd > 0)
    temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd, temp->olist[o_cnt].
    activity_subtype_disp = cv2.display
   ENDIF
   temp->olist[o_cnt].resource_route_lvl = o.resource_route_lvl
  DETAIL
   IF (o.resource_route_lvl != 2)
    r_cnt = (r_cnt+ 1), temp->olist[o_cnt].r_cnt = r_cnt, stat = alterlist(temp->olist[o_cnt].rlist,
     r_cnt),
    temp->olist[o_cnt].rlist[r_cnt].service_resource_cd = r.service_resource_cd, temp->olist[o_cnt].
    rlist[r_cnt].sequence = r.sequence
    IF (r.primary_ind=1)
     temp->olist[o_cnt].rlist[r_cnt].primary_ind = 1
    ENDIF
    IF (r.active_ind=0)
     temp->olist[o_cnt].rlist[r_cnt].instr_bench_status = "Inactive Relation"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Instrument/Bench"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Sequence"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Default"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Department Name (Label Display)"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Subactivity Type"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "catalog_cd"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 1
 SET reply->collist[9].header_text = "service_resource_cd"
 SET reply->collist[9].data_type = 2
 SET reply->collist[9].hide_ind = 1
 SET reply->collist[10].header_text = "Instrument/Bench Status"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO temp->o_cnt)
   IF ((temp->olist[x].r_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = temp->olist[x].r_cnt),
      code_value cv
     PLAN (d
      WHERE (temp->olist[x].rlist[d.seq].service_resource_cd > 0))
      JOIN (cv
      WHERE (cv.code_value=temp->olist[x].rlist[d.seq].service_resource_cd))
     ORDER BY d.seq
     HEAD d.seq
      temp->olist[x].rlist[d.seq].service_resource_disp = trim(cv.display)
      IF ((temp->olist[x].rlist[d.seq].instr_bench_status=" "))
       IF (cv.active_ind=0)
        temp->olist[x].rlist[d.seq].instr_bench_status = "Inactive"
       ELSE
        temp->olist[x].rlist[d.seq].instr_bench_status = "Active"
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (x = 1 TO temp->o_cnt)
   IF ((temp->olist[x].r_cnt=0))
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[x].activity_type_disp
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->olist[x].primary_mnemonic
    SET reply->rowlist[row_nbr].celllist[6].string_value = temp->olist[x].dept_display_name
    SET reply->rowlist[row_nbr].celllist[7].string_value = temp->olist[x].activity_subtype_disp
    SET reply->rowlist[row_nbr].celllist[8].double_value = temp->olist[x].catalog_cd
    IF ((temp->olist[x].resource_route_lvl=2))
     SET reply->rowlist[row_nbr].celllist[3].string_value = "Assay Level"
    ENDIF
   ELSE
    FOR (y = 1 TO temp->olist[x].r_cnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[x].activity_type_disp
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->olist[x].primary_mnemonic
      SET reply->rowlist[row_nbr].celllist[6].string_value = temp->olist[x].dept_display_name
      SET reply->rowlist[row_nbr].celllist[7].string_value = temp->olist[x].activity_subtype_disp
      SET reply->rowlist[row_nbr].celllist[8].double_value = temp->olist[x].catalog_cd
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->olist[x].rlist[y].
      service_resource_disp
      SET reply->rowlist[row_nbr].celllist[4].string_value = cnvtstring(temp->olist[x].rlist[y].
       sequence)
      IF ((temp->olist[x].rlist[y].primary_ind=1))
       SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
      ELSE
       SET reply->rowlist[row_nbr].celllist[5].string_value = " "
      ENDIF
      SET reply->rowlist[row_nbr].celllist[9].double_value = temp->olist[x].rlist[y].
      service_resource_cd
      SET reply->rowlist[row_nbr].celllist[10].string_value = temp->olist[x].rlist[y].
      instr_bench_status
      IF ((reply->rowlist[row_nbr].celllist[3].string_value=" "))
       SET reply->rowlist[row_nbr].celllist[4].string_value = " "
       SET reply->rowlist[row_nbr].celllist[10].string_value = " "
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_work_rtg_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

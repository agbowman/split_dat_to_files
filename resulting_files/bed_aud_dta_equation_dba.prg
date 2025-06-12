CREATE PROGRAM bed_aud_dta_equation:dba
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
 RECORD temph(
   1 dlist[*]
     2 task_assay_cd = f8
 )
 RECORD temp(
   1 dlist[*]
     2 subactivity_type_cd = f8
     2 subactivity_type_disp = vc
     2 task_assay_cd = f8
     2 dtaname = vc
     2 dtadesc = vc
     2 elist[*]
       3 service_resource_cd = f8
       3 service_resource = vc
       3 mult_equation_ind = i2
       3 default_ind = i2
 )
 DECLARE glb_disp = vc
 SET glb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=106
    AND c.cdf_meaning="GLB"
    AND c.active_ind=1)
  DETAIL
   glb_cd = c.code_value, glb_disp = c.display
  WITH nocounter
 ;end select
 SET calc_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=289
    AND c.cdf_meaning="8"
    AND c.active_ind=1)
  DETAIL
   calc_cd = c.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE dta.activity_type_cd=glb_cd
     AND dta.active_ind=1)
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
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   assay_processing_r apr
  PLAN (dta
   WHERE dta.active_ind=1
    AND dta.activity_type_cd=glb_cd)
   JOIN (apr
   WHERE apr.task_assay_cd=dta.task_assay_cd
    AND apr.default_result_type_cd=calc_cd
    AND apr.active_ind=1)
  HEAD REPORT
   dcnt = 0
  HEAD dta.task_assay_cd
   dcnt = (dcnt+ 1), stat = alterlist(temph->dlist,dcnt), temph->dlist[dcnt].task_assay_cd = dta
   .task_assay_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   assay_processing_r apr
  PLAN (dta
   WHERE dta.active_ind=1
    AND dta.activity_type_cd=glb_cd
    AND dta.default_result_type_cd=calc_cd)
   JOIN (apr
   WHERE apr.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND apr.active_ind=outerjoin(1))
  HEAD dta.task_assay_cd
   IF (apr.task_assay_cd=0)
    dcnt = (dcnt+ 1), stat = alterlist(temph->dlist,dcnt), temph->dlist[dcnt].task_assay_cd = dta
    .task_assay_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (dcnt=0)
  GO TO skip_processing
 ENDIF
 SET totdcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = dcnt),
   code_value cvdta,
   profile_task_r ptr,
   order_catalog oc,
   code_value cvasc
  PLAN (d)
   JOIN (cvdta
   WHERE (cvdta.code_value=temph->dlist[d.seq].task_assay_cd))
   JOIN (ptr
   WHERE ptr.task_assay_cd=cvdta.code_value)
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1)
   JOIN (cvasc
   WHERE cvasc.code_value=outerjoin(oc.activity_subtype_cd))
  ORDER BY cvdta.code_value
  HEAD REPORT
   totdcnt = 0
  HEAD cvdta.code_value
   totdcnt = (totdcnt+ 1), stat = alterlist(temp->dlist,totdcnt), temp->dlist[totdcnt].task_assay_cd
    = cvdta.code_value,
   temp->dlist[totdcnt].dtaname = cvdta.display, temp->dlist[totdcnt].dtadesc = cvdta.description
   IF (oc.activity_subtype_cd > 0.0)
    temp->dlist[totdcnt].subactivity_type_cd = oc.activity_subtype_cd, temp->dlist[totdcnt].
    subactivity_type_disp = cvasc.display
   ELSE
    temp->dlist[totdcnt].subactivity_type_cd = 0.0, temp->dlist[totdcnt].subactivity_type_disp = " "
   ENDIF
  WITH nocounter
 ;end select
#skip_processing
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Subactivity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Equation Defined"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Instrument/Bench"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Multiple Equations"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Default Equation"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 IF (totdcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = totdcnt),
   equation e,
   code_value cvsr
  PLAN (d)
   JOIN (e
   WHERE (e.task_assay_cd=temp->dlist[d.seq].task_assay_cd)
    AND e.active_ind=1)
   JOIN (cvsr
   WHERE cvsr.code_value=e.service_resource_cd)
  ORDER BY d.seq, e.service_resource_cd
  HEAD d.seq
   ecnt = 0
  HEAD e.service_resource_cd
   ecnt = (ecnt+ 1), stat = alterlist(temp->dlist[d.seq].elist,ecnt)
   IF (e.service_resource_cd > 0)
    temp->dlist[d.seq].elist[ecnt].service_resource_cd = e.service_resource_cd, temp->dlist[d.seq].
    elist[ecnt].service_resource = cvsr.display
   ELSE
    temp->dlist[d.seq].elist[ecnt].service_resource_cd = 0.0, temp->dlist[d.seq].elist[ecnt].
    service_resource = "All"
   ENDIF
   eqcnt = 0
  DETAIL
   IF (e.default_ind=1)
    temp->dlist[d.seq].elist[ecnt].default_ind = 1
   ENDIF
   eqcnt = (eqcnt+ 1)
  FOOT  e.service_resource_cd
   IF (eqcnt > 1)
    temp->dlist[d.seq].elist[ecnt].mult_equation_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = totdcnt)
  ORDER BY temp->dlist[d.seq].subactivity_type_disp, temp->dlist[d.seq].dtaname
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,6),
   reply->rowlist[row_nbr].celllist[1].string_value = temp->dlist[d.seq].subactivity_type_disp, reply
   ->rowlist[row_nbr].celllist[2].string_value = temp->dlist[d.seq].dtaname, eqcnt = size(temp->
    dlist[d.seq].elist,5)
   IF (eqcnt > 0)
    IF ((temp->dlist[d.seq].elist[1].service_resource > " "))
     reply->rowlist[row_nbr].celllist[3].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = "Not Defined"
    ENDIF
    reply->rowlist[row_nbr].celllist[4].string_value = temp->dlist[d.seq].elist[1].service_resource
    IF ((temp->dlist[d.seq].elist[1].mult_equation_ind=1))
     reply->rowlist[row_nbr].celllist[5].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[5].string_value = " "
    ENDIF
    IF ((temp->dlist[d.seq].elist[1].default_ind=1))
     reply->rowlist[row_nbr].celllist[6].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[6].string_value = " "
    ENDIF
    IF (eqcnt > 1)
     FOR (i = 2 TO eqcnt)
       row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
        rowlist[row_nbr].celllist,6),
       reply->rowlist[row_nbr].celllist[1].string_value = temp->dlist[d.seq].subactivity_type_disp,
       reply->rowlist[row_nbr].celllist[2].string_value = temp->dlist[d.seq].dtaname
       IF ((temp->dlist[d.seq].elist[i].service_resource > " "))
        reply->rowlist[row_nbr].celllist[3].string_value = "X"
       ELSE
        reply->rowlist[row_nbr].celllist[3].string_value = "Not Defined"
       ENDIF
       reply->rowlist[row_nbr].celllist[4].string_value = temp->dlist[d.seq].elist[i].
       service_resource
       IF ((temp->dlist[d.seq].elist[i].mult_equation_ind=1))
        reply->rowlist[row_nbr].celllist[5].string_value = "X"
       ELSE
        reply->rowlist[row_nbr].celllist[5].string_value = " "
       ENDIF
       IF ((temp->dlist[d.seq].elist[i].default_ind=1))
        reply->rowlist[row_nbr].celllist[6].string_value = "X"
       ELSE
        reply->rowlist[row_nbr].celllist[6].string_value = " "
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    reply->rowlist[row_nbr].celllist[3].string_value = "Not Defined"
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("dta_equation_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

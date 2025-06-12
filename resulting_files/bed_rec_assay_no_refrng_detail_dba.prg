CREATE PROGRAM bed_rec_assay_no_refrng_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 assays[*]
     2 display = vc
     2 desc = vc
     2 result_type = vc
     2 rrf_exists_ind = i2
 )
 SET reply->run_status_flag = 1
 DECLARE glb_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glb_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE alpha_cd = f8 WITH public, noconstant(0.0)
 DECLARE numeric_cd = f8 WITH public, noconstant(0.0)
 DECLARE calc_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning IN ("2", "3", "8")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="2")
    alpha_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="3")
    numeric_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="8")
    calc_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET col_cnt = 3
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Assay Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Result Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="GLASSAYSWITHOUTREFRNGE"))
    SET tcnt = 0
    SELECT INTO "NL:"
     FROM discrete_task_assay dta,
      code_value cv,
      code_value cv1,
      profile_task_r ptr,
      order_catalog oc,
      reference_range_factor rrf,
      dummyt d
     PLAN (dta
      WHERE dta.activity_type_cd=glb_cd
       AND dta.default_result_type_cd IN (alpha_cd, numeric_cd, calc_cd)
       AND dta.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=dta.task_assay_cd
       AND cv.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=dta.default_result_type_cd
       AND cv1.active_ind=1)
      JOIN (ptr
      WHERE ptr.task_assay_cd=dta.task_assay_cd
       AND ptr.active_ind=1)
      JOIN (oc
      WHERE oc.catalog_cd=ptr.catalog_cd
       AND oc.active_ind=1)
      JOIN (d)
      JOIN (rrf
      WHERE rrf.task_assay_cd=dta.task_assay_cd
       AND rrf.active_ind=1)
     ORDER BY cv.display
     HEAD dta.task_assay_cd
      tcnt = (tcnt+ 1), stat = alterlist(temp->assays,tcnt), temp->assays[tcnt].display = cv.display,
      temp->assays[tcnt].desc = dta.description, temp->assays[tcnt].result_type = cv1.display
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
 ENDFOR
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,col_cnt)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->assays[x].display
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->assays[x].desc
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->assays[x].result_type
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

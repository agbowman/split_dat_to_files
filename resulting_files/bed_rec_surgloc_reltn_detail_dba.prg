CREATE PROGRAM bed_rec_surgloc_reltn_detail:dba
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
 DECLARE inst_cd = f8
 DECLARE dept_cd = f8
 DECLARE surg_cd = f8
 DECLARE stage_cd = f8
 DECLARE op_cd = f8
 SET inst_cd = uar_get_code_by("MEANING",223,"INSTITUTION")
 SET dept_cd = uar_get_code_by("MEANING",223,"DEPARTMENT")
 SET surg_cd = uar_get_code_by("MEANING",223,"SURGAREA")
 SET stage_cd = uar_get_code_by("MEANING",223,"SURGSTAGE")
 SET op_cd = uar_get_code_by("MEANING",223,"SURGOP")
 SET col_cnt = 8
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Facility Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Department Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Surgical Area Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Staging Area Display"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Surgical Operating Room Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Inactive Surgical Area"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Inactive Staging Area"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Inactive Surgical Operating Room"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="INACTSURGLOCACTRELN"))
    SET rcnt = 0
    SET totcnt = 0
    SELECT INTO "nl:"
     FROM resource_group rg1,
      code_value cv1,
      resource_group rg2,
      code_value cv2,
      resource_group rg3,
      code_value cv3,
      resource_group rg4,
      code_value cv4,
      dummyt d,
      service_resource sr,
      code_value cv5
     PLAN (rg1
      WHERE rg1.resource_group_type_cd=inst_cd
       AND rg1.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=rg1.parent_service_resource_cd
       AND cv1.active_ind=1)
      JOIN (rg2
      WHERE rg2.parent_service_resource_cd=rg1.child_service_resource_cd
       AND rg2.resource_group_type_cd=dept_cd)
      JOIN (cv2
      WHERE cv2.code_value=rg2.parent_service_resource_cd)
      JOIN (rg3
      WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
       AND rg3.resource_group_type_cd=surg_cd)
      JOIN (cv3
      WHERE cv3.code_value=rg3.parent_service_resource_cd)
      JOIN (rg4
      WHERE rg4.parent_service_resource_cd=rg3.child_service_resource_cd
       AND rg4.resource_group_type_cd=stage_cd)
      JOIN (cv4
      WHERE cv4.code_value=rg4.parent_service_resource_cd)
      JOIN (d)
      JOIN (sr
      WHERE sr.service_resource_cd=rg4.child_service_resource_cd
       AND sr.service_resource_type_cd=op_cd)
      JOIN (cv5
      WHERE cv5.code_value=sr.service_resource_cd)
     DETAIL
      totcnt = (totcnt+ 1)
      IF (((cv3.active_ind=0
       AND ((rg2.active_ind=1) OR (rg3.active_ind=1)) ) OR (((cv4.active_ind=0
       AND ((rg3.active_ind=1) OR (rg4.active_ind=1)) ) OR (cv5.active_ind=0
       AND rg4.active_ind=1)) )) )
       rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt]
        .celllist,col_cnt),
       reply->rowlist[rcnt].celllist[1].string_value = cv1.display, reply->rowlist[rcnt].celllist[2].
       string_value = cv2.display, reply->rowlist[rcnt].celllist[3].string_value = cv3.display,
       reply->rowlist[rcnt].celllist[4].string_value = cv4.display, reply->rowlist[rcnt].celllist[5].
       string_value = cv5.display
       IF (cv3.active_ind=0
        AND ((rg2.active_ind=1) OR (rg3.active_ind=1)) )
        reply->rowlist[rcnt].celllist[6].string_value = "X"
       ENDIF
       IF (cv4.active_ind=0
        AND ((rg3.active_ind=1) OR (rg4.active_ind=1)) )
        reply->rowlist[rcnt].celllist[7].string_value = "X"
       ENDIF
       IF (cv5.active_ind=0
        AND rg4.active_ind=1)
        reply->rowlist[rcnt].celllist[8].string_value = "X"
       ENDIF
      ENDIF
     WITH nocounter, outerjoin = d
    ;end select
   ENDIF
 ENDFOR
#exit_script
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO

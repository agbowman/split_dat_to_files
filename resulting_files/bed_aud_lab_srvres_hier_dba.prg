CREATE PROGRAM bed_aud_lab_srvres_hier:dba
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
   1 client = vc
   1 user = vc
   1 i_cnt = i2
   1 ilist[*]
     2 inst_cd = f8
     2 inst_disp = vc
     2 inst_desc = vc
     2 d_cnt = i2
     2 dlist[*]
       3 dept_cd = f8
       3 dept_disp = vc
       3 dept_desc = vc
       3 s_cnt = i2
       3 slist[*]
         4 sect_cd = f8
         4 sect_disp = vc
         4 sect_desc = vc
         4 ss_cnt = i2
         4 sslist[*]
           5 subsect_cd = f8
           5 subsect_disp = vc
           5 subsect_desc = vc
           5 r_cnt = i2
           5 rlist[*]
             6 res_cd = f8
             6 res_disp = vc
             6 res_desc = vc
 )
 DECLARE institution = f8 WITH public, noconstant(0.0)
 DECLARE instrument = f8 WITH public, noconstant(0.0)
 DECLARE bench = f8 WITH public, noconstant(0.0)
 DECLARE lab_discipline_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTITUTION"
    AND cv.active_ind=1)
  DETAIL
   institution = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="BENCH"
    AND cv.active_ind=1)
  DETAIL
   bench = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTRUMENT"
    AND cv.active_ind=1)
  DETAIL
   instrument = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   lab_discipline_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_prsnl bp
  PLAN (bp
   WHERE (bp.br_prsnl_id=reqinfo->updt_id))
  DETAIL
   temp->user = bp.name_full_formatted
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM service_resource sr
   PLAN (sr
    WHERE sr.service_resource_type_cd=institution
     AND sr.active_ind=1)
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
 SELECT DISTINCT INTO "nl:"
  FROM service_resource sr,
   code_value cv
  PLAN (sr
   WHERE sr.service_resource_type_cd=institution
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd)
  ORDER BY cv.display_key
  HEAD REPORT
   i_cnt = 0
  HEAD sr.service_resource_cd
   i_cnt = (i_cnt+ 1), temp->i_cnt = i_cnt, stat = alterlist(temp->ilist,i_cnt),
   temp->ilist[i_cnt].inst_cd = sr.service_resource_cd, temp->ilist[i_cnt].inst_disp = trim(cv
    .display), temp->ilist[i_cnt].inst_desc = trim(cv.description)
  WITH nocounter
 ;end select
 FOR (y = 1 TO temp->i_cnt)
   SET d_cnt = 0
   SELECT INTO "nl:"
    FROM resource_group rg,
     service_resource sr,
     code_value cv
    PLAN (rg
     WHERE (rg.parent_service_resource_cd=temp->ilist[y].inst_cd)
      AND rg.active_ind=1)
     JOIN (sr
     WHERE sr.service_resource_cd=rg.child_service_resource_cd
      AND sr.discipline_type_cd=lab_discipline_cd)
     JOIN (cv
     WHERE cv.code_value=rg.child_service_resource_cd)
    ORDER BY rg.sequence
    HEAD REPORT
     d_cnt = 0
    DETAIL
     d_cnt = (d_cnt+ 1), temp->ilist[y].d_cnt = d_cnt, stat = alterlist(temp->ilist[y].dlist,d_cnt),
     temp->ilist[y].dlist[d_cnt].dept_cd = rg.child_service_resource_cd, temp->ilist[y].dlist[d_cnt].
     dept_desc = trim(cv.description), temp->ilist[y].dlist[d_cnt].dept_disp = trim(cv.display)
    WITH nocounter
   ;end select
   FOR (z = 1 TO temp->ilist[y].d_cnt)
     SET s_cnt = 0
     SELECT INTO "nl:"
      FROM resource_group rg,
       code_value cv
      PLAN (rg
       WHERE (rg.parent_service_resource_cd=temp->ilist[y].dlist[z].dept_cd)
        AND rg.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=rg.child_service_resource_cd)
      ORDER BY rg.sequence
      HEAD REPORT
       s_cnt = 0
      DETAIL
       s_cnt = (s_cnt+ 1), temp->ilist[y].dlist[z].s_cnt = s_cnt, stat = alterlist(temp->ilist[y].
        dlist[z].slist,s_cnt),
       temp->ilist[y].dlist[z].slist[s_cnt].sect_cd = rg.child_service_resource_cd, temp->ilist[y].
       dlist[z].slist[s_cnt].sect_desc = trim(cv.description), temp->ilist[y].dlist[z].slist[s_cnt].
       sect_disp = trim(cv.display)
      WITH nocounter
     ;end select
     FOR (w = 1 TO temp->ilist[y].dlist[z].s_cnt)
       SET ss_cnt = 0
       SELECT INTO "nl:"
        FROM resource_group rg,
         code_value cv
        PLAN (rg
         WHERE (rg.parent_service_resource_cd=temp->ilist[y].dlist[z].slist[w].sect_cd)
          AND rg.active_ind=1)
         JOIN (cv
         WHERE cv.code_value=rg.child_service_resource_cd)
        ORDER BY rg.sequence
        HEAD REPORT
         ss_cnt = 0
        DETAIL
         ss_cnt = (ss_cnt+ 1), temp->ilist[y].dlist[z].slist[w].ss_cnt = ss_cnt, stat = alterlist(
          temp->ilist[y].dlist[z].slist[w].sslist,ss_cnt),
         temp->ilist[y].dlist[z].slist[w].sslist[ss_cnt].subsect_cd = rg.child_service_resource_cd,
         temp->ilist[y].dlist[z].slist[w].sslist[ss_cnt].subsect_desc = trim(cv.description), temp->
         ilist[y].dlist[z].slist[w].sslist[ss_cnt].subsect_disp = trim(cv.display)
        WITH nocounter
       ;end select
       FOR (v = 1 TO temp->ilist[y].dlist[z].slist[w].ss_cnt)
        SET r_cnt = 0
        SELECT INTO "nl:"
         FROM resource_group rg,
          service_resource sr,
          code_value cv
         PLAN (rg
          WHERE (rg.parent_service_resource_cd=temp->ilist[y].dlist[z].slist[w].sslist[v].subsect_cd)
           AND rg.active_ind=1)
          JOIN (sr
          WHERE sr.service_resource_cd=rg.child_service_resource_cd
           AND sr.active_ind=1)
          JOIN (cv
          WHERE cv.code_value=rg.child_service_resource_cd)
         ORDER BY rg.sequence
         HEAD REPORT
          r_cnt = 0
         DETAIL
          r_cnt = (r_cnt+ 1), temp->ilist[y].dlist[z].slist[w].sslist[v].r_cnt = r_cnt, stat =
          alterlist(temp->ilist[y].dlist[z].slist[w].sslist[v].rlist,r_cnt),
          temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].res_cd = rg
          .child_service_resource_cd, temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].
          res_desc = trim(cv.description), temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].
          res_disp = trim(cv.display)
         WITH nocounter
        ;end select
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET stat = alterlist(reply->collist,15)
 SET reply->collist[1].header_text = "Facility Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Facility Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Department Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Department Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Section Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Section Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Subsection Display"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Subsection Description"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Instrument/Bench Display"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Instrument/Bench Description"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "institution_cd"
 SET reply->collist[11].data_type = 2
 SET reply->collist[11].hide_ind = 1
 SET reply->collist[12].header_text = "deptartment_cd"
 SET reply->collist[12].data_type = 2
 SET reply->collist[12].hide_ind = 1
 SET reply->collist[13].header_text = "section_cd"
 SET reply->collist[13].data_type = 2
 SET reply->collist[13].hide_ind = 1
 SET reply->collist[14].header_text = "subsection_cd"
 SET reply->collist[14].data_type = 2
 SET reply->collist[14].hide_ind = 1
 SET reply->collist[15].header_text = "resource_cd"
 SET reply->collist[15].data_type = 2
 SET reply->collist[15].hide_ind = 1
 SET row_nbr = 1
 IF ((temp->i_cnt > 0))
  SET stat = alterlist(reply->rowlist,1)
  SET stat = alterlist(reply->rowlist[1].celllist,15)
 ENDIF
 SET first_res = 1
 SET first_subsect = 1
 SET first_sect = 1
 SET first_dept = 1
 SET first_inst = 1
 FOR (x = 1 TO temp->i_cnt)
   IF (first_inst=0)
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,15)
   ELSE
    SET first_inst = 0
   ENDIF
   SET first_dept = 1
   SET first_sect = 1
   SET first_subsect = 1
   SET first_res = 1
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->ilist[x].inst_disp
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->ilist[x].inst_desc
   SET reply->rowlist[row_nbr].celllist[11].double_value = temp->ilist[x].inst_cd
   FOR (y = 1 TO temp->ilist[x].d_cnt)
     IF (first_dept=0)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,15)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->ilist[x].inst_disp
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->ilist[x].inst_desc
      SET reply->rowlist[row_nbr].celllist[11].double_value = temp->ilist[x].inst_cd
     ELSE
      SET first_dept = 0
     ENDIF
     SET first_sect = 1
     SET first_subsect = 1
     SET first_res = 1
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->ilist[x].dlist[y].dept_disp
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->ilist[x].dlist[y].dept_desc
     SET reply->rowlist[row_nbr].celllist[12].double_value = temp->ilist[x].dlist[y].dept_cd
     FOR (z = 1 TO temp->ilist[x].dlist[y].s_cnt)
       IF (first_sect=0)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,15)
        SET reply->rowlist[row_nbr].celllist[1].string_value = temp->ilist[x].inst_disp
        SET reply->rowlist[row_nbr].celllist[2].string_value = temp->ilist[x].inst_desc
        SET reply->rowlist[row_nbr].celllist[11].double_value = temp->ilist[x].inst_cd
        SET reply->rowlist[row_nbr].celllist[12].double_value = temp->ilist[x].dlist[y].dept_cd
       ELSE
        SET first_sect = 0
       ENDIF
       SET first_subsect = 1
       SET first_res = 1
       SET reply->rowlist[row_nbr].celllist[5].string_value = temp->ilist[x].dlist[y].slist[z].
       sect_disp
       SET reply->rowlist[row_nbr].celllist[6].string_value = temp->ilist[x].dlist[y].slist[z].
       sect_desc
       SET reply->rowlist[row_nbr].celllist[13].double_value = temp->ilist[x].dlist[y].slist[z].
       sect_cd
       FOR (w = 1 TO temp->ilist[x].dlist[y].slist[z].ss_cnt)
         IF (first_subsect=0)
          SET row_nbr = (row_nbr+ 1)
          SET stat = alterlist(reply->rowlist,row_nbr)
          SET stat = alterlist(reply->rowlist[row_nbr].celllist,15)
          SET reply->rowlist[row_nbr].celllist[1].string_value = temp->ilist[x].inst_disp
          SET reply->rowlist[row_nbr].celllist[2].string_value = temp->ilist[x].inst_desc
          SET reply->rowlist[row_nbr].celllist[11].double_value = temp->ilist[x].inst_cd
          SET reply->rowlist[row_nbr].celllist[12].double_value = temp->ilist[x].dlist[y].dept_cd
          SET reply->rowlist[row_nbr].celllist[13].double_value = temp->ilist[x].dlist[y].slist[z].
          sect_cd
         ELSE
          SET first_subsect = 0
         ENDIF
         SET first_res = 1
         SET reply->rowlist[row_nbr].celllist[7].string_value = temp->ilist[x].dlist[y].slist[z].
         sslist[w].subsect_disp
         SET reply->rowlist[row_nbr].celllist[8].string_value = temp->ilist[x].dlist[y].slist[z].
         sslist[w].subsect_desc
         SET reply->rowlist[row_nbr].celllist[14].double_value = temp->ilist[x].dlist[y].slist[z].
         sslist[w].subsect_cd
         FOR (u = 1 TO temp->ilist[x].dlist[y].slist[z].sslist[w].r_cnt)
           IF (first_res=0)
            SET row_nbr = (row_nbr+ 1)
            SET stat = alterlist(reply->rowlist,row_nbr)
            SET stat = alterlist(reply->rowlist[row_nbr].celllist,15)
            SET reply->rowlist[row_nbr].celllist[1].string_value = temp->ilist[x].inst_disp
            SET reply->rowlist[row_nbr].celllist[2].string_value = temp->ilist[x].inst_desc
            SET reply->rowlist[row_nbr].celllist[11].double_value = temp->ilist[x].inst_cd
            SET reply->rowlist[row_nbr].celllist[12].double_value = temp->ilist[x].dlist[y].dept_cd
            SET reply->rowlist[row_nbr].celllist[13].double_value = temp->ilist[x].dlist[y].slist[z].
            sect_cd
            SET reply->rowlist[row_nbr].celllist[14].double_value = temp->ilist[x].dlist[y].slist[z].
            sslist[w].subsect_cd
           ELSE
            SET first_res = 0
           ENDIF
           SET reply->rowlist[row_nbr].celllist[9].string_value = temp->ilist[x].dlist[y].slist[z].
           sslist[w].rlist[u].res_disp
           SET reply->rowlist[row_nbr].celllist[10].string_value = temp->ilist[x].dlist[y].slist[z].
           sslist[w].rlist[u].res_desc
           SET reply->rowlist[row_nbr].celllist[15].double_value = temp->ilist[x].dlist[y].slist[z].
           sslist[w].rlist[u].res_cd
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("lab_serv_res_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

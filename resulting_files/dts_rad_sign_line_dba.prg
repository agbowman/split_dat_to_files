CREATE PROGRAM dts_rad_sign_line:dba
 IF ((request->called_ind != "Y"))
  RECORD reply(
    1 qual[*]
      2 signature_line = vc
      2 task_assay_cd = f8
    1 signature_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD prsnl_info(
   1 qual[*]
     2 prsnl_id = f8
     2 initials = c3
     2 name_full = c100
     2 name_first = c100
     2 name_middle = c100
     2 name_last = c100
     2 name_title = c100
     2 user_name = c100
     2 street_addr = c100
     2 street_addr2 = c100
     2 city = c100
     2 state = c100
     2 zipcode = c25
     2 contactname = c200
     2 comment = c200
 )
 RECORD signline(
   1 sign_list[*]
     2 rad_report_id = f8
     2 order_id = f8
     2 report_event_id = f8
     2 detail_event_id = f8
     2 task_assay_cd = f8
     2 format_id = f8
     2 status_flag = i2
 )
 RECORD tech(
   1 qual[*]
     2 tech_name = vc
     2 tech_username = vc
     2 tech_init = c3
 )
 RECORD cosigner(
   1 qual[*]
     2 cosign_name = vc
     2 cosign_username = vc
     2 cosign_init = c3
     2 cosign_title = vc
 )
 RECORD dates(
   1 dict_dt_tm = dq8
   1 sign_dt_tm = dq8
   1 trans_dt_tm = dq8
 )
 RECORD temp(
   1 qual[10]
     2 line_nbr = i4
     2 column_pos = i4
     2 meaning = c12
     2 literal_display = vc
     2 max_size = i4
     2 literal_size = i4
     2 format_desc = c60
 )
#start_script
 SET cnt1 = 0
 SET taskcnt = 0
 SET return_val = 0
 SET cnt_qualified = 0
 SET status_flag = 0
 SET request->called_ind = "Y"
 SET cnt = 0
 DECLARE temp_task_assay_cd = f8
 SET temp_task_assay_cd = 0
 SET temp_status_flag = 0
 SET meaning = fillstring(12," ")
 SET exam_prsnl_ind = 0
 SET report_prsnl_ind = 0
 SET report_info_ind = 0
 SET mammo_info_ind = 0
 SET return_string = fillstring(100," ")
 SET i = 0
 DECLARE hold_rad_id = f8
 SET hold_rad_id = 0.0
 SET bretrievedprsnldata = 0
 SET nprsnlitem = 0
 SET prsnl_cnt = 0
 SET prsnl_ind = 0
 SET resi_ind = 0
 DECLARE t_prsnl_id = f8
 SET t_prsnl_id = 0.0
 SET action_prsnl_cnt = 0
 SET action_date = fillstring(20," ")
 SET action_time = fillstring(20," ")
 SET iapiip = 0
 SET ibsldr = 0
 SET igpip = 0
 SET igvd = 0
 SET iaction_prsnl = 0
 SET cur_row = 0
 SET cur_row_pos = 0
 SET cur_col_pos = 0
 SET z = 0
 SET max_cols = 0
 SET dict_rad_init = fillstring(3," ")
 SET dict_rad_name = fillstring(100," ")
 SET dict_rad_username = fillstring(50," ")
 SET dict_rad_title = fillstring(100," ")
 SET proxy_rad_init = fillstring(3," ")
 SET proxy_rad_name = fillstring(100," ")
 SET proxy_rad_username = fillstring(50," ")
 SET proxy_rad_title = fillstring(100," ")
 SET dates->dict_dt_tm = null
 SET dates->trans_dt_tm = null
 SET dates->sign_dt_tm = null
 SET sign_rad_init = fillstring(3," ")
 SET sign_rad_name = fillstring(100," ")
 SET sign_rad_username = fillstring(50," ")
 SET sign_rad_title = fillstring(100," ")
 SET res_init = fillstring(3," ")
 SET res_name = fillstring(100," ")
 SET res_username = fillstring(50," ")
 SET res_title = fillstring(100," ")
 SET trans_init = fillstring(3," ")
 SET trans_name = fillstring(100," ")
 SET trans_username = fillstring(50," ")
 SET mammo_assessment = fillstring(100," ")
 SET mammo_recommendation = fillstring(100," ")
 SET tech_cnt = 0
 SET cosign_cnt = 0
 DECLARE current_name_cd = f8
 SET current_name_cd = 0
 DECLARE code_value = f8
 SET code_value = 0.0
 SET code_set = 213
 SET cdf_meaning = "CURRENT     "
 EXECUTE cpm_get_cd_for_cdf
 SET current_name_cd = code_value
 CALL echo(build("CurNameCd--->>>",current_name_cd))
 SET reply->status_data.status = "F"
 CALL getradinfo(0)
 SET action_prsnl_cnt = size(request->action_prsnl_qual,5)
 CALL retrieveprsnlinfo(0)
 FOR (cnt1 = 1 TO size(request->sign_list,5))
   SET taskcnt = cnt1
   SET return_val = getformatforsection(request->sign_list[taskcnt].format_id)
   CALL echo(build("RETURN VALUE AFTER GetFormatSection :",return_val))
   IF (return_val=0)
    CALL echo(build("Error Retrieving Signature Line Format for format id: ",request->sign_list[
      taskcnt].format_id))
    SET stat = alterlist(reply->qual,cnt1)
    SET reply->qual[cnt1].signature_line = ""
    SET reply->qual[cnt1].task_assay_cd = request->sign_list[cnt1].task_assay_cd
   ELSE
    CALL retrievesignlinedata(exam_prsnl_ind,report_prsnl_ind,report_info_ind,mammo_info_ind)
    CALL buildsldatarequest(return_val)
    EXECUTE aps_get_signature_line
    SET reqinfo->commit_ind = 1
    CALL echo("Sign Line is: ")
    CALL echo(reply->signature_line)
    SET stat = alterlist(reply->qual,cnt1)
    SET reply->qual[cnt1].signature_line = reply->signature_line
    SET reply->qual[cnt1].task_assay_cd = request->sign_list[cnt1].task_assay_cd
   ENDIF
   CALL echo(build("Reqinfo->commit_ind is: ",reqinfo->commit_ind))
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echo(build("===================================================="))
 CALL echo(build("multiple sign lines... "))
 FOR (cnt1 = 1 TO size(request->sign_list,5))
   CALL echo(build("signature line # ",cnt1))
   CALL echo(reply->qual[cnt1].signature_line)
   CALL echo(build("task assay cd =",reply->qual[cnt1].task_assay_cd))
 ENDFOR
 SUBROUTINE getradinfo(dummy)
   SET w = 0
   SET x = 0
   FOR (x = 1 TO size(request->sign_list,5))
    CALL echo(build("Trying Row:",x,"ORDER:",request->sign_list[x].order_id,"TASK:",
      request->sign_list[x].task_assay_cd))
    SELECT INTO "nl:"
     o.order_id, sldr.format_id, sldr.status_flag
     FROM order_radiology o,
      order_catalog oc,
      sign_line_dta_r sldr,
      (dummyt d  WITH seq = 1)
     PLAN (o
      WHERE (o.order_id=request->sign_list[x].order_id))
      JOIN (oc
      WHERE o.catalog_cd=oc.catalog_cd)
      JOIN (d
      WHERE d.seq=1)
      JOIN (sldr
      WHERE sldr.activity_subtype_cd=oc.activity_subtype_cd
       AND (sldr.task_assay_cd=request->sign_list[x].task_assay_cd)
       AND sldr.status_flag IN (0, 1))
     DETAIL
      IF (sldr.format_id > 0.0)
       CALL echo(build("found format ids in the table :",sldr.format_id)), request->sign_list[x].
       order_id = o.order_id, request->sign_list[x].format_id = sldr.format_id,
       request->sign_list[x].status_flag = 1,
       CALL echo(build("Rad_Report_Id :",request->sign_list[x].rad_report_id)),
       CALL echo(build("Order_Id :",request->sign_list[x].order_id)),
       CALL echo(build("Task_Assay_Cd :",request->sign_list[x].task_assay_cd)),
       CALL echo(build("Report_Event_Id :",request->sign_list[x].report_event_id)),
       CALL echo(build("Detail_Event_Id :",request->sign_list[x].detail_event_id)),
       CALL echo(build("Format_id :",request->sign_list[x].format_id)),
       CALL echo(build("Status_Flag :",request->sign_list[x].status_flag))
      ENDIF
     WITH nocounter, outerjoin = d
    ;end select
   ENDFOR
 END ;Subroutine
 DECLARE getformatforsection(gffsformat_id) = i2
 SUBROUTINE getformatforsection(gffsformat_id)
   CALL echo("Just entered GetFormatForSection...")
   SET cnt_qualified = 0
   SET stat = alter(temp->qual,1)
   SET stat = alter(temp->qual,10)
   SELECT INTO "nl:"
    slf.format_id, slfd.format_id, slfd.sequence,
    cv.cdf_meaning, format_desc = uar_get_code_description(slfd.data_element_format_cd)
    FROM sign_line_format slf,
     sign_line_format_detail slfd,
     code_value cv
    PLAN (slf
     WHERE gffsformat_id=slf.format_id
      AND slf.active_ind=1)
     JOIN (slfd
     WHERE slf.format_id=slfd.format_id)
     JOIN (cv
     WHERE slfd.data_element_cd=cv.code_value)
    ORDER BY slfd.format_id DESC, slfd.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt_qualified = (cnt_qualified+ 1)
     IF (mod(cnt_qualified,10)=1
      AND cnt_qualified != 1)
      stat = alter(temp->qual,(cnt_qualified+ 9))
     ENDIF
     temp->qual[cnt_qualified].line_nbr = slfd.line_nbr, temp->qual[cnt_qualified].column_pos = slfd
     .column_pos, temp->qual[cnt_qualified].meaning = cv.cdf_meaning,
     temp->qual[cnt_qualified].literal_display = slfd.literal_display, temp->qual[cnt_qualified].
     max_size = slfd.max_size, temp->qual[cnt_qualified].literal_size = slfd.literal_size,
     CALL echo(build("##GFFS-0 format_id:",gffsformat_id)),
     CALL echo(build("##GFFS-1 cv.code_value:",cv.code_value)),
     CALL echo(build("##GFFS-2 cv.cdf_meaning:",cv.cdf_meaning)),
     CALL echo(build("##GFFS-3 format_desc:",format_desc)),
     CALL echo(build("##GFFS-4 data_element_format_cd:",slfd.data_element_format_cd)), temp->qual[
     cnt_qualified].format_desc = format_desc
     CASE (trim(cv.cdf_meaning))
      OF "RADICTNAME":
       report_prsnl_ind = 1
      OF "RADICTINIT":
       report_prsnl_ind = 1
      OF "RADICTUSER":
       report_prsnl_ind = 1
      OF "RADICTTITLE":
       report_prsnl_ind = 1
      OF "RARESNAME":
       report_prsnl_ind = 1
      OF "RARESINIT":
       report_prsnl_ind = 1
      OF "RARESUSER":
       report_prsnl_ind = 1
      OF "RARESTITLE":
       report_prsnl_ind = 1
      OF "RASIGNNAME":
       report_prsnl_ind = 1
      OF "RASIGNINIT":
       report_prsnl_ind = 1
      OF "RASIGNUSER":
       report_prsnl_ind = 1
      OF "RASIGNTITLE":
       report_prsnl_ind = 1
      OF "RAPROXYNAME":
       report_prsnl_ind = 1
      OF "RAPROXYINIT":
       report_prsnl_ind = 1
      OF "RAPROXYUSER":
       report_prsnl_ind = 1
      OF "RAPROXYTITLE":
       report_prsnl_ind = 1
      OF "RATRANNAME":
       report_prsnl_ind = 1
      OF "RATRANINIT":
       report_prsnl_ind = 1
      OF "RATRANUSER":
       report_prsnl_ind = 1
      OF "RACOSIGNNAME":
       report_prsnl_ind = 1
      OF "RACOSIGNINIT":
       report_prsnl_ind = 1
      OF "RACOSIGNUSER":
       report_prsnl_ind = 1
      OF "RATECHNAME":
       exam_prsnl_ind = 1
      OF "RATECHINIT":
       exam_prsnl_ind = 1
      OF "RATECHUSER":
       exam_prsnl_ind = 1
      OF "RADICTDTTM":
       report_info_ind = 1
      OF "RASIGNDTTM":
       report_info_ind = 1
      OF "RATRANDTTM":
       report_info_ind = 1
      OF "RAMAMASSESS":
       mammo_info_ind = 1
      OF "RAMAMRECOMM":
       mammo_info_ind = 1
     ENDCASE
    FOOT REPORT
     stat = alter(temp->qual,cnt_qualified)
    WITH nocounter
   ;end select
   RETURN(cnt_qualified)
 END ;Subroutine
 SUBROUTINE retrievesignlinedata(rsldeprsnlind,rsldrprsnlind,rsldrinfoind,rsldminfoind)
   CALL echo("Just entered RetrieveSignLineData...")
   IF (rsldeprsnlind=1)
    SELECT INTO "nl:"
     rep.exam_prsnl_id, p.username, p.name_full_formatted,
     pn.name_initials
     FROM order_radiology o,
      rad_exam re,
      rad_exam_prsnl rep,
      prsnl_group pg,
      prsnl_group_reltn pr,
      prsnl p,
      person_name pn
     PLAN (o
      WHERE (o.parent_order_id=request->sign_list[taskcnt].order_id))
      JOIN (re
      WHERE re.order_id=o.order_id)
      JOIN (rep
      WHERE rep.rad_exam_id=re.rad_exam_id)
      JOIN (pg)
      JOIN (pr
      WHERE pg.prsnl_group_id=pr.prsnl_group_id
       AND pr.person_id=rep.exam_prsnl_id)
      JOIN (p
      WHERE pr.person_id=p.person_id)
      JOIN (pn
      WHERE p.person_id=pn.person_id
       AND pn.name_type_cd=current_name_cd)
     ORDER BY rep.exam_prsnl_id
     HEAD rep.exam_prsnl_id
      tech_cnt = (tech_cnt+ 1), stat = alterlist(tech->qual,tech_cnt), tech->qual[tech_cnt].tech_init
       = substring(1,3,pn.name_initials),
      tech->qual[tech_cnt].tech_name = trim(p.name_full_formatted), tech->qual[tech_cnt].
      tech_username = trim(p.username)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Did not retrieve any Exam Prsnl.")
    ENDIF
   ENDIF
   IF (rsldminfoind=1)
    SELECT INTO "nl:"
     ms.order_id, ms.assessment_id, ms.recommendation_id,
     rff.field_description, rff2.field_description
     FROM mammo_study ms,
      rad_fol_up_field rff,
      rad_fol_up_field rff2
     PLAN (ms
      WHERE (ms.order_id=request->sign_list[taskcnt].order_id))
      JOIN (rff
      WHERE ms.assessment_id=rff.follow_up_field_id)
      JOIN (rff2
      WHERE ms.recommendation_id=rff2.follow_up_field_id)
     DETAIL
      mammo_assessment = rff.field_description, mammo_recommendation = rff2.field_description
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Did not retrieve any Mammo Info.")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addprsnlinfoitem(apiiprsnlid)
   IF (apiiprsnlid != 0)
    SET nprsnlitem = 0
    SET iapiip = 1
    WHILE (iapiip <= prsnl_cnt
     AND nprsnlitem=0)
     IF ((apiiprsnlid=prsnl_info->qual[iapiip].prsnl_id))
      SET nprsnlitem = iapiip
     ENDIF
     SET iapiip = (iapiip+ 1)
    ENDWHILE
    IF (nprsnlitem=0)
     SET prsnl_cnt = (prsnl_cnt+ 1)
     SET stat = alterlist(prsnl_info->qual,prsnl_cnt)
     SET prsnl_info->qual[prsnl_cnt].prsnl_id = apiiprsnlid
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnlinfobyid(gpiprsnlid)
  SET nprsnlitem = 0
  IF (gpiprsnlid != 0)
   SET igpip = 1
   WHILE (igpip <= prsnl_cnt
    AND nprsnlitem=0)
    IF ((gpiprsnlid=prsnl_info->qual[igpip].prsnl_id))
     SET nprsnlitem = igpip
    ENDIF
    SET igpip = (igpip+ 1)
   ENDWHILE
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprsnlinfo(rpidummy)
   CALL echo("Just entered RetrievePrsnlInfo...")
   CALL echo(build("Action_Prsnl_Cnt :",action_prsnl_cnt))
   IF (bretrievedprsnldata=0)
    FOR (ib = 1 TO action_prsnl_cnt)
     CALL addprsnlinfoitem(request->action_prsnl_qual[ib].action_prsnl_id)
     IF ((request->action_prsnl_qual[ib].proxy_prsnl_id > 0))
      CALL addprsnlinfoitem(request->action_prsnl_qual[ib].proxy_prsnl_id)
     ENDIF
    ENDFOR
    CALL echo(build("prsnl_cnt :",prsnl_cnt))
    IF (prsnl_cnt > 0)
     SELECT INTO "nl:"
      d.seq, pn.person_id, a.street_addr,
      a.street_addr2, a.city, a.state,
      a.zipcode
      FROM code_value cv,
       person_name pn,
       (dummyt d  WITH seq = value(prsnl_cnt)),
       dummyt d1,
       address a
      PLAN (cv
       WHERE cv.code_set=213
        AND cv.cdf_meaning="CURRENT"
        AND cv.active_ind=1)
       JOIN (d)
       JOIN (a
       WHERE (prsnl_info->qual[d.seq].prsnl_id=a.parent_entity_id)
        AND a.active_ind=1)
       JOIN (d1)
       JOIN (pn
       WHERE (prsnl_info->qual[d.seq].prsnl_id=pn.person_id)
        AND cv.code_value=pn.name_type_cd
        AND pn.active_ind=1
        AND pn.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pn.end_effective_dt_tm=
       null)) )
      DETAIL
       prsnl_info->qual[d.seq].initials = substring(1,3,pn.name_initials), prsnl_info->qual[d.seq].
       name_full = trim(pn.name_full), prsnl_info->qual[d.seq].name_full = concat(trim(pn.name_first),
        " ",trim(pn.name_last)),
       prsnl_info->qual[d.seq].name_first = trim(pn.name_first), prsnl_info->qual[d.seq].name_middle
        = trim(pn.name_middle), prsnl_info->qual[d.seq].name_last = trim(pn.name_last),
       prsnl_info->qual[d.seq].name_title = trim(pn.name_title), prsnl_info->qual[d.seq].street_addr
        = trim(a.street_addr), prsnl_info->qual[d.seq].street_addr2 = trim(a.street_addr2),
       prsnl_info->qual[d.seq].city = trim(a.city), prsnl_info->qual[d.seq].state = trim(a.state),
       prsnl_info->qual[d.seq].zipcode = trim(a.zipcode),
       prsnl_info->qual[d.seq].contactname = trim(a.contact_name), prsnl_info->qual[d.seq].comment =
       trim(a.comment_txt)
      WITH nocounter, dontcare = a
     ;end select
    ENDIF
    CALL echo(build("count of prsnl ",size(prsnl_info->qual)))
    IF (prsnl_cnt > 0)
     SELECT INTO "nl:"
      p.username
      FROM prsnl p,
       (dummyt d  WITH seq = value(prsnl_cnt))
      PLAN (d)
       JOIN (p
       WHERE (prsnl_info->qual[d.seq].prsnl_id=p.person_id))
      DETAIL
       prsnl_info->qual[d.seq].user_name = p.username,
       CALL echo(build("User name is _",p.username))
      WITH nocounter
     ;end select
    ENDIF
    SET bretrievedprsnldata = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE findactionperson(saction)
   CALL echo("Just entered FindAuthor...")
   SET nprsnlitem = 0
   SET ib = 1
   IF (saction="PROXY")
    SET iproxy = 1
    SET saction = "SIGN"
   ELSE
    SET iproxy = 0
   ENDIF
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     IF (iproxy=0)
      CALL getprsnlinfobyid(request->action_prsnl_qual[ib].action_prsnl_id)
      CALL echo(build("FoundAuthor...",prsnl_info->qual[nprsnlitem].name_full))
     ELSE
      CALL getprsnlinfobyid(request->action_prsnl_qual[ib].proxy_prsnl_id)
      CALL echo(build("FoundProxy...",prsnl_info->qual[nprsnlitem].name_full))
     ENDIF
    ENDIF
    SET ib = (ib+ 1)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE findactiondate(saction)
   CALL echo("Just entered FindActionDate...")
   SET nprsnlitem = 0
   SET ib = 1
   SET action_date = fillstring(20," ")
   SET action_time = fillstring(20," ")
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     SET action_date = format(cnvtdatetime(request->action_prsnl_qual[ib].action_dt_tm),"mm/dd/yy;;d"
      )
     SET action_time = format(cnvtdatetime(request->action_prsnl_qual[ib].action_dt_tm),"hh:mm;;d")
     CALL echo(build("FoundDate...",action_date,"_and time_",action_time))
     CASE (trim(gvdmeaning))
      OF "RADICTDTTM":
       SET dates->dict_dt_tm = cnvtdatetime(request->action_prsnl_qual[ib].action_dt_tm)
      OF "RASIGNDTTM":
       SET dates->sign_dt_tm = cnvtdatetime(request->action_prsnl_qual[ib].action_dt_tm)
      OF "RATRANDTTM":
       SET dates->trans_dt_tm = cnvtdatetime(request->action_prsnl_qual[ib].action_dt_tm)
     ENDCASE
    ENDIF
    SET ib = (ib+ 1)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE findactionstatus(saction)
   CALL echo("Just entered FindActionStatus...")
   SET nprsnlitem = 0
   SET ib = 1
   SET action_status = fillstring(20," ")
   SET action_status_mean = fillstring(20," ")
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     SET action_status_mean = request->action_prsnl_qual[ib].action_status_mean
    ENDIF
    SET ib = (ib+ 1)
   ENDWHILE
   SELECT INTO "nl:"
    cv1.description
    FROM code_value cv1
    PLAN (cv1
     WHERE cv1.code_set=103
      AND cv1.cdf_meaning=action_status_mean
      AND cv1.active_ind=1)
    DETAIL
     action_status = cv1.description
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE buildsldatarequest(bsldrcnt)
   CALL echo("Just entered BuildSLDataRequest...")
   SET cur_row_pos = 0
   SET cur_row = 0
   SET max_cols = 0
   FOR (i = 1 TO bsldrcnt)
     SET return_string = fillstring(100," ")
     IF ((temp->qual[i].line_nbr != cur_row))
      SET cur_row_pos = (cur_row_pos+ 1)
      SET cur_row = temp->qual[i].line_nbr
      SET cur_col_pos = 1
      SET stat = alterlist(request->row_qual,cur_row_pos)
      SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[i].column_pos
      SET request->row_qual[cur_row_pos].line_num = temp->qual[i].line_nbr
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[i].max_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[i].
      literal_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[i].
      literal_display
      IF (trim(temp->qual[i].meaning) != "")
       CALL getvaluedata(trim(temp->qual[i].meaning),temp->qual[i].format_desc)
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(return_string)
       IF (textlen(trim(return_string))=0)
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
       ELSE
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[i].
        literal_display
       ENDIF
      ENDIF
     ELSE
      SET cur_col_pos = (cur_col_pos+ 1)
      SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[i].column_pos
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[i].max_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[i].
      literal_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[i].
      literal_display
      IF (trim(temp->qual[i].meaning) != "")
       CALL getvaluedata(trim(temp->qual[i].meaning),temp->qual[i].format_desc)
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(return_string)
       CALL echo(build(trim(temp->qual[i].meaning)," :",trim(return_string)))
       IF (textlen(trim(return_string))=0)
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
       ELSE
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[i].
        literal_display
       ENDIF
      ENDIF
     ENDIF
     IF (cur_col_pos > max_cols)
      SET max_cols = cur_col_pos
     ENDIF
   ENDFOR
   SET request->max_cols = max_cols
 END ;Subroutine
 SUBROUTINE getvaluedata(gvdmeaning,formatdef)
   CALL echo(build("Just entered GetValueData...GVDmeaning = ",gvdmeaning))
   SET return_string = ""
   CASE (trim(gvdmeaning))
    OF "RADICTNAME":
     CALL findactionperson("PERFORM")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    OF "RADICTINIT":
     CALL findactionperson("PERFORM")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "RADICTUSER":
     CALL findactionperson("PERFORM")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].username
     ENDIF
    OF "RADICTTITLE":
     IF (nprsnlitem != 0)
      CALL findactionperson("PERFORM")
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "RARESNAME":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    OF "RARESINIT":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "RARESUSER":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].user_name
     ENDIF
    OF "RARESTITLE":
     IF (nprsnlitem != 0)
      CALL findactionperson("SIGN")
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "RASIGNNAME":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    OF "RASIGNINIT":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "RASIGNUSER":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].user_name
     ENDIF
    OF "RASIGNTITLE":
     IF (nprsnlitem != 0)
      CALL findactionperson("VERIFY")
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "RAPROXYNAME":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    OF "RAPROXYINIT":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "RAPROXYUSER":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].user_name
     ENDIF
    OF "RAPROXYTITLE":
     IF (nprsnlitem != 0)
      CALL findactionperson("PROXY")
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "RATRANNAME":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    OF "RATRANINIT":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "RATRANUSER":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].user_name
     ENDIF
    OF "RACOSIGNNAME":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    OF "RACOSIGNINIT":
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "RACOSIGNUSER":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].user_name
     ENDIF
    OF "RATECHNAME":
     FOR (z = 1 TO tech_cnt)
       IF (z=1)
        SET return_string = tech->qual[z].tech_name
       ELSE
        SET return_string = build(trim(return_string),",",tech->qual[z].tech_name)
       ENDIF
     ENDFOR
    OF "RATECHINIT":
     FOR (z = 1 TO tech_cnt)
       IF (z=1)
        SET return_string = tech->qual[z].tech_init
       ELSE
        SET return_string = build(trim(return_string),",",tech->qual[z].tech_init)
       ENDIF
     ENDFOR
    OF "RATECHUSER":
     FOR (z = 1 TO tech_cnt)
       IF (z=1)
        SET return_string = tech->qual[z].tech_username
       ELSE
        SET return_string = build(trim(return_string),",",tech->qual[z].tech_username)
       ENDIF
     ENDFOR
    OF "RADICTDTTM":
    OF "RASIGNDTTM":
     CALL findactiondate("SIGN")
     SET return_string = action_date
    OF "RATRANDTTM":
     CALL findactiondate("TRANSCRIBE")
     CALL echo(build("Transcribed date & time: ",format(dates->trans_dt_tm,";;q")))
     CALL echo(build("elelment format :",formatdef))
     IF (((formatdef="") OR (formatdef=" ")) )
      SET return_string = format(cnvtdatetime(dates->trans_dt_tm),"mm/dd/yyyy hh:mm;;d")
     ELSE
      CALL formatdatebymask(formatdef)
     ENDIF
    OF "RAMAMASSESS":
     SET return_string = trim(mammo_assessment)
    OF "RAMAMRECOMM":
     SET return_string = trim(mammo_recommendation)
    ELSE
     SET return_string = "?????"
   ENDCASE
 END ;Subroutine
 SUBROUTINE formatdatebymask(formatdesc)
   SET deflength = 0
   SET findpt = 0
   SET findpt = findstring("|",formatdesc)
   IF (findpt=0)
    CASE (trim(gvdmeaning))
     OF "RADICTDTTM":
      SET return_string = format(dates->dict_dt_tm,formatdesc)
     OF "RASIGNDTTM":
      SET return_string = format(dates->sign_dt_tm,formatdesc)
     OF "RATRANDTTM":
      SET return_string = format(dates->trans_dt_tm,formatdesc)
    ENDCASE
   ELSE
    SET deflength = textlen(trim(formatdesc))
    SET date_mask = substring(1,(findpt - 1),formatdesc)
    SET time_mask = substring((findpt+ 1),deflength,formatdesc)
    IF (substring(deflength,deflength,formatdesc)="S")
     CASE (trim(gvdmeaning))
      OF "RADICTDTTM":
       SET time_now = format(dates->dict_dt_tm,time_mask)
      OF "RASIGNDTTM":
       SET time_now = format(dates->sign_dt_tm,time_mask)
      OF "RATRANDTTM":
       SET time_now = format(dates->trans_dt_tm,time_mask)
     ENDCASE
     IF (substring(1,1,time_now)="0")
      SET time_now = substring(2,textlen(time_now),time_now)
     ENDIF
    ELSE
     CASE (trim(gvdmeaning))
      OF "RADICTDTTM":
       SET time_now = format(dates->dict_dt_tm,time_mask)
      OF "RASIGNDTTM":
       SET time_now = format(dates->sign_dt_tm,time_mask)
      OF "RATRANDTTM":
       SET time_now = format(dates->trans_dt_tm,time_mask)
     ENDCASE
    ENDIF
    CASE (trim(gvdmeaning))
     OF "RADICTDTTM":
      CALL echo(build("##FDM-1 Dict dt/tm:",dates->dict_dt_tm))
      IF ((dates->dict_dt_tm > 0))
       SET return_string = concat(format(dates->dict_dt_tm,date_mask)," ",time_now)
      ELSE
       SET return_string = ""
      ENDIF
     OF "RASIGNDTTM":
      CALL echo(build("##FDM-2 Sign dt/tm:",dates->sign_dt_tm))
      IF ((dates->sign_dt_tm > 0))
       SET return_string = concat(format(dates->sign_dt_tm,date_mask)," ",time_now)
      ELSE
       SET return_string = ""
      ENDIF
     OF "RATRANDTTM":
      CALL echo(build("##FDM-3 Trans dt/tm:",dates->trans_dt_tm))
      IF ((dates->trans_dt_tm > 0))
       SET return_string = concat(format(dates->trans_dt_tm,date_mask)," ",time_now)
      ELSE
       SET return_string = ""
      ENDIF
    ENDCASE
    CALL echo(build("##FDM-13 return_string:",return_string))
   ENDIF
 END ;Subroutine
 GO TO end_script
#exit_script
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 0
#end_script
 CALL echo(build("DTS_RAD_SIGN_LINE exiting for rad_report_id: ",request->sign_list[taskcnt].
   rad_report_id))
END GO

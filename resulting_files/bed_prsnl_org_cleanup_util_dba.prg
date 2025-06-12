CREATE PROGRAM bed_prsnl_org_cleanup_util:dba
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
    1 output_filename = vc
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
  ) WITH protect
 ENDIF
 IF ( NOT (validate(frec,0)))
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(temp,0)))
  RECORD temp(
    1 result[*]
      2 person_id = f8
      2 prsnl_org_reltn_id = f8
      2 active_status_cd = f8
  ) WITH protect
 ENDIF
 DECLARE active_report_name = vc WITH protect, constant("bed_prsnl_org_cleanup_util_active")
 DECLARE inactive_report_name = vc WITH protect, constant("bed_prsnl_org_cleanup_util_inactive")
 DECLARE limit_per_file = i4 WITH protect, constant(500000)
 DECLARE code_value_deleted = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE tot_exec_per_itr = i4 WITH protect, constant(1000)
 DECLARE main_menu_title = vc WITH protect, constant(
  "Bedrock Personnel to Org Logical Domain Cleanup Utility Menu")
 DECLARE main_menu_item1 = vc WITH protect, constant("1)  Generate Report")
 DECLARE main_menu_item2 = vc WITH protect, constant("2)  Run Cleanup")
 DECLARE main_menu_item3 = vc WITH protect, constant("3)  Exit")
 DECLARE menu_q_text = vc WITH protect, constant("What would you like to select?")
 DECLARE menu_option_text = vc WITH protect, constant("Select Option ")
 DECLARE menu_item_text = vc WITH protect, constant("3)  Go to Main Menu")
 DECLARE menu_instruction_text = vc WITH protect, constant("Press <Enter> to exit.")
 DECLARE active_prsnl_org_cnt = vc WITH protect, constant(
  "Total number of active prsnl org relation records: ")
 DECLARE inactive_prsnl_org_cnt = vc WITH protect, constant(
  "Total number of inactive prsnl org relation records: ")
 DECLARE reports_location = vc WITH protect, constant(
  "Reports located at /cerner/d_<DOMAIN_NAME>/ccluserdir/")
 DECLARE view_report_step1 = vc WITH protect, constant("1)  cd /cerner/d_<DOMAIN_NAME>/ccluserdir/")
 DECLARE view_report_act_step2 = vc WITH protect, constant(
  "2)  cat bed_prsnl_org_cleanup_util_active_<REPORT_NUMBER>.csv")
 DECLARE view_report_inact_step2 = vc WITH protect, constant(
  "2)  cat bed_prsnl_org_cleanup_util_inactive_<REPORT_NUMBER>.csv")
 DECLARE report_status_nodata = vc WITH protect, constant("No data avaiable for report creation")
 DECLARE cleanup_q_text = vc WITH protect, constant("Do you want to run cleanup? (Y/N)")
 DECLARE cleanup_status_nodata = vc WITH protect, constant("No data available for cleanup")
 DECLARE gr_menu_item1 = vc WITH protect, constant("1)  Generate Active prsnl org relation report")
 DECLARE gr_menu_item2 = vc WITH protect, constant("2)  Generate Inactive prsnl org relation report")
 DECLARE gr_active_menu_title = vc WITH protect, constant(
  "Instructions to view active prsnl org relation reports")
 DECLARE gr_inactive_menu_title = vc WITH protect, constant(
  "Instructions to view Inactive prsnl org relation reports")
 DECLARE sec_login_off_status = vc WITH protect, constant(
  "You have not logged in. Please login to CCLPROMPT to perform cleanup.")
 DECLARE cu_menu_item1 = vc WITH protect, constant("1)  Cleanup Active prsnl org relation data")
 DECLARE cu_menu_item2 = vc WITH protect, constant("2)  Cleanup Inactive prsnl org relation data")
 DECLARE active_cleanup_status = vc WITH protect, constant(
  "Active prsnl org relation records updated successfully.")
 DECLARE inactive_cleanup_status = vc WITH protect, constant(
  "Inactive prsnl org relation records updated successfully.")
 DECLARE row_string = vc WITH protect, noconstant("")
 DECLARE header_string = vc WITH protect, noconstant("")
 DECLARE cell_value = vc WITH protect, noconstant("")
 DECLARE tot_col = i4 WITH protect, noconstant(0)
 DECLARE output_filename = vc WITH protect, noconstant("")
 DECLARE total_active_rows = i4 WITH protect, noconstant(0)
 DECLARE total_inactive_rows = i4 WITH protect, noconstant(0)
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect, noconstant("N")
 DECLARE start_row = i4 WITH protect, noconstant(0)
 DECLARE end_row = i4 WITH protect, noconstant(0)
 DECLARE active_file_cnt = i4 WITH protect, noconstant(0)
 DECLARE inactive_file_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE lower_bound = i4 WITH protect, noconstant(0)
 DECLARE upper_bound = i4 WITH protect, noconstant(0)
 DECLARE clone_reply_size = i4 WITH protect, noconstant(0)
 DECLARE preparecsvtowrite(dummyvar=i2) = i2
 DECLARE writereporttocsv(start_row=i4,end_row=i4) = i2
 DECLARE closecsvwrittento(dummyvar=i2) = i2
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET tot_col = 8
 SET width = 132
 SET modify = system
#menu
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,menu_q_text)
 CALL text(9,20,main_menu_item1)
 CALL text(11,20,main_menu_item2)
 CALL text(13,20,main_menu_item3)
 CALL text(16,2,menu_option_text)
 CALL accept(16,20,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(16,1)
 CASE (curaccept)
  OF 1:
   GO TO generate_report
  OF 2:
   IF ((reqinfo->updt_id > 0.0))
    GO TO run_cleanup
   ELSE
    GO TO sec_login_off
   ENDIF
  OF 3:
   GO TO exit_script
  ELSE
   GO TO exit_script
 ENDCASE
#sec_login_off
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(9,20,sec_login_off_status)
 CALL text(16,2,menu_instruction_text)
 CALL accept(16,30,"9;",1
  WHERE curaccept IN (1, 2))
 CALL clear(16,1)
 IF (curaccept)
  GO TO exit_script
 ENDIF
#generate_report
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,menu_q_text)
 CALL text(9,20,gr_menu_item1)
 CALL text(11,20,gr_menu_item2)
 CALL text(13,20,menu_item_text)
 CALL text(16,2,menu_option_text)
 CALL accept(16,20,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(16,1)
 CASE (curaccept)
  OF 1:
   SET total_active_rows = 0
   SET start_row = 1
   SET end_row = limit_per_file
   CALL findactiveprsnlorgldomaincount(0)
   IF (total_active_rows > 0)
    SET active_file_cnt = ceil((total_active_rows/ cnvtreal(limit_per_file)))
    CALL loadactiveprsnlorglogicaldata(0)
    FOR (i = 1 TO active_file_cnt)
      SET output_filename = build(active_report_name,"_",i,".csv")
      SET reply->output_filename = output_filename
      IF (end_row >= total_active_rows)
       SET end_row = total_active_rows
      ENDIF
      CALL preparecsvheaders(0)
      CALL preparecsvtowrite(0)
      CALL writereporttocsv(start_row,end_row)
      CALL closecsvwrittento(0)
      SET start_row = (start_row+ limit_per_file)
      SET end_row = (end_row+ limit_per_file)
    ENDFOR
   ENDIF
   GO TO active_report
  OF 2:
   SET total_inactive_rows = 0
   SET start_row = 1
   SET end_row = limit_per_file
   CALL findinactiveprsnlorgldomaincount(0)
   IF (total_inactive_rows > 0)
    SET inactive_file_cnt = ceil((total_inactive_rows/ cnvtreal(limit_per_file)))
    CALL loadinactiveprsnlorglogicaldata(0)
    FOR (i = 1 TO inactive_file_cnt)
      SET output_filename = build(inactive_report_name,"_",i,".csv")
      SET reply->output_filename = output_filename
      IF (end_row >= total_inactive_rows)
       SET end_row = total_inactive_rows
      ENDIF
      CALL preparecsvheaders(0)
      CALL preparecsvtowrite(0)
      CALL writereporttocsv(start_row,end_row)
      CALL closecsvwrittento(0)
      SET start_row = (start_row+ limit_per_file)
      SET end_row = (end_row+ limit_per_file)
    ENDFOR
   ENDIF
   GO TO inactive_report
  OF 3:
   GO TO menu
  ELSE
   GO TO menu
 ENDCASE
#active_report
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,gr_active_menu_title,w)
 CALL text(7,20,active_prsnl_org_cnt)
 CALL text(7,72,cnvtstring(total_active_rows))
 IF (total_active_rows > 0)
  CALL text(9,20,reports_location)
  CALL text(11,20,view_report_step1)
  CALL text(13,20,view_report_act_step2)
 ELSE
  CALL text(9,20,report_status_nodata)
 ENDIF
 CALL text(16,2,menu_instruction_text)
 CALL accept(16,53,"9;",1
  WHERE curaccept IN (1, 2))
 IF (curaccept)
  GO TO generate_report
 ENDIF
#inactive_report
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,gr_inactive_menu_title,w)
 CALL text(7,20,inactive_prsnl_org_cnt)
 CALL text(7,72,cnvtstring(total_inactive_rows))
 IF (total_inactive_rows > 0)
  CALL text(9,20,reports_location)
  CALL text(11,20,view_report_step1)
  CALL text(13,20,view_report_inact_step2)
 ELSE
  CALL text(9,20,report_status_nodata)
 ENDIF
 CALL text(16,2,menu_instruction_text)
 CALL accept(16,53,"9;",1
  WHERE curaccept IN (1, 2))
 IF (curaccept)
  GO TO generate_report
 ENDIF
#run_cleanup
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,menu_q_text)
 CALL text(9,20,cu_menu_item1)
 CALL text(11,20,cu_menu_item2)
 CALL text(13,20,menu_item_text)
 CALL text(16,2,menu_option_text)
 CALL accept(16,20,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(16,1)
 CASE (curaccept)
  OF 1:
   SET total_active_rows = 0
   CALL findactiveprsnlorgldomaincount(0)
   GO TO active_cleanup
  OF 2:
   SET total_inactive_rows = 0
   CALL findinactiveprsnlorgldomaincount(0)
   GO TO inactive_cleanup
  OF 3:
   GO TO menu
  ELSE
   GO TO menu
 ENDCASE
#active_cleanup
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,active_prsnl_org_cnt)
 CALL text(7,72,cnvtstring(total_active_rows))
 IF (total_active_rows > 0)
  CALL text(16,2,cleanup_q_text)
  CALL accept(16,40,"P;CU","N"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="N")
   GO TO run_cleanup
  ENDIF
 ELSE
  CALL text(9,20,cleanup_status_nodata)
  CALL text(16,2,menu_instruction_text)
  CALL accept(16,53,"9;",1
   WHERE curaccept IN (1, 2))
  IF (curaccept)
   GO TO run_cleanup
  ENDIF
 ENDIF
#active_status
 CALL loadactiveprsnlorglogicaldata(0)
 CALL cleanupcrosslogidomdata(0)
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,active_cleanup_status)
 CALL text(16,2,menu_instruction_text)
 CALL accept(16,53,"9;",1
  WHERE curaccept IN (1, 2))
 IF (curaccept)
  GO TO run_cleanup
 ENDIF
#inactive_cleanup
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,inactive_prsnl_org_cnt)
 CALL text(7,72,cnvtstring(total_inactive_rows))
 IF (total_inactive_rows > 0)
  CALL text(16,2,cleanup_q_text)
  CALL accept(16,40,"P;CU","N"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="N")
   GO TO run_cleanup
  ENDIF
 ELSE
  CALL text(9,20,cleanup_status_nodata)
  CALL text(16,2,menu_instruction_text)
  CALL accept(16,53,"9;",1
   WHERE curaccept IN (1, 2))
  IF (curaccept)
   GO TO run_cleanup
  ENDIF
 ENDIF
#inactive_status
 CALL loadinactiveprsnlorglogicaldata(0)
 CALL cleanupcrosslogidomdata(0)
 CALL clear(1,1)
 CALL box(3,1,15,132)
 CALL text(2,1,main_menu_title,w)
 CALL text(7,20,inactive_cleanup_status)
 CALL text(16,2,menu_instruction_text)
 CALL accept(16,53,"9;",1
  WHERE curaccept IN (1, 2))
 IF (curaccept)
  GO TO run_cleanup
 ENDIF
 SUBROUTINE findactiveprsnlorgldomaincount(dummyvar)
   SELECT INTO "nl:"
    cnt = count(*)
    FROM prsnl p,
     prsnl_org_reltn por,
     organization o,
     logical_domain l,
     logical_domain l2
    PLAN (p
     WHERE p.active_ind=1
      AND  NOT (cnvtupper(p.username) IN (cnvtupper("CERNER"), cnvtupper("SYSTEM"), cnvtupper(
      "SYSTEMOE"))))
     JOIN (por
     WHERE por.person_id=p.person_id
      AND por.active_ind=1
      AND por.end_effective_dt_tm >= sysdate)
     JOIN (o
     WHERE por.organization_id=o.organization_id
      AND o.logical_domain_id != p.logical_domain_id)
     JOIN (l
     WHERE p.logical_domain_id=l.logical_domain_id)
     JOIN (l2
     WHERE o.logical_domain_id=l2.logical_domain_id)
    ORDER BY p.name_full_formatted, o.org_name
    DETAIL
     total_active_rows = cnt
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "ERROR 001: Issue in retrieving prsnl org relation count."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadactiveprsnlorglogicaldata(dummyvar)
   SET row_nbr = 0
   SELECT INTO "nl:"
    FROM prsnl p,
     prsnl_org_reltn por,
     organization o,
     logical_domain l,
     logical_domain l2
    PLAN (p
     WHERE p.active_ind=1
      AND  NOT (cnvtupper(p.username) IN (cnvtupper("CERNER"), cnvtupper("SYSTEM"), cnvtupper(
      "SYSTEMOE"))))
     JOIN (por
     WHERE por.person_id=p.person_id
      AND por.active_ind=1
      AND por.end_effective_dt_tm >= sysdate)
     JOIN (o
     WHERE por.organization_id=o.organization_id
      AND o.logical_domain_id != p.logical_domain_id)
     JOIN (l
     WHERE p.logical_domain_id=l.logical_domain_id)
     JOIN (l2
     WHERE o.logical_domain_id=l2.logical_domain_id)
    ORDER BY p.name_full_formatted, o.org_name
    DETAIL
     row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
      rowlist[row_nbr].celllist,tot_col),
     reply->rowlist[row_nbr].celllist[1].string_value = p.name_full_formatted, reply->rowlist[row_nbr
     ].celllist[2].string_value = p.username, reply->rowlist[row_nbr].celllist[3].double_value = p
     .logical_domain_id,
     reply->rowlist[row_nbr].celllist[4].string_value = l.mnemonic, reply->rowlist[row_nbr].celllist[
     5].string_value = o.org_name, reply->rowlist[row_nbr].celllist[6].double_value = o
     .logical_domain_id,
     reply->rowlist[row_nbr].celllist[7].string_value = l2.mnemonic, reply->rowlist[row_nbr].
     celllist[8].double_value = por.prsnl_org_reltn_id
    WITH nocounter, expand = 2
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "ERROR 002: Issue in loading prsnl org relation data."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE cleanupcrosslogidomdata(dummyvar)
   IF (size(reply->rowlist,5) > tot_exec_per_itr)
    SET lower_bound = 1
    SET upper_bound = tot_exec_per_itr
    SET clone_reply_size = size(reply->rowlist,5)
    WHILE (clone_reply_size > 0)
     UPDATE  FROM prsnl_org_reltn por
      SET por.active_ind = 0, por.active_status_cd = code_value_deleted, por.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       por.updt_applctx = 279346.0, por.updt_cnt = (por.updt_cnt+ 1), por.updt_id = reqinfo->updt_id,
       por.updt_task = 3202004, por.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      PLAN (por
       WHERE expand(num,lower_bound,upper_bound,por.prsnl_org_reltn_id,reply->rowlist[num].celllist[8
        ].double_value))
      WITH nocounter, expand = 2
     ;end update
     IF (ierrcode > 0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "ERROR 003: Issue in updating prsnl org data."
      GO TO exit_script
     ELSE
      CALL echo(build("Prsnl Org Relation records updated: ",upper_bound))
      SET clone_reply_size = (clone_reply_size - tot_exec_per_itr)
      IF (clone_reply_size > 0)
       CALL echo(build("Records yet to update: ",clone_reply_size))
      ELSE
       CALL echo(build("Records yet to update: ",0))
      ENDIF
      SET lower_bound = (upper_bound+ 1)
      SET upper_bound = (upper_bound+ tot_exec_per_itr)
      IF (upper_bound >= size(reply->rowlist,5))
       SET upper_bound = size(reply->rowlist,5)
      ENDIF
      COMMIT
     ENDIF
    ENDWHILE
   ELSE
    UPDATE  FROM prsnl_org_reltn por
     SET por.active_ind = 0, por.active_status_cd = code_value_deleted, por.end_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
      por.updt_applctx = 279346.0, por.updt_cnt = (por.updt_cnt+ 1), por.updt_id = reqinfo->updt_id,
      por.updt_task = 3202004, por.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (por
      WHERE expand(num,1,size(reply->rowlist,5),por.prsnl_org_reltn_id,reply->rowlist[num].celllist[8
       ].double_value))
     WITH nocounter, expand = 2
    ;end update
    IF (ierrcode > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname =
     "ERROR 003: Issue in updating prsnl org data."
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE findinactiveprsnlorgldomaincount(dummyvar)
   SELECT INTO "nl:"
    cnt = count(*)
    FROM prsnl p,
     prsnl_org_reltn por,
     organization o,
     logical_domain l,
     logical_domain l2
    PLAN (p
     WHERE p.active_ind=0
      AND  NOT (cnvtupper(p.username) IN (cnvtupper("CERNER"), cnvtupper("SYSTEM"), cnvtupper(
      "SYSTEMOE"))))
     JOIN (por
     WHERE por.person_id=p.person_id
      AND por.active_ind=1
      AND por.end_effective_dt_tm >= sysdate)
     JOIN (o
     WHERE por.organization_id=o.organization_id
      AND o.logical_domain_id != p.logical_domain_id)
     JOIN (l
     WHERE p.logical_domain_id=l.logical_domain_id)
     JOIN (l2
     WHERE o.logical_domain_id=l2.logical_domain_id)
    ORDER BY p.name_full_formatted, o.org_name
    DETAIL
     total_inactive_rows = cnt
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "ERROR 004: Issue in retrieving Inactive prsnl org relation count."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadinactiveprsnlorglogicaldata(dummyvar)
   SET row_nbr = 0
   SELECT INTO "nl:"
    FROM prsnl p,
     prsnl_org_reltn por,
     organization o,
     logical_domain l,
     logical_domain l2
    PLAN (p
     WHERE p.active_ind=0
      AND  NOT (cnvtupper(p.username) IN (cnvtupper("CERNER"), cnvtupper("SYSTEM"), cnvtupper(
      "SYSTEMOE"))))
     JOIN (por
     WHERE por.person_id=p.person_id
      AND por.active_ind=1
      AND por.end_effective_dt_tm >= sysdate)
     JOIN (o
     WHERE por.organization_id=o.organization_id
      AND o.logical_domain_id != p.logical_domain_id)
     JOIN (l
     WHERE p.logical_domain_id=l.logical_domain_id)
     JOIN (l2
     WHERE o.logical_domain_id=l2.logical_domain_id)
    ORDER BY p.name_full_formatted, o.org_name
    DETAIL
     row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
      rowlist[row_nbr].celllist,tot_col),
     reply->rowlist[row_nbr].celllist[1].string_value = p.name_full_formatted, reply->rowlist[row_nbr
     ].celllist[2].string_value = p.username, reply->rowlist[row_nbr].celllist[3].double_value = p
     .logical_domain_id,
     reply->rowlist[row_nbr].celllist[4].string_value = l.mnemonic, reply->rowlist[row_nbr].celllist[
     5].string_value = o.org_name, reply->rowlist[row_nbr].celllist[6].double_value = o
     .logical_domain_id,
     reply->rowlist[row_nbr].celllist[7].string_value = l2.mnemonic, reply->rowlist[row_nbr].
     celllist[8].double_value = por.prsnl_org_reltn_id
    WITH nocounter, expand = 2
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "ERROR 005: Issue in loading inactive prsnl org relation data."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE preparecsvheaders(dummyvar)
   SET stat = alterlist(reply->collist,7)
   SET reply->collist[1].header_text = "Name"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Username"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "User Logical Domain"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Domain Mnemonic"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Organization Name"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Org Logical Domain"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "Mnemonic"
   SET reply->collist[7].data_type = 1
   SET reply->collist[7].hide_ind = 0
 END ;Subroutine
 SUBROUTINE preparecsvtowrite(dummyvar)
   SET frec->file_name = output_filename
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
 END ;Subroutine
 SUBROUTINE writereporttocsv(start_row,end_row)
   FOR (x = 1 TO size(reply->collist,5))
     IF (x=1)
      SET header_string = build('"',reply->collist[x].header_text,'"')
     ELSE
      SET header_string = build(header_string,',"',reply->collist[x].header_text,'"')
     ENDIF
   ENDFOR
   SET frec->file_buf = build(header_string)
   SET stat = cclio("WRITE",frec)
   SET frec->file_buf = ""
   FOR (x = start_row TO end_row)
     FOR (y = 1 TO 7)
       SET cell_value = " "
       IF ((reply->rowlist[x].celllist[y].string_value > " "))
        SET cell_value = reply->rowlist[x].celllist[y].string_value
        SET cell_value = replace(cell_value,'"','""',0)
       ELSEIF ((reply->rowlist[x].celllist[y].double_value > 0))
        SET cell_value = cnvtstring(reply->rowlist[x].celllist[y].double_value)
       ELSEIF ((reply->rowlist[x].celllist[y].nbr_value > 0))
        SET cell_value = cnvtstring(reply->rowlist[x].celllist[y].nbr_value)
       ELSEIF ((reply->rowlist[x].celllist[y].date_value > 0))
        SET cell_value = format(reply->rowlist[x].celllist[y].date_value,"mm/dd/yyyy hh:mm;;d")
       ENDIF
       IF (y=1)
        SET row_string = build('"',cell_value,'"')
       ELSE
        SET row_string = build(row_string,',"',cell_value,'"')
       ENDIF
     ENDFOR
     SET frec->file_buf = build(frec->file_buf,char(10),row_string)
     SET stat = cclio("WRITE",frec)
     SET frec->file_buf = ""
   ENDFOR
 END ;Subroutine
 SUBROUTINE closecsvwrittento(dummyvar)
   SET stat = cclio("CLOSE",frec)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  SET reply->output_filename = ""
  CALL echorecord(reply)
 ENDIF
END GO

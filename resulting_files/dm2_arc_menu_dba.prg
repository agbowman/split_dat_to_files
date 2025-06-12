CREATE PROGRAM dm2_arc_menu:dba
 DECLARE arc_error_check(error_header=vc,direction=vc,archive_entity_name=vc) = i2
 DECLARE arc_log_insert(error_header=vc,errormsg=vc,direction=vc,archive_entity_name=vc,
  archive_entity_id=f8,
  run_secs=i4) = null
 DECLARE outside_time_window(null) = i2
 DECLARE stop_at_next_check(mover_name=vc) = i2
 DECLARE arc_replace(stmt_str=vc,link_ind=i2,list_ind=i2,entity_ind=i2,pre_link=vc,
  post_link=vc,entity_id=f8) = vc
 DECLARE update_time_window(null) = i2
 IF (validate(errormsg,"-1")="-1")
  DECLARE errormsg = vc
 ENDIF
 SUBROUTINE arc_error_check(error_header,direction,archive_entity_name)
   IF (error(errormsg,0) != 0)
    ROLLBACK
    SET reply->status_data.subeventstatus.targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    CALL arc_log_insert(error_header,errormsg,direction,archive_entity_name,0.0,
     null)
    COMMIT
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE arc_log_insert(error_header,errormsg,direction,archive_entity_name,archive_entity_id,
  run_secs)
   INSERT  FROM dm_arc_log d
    SET d.dm_arc_log_id = seq(archive_seq,nextval), d.archive_entity_id = archive_entity_id, d
     .run_secs = run_secs,
     d.log_dt_tm = cnvtdatetime(curdate,curtime3), d.direction = direction, d.err_msg = trim(
      substring(1,255,concat(curprog,": ",error_header," ",errormsg))),
     d.archive_entity_name = archive_entity_name, d.instigator_app = reqinfo->updt_app, d
     .instigator_task = reqinfo->updt_task,
     d.instigator_req = reqinfo->updt_req, d.instigator_id = reqinfo->updt_id, d.instigator_applctx
      = reqinfo->updt_applctx,
     d.rdbhandle = currdbhandle, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
     .updt_cnt = 0
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE outside_time_window(null)
   IF ( NOT ((((pers_arc->start_time > pers_arc->stop_time)
    AND (((cnvtmin(curtime) < pers_arc->stop_time)) OR ((cnvtmin(curtime) > pers_arc->start_time))) )
    OR ((((pers_arc->start_time < pers_arc->stop_time)
    AND (cnvtmin(curtime) < pers_arc->stop_time)
    AND (cnvtmin(curtime) > pers_arc->start_time)) OR ((pers_arc->start_time=pers_arc->stop_time)))
   )) ))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE stop_at_next_check(mover_name)
   DECLARE s_mover_state = vc
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="ARCHIVE-PERSON"
     AND d.info_name=mover_name
    DETAIL
     s_mover_state = d.info_char
    WITH nocounter
   ;end select
   IF (arc_error_check("An error occurred while selecting from dm_info: ","ARCHIVE","PERSON")=1)
    RETURN(1)
   ENDIF
   IF (s_mover_state="STOP AT NEXT CHECK")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE arc_replace(arc_stmt_str,arc_link_ind,arc_list_ind,arc_entity_ind,arc_pre_link,
  arc_post_link,arc_entity_id)
   DECLARE s_arc_return_str = vc
   SET s_arc_return_str = arc_stmt_str
   IF (arc_link_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,":pre_link:",nullterm(arc_pre_link),0)
    SET s_arc_return_str = replace(s_arc_return_str,":post_link:",nullterm(arc_post_link),0)
   ENDIF
   IF (arc_list_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,"list","",0)
   ENDIF
   IF (arc_entity_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,"v_archive_entity_id",build(arc_entity_id),0)
    SET s_arc_return_str = replace(s_arc_return_str,"V_ARCHIVE_ENTITY_ID",build(arc_entity_id),0)
   ENDIF
   RETURN(s_arc_return_str)
 END ;Subroutine
 SUBROUTINE update_time_window(null)
  SELECT INTO "nl:"
   di.info_name, di.info_number
   FROM dm_arc_info di
   WHERE di.info_domain="ARCHIVE-PERSON"
    AND cnvtdatetime(curdate,curtime3) BETWEEN beg_effective_dt_tm AND end_effective_dt_tm
   DETAIL
    CASE (di.info_name)
     OF "START AFTER TIME":
      pers_arc->start_time = di.info_number
     OF "STOP BY TIME":
      pers_arc->stop_time = di.info_number
    ENDCASE
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_arc_info rows: ","ARCHIVE","PERSON")=
  1)
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 IF (validate(dai_request->info_domain,"-1")="-1")
  FREE RECORD dai_request
  RECORD dai_request(
    1 info_domain = vc
    1 arc_dt_tm = dq8
  )
 ENDIF
 IF ((validate(dai_reply->names,- (1))=- (1)))
  FREE RECORD dai_reply
  RECORD dai_reply(
    1 names[*]
      2 info_name = vc
      2 info_number = f8
      2 info_char = vc
      2 info_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(dai_ins_request->info_domain,"-1")="-1")
  FREE RECORD dai_ins_request
  RECORD dai_ins_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_number = f8
    1 info_char = vc
    1 info_dt_tm = f8
    1 beg_effective_dt_tm = f8
  )
 ENDIF
 IF ((validate(dai_ins_reply->end_effective_date_time,- (1))=- (1)))
  FREE RECORD dai_ins_reply
  RECORD dai_ins_reply(
    1 end_effective_dt_tm = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 FREE RECORD domains
 FREE RECORD db_link_request
 FREE RECORD menu_archive_db
 RECORD domains(
   1 names[*]
     2 dname = vc
 )
 RECORD db_link_request(
   1 menu_title_text = vc
   1 environment_type = vc
   1 der_relationship_type = vc
   1 dsrdm_db_link_prefix = vc
 )
 RECORD menu_archive_db(
   1 db[*]
     2 name = vc
     2 env_id = f8
     2 active_ind = i2
   1 active_exists = i2
 )
 DECLARE arc_child_in = i2
 DECLARE arc_i_name_ind = i2
 DECLARE arc_d_num = i2
 DECLARE arc_a_num = i2
 DECLARE arc_movers = i4
 DECLARE arc_desc1 = vc
 DECLARE arc_desc2 = vc
 DECLARE arc_ind = i2
 DECLARE arc_minval = f8
 DECLARE arc_done = i2
 DECLARE arc_temp_op_string = vc
 DECLARE arc_act_env_ind = f8
 DECLARE arc_prelink = vc
 DECLARE arc_postlink = vc
 DECLARE arc_startdate = f8 WITH public, noconstant(cnvtdatetime((curdate - 7),0))
 DECLARE arc_enddate = f8 WITH public, noconstant(cnvtdatetime(curdate,235959))
 DECLARE arc_tempdate = vc
 DECLARE arc_errmsg = vc
 DECLARE arc_conn_check_table_name = vc
 DECLARE arc_can_modify = i2
 DECLARE arc_menu_temp_count = i4
 DECLARE archived_cv = f8
 DECLARE arc_menu_env_id = f8
 DECLARE arc_menu_env_name = vc
 DECLARE arc_table_name = vc
 DECLARE archivecheck = vc
 DECLARE v_exp_ndx = i4
 DECLARE v_num_to_check = i4
 DECLARE rest_percent_result = vc
 DECLARE v_date_1800 = f8
 DECLARE v_sample_size = i4
 DECLARE pi_ndx = i4
 DECLARE v_tot_yr_cnt = i2
 DECLARE v_prog_start = f8
 DECLARE v_yr_cnt = i2
 DECLARE arc_report_result = vc
 DECLARE mover_num = i2
 DECLARE v_i18n_handle = i4
 DECLARE v_i18n_return = i4
 DECLARE arc_center = vc
 SET v_i18n_handle = 0
 SET v_i18n_return = uar_i18nlocalizationinit(v_i18n_handle,curprog,"",curcclrev)
 DECLARE find_info_name(i_name=vc) = i2
 DECLARE connection_check(prel=vc,postl=vc) = i2
 SET arc_center = concat(fillstring(130,"#"),";c;")
 SET message = window
 CALL video(r)
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="ARCHIVE-DOMAIN"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(domains->names,cnt), domains->names[cnt].dname = d.info_name
  WITH nocounter
 ;end select
 SET arc_d_num = size(domains->names,5)
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_environment b
  PLAN (a
   WHERE a.info_name="DM_ENV_ID"
    AND a.info_domain="DATA MANAGEMENT")
   JOIN (b
   WHERE a.info_number=b.environment_id)
  DETAIL
   arc_menu_env_id = b.environment_id, arc_menu_env_name = b.environment_name
  WITH nocounter
 ;end select
#domain_select
 IF (arc_d_num > 1)
  CALL header_box(null)
  CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k3","Main menu - Root Table Selection"),
    arc_center))
  CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k4","Please choose an archive root table:"))
  FOR (cnt = 1 TO arc_d_num)
    CALL text((6+ cnt),4,concat(trim(cnvtstring(cnt)),". ",domains->names[cnt].dname))
  ENDFOR
  CALL text(((6+ arc_d_num)+ 1),4,"0. Exit")
  CALL accept(6,40,"9"
   WHERE cnvtreal(curaccept) <= arc_d_num)
  SET arc_child_in = curaccept
  IF (arc_child_in=0)
   GO TO exit_menu
  ENDIF
 ELSE
  SET arc_child_in = 1
 ENDIF
#main
 IF ((domains->names[arc_child_in].dname="PERSON"))
  CALL header_box(null)
  CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k5","PERSON"),arc_center))
  CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k6","1. Define Archive Criteria"))
  CALL text(8,4,uar_i18ngetmessage(v_i18n_handle,"k7","2. Manage Archive Databases"))
  CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k8","3. Manage Archive Movers"))
  CALL text(10,4,uar_i18ngetmessage(v_i18n_handle,"k9","4. Run Archive Reports"))
  IF (size(domains->names,5) > 1)
   CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k10","5. Select a Different Root Table "))
   CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k11","0. Exit"))
  ELSE
   CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k12","0. Exit"))
  ENDIF
  CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k13","Please choose from the following options:"))
  CALL accept(6,50,"9"
   WHERE cnvtreal(curaccept) <= 5)
  SET temp_choice = curaccept
  CASE (temp_choice)
   OF 1:
    WHILE (1=1)
      SET dai_request->info_domain = concat("ARCHIVE-",domains->names[arc_child_in].dname)
      SET dai_request->arc_dt_tm = cnvtdatetime(curdate,curtime3)
      EXECUTE dm2_arc_get_info_by_date  WITH replace(request,dai_request), replace(reply,dai_reply)
      CALL header_box(null)
      CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k148","Define Archive Criteria"),
        arc_center))
      CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k14",concat(
         "Select an archive criteria to view a detailed description and",
         " to access further options(current value is displayed):")))
      SET arc_ind = find_info_name("START AFTER TIME")
      CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k15","1. START AFTER TIME: "))
      IF ((arc_ind != - (1)))
       CALL text(7,45,format(cnvttime(dai_reply->names[arc_ind].info_number),"HH:MM;;M"))
      ENDIF
      SET arc_ind = find_info_name("STOP BY TIME")
      CALL text(8,4,uar_i18ngetmessage(v_i18n_handle,"k16","2. STOP BY TIME: "))
      IF ((arc_ind != - (1)))
       CALL text(8,45,format(cnvttime(dai_reply->names[arc_ind].info_number),"HH:MM;;M"))
      ENDIF
      SET arc_ind = find_info_name("NEXT RESTORE OFFSET")
      CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k17","3. NEXT RESTORE OFFSET: "))
      IF ((arc_ind != - (1)))
       CALL text(9,45,cnvtstring(dai_reply->names[arc_ind].info_number))
      ENDIF
      SET arc_ind = find_info_name("STALE DAYS")
      CALL text(10,4,uar_i18ngetmessage(v_i18n_handle,"k18","4. STALE DAYS: "))
      IF ((arc_ind != - (1)))
       CALL text(10,45,cnvtstring(dai_reply->names[arc_ind].info_number))
      ENDIF
      CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k19","5. NUM MOVERS: "))
      SELECT INTO "nl:"
       d.info_number
       FROM dm_info d
       WHERE (d.info_domain=dai_request->info_domain)
        AND d.info_name="NUM MOVERS"
       DETAIL
        arc_movers = d.info_number
       WITH nocounter
      ;end select
      CALL text(11,45,cnvtstring(arc_movers))
      CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k20","6. Go up one level"))
      CALL text(13,4,uar_i18ngetmessage(v_i18n_handle,"k21","0. Exit program"))
      CALL accept(6,125,"9"
       WHERE cnvtreal(curaccept) <= 6)
      CASE (curaccept)
       OF 1:
        SET arc_ind = find_info_name("START AFTER TIME")
        SET arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k117",
         "Time after which the mover is allowed to run")
        SET arc_desc2 = " "
        SET arc_minval = 0
        SET arc_done = 0
        CALL generate_crit_val_detail_menu(arc_ind,arc_desc1,arc_desc2,arc_minval,uar_i18ngetmessage(
          v_i18n_handle,"k118","START AFTER TIME"))
       OF 2:
        SET arc_ind = find_info_name("STOP BY TIME")
        SET arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k119",
         "Time at which the mover should stop running")
        SET arc_desc2 = " "
        SET arc_minval = 0
        SET arc_done = 0
        CALL generate_crit_val_detail_menu(arc_ind,arc_desc1,arc_desc2,arc_minval,uar_i18ngetmessage(
          v_i18n_handle,"k120","STOP BY TIME"))
       OF 3:
        SET arc_ind = find_info_name("NEXT RESTORE OFFSET")
        SET arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k121",
         "Number of days before a person's next restore date to")
        SET arc_desc2 = uar_i18ngetmessage(v_i18n_handle,"k122","perform the restore")
        SET arc_minval = 1
        SET arc_done = 0
        CALL generate_crit_val_detail_menu(arc_ind,arc_desc1,arc_desc2,arc_minval,uar_i18ngetmessage(
          v_i18n_handle,"k123","NEXT RESTORE OFFSET"))
       OF 4:
        SET arc_ind = find_info_name("STALE DAYS")
        SET arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k124",
         "Minimum number of days since the person was last accessed")
        SET arc_desc2 = uar_i18ngetmessage(v_i18n_handle,"k125",
         "to wait before sending them to the archive database")
        SET arc_minval = 365
        SET arc_done = 0
        CALL generate_crit_val_detail_menu(arc_ind,arc_desc1,arc_desc2,arc_minval,uar_i18ngetmessage(
          v_i18n_handle,"k126","STALE DAYS"))
       OF 5:
        SET arc_done = 0
        WHILE (arc_done=0)
          CALL header_box(null)
          CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k22",
             "Detailed Description - NUM MOVERS"),arc_center))
          CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k23","Description of criteria-"))
          CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k24",
            "Number of movers to run concurrently to perform archives and restores"))
          CALL text(8,4,uar_i18ngetmessage(v_i18n_handle,"k25",
            "Note: You should have an extra instance of the CPM ASYNC SCRIPT server (server 54)"))
          CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k26",
            "      running for each archive mover."))
          CALL text(11,4,uar_i18nbuildmessage(v_i18n_handle,"k27","Current Value: %1","i",arc_movers
            ))
          CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k28",
            "Please choose one of the following options:"))
          CALL text(13,4,uar_i18ngetmessage(v_i18n_handle,"k29","1. Modify"))
          CALL text(14,4,uar_i18ngetmessage(v_i18n_handle,"k30","2. Up One Level"))
          CALL text(15,4,uar_i18ngetmessage(v_i18n_handle,"k31","0. Exit Program"))
          CALL accept(12,50,"9"
           WHERE cnvtreal(curaccept) <= 2)
          CASE (curaccept)
           OF 1:
            CALL text(11,35,uar_i18ngetmessage(v_i18n_handle,"k32","(Minimum Value: 0)"))
            CALL accept(11,19,"9(8);H",cnvtstring(arc_movers)
             WHERE cnvtreal(curaccept) >= 0)
            SET newval = curaccept
            UPDATE  FROM dm_info d
             SET d.info_number = newval
             WHERE d.info_domain="ARCHIVE-PERSON"
              AND d.info_name="NUM MOVERS"
            ;end update
            IF (curqual=0)
             INSERT  FROM dm_info d
              SET d.info_number = newval, d.info_domain = "ARCHIVE-PERSON", d.info_name =
               "NUM MOVERS"
             ;end insert
            ENDIF
            IF (newval < arc_movers)
             CALL parser("update into dm_info d ",0)
             CALL parser("set d.info_char = 'STOP AT NEXT CHECK', ",0)
             CALL parser("d.info_date = cnvtdatetime(curdate,curtime3) ",0)
             CALL parser("where d.info_name in (",0)
             FOR (mover_num = (newval+ 1) TO arc_movers)
              CALL parser(build("'ARCHIVE MOVER",mover_num,"'"),0)
              IF (mover_num < arc_movers)
               CALL parser(", ",0)
              ENDIF
             ENDFOR
             CALL parser(") with nocounter go",1)
            ENDIF
            SET arc_movers = newval
            COMMIT
           OF 2:
            SET arc_done = 1
           OF 0:
            GO TO exit_menu
          ENDCASE
        ENDWHILE
       OF 6:
        GO TO main
       OF 0:
        GO TO exit_menu
      ENDCASE
    ENDWHILE
   OF 2:
    SELECT INTO "nl:"
     d.environment_id
     FROM dm_environment d
     WITH nocounter, maxqual(d,1)
    ;end select
    IF (error(arc_errmsg,0) != 0)
     CALL text(13,5,uar_i18ngetmessage(v_i18n_handle,"k33",
       "***ERROR: The ADMIN DB must be running in order to access this menu***"))
     CALL pause(3)
     GO TO main
    ENDIF
    WHILE (1=1)
      SET stat = alterlist(menu_archive_db->db,0)
      SET menu_archive_db->active_exists = 0
      SET db_link_request->menu_title_text = ""
      SET db_link_request->environment_type = ""
      SET db_link_request->der_relationship_type = ""
      SET db_link_request->dsrdm_db_link_prefix = ""
      SELECT INTO "nl:"
       d.info_number
       FROM dm_arc_info d
       WHERE d.info_domain="ARCHIVE-PERSON"
        AND d.info_name="ACTIVE ARCHIVE"
       DETAIL
        arc_act_env_ind = d.info_number
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       e.environment_id, e.environment_name
       FROM dm_environment e
       WHERE  EXISTS (
       (SELECT
        d.env_id
        FROM dm_arc_env d
        WHERE e.environment_id=d.env_id))
       HEAD REPORT
        cnt = 0
       DETAIL
        cnt = (cnt+ 1), stat = alterlist(menu_archive_db->db,cnt), menu_archive_db->db[cnt].name = e
        .environment_name,
        menu_archive_db->db[cnt].env_id = e.environment_id
        IF (arc_act_env_ind=e.environment_id)
         menu_archive_db->db[cnt].active_ind = 1, menu_archive_db->active_exists = 1
        ENDIF
       WITH nocounter
      ;end select
      SET arc_a_num = size(menu_archive_db->db,5)
      CALL header_box(null)
      CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k34","Manage Archive Databases"),
        arc_center))
      FOR (arc_ind = 1 TO arc_a_num)
        SET arc_temp_op_string = concat(build(arc_ind),". ",uar_i18ngetmessage(v_i18n_handle,"k137",
          "Manage")," ",menu_archive_db->db[arc_ind].name)
        IF ((menu_archive_db->db[arc_ind].active_ind=1))
         SET arc_temp_op_string = concat(arc_temp_op_string," ",uar_i18ngetmessage(v_i18n_handle,
           "k138","(TARGET ARCHIVE DB)"))
        ENDIF
        CALL text((6+ arc_ind),4,arc_temp_op_string)
      ENDFOR
      CALL text(((6+ arc_a_num)+ 1),4,uar_i18nbuildmessage(v_i18n_handle,"k36","%1. Add","i",(
        arc_a_num+ 1)))
      CALL text(((6+ arc_a_num)+ 2),4,uar_i18nbuildmessage(v_i18n_handle,"k37","%1. Go up one level",
        "i",(arc_a_num+ 2)))
      CALL text(((6+ arc_a_num)+ 3),4,uar_i18ngetmessage(v_i18n_handle,"k38","0. Exit"))
      CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k39",
        "Please choose from the following options:"))
      CALL accept(6,50,"9"
       WHERE (cnvtreal(curaccept) <= (arc_a_num+ 2)))
      SET temp_accept = curaccept
      CASE (temp_accept)
       OF (arc_a_num+ 1):
        SET db_link_request->menu_title_text = "SETUP ARCHIVE DB LINK"
        SET db_link_request->environment_type = "ARCHIVE"
        SET db_link_request->der_relationship_type = "ARCHIVE DB"
        SET db_link_request->dsrdm_db_link_prefix = "ARCHIVE"
        EXECUTE dm2_setup_db_link  WITH replace(request,db_link_request)
       OF (arc_a_num+ 2):
        GO TO main
       OF 0:
        GO TO exit_menu
       ELSE
        IF (arc_a_num > 0
         AND temp_accept <= arc_a_num)
         SET arc_done = 0
         WHILE (arc_done=0)
           SELECT INTO "nl:"
            d.post_link_name, d.pre_link_name
            FROM dm_arc_env d
            WHERE (d.env_id=menu_archive_db->db[temp_accept].env_id)
            HEAD REPORT
             arc_prelink = "", arc_postlink = ""
            DETAIL
             IF (currdb="ORACLE")
              arc_postlink = d.post_link_name
             ELSE
              arc_prelink = d.pre_link_name
             ENDIF
            WITH nocounter
           ;end select
           CALL header_box(null)
           SET arc_desc1 = concat(uar_i18ngetmessage(v_i18n_handle,"k40","Manage")," ",
            menu_archive_db->db[temp_accept].name)
           CALL text(3,2,format(arc_desc1,arc_center))
           CALL text(6,4,uar_i18nbuildmessage(v_i18n_handle,"k41","Environment ID: %1","s",
             cnvtstring(menu_archive_db->db[temp_accept].env_id)))
           IF (currdb="ORACLE")
            CALL text(7,4,uar_i18nbuildmessage(v_i18n_handle,"k42","Postlink Name: %1","s",
              arc_postlink))
           ELSE
            CALL text(7,4,uar_i18nbuildmessage(v_i18n_handle,"k43","Prelink Name: %1","s",
              arc_prelink))
           ENDIF
           CALL text(10,4,uar_i18ngetmessage(v_i18n_handle,"k44","1. Modify"))
           CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k45","2. Set As Current Target"))
           CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k46","3. Test Connection"))
           CALL text(13,4,uar_i18ngetmessage(v_i18n_handle,"k47","4. Drop This Relation"))
           CALL text(14,4,uar_i18ngetmessage(v_i18n_handle,"k48","5. Go up one level"))
           CALL text(15,4,uar_i18ngetmessage(v_i18n_handle,"k49","0. Exit"))
           CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k50",
             "Please choose from the following options: "))
           CALL accept(9,50,"9"
            WHERE cnvtreal(curaccept) <= 5)
           CASE (curaccept)
            OF 1:
             CALL header_box(null)
             SET arc_desc1 = concat(uar_i18ngetmessage(v_i18n_handle,"k51","Manage")," ",
              menu_archive_db->db[temp_accept].name)
             CALL text(3,2,format(arc_desc1,arc_center))
             SET archivecheck = concat("select into 'nl:' arccnt = count(*) from ",trim(arc_prelink),
              "dm_arc_activity",trim(arc_postlink)," where archive_entity_id > 0 ",
              "detail arc_menu_temp_count = arccnt ","with nocounter go")
             CALL parser(archivecheck)
             IF (arc_menu_temp_count > 0)
              CALL pause(2)
              CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k52",concat(
                 "There are currently person(s) archived in this environment.",
                 "They must be restored before the environment can be modified")))
              CALL pause(3)
             ELSE
              CALL header_box(null)
              CALL text(3,2,format(arc_desc1,arc_center))
              CALL text(6,4,uar_i18nbuildmessage(v_i18n_handle,"k54","Environment ID: %1","f",
                menu_archive_db->db[temp_accept].env_id))
              CALL text(10,4,uar_i18ngetmessage(v_i18n_handle,"k55","1. Modify"))
              CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k56","2. Set As Current Target"))
              CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k57","3. Test Connection"))
              CALL text(13,4,uar_i18ngetmessage(v_i18n_handle,"k58","4. Drop This Relation"))
              CALL text(14,4,uar_i18ngetmessage(v_i18n_handle,"k59","5. Go up one level"))
              CALL text(15,4,uar_i18ngetmessage(v_i18n_handle,"k60","0. Exit"))
              IF (currdb="ORACLE")
               CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k61","Enter new postlink name:"))
               CALL text(7,65,uar_i18ngetmessage(v_i18n_handle,"k62","(i.e. @dm3a1)"))
               CALL accept(7,30,"P(30);CU",arc_postlink
                WHERE curaccept=patstring("@*"))
               SET arc_postlink = curaccept
               SET arc_prelink = ""
              ELSE
               CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k63","Enter new prelink name:"))
               CALL text(7,65,uar_i18ngetmessage(v_i18n_handle,"k64","(i.e. dm3a1.)"))
               CALL accept(7,30,"P(29);CU",arc_prelink
                WHERE curaccept=patstring("*."))
               SET arc_prelink = curaccept
               SET arc_postlink = ""
              ENDIF
              UPDATE  FROM dm_arc_env d
               SET d.pre_link_name = arc_prelink, d.post_link_name = arc_postlink
               WHERE (d.env_id=menu_archive_db->db[temp_accept].env_id)
              ;end update
              COMMIT
             ENDIF
            OF 2:
             IF (connection_check(arc_prelink,arc_postlink)=1)
              UPDATE  FROM dm_arc_info d
               SET d.info_number = menu_archive_db->db[temp_accept].env_id
               WHERE d.info_domain="ARCHIVE-PERSON"
                AND d.info_name="ACTIVE ARCHIVE"
              ;end update
              IF (curqual=0)
               INSERT  FROM dm_arc_info d
                SET d.dm_arc_info_id = seq(dm_clinical_seq,nextval), d.info_domain = "ARCHIVE-PERSON",
                 d.info_name = "ACTIVE ARCHIVE",
                 d.info_number = menu_archive_db->db[temp_accept].env_id, d.updt_id = reqinfo->
                 updt_id, d.updt_task = reqinfo->updt_task,
                 d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3
                  ), d.updt_cnt = 0
               ;end insert
              ENDIF
              CALL text(18,4,uar_i18ngetmessage(v_i18n_handle,"k65",
                "****DB has been set as current target****"))
              CALL pause(2)
              IF (error(arc_errmsg,0)=0)
               COMMIT
              ENDIF
             ENDIF
            OF 3:
             SET conncheck = connection_check(arc_prelink,arc_postlink)
             IF (conncheck=0)
              CALL pause(2)
              CALL text(18,4,uar_i18nbuildmessage(v_i18n_handle,"k66",
                "****An error occured: %1 ****","s",arc_errmsg))
              CALL pause(5)
             ELSE
              CALL pause(2)
              CALL text(18,4,uar_i18ngetmessage(v_i18n_handle,"k67","****Connection successful!****")
               )
              CALL pause(3)
             ENDIF
            OF 4:
             SET arc_menu_temp_count = 0
             SET archivecheck = concat("select into 'nl:' arccnt = count(*) from ",trim(arc_prelink),
              "dm_arc_activity",trim(arc_postlink)," where archive_entity_id > 0 ",
              "detail arc_menu_temp_count = arccnt ","with nocounter go")
             CALL parser(archivecheck)
             IF (arc_menu_temp_count=0)
              DELETE  FROM dm_arc_env d
               WHERE (d.env_id=menu_archive_db->db[temp_accept].env_id)
              ;end delete
              COMMIT
              SET arc_done = 1
             ELSE
              CALL pause(2)
              CALL text(18,4,uar_i18ngetmessage(v_i18n_handle,"k68",
                "****Database must be empty before it can be deleted!****"))
              CALL pause(3)
             ENDIF
            OF 5:
             SET arc_done = 1
            OF 0:
             GO TO exit_menu
           ENDCASE
         ENDWHILE
        ENDIF
      ENDCASE
    ENDWHILE
   OF 3:
    WHILE (1=1)
      CALL header_box(null)
      CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k69","Manage Archive Movers"),arc_center
        ))
      CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k70","1. Current Mover Status"))
      CALL text(8,4,uar_i18ngetmessage(v_i18n_handle,"k71","2. Go up one level"))
      CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k72","0. Exit"))
      CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k73",
        "Please choose from the following options:"))
      CALL accept(6,50,"9"
       WHERE cnvtreal(curaccept) <= 2)
      SET temp_choice = curaccept
      CASE (temp_choice)
       OF 1:
        SELECT
         iname = substring(1,15,d.info_name), ichar = substring(1,20,d.info_char), d.info_number,
         status = format(d.info_date,";;Q")
         FROM dm_info d
         WHERE d.info_domain="ARCHIVE-PERSON"
          AND d.info_name="ARCHIVE MOVER*"
         ORDER BY d.info_name
         HEAD REPORT
          col 0, "Name", col 17,
          "Status", col 39, "Status Date",
          row + 1
         DETAIL
          col 0, iname, col 17,
          ichar, col 39, status,
          row + 1
        ;end select
       OF 2:
        GO TO main
       OF 0:
        GO TO exit_menu
      ENDCASE
    ENDWHILE
   OF 4:
    WHILE (1=1)
      CALL header_box(null)
      CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k74","Run Archive Reports"),arc_center))
      CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k75","1. Number of archives"))
      CALL text(8,4,uar_i18ngetmessage(v_i18n_handle,"k76","2. Number of restores"))
      CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k77",
        "3. Number of combines that initiated restores"))
      CALL text(10,4,uar_i18ngetmessage(v_i18n_handle,"k78","4. Average time for an archive"))
      CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k79","5. Average time for a restore"))
      CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k80","6. List of errors"))
      CALL text(13,4,uar_i18ngetmessage(v_i18n_handle,"k81","7. Number of persons in archive"))
      CALL text(14,4,uar_i18ngetmessage(v_i18n_handle,"k82","8. Estimated bytes used in archive"))
      CALL text(15,4,uar_i18ngetmessage(v_i18n_handle,"k83",
        "9. Estimate number of persons to be archived"))
      CALL text(16,4,uar_i18ngetmessage(v_i18n_handle,"k84","10. Estimated % restores per encounter"
        ))
      CALL text(17,4,uar_i18ngetmessage(v_i18n_handle,"k85","11. Go up one level"))
      CALL text(18,4,uar_i18ngetmessage(v_i18n_handle,"k86","0. Exit"))
      CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k87",
        "Please choose form the following options:"))
      CALL accept(6,50,"99"
       WHERE cnvtreal(curaccept) <= 11)
      SET temp_choice = curaccept
      CASE (temp_choice)
       OF 1:
        CALL request_dates(null)
        SELECT
         number_archived = count(*)
         FROM dm_arc_log
         WHERE direction="ARCHIVE"
          AND run_secs > 0
          AND log_dt_tm BETWEEN cnvtdatetime(arc_startdate) AND cnvtdatetime(arc_enddate)
        ;end select
       OF 2:
        CALL request_dates(null)
        SELECT
         number_restored = count(*)
         FROM dm_arc_log
         WHERE direction="RESTORE"
          AND run_secs > 0
          AND log_dt_tm BETWEEN cnvtdatetime(arc_startdate) AND cnvtdatetime(arc_enddate)
        ;end select
       OF 3:
        CALL request_dates(null)
        SELECT
         d.instigator_app, restored = count(*)
         FROM dm_arc_log d
         WHERE direction="RESTORE"
          AND d.err_msg=""
          AND d.log_dt_tm BETWEEN cnvtdatetime(arc_startdate) AND cnvtdatetime(arc_enddate)
          AND d.instigator_app IN (70000, 11, 100000)
         GROUP BY d.instigator_app
         DETAIL
          IF (d.instigator_app=11)
           col 0, "From ESI: ", col 12,
           restored
          ELSEIF (d.instigator_app=70000)
           col 0, "From combine tool: ", col 19,
           restored
          ELSE
           col 0, "From PM post processing: ", col 25,
           restored
          ENDIF
          row + 2
        ;end select
       OF 4:
        CALL request_dates(null)
        SELECT
         average_archive_time = avg(run_secs)
         FROM dm_arc_log
         WHERE direction="ARCHIVE"
          AND run_secs >= 0
          AND log_dt_tm BETWEEN cnvtdatetime(arc_startdate) AND cnvtdatetime(arc_enddate)
        ;end select
       OF 5:
        CALL request_dates(null)
        SELECT
         average_restore_time = avg(run_secs)
         FROM dm_arc_log
         WHERE direction="RESTORE"
          AND run_secs >= 0
          AND log_dt_tm BETWEEN cnvtdatetime(arc_startdate) AND cnvtdatetime(arc_enddate)
        ;end select
       OF 6:
        CALL request_dates(null)
        SELECT
         direction, date = format(log_dt_tm,";;Q"), err_msg
         FROM dm_arc_log
         WHERE run_secs=null
          AND err_msg != ""
          AND log_dt_tm BETWEEN cnvtdatetime(arc_startdate) AND cnvtdatetime(arc_enddate)
        ;end select
       OF 7:
        FREE RECORD arc_env
        RECORD arc_env(
          1 env[*]
            2 env_name = vc
            2 prelink = vc
            2 postlink = vc
            2 count = f8
        )
        SELECT INTO "nl:"
         er.post_link_name, er.pre_link_name, de.environment_name
         FROM dm_arc_env er,
          dm_environment de
         WHERE er.env_id=de.environment_id
         HEAD REPORT
          cnt = 0
         DETAIL
          cnt = (cnt+ 1), stat = alterlist(arc_env->env,cnt), arc_env->env[cnt].prelink = er
          .pre_link_name,
          arc_env->env[cnt].postlink = er.post_link_name, arc_env->env[cnt].env_name = de
          .environment_name
         WITH nocounter
        ;end select
        FOR (count_ndx = 1 TO size(arc_env->env,5))
         SET arc_table_name = build(nullterm(arc_env->env[count_ndx].prelink),"dm_arc_activity",
          nullterm(arc_env->env[count_ndx].postlink))
         SELECT INTO "nl:"
          cnt = count(DISTINCT archive_entity_id)
          FROM (parser(arc_table_name))
          WHERE archive_entity_name="PERSON"
           AND archive_entity_id > 0
          DETAIL
           arc_env->env[count_ndx].count = cnt
          WITH nocounter
         ;end select
        ENDFOR
        SELECT
         *
         FROM (dummyt d  WITH seq = size(arc_env->env,5))
         HEAD REPORT
          col 0, "Archive Environment", col 30,
          "Count"
         DETAIL
          row + 1, col 0, arc_env->env[d.seq].env_name,
          col 30, arc_env->env[d.seq].count
         WITH nocounter
        ;end select
        FREE RECORD arc_env
       OF 8:
        CALL header_box(null)
        CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k88",
           "Estimate Bytes Used in Archive(s)"),arc_center))
        CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k89","Please wait while query processes."))
        FREE RECORD arc_byte_report
        RECORD arc_byte_report(
          1 env[*]
            2 environment_name = vc
            2 prelink = vc
            2 postlink = vc
            2 tables[*]
              3 table_name = vc
              3 num_rows = i4
              3 bytes_used = f8
            2 tot_rows = i4
            2 tot_bytes = f8
        )
        SELECT INTO "nl:"
         er.post_link_name, er.pre_link_name, de.environment_name
         FROM dm_arc_env er,
          dm_environment de
         WHERE er.env_id=de.environment_id
         HEAD REPORT
          cnt = 0
         DETAIL
          cnt = (cnt+ 1), stat = alterlist(arc_byte_report->env,cnt), arc_byte_report->env[cnt].
          prelink = er.pre_link_name,
          arc_byte_report->env[cnt].postlink = er.post_link_name, arc_byte_report->env[cnt].
          environment_name = de.environment_name
         WITH nocounter
        ;end select
        FOR (count_ndx = 1 TO size(arc_byte_report->env,5))
          SET arc_table_name = build(nullterm(arc_byte_report->env[count_ndx].prelink),
           "dm_arc_activity",nullterm(arc_byte_report->env[count_ndx].postlink))
          CALL parser("select into 'nl:' ",0)
          CALL parser("d.table_name, x = sum(d.num_rows) from ",0)
          CALL parser(arc_table_name,0)
          CALL parser(" d ",0)
          CALL parser("group by d.table_name ",0)
          CALL parser("head report ",0)
          CALL parser("cnt = 0 ",0)
          CALL parser("detail ",0)
          CALL parser("cnt = cnt + 1 ",0)
          CALL parser("if (mod(cnt, 10) = 1) ",0)
          CALL parser("stat = alterlist(arc_byte_report->env[count_ndx]->tables,cnt+9) ",0)
          CALL parser("endif ")
          CALL parser("arc_byte_report->env[count_ndx]->tables[cnt].table_name = d.table_name ",0)
          CALL parser("arc_byte_report->env[count_ndx]->tables[cnt].num_rows = x ",0)
          CALL parser(
           "arc_byte_report->env[count_ndx].tot_rows =  arc_byte_report->env[count_ndx].tot_rows + x ",
           0)
          CALL parser("foot report ",0)
          CALL parser("stat = alterlist(arc_byte_report->env[count_ndx]->tables,cnt) ",0)
          CALL parser("with nocounter go",1)
          SET arc_table_name = build(nullterm(arc_byte_report->env[count_ndx].prelink),"user_tables",
           nullterm(arc_byte_report->env[count_ndx].postlink))
          CALL parser("select into 'nl:' ",0)
          CALL parser(" u.avg_row_len ",0)
          CALL parser(concat("from ",arc_table_name," u "),0)
          CALL parser("where expand(v_exp_ndx, 1, size(arc_byte_report->env[count_ndx]->tables,5), ",
           0)
          CALL parser("u.table_name, arc_byte_report->env[count_ndx]->tables[v_exp_ndx].table_name) ",
           0)
          CALL parser("head report ",0)
          CALL parser("cnt = 0 ",0)
          CALL parser("detail ",0)
          CALL parser("index = locateval(cnt, 1, size(arc_byte_report->env[count_ndx]->tables,5), ",0
           )
          CALL parser("u.table_name, arc_byte_report->env[count_ndx]->tables[cnt].table_name) ",0)
          CALL parser("arc_byte_report->env[count_ndx]->tables[index].bytes_used = ",0)
          CALL parser("u.avg_row_len * arc_byte_report->env[count_ndx]->tables[index].num_rows ",0)
          CALL parser(
           "arc_byte_report->env[count_ndx].tot_bytes = arc_byte_report->env[count_ndx].tot_bytes + ",
           0)
          CALL parser("arc_byte_report->env[count_ndx]->tables[index].bytes_used ",0)
          CALL parser("with nocounter go",1)
        ENDFOR
        SELECT
         *
         FROM (dummyt d  WITH seq = size(arc_byte_report->env,5))
         HEAD REPORT
          arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k139",
           "Archive Environment Space Utilization Report "), col 40, arc_desc1,
          row + 1, arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k140",
           "Summary for all archive environments:"), col 0,
          arc_desc1, row + 1
          FOR (cnt = 1 TO size(arc_byte_report->env,5))
            arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k141","Total rows in "), col 0, arc_desc1,
            col + 1, arc_byte_report->env[cnt].environment_name, col + 1,
            ": ", col + 1, arc_byte_report->env[cnt].tot_rows,
            arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k142","Total bytes used in "), col + 5,
            arc_desc1,
            col + 1, arc_byte_report->env[cnt].environment_name, arc_desc1 = uar_i18ngetmessage(
             v_i18n_handle,"k143","(in MB): "),
            col + 1, arc_desc1, arc_byte_report->env[cnt].tot_bytes = (arc_byte_report->env[cnt].
            tot_bytes/ 1048576),
            col + 1, arc_byte_report->env[cnt].tot_bytes, row + 1
          ENDFOR
          row + 1
         DETAIL
          arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k144","Archive Environment"), col 0,
          arc_desc1,
          arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k145","Table Name"), col 30, arc_desc1,
          arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k146","Row count"), col 50, arc_desc1,
          arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k147","Size (MB)"), col 70, arc_desc1,
          row + 1, col 0, arc_byte_report->env[d.seq].environment_name,
          row + 1
          FOR (cnt = 1 TO size(arc_byte_report->env[d.seq].tables,5))
            col 30, arc_byte_report->env[d.seq].tables[cnt].table_name, col 50,
            arc_byte_report->env[d.seq].tables[cnt].num_rows, arc_byte_report->env[d.seq].tables[cnt]
            .bytes_used = (arc_byte_report->env[d.seq].tables[cnt].bytes_used/ 1048576), col 65,
            arc_byte_report->env[d.seq].tables[cnt].bytes_used, row + 1
          ENDFOR
          BREAK
         WITH nocounter, formfeed = none, maxrow = 1
        ;end select
        FREE RECORD arc_byte_report
       OF 9:
        CALL header_box(null)
        CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k90",
           "Estimate Number of Persons to be Archived"),arc_center))
        CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k91",
          "Enter number of people to base estimate on: "))
        CALL text(6,55,uar_i18ngetmessage(v_i18n_handle,"k91",
          "(If nothing is entered a default of 25 will be used. Minimum Value = 1)"))
        CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k92",
          "Note: The higher the number of people the more accurate, but the longer the process will take."
          ))
        CALL accept(6,48,"99999;H",25
         WHERE curaccept > 0)
        SET v_sample_size = curaccept
        CALL text(23,54,uar_i18ngetmessage(v_i18n_handle,"k93","***Query is processing***"))
        FREE SET v_max_years
        DECLARE v_max_years = i2 WITH constant(19)
        RECORD years(
          1 data[v_max_years]
            2 num_pers = f8
            2 start_date = dq8
            2 end_date = dq8
            2 sum_bytes = f8
            2 sample_pers = i4
        )
        RECORD ap(
          1 tabs[*]
            2 parent_table = vc
            2 parent_column = vc
            2 child_table = vc
            2 child_column = vc
            2 child_where = vc
            2 from_str = vc
            2 where_str = vc
            2 select_str = vc
            2 count_str = vc
            2 assign_str = vc
            2 echo_str = vc
            2 found_ind = i2
            2 count_val = f8
            2 avg_row_len = i4
            2 exclude_ind = i2
        )
        RECORD pers(
          1 ids[*]
            2 person_id = f8
        )
        SELECT INTO "nl:"
         t1.year_count, t1.years_old
         FROM (
          (
          (SELECT
           year_count = count(*), years_old = floor((datetimediff(sysdate,p.last_accessed_dt_tm)/ 365
            ))
           FROM person p
           WHERE p.ft_entity_id=0
           GROUP BY floor((datetimediff(sysdate,p.last_accessed_dt_tm)/ 365))
           WITH sqltype("I4","I4")))
          t1)
         DETAIL
          IF (t1.years_old BETWEEN 1 AND v_max_years)
           years->data[t1.years_old].num_pers = t1.year_count
          ENDIF
         WITH nocounter
        ;end select
        SET v_tot_yr_cnt = 0
        FOR (yr_ndx = 1 TO v_max_years)
          IF ((years->data[yr_ndx].num_pers >= 1000))
           SET v_tot_yr_cnt = (v_tot_yr_cnt+ 1)
          ENDIF
        ENDFOR
        CALL get_arc_cnt_str(1)
        SET v_yr_cnt = 0
        SET v_prog_start = sysdate
        FOR (yr_ndx = 1 TO v_max_years)
          IF ((years->data[yr_ndx].num_pers >= 1000))
           SET v_yr_cnt = (v_yr_cnt+ 1)
           SET years->data[yr_ndx].end_date = cnvtlookbehind(build(yr_ndx,",Y"),sysdate)
           SET years->data[yr_ndx].start_date = cnvtlookbehind("1,Y",years->data[yr_ndx].end_date)
           SET v_start_date = years->data[yr_ndx].start_date
           SET v_end_date = years->data[yr_ndx].end_date
           SELECT INTO "nl:"
            t.person_id
            FROM person t
            WHERE t.last_accessed_dt_tm BETWEEN cnvtdatetime(v_start_date) AND cnvtdatetime(
             v_end_date)
             AND t.ft_entity_id=0
            HEAD REPORT
             pers_cnt = 0, stat = alterlist(pers->ids,v_sample_size)
            DETAIL
             pers_cnt = (pers_cnt+ 1), pers->ids[pers_cnt].person_id = t.person_id
            FOOT REPORT
             stat = alterlist(pers->ids,pers_cnt), years->data[yr_ndx].sample_pers = pers_cnt
            WITH maxqual(t,value(v_sample_size)), nocounter
           ;end select
           FOR (t_ndx = 1 TO size(ap->tabs,5))
             IF ((ap->tabs[t_ndx].exclude_ind=0))
              SET ap->tabs[t_ndx].count_val = 0
              SET message = - (1)
              CALL parser(ap->tabs[t_ndx].count_str)
              SET message = 10
              SET years->data[yr_ndx].sum_bytes = (years->data[yr_ndx].sum_bytes+ (ap->tabs[t_ndx].
              count_val * ap->tabs[t_ndx].avg_row_len))
              IF (v_yr_cnt > 1)
               CALL text(23,20,uar_i18nbuildmessage(v_i18n_handle,"k94",
                 "Working on year %1 of %2: %3 % of tables checked. Estimated time remaining = %4 minutes.",
                 "iiss",v_yr_cnt,
                 v_tot_yr_cnt,format((100.0 * ((1.0 * t_ndx)/ size(ap->tabs,5))),"###.##"),format(((
                  1.0 * (datetimediff(sysdate,v_prog_start,4)/ (((((v_yr_cnt - 1) * size(ap->tabs,5))
                  + t_ndx) * 1.0)/ (v_tot_yr_cnt * size(ap->tabs,5))))) - datetimediff(sysdate,
                   v_prog_start,4)),"####.##")))
              ELSE
               CALL text(23,43,uar_i18nbuildmessage(v_i18n_handle,"k95",
                 "Working on year %1 of %2: %3% of tables checked.","iis",v_yr_cnt,
                 v_tot_yr_cnt,format((100.0 * ((1.0 * t_ndx)/ size(ap->tabs,5))),"###.##")))
              ENDIF
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
        SELECT
         *
         FROM (dummyt d  WITH seq = size(years->data,5))
         DETAIL
          IF ((years->data[d.seq].num_pers >= 1000))
           arc_report_result = uar_i18nbuildmessage(v_i18n_handle,"k148",
            "%1 to %2: %3 MB for %4 persons.","sssf",format(years->data[d.seq].start_date,
             "YYYY-MM-DD;;d"),
            format(years->data[d.seq].end_date,"YYYY-MM-DD;;d"),format((((years->data[d.seq].
             sum_bytes/ (1024 * 1024))/ years->data[d.seq].sample_pers) * years->data[d.seq].num_pers
             ),"#######.##"),years->data[d.seq].num_pers), col 0, arc_report_result,
           row + 1
          ENDIF
         WITH nocounter
        ;end select
        FREE RECORD years
        FREE RECORD ap
        FREE RECORD pers
       OF 10:
        CALL header_box(null)
        CALL text(3,2,format(uar_i18ngetmessage(v_i18n_handle,"k96",
           "Estimate Percent Restores Per Encounter"),arc_center))
        CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k97",
          "Enter number of people to base estimate on: "))
        CALL text(6,55,uar_i18ngetmessage(v_i18n_handle,"k98",
          "(If nothing is entered a default of 10000 will be used. Minimum Value = 1)"))
        CALL text(7,4,uar_i18ngetmessage(v_i18n_handle,"k99",
          "Note: The higher the number of people the more accurate, but the longer the process will take."
          ))
        CALL accept(6,48,"99999;H",10000
         WHERE curaccept > 0)
        SET v_num_to_check = curaccept
        CALL text(23,54,uar_i18ngetmessage(v_i18n_handle,"k100","***Query is processing***"))
        FREE SET v_max_gap
        DECLARE v_max_gap = i2 WITH constant(10)
        FREE RECORD years
        RECORD years(
          1 data[v_max_gap]
            2 count = i4
        )
        SELECT
         e.reg_dt_tm, e.disch_dt_tm, e.person_id
         FROM encounter e
         WHERE e.person_id IN (
         (SELECT DISTINCT
          e2.person_id
          FROM encounter e2
          WHERE e2.reg_dt_tm > cnvtdatetime(cnvtlookbehind("3,Y",sysdate))
          WITH maxqual(e2,value(v_num_to_check))))
          AND e.disch_dt_tm > cnvtdatetime(cnvtlookbehind("15,Y",sysdate))
         ORDER BY e.person_id, e.reg_dt_tm
         HEAD REPORT
          tot_enc = 0, tot_pers = 0
         HEAD e.person_id
          prev_disch = cnvtdatetime(curdate,curtime3), prev_pid = 0, tot_pers = (tot_pers+ 1)
         DETAIL
          tot_enc = (tot_enc+ 1)
          IF (prev_pid=e.person_id)
           pers_years = floor((datetimediff(e.reg_dt_tm,prev_disch)/ 365))
           IF (pers_years >= 1)
            IF (pers_years < v_max_gap)
             years->data[pers_years].count = (years->data[pers_years].count+ 1)
            ELSE
             years->data[v_max_gap].count = (years->data[v_max_gap].count+ 1)
            ENDIF
           ENDIF
          ENDIF
          prev_disch = e.disch_dt_tm, prev_pid = e.person_id
         FOOT REPORT
          arc_desc1 = uar_i18ngetmessage(v_i18n_handle,"k100","Number of persons actually checked: "),
          col 0, arc_desc1,
          col + 1, tot_pers, row + 1,
          run_tot = 0.0
          FOR (i = 1 TO 10)
            run_tot = (run_tot+ years->data[((v_max_gap+ 1) - i)].count), rest_percent_result =
            uar_i18nbuildmessage(v_i18n_handle,"k101",
             "Estimated % restores if stale time set to %1 year(s): %2% (%3/%4 encounters)",
             "ssff",format(((v_max_gap+ 1) - i),"##"),
             format(((run_tot/ tot_enc) * 100.0),"##.##"),run_tot,tot_enc), col 0,
            rest_percent_result, row + 1
          ENDFOR
         WITH nocounter
        ;end select
       OF 11:
        GO TO main
       OF 0:
        GO TO exit_menu
      ENDCASE
    ENDWHILE
   OF 5:
    GO TO domain_select
   OF 0:
    GO TO exit_menu
  ENDCASE
 ENDIF
 SUBROUTINE header_box(null)
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,5,132)
   CALL clear(2,2,130)
   CALL clear(3,2,130)
   CALL clear(4,2,130)
   DECLARE count = i2
   SET count = 6
   WHILE (count < 24)
    CALL clear(count,1,132)
    SET count = (count+ 1)
   ENDWHILE
   CALL text(2,54,uar_i18ngetmessage(v_i18n_handle,"k102","*** Millenium Archive ***"))
   CALL text(4,80,uar_i18ngetmessage(v_i18n_handle,"k1","ENVIRONMENT ID:"))
   CALL text(4,25,uar_i18ngetmessage(v_i18n_handle,"k2","ENVIRONMENT NAME:"))
   CALL text(4,100,cnvtstring(arc_menu_env_id))
   CALL text(4,45,arc_menu_env_name)
 END ;Subroutine
 SUBROUTINE find_info_name(i_name)
   SET arc_i_name_ind = - (1)
   FOR (index = 1 TO size(dai_reply->names,5))
     IF ((dai_reply->names[index].info_name=i_name))
      SET arc_i_name_ind = index
     ENDIF
   ENDFOR
   RETURN(arc_i_name_ind)
 END ;Subroutine
 SUBROUTINE generate_crit_val_detail_menu(subind,arc_desc1,arc_desc2,arc_minval,name)
  SET arc_done = 0
  WHILE (arc_done=0)
    CALL header_box(null)
    CALL text(3,(55 - (textlen(name)/ 2)),concat(uar_i18ngetmessage(v_i18n_handle,"k103",
       "Detailed Description - "),name))
    CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k104","Description of criteria - "))
    CALL text(7,4,concat(arc_desc1," ",arc_desc2))
    IF (subind > 0)
     IF (((name="START AFTER TIME") OR (name="STOP BY TIME")) )
      CALL text(9,4,concat(uar_i18ngetmessage(v_i18n_handle,"k105","Current Value: "),format(cnvttime
         (dai_reply->names[subind].info_number),"HH:MM;;M")))
     ELSE
      CALL text(9,4,concat(uar_i18ngetmessage(v_i18n_handle,"k106","Current Value: "),cnvtstring(
         dai_reply->names[subind].info_number)))
     ENDIF
    ELSE
     CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k107","Current Value: "))
    ENDIF
    CALL text(11,4,uar_i18ngetmessage(v_i18n_handle,"k108",
      "Please choose one of the following options:"))
    CALL text(12,4,uar_i18ngetmessage(v_i18n_handle,"k109","1. Modify"))
    CALL text(13,4,uar_i18ngetmessage(v_i18n_handle,"k110","2. View History"))
    CALL text(14,4,uar_i18ngetmessage(v_i18n_handle,"k111","3. Up One Level"))
    CALL text(15,4,uar_i18ngetmessage(v_i18n_handle,"k112","0. Exit Program"))
    CALL accept(11,50,"9"
     WHERE cnvtreal(curaccept) <= 3)
    CASE (curaccept)
     OF 1:
      IF (((name="START AFTER TIME") OR (name="STOP BY TIME")) )
       CALL text(9,35,uar_i18ngetmessage(v_i18n_handle,"k113",
         "Value must be a valid time (24 hour clock)"))
       SET check = 0
       WHILE (check=0)
        IF (subind > 0)
         CALL accept(9,19,"99D99;C",format(cnvttime(dai_reply->names[subind].info_number),"HH:MM;;M")
          )
        ELSE
         CALL accept(9,19,"99D99;C","00:00")
        ENDIF
        IF (cnvtint(substring(1,2,curaccept)) <= 23)
         IF (cnvtint(substring(4,2,curaccept)) <= 59)
          SET check = 1
          SET newval = (cnvtint(substring(4,2,curaccept))+ (cnvtint(substring(1,2,curaccept)) * 60))
         ELSE
          CALL clear(9,35,45)
          CALL text(9,35,uar_i18ngetmessage(v_i18n_handle,"k114",
            "Minutes value should be between 0 and 59"))
         ENDIF
        ELSE
         CALL clear(9,35,45)
         CALL text(9,35,uar_i18ngetmessage(v_i18n_handle,"k115",
           "Hours value should be between 0 and 23"))
        ENDIF
       ENDWHILE
      ELSE
       CALL text(9,35,concat(uar_i18ngetmessage(v_i18n_handle,"k116","(Minimum Value: "),trim(
          cnvtstring(arc_minval)),")"))
       IF (subind > 0)
        CALL accept(9,19,"9(8);H",cnvtstring(dai_reply->names[subind].info_number)
         WHERE cnvtreal(curaccept) >= arc_minval)
       ELSE
        CALL accept(9,19,"9(8);H"
         WHERE cnvtreal(curaccept) >= arc_minval)
       ENDIF
       SET newval = cnvtreal(curaccept)
      ENDIF
      IF ((((newval != dai_reply->names[subind].info_number)) OR (subind < 0)) )
       SET dai_ins_reply->status_data.subeventstatus.targetobjectvalue = ""
       SET dai_ins_reply->status_data.status = ""
       SET dai_ins_request->info_domain = concat("ARCHIVE-",domains->names[arc_child_in].dname)
       SET dai_ins_request->info_name = name
       SET dai_ins_request->info_number = newval
       SET dai_ins_request->info_dt_tm = cnvtdatetime(curdate,curtime3)
       SET dai_ins_request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
       EXECUTE dm2_arc_info_ins  WITH replace("REQUEST","DAI_INS_REQUEST"), replace("REPLY",
        "DAI_INS_REPLY")
       IF ((dai_ins_reply->status_data.status="F"))
        CALL text(23,0,dai_ins_reply->status_data.subeventstatus.targetobjectvalue)
        GO TO exit_menu
       ENDIF
       IF (subind > 0)
        SET dai_reply->names[subind].info_number = newval
       ELSE
        SET dai_reply->status_data.subeventstatus.targetobjectvalue = ""
        SET dai_reply->status_data.status = ""
        SET stat = alterlist(dai_reply->names,0)
        SET dai_request->info_domain = concat("ARCHIVE-",domains->names[arc_child_in].dname)
        SET dai_request->arc_dt_tm = cnvtdatetime(curdate,curtime3)
        EXECUTE dm2_arc_get_info_by_date  WITH replace(request,dai_request), replace(reply,dai_reply)
        SET subind = find_info_name(name)
       ENDIF
      ENDIF
     OF 2:
      IF (subind > 0)
       SELECT
        d.info_number, d.beg_effective_dt_tm, d.end_effective_dt_tm,
        d.info_dt_tm, d.info_name
        FROM dm_arc_info d
        WHERE (d.info_domain=dai_request->info_domain)
         AND (d.info_name=dai_reply->names[subind].info_name)
        ORDER BY d.beg_effective_dt_tm DESC
        HEAD REPORT
         arc_temp_op_string = uar_i18ngetmessage(v_i18n_handle,"k127","VALUE"), col 0,
         arc_temp_op_string,
         arc_temp_op_string = uar_i18ngetmessage(v_i18n_handle,"k128","BEGIN DATE"), col 20,
         arc_temp_op_string,
         arc_temp_op_string = uar_i18ngetmessage(v_i18n_handle,"k129","END DATE"), col 35,
         arc_temp_op_string,
         arc_temp_op_string = uar_i18ngetmessage(v_i18n_handle,"k130","INFO DATE"), col 50,
         arc_temp_op_string,
         row + 1
        DETAIL
         IF (((d.info_name="START AFTER TIME") OR (d.info_name="STOP BY TIME")) )
          time = format(cnvttime(d.info_number),"HH:MM;;M"), col 0, time
         ELSE
          col 0, d.info_number
         ENDIF
         col 20, d.beg_effective_dt_tm, col 35,
         d.end_effective_dt_tm, col 50, d.info_dt_tm,
         row + 1
        WITH nocounter
       ;end select
      ELSE
       CALL text(16,5,uar_i18ngetmessage(v_i18n_handle,"k131","This value has never been set"))
       CALL pause(2)
      ENDIF
     OF 3:
      SET arc_done = 1
     OF 0:
      GO TO exit_menu
    ENDCASE
  ENDWHILE
 END ;Subroutine
 SUBROUTINE connection_check(prel,postl)
   IF (currdb="ORACLE")
    SET arc_conn_check_table_name = concat("orders",postl)
   ELSE
    SET arc_conn_check_table_name = concat(prel,"orders")
   ENDIF
   SELECT INTO "nl:"
    order_id
    FROM (parser(arc_conn_check_table_name))
    WITH nocounter, maxrec = 1
   ;end select
   IF (error(arc_errmsg,0) != 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE request_dates(null)
  SET check2 = 0
  WHILE (check2=0)
    CALL header_box(null)
    CALL text(3,54,uar_i18ngetmessage(v_i18n_handle,"k132","Report - Date Range Entry"))
    CALL text(6,4,uar_i18ngetmessage(v_i18n_handle,"k133","Enter dates in the format MM-DD-YYYY"))
    CALL text(8,4,uar_i18ngetmessage(v_i18n_handle,"k134","Enter Start Date: "))
    CALL text(9,4,uar_i18ngetmessage(v_i18n_handle,"k135","Enter End Date: "))
    SET check = 0
    WHILE (check=0)
     CALL accept(8,22,"99D99D9999;C",format(arc_startdate,"MM-DD-YYYY;;D"))
     IF (cnvtreal(substring(1,2,curaccept)) <= 12)
      IF (cnvtreal(substring(4,2,curaccept)) <= 31)
       SET check = 1
       SET arc_tempdate = replace(curaccept,"-","",0)
       SET arc_startdate = cnvtdatetime(cnvtdate(arc_tempdate),0)
      ENDIF
     ENDIF
    ENDWHILE
    SET check = 0
    WHILE (check=0)
     CALL accept(9,22,"99D99D9999;C",format(arc_enddate,"MM-DD-YYYY;;D"))
     IF (cnvtreal(substring(1,2,curaccept)) <= 12)
      IF (cnvtreal(substring(4,2,curaccept)) <= 31)
       SET check = 1
       SET arc_tempdate = replace(curaccept,"-","",0)
       SET arc_enddate = cnvtdatetime(cnvtdate(arc_tempdate),235959)
      ENDIF
     ENDIF
    ENDWHILE
    IF (arc_startdate < arc_enddate)
     SET check2 = 1
    ELSE
     CALL text(10,4,uar_i18ngetmessage(v_i18n_handle,"k136","Start date should not exceed end date"))
     CALL pause(2)
    ENDIF
  ENDWHILE
 END ;Subroutine
 SUBROUTINE get_arc_cnt_str(null)
   RECORD curtab(
     1 tab[*]
       2 parent_table = vc
       2 parent_column = vc
       2 child_table = vc
       2 child_column = vc
       2 child_where = vc
       2 from_str = vc
       2 where_str = vc
       2 select_str = vc
   )
   DECLARE binsearch(i_key=vc) = i4
   DECLARE v_found_ndx = i4 WITH noconstant(0)
   DECLARE v_end_paren = vc
   SELECT DISTINCT INTO "nl:"
    dac.parent_table, dac.parent_column, dac.child_table,
    dac.child_column, dac.exclude_ind
    FROM dm_arc_constraints dac
    WHERE  EXISTS (
    (SELECT
     "x"
     FROM user_tables
     WHERE table_name=dac.child_table))
    ORDER BY dac.child_table
    HEAD REPORT
     row_cnt = 0
    DETAIL
     row_cnt = (row_cnt+ 1)
     IF (mod(row_cnt,50)=1)
      stat = alterlist(ap->tabs,(row_cnt+ 49))
     ENDIF
     ap->tabs[row_cnt].parent_table = trim(dac.parent_table,3), ap->tabs[row_cnt].parent_column =
     trim(dac.parent_column,3), ap->tabs[row_cnt].child_table = trim(dac.child_table,3),
     ap->tabs[row_cnt].child_column = trim(dac.child_column,3), ap->tabs[row_cnt].exclude_ind = dac
     .exclude_ind
     IF (trim(dac.child_where,3)="")
      ap->tabs[row_cnt].child_where = " "
     ELSE
      ap->tabs[row_cnt].child_where = trim(dac.child_where,3)
     ENDIF
    FOOT REPORT
     stat = alterlist(ap->tabs,row_cnt)
    WITH nocounter
   ;end select
   FOR (t_ndx = 1 TO size(ap->tabs,5))
     SET stat = alterlist(curtab->tab,1)
     SET curtab->tab[1].child_table = ap->tabs[t_ndx].child_table
     SET curtab->tab[1].child_column = ap->tabs[t_ndx].child_column
     SET curtab->tab[1].child_where = ap->tabs[t_ndx].child_where
     SET curtab->tab[1].parent_table = ap->tabs[t_ndx].parent_table
     SET curtab->tab[1].parent_column = ap->tabs[t_ndx].parent_column
     SET curtab->tab[1].from_str = ap->tabs[t_ndx].child_table
     SET curtab->tab[1].where_str = " "
     SET cur_ndx = 1
     SET cur_count = 1
     SET v_end_paren = ""
     WHILE (cur_ndx <= cur_count)
      IF (cur_count > 10)
       SET cur_ndx = (cur_count+ 2)
      ELSE
       IF ((curtab->tab[cur_ndx].parent_table="PERSON"))
        SET ap->tabs[t_ndx].found_ind = 1
        SET ap->tabs[t_ndx].from_str = curtab->tab[cur_ndx].from_str
        IF (cur_ndx=1)
         SET ap->tabs[t_ndx].select_str = concat(trim(curtab->tab[cur_ndx].child_table,3)," where ",
          evaluate(curtab->tab[cur_ndx].child_where," "," ",concat(trim(substring(6,10000,curtab->
              tab[cur_ndx].child_where),3)," and "))," expand(pi_ndx,1,size(pers->ids,5),",curtab->
          tab[cur_ndx].child_table,
          ".",curtab->tab[cur_ndx].child_column," ,pers->ids[pi_ndx].person_id) ")
        ELSE
         SET ap->tabs[t_ndx].select_str = concat(curtab->tab[cur_ndx].select_str," where ",evaluate(
           curtab->tab[cur_ndx].child_where," "," ",concat(trim(substring(6,10000,curtab->tab[cur_ndx
              ].child_where),3)," and "))," expand(pi_ndx,1,size(pers->ids,5),",curtab->tab[cur_ndx].
          child_table,
          ".",curtab->tab[cur_ndx].child_column," ,pers->ids[pi_ndx].person_id) ",trim(v_end_paren,3)
          )
        ENDIF
       ELSE
        SET v_found_ndx = binsearch(curtab->tab[cur_ndx].parent_table)
        IF ((v_found_ndx != - (1)))
         SET found = 0
         FOR (ct_ndx = 1 TO size(curtab->tab,5))
           IF ((curtab->tab[ct_ndx].child_table=ap->tabs[cur_ndx].parent_table))
            SET found = (found+ 1)
           ENDIF
         ENDFOR
         IF (found=0)
          SET cur_count = (cur_count+ 1)
          SET stat = alterlist(curtab->tab,cur_count)
          SET curtab->tab[cur_count].parent_table = ap->tabs[v_found_ndx].parent_table
          SET curtab->tab[cur_count].parent_column = ap->tabs[v_found_ndx].parent_column
          SET curtab->tab[cur_count].child_table = ap->tabs[v_found_ndx].child_table
          SET curtab->tab[cur_count].child_column = ap->tabs[v_found_ndx].child_column
          SET curtab->tab[cur_count].child_where = ap->tabs[v_found_ndx].child_where
          SET curtab->tab[cur_count].from_str = concat(curtab->tab[cur_ndx].from_str,",",ap->tabs[
           v_found_ndx].child_table)
          SET curtab->tab[cur_count].where_str = concat(evaluate(curtab->tab[cur_ndx].child_where," ",
            " ",concat(curtab->tab[cur_ndx].child_table,".",trim(substring(6,10000,curtab->tab[
               cur_ndx].child_where),3)," and ")),"list (",curtab->tab[cur_ndx].child_column,")")
          IF (cur_ndx=1)
           SET curtab->tab[cur_count].select_str = concat(trim(curtab->tab[cur_ndx].child_table,3),
            " where ",curtab->tab[cur_count].where_str," in (select ",curtab->tab[cur_ndx].
            parent_column,
            " from  ",trim(curtab->tab[cur_ndx].parent_table,3))
          ELSE
           SET curtab->tab[cur_count].select_str = concat(curtab->tab[cur_ndx].select_str," where ",
            curtab->tab[cur_count].where_str," in (select ",curtab->tab[cur_ndx].parent_column,
            " from  ",trim(curtab->tab[cur_ndx].parent_table,3))
          ENDIF
          SET v_end_paren = build(")",v_end_paren)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      SET cur_ndx = (cur_ndx+ 1)
     ENDWHILE
   ENDFOR
   FOR (t_ndx = 1 TO size(ap->tabs,5))
    SET ap->tabs[t_ndx].count_str = concat("select into 'nl:' cnt = count(*) from ",ap->tabs[t_ndx].
     select_str," detail ap->tabs[t_ndx].count_val = cnt with nocounter go")
    SELECT INTO "nl:"
     ut.avg_row_len
     FROM user_tables ut
     WHERE (ut.table_name=ap->tabs[t_ndx].child_table)
     DETAIL
      ap->tabs[t_ndx].avg_row_len = ut.avg_row_len
     WITH nocounter
    ;end select
   ENDFOR
 END ;Subroutine
 SUBROUTINE binsearch(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(ap->tabs,5)
   WHILE (((v_high - v_low) > 1))
    SET v_mid = cnvtint(((v_high+ v_low)/ 2))
    IF ((i_key <= ap->tabs[v_mid].child_table))
     SET v_high = v_mid
    ELSE
     SET v_low = v_mid
    ENDIF
   ENDWHILE
   IF (trim(i_key,3)=trim(ap->tabs[v_high].child_table,3))
    RETURN(v_high)
   ELSE
    RETURN(- (1))
   ENDIF
 END ;Subroutine
#exit_menu
 FREE RECORD domains
 FREE RECORD db_link_request
 FREE RECORD menu_archive_db
 FREE RECORD dai_reply
 FREE RECORD dai_request
 FREE RECORD dai_ins_reply
 FREE RECORD dai_ins_request
 CALL clear(1,1)
 CALL video(n)
 SET message = nowindow
END GO

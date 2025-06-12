CREATE PROGRAM caremanager:dba
 PAINT
 RECORD app(
   1 nv_cnt = i2
   1 nv[15]
     2 pvc_name = vc
     2 pvc_value = vc
 )
 SET app->nv_cnt = 15
 SET app->nv[1].pvc_name = "CHART_COLORS"
 SET app->nv[1].pvc_value = "8454143,16777088,8454016,4227327"
 SET app->nv[2].pvc_name = "CHART_POSITION"
 SET app->nv[2].pvc_value = "230,130,550,725"
 SET app->nv[3].pvc_name = "DEFAULT_VIEWS"
 SET app->nv[3].pvc_value = "0,0"
 SET app->nv[4].pvc_name = "DEMOGWND"
 SET app->nv[4].pvc_value = "1"
 SET app->nv[5].pvc_name = "EXIT_WARN"
 SET app->nv[5].pvc_value = "0"
 SET app->nv[6].pvc_name = "INDICATORS"
 SET app->nv[6].pvc_value = "1,1,1"
 SET app->nv[7].pvc_name = "ORG_POSITION"
 SET app->nv[7].pvc_value = "100,60,550,675"
 SET app->nv[8].pvc_name = "PPRASSIGN"
 SET app->nv[8].pvc_value = "1"
 SET app->nv[9].pvc_name = "STICKYNOTES"
 SET app->nv[9].pvc_value = "1"
 SET app->nv[10].pvc_name = "STYLE_ORIENTATION_FLAGS"
 SET app->nv[10].pvc_value = "0,0,0,0"
 SET app->nv[11].pvc_name = "WINDOW_STATES"
 SET app->nv[11].pvc_value = "0,0"
 SET app->nv[12].pvc_name = "DEMOG_ATTR"
 SET app->nv[12].pvc_value = "-1"
 SET app->nv[13].pvc_name = "CHANGEUSER"
 SET app->nv[13].pvc_value = "1"
 SET app->nv[14].pvc_name = "CHGUSERMODE"
 SET app->nv[14].pvc_value = "1"
 SET app->nv[15].pvc_name = "CHART_ACCESS"
 SET app->nv[15].pvc_value = "1"
 RECORD viewp(
   1 nv_cnt = i2
   1 nv[4]
     2 pvc_name = vc
     2 pvc_value = vc
 )
 SET viewp->nv_cnt = 4
 SET viewp->nv[1].pvc_name = "VIEW_CAPTION"
 SET viewp->nv[2].pvc_name = "DISPLAY_SEQ"
 SET viewp->nv[3].pvc_name = "VIEW_IND"
 SET viewp->nv[4].pvc_name = "DLL_NAME"
 RECORD viewcp(
   1 nv_cnt = i2
   1 nv[2]
     2 pvc_name = vc
     2 pvc_value = vc
 )
 SET viewcp->nv_cnt = 2
 SET viewcp->nv[1].pvc_name = "COMP_POSITION"
 SET viewcp->nv[1].pvc_value = "0,0,3,4"
 SET viewcp->nv[2].pvc_name = "COMP_DLLNAME"
 SET viewcp->nv[2].pvc_value = "                         "
 RECORD temp(
   1 pid_cnt = i2
   1 pid[*]
     2 parent_entity_id = f8
 )
 RECORD temp1(
   1 qual[*]
     2 pvc_name = vc
     2 pvc_value = vc
 )
 RECORD temp2(
   1 qual[*]
     2 nvp_id = f8
 )
#initialize_vars
 SET app_nbr = 4180000
 SET uncomitted_chgs = "N"
 SET option_choice = 0
 SET wo_opt_choice = 0
 SET mod_choice = 0
 SET new_choice = 0
 SET hlp_choice = 0
 SET mod_app_choice = 0
 SET mod_view_choice = 0
 SET mod_comp_choice = 0
 SET mod_det_choice = 0
 SET mod_nv_choice = 0
 SET qry_opt_choice = 0
 SET qry_spec_choice = 0
 SET psn_cd = 0
 SET psn_disp = "                                            "
 SET prsnl_id = 0
 SET prsnl_name = "                                             "
 SET confirm = "N"
 SET pw = "      "
 SET nv = "                              "
 SET ap_id = 0
 SET nvp_id = 0
 SET vp_id = 0
 SET vcp_id = 0
 SET dp_id = 0
 SET ft = "            "
 SET vn = "            "
 SET vs = 0
 SET vi = " "
 SET cn = "            "
 SET cs = 0
 SET avcd = " "
 SET beg_psn_cd = 000000000
 SET end_psn_cd = 999999999
 SET beg_prsnl_id = 000000000
 SET end_prsnl_id = 999999999
 SET beg_view_seq = 00
 SET end_view_seq = 99
 SET beg_comp_seq = 00
 SET end_comp_seq = 99
 SET pvc_name = "                              "
 SET pvc_value = "                                        "
 SET count1 = 0
 SET count2 = 0
#accept_option
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(4,25,"APPLICATION NUMBER:")
 CALL text(4,45,cnvtstring(app_nbr))
 CALL text(7,15,"Options:")
 CALL text(9,20,"1) Query")
 CALL text(10,20,"2) Resequence")
 CALL text(11,20,"3) Wipeout")
 CALL text(12,20,"4) Add something new")
 CALL text(13,20,"5) Clean up preferences")
 CALL text(14,20,"6) Rollback Changes")
 CALL text(15,20,"7) Commit Changes")
 CALL text(16,20,"8) Helpful Information")
 CALL text(17,20,"9) Change Application Number")
 CALL text(20,20,"99) Exit Program")
 CALL text(22,15,"Please select option -> ")
#acc_opt
 CALL accept(22,39,"99;")
 SET option_choice = curaccept
 IF (option_choice=99)
  GO TO exit_program
 ENDIF
 IF (((option_choice < 1) OR (option_choice > 9)) )
  GO TO acc_opt
 ENDIF
 IF (option_choice=7)
  COMMIT
  SET uncomitted_chgs = "N"
  GO TO acc_opt
 ENDIF
 IF (option_choice=6)
  ROLLBACK
  SET uncomitted_chgs = "N"
  GO TO acc_opt
 ENDIF
 IF (option_choice=9)
  CALL accept(4,45,"9999999",4180000)
  SET app_nbr = curaccept
 ENDIF
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 IF (option_choice=3)
  GO TO wipeout
 ENDIF
 IF (option_choice=2)
  CALL text(3,25,"** RESEQUENCE PREFERENCES **")
  GO TO resequence
 ENDIF
 IF (option_choice=1)
  GO TO query
 ENDIF
 IF (option_choice=5)
  CALL text(3,25,"** CLEANING UP PREFERENCES **")
  GO TO nv_cleanup
 ENDIF
 IF (option_choice=4)
  GO TO new
 ENDIF
 IF (option_choice=8)
  GO TO helpful_info
 ENDIF
 GO TO accept_option
#wipeout
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** WIPEOUT PREFERENCES **")
 CALL text(5,3,"1) Wipe out all prefs")
 CALL text(6,3,"2) Wipe out all but the system level prefs")
 CALL text(7,3,"3) Wipe out all position level prefs")
 CALL text(8,3,"4) Wipe out a specific position's prefs")
 CALL text(9,3,"5) Wipe out all user level prefs")
 CALL text(10,3,"6) Wipe out all user level prefs except pt lists")
 CALL text(11,3,"7) Wipe out a specific user's prefs")
 CALL text(12,3,"8) Wipe out a specific name/value pair everywhere")
 CALL text(13,3,"9) Wipe out a specific name/value pair for a specific position")
 CALL text(14,3,"10) Wipe out a specific name/value pair for a specific user")
 CALL text(19,3,"98) Return to previous menu")
 CALL text(20,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> ")
#accept_wo_opt
 CALL accept(22,39,"99;")
 SET wo_opt_choice = curaccept
 IF (wo_opt_choice=99)
  GO TO exit_program
 ENDIF
 IF (wo_opt_choice=98)
  GO TO accept_option
 ENDIF
 IF (((wo_opt_choice < 1) OR (wo_opt_choice > 10)) )
  GO TO accept_wo_opt
 ENDIF
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"caremanager    P R E F E R E N C E S")
 IF (wo_opt_choice=1)
  CALL text(3,25,"** wiping out all preferences **")
  CALL text(5,3,"Enter password to wipe out all prefs->")
  CALL accept(5,42,"CCCCCC;CU")
  SET pw = curaccept
  IF (pw="LAUREN")
   CALL text(5,3,"                      Please Wait...                                     ")
   GO TO wo_all
  ELSE
   GO TO wipeout
  ENDIF
 ENDIF
 IF (wo_opt_choice=2)
  CALL text(3,25,"** wiping out all but system level preferences **")
  CALL text(5,3,"This will wipe out all but the system level prefs, continue? N")
  CALL accept(5,64,"C;CU","N")
  SET confirm = curaccept
  IF (((confirm="Y") OR (((confirm="y") OR (((confirm="A") OR (confirm="V")) )) )) )
   CALL text(5,3,"                      Please Wait...                                     ")
   GO TO wo_all_but_sys
  ELSE
   GO TO wipeout
  ENDIF
 ENDIF
 IF (wo_opt_choice=3)
  CALL text(3,25,"** wiping out all position level preferences **")
  CALL text(5,3,"This will wipe out all position level prefs, continue? N")
  CALL accept(5,58,"C;CU","N")
  SET confirm = curaccept
  IF (((confirm="Y") OR (((confirm="y") OR (((confirm="A") OR (confirm="V")) )) )) )
   CALL text(5,3,"                      Please Wait...                                     ")
   GO TO wo_all_psn
  ELSE
   GO TO wipeout
  ENDIF
 ENDIF
 IF (wo_opt_choice=4)
  GO TO wo_spec_psn
 ENDIF
 IF (wo_opt_choice=5)
  CALL text(3,25,"** wiping out all user level preferences **")
  CALL text(5,3,"This will wipe out all user level prefs, continue? N")
  CALL accept(5,54,"C;CU","N")
  SET confirm = curaccept
  IF (((confirm="Y") OR (((confirm="y") OR (((confirm="A") OR (confirm="V")) )) )) )
   CALL text(5,3,"                      Please Wait...                                     ")
   GO TO wo_all_user
  ELSE
   GO TO wipeout
  ENDIF
 ENDIF
 IF (wo_opt_choice=6)
  CALL text(3,20,"** wiping out all user level preferences except pt list **")
  CALL text(5,3,"This will wipe out all user level prefs except pt lists, continue? N")
  CALL accept(5,70,"C;CU","N")
  SET confirm = curaccept
  IF (((confirm="Y") OR (((confirm="y") OR (((confirm="A") OR (confirm="V")) )) )) )
   CALL text(5,3,"                      Please Wait...                                     ")
   GO TO wo_all_user_but_ptl
  ELSE
   GO TO wipeout
  ENDIF
 ENDIF
 IF (wo_opt_choice=7)
  GO TO wo_spec_user
 ENDIF
 IF (wo_opt_choice=8)
  GO TO wo_spec_nv
 ENDIF
 IF (wo_opt_choice=9)
  GO TO wo_spec_nv_psn
 ENDIF
 IF (wo_opt_choice=10)
  GO TO wo_spec_nv_user
 ENDIF
 GO TO wipeout
#wo_all
 SET uncomitted_chgs = "Y"
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_all_but_sys
 SET uncomitted_chgs = "Y"
 IF (confirm="V")
  GO TO wo_all_but_sys_view
 ENDIF
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr
    AND ((a.position_cd > 0) OR (a.prsnl_id > 0)) ))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
   AND ((a.position_cd > 0) OR (a.prsnl_id > 0))
  WITH nocounter
 ;end delete
 IF (confirm="A")
  GO TO wipeout
 ENDIF
#wo_all_but_sys_view
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND ((v.position_cd > 0) OR (v.prsnl_id > 0)) ))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr
    AND ((v.position_cd > 0) OR (v.prsnl_id > 0)) ))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr
    AND ((d.position_cd > 0) OR (((d.prsnl_id > 0) OR (d.person_id > 0)) )) ))
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
   AND ((v.position_cd > 0) OR (v.prsnl_id > 0))
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
   AND ((v.position_cd > 0) OR (v.prsnl_id > 0))
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
   AND ((d.position_cd > 0) OR (((d.prsnl_id > 0) OR (d.person_id > 0)) ))
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_all_psn
 SET uncomitted_chgs = "Y"
 IF (confirm="V")
  GO TO wo_all_psn_view
 ENDIF
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr
    AND a.position_cd > 0))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
   AND a.position_cd > 0
  WITH nocounter
 ;end delete
 IF (confirm="A")
  GO TO wipeout
 ENDIF
#wo_all_psn_view
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND v.position_cd > 0))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr
    AND v.position_cd > 0))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr
    AND d.position_cd > 0))
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.position_cd > 0
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.position_cd > 0
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
   AND d.position_cd > 0
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_spec_psn
 SET psn_cd = 999999999
 CALL text(3,25,"** wiping out a specic position's preferences **")
 CALL text(5,3,"Position Code (use query option 5 to get position codes) -> ")
 CALL accept(5,63,"999999999",0)
 SET psn_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_set=88
   AND c.code_value=psn_cd
  DETAIL
   psn_disp = c.display
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET psn_disp = "Position code not on codeset 88"
 ENDIF
 CALL text(6,3,"Position: ")
 CALL text(6,13,psn_disp)
 CALL text(7,3,"This will wipe out this position's prefs, continue? N")
 CALL accept(7,55,"C;CU","N")
 SET confirm = curaccept
 IF (((confirm="Y") OR (((confirm="y") OR (((confirm="A") OR (confirm="V")) )) )) )
  CALL text(7,3,"                                                                         ")
  CALL text(6,3,"                                                                         ")
  CALL text(5,3,"                      Please Wait...                                     ")
 ELSE
  GO TO wipeout
 ENDIF
 SET uncomitted_chgs = "Y"
 IF (confirm="V")
  GO TO wo_spec_psn_view
 ENDIF
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr
    AND a.position_cd=psn_cd))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
   AND a.position_cd=psn_cd
  WITH nocounter
 ;end delete
 IF (confirm="A")
  GO TO wipeout
 ENDIF
#wo_spec_psn_view
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND v.position_cd=psn_cd))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr
    AND v.position_cd=psn_cd))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr
    AND d.position_cd=psn_cd))
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.position_cd=psn_cd
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.position_cd=psn_cd
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
   AND d.position_cd=psn_cd
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_all_user
 SET uncomitted_chgs = "Y"
 IF (confirm="V")
  GO TO wo_all_user_view
 ENDIF
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr
    AND a.prsnl_id > 0))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
   AND a.prsnl_id > 0
  WITH nocounter
 ;end delete
 IF (confirm="A")
  GO TO wipeout
 ENDIF
#wo_all_user_view
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND v.prsnl_id > 0))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr
    AND v.prsnl_id > 0))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr
    AND d.prsnl_id > 0))
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.prsnl_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.prsnl_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
   AND d.prsnl_id > 0
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_all_user_but_ptl
 SET uncomitted_chgs = "Y"
 IF (confirm="V")
  GO TO wo_all_user_but_ptl_view
 ENDIF
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr
    AND a.prsnl_id > 0))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
   AND a.prsnl_id > 0
  WITH nocounter
 ;end delete
 IF (confirm="A")
  GO TO wipeout
 ENDIF
#wo_all_user_but_ptl_view
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND v.prsnl_id > 0
    AND v.view_name != "PTLISTVIEW"))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr
    AND v.prsnl_id > 0
    AND v.view_name != "PTLISTVIEW"))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr
    AND d.prsnl_id > 0
    AND d.view_name != "PTLISTVIEW"))
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.prsnl_id > 0
   AND v.view_name != "PTLISTVIEW"
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.prsnl_id > 0
   AND v.view_name != "PTLISTVIEW"
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
   AND d.prsnl_id > 0
   AND d.view_name != "PTLISTVIEW"
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_spec_user
 SET prsnl_id = 999999999
 CALL text(3,25,"** wiping out a specic user's preferences **")
 CALL text(5,3,"Prsnl Id (use query options 5 or 6 to get prsnl id) ->")
 CALL accept(5,58,"999999999",0)
 SET prsnl_id = curaccept
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prsnl p
  WHERE p.person_id=prsnl_id
  DETAIL
   prsnl_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET prsnl_name = "User not found on prsnl table"
 ENDIF
 CALL text(6,3,"User: ")
 CALL text(6,9,prsnl_name)
 CALL text(7,3,"This will wipe out this user's prefs, continue? N")
 CALL accept(7,51,"C;CU","N")
 SET confirm = curaccept
 IF (((confirm="Y") OR (((confirm="y") OR (((confirm="A") OR (confirm="V")) )) )) )
  CALL text(7,3,"                                                                         ")
  CALL text(6,3,"                                                                         ")
  CALL text(5,3,"                      Please Wait...                                     ")
 ELSE
  GO TO wipeout
 ENDIF
 SET uncomitted_chgs = "Y"
 IF (confirm="V")
  GO TO wo_spec_user_view
 ENDIF
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.application_number=app_nbr
    AND a.prsnl_id=prsnl_id))
 ;end delete
 DELETE  FROM app_prefs a
  WHERE a.app_prefs_id > 0
   AND a.application_number=app_nbr
   AND a.prsnl_id=prsnl_id
  WITH nocounter
 ;end delete
 IF (confirm="A")
  GO TO wipeout
 ENDIF
#wo_spec_user_view
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND v.prsnl_id=prsnl_id))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.application_number=app_nbr
    AND v.prsnl_id=prsnl_id))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.name_value_prefs_id > 0
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.application_number=app_nbr
    AND d.prsnl_id=prsnl_id))
 ;end delete
 DELETE  FROM view_prefs v
  WHERE v.view_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.prsnl_id=prsnl_id
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs v
  WHERE v.view_comp_prefs_id > 0
   AND v.application_number=app_nbr
   AND v.prsnl_id=prsnl_id
  WITH nocounter
 ;end delete
 DELETE  FROM detail_prefs d
  WHERE d.detail_prefs_id > 0
   AND d.application_number=app_nbr
   AND d.prsnl_id=prsnl_id
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_spec_nv
 SET nv = " "
 CALL text(3,25,"** wiping out a specic name/value pair **")
 CALL text(5,3,"Name ->")
 CALL accept(5,11,"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;C")
 SET nv = curaccept
 CALL text(6,3,"This will wipe out this name/value pair everywhere it appears, continue? N")
 CALL accept(6,76,"C;CU","N")
 SET confirm = curaccept
 IF (((confirm="Y") OR (confirm="y")) )
  CALL text(6,3,"                                                                         ")
  CALL text(5,3,"                      Please Wait...                                     ")
 ELSE
  GO TO wipeout
 ENDIF
 SET uncomitted_chgs = "Y"
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=nv
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_spec_nv_psn
 SET psn_cd = 999999999
 CALL text(3,25,"** wiping out a name/value for a specic position **")
 CALL text(5,3,"Position Code (use query option 5 to get position codes) -> ")
 CALL accept(5,63,"999999999",0)
 SET psn_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_set=88
   AND c.code_value=psn_cd
  DETAIL
   psn_disp = c.display
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET psn_disp = "Position code not on codeset 88"
 ENDIF
 CALL text(6,3,"Position: ")
 CALL text(6,13,psn_disp)
 CALL text(7,3,"Name: ")
 CALL accept(7,9,"CCCCCCCCCCCCCCCCCCCCCCCCC;C")
 SET pvc_name = curaccept
 CALL text(8,3,"This will wipe this name/value for this position, continue? N")
 CALL accept(8,63,"C;CU","N")
 SET confirm = curaccept
 IF (((confirm="Y") OR (confirm="y")) )
  CALL text(8,3,"                                                                         ")
  CALL text(7,3,"                                                                         ")
  CALL text(6,3,"                                                                         ")
  CALL text(5,3,"                      Please Wait...                                     ")
 ELSE
  GO TO wipeout
 ENDIF
 SET uncomitted_chgs = "Y"
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.detail_prefs_id=n.parent_entity_id
    AND d.position_cd=psn_cd
    AND d.application_number=app_nbr))
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.view_comp_prefs_id=n.parent_entity_id
    AND v.position_cd=psn_cd
    AND v.application_number=app_nbr))
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.view_prefs_id=n.parent_entity_id
    AND v.position_cd=psn_cd
    AND v.application_number=app_nbr))
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.app_prefs_id=n.parent_entity_id
    AND a.position_cd=psn_cd
    AND a.application_number=app_nbr))
  WITH nocounter
 ;end delete
 GO TO wipeout
#wo_spec_nv_user
 SET prsnl_id = 999999999
 CALL text(3,25,"** wiping out a name/value pair for a specic user **")
 CALL text(5,3,"Prsnl Id (use query options 5 or 6 to get prsnl id) ->")
 CALL accept(5,58,"999999999",0)
 SET prsnl_id = curaccept
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prsnl p
  WHERE p.person_id=prsnl_id
  DETAIL
   prsnl_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET prsnl_name = "User not found on prsnl table"
 ENDIF
 CALL text(6,3,"User: ")
 CALL text(6,9,prsnl_name)
 CALL text(7,3,"Name: ")
 CALL accept(7,9,"CCCCCCCCCCCCCCCCCCCCCCCCC;C")
 SET pvc_name = curaccept
 CALL text(8,3,"This will wipe this name/value for this user, continue? N")
 CALL accept(8,59,"C;CU","N")
 SET confirm = curaccept
 IF (((confirm="Y") OR (confirm="y")) )
  CALL text(8,3,"                                                                         ")
  CALL text(7,3,"                                                                         ")
  CALL text(6,3,"                                                                         ")
  CALL text(5,3,"                      Please Wait...                                     ")
 ELSE
  GO TO wipeout
 ENDIF
 SET uncomitted_chgs = "Y"
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="DETAIL_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   d.detail_prefs_id
   FROM detail_prefs d
   WHERE d.detail_prefs_id=n.parent_entity_id
    AND d.prsnl_id=prsnl_id
    AND d.application_number=app_nbr))
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="VIEW_COMP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   v.view_comp_prefs_id
   FROM view_comp_prefs v
   WHERE v.view_comp_prefs_id=n.parent_entity_id
    AND v.prsnl_id=prsnl_id
    AND v.application_number=app_nbr))
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="VIEW_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.view_prefs_id=n.parent_entity_id
    AND v.prsnl_id=prsnl_id
    AND v.application_number=app_nbr))
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name=pvc_name
   AND n.parent_entity_name="APP_PREFS"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   a.app_prefs_id
   FROM app_prefs a
   WHERE a.app_prefs_id=n.parent_entity_id
    AND a.prsnl_id=prsnl_id
    AND a.application_number=app_nbr))
  WITH nocounter
 ;end delete
 GO TO wipeout
#query
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** QUERY PREFERENCES **")
 CALL text(5,3,"1) Query system level prefs")
 CALL text(6,3,"2) Query a specific position's prefs")
 CALL text(7,3,"3) Query a specific user's prefs")
 CALL text(8,3,"4) Query the available predefined prefs")
 CALL text(9,3,"5) Query positions (codeset 88)")
 CALL text(10,3,"6) Query prsnl info for all users")
 CALL text(11,3,"7) Query prsnl info by username")
 CALL text(12,3,"8) Query order selection categories")
 CALL text(19,3,"98) Return to previous menu")
 CALL text(20,3,"99) Exit Program")
#accept_qry_opt
 CALL text(22,15,"Please select option ->                                   ")
 CALL accept(22,39,"99;")
 SET qry_opt_choice = curaccept
 IF (qry_opt_choice=98)
  GO TO accept_option
 ENDIF
 IF (qry_opt_choice=99)
  GO TO exit_program
 ENDIF
 IF (((qry_opt_choice < 1) OR (qry_opt_choice > 8)) )
  GO TO accept_qry_opt
 ENDIF
 IF ( NOT (qry_opt_choice IN (1, 2, 3)))
  GO TO acc_qry_opt_cont
 ENDIF
#pref_qry_spec
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** QUERY SPECIFICS **")
 CALL text(5,3,"1) Query view/component/detail hierarchy")
 CALL text(6,3,"2) Query application name/value pairs")
 CALL text(7,3,"3) Query view level name/value pairs")
 CALL text(8,3,"4) Query component level name/value pairs")
 CALL text(9,3,"5) Query detail level name/value pairs")
 CALL text(19,3,"98) Return to previous menu")
 CALL text(20,3,"99) Exit Program")
#accept_qry_spec_opt
 CALL text(22,15,"Please select option ->                                   ")
 CALL accept(22,39,"99;")
 SET qry_spec_choice = curaccept
 IF (qry_spec_choice=98)
  GO TO query
 ENDIF
 IF (qry_spec_choice=99)
  GO TO exit_program
 ENDIF
 IF (((qry_spec_choice < 1) OR (qry_spec_choice > 5)) )
  GO TO pref_qry_spec
 ENDIF
#acc_qry_opt_cont
 CALL text(22,15,"                 Please Wait...                        ")
 IF (qry_opt_choice=1)
  GO TO qry_system
 ENDIF
 IF (qry_opt_choice=2)
  GO TO qry_psn
 ENDIF
 IF (qry_opt_choice=3)
  GO TO qry_user
 ENDIF
 IF (qry_opt_choice=4)
  GO TO qry_pred_prefs
 ENDIF
 IF (qry_opt_choice=5)
  GO TO qry_cs88
 ENDIF
 IF (qry_opt_choice=6)
  GO TO qry_prsnl
 ENDIF
 IF (qry_opt_choice=7)
  GO TO qry_spec_prsnl
 ENDIF
 IF (qry_opt_choice=8)
  GO TO qry_alt_sel_cat
 ENDIF
#qry_system
 IF (qry_spec_choice=1)
  SELECT
   frame_type =
   IF (v.frame_type="ORG") "AA-ORG"
   ELSEIF (v.frame_type="CHART") "AB-CHART"
   ELSE v.frame_type
   ENDIF
   , v.view_name, v.view_seq,
   vc.comp_name, vc.comp_seq, d.comp_name,
   d.comp_seq
   FROM view_prefs v,
    (dummyt d1  WITH seq = 1),
    view_comp_prefs vc,
    (dummyt d2  WITH seq = 1),
    detail_prefs d
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=0
     AND v.prsnl_id=0)
    JOIN (d1)
    JOIN (vc
    WHERE vc.application_number=app_nbr
     AND vc.position_cd=0
     AND vc.prsnl_id=0
     AND vc.view_name=v.view_name
     AND vc.view_seq=v.view_seq)
    JOIN (d2)
    JOIN (d
    WHERE d.application_number=app_nbr
     AND d.position_cd=0
     AND d.prsnl_id=0
     AND d.person_id=0
     AND d.view_name=vc.view_name
     AND d.view_seq=vc.view_seq
     AND d.comp_name=vc.comp_name
     AND d.comp_seq=vc.comp_seq)
   ORDER BY frame_type, v.view_seq, vc.comp_seq,
    d.comp_seq
   HEAD PAGE
    "FRAME", col 15, "VIEW",
    col 37, "V-SEQ", col 50,
    "COMPONENT", col 71, "C-SEQ",
    col 85, "DETAIL", row + 2
   HEAD frame_type
    IF (frame_type="AA-ORG")
     "ORG"
    ELSEIF (frame_type="AB-CHART")
     "CHART"
    ELSE
     frame_type
    ENDIF
   HEAD v.view_seq
    col 15, v.view_name, col 30,
    v.view_seq
   HEAD vc.comp_seq
    col 50, vc.comp_name, col 65,
    vc.comp_seq
   HEAD d.comp_seq
    col 85, d.comp_name, row + 1
   DETAIL
    row + 0
   FOOT  v.view_seq
    row + 0
   FOOT  frame_type
    row + 1
   WITH outerjoin = d1, outerjoin = d2, nocounter,
    maxcol = 500, check
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=2)
  SELECT
   n.name_value_prefs_id, n.pvc_name, n.pvc_value
   FROM app_prefs a,
    (dummyt d  WITH seq = 1),
    name_value_prefs n
   PLAN (a
    WHERE a.application_number=app_nbr
     AND a.position_cd=0
     AND a.prsnl_id=0)
    JOIN (d)
    JOIN (n
    WHERE a.app_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="APP_PREFS")
   ORDER BY n.pvc_name
   WITH maxqual(a,1), nocounter
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=3)
  SELECT
   frame =
   IF (v.frame_type="ORG") "AAORG"
   ELSEIF (v.frame_type="CHART") "ABCHART"
   ELSE v.frame_type
   ENDIF
   , v.view_name, v.view_seq,
   n.name_value_prefs_id, n.pvc_name, n.pvc_value
   FROM view_prefs v,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=0
     AND v.prsnl_id=0)
    JOIN (d1)
    JOIN (n
    WHERE v.view_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="VIEW_PREFS")
   ORDER BY frame, v.view_seq, n.pvc_name
   HEAD frame
    IF (frame="AAORG")
     "ORG"
    ELSEIF (frame="ABCHART")
     "CHART"
    ELSE
     frame
    ENDIF
   HEAD v.view_seq
    col 15, v.view_name, col 30,
    v.view_seq
   DETAIL
    col 45, n.name_value_prefs_id, col 60,
    n.pvc_name, col 80, n.pvc_value,
    row + 1
   FOOT  v.view_seq
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=4)
  SELECT
   v.view_name, v.view_seq, v.comp_name,
   v.comp_seq, n.name_value_prefs_id, n.pvc_name,
   n.pvc_value
   FROM view_comp_prefs v,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=0
     AND v.prsnl_id=0)
    JOIN (d1)
    JOIN (n
    WHERE v.view_comp_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="VIEW_COMP_PREFS")
   ORDER BY v.view_seq, v.view_name, v.comp_seq,
    v.comp_name, n.pvc_name
   HEAD v.view_seq
    row + 0
   HEAD v.view_name
    v.view_name, col 15, v.view_seq
   HEAD v.comp_seq
    row + 0
   HEAD v.comp_name
    col 30, v.comp_name, col 45,
    v.comp_seq
   DETAIL
    col 60, n.name_value_prefs_id, col 75,
    n.pvc_name, col 95, n.pvc_value,
    row + 1
   FOOT  v.comp_name
    row + 1
   FOOT  v.view_name
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=5)
  SELECT
   d.view_name, d.view_seq, d.comp_name,
   d.comp_seq, n.name_value_prefs_id, n.pvc_name,
   n.pvc_value
   FROM detail_prefs d,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (d
    WHERE d.application_number=app_nbr
     AND d.position_cd=0
     AND d.prsnl_id=0)
    JOIN (d1)
    JOIN (n
    WHERE d.detail_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="DETAIL_PREFS")
   ORDER BY d.view_name, d.view_seq, d.comp_name,
    d.comp_seq
   HEAD d.view_name
    d.view_name
   HEAD d.view_seq
    col 15, d.view_seq
   HEAD d.comp_name
    col 30, d.comp_name
   HEAD d.comp_seq
    col 45, d.comp_seq
   DETAIL
    col 60, n.name_value_prefs_id, col 75,
    n.pvc_name, col 100, n.pvc_value,
    row + 1
   FOOT  d.comp_name
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 GO TO pref_qry_spec
#qry_psn
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** QUERY FOR A SPECIFIC POSITION **")
 CALL text(5,3,"Position Code (use query option 5 to get position codes) -> ")
 CALL accept(5,63,"999999999",0)
 SET psn_cd = curaccept
 IF (psn_cd=0)
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=1)
  SELECT
   frame_type =
   IF (v.frame_type="ORG") "AA-ORG"
   ELSEIF (v.frame_type="CHART") "AB-CHART"
   ELSE v.frame_type
   ENDIF
   , v.view_name, v.view_seq,
   vc.comp_name, vc.comp_seq, d.comp_name,
   d.comp_seq
   FROM view_prefs v,
    (dummyt d1  WITH seq = 1),
    view_comp_prefs vc,
    (dummyt d2  WITH seq = 1),
    detail_prefs d
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=psn_cd
     AND v.prsnl_id=0)
    JOIN (d1)
    JOIN (vc
    WHERE vc.application_number=app_nbr
     AND vc.position_cd=psn_cd
     AND vc.prsnl_id=0
     AND vc.view_name=v.view_name
     AND vc.view_seq=v.view_seq)
    JOIN (d2)
    JOIN (d
    WHERE d.application_number=app_nbr
     AND d.position_cd=psn_cd
     AND d.prsnl_id=0
     AND d.person_id=0
     AND d.view_name=vc.view_name
     AND d.view_seq=vc.view_seq
     AND d.comp_name=vc.comp_name
     AND d.comp_seq=vc.comp_seq)
   ORDER BY frame_type, v.view_seq, vc.comp_seq,
    d.comp_seq
   HEAD PAGE
    "FRAME", col 15, "VIEW",
    col 37, "V-SEQ", col 50,
    "COMPONENT", col 71, "C-SEQ",
    col 85, "DETAIL", row + 2
   HEAD frame_type
    IF (frame_type="AA-ORG")
     "ORG"
    ELSEIF (frame_type="AB-CHART")
     "CHART"
    ELSE
     frame_type
    ENDIF
   HEAD v.view_seq
    col 15, v.view_name, col 30,
    v.view_seq
   HEAD vc.comp_seq
    col 50, vc.comp_name, col 65,
    vc.comp_seq
   HEAD d.comp_seq
    col 85, d.comp_name, row + 1
   DETAIL
    row + 0
   FOOT  v.view_seq
    row + 0
   FOOT  frame_type
    row + 1
   WITH outerjoin = d1, outerjoin = d2, nocounter,
    maxcol = 500, check
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=2)
  SELECT
   n.name_value_prefs_id, n.pvc_name, n.pvc_value
   FROM app_prefs a,
    (dummyt d  WITH seq = 1),
    name_value_prefs n
   PLAN (a
    WHERE a.application_number=app_nbr
     AND a.position_cd=psn_cd
     AND a.prsnl_id=0)
    JOIN (d)
    JOIN (n
    WHERE a.app_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="APP_PREFS")
   WITH maxqual(a,1), nocounter
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=3)
  SELECT
   frame =
   IF (v.frame_type="ORG") "AAORG"
   ELSEIF (v.frame_type="CHART") "ABCHART"
   ELSE v.frame_type
   ENDIF
   , v.view_name, v.view_seq,
   n.name_value_prefs_id, n.pvc_name, n.pvc_value
   FROM view_prefs v,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=psn_cd
     AND v.prsnl_id=0)
    JOIN (d1)
    JOIN (n
    WHERE v.view_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="VIEW_PREFS")
   ORDER BY frame, v.view_seq, n.pvc_name
   HEAD frame
    IF (frame="AAORG")
     "ORG"
    ELSEIF (frame="ABCHART")
     "CHART"
    ELSE
     frame
    ENDIF
   HEAD v.view_seq
    col 15, v.view_name, col 30,
    v.view_seq
   DETAIL
    col 45, n.name_value_prefs_id, col 60,
    n.pvc_name, col 80, n.pvc_value,
    row + 1
   FOOT  v.view_seq
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=4)
  SELECT
   v.view_name, v.view_seq, v.comp_name,
   v.comp_seq, n.name_value_prefs_id, n.pvc_name,
   n.pvc_value
   FROM view_comp_prefs v,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=psn_cd
     AND v.prsnl_id=0)
    JOIN (d1)
    JOIN (n
    WHERE v.view_comp_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="VIEW_COMP_PREFS")
   ORDER BY v.view_seq, v.view_name, v.comp_seq,
    v.comp_name, n.pvc_name
   HEAD v.view_seq
    row + 0
   HEAD v.view_name
    v.view_name, col 15, v.view_seq
   HEAD v.comp_seq
    row + 0
   HEAD v.comp_name
    col 30, v.comp_name, col 45,
    v.comp_seq
   DETAIL
    col 60, n.name_value_prefs_id, col 75,
    n.pvc_name, col 95, n.pvc_value,
    row + 1
   FOOT  v.comp_name
    row + 1
   FOOT  v.view_name
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=5)
  SELECT
   d.view_name, d.view_seq, d.comp_name,
   d.comp_seq, n.name_value_prefs_id, n.pvc_name,
   n.pvc_value
   FROM detail_prefs d,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (d
    WHERE d.application_number=app_nbr
     AND d.position_cd=psn_cd
     AND d.prsnl_id=0)
    JOIN (d1)
    JOIN (n
    WHERE d.detail_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="DETAIL_PREFS")
   ORDER BY d.view_name, d.view_seq, d.comp_name,
    d.comp_seq
   HEAD d.view_name
    d.view_name
   HEAD d.view_seq
    col 15, d.view_seq
   HEAD d.comp_name
    col 30, d.comp_name
   HEAD d.comp_seq
    col 45, d.comp_seq
   DETAIL
    col 60, n.name_value_prefs_id, col 75,
    n.pvc_name, col 100, n.pvc_value,
    row + 1
   FOOT  d.comp_name
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 GO TO pref_qry_spec
#qry_user
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** QUERY FOR A SPECIFIC USER **")
 CALL text(5,3,"Prsnl ID (use query options 6 or 7 to get prsnl ids) -> ")
 CALL accept(5,59,"999999999",0)
 SET prsnl_id = curaccept
 IF (prsnl_id=0)
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=1)
  SELECT
   frame_type =
   IF (v.frame_type="ORG") "AA-ORG"
   ELSEIF (v.frame_type="CHART") "AB-CHART"
   ELSE v.frame_type
   ENDIF
   , v.view_name, v.view_seq,
   vc.comp_name, vc.comp_seq, d.comp_name,
   d.comp_seq
   FROM view_prefs v,
    (dummyt d1  WITH seq = 1),
    view_comp_prefs vc,
    (dummyt d2  WITH seq = 1),
    detail_prefs d
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=0
     AND v.prsnl_id=prsnl_id)
    JOIN (d1)
    JOIN (vc
    WHERE vc.application_number=app_nbr
     AND vc.position_cd=0
     AND vc.prsnl_id=prsnl_id
     AND vc.view_name=v.view_name
     AND vc.view_seq=v.view_seq)
    JOIN (d2)
    JOIN (d
    WHERE d.application_number=app_nbr
     AND d.position_cd=0
     AND d.prsnl_id=prsnl_id
     AND d.person_id=0
     AND d.view_name=vc.view_name
     AND d.view_seq=vc.view_seq
     AND d.comp_name=vc.comp_name
     AND d.comp_seq=vc.comp_seq)
   ORDER BY frame_type, v.view_seq, vc.comp_seq,
    d.comp_seq
   HEAD PAGE
    "FRAME", col 15, "VIEW",
    col 37, "V-SEQ", col 50,
    "COMPONENT", col 71, "C-SEQ",
    col 85, "DETAIL", row + 2
   HEAD frame_type
    IF (frame_type="AA-ORG")
     "ORG"
    ELSEIF (frame_type="AB-CHART")
     "CHART"
    ELSE
     frame_type
    ENDIF
   HEAD v.view_seq
    col 15, v.view_name, col 30,
    v.view_seq
   HEAD vc.comp_seq
    col 50, vc.comp_name, col 65,
    vc.comp_seq
   HEAD d.comp_seq
    col 85, d.comp_name, row + 1
   DETAIL
    row + 0
   FOOT  v.view_seq
    row + 0
   FOOT  frame_type
    row + 1
   WITH outerjoin = d1, outerjoin = d2, nocounter,
    maxcol = 500, check
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=2)
  SELECT
   n.name_value_prefs_id, n.pvc_name, n.pvc_value
   FROM app_prefs a,
    (dummyt d  WITH seq = 1),
    name_value_prefs n
   PLAN (a
    WHERE a.application_number=app_nbr
     AND a.position_cd=0
     AND a.prsnl_id=prsnl_id)
    JOIN (d)
    JOIN (n
    WHERE a.app_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="APP_PREFS")
   WITH maxqual(a,1), nocounter
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=3)
  SELECT
   frame =
   IF (v.frame_type="ORG") "AAORG"
   ELSEIF (v.frame_type="CHART") "ABCHART"
   ELSE v.frame_type
   ENDIF
   , v.view_name, v.view_seq,
   n.name_value_prefs_id, n.pvc_name, n.pvc_value
   FROM view_prefs v,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=0
     AND v.prsnl_id=prsnl_id)
    JOIN (d1)
    JOIN (n
    WHERE v.view_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="VIEW_PREFS")
   ORDER BY frame, v.view_seq, n.pvc_name
   HEAD frame
    IF (frame="AAORG")
     "ORG"
    ELSEIF (frame="ABCHART")
     "CHART"
    ELSE
     frame
    ENDIF
   HEAD v.view_seq
    col 15, v.view_name, col 30,
    v.view_seq
   DETAIL
    col 45, n.name_value_prefs_id, col 60,
    n.pvc_name, col 80, n.pvc_value,
    row + 1
   FOOT  v.view_seq
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=4)
  SELECT
   v.view_name, v.view_seq, v.comp_name,
   v.comp_seq, n.name_value_prefs_id, n.pvc_name,
   n.pvc_value
   FROM view_comp_prefs v,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (v
    WHERE v.application_number=app_nbr
     AND v.position_cd=0
     AND v.prsnl_id=prsnl_id)
    JOIN (d1)
    JOIN (n
    WHERE v.view_comp_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="VIEW_COMP_PREFS")
   ORDER BY v.view_seq, v.view_name, v.comp_seq,
    v.comp_name, n.pvc_name
   HEAD v.view_seq
    row + 0
   HEAD v.view_name
    v.view_name, col 15, v.view_seq
   HEAD v.comp_seq
    row + 0
   HEAD v.comp_name
    col 30, v.comp_name, col 45,
    v.comp_seq
   DETAIL
    col 60, n.name_value_prefs_id, col 75,
    n.pvc_name, col 95, n.pvc_value,
    row + 1
   FOOT  v.comp_name
    row + 1
   FOOT  v.view_name
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 IF (qry_spec_choice=5)
  SELECT
   d.view_name, d.view_seq, d.comp_name,
   d.comp_seq, n.name_value_prefs_id, n.pvc_name,
   n.pvc_value
   FROM detail_prefs d,
    (dummyt d1  WITH seq = 1),
    name_value_prefs n
   PLAN (d
    WHERE d.application_number=app_nbr
     AND d.position_cd=0
     AND d.prsnl_id=prsnl_id)
    JOIN (d1)
    JOIN (n
    WHERE d.detail_prefs_id=n.parent_entity_id
     AND n.parent_entity_name="DETAIL_PREFS")
   ORDER BY d.view_name, d.view_seq, d.comp_name,
    d.comp_seq
   HEAD d.view_name
    d.view_name
   HEAD d.view_seq
    col 15, d.view_seq
   HEAD d.comp_name
    col 30, d.comp_name
   HEAD d.comp_seq
    col 45, d.comp_seq
   DETAIL
    col 60, n.name_value_prefs_id, col 75,
    n.pvc_name, col 100, n.pvc_value,
    row + 1
   FOOT  d.comp_name
    row + 1
   WITH nocounter, outerjoin = d1, maxcol = 500
  ;end select
  GO TO pref_qry_spec
 ENDIF
 GO TO pref_qry_spec
#qry_pred_prefs
 SELECT
  p.predefined_prefs_id, p.predefined_type_meaning, p.name,
  p.active_ind
  FROM predefined_prefs p
  WHERE p.predefined_prefs_id > 0
  ORDER BY p.predefined_type_meaning, p.name
  WITH nocounter
 ;end select
 GO TO query
#qry_cs88
 SELECT
  c.code_value, c.display, c.active_ind
  FROM code_value c
  WHERE c.code_set=88
  ORDER BY c.code_value
  WITH nocounter
 ;end select
 GO TO query
#qry_prsnl
 SELECT
  prsnl_id = p.person_id, nme = p.name_full_formatted, psition_code = p.position_cd,
  usrname = p.username
  FROM prsnl p
  WHERE p.person_id > 0
  HEAD REPORT
   col 0, "PRSNL ID", col 20,
   "NAME", col 70, "POSITION CD",
   col 85, "USERNAME", row + 2
  DETAIL
   col 0, prsnl_id, col 20,
   nme, col 70, psition_code,
   col 85, usrname, row + 1
  WITH nocounter, maxcol = 150
 ;end select
 GO TO query
#qry_spec_prsnl
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** QUERY PRSNL TABLE FOR A SPECIFIC USERNAME **")
 SET un = "      "
 SET nff = "                          "
 CALL text(5,3,"Username: ")
 CALL accept(5,13,"XXXXXX;CU")
 SET un = curaccept
 SELECT
  *
  FROM prsnl p
  WHERE p.username=un
  WITH nocounter
 ;end select
 GO TO query
#qry_alt_sel_cat
 SELECT
  a.alt_sel_category_id, a.short_description, a.long_description
  FROM alt_sel_cat a
  WHERE a.alt_sel_category_id > 0
  ORDER BY a.alt_sel_category_id
  WITH nocounter
 ;end select
 GO TO query
#nv_cleanup
 SET uncomitted_chgs = "Y"
 CALL text(5,4,"Making sure both prsnl_id AND position_cd aren't filled out...")
 UPDATE  FROM app_prefs a
  SET a.position_cd = 0
  WHERE a.prsnl_id > 0
   AND a.position_cd > 0
  WITH nocounter
 ;end update
 UPDATE  FROM view_prefs v
  SET v.position_cd = 0
  WHERE v.prsnl_id > 0
   AND v.position_cd > 0
  WITH nocounter
 ;end update
 UPDATE  FROM view_comp_prefs v
  SET v.position_cd = 0
  WHERE v.prsnl_id > 0
   AND v.position_cd > 0
  WITH nocounter
 ;end update
 UPDATE  FROM detail_prefs d
  SET d.position_cd = 0
  WHERE d.prsnl_id > 0
   AND d.position_cd > 0
  WITH nocounter
 ;end update
 CALL text(6,4,"Getting rid of dup rows at the app,view,comp & detail levels...")
 SELECT INTO "nl:"
  a.position_cd, a.prsnl_id
  FROM app_prefs a
  WHERE a.application_number=app_nbr
  ORDER BY a.position_cd, a.prsnl_id
  HEAD REPORT
   count1 = 0, p_id = 1, psn_cd = 1
  HEAD a.position_cd
   p_id = 1, psn_cd = 1
  HEAD a.prsnl_id
   p_id = 1, psn_cd = 1
  DETAIL
   IF (a.prsnl_id=p_id
    AND a.position_cd=psn_cd)
    count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = a
    .app_prefs_id
   ELSE
    p_id = a.prsnl_id, psn_cd = a.position_cd
   ENDIF
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 DELETE  FROM (dummyt d  WITH seq = value(temp->pid_cnt)),
   app_prefs a
  SET a.seq = 1
  PLAN (d)
   JOIN (a
   WHERE (a.app_prefs_id=temp->pid[d.seq].parent_entity_id))
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  a.position_cd, a.prsnl_id, a.frame_type,
  a.view_name, a.view_seq
  FROM view_prefs a
  WHERE a.application_number=app_nbr
  ORDER BY a.position_cd, a.prsnl_id, a.frame_type,
   a.view_name, a.view_seq
  HEAD REPORT
   count1 = 0, p_id = 0, psn_cd = 0,
   ft = fillstring(12," "), vn = fillstring(12," "), vs = 0
  HEAD a.position_cd
   p_id = 0, psn_cd = 0, ft = fillstring(12," "),
   vn = fillstring(12," "), vs = 0
  HEAD a.prsnl_id
   p_id = 0, psn_cd = 0, ft = fillstring(12," "),
   vn = fillstring(12," "), vs = 0
  HEAD a.frame_type
   p_id = 0, psn_cd = 0, ft = fillstring(12," "),
   vn = fillstring(12," "), vs = 0
  HEAD a.view_name
   p_id = 0, psn_cd = 0, ft = fillstring(12," "),
   vn = fillstring(12," "), vs = 0
  HEAD a.view_seq
   p_id = 0, psn_cd = 0, ft = fillstring(12," "),
   vn = fillstring(12," "), vs = 0
  DETAIL
   IF (a.prsnl_id=p_id
    AND a.position_cd=psn_cd
    AND a.frame_type=ft
    AND a.view_name=vn
    AND a.view_seq=vs)
    count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = a
    .view_prefs_id
   ELSE
    p_id = a.prsnl_id, psn_cd = a.position_cd, ft = a.frame_type,
    vn = a.view_name, vs = a.view_seq
   ENDIF
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 DELETE  FROM (dummyt d  WITH seq = value(temp->pid_cnt)),
   view_prefs a
  SET a.seq = 1
  PLAN (d)
   JOIN (a
   WHERE (a.view_prefs_id=temp->pid[d.seq].parent_entity_id))
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  a.position_cd, a.prsnl_id, a.view_name,
  a.view_seq, a.comp_name, a.comp_seq
  FROM view_comp_prefs a
  WHERE a.application_number=app_nbr
  ORDER BY a.position_cd, a.prsnl_id, a.view_name,
   a.view_seq, a.comp_name, a.comp_seq
  HEAD REPORT
   count1 = 0, p_id = 0, psn_cd = 0,
   cn = fillstring(12," "), vn = fillstring(12," "), vs = 0,
   cs = 0
  HEAD a.position_cd
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.prsnl_id
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.view_name
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.view_seq
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.comp_name
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.comp_seq
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  DETAIL
   IF (a.prsnl_id=p_id
    AND a.position_cd=psn_cd
    AND a.view_name=vn
    AND a.view_seq=vs
    AND a.comp_name=cn
    AND a.comp_seq=cs)
    count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = a
    .view_comp_prefs_id
   ELSE
    p_id = a.prsnl_id, psn_cd = a.position_cd, vn = a.view_name,
    vs = a.view_seq, cn = a.comp_name, cs = a.comp_seq
   ENDIF
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 DELETE  FROM (dummyt d  WITH seq = value(temp->pid_cnt)),
   view_comp_prefs a
  SET a.seq = 1
  PLAN (d)
   JOIN (a
   WHERE (a.view_comp_prefs_id=temp->pid[d.seq].parent_entity_id))
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  a.position_cd, a.prsnl_id, a.view_name,
  a.view_seq, a.comp_name, a.comp_seq
  FROM detail_prefs a
  WHERE a.application_number=app_nbr
  ORDER BY a.position_cd, a.prsnl_id, a.view_name,
   a.view_seq, a.comp_name, a.comp_seq
  HEAD REPORT
   count1 = 0, p_id = 0, psn_cd = 0,
   cn = fillstring(12," "), vn = fillstring(12," "), vs = 0,
   cs = 0
  HEAD a.position_cd
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.prsnl_id
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.view_name
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.view_seq
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.comp_name
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  HEAD a.comp_seq
   p_id = 0, psn_cd = 0, cn = fillstring(12," "),
   vn = fillstring(12," "), vs = 0, cs = 0
  DETAIL
   IF (a.prsnl_id=p_id
    AND a.position_cd=psn_cd
    AND a.view_name=vn
    AND a.view_seq=vs
    AND a.comp_name=cn
    AND a.comp_seq=cs)
    count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = a
    .detail_prefs_id
   ELSE
    p_id = a.prsnl_id, psn_cd = a.position_cd, vn = a.view_name,
    vs = a.view_seq, cn = a.comp_name, cs = a.comp_seq
   ENDIF
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 DELETE  FROM (dummyt d  WITH seq = value(temp->pid_cnt)),
   detail_prefs a
  SET a.seq = 1
  PLAN (d)
   JOIN (a
   WHERE (a.detail_prefs_id=temp->pid[d.seq].parent_entity_id))
  WITH nocounter
 ;end delete
 CALL text(7,4,"Deleting any stranded name_value_prefs rows...")
 DELETE  FROM name_value_prefs n
  WHERE n.parent_entity_name="APP_PREFS"
   AND  NOT (n.parent_entity_id IN (
  (SELECT DISTINCT
   a.app_prefs_id
   FROM app_prefs a)))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.parent_entity_name="VIEW_PREFS"
   AND  NOT (n.parent_entity_id IN (
  (SELECT DISTINCT
   v.view_prefs_id
   FROM view_prefs v)))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.parent_entity_name="VIEW_COMP_PREFS"
   AND  NOT (n.parent_entity_id IN (
  (SELECT DISTINCT
   vc.view_comp_prefs_id
   FROM view_comp_prefs vc)))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.parent_entity_name="DETAIL_PREFS"
   AND  NOT (n.parent_entity_id IN (
  (SELECT DISTINCT
   d.detail_prefs_id
   FROM detail_prefs d)))
 ;end delete
 DELETE  FROM name_value_prefs n
  WHERE n.parent_entity_name="PREDEFINED_PREFS"
   AND  NOT (n.parent_entity_id IN (
  (SELECT DISTINCT
   p.predefined_prefs_id
   FROM predefined_prefs p)))
 ;end delete
 CALL text(8,4,"Deleting duplicate name value pairs...")
 SET count1 = 0
 SELECT INTO "nl:"
  n.parent_entity_name, n.parent_entity_id, n.pvc_name,
  n.sequence
  FROM name_value_prefs n
  ORDER BY n.parent_entity_name, n.parent_entity_id, n.pvc_name,
   n.sequence
  HEAD REPORT
   count1 = 0
  HEAD n.parent_entity_name
   idx = 0
  HEAD n.parent_entity_id
   idx = 0
  HEAD n.pvc_name
   idx = 0
  HEAD n.sequence
   idx = 0
  DETAIL
   idx = (idx+ 1)
   IF (idx > 1)
    count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = n
    .name_value_prefs_id
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO count1)
   DELETE  FROM name_value_prefs n
    WHERE (n.name_value_prefs_id=temp->pid[x].parent_entity_id)
   ;end delete
 ENDFOR
 CALL text(9,4,"Deleting cascaded duplicate name value pairs...")
 SELECT INTO "nl:"
  n.pvc_name, n.pvc_value
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.application_number=app_nbr
    AND a.position_cd=0
    AND a.prsnl_id=0)
   JOIN (n
   WHERE n.parent_entity_id=a.app_prefs_id
    AND n.parent_entity_name="APP_PREFS")
  ORDER BY n.pvc_name
  HEAD REPORT
   count1 = 0
  HEAD n.pvc_name
   count1 = (count1+ 1), stat = alterlist(temp1->qual,count1), temp1->qual[count1].pvc_name = n
   .pvc_name,
   temp1->qual[count1].pvc_value = n.pvc_value
  DETAIL
   row + 0
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(count1)),
    app_prefs a,
    name_value_prefs n
   PLAN (d)
    JOIN (n
    WHERE (n.pvc_name=temp1->qual[d.seq].pvc_name)
     AND (n.pvc_value=temp1->qual[d.seq].pvc_value)
     AND n.parent_entity_name="APP_PREFS")
    JOIN (a
    WHERE a.app_prefs_id=n.parent_entity_id
     AND a.application_number=app_nbr
     AND ((a.position_cd > 0) OR (a.prsnl_id > 0)) )
   HEAD REPORT
    count2 = 0
   DETAIL
    count2 = (count2+ 1), stat = alterlist(temp2->qual,count2), temp2->qual[count2].nvp_id = n
    .name_value_prefs_id
   WITH nocounter
  ;end select
  FOR (x = 1 TO count2)
    DELETE  FROM name_value_prefs n
     PLAN (n
      WHERE (n.name_value_prefs_id=temp2->qual[x].nvp_id))
     WITH nocounter
    ;end delete
  ENDFOR
 ENDIF
 GO TO accept_option
#resequence
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,25,"** RESEQUENCE POWERCHART PREFERENCES **")
 CALL text(5,3,"Beginning Position Code -> 0")
 CALL text(6,3,"Ending Position Code -> 999999999")
 CALL text(7,3,"Beginning Prsnl Id -> 0")
 CALL text(8,3,"Ending Prsnl Id -> 999999999")
 CALL text(9,3,"View Name ->")
 CALL text(10,3,"New Seq -> 0")
 CALL text(22,3,"Correct ->")
#seq_beg_psn
 CALL accept(5,30,"999999999",0)
 SET beg_psn_cd = curaccept
#seq_end_psn
 CALL accept(6,27,"999999999",999999999)
 SET end_psn_cd = curaccept
#seq_beg_prsnl_id
 IF (beg_psn_cd > 0)
  SET beg_prsnl_id = 0
  SET end_prsnl_id = 999999999
  GO TO seq_view_name
 ENDIF
 CALL accept(7,25,"999999999",0)
 SET beg_prsnl_id = curaccept
#seq_end_prsnl_id
 CALL accept(8,22,"999999999",999999999)
 SET end_prsnl_id = curaccept
#seq_view_name
 CALL accept(9,16,"CCCCCCCCCCCCCCC;CU")
 SET vn = curaccept
#seq_view_seq
 CALL accept(10,14,"99",0)
 SET vs = curaccept
 CALL accept(22,14,"C;CU","Y")
 SET confirm = curaccept
 IF (confirm != "Y")
  GO TO accept_option
 ENDIF
 SET uncomitted_chgs = "Y"
 UPDATE  FROM view_prefs v
  SET v.view_seq = vs
  WHERE v.application_number=app_nbr
   AND v.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND v.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND v.view_name=vn
  WITH nocounter
 ;end update
 UPDATE  FROM name_value_prefs n
  SET n.pvc_value = cnvtstring(vs)
  WHERE n.parent_entity_name="VIEW_PREFS"
   AND n.pvc_name="DISPLAY_SEQ"
   AND n.parent_entity_id IN (
  (SELECT DISTINCT
   v.view_prefs_id
   FROM view_prefs v
   WHERE v.application_number=app_nbr
    AND v.position_cd BETWEEN beg_psn_cd AND end_psn_cd
    AND v.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
    AND v.view_name=vn))
 ;end update
 UPDATE  FROM view_comp_prefs v
  SET v.view_seq = vs
  WHERE v.application_number=app_nbr
   AND v.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND v.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND v.view_name=vn
  WITH nocounter
 ;end update
 UPDATE  FROM detail_prefs d
  SET d.view_seq = vs
  WHERE d.application_number=app_nbr
   AND d.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND d.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND d.view_name=vn
  WITH nocounter
 ;end update
 GO TO accept_option
#new
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"ADDING A NEW PREFERENCE")
 CALL text(5,3,"1) Add a new application row")
 CALL text(6,3,"2) Add a new view row")
 CALL text(7,3,"3) Add a new component row")
 CALL text(8,3,"4) Add a new detail row")
 CALL text(9,3,"5) Add a name/value pair")
 CALL text(19,3,"98) Return to previous menu")
 CALL text(20,3,"99) Exit Program")
#accept_new_opt
 CALL text(22,15,"Please select option ->                                   ")
 CALL accept(22,39,"99;")
 SET new_choice = curaccept
 IF (new_choice=98)
  GO TO accept_option
 ENDIF
 IF (new_choice=99)
  GO TO exit_program
 ENDIF
 IF (((new_choice < 1) OR (new_choice > 5)) )
  GO TO accept_new_opt
 ENDIF
 IF (new_choice=1)
  GO TO new_app_row
 ENDIF
 IF (new_choice=2)
  GO TO new_view_row
 ENDIF
 IF (new_choice=3)
  GO TO new_comp_row
 ENDIF
 IF (new_choice=4)
  GO TO new_det_row
 ENDIF
 IF (new_choice=5)
  GO TO new_nv_row
 ENDIF
 GO TO new
#new_app_row
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"ADDING A NEW APPLICATION ROW")
 CALL text(5,3,"Position Code -> 000000000")
 CALL text(6,3,"Prsnl Id -> 000000000")
 CALL text(7,3,"Correct? Y")
 CALL accept(5,20,"999999999")
 SET psn_cd = curaccept
 IF (psn_cd > 0)
  SET prsnl_id = 0
  GO TO nar_correct
 ENDIF
 CALL accept(6,15,"999999999")
 SET prsnl_id = curaccept
#nar_correct
 CALL accept(7,12,"C;CU","Y")
 SET confirm = curaccept
 IF (confirm="Y")
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    ap_id = cnvtint(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM app_prefs ap
   SET ap.app_prefs_id = ap_id, ap.application_number = app_nbr, ap.position_cd = psn_cd,
    ap.prsnl_id = prsnl_id, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ap.updt_id = 0, ap.updt_task = 0, ap.updt_applctx = 0,
    ap.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual > 0)
   INSERT  FROM name_value_prefs nvp,
     (dummyt d1  WITH seq = value(app->nv_cnt))
    SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
     "APP_PREFS",
     nvp.parent_entity_id = ap_id, nvp.pvc_name = app->nv[d1.seq].pvc_name, nvp.pvc_value = app->nv[
     d1.seq].pvc_value,
     nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = 0,
     nvp.updt_task = 0, nvp.updt_applctx = 0, nvp.updt_cnt = 0
    PLAN (d1)
     JOIN (nvp)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 GO TO new
#new_view_row
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"ADDING A NEW VIEW ROW       ")
 CALL text(5,3,"Position Code -> 000000000")
 CALL text(6,3,"Prsnl Id -> 000000000")
 CALL text(7,3,"Frame Type ->")
 CALL text(8,3,"View Name ->")
 CALL text(9,3,"View Seq ->")
 CALL text(10,3,"Caption ->")
 CALL text(11,3,"Does this view contain another view?")
 CALL text(12,3,"DLL Name ->")
 CALL text(13,3,"Correct? Y")
 CALL accept(5,20,"999999999")
 SET psn_cd = curaccept
 IF (psn_cd > 0)
  SET prsnl_id = 0
  GO TO nvr_frame
 ENDIF
 CALL accept(6,15,"999999999")
 SET prsnl_id = curaccept
#nvr_frame
 CALL accept(7,17,"CCCCCCCCCCCC;CU")
 SET ft = curaccept
 CALL accept(8,16,"CCCCCCCCCCCC;CU")
 SET vn = curaccept
 CALL accept(9,15,"99")
 SET vs = curaccept
 SET viewp->nv[2].pvc_value = cnvtstring(vs)
 CALL accept(10,14,"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;C")
 SET viewp->nv[1].pvc_value = curaccept
 CALL accept(11,40,"C;CU")
 SET vi = curaccept
 IF (vi="N")
  SET viewp->nv[3].pvc_value = "0"
  SET viewp->nv[4].pvc_value = " "
  GO TO nvr_correct
 ENDIF
 SET viewp->nv[3].pvc_value = "1"
 CALL accept(12,15,"CCCCCCCCCCCC;CU")
 SET viewp->nv[4].pvc_value = curaccept
#nvr_correct
 CALL accept(13,12,"C;CU","Y")
 SET confirm = curaccept
 IF (confirm="Y")
  SET uncomitted_chgs = "Y"
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    vp_id = cnvtint(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM view_prefs vp
   SET vp.view_prefs_id = vp_id, vp.application_number = app_nbr, vp.position_cd = psn_cd,
    vp.prsnl_id = prsnl_id, vp.frame_type = ft, vp.view_name = vn,
    vp.view_seq = vs, vp.active_ind = 1, vp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    vp.updt_id = 0, vp.updt_task = 0, vp.updt_applctx = 0,
    vp.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual > 0)
   INSERT  FROM name_value_prefs nvp,
     (dummyt d1  WITH seq = value(viewp->nv_cnt))
    SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
     "VIEW_PREFS",
     nvp.parent_entity_id = vp_id, nvp.pvc_name = viewp->nv[d1.seq].pvc_name, nvp.pvc_value = viewp->
     nv[d1.seq].pvc_value,
     nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = 0,
     nvp.updt_task = 0, nvp.updt_applctx = 0, nvp.updt_cnt = 0
    PLAN (d1)
     JOIN (nvp)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 GO TO new
#new_comp_row
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"ADDING A NEW COMPONENT ROW       ")
 CALL text(5,3,"Position Code -> 000000000")
 CALL text(6,3,"Prsnl Id -> 000000000")
 CALL text(7,3,"View Name ->")
 CALL text(8,3,"View Seq ->")
 CALL text(9,3,"Comp Name ->")
 CALL text(10,3,"Comp Seq ->")
 CALL text(11,3,"Top,Left,Height,Width -> 0,0,3,4")
 CALL text(12,3,"DLL Name ->")
 CALL text(13,3,"Correct? Y")
 CALL accept(5,20,"999999999")
 SET psn_cd = curaccept
 IF (psn_cd > 0)
  SET prsnl_id = 0
  GO TO ncr_view
 ENDIF
 CALL accept(6,15,"999999999")
 SET prsnl_id = curaccept
#ncr_view
 CALL accept(7,16,"CCCCCCCCCCCC;CU")
 SET vn = curaccept
 CALL accept(8,15,"99")
 SET vs = curaccept
 CALL accept(9,16,"CCCCCCCCCCCC;CU")
 SET cn = curaccept
 CALL accept(10,15,"99")
 SET cs = curaccept
 CALL accept(11,28,"CCCCCCC;C","0,0,3,4")
 SET viewcp->nv[1].pvc_value = curaccept
 CALL accept(12,15,"CCCCCCCCCCCCCCCCCCCCCCCCC;CU")
 SET viewcp->nv[2].pvc_value = curaccept
#ncr_correct
 CALL accept(13,12,"C;CU","Y")
 SET confirm = curaccept
 IF (confirm="Y")
  SET uncomitted_chgs = "Y"
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    vcp_id = cnvtint(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM view_comp_prefs vcp
   SET vcp.view_comp_prefs_id = vcp_id, vcp.application_number = app_nbr, vcp.position_cd = psn_cd,
    vcp.prsnl_id = prsnl_id, vcp.view_name = vn, vcp.view_seq = vs,
    vcp.comp_name = cn, vcp.comp_seq = cs, vcp.active_ind = 1,
    vcp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vcp.updt_id = 0, vcp.updt_task = 0,
    vcp.updt_applctx = 0, vcp.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual > 0)
   INSERT  FROM name_value_prefs nvp,
     (dummyt d1  WITH seq = value(viewcp->nv_cnt))
    SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
     "VIEW_COMP_PREFS",
     nvp.parent_entity_id = vcp_id, nvp.pvc_name = viewcp->nv[d1.seq].pvc_name, nvp.pvc_value =
     viewcp->nv[d1.seq].pvc_value,
     nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = 0,
     nvp.updt_task = 0, nvp.updt_applctx = 0, nvp.updt_cnt = 0
    PLAN (d1)
     JOIN (nvp)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 GO TO new
#new_det_row
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"ADDING A NEW DETAIL ROW           ")
 CALL text(5,3,"Position Code -> 000000000")
 CALL text(6,3,"Prsnl Id -> 000000000")
 CALL text(7,3,"View Name ->")
 CALL text(8,3,"View Seq ->")
 CALL text(9,3,"Comp Name ->")
 CALL text(10,3,"Comp Seq ->")
 CALL text(13,3,"Correct? Y")
 CALL accept(5,20,"999999999")
 SET psn_cd = curaccept
 IF (psn_cd > 0)
  SET prsnl_id = 0
  GO TO ndr_view
 ENDIF
 CALL accept(6,15,"999999999")
 SET prsnl_id = curaccept
#ndr_view
 CALL accept(7,16,"CCCCCCCCCCCC;CU")
 SET vn = curaccept
 CALL accept(8,15,"99")
 SET vs = curaccept
 CALL accept(9,16,"CCCCCCCCCCCC;CU")
 SET cn = curaccept
 CALL accept(10,15,"99")
 SET cs = curaccept
#ndr_correct
 CALL accept(13,12,"C;CU","Y")
 SET confirm = curaccept
 IF (confirm="Y")
  SET uncomitted_chgs = "Y"
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    dp_id = cnvtint(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM detail_prefs dp
   SET dp.detail_prefs_id = dp_id, dp.application_number = app_nbr, dp.position_cd = psn_cd,
    dp.prsnl_id = prsnl_id, dp.person_id = 0, dp.view_name = vn,
    dp.view_seq = vs, dp.comp_name = cn, dp.comp_seq = cs,
    dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = 0,
    dp.updt_task = 0, dp.updt_applctx = 0, dp.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 GO TO new
#new_nv_row
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"ADDING A NAME/VALUE ROW           ")
 CALL text(5,3,"(A)pplication, (V)iew, (C)omponent or (D)etail?")
 CALL text(6,3,"Beginning Position Code -> 0")
 CALL text(7,3,"Ending Position Code -> 999999999")
 CALL text(8,3,"Beginning Prsnl Id -> 0")
 CALL text(9,3,"Ending Prsnl Id -> 999999999")
 CALL text(10,3,"View Name ->")
 CALL text(11,3,"Beg View Seq -> 0")
 CALL text(12,3,"End View Seq -> 99")
 CALL text(13,3,"Comp Name ->")
 CALL text(14,3,"Beg Comp Seq -> 0")
 CALL text(15,3,"End Comp Seq -> 99")
 CALL text(16,3,"Name ->")
 CALL text(17,3,"Value ->")
 CALL text(22,3,"Correct ->")
#avcd
 CALL accept(5,51,"C;CU")
 SET avcd = curaccept
 IF ( NOT (avcd IN ("A", "V", "C", "D")))
  GO TO avcd
 ENDIF
#beg_psn
 CALL accept(6,30,"999999999",0)
 SET beg_psn_cd = curaccept
#end_psn
 CALL accept(7,27,"999999999",999999999)
 SET end_psn_cd = curaccept
#beg_prsnl_id
 IF (beg_psn_cd > 0)
  SET beg_prsnl_id = 0
  SET end_prsnl_id = 999999999
  GO TO view_name
 ENDIF
 CALL accept(8,25,"999999999",0)
 SET beg_prsnl_id = curaccept
#end_prsnl_id
 CALL accept(9,22,"999999999",999999999)
 SET end_prsnl_id = curaccept
#view_name
 IF (avcd="A")
  GO TO pvc_name
 ENDIF
 CALL accept(10,16,"CCCCCCCCCCCCCCC;CU")
 SET vn = curaccept
#beg_view_seq
 CALL accept(11,19,"99",0)
 SET beg_view_seq = curaccept
#end_view_seq
 CALL accept(12,19,"99",99)
 SET end_view_seq = curaccept
#comp_name
 IF (avcd="V")
  GO TO pvc_name
 ENDIF
 CALL accept(13,16,"CCCCCCCCCCCCCCC;CU")
 SET cn = curaccept
#beg_comp_seq
 CALL accept(14,19,"99",0)
 SET beg_comp_seq = curaccept
#end_comp_seq
 CALL accept(15,19,"99",99)
 SET end_comp_seq = curaccept
#pvc_name
 CALL accept(16,11,"CCCCCCCCCCCCCCCCCCCCCCCCC;C")
 SET pvc_name = curaccept
#pvc_value
 CALL accept(17,12,"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;C")
 SET pvc_value = curaccept
 CALL accept(22,14,"C;CU","Y")
 SET confirm = curaccept
 IF (confirm != "Y")
  GO TO new
 ENDIF
 SET uncomitted_chgs = "Y"
 IF (avcd="A")
  GO TO new_app_nv
 ENDIF
 IF (avcd="V")
  GO TO new_view_nv
 ENDIF
 IF (avcd="C")
  GO TO new_comp_nv
 ENDIF
 IF (avcd="D")
  GO TO new_det_nv
 ENDIF
#new_app_nv
 SELECT INTO "nl:"
  FROM app_prefs a
  WHERE a.application_number=app_nbr
   AND a.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND a.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = a
   .app_prefs_id
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 INSERT  FROM name_value_prefs n,
   (dummyt d1  WITH seq = value(temp->pid_cnt))
  SET n.seq = 1, n.name_value_prefs_id = seq(carenet_seq,nextval), n.parent_entity_name = "APP_PREFS",
   n.parent_entity_id = temp->pid[d1.seq].parent_entity_id, n.pvc_name = pvc_name, n.pvc_value =
   pvc_value,
   n.active_ind = 1, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0,
   n.updt_task = 0, n.updt_applctx = 0, n.updt_cnt = 0
  PLAN (d1)
   JOIN (n)
  WITH nocounter
 ;end insert
 GO TO new
#new_view_nv
 SELECT INTO "nl:"
  FROM view_prefs v
  WHERE v.application_number=app_nbr
   AND v.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND v.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND v.view_name=vn
   AND v.view_seq BETWEEN beg_view_seq AND end_view_seq
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = v
   .view_prefs_id
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 INSERT  FROM name_value_prefs n,
   (dummyt d1  WITH seq = value(temp->pid_cnt))
  SET n.seq = 1, n.name_value_prefs_id = seq(carenet_seq,nextval), n.parent_entity_name =
   "VIEW_PREFS",
   n.parent_entity_id = temp->pid[d1.seq].parent_entity_id, n.pvc_name = pvc_name, n.pvc_value =
   pvc_value,
   n.active_ind = 1, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0,
   n.updt_task = 0, n.updt_applctx = 0, n.updt_cnt = 0
  PLAN (d1)
   JOIN (n)
  WITH nocounter
 ;end insert
 GO TO new
#new_comp_nv
 SELECT INTO "nl:"
  FROM view_comp_prefs v
  WHERE v.application_number=app_nbr
   AND v.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND v.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND v.view_name=vn
   AND v.view_seq BETWEEN beg_view_seq AND end_view_seq
   AND v.comp_name=cn
   AND v.comp_seq BETWEEN beg_comp_seq AND end_comp_seq
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = v
   .view_comp_prefs_id
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 INSERT  FROM name_value_prefs n,
   (dummyt d1  WITH seq = value(temp->pid_cnt))
  SET n.seq = 1, n.name_value_prefs_id = seq(carenet_seq,nextval), n.parent_entity_name =
   "VIEW_COMP_PREFS",
   n.parent_entity_id = temp->pid[d1.seq].parent_entity_id, n.pvc_name = pvc_name, n.pvc_value =
   pvc_value,
   n.active_ind = 1, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0,
   n.updt_task = 0, n.updt_applctx = 0, n.updt_cnt = 0
  PLAN (d1)
   JOIN (n)
  WITH nocounter
 ;end insert
 GO TO new
#new_det_nv
 SELECT INTO "nl:"
  FROM detail_prefs d
  WHERE d.application_number=app_nbr
   AND d.position_cd BETWEEN beg_psn_cd AND end_psn_cd
   AND d.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND d.view_name=vn
   AND d.view_seq BETWEEN beg_view_seq AND end_view_seq
   AND d.comp_name=cn
   AND d.comp_seq BETWEEN beg_comp_seq AND end_comp_seq
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(temp->pid,count1), temp->pid[count1].parent_entity_id = d
   .detail_prefs_id
  FOOT REPORT
   temp->pid_cnt = count1
  WITH nocounter
 ;end select
 INSERT  FROM name_value_prefs n,
   (dummyt d1  WITH seq = value(temp->pid_cnt))
  SET n.seq = 1, n.name_value_prefs_id = seq(carenet_seq,nextval), n.parent_entity_name =
   "DETAIL_PREFS",
   n.parent_entity_id = temp->pid[d1.seq].parent_entity_id, n.pvc_name = pvc_name, n.pvc_value =
   pvc_value,
   n.active_ind = 1, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0,
   n.updt_task = 0, n.updt_applctx = 0, n.updt_cnt = 0
  PLAN (d1)
   JOIN (n)
  WITH nocounter
 ;end insert
 GO TO new
#helpful_info
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION ")
 CALL text(5,3,"1) Overview")
 CALL text(6,3,"2) Application level preferences")
 CALL text(7,3,"3) View level preferences")
 CALL text(8,3,"4) Component level preferences")
 CALL text(9,3,"5) Detail level preferences")
 CALL text(10,3,"6) Examples")
 CALL text(11,3,"7) Dll names & example colors")
 CALL text(19,3,"98) Return to previous menu")
 CALL text(20,3,"99) Exit Program")
#accept_hlp_opt
 CALL text(22,15,"Please select option ->                                   ")
 CALL accept(22,39,"99;")
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO accept_option
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 IF (((hlp_choice < 1) OR (hlp_choice > 7)) )
  GO TO accept_hlp_opt
 ENDIF
 IF (hlp_choice=1)
  GO TO hlp_overview
 ENDIF
 IF (hlp_choice=2)
  GO TO hlp_app
 ENDIF
 IF (hlp_choice=3)
  GO TO hlp_view
 ENDIF
 IF (hlp_choice=4)
  GO TO hlp_comp
 ENDIF
 IF (hlp_choice=5)
  GO TO hlp_det
 ENDIF
 IF (hlp_choice=6)
  GO TO hlp_examples
 ENDIF
 IF (hlp_choice=7)
  GO TO hlp_dll
 ENDIF
 GO TO helpful_info
#hlp_overview
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - OVERVIEW PAGE.1")
 CALL text(5,3,"The PowerChart Preference model is designed to allow maximum configuration")
 CALL text(6,3,"of the PowerChart application at a client site.  Many preferences may be  ")
 CALL text(7,3,"set using the PrefTool and the PredTool, both GUI applications.  Some may ")
 CALL text(8,3,"be set from the application itself, such as window size & location or which ")
 CALL text(9,3,"patient lists should appear.")
 CALL text(10,3,"The Preference model is composed at four levels:")
 CALL text(11,3,"   1. Application Level - high level preferences such as organizer and chart")
 CALL text(12,3,"      size and positions. Application level prefs get stored for each user ")
 CALL text(13,3,"      after they run the application the first time.  Application level ")
 CALL text(14,3,"      defaults can be set at a position or a system level.")
 CALL text(15,3,"   2. View level - contains information about which views (tabs) should ")
 CALL text(16,3,"      display and in what order. View level prefs can be set at the position")
 CALL text(17,3,"      or system level.")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 IF (hlp_choice != 97)
  GO TO hlp_overview
 ENDIF
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - OVERVIEW PAGE.2")
 CALL text(5,3,"   3. Component level - contains information about what is contained on a ")
 CALL text(6,3,"      view (tab). Component level prefs are also stored at either a position")
 CALL text(7,3,"      or a system level.")
 CALL text(8,3,"   4  Detail level - contains information relevant to a specific component.")
 CALL text(9,3,"      This information can be at a user, postition or system level and can ")
 CALL text(10,3,"      contain things such as flowsheet colors, order categories, etc.")
 CALL text(12,3,"The tables involved are APP_PREFS, VIEW_PREFS, VIEW_COMP_PREFS, DETAIL_PREFS")
 CALL text(13,3,"and NAME_VALUE_PREFS.  More information about each can be found using the ")
 CALL text(14,3,"other Helpful Information options.")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Prev screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO hlp_overview
#hlp_app
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - APPLICATION LEVEL PG.1")
 CALL text(5,3,"NAME           VALUE                DESC")
 CALL text(6,3,"CHANGEUSER     1  (or 0)            Turn on/off change user functionality   ")
 CALL text(7,3,"CHART_ACCESS   1  (or 0)            Turn on/off chart access logging        ")
 CALL text(8,3,"CHART_COLORS   8454143,16777088,8454016,4227327  (yellow,blue,green,orange) ")
 CALL text(9,3,"   note: 4 demogbar color #'s, comma seperated, to cycle through            ")
 CALL text(10,3,"CHART_POSITION 230,130,550,725      Top,Left,Height,Width for the chart     ")
 CALL text(11,3,"DBLAYOUT       4011;4111;3011;3111;2011;2111;0;0;0022;0                     ")
 CALL text(12,3,"   note: if DEMOGATTR is -1, this is the value needed for this field        ")
 CALL text(13,3,"DEFAULT_ VIEWS  0,0                 The default view for org,chart (0,1,...)")
 CALL text(14,3,"DEMOGWND       1 (or 0)             Turn on/off the demogbar component      ")
 CALL text(15,3,"DEMOGATTR      -1                   To display all demogbar fields          ")
 CALL text(16,3,"EXIT_WARN      0 (or 1)             Turn on/off the exit confirmation window")
 CALL text(17,3,"ORG_POSITION   100,60,550,675       Top,Left,Height,Width for the organizer ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_app2
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - APPLICATION LEVEL PG.2")
 CALL text(5,3,"NAME           VALUE                DESC")
 CALL text(6,3,"PPRASSIGN      1  (or 0)            Turn on coverage assignment functionali ")
 CALL text(7,3,"STICKYNOTES    1  (or 0)            Turn on/off stick note functionality    ")
 CALL text(8,3,"STYLE_ORIENTATION_FLAGS 0,0,0,0     View/subview style,view/subview orient  ")
 CALL text(9,3,"  orient note: 0-top,1-bot,2-left-3,right  style note: 0-tab,1-radio button ")
 CALL text(11,3,"WINDOW_STATES  0,0                  org,chart window state 0-nrm,1-min,2-max")
 CALL text(12,3,"                       -------------------------------                      ")
 CALL text(13,3,"DEFAULT_ORD_PROVIDER ATTENDDOC,1 (CS333-CDF MEANING,prompt on=1,off=0)      ")
 CALL text(14,3,"CALLING_SYNCH_SERVER 1 (or 0)       turn call to synchronous ord srv on/off ")
 CALL text(15,3,"DETAILS_WHEN_NEEDED  1 (or 0)       to get detail window to auto-open if    ")
 CALL text(16,3,"                                       required fields are missing          ")
 CALL text(17,3,"                                                                            ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Prev screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO hlp_app
#hlp_view
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - VIEW LEVEL")
 CALL text(5,3,"FRAME    VIEW")
 CALL text(6,3,"CHART    CHARTSUMM,CLINNOTES,FLOWSHEET,ORDERS,I&O,ORDERS,PTINFO,SPTASKLIST  ")
 CALL text(7,3,"ORDERS   EXISTTAB, NEWTAB")
 CALL text(8,3,"ORDINFO  ORDADDINFO,ORDCMT,ORDDET,ORDHIS,ORDING,ORDVAL")
 CALL text(9,3,"ORG      INBOX,MPTASKLIST,PTLIST,SCHEDVIEW")
 CALL text(10,3,"PTINFO   ALLERGY,DEMOGS,GROWTHCHART,ISTRIP,PPRSUMM,PROBLIST,VISITLIST")
 CALL text(11,3,"PTLIST   PTLISTVIEW")
 CALL text(12,3,"SPTASKLIST   TABONE,TABTWO,TABTHREE,...")
 CALL text(13,3,"MPTASKLIST   TABONE,TABTWO,TABTHREE,...")
 CALL text(14,3,"NAME/VALUE PAIRS:                                                           ")
 CALL text(15,3,"    VIEW_IND: 0 - contains components, 1 - contains another view (tabs)     ")
 CALL text(16,3,"    DLL_NAME - if the view_ind = 1, this field is required                  ")
 CALL text(17,3,"    VIEW_CAPTION - this contains what gets displayed on the tab (radio btn) ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO hlp_view
#hlp_comp
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - COMPONENT LEVEL")
 CALL text(5,3,"VIEW       COMPONENT")
 CALL text(6,3,"EXISTTAB   EXISTORD")
 CALL text(7,3,"NEWTAB     SCRATCH,ORDSEL")
 CALL text(8,3,"CHARTSUMM  any chart component")
 CALL text(9,3,"ORGSUMM    any organizer component")
 CALL text(10,3,"ALL OTHERS the component name = the view name")
 CALL text(14,3,"NAME/VALUE PAIRS:                                                           ")
 CALL text(15,3,"    COMP_DLLNAME: required field                                            ")
 CALL text(16,3,"    COMP_POSITION: 0,0,3,4 (top,left,height,width of component on the view) ")
 CALL text(17,3,"        note: view divided into 3x4 sections, top left (0,0) bot right(3,4) ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO hlp_comp
#hlp_det
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - DETAIL LEVEL")
 CALL text(5,3,"1) CLINNOTES")
 CALL text(6,3,"2) DEMOGS")
 CALL text(7,3,"3) EXISTORD")
 CALL text(8,3,"4) FLOWSHEET")
 CALL text(9,3,"5) ORDSEL")
 CALL text(10,3,"6) VISITLIST")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option ->                                   ")
 CALL accept(22,39,"99;")
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 IF (((hlp_choice < 1) OR (hlp_choice > 6)) )
  GO TO hlp_det
 ENDIF
 IF (hlp_choice=1)
  GO TO hlp_cn
 ENDIF
 IF (hlp_choice=2)
  GO TO hlp_demogs
 ENDIF
 IF (hlp_choice=3)
  GO TO hlp_exist
 ENDIF
 IF (hlp_choice=4)
  GO TO hlp_fs
 ENDIF
 IF (hlp_choice=5)
  GO TO hlp_ordsel
 ENDIF
 IF (hlp_choice=6)
  GO TO hlp_visit
 ENDIF
#hlp_cn
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Clinical Notes ")
 CALL text(5,3,"NAME/VALUE PAIRS:")
 CALL text(6,3,"pvNotes.DefaultNoteType - 0 or a valid note_type_id from the note_type table")
 CALL text(7,3,"   note: not required, but if filled out, the note type will dflt when      ")
 CALL text(8,3,"         writing a new note                                                 ")
 CALL text(9,3,"pvNotes.ReadOnly - 0 or 1, set to 1 to keep user from writing new notes (0) ")
 CALL text(10,3,"pvNotes.AllowFutureCharting - 0 or 1 to turn writing a document for a future")
 CALL text(11,3,"                              date/time on/off, dflt=1, set to 0 to disallow")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_demogs
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Demographics   ")
 CALL text(5,3,"NAME/VALUE PAIRS:")
 CALL text(6,3,"PREDEFINED_PREFS - a valid predefined_prefs_id from the predefined_prefs tbl")
 CALL text(7,3,"   note: this field is required, get valid pred prefs from query opt 4")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_exist
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Existing Orders")
 CALL text(5,3,"NAME/VALUE PAIRS:")
 CALL text(6,3,"ENCNTR_FILTER - 'ALL' or 'FOCUS', set to 'FOCUS' to restrict the current    ")
 CALL text(7,3,"                orders list to orders for the current 'in focus' visit.     ")
 CALL text(8,3,"                the default is 'ALL'                                        ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_fs
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Flowsheet pg.1 ")
 CALL text(5,3,"NAME/VALUE PAIRS - none are required, the defaults are hard-coded           ")
 CALL text(6,3,"DASHBOARD - 1 or 0 to turn dashboard on/off (1 is the default)              ")
 CALL text(7,3,"NAVIGATOR - 1 or 0 to turn navigator on/off (1 is the default)              ")
 CALL text(8,3,"REFRESH_BUTTON - 1 or 0 to turn as of button on/off (1 is the default)      ")
 CALL text(9,3,"RESULT_RADIO - 1 or 0 to turn the all results flowsheet option on/off (1)   ")
 CALL text(10,3,"ACTIVITY_RADIO - 1 or 0 to turn the activity based flowsheet option on/off 1")
 CALL text(11,3,"CUSTOM_RADIO - 1 or 0 to turn the custom flowsheet option on/off (dflt=1)   ")
 CALL text(12,3,"ADHOC_CHARTING - 1 or 0 to turn adhoc charting on/off (0 is the default)    ")
 CALL text(13,3,"DIRECT_CHARTING - 1 or 0 to turn direct charting on/off (0 is the default)  ")
 CALL text(14,3,"MAXIMIZE_VIEW - 1 or 0 to always hide dashboard,navigator (0 is the dflt)   ")
 CALL text(15,3,"AUTO_REFRESH - 0,5,15,30,60 OR 120, minutes between refresh (0-dflt,no rfr) ")
 CALL text(16,3,"FLOWSHEET_TYPE - 0-rslt,1-activity,2-custom,4-order set for dflt fs (0-dflt)")
 CALL text(17,3,"ACTIVITY_TASK_IND - 0 or 1, if fs_type=1, will there be tasks (0-dflt)      ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_fs2
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Flowsheet pg.2 ")
 CALL text(5,3,"NAME/VALUE PAIRS - none are required, the defaults are hard-coded")
 CALL text(6,3,"HEAD_BK_CLR & HEAD_TXT_CLR - header background and text colors              ")
 CALL text(7,3,"GROUP_BK_CLR & GROUP_TXT_CLR - group background and text colors             ")
 CALL text(8,3,"SECT_BK_CLR & SECT_TXT_CLR - section background and text colors             ")
 CALL text(9,3,"CAT_BK_CLR & CAT_TXT_CLR - category background and text colors              ")
 CALL text(10,3,"CRIT_VAL_CLR - critical value color                                         ")
 CALL text(11,3,"NEW_DATA_CLR - new data color                                               ")
 CALL text(12,3,"CHART_DATA_CLR - charted, but unsaved, data color                           ")
 CALL text(13,3,"ORDER_BK_CLR & ORDER_TXT_CLR - order background and text colors             ")
 CALL text(14,3,"TASK_BK_CLR & TASK_TXT_CLR - task background and text colors                ")
 CALL text(15,3,"DISCRETE_BK_CLR & DISCRETE_TXT_CLR - discrete background and text colors    ")
 CALL text(16,3,"*THE REST ARE BY FLOWSHEET_TYPE, EXAMPLES ARE FOR RSLT(R_),(A_)(C_)(O_)     ")
 CALL text(17,3,"R_ORIENTATION - 0 horizontal, 1 vertical (0 default)                        ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_fs3
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Flowsheet pg.3 ")
 CALL text(5,3,"NAME/VALUE PAIRS - none are required, the defaults are hard-coded")
 CALL text(6,3,"R_TIME_SORT - 0 chron, 1 - reverse chron (0 - default)                      ")
 CALL text(7,3,"R_FONT_SIZE - # greater than 6, (8 - default)                               ")
 CALL text(8,3,"R_COL_WIDTH - # greater than 5, (8 - default)                               ")
 CALL text(9,3,"R_OFFSET_BACK - # greater than 0, (2 - default)                             ")
 CALL text(10,3,"R_OFFSET_FORWARD - # greater than 0, (1 - default)                          ")
 CALL text(11,3,"R_OFFSET_UNIT - 3(min),4(hr),5(day),6(wk),7(mo),8(yr) (5 - default)         ")
 CALL text(12,3,"R_DISPLAY_RULE_IND - 0 - display [multiple], 1 - use disp_rule (1-dflt)     ")
 CALL text(13,3,"R_DISPLAY_RULE - 0(first),1(last),2(max),3(mean),4(min),5(range) (1-dflt)   ")
 CALL text(14,3,"R_RULE_TO_ACTUAL - 1 - use disp rule in actual mode, 0 - comma sep (1-dflt) ")
 CALL text(15,3,"R_RETRIEVE_TYPE - 0(clin date),1(sys date),2(event cnt),3(new rslt) (0-dflt)")
 CALL text(16,3,"R_RETRIEVE_CNT - 1 to 1000 (nbr events to retrieve if type=2) (50-dflt)     ")
 CALL text(17,3,"R_TIME_SCALE_NAME - 'actual'                                                ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_fs4
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Flowsheet pg.4 ")
 CALL text(5,3,"R_EVENT_SET_NAME - for results or custom, the eventset to load (all-dflt)   ")
 CALL text(6,3,"R_NEW_DATA_IND - 1 or 0 to turn displaying new results in diff color on/off1")
 CALL text(7,3,"R_NEW_DATA_CHAR_IND - 1 or  0 to turn new results character on/off (0-dflt) ")
 CALL text(8,3,"R_CHART_DATA_IND - 1 or 0 to turn display charted data in diff color on/off0")
 CALL text(9,3,"R_CRIT_IND - 1 or 0 to turn display critical data in diff color on/off (1)  ")
 CALL text(10,3,"R_CRIT_CHAR_IND- 1 or 0 to turn critical results character on/off  (0-dflt) ")
 CALL text(11,3,"R_UNITS_IND - 1 or 0 to turn units display in cell on/off   (1-dflt)        ")
 CALL text(12,3,"R_DOC_STATUS_IND - 1 or 0 to turn document status display in cell on/off (1)")
 CALL text(13,3,"R_SHOW_UNUSED_IND - 1 or 0 to turn the showing of empty columns on/off (1)  ")
 CALL text(14,3,"R_APPEND_AFTER_IND - 1 or 0 to turn displing indicators after rslt on/off(0)")
 CALL text(15,3,"some colors: 8454143-lightyellow 16777088-lightblue 8454016-lightgreen      ")
 CALL text(16,3,"4227327-orangish 16777215-white 0-black 16711680-blue 255-red 65280-green   ")
 CALL text(17,3,"16711935-pink 16776960-cyan 65535-yellow 8388608-darkblue 50-darkred        ")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_ordsel
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Order Selection")
 CALL text(5,3,"NAME/VALUE PAIRS:")
 CALL text(6,3,"ALT CATEGORY - a valid alt_sel_category_id from the alt_sel_cat table, the  ")
 CALL text(7,3,"   contents of this category will be displayed as part of order selection   ")
 CALL text(8,3,"   window.                                                                  ")
 CALL text(9,3,"ORDER PRO - 1 or 0 to turn on/off hooks to discern dialog (order pro)(0-def)")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#hlp_visit
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - Visit List     ")
 CALL text(5,3,"NAME/VALUE PAIRS:")
 CALL text(6,3,"PREDEFINED_PREFS - a valid predefined_prefs_id from the predefined_prefs tbl")
 CALL text(7,3,"   note: this field is required, get valid pred prefs from query opt 4")
 CALL text(18,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO hlp_det
#hlp_examples
#example_one
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - EXAMPLES    ")
 CALL text(5,3,"Ex 1. Everyone needs access to adhoc charting via the flowsheet.")
 CALL text(6,15,"(you'll need to back up between steps using option '98')")
 CALL text(7,3,"Step1: 8-helpful info,5-detail level preferences,1-flowsheet to get the     ")
 CALL text(8,3,"         name and valid values for a flowsheet preference of adhoc charting.")
 CALL text(9,3,"Step2: 3-wipeout,8-wipeout a specific name/value pair,'ADHOC_CHARTING' to   ")
 CALL text(10,3,"         get rid of any prefs already defined for adhoc charting.           ")
 CALL text(11,3,"Step3: 4-add something new,5-add a name/value pair,D-detail,0-beg position, ")
 CALL text(12,3,"         all 9's-end position,0-beg prsnl,all 9's-end prsnl,FLOWSHEET-view  ")
 CALL text(13,3,"         name,0-beg view seq,99-end view seq,FLOWSHEET-comp name,0-beg comp ")
 CALL text(14,3,"         seq,99-end comp seq,ADHOC_CHARTING-name,1-value to add the name    ")
 CALL text(15,3,"         value pair to all users in all positions.                          ")
 CALL text(17,3,"----------------------------------------------------------------------------")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#example_two
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - EXAMPLES    ")
 CALL text(5,3,"Ex 2. The position of RN needs access to adhoc charting via the flowsheet.")
 CALL text(6,15,"(you'll need to back up between steps using option '98')")
 CALL text(7,3,"Step1: 8-helpful info,5-detail level preferences,1-flowsheet to get the     ")
 CALL text(8,3,"         name and valid values for a flowsheet preference of adhoc charting.")
 CALL text(9,3,"Step2: 1-query,5-query positions to get the code value for position RN.     ")
 CALL text(10,3,"Step3: 3-wipeout,9-wipeout a spec nv pair for a spec user, enter the code   ")
 CALL text(11,3,"         for the RN position, enter the name portion of the name/value pair ")
 CALL text(12,3,"Step4: 4-add something new,5-add a name/value pair,D-detail,RN psn cd for   ")
 CALL text(13,3,"         beg and end position,0-beg prsnl,all 9's-end prsnl,FLOWSHEET-view  ")
 CALL text(14,3,"         name,0-beg view seq,99-end view seq,FLOWSHEET-comp name,0-beg comp ")
 CALL text(15,3,"         seq,99-end comp seq,ADHOC_CHARTING-name,1-value to add the name    ")
 CALL text(16,3,"         value pair to the RN position's preferences.                       ")
 CALL text(17,3,"----------------------------------------------------------------------------")
 CALL text(18,3,"96) Prev screen")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=96)
  GO TO example_one
 ENDIF
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
#example_three
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - EXAMPLES    ")
 CALL text(5,3,"Ex 3. The system default needs the clinical notes tab added.                ")
 CALL text(6,15,"(you'll need to back up between steps using option '98')")
 CALL text(7,3,"Step1: 8-helpful info,3&4 to get the view and component information for     ")
 CALL text(8,3,"         clinical notes.                                                    ")
 CALL text(9,3,"Step2: 1-query,1-query system level prefs,1-query view/comp...hierarchy,    ")
 CALL text(10,3,"         under the section FRAME-CHART, jot down the highest v-seq.         ")
 CALL text(11,3,"Step3: 4-add something new,2-add a new view row,0-position,0-prsnl,         ")
 CALL text(12,3,"         ORG-frame type, CLINNOTES-view name, add 1 to the v-seq and use    ")
 CALL text(13,3,"         for view seq, enter a tab caption,N-does this contain another view ")
 CALL text(14,3,"Step4: 4-add something new,3-add a new comp row,0-position,0-prsnl,         ")
 CALL text(15,3,"         CLINNOTES-view name, same view seq as above, CLINNOTES as comp     ")
 CALL text(16,3,"         name,1-comp seq, 0,0,3,4 as top,left...,PVNOTES as dllname         ")
 CALL text(17,3,"----------------------------------------------------------------------------")
 CALL text(18,3,"96) Prev screen")
 CALL text(19,3,"97) Next screen")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 97                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=96)
  GO TO example_two
 ENDIF
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO hlp_examples
#hlp_dll
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"CAREMANAGER    P R E F E R E N C E S")
 CALL text(3,15,"   HELPFUL INFORMATION - DLL'S & COLORS    ")
 CALL text(5,3,"Pt.List-pvpatlis,Inbox-pvmyp,Sched-cpsschedule,Multi-pt.tasklist-pvtasklist ")
 CALL text(6,3,"Pt.Info-pvpatinfo,Demogs-pvdemogs,PPRSummary-pvdemogppr,Visitlst-pvvisitlist")
 CALL text(7,3,"Intel-strip-isdll,Alrgy-pvallergy,GrwthChrt-pvgrowthchart,Prob-pvproblemlist")
 CALL text(8,3,"Orders-pvorder,Orderinfo-pvordinfo,OrdCmnt-pvordcmt,OrdAddlinfo-pvordaddinfo")
 CALL text(9,3,"OrdDets-pvorddet,Ordhist-pvordhis,Ordingred-pvording,Ordvalidation-pvordval ")
 CALL text(10,3,"ClinNotes-pvnotes,I&O-pvino,Single-pt.tasklist-pvtasklist                   ")
 CALL text(14,3,"8454143-lightyellow,16777088-lightblue,8454016-lightgreen,50-darkred,       ")
 CALL text(15,3,"4227327-orangish,16777215-white,0-black,16711680-blue,255-red,65280-green,  ")
 CALL text(16,3,"16711935-pink,16776960-cyan,65535-yellow,8388608-darkblue                   ")
 CALL text(17,3,"----------------------------------------------------------------------------")
 CALL text(20,3,"98) Return to previous menu")
 CALL text(21,3,"99) Exit Program")
 CALL text(22,15,"Please select option -> 98                                ")
 CALL accept(22,39,"99;",97)
 SET hlp_choice = curaccept
 IF (hlp_choice=98)
  GO TO helpful_info
 ENDIF
 IF (hlp_choice=99)
  GO TO exit_program
 ENDIF
 GO TO helpful_info
#exit_program
 IF (uncomitted_chgs="Y")
  CALL text(22,15,"Commit changes?                                        ")
  CALL accept(22,31,"X;CU","N")
  IF (curaccept="Y")
   COMMIT
  ENDIF
 ENDIF
 CALL clear(1,1)
END GO

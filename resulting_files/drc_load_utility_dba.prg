CREATE PROGRAM drc_load_utility:dba
 PAINT
 CALL video("R")
 CALL clear(1,1,80)
 CALL text(1,32,"DRC LOAD UTILITY")
 CALL video("N")
 DECLARE send_dcl(dcl_string=vc) = null
 DECLARE show_processing(x=i2) = null
 DECLARE rename_log(from_name=vc,to_name=vc) = null
 DECLARE view_log(lname=vc) = null
 DECLARE get_cd_by_mean(cmean=vc,cset=i4) = i2
 DECLARE down_arrow(str1=vc) = null
 DECLARE up_arrow(strup=vc) = null
 DECLARE create_std_box(mxcnt=i2) = null
 DECLARE clear_screen(abc=i2) = null
 SUBROUTINE send_dcl(dcl_string)
   SET dcl_flag = 0
   SET dcl_length = size(dcl_string)
   CALL dcl(dcl_string,dcl_length,dcl_flag)
 END ;Subroutine
 SUBROUTINE show_processing(x)
  CALL clear_screen(0)
  CALL text(23,1,"Processing...")
 END ;Subroutine
 SUBROUTINE rename_log(from_name,to_name)
   IF (findfile(value(from_name)))
    FREE SET dlen
    FREE SET dstat
    FREE SET dstr
    DECLARE dlen = i4 WITH public, noconstant(0)
    DECLARE dstat = i2 WITH public, noconstant(0)
    DECLARE dstr = vc WITH public, noconstant("")
    IF (cursys="AIX")
     SET dstr = concat("mv ",trim(from_name)," ",trim(to_name))
     SET dlen = textlen(dstr)
    ENDIF
    IF (cursys="AXP")
     SET dstr = concat("rename ",trim(from_name)," ",trim(to_name))
     SET dlen = textlen(dstr)
    ENDIF
    CALL dcl(dstr,dlen,dstat)
    IF (dstat=0)
     CALL echo("***** FILE RENAME FAILED *****")
     CALL echo("***** FILE RENAME FAILED *****")
     CALL echo("***** FILE RENAME FAILED *****")
     GO TO exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE view_log(lname)
   IF (findfile(value(lname)))
    CALL echo(concat(lname," was successfully found..."))
    SET lcnt = 0
    FREE RECORD lg
    RECORD lg(
      1 lst[*]
        2 ln = c78
    )
    DEFINE rtl value(lname)
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     DETAIL
      lcnt = (lcnt+ 1)
      IF (mod(lcnt,10)=1)
       stat = alterlist(lg->lst,(lcnt+ 10))
      ENDIF
      lg->lst[lcnt].ln = substring(1,73,r.line)
      IF (textlen(trim(r.line)) > 72)
       lcnt = (lcnt+ 1)
       IF (mod(lcnt,10)=1)
        stat = alterlist(lg->lst,(lcnt+ 10))
       ENDIF
       lg->lst[lcnt].ln = concat(" *",substring(74,70,r.line))
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(lg->lst,lcnt)
    CALL create_std_box(lcnt)
    CALL clear_screen(0)
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      SET holdstr = lg->lst[cnt].ln
      CALL scrolltext(cnt,holdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
    CALL text(23,1,"Press <return> to go back        ROW:")
    SET pick = 0
    WHILE (pick=0)
     CALL accept(23,38,"9999;S",cnt)
     CASE (curscroll)
      OF 0:
       CALL clear_screen(0)
       GO TO list_new_drc_grp
      OF 1:
       IF (cnt < maxcnt)
        SET cnt = (cnt+ 1)
        SET holdstr = lg->lst[cnt].ln
        CALL down_arrow(holdstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET holdstr = lg->lst[cnt].ln
        CALL up_arrow(holdstr)
       ENDIF
      OF 3:
      OF 4:
      OF 6:
       IF (numsrow < maxcnt)
        SET cnt = ((cnt+ numsrow) - 1)
        IF (((cnt+ numsrow) > maxcnt))
         SET cnt = (maxcnt - numsrow)
        ENDIF
        SET arow = 1
        WHILE (arow <= numsrow)
          SET cnt = (cnt+ 1)
          SET holdstr = lg->lst[cnt].ln
          CALL scrolltext(arow,holdstr)
          SET arow = (arow+ 1)
        ENDWHILE
        SET arow = 1
        SET cnt = ((cnt - numsrow)+ 1)
       ENDIF
      OF 5:
       IF (((cnt - numsrow) > 0))
        SET cnt = (cnt - numsrow)
       ELSE
        SET cnt = 1
       ENDIF
       SET tmp1 = cnt
       SET arow = 1
       WHILE (arow <= numsrow
        AND cnt < maxcnt)
         SET holdstr = lg->lst[cnt].ln
         CALL scrolltext(arow,holdstr)
         SET cnt = (cnt+ 1)
         SET arow = (arow+ 1)
       ENDWHILE
       SET cnt = tmp1
       SET arow = 1
     ENDCASE
    ENDWHILE
    CALL clear_screen(0)
   ELSE
    CALL echo(concat(lname," was NOT found..."))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_cd_by_mean(cmean,cset)
   DECLARE cv = f8
   SET cv = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=cset
     AND c.cdf_meaning=trim(cmean)
    DETAIL
     cv = c.code_value
    WITH nocounter
   ;end select
   RETURN(cv)
 END ;Subroutine
 SUBROUTINE down_arrow(str1)
   IF (arow=numsrow)
    CALL scrolldown(arow,arow,str1)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,str1)
   ENDIF
 END ;Subroutine
 SUBROUTINE up_arrow(strup)
   IF (arow=1)
    CALL scrollup(arow,arow,strup)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,strup)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_std_box(mxcnt)
   SET maxcnt = mxcnt
   SET cnt = 1
   SET holdstr = ""
   CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
   CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 END ;Subroutine
 SUBROUTINE clear_screen(abc)
   IF (abc=0)
    CALL clear(3,1)
   ENDIF
 END ;Subroutine
 IF (validate(readme_data,"0")="0")
  IF ( NOT (validate(readme_data,0)))
   FREE SET readme_data
   RECORD readme_data(
     1 ocd = i4
     1 readme_id = f8
     1 instance = i4
     1 readme_type = vc
     1 description = vc
     1 script = vc
     1 check_script = vc
     1 data_file = vc
     1 par_file = vc
     1 blocks = i4
     1 log_rowid = vc
     1 status = vc
     1 message = c255
     1 options = vc
     1 driver = vc
     1 batch_dt_tm = dq8
   )
  ENDIF
  SET kia_notreadme = 1
 ENDIF
 DECLARE numscol = i4 WITH public, noconstant(75)
 DECLARE numsrow = i4 WITH public, noconstant(17)
 DECLARE srowoff = i4 WITH public, noconstant(4)
 DECLARE scoloff = i4 WITH public, noconstant(2)
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE lcnt = i4 WITH public, noconstant(0)
 DECLARE maxcnt = i4 WITH public, noconstant(0)
 DECLARE holdstr = c75 WITH public, noconstant("")
 DECLARE route_cnt = i4 WITH public, noconstant(0)
 DECLARE lexi_check = i2 WITH public, noconstant(0)
 DECLARE lexi_grpr_id = f8 WITH public, noconstant(0.0)
 DECLARE lexi_grpr_nm = vc WITH public, noconstant("")
 IF ((xxcclseclogin->loggedin != 1)
  AND  NOT (cnvtupper(curuser) IN ("P30INS", "DD011127")))
  EXECUTE cclseclogin
  IF ((xxcclseclogin->loggedin != 1))
   SET message = nowindow
   CALL clear_screen(0)
   CALL echo("USER MUST BE LOGGED INTO CCL TO RUN THIS UTILITY...")
   CALL echo("USER MUST BE LOGGED INTO CCL TO RUN THIS UTILITY...")
   CALL echo("USER MUST BE LOGGED INTO CCL TO RUN THIS UTILITY...")
   CALL pause(3)
   SET message = window
   GO TO exit_program
  ENDIF
 ENDIF
 IF (findfile("cer_install:lexicomp_drc_extract.csv")=1)
  SET lexi_check = 1
  CALL create_lexi_log(1)
 ELSE
  SET lexi_check = 0
 ENDIF
#pick_mode
 CALL clear_screen(0)
 CALL text(3,18,"   PROGRAM OPTIONS FOR STANDARD DATA NOT LOADED   ")
 CALL text(5,1,"01 CHECK ROUTES AND UNITS                                                       ")
 CALL text(6,1,"02 RECONCILE ROUTE MAPPINGS                                                     ")
 CALL text(7,1,"03 SHOW LIST/LOAD NEW DRC GROUPER DATA                                          ")
 CALL text(8,1,"04 SHOW LIST/LOAD NEW CONDITION DATA                        AVAILABLE VIA WIZARD")
 CALL text(9,1,"05 SHOW LIST/LOAD NEW POST MENSTRUAL AGE DATA               AVAILABLE VIA WIZARD")
 CALL text(10,1,"06 SHOW LIST/LOAD NEW HEPATIC DATA                          AVAILABLE VIA WIZARD")
 CALL text(11,1,"07 SHOW LIST/LOAD NEW CrCl DATA                             AVAILABLE VIA WIZARD")
 IF (lexi_check=1)
  CALL text(12,1,"08 LOAD Lexi-Comp                                           AVAILABLE VIA WIZARD")
  CALL text(13,1,"                                                                                ")
  CALL text(14,1,"99 EXIT PROGRAM                                                                 ")
  CALL text(23,1,"Choose an option:")
  CALL accept(23,19,"99;",99
   WHERE curaccept IN (1, 2, 3, 4, 5,
   6, 7, 99))
 ELSE
  CALL text(12,1,"                                                                                ")
  CALL text(13,1,"99 EXIT PROGRAM                                                                 ")
  CALL text(23,1,"Choose an option:")
  CALL accept(23,19,"99;",99
   WHERE curaccept IN (1, 2, 3, 4, 5,
   6, 7, 99))
 ENDIF
#restart
 CASE (curaccept)
  OF 1:
   GO TO routes_units_mode
  OF 2:
   EXECUTE FROM reconcile_routes TO reconcile_routes_exit
  OF 3:
   EXECUTE FROM list_new_drc_grp TO list_new_drc_grp_exit
  OF 4:
   GO TO pick_mode
  OF 5:
   GO TO pick_mode
  OF 6:
   GO TO pick_mode
  OF 7:
   GO TO pick_mode
  OF 8:
   EXECUTE FROM load_lexi TO load_lexi_exit
  OF 9:
   EXECUTE FROM lexi_reports TO lexi_reports_exit
  OF 99:
   GO TO exit_program
 ENDCASE
 GO TO pick_mode
#routes_units_mode
 CALL clear_screen(0)
 CALL text(3,29,"CHECK ROUTES AND UNITS     ")
 CALL text(5,1,"01 ROUTES                    ")
 CALL text(6,1,"02 UNITS                     ")
 CALL text(7,1,"03 RECONCILE ROUTE MAPPINGS  ")
 CALL text(8,1,"04 Return To Main Menu       ")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM routes TO routes_exit
  OF 2:
   EXECUTE FROM units TO units_exit
  OF 3:
   EXECUTE FROM reconcile_routes TO reconcile_routes_exit
  OF 4:
   GO TO pick_mode
 ENDCASE
 GO TO routes_units_mode
#routes
 CALL clear_screen(0)
 CALL video("N")
 UPDATE  FROM dcp_entity_reltn d
  SET d.entity2_display =
   (SELECT
    c.display
    FROM code_value c
    WHERE c.code_value=d.entity2_id), d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = sysdate
  WHERE (d.entity2_display !=
  (SELECT
   c.display
   FROM code_value c
   WHERE c.code_value=d.entity2_id))
   AND d.entity_reltn_mean="DRC/ROUTE"
  WITH nocounter
 ;end update
 IF (curqual > 0)
  COMMIT
 ENDIF
 FREE RECORD routes
 RECORD routes(
   1 lst[*]
     2 mltm_display = c40
     2 mill_display = c40
     2 combined_str = c75
 )
 SET route_cnt = 0
 SELECT DISTINCT INTO "nl:"
  m.route_disp
  FROM mltm_drc_premise m
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    d.entity1_id
    FROM dcp_entity_reltn d
    WHERE m.route_id=d.entity1_id
     AND d.entity_reltn_mean="DRC/ROUTE"))))
  ORDER BY m.route_disp
  DETAIL
   route_cnt = (route_cnt+ 1), stat = alterlist(routes->lst,route_cnt), routes->lst[route_cnt].
   mltm_display = m.route_disp,
   routes->lst[route_cnt].mill_display = "", temp = fillstring(35," "), routes->lst[route_cnt].
   combined_str = concat(substring(1,35,m.route_disp),"     ",temp)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m,
   dcp_entity_reltn d
  PLAN (m)
   JOIN (d
   WHERE m.route_id=d.entity1_id
    AND m.route_disp != d.entity2_display
    AND d.entity_reltn_mean="DRC/ROUTE")
  ORDER BY m.route_disp
  DETAIL
   route_cnt = (route_cnt+ 1), stat = alterlist(routes->lst,route_cnt), routes->lst[route_cnt].
   mltm_display = m.route_disp,
   routes->lst[route_cnt].mill_display = substring(1,40,d.entity2_display), routes->lst[route_cnt].
   combined_str = concat(substring(1,35,m.route_disp),"     ",substring(1,35,d.entity2_display))
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m,
   dcp_entity_reltn d
  PLAN (m)
   JOIN (d
   WHERE m.route_id=d.entity1_id
    AND m.route_disp=d.entity2_display
    AND d.entity_reltn_mean="DRC/ROUTE")
  ORDER BY m.route_disp
  DETAIL
   route_cnt = (route_cnt+ 1), stat = alterlist(routes->lst,route_cnt), routes->lst[route_cnt].
   mltm_display = m.route_disp,
   routes->lst[route_cnt].mill_display = substring(1,40,d.entity2_display), routes->lst[route_cnt].
   combined_str = concat(substring(1,35,m.route_disp),"     ",substring(1,35,d.entity2_display))
  WITH nocounter
 ;end select
 CALL create_std_box(route_cnt)
 CALL clear_screen(0)
 CALL video("R")
 CALL text(4,3,"DRC Route Display                       Data Base Display                    ")
 CALL video("N")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr = routes->lst[cnt].combined_str
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Press <return> to go back        ROW:")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,38,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    CALL clear_screen(0)
    GO TO routes_units_mode
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr = routes->lst[cnt].combined_str
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr = ""
     SET holdstr = routes->lst[cnt].combined_str
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr = ""
       SET holdstr = routes->lst[cnt].combined_str
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr = ""
      SET holdstr = routes->lst[cnt].combined_str
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 GO TO routes
#routes_exit
#units
 CALL clear_screen(0)
 CALL video("N")
 FREE RECORD units
 RECORD units(
   1 lst[*]
     2 mltm_display = c17
     2 mill_display = c17
     2 cki = c30
     2 combined_str = c75
 )
 SET unit_cnt = 0
 SELECT DISTINCT INTO "nl:"
  m.dose_unit_disp
  FROM mltm_drc_premise m
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    c.cki
    FROM code_value c
    WHERE c.code_set=54
     AND m.dose_unit_cki=c.cki)))
    AND  NOT (m.dose_unit_disp IN ("", " ", null)))
  ORDER BY cnvtupper(m.dose_unit_disp)
  DETAIL
   unit_cnt = (unit_cnt+ 1), stat = alterlist(units->lst,unit_cnt), units->lst[unit_cnt].mltm_display
    = m.dose_unit_disp,
   units->lst[unit_cnt].mill_display = " ", units->lst[unit_cnt].cki = m.dose_unit_cki, temp =
   fillstring(5," "),
   units->lst[unit_cnt].combined_str = concat(units->lst[unit_cnt].mltm_display,temp,units->lst[
    unit_cnt].mill_display,temp,units->lst[unit_cnt].cki)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  m.dose_unit_disp
  FROM mltm_drc_premise m,
   code_value c
  PLAN (m
   WHERE  NOT (m.dose_unit_disp IN ("", " ", null)))
   JOIN (c
   WHERE m.dose_unit_cki=c.cki)
  ORDER BY cnvtupper(m.dose_unit_disp)
  DETAIL
   unit_cnt = (unit_cnt+ 1), stat = alterlist(units->lst,unit_cnt), units->lst[unit_cnt].mltm_display
    = m.dose_unit_disp,
   units->lst[unit_cnt].mill_display = c.display, units->lst[unit_cnt].cki = c.cki, temp = fillstring
   (5," "),
   units->lst[unit_cnt].combined_str = concat(units->lst[unit_cnt].mltm_display,temp,units->lst[
    unit_cnt].mill_display,temp,units->lst[unit_cnt].cki)
  WITH nocounter
 ;end select
 CALL create_std_box(unit_cnt)
 CALL clear_screen(0)
 CALL text(3,15," ***** USE CS_54_UTILITY to RECONCILE UNITS ***** ")
 CALL video("R")
 CALL text(4,3,"DRC DISPLAY           DATA BASE DISPLAY     CKI                            ")
 CALL video("N")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr = units->lst[cnt].combined_str
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Press <return> to go back        ROW:")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,38,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    CALL clear_screen(0)
    GO TO routes_units_mode
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr = units->lst[cnt].combined_str
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr = ""
     SET holdstr = units->lst[cnt].combined_str
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr = ""
       SET holdstr = units->lst[cnt].combined_str
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr = ""
      SET holdstr = units->lst[cnt].combined_str
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 GO TO units
#units_exit
#list_new_drc_grp
 CALL clear_screen(0)
 FREE RECORD drc_grp
 RECORD drc_grp(
   1 lst[*]
     2 grp_name = c100
     2 grp_id = f8
 )
 SET drc_grp_cnt = 0
 SELECT INTO "nl:"
  FROM mltm_drc_premise m
  WHERE m.dose_range_check_id < 1
   AND m.renal_unit_cki IN ("", " ", null)
   AND m.renal_condition_txt IN ("", " ", null)
   AND m.liver_desc IN ("", " ", null)
   AND m.corrected_gest_age_unit_disp IN ("", " ", null)
  ORDER BY cnvtupper(m.grouper_name)
  HEAD m.grouper_name
   drc_grp_cnt = (drc_grp_cnt+ 1), stat = alterlist(drc_grp->lst,drc_grp_cnt), drc_grp->lst[
   drc_grp_cnt].grp_name = m.grouper_name,
   drc_grp->lst[drc_grp_cnt].grp_id = m.grouper_id
  DETAIL
   djd = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO drc_grp_cnt)
   SELECT INTO "drc_new_groupers.log"
    FROM dual
    DETAIL
     IF (x=1)
      temp_str = fillstring(50,"*"),
      CALL print(temp_str), row + 1,
      CALL print(concat("NEW DRC GROUPERS - ",format(cnvtdatetime(curdate,curtime3),
        "dd-mmm-yyyy hh:mm:ss;;d"))), row + 1, temp_str = fillstring(40,"-"),
      CALL print(temp_str), row + 1
     ENDIF
     IF (x < 10)
      CALL print(concat("0",trim(cnvtstring(x)),": ",drc_grp->lst[x].grp_name))
     ELSE
      CALL print(concat(trim(cnvtstring(x)),": ",drc_grp->lst[x].grp_name))
     ENDIF
    WITH append, nocounter, noformfeed,
     format = variable, maxcol = 132, maxrow = 1
   ;end select
 ENDFOR
 CALL text(3,29,"  LIST/LOAD NEW DRC GROUPERS  ")
 CALL text(5,1,"01 VIEW NEW GROUPERS                ")
 CALL text(6,1,"02 LOAD NEW GROUPERS                ")
 CALL text(7,1,"03 VIEW IMPORT LOG FILE             ")
 CALL text(8,1,"04 Return to Main Menu              ")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM view_new_drc_grp TO view_new_drc_grp_exit
  OF 2:
   EXECUTE FROM load_new_drc_grp TO load_new_drc_grp_exit
  OF 3:
   CALL view_log("kia_import_drc_2.log")
  OF 4:
   GO TO pick_mode
 ENDCASE
 GO TO list_new_drc_grp
#list_new_drc_grp_exit
#view_new_drc_grp
 CALL clear_screen(0)
 CALL video("N")
 CALL create_std_box(drc_grp_cnt)
 CALL clear_screen(0)
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr = drc_grp->lst[cnt].grp_name
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(3,27,"   New Grouper Listing   ")
 CALL text(4,29,concat(" ",trim(cnvtstring(size(drc_grp->lst,5)))," new groupers "))
 CALL text(23,1,"Press <return> to go back        ROW:")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,38,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    CALL clear_screen(0)
    GO TO list_new_drc_grp
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr = drc_grp->lst[cnt].grp_name
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr = ""
     SET holdstr = drc_grp->lst[cnt].grp_name
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr = ""
       SET holdstr = drc_grp->lst[cnt].grp_name
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr = ""
      SET holdstr = drc_grp->lst[cnt].grp_name
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 GO TO list_new_drc_grp
#view_new_drc_grp_exit
#load_new_drc_grp
 CALL clear_screen(0)
 CALL text(3,29,"LOAD NEW GROUPERS")
 CALL text(5,1,"01 Load As ACTIVE             ")
 CALL text(6,1,"02 Load As INACTIVE           ")
 CALL text(7,1,"03 Return To New Grouper Menu ")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",3
  WHERE curaccept IN (1, 2, 3))
 SET new_grp_active = 0
 CASE (curaccept)
  OF 1:
   SET new_grp_active = 1
   EXECUTE FROM import_new_drc_grp TO import_new_drc_grp_exit
  OF 2:
   SET new_grp_active = 0
   EXECUTE FROM import_new_drc_grp TO import_new_drc_grp_exit
  OF 3:
   GO TO list_new_drc_grp
 ENDCASE
 GO TO load_new_drc_grp
#load_new_drc_grp_exit
#import_new_drc_grp
 CALL show_processing(0)
 EXECUTE FROM create_request_struct TO create_request_struct_exit
 SET request->domain_flag = 0
 SET request->import_method_flag = 1
 SET stat = alterlist(request->drc_obj_list,50)
 SET loop_ctr = 0
 SET script_ctr = 0
 FOR (master_ctr = 1 TO drc_grp_cnt)
   IF ( NOT ((drc_grp->lst[master_ctr].grp_name IN ("", " ", null))))
    SET loop_ctr = (loop_ctr+ 1)
    SET request->drc_obj_list[loop_ctr].drc_obj.active_ind = new_grp_active
    SET request->drc_obj_list[loop_ctr].drc_obj.build_contributor = "MULTUM INSTALL"
    SET request->drc_obj_list[loop_ctr].drc_obj.grouper_id = cnvtint(drc_grp->lst[master_ctr].grp_id)
    SET request->drc_obj_list[loop_ctr].drc_obj.grouper_name = drc_grp->lst[master_ctr].grp_name
    SET request->drc_obj_list[loop_ctr].drc_obj.facility_disp = "DEFAULT"
    SET drc_obj_cnt = 0
    SELECT INTO "nl:"
     FROM mltm_drc_premise m
     PLAN (m
      WHERE m.grouper_id=cnvtreal(request->drc_obj_list[loop_ctr].drc_obj.grouper_id)
       AND m.renal_unit_cki IN ("", " ", null)
       AND m.renal_condition_txt IN ("", " ", null)
       AND m.liver_desc IN ("", " ", null)
       AND m.corrected_gest_age_unit_disp IN ("", " ", null))
     ORDER BY m.drc_identifier, m.multum_case_id
     DETAIL
      drc_obj_cnt = (drc_obj_cnt+ 1), stat = alterlist(request->drc_obj_list[loop_ctr].drc_obj.
       qualifier_list,drc_obj_cnt), request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[
      drc_obj_cnt].qualifier.active_ind = 1,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.age_operator = m
      .age_operator_txt, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].
      qualifier.age_unit = m.age_unit_disp, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[
      drc_obj_cnt].qualifier.age_unit_cki = m.age_unit_cki,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.drc_identifier =
      m.drc_identifier, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier
      .qualifier_id = 0.0, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].
      qualifier.from_age = m.age_low_nbr,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.to_age = m
      .age_high_nbr, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
      weight_operator = m.weight_operator_txt, request->drc_obj_list[loop_ctr].drc_obj.
      qualifier_list[drc_obj_cnt].qualifier.from_weight = m.weight_low_value,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.to_weight = m
      .weight_high_value, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].
      qualifier.weight_unit = m.weight_unit_disp, request->drc_obj_list[loop_ctr].drc_obj.
      qualifier_list[drc_obj_cnt].qualifier.weight_unit_cki = m.weight_unit_cki,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.renal_operator =
      m.renal_operator_txt, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].
      qualifier.from_renal = m.renal_low_value, request->drc_obj_list[loop_ctr].drc_obj.
      qualifier_list[drc_obj_cnt].qualifier.to_renal = m.renal_high_value,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.renal_unit = m
      .renal_unit_disp, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier
      .renal_unit_cki = m.renal_unit_cki, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[
      drc_obj_cnt].qualifier.multum_case_id = m.multum_case_id,
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.route_group = "",
      request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[drc_obj_cnt].qualifier.concept_cki = m
      .condition_concept_cki
     WITH nocounter
    ;end select
    FOR (x = 1 TO drc_obj_cnt)
     SET route_obj_cnt = 0
     SELECT DISTINCT INTO "nl:"
      d.entity2_display
      FROM mltm_drc_premise m,
       dcp_entity_reltn d
      PLAN (m
       WHERE m.grouper_id=cnvtreal(request->drc_obj_list[loop_ctr].drc_obj.grouper_id)
        AND (m.drc_identifier=request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[x].qualifier.
       drc_identifier)
        AND m.renal_unit_cki IN ("", " ", null)
        AND m.renal_condition_txt IN ("", " ", null)
        AND m.liver_desc IN ("", " ", null)
        AND m.corrected_gest_age_unit_disp IN ("", " ", null))
       JOIN (d
       WHERE m.route_id=d.entity1_id
        AND d.entity_reltn_mean="DRC/ROUTE")
      DETAIL
       route_obj_cnt = (route_obj_cnt+ 1), stat = alterlist(request->drc_obj_list[loop_ctr].drc_obj.
        qualifier_list[x].qualifier.route_list,route_obj_cnt), request->drc_obj_list[loop_ctr].
       drc_obj.qualifier_list[x].qualifier.route_list[route_obj_cnt].route.active_ind = 1,
       request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[x].qualifier.route_list[route_obj_cnt].
       route.route_cki = "", request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[x].qualifier.
       route_list[route_obj_cnt].route.route_disp = d.entity2_display, request->drc_obj_list[loop_ctr
       ].drc_obj.qualifier_list[x].qualifier.route_list[route_obj_cnt].route.route_id = 0.0
      WITH nocounter
     ;end select
    ENDFOR
    FOR (q = 1 TO drc_obj_cnt)
     SET dr_obj_cnt = 0
     SELECT DISTINCT INTO "nl:"
      m.dose_range_type_id
      FROM mltm_drc_premise m
      WHERE m.grouper_id=cnvtreal(request->drc_obj_list[loop_ctr].drc_obj.grouper_id)
       AND (m.drc_identifier=request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.
      drc_identifier)
       AND m.renal_unit_cki IN ("", " ", null)
       AND m.renal_condition_txt IN ("", " ", null)
       AND m.liver_desc IN ("", " ", null)
       AND m.corrected_gest_age_unit_disp IN ("", " ", null)
      DETAIL
       dr_obj_cnt = (dr_obj_cnt+ 1), stat = alterlist(request->drc_obj_list[loop_ctr].drc_obj.
        qualifier_list[q].qualifier.dose_range_list,dr_obj_cnt), request->drc_obj_list[loop_ctr].
       drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.active_ind = 1,
       request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt
       ].dose_range.comment = m.comment_txt, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q
       ].qualifier.dose_range_list[dr_obj_cnt].dose_range.dose_range_id = 0.0, request->drc_obj_list[
       loop_ctr].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.
       dose_range_type = m.dose_range_type,
       request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt
       ].dose_range.dose_unit = m.dose_unit_disp, request->drc_obj_list[loop_ctr].drc_obj.
       qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.dose_unit_cki = m
       .dose_unit_cki, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.
       dose_range_list[dr_obj_cnt].dose_range.max_dose = m.max_dose_amt,
       request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt
       ].dose_range.max_dose_unit = m.max_dose_unit_disp, request->drc_obj_list[loop_ctr].drc_obj.
       qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.max_dose_unit_cki = m
       .max_dose_unit_cki, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.
       dose_range_list[dr_obj_cnt].dose_range.from_dose_amount = m.low_dose_value,
       request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt
       ].dose_range.from_variance_percent = 0, request->drc_obj_list[loop_ctr].drc_obj.
       qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.to_dose_amount = m
       .high_dose_value, request->drc_obj_list[loop_ctr].drc_obj.qualifier_list[q].qualifier.
       dose_range_list[dr_obj_cnt].dose_range.to_variance_percent = 0
      WITH nocounter
     ;end select
    ENDFOR
    IF (((loop_ctr=50) OR (master_ctr=drc_grp_cnt)) )
     SET script_ctr = (script_ctr+ 1)
     CALL show_processing2(script_ctr)
     EXECUTE kia_import_drc
     EXECUTE mltm_upd_mltm_drc_premise
     IF (master_ctr=drc_grp_cnt)
      FREE RECORD request
     ELSE
      EXECUTE FROM create_request_struct TO create_request_struct_exit
      SET request->domain_flag = 0
      SET request->import_method_flag = 1
      SET stat = alterlist(request->drc_obj_list,50)
      SET loop_ctr = 0
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#import_new_drc_grp_exit
#reconcile_routes
 FREE RECORD routes
 RECORD routes(
   1 lst[*]
     2 mltm_display = c40
     2 mltm_id = f8
     2 mill_display = c40
     2 mill_id = f8
     2 combined_str = c75
 )
 SET route_cnt = 0
 SELECT DISTINCT INTO "nl:"
  m.route_disp
  FROM mltm_drc_premise m
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    d.entity1_id
    FROM dcp_entity_reltn d
    WHERE m.route_id=d.entity1_id
     AND d.entity_reltn_mean="DRC/ROUTE"))))
  ORDER BY m.route_disp
  DETAIL
   route_cnt = (route_cnt+ 1), stat = alterlist(routes->lst,route_cnt), routes->lst[route_cnt].
   mltm_display = m.route_disp,
   routes->lst[route_cnt].mltm_id = m.route_id, routes->lst[route_cnt].mill_display = "", temp =
   fillstring(35," "),
   routes->lst[route_cnt].combined_str = concat(substring(1,35,m.route_disp),"     ",temp)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m,
   dcp_entity_reltn d
  PLAN (m)
   JOIN (d
   WHERE m.route_id=d.entity1_id
    AND m.route_disp != d.entity2_display
    AND d.entity_reltn_mean="DRC/ROUTE")
  ORDER BY m.route_disp
  DETAIL
   route_cnt = (route_cnt+ 1), stat = alterlist(routes->lst,route_cnt), routes->lst[route_cnt].
   mltm_display = m.route_disp,
   routes->lst[route_cnt].mltm_id = m.route_id, routes->lst[route_cnt].mill_display = substring(1,40,
    d.entity2_display), routes->lst[route_cnt].mill_id = d.entity2_id,
   routes->lst[route_cnt].combined_str = concat(substring(1,35,m.route_disp),"     ",substring(1,35,d
     .entity2_display))
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m,
   dcp_entity_reltn d
  PLAN (m)
   JOIN (d
   WHERE m.route_id=d.entity1_id
    AND m.route_disp=d.entity2_display
    AND d.entity_reltn_mean="DRC/ROUTE")
  ORDER BY m.route_disp
  DETAIL
   route_cnt = (route_cnt+ 1), stat = alterlist(routes->lst,route_cnt), routes->lst[route_cnt].
   mltm_display = m.route_disp,
   routes->lst[route_cnt].mltm_id = m.route_id, routes->lst[route_cnt].mill_display = substring(1,40,
    d.entity2_display), routes->lst[route_cnt].mill_id = d.entity2_id,
   routes->lst[route_cnt].combined_str = concat(substring(1,35,m.route_disp),"     ",substring(1,35,d
     .entity2_display))
  WITH nocounter
 ;end select
 FOR (x = 1 TO route_cnt)
   SELECT INTO "drc_routes.log"
    FROM dual
    DETAIL
     IF (x=1)
      temp_str = fillstring(75,"*"),
      CALL print(temp_str), row + 1,
      CALL print(concat("DATE/TIME: ",format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"
        ))), row + 1, col 4,
      "MULTUM ROUTE", col 44, "MILLENNIUM ROUTE",
      row + 1, temp_str = fillstring(75,"-"),
      CALL print(temp_str),
      row + 1
     ENDIF
     IF (x < 10)
      CALL print(concat("0",trim(cnvtstring(x)),": ",routes->lst[x].combined_str))
     ELSE
      CALL print(concat(trim(cnvtstring(x)),": ",routes->lst[x].combined_str))
     ENDIF
    WITH append, nocounter, noformfeed,
     format = variable, maxcol = 132, maxrow = 1
   ;end select
 ENDFOR
 CALL create_std_box(route_cnt)
 CALL clear_screen(0)
 CALL text(3,3,"                       CURRENT ROUTE MAPPINGS                              ")
 CALL video("R")
 CALL text(4,3,"     DRC Route Display                       Data Base Display              ")
 CALL video("N")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",routes->lst[cnt].combined_str)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(24,1,"Select a ROUTE to reconcile (MAP/UNMAP)   (enter 0 to go back):")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(24,65,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pick_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     IF ((routes->lst[pick].mill_display > ""))
      CALL unmap_route(routes->lst[pick].mltm_id,routes->lst[pick].mill_id,routes->lst[pick].
       mltm_display,routes->lst[pick].mill_display)
     ELSE
      CALL list_cs_4001(routes->lst[pick].mltm_display,routes->lst[pick].mltm_id)
     ENDIF
    ELSE
     CALL clear_screen(0)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",routes->lst[cnt].combined_str)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr = ""
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",routes->lst[cnt].combined_str)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",routes->lst[cnt].combined_str)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr = ""
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",routes->lst[cnt].combined_str)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 GO TO reconcile_routes
#reconcile_routes_exit
 SUBROUTINE list_cs_4001(mltm_display,mltm_id)
   FREE RECORD cs_4001
   RECORD cs_4001(
     1 lst[*]
       2 cv = f8
       2 disp = vc
   )
   SET 4001_cnt = 0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE  NOT ( EXISTS (
    (SELECT
     m.entity2_id
     FROM dcp_entity_reltn m
     WHERE m.entity_reltn_mean="DRC/ROUTE"
      AND c.code_value=m.entity2_id)))
     AND c.code_set=4001
    ORDER BY c.display_key
    DETAIL
     4001_cnt = (4001_cnt+ 1), stat = alterlist(cs_4001->lst,4001_cnt), cs_4001->lst[4001_cnt].cv = c
     .code_value,
     cs_4001->lst[4001_cnt].disp = c.display
    WITH nocounter
   ;end select
   CALL create_std_box(4001_cnt)
   CALL video("R")
   SET djd = concat("MULTUM ROUTE: ",trim(mltm_display),"          CODE SET 4001 VALUE LISTING")
   CALL text(3,3,djd)
   CALL video("N")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",cs_4001->lst[cnt].disp)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(24,1,"Select a CODE_VALUE to reconcile        (enter 000 to go back):")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(24,65,"999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO reconcile_routes
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
       CALL save_to_dcp(cs_4001->lst[pick].disp,cs_4001->lst[pick].cv,mltm_display,mltm_id)
      ELSE
       CALL clear_screen(0)
       GO TO reconcile_routes
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",cs_4001->lst[cnt].disp)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",cs_4001->lst[cnt].disp)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr = ""
         SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",cs_4001->lst[cnt].disp)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr = ""
        SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",cs_4001->lst[cnt].disp)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE unmap_route(kia_mltm_id,kia_mill_id,kia_mltm_disp,kia_mill_disp)
   CALL clear_screen(0)
   CALL text(3,3,concat("Are you sure you want to UNMAP the ROUTE: ",kia_mltm_disp))
   CALL text(4,3,concat("from the CODE_VALUE: ",kia_mill_disp))
   CALL text(10,3," Y/N ")
   CALL accept(10,9,"C;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   CALL show_processing(0)
   CASE (curaccept)
    OF "Y":
     DELETE  FROM dcp_entity_reltn d
      WHERE d.entity1_id=kia_mltm_id
       AND d.entity2_id=kia_mill_id
       AND d.entity_reltn_mean="DRC/ROUTE"
      WITH nocounter
     ;end delete
     COMMIT
    OF "N":
     GO TO reconcile_routes
   ENDCASE
 END ;Subroutine
 SUBROUTINE save_to_dcp(kia_disp,kia_cv,kia_mltm_disp,kia_mltm_id)
   CALL clear_screen(0)
   CALL text(3,3,concat("Are you sure you want to map the ROUTE: ",kia_mltm_disp))
   CALL text(4,3,concat("to the CODE_VALUE: ",kia_disp))
   CALL text(10,3," Y/N ")
   CALL accept(10,9,"C;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   CALL show_processing(0)
   CASE (curaccept)
    OF "Y":
     INSERT  FROM dcp_entity_reltn a
      SET a.active_ind = 1, a.begin_effective_dt_tm = sysdate, a.dcp_entity_reltn_id = seq(
        carenet_seq,nextval),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), a.entity1_display =
       kia_mltm_disp, a.entity1_id = kia_mltm_id,
       a.entity1_name = "MLTM_DRC_PREMISE", a.entity2_display = kia_disp, a.entity2_id = kia_cv,
       a.entity2_name = "CODE_VALUE", a.entity_reltn_mean = "DRC/ROUTE", a.rank_sequence = 0,
       a.updt_applctx = 0.0, a.updt_cnt = 0, a.updt_dt_tm = sysdate,
       a.updt_id = 0, a.updt_task = 0
      WITH nocounter
     ;end insert
     COMMIT
    OF "N":
     GO TO reconcile_routes
   ENDCASE
 END ;Subroutine
#load_lexi
 CALL clear_screen(0)
 CALL text(3,3,"  PLEASE WAIT WHILE Lexi-Comp BASELINE DATA IS LOADING...  ")
 FREE SET cmt_import_log_id
 DECLARE cmt_import_log_id = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM cmt_import_log c
  WHERE c.input_filename="LEXICOMP_IMPORT"
  DETAIL
   cmt_import_log_id = c.cmt_import_log_id
  WITH nocounter
 ;end select
 IF (cmt_import_log_id=0.0)
  INSERT  FROM cmt_import_log c
   SET c.cmt_import_log_id = seq(reference_seq,nextval), c.end_dt_tm = cnvtdatetime("31-DEC-2100"), c
    .input_filename = "LEXICOMP_IMPORT",
    c.logfile_name = "STATUS_INFO", c.block_size = 0, c.log_level = 1,
    c.package_nbr = 99999, c.readme = 9999, c.script_name = "LEXICOMP_IMPORT",
    c.start_dt_tm = sysdate, c.start_record = 0, c.status_flag = 1,
    c.updt_cnt = 1, c.updt_dt_tm = sysdate
   WITH nocounter
  ;end insert
  SELECT INTO "nl:"
   FROM cmt_import_log c
   WHERE c.input_filename="LEXICOMP_IMPORT"
   DETAIL
    cmt_import_log_id = c.cmt_import_log_id
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("Remove rows that have any age_unit other than 'year(s)'...")
 DELETE  FROM mltm_drc_premise m
  WHERE m.age_unit_disp != "year(s)"
  WITH nocounter
 ;end delete
 CALL echo("Remove rows that have age_low_nbr < 18 and age_unit_disp = 'year(s)'...")
 DELETE  FROM mltm_drc_premise m
  WHERE m.age_low_nbr < 18
  WITH nocounter
 ;end delete
 CALL echo(
  "Remove rows that have age_low_nbr = 18 and age_operator is '<' and age_unit_disp = 'year(s)'...")
 DELETE  FROM mltm_drc_premise m
  WHERE m.age_low_nbr=18
   AND m.age_operator_txt="<"
   AND m.age_unit_disp="year(s)"
  WITH nocounter
 ;end delete
 COMMIT
 EXECUTE kia_upd_cs_4001990
 EXECUTE kia_dm_dbimport "cer_install:lexicomp_drc_extract.csv", "kia_imp_mltm_drc_premise", 1000,
 0
 CALL echo("REMOVE ANY GROUPERS THAT ARE NOT ON DOSE_RANGE_CHECK_TABLE")
 DELETE  FROM mltm_drc_premise m
  WHERE  NOT ( EXISTS (
  (SELECT
   1
   FROM dose_range_check d
   WHERE d.dose_range_check_name=m.grouper_name)))
  WITH nocounter
 ;end delete
 CALL echo("REMOVE ANY CONDITION ROWS THAT DO NOT HAVE A MATCHING CONCEPT_CKI ON NOMENCLATURE")
 DELETE  FROM mltm_drc_premise m
  WHERE  NOT ( EXISTS (
  (SELECT
   1
   FROM nomenclature n
   WHERE m.condition_concept_cki=n.concept_cki)))
   AND  NOT (m.condition_concept_cki IN ("", " ", null))
  WITH nocounter
 ;end delete
 CALL echo("Remove rows that have any age_unit other than 'year(s)'...")
 UPDATE  FROM mltm_drc_premise m
  SET m.updt_id = 100.0
  WHERE m.age_unit_disp != "year(s)"
  WITH nocounter
 ;end update
 CALL echo("Remove rows that have age_low_nbr < 18 and age_unit_disp = 'year(s)'...")
 UPDATE  FROM mltm_drc_premise m
  SET m.updt_id = 100.0
  WHERE m.age_low_nbr < 18
  WITH nocounter
 ;end update
 CALL echo(
  "Remove rows that have age_low_nbr = 18 and age_operator is '<' and age_unit_disp = 'year(s)'...")
 UPDATE  FROM mltm_drc_premise m
  SET m.updt_id = 100.0
  WHERE m.age_low_nbr=18
   AND m.age_operator_txt="<"
   AND m.age_unit_disp="year(s)"
  WITH nocounter
 ;end update
 UPDATE  FROM mltm_drc_premise m
  SET m.dose_range_type =
   (SELECT
    c.display
    FROM code_value c
    WHERE cnvtupper(c.description)=cnvtupper(m.dose_range_type)
     AND c.code_set=4001990
     AND c.active_ind=1), m.dose_range_type_id =
   (SELECT
    cnvtreal(c.cdf_meaning)
    FROM code_value c
    WHERE cnvtupper(c.description)=cnvtupper(m.dose_range_type)
     AND c.code_set=4001990
     AND c.active_ind=1)
  WHERE  NOT (m.dose_range_type IN ("", " ", null))
  WITH nocounter
 ;end update
 COMMIT
 EXECUTE mltm_upd_mltm_drc_premise
 UPDATE  FROM mltm_drc_premise m
  SET m.dose_range_check_id = 0.0
  WHERE m.updt_id=100.0
  WITH nocounter
 ;end update
 COMMIT
 EXECUTE FROM disp_lexicomp_data TO disp_lexicomp_data_exit
#load_lexi_exit
#disp_lexicomp_data
 FREE RECORD lexilist
 RECORD lexilist(
   1 lst[*]
     2 grouper_name = vc
     2 grouper_id = f8
 )
 DECLARE lexilist_ctr = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM mltm_drc_premise m
  WHERE m.dose_range_check_id=0.0
   AND m.updt_id=100.0
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM cmt_import_log_msg c
   WHERE c.cmt_import_log_id=cmt_import_log_id
    AND c.log_message=m.grouper_name)))
  ORDER BY cnvtupper(m.grouper_name)
  HEAD m.grouper_name
   lexilist_ctr = (lexilist_ctr+ 1), stat = alterlist(lexilist->lst,lexilist_ctr), lexilist->lst[
   lexilist_ctr].grouper_id = m.grouper_id,
   lexilist->lst[lexilist_ctr].grouper_name = m.grouper_name
  DETAIL
   kia_djd = 1
  WITH nocounter
 ;end select
 CALL create_std_box(lexilist_ctr)
 CALL clear_screen(0)
 CALL text(3,3,"                       Lexi-Comp GROUPERS                                  ")
 CALL video("R")
 CALL text(4,3,"      GROUPER NAME                                                         ")
 CALL video("N")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",lexilist->lst[cnt].grouper_name)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(24,1,"SELECT A GROUPER TO LOAD (0000 to go back) (9999 to load all):")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(24,65,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     EXECUTE mltm_upd_mltm_drc_premise
     GO TO pick_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL lexi_import_log(1,lexilist->lst[pick].grouper_name)
     IF (check_custom_data(lexilist->lst[pick].grouper_name)=0)
      CALL inactivate_premise(lexilist->lst[pick].grouper_name)
      SET lexi_grpr_id = lexilist->lst[pick].grouper_id
      SET lexi_grpr_nm = lexilist->lst[pick].grouper_name
      EXECUTE FROM import_lexi TO import_lexi_exit
     ENDIF
    ELSEIF (cnvtint(curaccept)=9999)
     CALL clear_screen(0)
     FOR (lexi_lp_ct = 1 TO maxcnt)
       SET pick = lexi_lp_ct
       CALL lexi_import_log(1,lexilist->lst[pick].grouper_name)
       IF (check_custom_data(lexilist->lst[pick].grouper_name)=0)
        CALL inactivate_premise(lexilist->lst[pick].grouper_name)
        SET lexi_grpr_id = lexilist->lst[pick].grouper_id
        SET lexi_grpr_nm = lexilist->lst[pick].grouper_name
        EXECUTE FROM import_lexi TO import_lexi_exit
       ENDIF
     ENDFOR
     EXECUTE mltm_upd_mltm_drc_premise
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",lexilist->lst[cnt].grouper_name)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr = ""
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",lexilist->lst[cnt].grouper_name)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr = ""
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",lexilist->lst[cnt].grouper_name)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr = ""
      SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",lexilist->lst[cnt].grouper_name)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 GO TO disp_lexicomp_data
#disp_lexicomp_data_exit
 SUBROUTINE lexi_import_log(lexi_status,lexi_grp_nm)
   FREE SET cmt_imp_log_msg_id
   FREE SET lexi_seq
   DECLARE cmt_imp_log_msg_id = f8 WITH public, noconstant(0.0)
   DECLARE lexi_seq = i4 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM cmt_import_log_msg c
    WHERE c.cmt_import_log_id=cmt_import_log_id
    ORDER BY c.log_seq
    DETAIL
     lexi_seq = (c.log_seq+ 1)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cmt_import_log_msg c
    WHERE c.cmt_import_log_id=cmt_import_log_id
     AND c.log_message=lexi_grp_nm
    DETAIL
     cmt_imp_log_msg_id = c.cmt_import_log_msg_id
    WITH nocounter
   ;end select
   IF (cmt_imp_log_msg_id > 0)
    UPDATE  FROM cmt_import_log_msg c
     SET c.log_status_flag = lexi_status, c.end_dt_tm = sysdate, c.updt_cnt = (c.updt_cnt+ 1),
      c.updt_dt_tm = sysdate
     WHERE c.cmt_import_log_msg_id=cmt_imp_log_msg_id
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM cmt_import_log_msg c
     SET c.cmt_import_log_id = cmt_import_log_id, c.cmt_import_log_msg_id = seq(reference_seq,nextval
       ), c.end_dt_tm = null,
      c.log_instance = 1, c.log_message = lexi_grp_nm, c.log_seq = lexi_seq,
      c.log_status_flag = 0, c.start_dt_tm = sysdate, c.updt_applctx = 0.0,
      c.updt_cnt = 0, c.updt_dt_tm = sysdate, c.updt_id = 0.0,
      c.updt_task = 0
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE check_custom_data(grp_name)
   FREE SET tmp_dose_range_check_id
   DECLARE tmp_dose_range_check_id = f8 WITH public, noconstant(0.0)
   FREE SET custom_data_ind
   DECLARE custom_data_ind = i2 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM dose_range_check d
    WHERE d.dose_range_check_name=grp_name
     AND d.active_ind=1
    DETAIL
     tmp_dose_range_check_id = d.dose_range_check_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM drc_premise d
    WHERE d.dose_range_check_id=tmp_dose_range_check_id
     AND d.updt_task=4170171
    DETAIL
     custom_data_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM drc_dose_range d
    WHERE d.drc_premise_id IN (
    (SELECT
     d2.drc_premise_id
     FROM drc_premise d2
     WHERE d2.dose_range_check_id=tmp_dose_range_check_id))
     AND d.updt_task=4170171
    DETAIL
     custom_data_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM long_text l
    WHERE (l.long_text_id=
    (SELECT
     d.long_text_id
     FROM drc_dose_range d
     WHERE d.drc_premise_id IN (
     (SELECT
      d2.drc_premise_id
      FROM drc_premise d2
      WHERE d2.dose_range_check_id=tmp_dose_range_check_id))))
     AND l.updt_task=4170171
    DETAIL
     custom_data_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM drc_premise_list d
    WHERE d.drc_premise_id IN (
    (SELECT
     d2.drc_premise_id
     FROM drc_premise d2
     WHERE d2.dose_range_check_id=tmp_dose_range_check_id))
     AND d.updt_task=4170171
    DETAIL
     custom_data_ind = 1
    WITH nocounter
   ;end select
   IF (custom_data_ind=1)
    CALL lexi_import_log(4,grp_name)
    SET message = nowindow
    CALL echo(
     "************************************************************************************************"
     )
    CALL echo(concat(grp_name," NOT LOADED BECAUSE PRE-EXISTING CUSTOM DATA WAS FOUND"))
    CALL echo(
     "************************************************************************************************"
     )
    CALL pause(2)
    SET message = window
   ENDIF
   RETURN(custom_data_ind)
 END ;Subroutine
 SUBROUTINE inactivate_premise(grper_name)
   FREE SET tmp_dose_range_check_id
   DECLARE tmp_dose_range_check_id = f8 WITH public, noconstant(0.0)
   FREE SET lexi_inact_ctr
   DECLARE lexi_inact_ctr = i4 WITH public, noconstant(0)
   FREE RECORD lexi_inact
   RECORD lexi_inact(
     1 lst[*]
       2 parent_prem_id = f8
       2 version_seq = i4
   )
   SELECT INTO "nl:"
    FROM dose_range_check d
    WHERE d.dose_range_check_name=grper_name
    DETAIL
     tmp_dose_range_check_id = d.dose_range_check_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM drc_premise d
    WHERE d.dose_range_check_id=tmp_dose_range_check_id
     AND d.premise_type_flag=1
     AND d.parent_premise_id != 0.0
     AND d.active_ind=1
     AND d.relational_operator_flag=1
     AND d.value1=18.0
     AND (d.value_unit_cd=
    (SELECT
     c.code_value
     FROM code_value c
     WHERE c.code_set=54
      AND c.cdf_meaning="YEARS"
      AND c.active_ind=1))
    DETAIL
     lexi_inact_ctr = (lexi_inact_ctr+ 1), stat = alterlist(lexi_inact->lst,lexi_inact_ctr),
     lexi_inact->lst[lexi_inact_ctr].parent_prem_id = d.parent_premise_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM drc_premise d
    WHERE d.dose_range_check_id=tmp_dose_range_check_id
     AND d.premise_type_flag=1
     AND d.parent_premise_id != 0.0
     AND d.active_ind=1
     AND d.value1 < 18.0
     AND (d.value_unit_cd=
    (SELECT
     c.code_value
     FROM code_value c
     WHERE c.code_set=54
      AND c.cdf_meaning="YEARS"
      AND c.active_ind=1))
    DETAIL
     lexi_inact_ctr = (lexi_inact_ctr+ 1), stat = alterlist(lexi_inact->lst,lexi_inact_ctr),
     lexi_inact->lst[lexi_inact_ctr].parent_prem_id = d.parent_premise_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM drc_premise d
    WHERE d.dose_range_check_id=tmp_dose_range_check_id
     AND d.premise_type_flag=1
     AND d.parent_premise_id != 0.0
     AND d.active_ind=1
     AND d.value_unit_cd > 0.0
     AND d.value_unit_cd IN (
    (SELECT
     c.code_value
     FROM code_value c
     WHERE c.code_set=54
      AND c.cdf_meaning IN ("SECONDS", "MINUTES", "HOURS", "DAYS", "WEEKS",
     "MONTHS")
      AND c.active_ind=1))
    DETAIL
     lexi_inact_ctr = (lexi_inact_ctr+ 1), stat = alterlist(lexi_inact->lst,lexi_inact_ctr),
     lexi_inact->lst[lexi_inact_ctr].parent_prem_id = d.parent_premise_id
    WITH nocounter
   ;end select
   IF (lexi_inact_ctr > 0)
    CALL echo("INACTIVATING PRE-EXISTING PREMISE'S...")
    UPDATE  FROM drc_premise d,
      (dummyt d2  WITH seq = value(lexi_inact_ctr))
     SET d.active_ind = 0, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = sysdate
     PLAN (d2)
      JOIN (d
      WHERE (d.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)
       AND d.active_ind=1)
     WITH nocounter, maxcommit = 500
    ;end update
    SELECT INTO "nl:"
     FROM drc_premise_ver d,
      (dummyt d2  WITH seq = value(lexi_inact_ctr))
     PLAN (d2)
      JOIN (d
      WHERE (d.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id))
     ORDER BY d.ver_seq
     DETAIL
      lexi_inact->lst[d2.seq].version_seq = (d.ver_seq+ 1)
     WITH nocounter
    ;end select
    CALL echo("Adding inactivated row to drc_premise_ver...")
    INSERT  FROM drc_premise_ver d,
      (dummyt d2  WITH seq = value(lexi_inact_ctr))
     SET d.active_ind =
      (SELECT
       x.active_ind
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.concept_cki =
      (SELECT
       x.concept_cki
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.dose_range_check_id =
      (SELECT
       x.dose_range_check_id
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)),
      d.drc_premise_id = lexi_inact->lst[d2.seq].parent_prem_id, d.multum_case_id =
      (SELECT
       x.multum_case_id
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.parent_ind =
      (SELECT
       x.parent_ind
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)),
      d.parent_premise_id =
      (SELECT
       x.parent_premise_id
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.premise_type_flag =
      (SELECT
       x.premise_type_flag
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.relational_operator_flag
       =
      (SELECT
       x.relational_operator_flag
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)),
      d.value1 =
      (SELECT
       x.value1
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.value1_string =
      (SELECT
       x.value1_string
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.value2 =
      (SELECT
       x.value2
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)),
      d.value2_string =
      (SELECT
       x.value2_string
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.value_type_flag =
      (SELECT
       x.value_type_flag
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)), d.value_unit_cd =
      (SELECT
       x.value_unit_cd
       FROM drc_premise x
       WHERE (x.drc_premise_id=lexi_inact->lst[d2.seq].parent_prem_id)),
      d.ver_seq = lexi_inact->lst[d2.seq].version_seq, d.updt_cnt = 0, d.updt_dt_tm = sysdate
     PLAN (d2)
      JOIN (d)
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
#import_lexi
 CALL show_processing(0)
 EXECUTE FROM create_request_struct TO create_request_struct_exit
 SET request->domain_flag = 0
 SET request->import_method_flag = 1
 SET stat = alterlist(request->drc_obj_list,1)
 SET new_grp_active = 1
 SELECT INTO "nl:"
  FROM dose_range_check d
  WHERE d.dose_range_check_name=lexi_grpr_nm
  DETAIL
   new_grp_active = d.active_ind
  WITH nocounter
 ;end select
 SET request->drc_obj_list[1].drc_obj.active_ind = new_grp_active
 SET request->drc_obj_list[1].drc_obj.build_contributor = "MULTUM INSTALL"
 SET request->drc_obj_list[1].drc_obj.grouper_id = cnvtint(lexi_grpr_id)
 SET request->drc_obj_list[1].drc_obj.grouper_name = lexi_grpr_nm
 SET request->drc_obj_list[1].drc_obj.facility_disp = "DEFAULT"
 SET drc_obj_cnt = 0
 SELECT INTO "nl:"
  FROM mltm_drc_premise m
  PLAN (m
   WHERE m.grouper_id=lexi_grpr_id
    AND m.updt_id=100.0)
  ORDER BY m.drc_identifier, m.multum_case_id
  DETAIL
   drc_obj_cnt = (drc_obj_cnt+ 1), stat = alterlist(request->drc_obj_list[1].drc_obj.qualifier_list,
    drc_obj_cnt), request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.active_ind
    = 1,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.age_operator = m
   .age_operator_txt, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.age_unit
    = m.age_unit_disp, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   age_unit_cki = m.age_unit_cki,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.drc_identifier = m
   .drc_identifier, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   qualifier_id = 0.0, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   from_age = m.age_low_nbr,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.to_age = m.age_high_nbr,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.weight_operator = m
   .weight_operator_txt, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   from_weight = m.weight_low_value,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.to_weight = m
   .weight_high_value, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   weight_unit = m.weight_unit_disp, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].
   qualifier.weight_unit_cki = m.weight_unit_cki,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.renal_operator = m
   .renal_operator_txt, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   from_renal = m.renal_low_value, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].
   qualifier.to_renal = m.renal_high_value,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.renal_unit = m
   .renal_unit_disp, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   renal_unit_cki = m.renal_unit_cki, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].
   qualifier.pma_operator = m.corrected_gest_age_oper_txt,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.from_pma = m
   .corrected_gest_age_low_nbr, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].
   qualifier.to_pma = m.corrected_gest_age_high_nbr, request->drc_obj_list[1].drc_obj.qualifier_list[
   drc_obj_cnt].qualifier.pma_unit = m.corrected_gest_age_unit_disp,
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.pma_unit_cki = m
   .corrected_gest_age_cki, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.
   multum_case_id = m.multum_case_id, request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].
   qualifier.route_group = "",
   request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.concept_cki = m
   .condition_concept_cki
   IF (cnvtupper(trim(m.liver_desc)) IN ("YES", "Y", "1"))
    request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.hepatic_dysfunction_ind =
    1
   ELSE
    request->drc_obj_list[1].drc_obj.qualifier_list[drc_obj_cnt].qualifier.hepatic_dysfunction_ind =
    0
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO drc_obj_cnt)
  SET route_obj_cnt = 0
  SELECT DISTINCT INTO "nl:"
   d.entity2_display
   FROM mltm_drc_premise m,
    dcp_entity_reltn d
   PLAN (m
    WHERE m.grouper_id=cnvtreal(request->drc_obj_list[1].drc_obj.grouper_id)
     AND (m.drc_identifier=request->drc_obj_list[1].drc_obj.qualifier_list[x].qualifier.
    drc_identifier)
     AND m.updt_id=100.0)
    JOIN (d
    WHERE m.route_id=d.entity1_id
     AND d.entity_reltn_mean="DRC/ROUTE")
   DETAIL
    route_obj_cnt = (route_obj_cnt+ 1), stat = alterlist(request->drc_obj_list[1].drc_obj.
     qualifier_list[x].qualifier.route_list,route_obj_cnt), request->drc_obj_list[1].drc_obj.
    qualifier_list[x].qualifier.route_list[route_obj_cnt].route.active_ind = 1,
    request->drc_obj_list[1].drc_obj.qualifier_list[x].qualifier.route_list[route_obj_cnt].route.
    route_cki = "", request->drc_obj_list[1].drc_obj.qualifier_list[x].qualifier.route_list[
    route_obj_cnt].route.route_id = 0.0, request->drc_obj_list[1].drc_obj.qualifier_list[x].qualifier
    .route_list[route_obj_cnt].route.route_disp = d.entity2_display
   WITH nocounter
  ;end select
 ENDFOR
 FOR (q = 1 TO drc_obj_cnt)
  SET dr_obj_cnt = 0
  SELECT DISTINCT INTO "nl:"
   m.dose_range_type_id
   FROM mltm_drc_premise m
   WHERE m.grouper_id=cnvtreal(request->drc_obj_list[1].drc_obj.grouper_id)
    AND (m.drc_identifier=request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.drc_identifier
   )
    AND m.updt_id=100.0
   DETAIL
    dr_obj_cnt = (dr_obj_cnt+ 1), stat = alterlist(request->drc_obj_list[1].drc_obj.qualifier_list[q]
     .qualifier.dose_range_list,dr_obj_cnt), request->drc_obj_list[1].drc_obj.qualifier_list[q].
    qualifier.dose_range_list[dr_obj_cnt].dose_range.active_ind = 1,
    request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].
    dose_range.comment = m.comment_txt, request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.
    dose_range_list[dr_obj_cnt].dose_range.dose_range_id = 0.0, request->drc_obj_list[1].drc_obj.
    qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.dose_range_type = m
    .dose_range_type,
    request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].
    dose_range.dose_unit = m.dose_unit_disp, request->drc_obj_list[1].drc_obj.qualifier_list[q].
    qualifier.dose_range_list[dr_obj_cnt].dose_range.dose_unit_cki = m.dose_unit_cki, request->
    drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.
    max_dose = m.max_dose_amt,
    request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].
    dose_range.max_dose_unit = m.max_dose_unit_disp, request->drc_obj_list[1].drc_obj.qualifier_list[
    q].qualifier.dose_range_list[dr_obj_cnt].dose_range.max_dose_unit_cki = m.max_dose_unit_cki,
    request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].
    dose_range.from_dose_amount = m.low_dose_value,
    request->drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].
    dose_range.from_variance_percent = 0, request->drc_obj_list[1].drc_obj.qualifier_list[q].
    qualifier.dose_range_list[dr_obj_cnt].dose_range.to_dose_amount = m.high_dose_value, request->
    drc_obj_list[1].drc_obj.qualifier_list[q].qualifier.dose_range_list[dr_obj_cnt].dose_range.
    to_variance_percent = 0
   WITH nocounter
  ;end select
 ENDFOR
 EXECUTE kia_import_drc_2
 IF ((readme_data->status="F"))
  CALL lexi_import_log(3,lexi_grpr_nm)
 ELSE
  CALL lexi_import_log(2,lexi_grpr_nm)
 ENDIF
 FREE RECORD request
#import_lexi_exit
#lexi_reports
 CALL clear_screen(0)
 CALL text(3,1,"                      Lexi-Comp REPORTS                                          ")
 CALL text(4,1,"                                                                                 ")
 CALL text(5,1,"01 Lexi-Comp GROUPER CONTENT SUCCESSFULLY LOADED                                 ")
 CALL text(6,1,"02 Lexi-Comp GROUPER CONTENT NOT LOADED BECAUSE OF PRE-EXISTING CUSTOM CONTENT   ")
 CALL text(7,1,"03 Lexi-Comp GROUPER CONTENT THAT FAILED DURING IMPORT                           ")
 CALL text(8,1,"04 Lexi-Comp PEDIATRIC DOSE RANGE CHECK GROUPER CONTENT                          ")
 CALL text(9,1,"                                                                                 ")
 CALL text(10,1,"99 EXIT                                                                          ")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",99
  WHERE curaccept IN (1, 2, 3, 4, 99))
 SET new_grp_active = 0
 CASE (curaccept)
  OF 1:
   CALL disp_lexi_rpt(1)
  OF 2:
   CALL disp_lexi_rpt(2)
  OF 3:
   CALL disp_lexi_rpt(3)
  OF 4:
   CALL disp_lexi_rpt(4)
  OF 99:
   GO TO pick_mode
 ENDCASE
 GO TO lexi_reports
#lexi_reports_exit
 SUBROUTINE disp_lexi_rpt(lexi_rpt_type)
   FREE SET lexi_tmp_id
   DECLARE lexi_tmp_id = f8 WITH public, noconstant(0.0)
   IF (lexi_rpt_type=4)
    CALL clear_screen(0)
    CALL text(3,3,"  PLEASE WAIT WHILE Lexi-Comp CONTENT IS ANALYZED...  ")
    EXECUTE kia_dm_dbimport "cer_install:lexicomp_drc_extract.csv", "kia_imp_mltm_drc_premise", 1000,
    0
    CALL echo("REMOVE ANY GROUPERS THAT ARE NOT ON DOSE_RANGE_CHECK_TABLE")
    DELETE  FROM mltm_drc_premise m
     WHERE  NOT ( EXISTS (
     (SELECT
      1
      FROM dose_range_check d
      WHERE d.dose_range_check_name=m.grouper_name)))
     WITH nocounter
    ;end delete
    CALL echo("REMOVE ANY CONDITION ROWS THAT DO NOT HAVE A MATCHING CONCEPT_CKI ON NOMENCLATURE")
    DELETE  FROM mltm_drc_premise m
     WHERE  NOT ( EXISTS (
     (SELECT
      1
      FROM nomenclature n
      WHERE m.condition_concept_cki=n.concept_cki)))
      AND  NOT (m.condition_concept_cki IN ("", " ", null))
     WITH nocounter
    ;end delete
    SELECT
     m.*
     FROM mltm_drc_premise m,
      code_value c
     PLAN (m
      WHERE ((m.drc_cki IN (
      (SELECT
       m2.drc_cki
       FROM mltm_drc_premise m2
       WHERE m2.age_low_nbr=18
        AND m2.age_operator_txt="<"
        AND m2.age_unit_disp="year(s)"))) OR (((m.drc_cki IN (
      (SELECT
       m2.drc_cki
       FROM mltm_drc_premise m2
       WHERE m2.age_low_nbr < 18))) OR (m.drc_cki IN (
      (SELECT
       m2.drc_cki
       FROM mltm_drc_premise m2
       WHERE m2.age_unit_disp != "year(s)")))) )) )
      JOIN (c
      WHERE c.cki=m.dose_unit_cki
       AND c.code_set=54)
     ORDER BY cnvtupper(m.grouper_name), m.route_disp, m.age_unit_disp,
      m.age_low_nbr, m.age_high_nbr, m.drc_identifier
     HEAD REPORT
      tmp_str = fillstring(255," ")
     HEAD m.grouper_name
      row + 1,
      CALL print(concat("GROUPER: ",substring(1,100,m.grouper_name)))
     HEAD m.route_disp
      row + 1, row + 1,
      CALL print(concat(" ROUTE: ",substring(1,100,m.route_disp))),
      row + 1, col 3, "AGE_OPERATOR",
      col 25, "AGE_LOW", col 35,
      "AGE_HIGH", col 45, "AGE_UNIT",
      col 65, "DOSE_RANGE_TYPE", col 85,
      "FROM", col 95, "TO",
      col 105, "DOSE_UNIT", col 125,
      "MAX_DOSE_AMT", col 140, "MAX_DOSE_UNIT",
      col 160, "WEIGHT_OPERATOR", col 180,
      "WEIGHT_LOW", col 195, "WEIGHT_HIGH",
      col 210, "WEIGHT_UNIT", col 230,
      "PMA_OPERATOR", col 250, "PMA_LOW",
      col 265, "PMA_HIGH", col 280,
      "PMA_UNIT", col 300, "CrCl_OPERATOR",
      col 320, "CrCl_LOW", col 335,
      "CrCl_HIGH", col 350, "CrCl_UNIT",
      col 370, "HEPATIC", col 380,
      "CONDITION_DESCRIPTION", col 430, "COMMENT_TEXT"
     DETAIL
      row + 1, tmp_str = trim(substring(1,20,trim(m.age_operator_txt))), col 3,
      tmp_str, tmp_str = trim(substring(1,8,trim(cnvtstring(m.age_low_nbr)))), col 25,
      tmp_str, tmp_str = trim(substring(1,8,trim(cnvtstring(m.age_high_nbr)))), col 35,
      tmp_str, tmp_str = trim(substring(1,18,trim(m.age_unit_disp))), col 45,
      tmp_str, tmp_str = trim(substring(1,18,trim(m.dose_range_type))), col 65,
      tmp_str, tmp_str = trim(substring(1,8,trim(cnvtstring(m.low_dose_value,11,2)))), col 85,
      tmp_str, tmp_str = trim(substring(1,8,trim(cnvtstring(m.high_dose_value,11,2)))), col 95,
      tmp_str, tmp_str = trim(substring(1,18,trim(c.display)))
      IF (tmp_str="A")
       col 105, "---"
      ELSE
       col 105, tmp_str
      ENDIF
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.max_dose_amt,11,2)))), col 125, tmp_str,
      tmp_str = trim(substring(1,18,m.max_dose_unit_disp)), col 140, tmp_str,
      tmp_str = trim(substring(1,18,trim(m.weight_operator_txt))), col 160, tmp_str,
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.weight_low_value,11,2)))), col 180, tmp_str,
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.weight_high_value,11,2)))), col 195, tmp_str,
      tmp_str = trim(substring(1,18,m.weight_unit_disp)), col 210, tmp_str,
      tmp_str = trim(substring(1,18,trim(m.corrected_gest_age_oper_txt))), col 230, tmp_str,
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.corrected_gest_age_low_nbr,11,2)))), col 250,
      tmp_str,
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.corrected_gest_age_high_nbr,11,2)))), col 265,
      tmp_str,
      tmp_str = trim(substring(1,18,m.corrected_gest_age_unit_disp)), col 280, tmp_str,
      tmp_str = trim(substring(1,18,trim(m.renal_operator_txt))), col 300, tmp_str,
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.renal_low_value,11,2)))), col 320, tmp_str,
      tmp_str = trim(substring(1,8,trim(cnvtstring(m.renal_high_value,11,2)))), col 335, tmp_str,
      tmp_str = trim(substring(1,18,m.renal_unit_disp)), col 350, tmp_str,
      tmp_str = cnvtupper(trim(substring(1,3,m.liver_desc)))
      IF (tmp_str="YES")
       col 370, "YES"
      ELSE
       col 370, "NO"
      ENDIF
      tmp_str = trim(substring(1,50,trim(m.condition1_desc))), col 380, tmp_str,
      tmp_str = trim(substring(1,255,m.comment_txt)), col 430, tmp_str
     FOOT  m.grouper_name
      row + 1, row + 1,
      CALL print("-------------------------------------------------------------------------"),
      row + 1
     WITH nocounter, maxcol = 700
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM cmt_import_log c
     WHERE c.input_filename="LEXICOMP_IMPORT"
     DETAIL
      lexi_tmp_id = c.cmt_import_log_id
     WITH nocounter
    ;end select
    IF (lexi_tmp_id > 0.0)
     DECLARE tmp_str = vc WITH public, noconstant("")
     DECLARE tmp_line = c100 WITH public, noconstant(fillstring(100,"-"))
     IF (lexi_rpt_type=1)
      SELECT
       c.*
       FROM cmt_import_log_msg c
       WHERE c.log_status_flag=2
        AND c.cmt_import_log_id=lexi_tmp_id
       ORDER BY cnvtupper(c.log_message)
       HEAD PAGE
        row + 1, col 1, "Lexi-Comp GROUPERS SUCCESSFULLY IMPORTED",
        row + 1, col 1, tmp_line,
        row + 1
       DETAIL
        row + 1, tmp_str = trim(substring(1,255,c.log_message)), col 1,
        tmp_str
       WITH nocounter
      ;end select
     ELSEIF (lexi_rpt_type=2)
      SELECT
       c.*
       FROM cmt_import_log_msg c
       WHERE c.log_status_flag=4
        AND c.cmt_import_log_id=lexi_tmp_id
       ORDER BY cnvtupper(c.log_message)
       HEAD PAGE
        row + 1, col 1, "Lexi-Comp GROUPERS NOT IMPORTED DUE TO PRE-EXISTING CUSTOMIZED CONTENT",
        row + 1, col 1, tmp_line,
        row + 1
       DETAIL
        row + 1, tmp_str = trim(substring(1,255,c.log_message)), col 1,
        tmp_str
       WITH nocounter
      ;end select
     ELSEIF (lexi_rpt_type=3)
      SELECT
       c.*
       FROM cmt_import_log_msg c
       WHERE c.log_status_flag=3
        AND c.cmt_import_log_id=lexi_tmp_id
       ORDER BY cnvtupper(c.log_message)
       HEAD PAGE
        row + 1, col 1, "Lexi-Comp GROUPERS FAILED DURING IMPORT",
        row + 1, col 1, tmp_line,
        row + 1
       DETAIL
        row + 1, tmp_str = trim(substring(1,255,c.log_message)), col 1,
        tmp_str
       WITH nocounter
      ;end select
     ENDIF
    ELSE
     CALL clear_screen(0)
     SET message = nowindow
     CALL echo("**************************************************")
     CALL echo("***  Lexi-Comp IMPORT HAS NOT BEEN STARTED YET ***")
     CALL echo("**************************************************")
     CALL pause(3)
     SET message = window
    ENDIF
   ENDIF
 END ;Subroutine
#view_log_mode
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,25,"         LOG VIEWER             ")
 CALL text(5,25,"LOGS                            ")
 CALL text(6,25," 01 View kia_import_drc_2.log    ")
 CALL text(7,25," 02 View drc_new_groupers.log   ")
 CALL text(8,25," 03 View drc_routes.log         ")
 CALL text(9,25," 09 Main menu                   ")
 CALL text(12,25,"Choose an option:")
 CALL accept(12,43,"99;",9
  WHERE curaccept IN (1, 2, 3, 9))
 CASE (curaccept)
  OF 1:
   CALL view_log("kia_import_drc_2.log")
  OF 2:
   CALL view_log("drc_new_groupers.log")
  OF 3:
   CALL view_log("drc_routes.log")
  OF 9:
   GO TO pick_mode
 ENDCASE
 GO TO view_log_mode
#view_log_mode_exit
#create_request_struct
 FREE RECORD request
 RECORD request(
   1 import_method_flag = i2
   1 domain_flag = i2
   1 drc_obj_list[*]
     2 drc_obj
       3 grouper_name = vc
       3 grouper_id = i4
       3 facility_flex_ind = i2
       3 facility_disp = vc
       3 qualifier_list[*]
         4 qualifier
           5 qualifier_id = i4
           5 age_operator = c12
           5 from_age = f8
           5 to_age = f8
           5 age_unit = vc
           5 age_unit_cki = vc
           5 pma_operator = c12
           5 from_pma = f8
           5 to_pma = f8
           5 pma_unit = vc
           5 pma_unit_cki = vc
           5 weight_operator = c12
           5 from_weight = f8
           5 to_weight = f8
           5 weight_unit = vc
           5 weight_unit_cki = vc
           5 renal_operator = c12
           5 from_renal = f8
           5 to_renal = f8
           5 renal_unit = vc
           5 renal_unit_cki = vc
           5 hepatic_dysfunction_ind = i2
           5 concept_cki = vc
           5 route_list[*]
             6 route
               7 route_id = i4
               7 route_disp = vc
               7 route_cki = vc
               7 active_ind = i2
           5 dose_range_list[*]
             6 dose_range
               7 dose_range_id = i4
               7 dose_range_type = vc
               7 from_dose_amount = f8
               7 to_dose_amount = f8
               7 dose_unit = vc
               7 dose_unit_cki = vc
               7 max_dose = f8
               7 max_dose_unit = vc
               7 max_dose_unit_cki = vc
               7 dose_days = i4
               7 active_ind = i2
               7 comment = vc
               7 from_variance_percent = f8
               7 to_variance_percent = f8
           5 active_ind = i2
           5 multum_case_id = i4
           5 route_group = vc
           5 drc_identifier = vc
       3 build_contributor = vc
       3 active_ind = i2
 )
#create_request_struct_exit
 SUBROUTINE show_processing2(x)
  CALL clear_screen(0)
  CALL text(23,1,concat("Processing group ",trim(cnvtstring(x)),"..."))
 END ;Subroutine
#exit_program
END GO

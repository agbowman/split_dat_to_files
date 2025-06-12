CREATE PROGRAM cs_54_utility:dba
 PAINT
 DECLARE kia_dm_info = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="Code Set Wizard"
   AND dm.info_name="WizTrigger"
  HEAD REPORT
   kia_dm_info = 0
  DETAIL
   kia_dm_info = (kia_dm_info+ 1)
  WITH nocounter
 ;end select
 IF (kia_dm_info > 0)
  CALL text(1,25,"This Utility has been replaced with the")
  CALL text(2,25,"Bedrock Code Set Management wizard per your current Administration release.")
  CALL text(3,25,"You can use this wizard to manage Code Set 54.")
  GO TO exit_script
 ENDIF
 CALL video("R")
 CALL clear(1,1,80)
 CALL text(1,25,"UNIT OF MEASURE (UOM) UTILITY")
 CALL video("N")
 RECORD temp(
   1 cnt = i2
   1 clist[*]
     2 disp = vc
     2 desc = vc
     2 cki = vc
     2 cdf = vc
     2 concept_cki = vc
     2 cv_disp = vc
     2 cv_cki = vc
     2 cv_cdf = vc
     2 cv_cv = f8
     2 cv_act_ind = i2
     2 mapped = i2
 )
 RECORD temp2(
   1 cnt = i2
   1 clist[*]
     2 disp = vc
     2 desc = vc
     2 cki = vc
     2 cdf = vc
     2 concept_cki = vc
     2 cv_disp = vc
     2 cv_cki = vc
     2 cv_cdf = vc
     2 cv_cv = f8
     2 cv_act_ind = i2
     2 mapped = i2
 )
 RECORD temp3(
   1 cnt = i2
   1 clist[*]
     2 disp = vc
     2 desc = vc
     2 cki = vc
     2 cdf = vc
     2 concept_cki = vc
     2 cv_disp = vc
     2 cv_cki = vc
     2 cv_cdf = vc
     2 cv_cv = f8
     2 cv_act_ind = i2
     2 mapped = i2
 )
 RECORD temp5(
   1 cnt = i2
   1 clist[*]
     2 disp = vc
     2 desc = vc
     2 cki = vc
     2 cdf = vc
     2 concept_cki = vc
     2 cv_disp = vc
     2 cv_cki = vc
     2 cv_cdf = vc
     2 cv_cv = f8
     2 cv_act_ind = i2
     2 mapped = i2
 )
 FREE RECORD request
 RECORD request(
   1 cd_value_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request2
 RECORD request2(
   1 cdf_mean_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 code_set = i4
     2 definition = vc
     2 display = vc
 )
 FREE RECORD reply2
 RECORD reply2(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE holdstr1 = c17
 DECLARE holdstr2 = c11
 DECLARE holdstr3 = c25
 DECLARE holdstr4 = c29
 DECLARE holdstr5 = c17
 DECLARE term_cnt = i4
 DECLARE first_time = i4
 SET first_time = 1
 SET confirm = " "
 SET commit_ind = 0
 DECLARE load_aliases(cont_src_mean=vc) = null
#pick_mode
 SET term_cnt = 0
 SELECT INTO "nl:"
  FROM cmt_code_value_load c
  WHERE c.code_set=54
  ORDER BY cnvtupper(c.display)
  DETAIL
   CALL add_term(c.display,c.description,c.cki,c.cdf_meaning,c.concept_cki)
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->clist,term_cnt)
 SET temp->cnt = term_cnt
 FOR (x = 1 TO temp->cnt)
   SET temp->clist[x].mapped = 0
   SET temp->clist[x].cv_cv = 0
   SET temp->clist[x].cv_cdf = " "
   SET temp->clist[x].cv_disp = " "
   SET temp->clist[x].cv_cki = " "
   SET temp->clist[x].cv_act_ind = 0
 ENDFOR
 IF (first_time=1)
  SELECT INTO "nl:"
   FROM common_data_foundation cdf,
    (dummyt d  WITH seq = term_cnt),
    dummyt d2
   PLAN (d)
    JOIN (d2)
    JOIN (cdf
    WHERE (cdf.cdf_meaning=temp->clist[d.seq].cdf)
     AND cdf.code_set=54)
   ORDER BY temp->clist[d.seq].disp
   HEAD REPORT
    cnt = 0
   DETAIL
    IF ((temp->clist[d.seq].cdf > " "))
     cnt = (cnt+ 1), stat = alterlist(request2->cdf_mean_list,cnt), request2->cdf_mean_list[cnt].
     display = temp->clist[d.seq].disp,
     request2->cdf_mean_list[cnt].cdf_meaning = temp->clist[d.seq].cdf, request2->cdf_mean_list[cnt].
     code_set = 54, request2->cdf_mean_list[cnt].definition = "",
     request2->cdf_mean_list[cnt].action_type_flag = 1
    ENDIF
   WITH nocounter, outerjoin = d2, dontexist
  ;end select
  IF (size(request2->cdf_mean_list,5) > 0)
   EXECUTE core_ens_cdf_meaning  WITH replace("REQUEST","REQUEST2"), replace("REPLY","REPLY2")
  ENDIF
  SET first_time = 0
 ENDIF
 CALL text(3,4,"PROGRAM OPTIONS ")
 CALL text(5,1,"01 View Cerner's master list of units of measure")
 CALL text(6,1,"02 See what CKI's are currently mapped, and unmap any incorrect items")
 CALL text(7,1,"03 See what CKI's are not mapped, and map or create new code set entries")
 CALL text(8,1,"04 See/resolve possible issue with duplicate 'units' entries")
 CALL text(9,1,"05 Map/unmap CDF meanings to code_set 54 entries")
 CALL text(10,1,"06 Load code value aliases")
 CALL text(11,1,"07 Exit program")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;S")
 SET select_option = cnvtint(curaccept)
 IF (select_option=7)
  GO TO exit_program
 ELSEIF (((select_option < 1) OR (select_option > 6)) )
  GO TO pick_mode
 ELSE
  CALL clear(3,1)
 ENDIF
#restart
 SET mapped_cnt = 0
 FOR (x = 1 TO temp->cnt)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=54
      AND (c.cki=temp->clist[x].cki))
    DETAIL
     temp->clist[x].cv_disp = c.display, temp->clist[x].cv_cv = c.code_value
     IF (c.cki = null)
      temp->clist[x].cv_cki = " "
     ELSE
      temp->clist[x].cv_cki = c.cki
     ENDIF
     IF (c.cdf_meaning = null)
      temp->clist[x].cv_cdf = " "
     ELSE
      temp->clist[x].cv_cdf = c.cdf_meaning
     ENDIF
     temp->clist[x].cv_act_ind = c.active_ind, temp->clist[x].mapped = 1, mapped_cnt = (mapped_cnt+ 1
     )
    WITH nocounter
   ;end select
 ENDFOR
 IF (select_option=1)
  GO TO view_only
 ELSEIF (select_option=2)
  GO TO audit_mode
 ELSEIF (select_option=3)
  GO TO not_mapped
 ELSEIF (select_option=4)
  GO TO unit_check
 ELSEIF (select_option=5)
  GO TO map_cdf
 ELSEIF (select_option=6)
  GO TO alias_load
 ELSE
  GO TO pick_mode
 ENDIF
#audit_mode
 SET ucnt = 0
 FOR (x = 1 TO temp->cnt)
   IF ((temp->clist[x].mapped=1))
    SET ucnt = (ucnt+ 1)
    SET stat = alterlist(temp2->clist,ucnt)
    SET temp2->clist[ucnt].disp = temp->clist[x].disp
    SET temp2->clist[ucnt].desc = temp->clist[x].desc
    SET temp2->clist[ucnt].cki = temp->clist[x].cki
    SET temp2->clist[ucnt].cdf = temp->clist[x].cdf
    SET temp2->clist[ucnt].cv_disp = temp->clist[x].cv_disp
    SET temp2->clist[ucnt].cv_cv = temp->clist[x].cv_cv
    SET temp2->clist[ucnt].cv_cdf = temp->clist[x].cv_cdf
    SET temp2->clist[ucnt].cv_act_ind = temp->clist[x].cv_act_ind
    SET temp2->clist[ucnt].mapped = 1
   ENDIF
 ENDFOR
 CALL text(3,2,"UOM'S currently mapped  (* = inactive)")
 CALL text(5,8,"Cerner Standard")
 CALL text(5,26,"Client CS 54")
 CALL text(5,44,"CKI")
 SET maxcnt = ucnt
 SET cnt = 1
 SET srowoff = 6
 SET scoloff = 2
 SET numsrow = 14
 SET numscol = 76
 SET holdstr = fillstring(75," ")
 SET holdstr1 = fillstring(17," ")
 SET holdstr5 = fillstring(17," ")
 SET holdstr3 = fillstring(25," ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr1 = trim(temp2->clist[cnt].disp)
   SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
   SET holdstr3 = trim(temp2->clist[cnt].cki)
   IF ((temp2->clist[cnt].cv_act_ind=0))
    SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
     " ",holdstr3)
   ELSE
    SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
     " ",holdstr3)
   ENDIF
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
#audit_repeat
 CALL text(23,1,"Select a UOM to undo mapping     (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear(3,1)
     GO TO pick_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear(3,1)
     CALL text(5,1,concat("Unmap ",trim(temp2->clist[pick].cv_disp)," ","from ",trim(temp2->clist[
        pick].disp)))
    ELSE
     CALL clear(3,1)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     IF (arow=numsrow)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      IF ((temp2->clist[cnt].cv_act_ind=0))
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
        " ",holdstr3)
      ELSE
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
        " ",holdstr3)
      ENDIF
      CALL scrolldown(arow,arow,holdstr)
     ELSE
      SET arow = (arow+ 1)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      IF ((temp2->clist[cnt].cv_act_ind=0))
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
        " ",holdstr3)
      ELSE
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
        " ",holdstr3)
      ENDIF
      CALL scrolldown((arow - 1),arow,holdstr)
     ENDIF
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     IF (arow=1)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      IF ((temp2->clist[cnt].cv_act_ind=0))
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
        " ",holdstr3)
      ELSE
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
        " ",holdstr3)
      ENDIF
      CALL scrollup(arow,arow,holdstr)
     ELSE
      SET arow = (arow - 1)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      IF ((temp2->clist[cnt].cv_act_ind=0))
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
        " ",holdstr3)
      ELSE
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
        " ",holdstr3)
      ENDIF
      CALL scrollup((arow+ 1),arow,holdstr)
     ENDIF
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
       SET holdstr1 = trim(temp2->clist[cnt].disp)
       SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
       SET holdstr3 = trim(temp2->clist[cnt].cki)
       IF ((temp2->clist[cnt].cv_act_ind=0))
        SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
         " ",holdstr3)
       ELSE
        SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
         " ",holdstr3)
       ENDIF
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    SET cnt = 1
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr5 = trim(temp2->clist[cnt].cv_disp)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      IF ((temp2->clist[cnt].cv_act_ind=0))
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1,"*",holdstr5,
        " ",holdstr3)
      ELSE
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr5,
        " ",holdstr3)
      ENDIF
      CALL scrolltext(cnt,holdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
  ENDCASE
 ENDWHILE
#unmap_yn
 CALL text(23,1,"Continue unmapping? (Y/N/Q)   ")
 CALL accept(23,29,"C;CU")
 SET confirm = curaccept
 IF (((confirm="q") OR (confirm="Q")) )
  CALL clear(3,1)
  GO TO pick_mode
 ELSEIF (((confirm="N") OR (confirm="n")) )
  CALL clear(3,1)
  GO TO audit_mode
 ELSEIF (((confirm="Y") OR (confirm="y")) )
  CALL cd_val_update("","code_value",temp2->clist[pick].cv_cv,
   "Error updating, unable to unmap. Continue? (Y/N)",
   "Unmapping completed w/o errors. Continue? (Y/N) ")
  CALL accept(23,50,"C;CU")
  SET confirm = curaccept
  CALL clear(3,1)
  IF (((confirm="Y") OR (confirm="y")) )
   FOR (x = 1 TO temp->cnt)
     SET temp->clist[x].mapped = 0
     SET temp->clist[x].cv_cki = " "
     SET temp->clist[x].cv_disp = " "
     SET temp->clist[x].cv_cv = 0
   ENDFOR
   GO TO restart
  ELSE
   GO TO pick_mode
  ENDIF
 ELSE
  GO TO unmap_yn
 ENDIF
 GO TO pick_mode
#map_cdf_choice
 CALL text(3,6,concat("UOM being mapped to: ",temp5->clist[pick].disp))
 FREE RECORD temp6
 RECORD temp6(
   1 cnt = i2
   1 clist[*]
     2 disp = vc
     2 cdf = vc
     2 mapped = i2
 )
 SET jcnt = 0
 SELECT INTO "NL:"
  FROM common_data_foundation cdf
  WHERE cdf.code_set=54
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM code_value c
   WHERE c.cdf_meaning=cdf.cdf_meaning
    AND c.code_set=54)))
  ORDER BY cdf.cdf_meaning
  HEAD REPORT
   jcnt = 0
  DETAIL
   jcnt = (jcnt+ 1), stat = alterlist(temp6->clist,jcnt), temp6->clist[jcnt].disp = cdf.display,
   temp6->clist[jcnt].mapped = 1, temp6->clist[jcnt].cdf = cdf.cdf_meaning
  FOOT REPORT
   temp6->cnt = jcnt
  WITH nocounter
 ;end select
 CALL text(5,12,"CDF_MEANING")
 SET maxcnt = temp6->cnt
 SET cnt = 1
 SET srowoff = 6
 SET scoloff = 6
 SET numsrow = 14
 SET numscol = 68
 SET holdstr = fillstring(75," ")
 SET holdstr1 = fillstring(17," ")
 SET holdstr2 = fillstring(11," ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr1 = trim(temp6->clist[cnt].cdf)
   SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
#map_cdf_choice_repeat
 CALL text(23,1,"Select a CDF to map (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,45,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear(3,1)
     GO TO map_cdf
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear(3,1)
     SET map = "Y"
     CALL text(4,6,concat("UOM being mapped to: ",temp5->clist[pick].disp))
     CALL cd_val_update_cdf(cdf_map_cv,temp6->clist[pick].cdf)
     CALL clear(3,5,75)
     CALL clear(4,5,75)
     GO TO map_cdf
    ELSE
     CALL clear(3,1)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     IF (arow=numsrow)
      SET holdstr1 = trim(temp6->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
      CALL scrolldown(arow,arow,holdstr)
     ELSE
      SET arow = (arow+ 1)
      SET holdstr1 = trim(temp6->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
      CALL scrolldown((arow - 1),arow,holdstr)
     ENDIF
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     IF (arow=1)
      SET holdstr1 = trim(temp6->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
      CALL scrollup(arow,arow,holdstr)
     ELSE
      SET arow = (arow - 1)
      SET holdstr1 = trim(temp6->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
      CALL scrollup((arow+ 1),arow,holdstr)
     ENDIF
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
       SET holdstr1 = trim(temp6->clist[cnt].cdf)
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    SET cnt = 1
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      SET holdstr1 = trim(temp6->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1)
      CALL scrolltext(cnt,holdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear(3,1)
#map_cdf_choice_exit
#not_mapped
 SET ucnt = 0
 FOR (x = 1 TO temp->cnt)
   IF ((temp->clist[x].mapped != 1))
    SET ucnt = (ucnt+ 1)
    SET stat = alterlist(temp2->clist,ucnt)
    SET temp2->clist[ucnt].disp = temp->clist[x].disp
    SET temp2->clist[ucnt].cki = temp->clist[x].cki
    SET temp2->clist[ucnt].cdf = temp->clist[x].cdf
    SET temp2->clist[ucnt].desc = temp->clist[x].desc
    SET temp2->clist[ucnt].mapped = 0
   ENDIF
 ENDFOR
#unmapped_master
 CALL text(5,2,"Cerner Standard items not found on client code set 54")
 SET maxcnt = ucnt
 SET cnt = 1
 SET srowoff = 6
 SET scoloff = 2
 SET numsrow = 14
 SET numscol = 32
 SET uholdstr = fillstring(31," ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
   CALL scrolltext(cnt,uholdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
#repeat
 CALL text(23,1,"Select a UOM from the master list      (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,35,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear(3,1)
     GO TO pick_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear(3,1)
     CALL text(3,1,concat("UOM being mapped to: ",temp2->clist[pick].disp," (",temp2->clist[pick].cki,
       ")"))
    ELSE
     CALL clear(3,1)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     IF (arow=numsrow)
      SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
      CALL scrolldown(arow,arow,uholdstr)
     ELSE
      SET arow = (arow+ 1)
      SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
      CALL scrolldown((arow - 1),arow,uholdstr)
     ENDIF
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     IF (arow=1)
      SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
      CALL scrollup(arow,arow,uholdstr)
     ELSE
      SET arow = (arow - 1)
      SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
      CALL scrollup((arow+ 1),arow,uholdstr)
     ENDIF
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
       SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
       CALL scrolltext(arow,uholdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    SET cnt = 1
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      SET uholdstr = concat(cnvtstring(cnt,3,0,r)," ",trim(temp2->clist[cnt].disp))
      CALL scrolltext(cnt,uholdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
  ENDCASE
 ENDWHILE
 SET cnt1 = 0
 SELECT INTO "nl:"
  FROM code_value c,
   (dummyt d1  WITH seq = 1),
   (dummyt d  WITH seq = temp->cnt)
  PLAN (c
   WHERE c.code_set=54)
   JOIN (d1)
   JOIN (d
   WHERE (c.cki=temp->clist[d.seq].cki))
  ORDER BY c.display_key
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1), stat = alterlist(temp3->clist,cnt1), temp3->clist[cnt1].cv_disp = c.display,
   temp3->clist[cnt1].cv_cv = c.code_value, temp3->clist[cnt1].cv_cki = c.cki, temp3->clist[cnt1].
   cv_cdf = c.cdf_meaning,
   temp3->clist[cnt1].cv_act_ind = c.active_ind
  WITH nocounter, outerjoin = d1, dontexist
 ;end select
#unmapped_codeset
 CALL text(5,2,"Client code set 54 entries not currently mapped (* = inactive)")
 SET maxcnt = cnt1
 SET cnt = 1
 SET srowoff = 6
 SET scoloff = 2
 SET numsrow = 14
 SET numscol = 32
 SET uholdstr = fillstring(31," ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   IF ((temp3->clist[cnt].cv_act_ind=0))
    SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
   ELSE
    SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
   ENDIF
   CALL scrolltext(cnt,uholdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
#repeat2
 CALL text(23,1,"Select a code set 54 entry, enter 999 to create new or 000 to go back")
 SET pick1 = 0
 WHILE (pick1=0)
  CALL accept(23,71,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear(3,1)
     GO TO unmapped_master
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick1 = cnvtint(curaccept)
     CALL clear(4,1)
     IF ((temp3->clist[pick1].cv_cki > " "))
      CALL text(04,01,concat("Unmapped entry selected from code set 54: ",temp3->clist[pick1].cv_disp,
        " (",temp3->clist[pick1].cv_cki,")"))
     ELSE
      CALL text(04,01,concat("Unmapped entry selected from code set 54: ",temp3->clist[pick1].cv_disp,
        " (","- no cki -",")"))
     ENDIF
    ELSEIF (cnvtint(curaccept)=999)
     SET pick1 = cnvtint(curaccept)
     CALL clear(4,1)
     CALL text(4,1,"Adding a new entry to code set 54")
    ELSE
     CALL clear(3,1)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     IF (arow=numsrow)
      IF ((temp3->clist[cnt].cv_act_ind=0))
       SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
      ELSE
       SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
      ENDIF
      CALL scrolldown(arow,arow,uholdstr)
     ELSE
      SET arow = (arow+ 1)
      IF ((temp3->clist[cnt].cv_act_ind=0))
       SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
      ELSE
       SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
      ENDIF
      CALL scrolldown((arow - 1),arow,uholdstr)
     ENDIF
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     IF (arow=1)
      IF ((temp3->clist[cnt].cv_act_ind=0))
       SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
      ELSE
       SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
      ENDIF
      CALL scrollup(arow,arow,uholdstr)
     ELSE
      SET arow = (arow - 1)
      IF ((temp3->clist[cnt].cv_act_ind=0))
       SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
      ELSE
       SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
      ENDIF
      CALL scrollup((arow+ 1),arow,uholdstr)
     ENDIF
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
       IF ((temp3->clist[cnt].cv_act_ind=0))
        SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
       ELSE
        SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
       ENDIF
       CALL scrolltext(arow,uholdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    SET cnt = 1
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      IF ((temp3->clist[cnt].cv_act_ind=0))
       SET uholdstr = concat(cnvtstring(cnt,3,0,r)," *",trim(temp3->clist[cnt].cv_disp))
      ELSE
       SET uholdstr = concat(cnvtstring(cnt,3,0,r),"  ",trim(temp3->clist[cnt].cv_disp))
      ENDIF
      CALL scrolltext(cnt,uholdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
  ENDCASE
 ENDWHILE
#map_yn
 IF (pick1=999)
  CALL text(23,1,"Create new entry as (A)ctive or (I)nactive? (A/I/Q)     (Enter Q to quit)")
  CALL accept(23,53,"C;CU")
 ELSE
  CALL text(23,1,"Continue mapping? (Y/N/Q)   ")
  CALL accept(23,27,"C;CU")
 ENDIF
 SET confirm = curaccept
 IF (((confirm="q") OR (confirm="Q")) )
  CALL clear(3,1)
  GO TO pick_mode
 ELSEIF (((confirm="N") OR (confirm="n")) )
  CALL clear(3,1)
  GO TO unmapped_master
 ELSEIF (((confirm="Y") OR (confirm="y")) )
  CALL cd_val_update("","cki",temp2->clist[pick].cki,"","")
  CALL cd_val_update(temp2->clist[pick].cki,"code_value",temp3->clist[pick1].cv_cv,
   "Error updating, unable to map. Continue? (Y/N)","Mapping completed w/o errors. Continue? (Y/N) ")
  CALL accept(23,48,"C;CU")
  SET confirm = curaccept
  CALL clear(3,1)
  IF (((confirm="Y") OR (confirm="y")) )
   FOR (x = 1 TO temp->cnt)
     SET temp->clist[x].mapped = 0
     SET temp->clist[x].cv_cki = " "
     SET temp->clist[x].cv_disp = " "
     SET temp->clist[x].cv_cv = 0
   ENDFOR
   GO TO restart
  ELSE
   GO TO pick_mode
  ENDIF
 ELSEIF (((confirm="A") OR (((confirm="a") OR (((confirm="I") OR (confirm="i")) )) )) )
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=54
     AND (c.display=temp2->clist[pick].disp))
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET trace = recpersist
   SET stat = alterlist(request->cd_value_list,1)
   SET request->cd_value_list[1].action_type_flag = 1
   IF ((temp2->clist[pick].cdf > " "))
    SET request->cd_value_list[1].cdf_meaning = temp2->clist[pick].cdf
   ELSE
    SET request->cd_value_list[1].cdf_meaning = null
   ENDIF
   SET request->cd_value_list[1].cki = temp2->clist[pick].cki
   SET request->cd_value_list[1].code_set = 54
   SET request->cd_value_list[1].code_value = 0.0
   SET request->cd_value_list[1].collation_seq = 0
   SET request->cd_value_list[1].concept_cki = " "
   SET request->cd_value_list[1].definition = temp2->clist[pick].desc
   SET request->cd_value_list[1].description = temp2->clist[pick].desc
   SET request->cd_value_list[1].display = temp2->clist[pick].disp
   SET request->cd_value_list[1].begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->cd_value_list[1].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
   IF (((confirm="A") OR (confirm="a")) )
    SET request->cd_value_list[1].active_ind = 1
   ELSE
    SET request->cd_value_list[1].active_ind = 0
   ENDIF
   SET request->cd_value_list[1].display_key = trim(cnvtupper(cnvtalphanum(temp2->clist[pick].disp)))
   EXECUTE core_ens_cd_value  WITH replace("request","REQUEST"), replace("reply","REPLY")
   CALL clear(3,1)
   IF ((reply->status_data.status != "S"))
    CALL text(23,1,"Error occured, unable to add. Continue? (Y/N)")
   ELSE
    IF ((temp2->clist[pick].cdf > " "))
     SELECT INTO "nl:"
      FROM common_data_foundation cdf
      PLAN (cdf
       WHERE cdf.code_set=54
        AND (cdf.cdf_meaning=temp2->clist[pick].cdf))
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM common_data_foundation cdf
       SET cdf.code_set = 54, cdf.cdf_meaning = temp2->clist[pick].cdf, cdf.display = temp2->clist[
        pick].disp,
        cdf.definition = temp2->clist[pick].desc, cdf.updt_applctx = 0, cdf.updt_cnt = 0,
        cdf.updt_task = 0, cdf.updt_id = 0, cdf.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    DECLARE insert_code_value = f8 WITH public, noconstant(0.0)
    DECLARE insert_uuid = vc WITH public, noconstant("")
    SELECT INTO "nl:"
     FROM code_value cv,
      cmt_code_value_load ccvl
     PLAN (cv
      WHERE (cv.cki=temp2->clist[pick].cki)
       AND cv.code_set=54)
      JOIN (ccvl
      WHERE cv.cki=ccvl.cki)
     DETAIL
      insert_code_value = cv.code_value, insert_uuid = ccvl.code_value_uuid
     WITH nocounter
    ;end select
    INSERT  FROM code_value_alias cva
     (cva.alias, cva.alias_type_meaning, cva.code_set,
     cva.code_value, cva.contributor_source_cd, cva.primary_ind)(SELECT
      ccval.alias, ccval.alias_type_meaning, ccval.code_set,
      insert_code_value, contributor_source_cd =
      (SELECT
       c.code_value
       FROM code_value c
       WHERE c.code_set=73
        AND c.cdf_meaning=ccval.contributor_source_mean), ccval.primary_ind
      FROM cmt_code_value_alias_load ccval
      WHERE ccval.code_value_uuid=insert_uuid
       AND ccval.code_set=54
       AND  EXISTS (
      (SELECT
       c.code_value
       FROM code_value c
       WHERE c.code_set=73
        AND c.cdf_meaning=ccval.contributor_source_mean))
       AND  NOT ( EXISTS (
      (SELECT
       cva2.alias
       FROM code_value_alias cva2
       WHERE cva2.alias=ccval.alias
        AND cva2.code_set=ccval.code_set
        AND (cva2.contributor_source_cd=
       (SELECT
        c.code_value
        FROM code_value c
        WHERE c.code_set=73
         AND c.cdf_meaning=ccval.contributor_source_mean))))))
    ;end insert
    INSERT  FROM code_value_outbound cvo
     (cvo.alias, cvo.alias_type_meaning, cvo.code_set,
     cvo.code_value, cvo.contributor_source_cd)(SELECT
      ccvol.alias, ccvol.alias_type_meaning, ccvol.code_set,
      insert_code_value, contributor_source_cd =
      (SELECT
       c.code_value
       FROM code_value c
       WHERE c.code_set=73
        AND c.cdf_meaning=ccvol.contributor_source_mean)
      FROM cmt_code_value_outbnd_load ccvol
      WHERE ccvol.code_value_uuid=insert_uuid
       AND ccvol.code_set=54
       AND  EXISTS (
      (SELECT
       c.code_value
       FROM code_value c
       WHERE c.code_set=73
        AND c.cdf_meaning=ccvol.contributor_source_mean))
       AND  NOT ( EXISTS (
      (SELECT
       cvo2.alias
       FROM code_value_outbound cvo2
       WHERE cvo2.code_value=insert_code_value
        AND (cvo2.contributor_source_cd=
       (SELECT
        c.code_value
        FROM code_value c
        WHERE c.code_set=73
         AND c.cdf_meaning=ccvol.contributor_source_mean))))))
    ;end insert
    SET commit_ind = 1
    CALL text(23,1,"New entry successfully added. Continue? (Y/N)")
   ENDIF
   SET trace = norecpersist
   CALL accept(23,47,"C;CU")
   SET confirm = curaccept
   CALL clear(3,1)
   IF (((confirm="Y") OR (confirm="y")) )
    FOR (x = 1 TO temp->cnt)
      SET temp->clist[x].mapped = 0
      SET temp->clist[x].cv_cki = " "
      SET temp->clist[x].cv_disp = " "
      SET temp->clist[x].cv_cv = 0
    ENDFOR
    GO TO restart
   ELSE
    GO TO pick_mode
   ENDIF
  ELSE
   CALL clear(23,1)
   CALL text(23,1,"Duplicate display found, unable to add. Continue? (Y/N)")
   CALL accept(23,57,"C;CU")
   SET confirm = curaccept
   CALL clear(3,1)
   IF (((confirm="Y") OR (confirm="y")) )
    FOR (x = 1 TO temp->cnt)
      SET temp->clist[x].mapped = 0
      SET temp->clist[x].cv_cki = " "
      SET temp->clist[x].cv_disp = " "
      SET temp->clist[x].cv_cv = 0
    ENDFOR
    GO TO restart
   ELSE
    GO TO pick_mode
   ENDIF
  ENDIF
 ELSE
  GO TO map_yn
 ENDIF
#unit_check
 CALL text(4,1,"Searching for UNIT code values...")
 SET good_unit_cv = 0.0
 SET bad_unit_cv = 0.0
 SET good_unit_active_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.cki="CKI.CODEVALUE!7094")
  DETAIL
   good_unit_cv = cv.code_value, good_unit_active_ind = cv.active_ind
  WITH nocounter
 ;end select
 IF (good_unit_cv > 0)
  IF (good_unit_active_ind=1)
   CALL text(5,4,concat("Good units code value: ",cnvtstring(good_unit_cv)))
  ELSE
   CALL text(5,4,concat("Good units code value: ",cnvtstring(good_unit_cv),
     " (Warning: code value is not active.)"))
  ENDIF
 ELSE
  CALL text(5,4,"Unable to find 'unit(s)' code value for CKI.CODEVALUE!7094")
  CALL text(23,1,"Please use option 2 of this tool to map or add 'unit(s)' to codeset 54.")
  CALL accept(23,75,"C;CU","Q")
  CALL clear(3,1)
  GO TO pick_mode
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.cki="CKI.CODEVALUE!464241")
  DETAIL
   bad_unit_cv = cv.code_value
  WITH nocounter
 ;end select
 IF (bad_unit_cv > 0)
  CALL text(6,4,concat("Duplicate units code value: ",cnvtstring(bad_unit_cv)))
 ELSE
  CALL text(6,4,"Duplicate 'unit(s)' code value not found using CKI.CODEVALUE!464241")
  IF (good_unit_active_ind=1)
   CALL text(23,1,"No need for further checks, press return to continue.")
  ELSE
   CALL text(23,1,concat("No need for further checks, press return to ",
     "continue. (See warning above)"))
  ENDIF
  CALL accept(23,75,"C;CU","Q")
  CALL clear(3,1)
  GO TO pick_mode
 ENDIF
 CALL text(7,1,"Scanning the medication_definition table...")
 SET g_cnt = 0
 SET b_cnt = 0
 SELECT INTO "nl:"
  FROM medication_definition md
  HEAD REPORT
   g_cnt = 0, b_cnt = 0
  DETAIL
   IF (md.strength_unit_cd=good_unit_cv)
    g_cnt = (g_cnt+ 1)
   ENDIF
   IF (md.volume_unit_cd=good_unit_cv)
    g_cnt = (g_cnt+ 1)
   ENDIF
   IF (md.strength_unit_cd=bad_unit_cv)
    b_cnt = (b_cnt+ 1)
   ENDIF
   IF (md.volume_unit_cd=bad_unit_cv)
    b_cnt = (b_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 CALL text(8,4,concat("Number of instances good code value used: ",cnvtstring(g_cnt)))
 CALL text(9,4,concat("Number of instances duplicate code value used: ",cnvtstring(b_cnt)))
 IF (b_cnt=0)
  CALL text(23,1,"No 'unit(s)' issues found, press return to continue.")
  CALL accept(23,75,"C;CU","Q")
  CALL clear(3,1)
  GO TO pick_mode
 ENDIF
 IF (g_cnt=0)
  CALL text(23,1,"Need to resolve duplicate 'unit(s)' code values, continue? (Y/N)")
  CALL accept(23,66,"C;CU","Y")
  SET confirm = curaccept
  IF (((confirm="Y") OR (confirm="y")) )
   CALL cd_val_update("","code_value",good_unit_cv,"","")
   CALL cd_val_update("CKI.CODEVALUE!7094","code_value",bad_unit_cv,
    "Error updating, not resolved.  Continue? (Y/N)",
    "Duplicate resolved w/o errors. Continue? (Y/N) ")
   CALL accept(23,48,"C;CU")
   SET confirm = curaccept
   CALL clear(3,1)
   IF (((confirm="Y") OR (confirm="y")) )
    FOR (x = 1 TO temp->cnt)
      SET temp->clist[x].mapped = 0
      SET temp->clist[x].cv_cki = " "
      SET temp->clist[x].cv_disp = " "
      SET temp->clist[x].cv_cv = 0
    ENDFOR
    GO TO pick_mode
   ELSE
    GO TO pick_mode
   ENDIF
  ELSE
   CALL clear(3,1)
   GO TO pick_mode
  ENDIF
 ELSE
  CALL text(23,1,"Both code values used, unable to resolve using this utility.")
  CALL accept(23,77,"C;CU","Q")
  CALL clear(3,1)
  GO TO pick_mode
 ENDIF
#map_cdf
 FREE RECORD temp5
 RECORD temp5(
   1 cnt = i2
   1 clist[*]
     2 disp = vc
     2 cv_cv = f8
     2 cdf = vc
     2 mapped = i2
 )
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=54
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(temp5->clist,icnt), temp5->clist[icnt].disp = cv.display,
   temp5->clist[icnt].cv_cv = cv.code_value, null_check = nullcheck("FALSE","TRUE ",nullind(cv
     .cdf_meaning))
   IF (((cv.cdf_meaning IN ("", " ", null)) OR (null_check="TRUE")) )
    temp5->clist[icnt].mapped = 0, temp5->clist[icnt].cdf = "-"
   ELSE
    temp5->clist[icnt].mapped = 1, temp5->clist[icnt].cdf = cv.cdf_meaning
   ENDIF
  FOOT REPORT
   temp5->cnt = icnt
  WITH nocounter
 ;end select
 DECLARE cdf_map_cv = f8
 SET cdf_map_cv = 0
 CALL text(3,7,"Units of measure with mapped CDF meanings")
 CALL text(5,12,"Cerner Display")
 CALL text(5,30,"CDF Meaning")
 SET maxcnt = temp5->cnt
 SET cnt = 1
 SET srowoff = 6
 SET scoloff = 6
 SET numsrow = 14
 SET numscol = 68
 SET holdstr = fillstring(75," ")
 SET holdstr1 = fillstring(17," ")
 SET holdstr2 = fillstring(11," ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr1 = trim(temp5->clist[cnt].disp)
   SET holdstr2 = trim(temp5->clist[cnt].cdf)
   SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
#map_cdf_repeat
 CALL text(23,1,"Select a UOM to map/unmap to CDF     (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear(3,1)
     GO TO pick_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear(3,1)
     SET map = "Y"
     IF ((temp5->clist[pick].mapped=1))
      CALL text(3,1,concat("Item selected: ",temp5->clist[pick].disp))
      CALL text(5,1,"Would you like to (R)emap or (U)nmap selection? (R/U/Q) (Enter Q to quit)")
      CALL accept(5,75,"C;CU")
      SET map = curaccept
      CALL clear(3,1,100)
      CALL clear(5,1,100)
      IF (((map="R") OR (map="r")) )
       SET map = "Y"
      ELSEIF (((map="U") OR (map="u")) )
       CALL text(3,5,concat("Item selected: ",temp5->clist[pick].disp))
       CALL text(4,5,"Unmapping can have adverse effects on existing orders and funcionality.")
       CALL text(5,5,"Do you want to continue? (Y/N)")
       CALL accept(5,37,"C;CU")
       SET map = curaccept
       IF (((map="Y") OR (map="y")) )
        SET map = "U"
       ELSE
        CALL clear(3,5,75)
        CALL clear(4,5,40)
        GO TO map_cdf
       ENDIF
      ELSE
       CALL clear(3,5,75)
       CALL clear(4,5,40)
       GO TO map_cdf
      ENDIF
     ENDIF
     IF (((map="Y") OR (map="y")) )
      SET cdf_map_cv = temp5->clist[pick].cv_cv
      EXECUTE FROM map_cdf_choice TO map_cdf_choice_exit
     ELSEIF (((map="U") OR (map="u")) )
      CALL cd_val_update_cdf(temp5->clist[pick].cv_cv,"")
     ELSE
      CALL clear(3,5,75)
      CALL clear(4,5,40)
      GO TO map_cdf
     ENDIF
    ELSE
     CALL clear(3,1)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     IF (arow=numsrow)
      SET holdstr1 = trim(temp5->clist[cnt].disp)
      SET holdstr2 = trim(temp5->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
      CALL scrolldown(arow,arow,holdstr)
     ELSE
      SET arow = (arow+ 1)
      SET holdstr1 = trim(temp5->clist[cnt].disp)
      SET holdstr2 = trim(temp5->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
      CALL scrolldown((arow - 1),arow,holdstr)
     ENDIF
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     IF (arow=1)
      SET holdstr1 = trim(temp5->clist[cnt].disp)
      SET holdstr2 = trim(temp5->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
      CALL scrollup(arow,arow,holdstr)
     ELSE
      SET arow = (arow - 1)
      SET holdstr1 = trim(temp5->clist[cnt].disp)
      SET holdstr2 = trim(temp5->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
      CALL scrollup((arow+ 1),arow,holdstr)
     ENDIF
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
       SET holdstr1 = trim(temp5->clist[cnt].disp)
       SET holdstr2 = trim(temp5->clist[cnt].cdf)
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    SET cnt = 1
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      SET holdstr1 = trim(temp5->clist[cnt].disp)
      SET holdstr2 = trim(temp5->clist[cnt].cdf)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2)
      CALL scrolltext(cnt,holdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear(3,1)
 GO TO map_cdf
#view_only
 SET ucnt = 0
 FOR (x = 1 TO temp->cnt)
   SET ucnt = (ucnt+ 1)
   SET stat = alterlist(temp2->clist,ucnt)
   SET temp2->clist[ucnt].disp = temp->clist[x].disp
   SET temp2->clist[ucnt].desc = temp->clist[x].desc
   SET temp2->clist[ucnt].cki = substring(15,7,temp->clist[x].cki)
   IF ((((temp->clist[x].cdf="")) OR ((temp->clist[x].cdf=" "))) )
    SET temp2->clist[ucnt].cdf = "-"
   ELSE
    SET temp2->clist[ucnt].cdf = temp->clist[x].cdf
   ENDIF
   SET temp2->clist[ucnt].cv_disp = temp->clist[x].cv_disp
   SET temp2->clist[ucnt].cv_cv = temp->clist[x].cv_cv
   SET temp2->clist[ucnt].cv_cdf = temp->clist[x].cv_cdf
   SET temp2->clist[ucnt].mapped = 1
 ENDFOR
 CALL text(3,2,"Cerner's Master list of units of measure")
 CALL text(5,8,"Cerner Display")
 CALL text(5,26,"CDF Meaning")
 CALL text(5,38,"CKI(#)")
 CALL text(5,46,"Description")
 SET maxcnt = ucnt
 SET cnt = 1
 SET srowoff = 6
 SET scoloff = 2
 SET numsrow = 14
 SET numscol = 76
 SET holdstr = fillstring(75," ")
 SET holdstr1 = fillstring(17," ")
 SET holdstr2 = fillstring(11," ")
 SET holdstr3 = fillstring(25," ")
 SET holdstr4 = fillstring(29," ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr1 = trim(temp2->clist[cnt].disp)
   SET holdstr2 = trim(temp2->clist[cnt].cdf)
   SET holdstr3 = trim(temp2->clist[cnt].cki)
   SET holdstr4 = trim(temp2->clist[cnt].desc)
   SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
    " ",substring(1,7,holdstr3)," ",holdstr4)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
#view_only_repeat
 CALL text(23,1,"Use up & down arrows, page up/down to view list, enter 000 to go back.")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,77,"999;S",000)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear(3,1)
     GO TO pick_mode
    ELSE
     CALL clear(3,1)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     IF (arow=numsrow)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr2 = trim(temp2->clist[cnt].cdf)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      SET holdstr4 = trim(temp2->clist[cnt].desc)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
       " ",substring(1,7,holdstr3)," ",holdstr4)
      CALL scrolldown(arow,arow,holdstr)
     ELSE
      SET arow = (arow+ 1)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr2 = trim(temp2->clist[cnt].cdf)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      SET holdstr4 = trim(temp2->clist[cnt].desc)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
       " ",substring(1,7,holdstr3)," ",holdstr4)
      CALL scrolldown((arow - 1),arow,holdstr)
     ENDIF
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     IF (arow=1)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr2 = trim(temp2->clist[cnt].cdf)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      SET holdstr4 = trim(temp2->clist[cnt].desc)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
       " ",substring(1,7,holdstr3)," ",holdstr4)
      CALL scrollup(arow,arow,holdstr)
     ELSE
      SET arow = (arow - 1)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr2 = trim(temp2->clist[cnt].cdf)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      SET holdstr4 = trim(temp2->clist[cnt].desc)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
       " ",substring(1,7,holdstr3)," ",holdstr4)
      CALL scrollup((arow+ 1),arow,holdstr)
     ENDIF
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
       SET holdstr1 = trim(temp2->clist[cnt].disp)
       SET holdstr2 = trim(temp2->clist[cnt].cdf)
       SET holdstr3 = trim(temp2->clist[cnt].cki)
       SET holdstr4 = trim(temp2->clist[cnt].desc)
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
        " ",substring(1,7,holdstr3)," ",holdstr4)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    SET cnt = 1
    WHILE (cnt <= numsrow
     AND cnt <= maxcnt)
      SET holdstr1 = trim(temp2->clist[cnt].disp)
      SET holdstr2 = trim(temp2->clist[cnt].cdf)
      SET holdstr3 = trim(temp2->clist[cnt].cki)
      SET holdstr4 = trim(temp2->clist[cnt].desc)
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr1," ",holdstr2,
       " ",substring(1,7,holdstr3)," ",holdstr4)
      CALL scrolltext(cnt,holdstr)
      SET cnt = (cnt+ 1)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear(3,1)
 GO TO view_only
#alias_load
 CALL clear(3,1)
 CALL text(3,4,"LOAD CODE_VALUE ALIASES ")
 CALL text(5,1,"01 Load Multum Aliases based on CKI")
 CALL text(6,1,"02 Load SureScript Aliases based on CKI")
 CALL text(7,1,"03 Return to Program Options")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;S")
 SET select_option = cnvtint(curaccept)
 IF (select_option=1)
  GO TO load_multum_aliases
 ELSEIF (select_option=2)
  GO TO load_surescript_aliases
 ELSEIF (select_option=3)
  GO TO pick_mode
 ELSE
  CALL clear(3,1)
  GO TO alias_load
 ENDIF
#load_multum_aliases
 CALL load_aliases("MULTUM")
 CALL clear(3,1)
 CALL text(23,1,"Multum aliases have been loaded.")
 CALL text(24,1,"Press Enter to continue...")
 CALL accept(24,29,";CDH"," ")
 GO TO alias_load
#load_surescript_aliases
 CALL load_aliases("NCPDPSCRIPT")
 CALL clear(3,1)
 CALL text(23,1,"SureScript aliases have been loaded.")
 CALL text(24,1,"Press Enter to continue...")
 CALL accept(24,29,";CDH"," ")
 GO TO alias_load
#exit_program
 IF (commit_ind=1)
  CALL clear(3,1)
  CALL text(23,1,"Commit all changes to the database? (Y/N)")
  CALL accept(23,43,"C;CU","N")
  SET confirm = curaccept
  IF (((confirm="Y") OR (confirm="y")) )
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
#exit_script
 SUBROUTINE add_term(disp,desc,cki,cdf,concept_cki)
   SET term_cnt = (term_cnt+ 1)
   IF (mod(term_cnt,50)=1)
    SET stat = alterlist(temp->clist,(term_cnt+ 49))
   ENDIF
   SET temp->clist[term_cnt].disp = disp
   SET temp->clist[term_cnt].desc = desc
   SET temp->clist[term_cnt].cki = cki
   SET temp->clist[term_cnt].cdf = cdf
   SET temp->clist[term_cnt].concept_cki = concept_cki
 END ;Subroutine
 SUBROUTINE cd_val_update(sub_cki,sub_criteria_field,sub_criteria_value,sub_error_msg,sub_success_msg
  )
   SET trace = recpersist
   SELECT INTO "nl:"
    cv.*
    FROM code_value cv
    WHERE parser(concat("cv.",sub_criteria_field))=sub_criteria_value
    HEAD REPORT
     stat = alterlist(request->cd_value_list,10), rec_count = 0
    DETAIL
     rec_count = (rec_count+ 1)
     IF (mod(rec_count,10)=1
      AND rec_count != 1)
      stat = alterlist(request->cd_value_list,(rec_count+ 9))
     ENDIF
     request->cd_value_list[rec_count].action_type_flag = 2, request->cd_value_list[rec_count].
     cdf_meaning = cv.cdf_meaning, request->cd_value_list[rec_count].cki = sub_cki,
     request->cd_value_list[rec_count].code_set = cv.code_set, request->cd_value_list[rec_count].
     code_value = cv.code_value, request->cd_value_list[rec_count].collation_seq = cv.collation_seq,
     request->cd_value_list[rec_count].concept_cki = cv.concept_cki, request->cd_value_list[rec_count
     ].definition = cv.definition, request->cd_value_list[rec_count].description = cv.description,
     request->cd_value_list[rec_count].display = cv.display, request->cd_value_list[rec_count].
     begin_effective_dt_tm = cv.begin_effective_dt_tm, request->cd_value_list[rec_count].
     end_effective_dt_tm = cv.end_effective_dt_tm,
     request->cd_value_list[rec_count].active_ind = cv.active_ind, request->cd_value_list[rec_count].
     display_key = cv.display_key
    FOOT REPORT
     stat = alterlist(request->cd_value_list,rec_count)
    WITH nocounter
   ;end select
   EXECUTE core_ens_cd_value
   IF (sub_error_msg > "")
    CALL clear(3,1)
    IF ((reply->status_data.status != "S"))
     CALL text(24,1,sub_error_msg)
    ELSE
     SET commit_ind = 1
     CALL text(23,1,sub_success_msg)
    ENDIF
   ENDIF
   SET trace = norecpersist
 END ;Subroutine
 SUBROUTINE cd_val_update_cdf(code_value,sub_cdf)
   SET trace = recpersist
   SELECT INTO "nl:"
    cv.*
    FROM code_value cv
    WHERE cv.code_value=code_value
    HEAD REPORT
     stat = alterlist(request->cd_value_list,10), rec_count = 0
    DETAIL
     rec_count = (rec_count+ 1)
     IF (mod(rec_count,10)=1
      AND rec_count != 1)
      stat = alterlist(request->cd_value_list,(rec_count+ 9))
     ENDIF
     request->cd_value_list[rec_count].action_type_flag = 2, request->cd_value_list[rec_count].
     cdf_meaning = sub_cdf, request->cd_value_list[rec_count].cki = cv.cki,
     request->cd_value_list[rec_count].code_set = cv.code_set, request->cd_value_list[rec_count].
     code_value = cv.code_value, request->cd_value_list[rec_count].collation_seq = cv.collation_seq,
     request->cd_value_list[rec_count].concept_cki = cv.concept_cki, request->cd_value_list[rec_count
     ].definition = cv.definition, request->cd_value_list[rec_count].description = cv.description,
     request->cd_value_list[rec_count].display = cv.display, request->cd_value_list[rec_count].
     begin_effective_dt_tm = cv.begin_effective_dt_tm, request->cd_value_list[rec_count].
     end_effective_dt_tm = cv.end_effective_dt_tm,
     request->cd_value_list[rec_count].active_ind = cv.active_ind, request->cd_value_list[rec_count].
     display_key = cv.display_key
    FOOT REPORT
     stat = alterlist(request->cd_value_list,rec_count)
    WITH nocounter
   ;end select
   EXECUTE core_ens_cd_value
   SET trace = norecpersist
   SET commit_ind = 1
 END ;Subroutine
 SUBROUTINE load_aliases(cont_src_mean)
   DECLARE contr_cd = f8 WITH public, noconstant(0.0)
   DECLARE cva_insert_cnt = i4 WITH public, noconstant(0)
   DECLARE cvo_insert_cnt = i4 WITH public, noconstant(0)
   DECLARE cv_uuid_cnt = i4 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=value(73)
     AND c.cdf_meaning=value(cont_src_mean)
    DETAIL
     contr_cd = c.code_value
    WITH nocounter
   ;end select
   IF (contr_cd < 0.0)
    CALL clear(3,1)
    CALL text(23,1,concat("Aliases cannot be added because the contributor source, ",cont_src_mean,
      ", does not exist."))
    CALL text(24,1,"Press Enter to continue...")
    CALL accept(24,29,";CDH"," ")
    RETURN
   ENDIF
   FREE SET cv_uuid
   RECORD cv_uuid(
     1 lst[*]
       2 code_value = f8
       2 uuid = vc
   )
   FREE SET cva_inserts
   RECORD cva_inserts(
     1 lst[*]
       2 alias = vc
       2 alias_type_meaning = vc
       2 code_set = f8
       2 code_value = f8
       2 primary_ind = i2
   )
   FREE SET cvo_inserts
   RECORD cvo_inserts(
     1 lst[*]
       2 alias = vc
       2 alias_type_meaning = vc
       2 code_set = f8
       2 code_value = f8
   )
   SELECT INTO "nl:"
    FROM code_value cv,
     cmt_code_value_load ccvl
    WHERE cv.cki=ccvl.cki
     AND cv.code_set=ccvl.code_set
     AND ccvl.code_set=54
    DETAIL
     cv_uuid_cnt = (cv_uuid_cnt+ 1)
     IF (mod(cv_uuid_cnt,100)=1)
      stat = alterlist(cv_uuid->lst,(cv_uuid_cnt+ 99))
     ENDIF
     cv_uuid->lst[cv_uuid_cnt].code_value = cv.code_value, cv_uuid->lst[cv_uuid_cnt].uuid = ccvl
     .code_value_uuid
    WITH nocounter
   ;end select
   SET stat = alterlist(cv_uuid->lst,cv_uuid_cnt)
   SELECT INTO "nl:"
    FROM cmt_code_value_alias_load cval,
     code_value_alias cva,
     (dummyt d  WITH seq = value(cv_uuid_cnt)),
     dummyt d2
    PLAN (d)
     JOIN (cval
     WHERE (cval.code_value_uuid=cv_uuid->lst[d.seq].uuid)
      AND cval.contributor_source_mean=cont_src_mean)
     JOIN (d2)
     JOIN (cva
     WHERE cva.alias=cval.alias
      AND cva.code_set=cval.code_set
      AND cval.code_set=54
      AND cva.contributor_source_cd=contr_cd)
    DETAIL
     cva_insert_cnt = (cva_insert_cnt+ 1)
     IF (mod(cva_insert_cnt,10)=1)
      stat = alterlist(cva_inserts->lst,(cva_insert_cnt+ 9))
     ENDIF
     cva_inserts->lst[cva_insert_cnt].alias = cval.alias, cva_inserts->lst[cva_insert_cnt].
     alias_type_meaning = cval.alias_type_meaning, cva_inserts->lst[cva_insert_cnt].code_set = cval
     .code_set,
     cva_inserts->lst[cva_insert_cnt].code_value = cv_uuid->lst[d.seq].code_value, cva_inserts->lst[
     cva_insert_cnt].primary_ind = cval.primary_ind
    WITH nocounter, outerjoin = d2, dontexist
   ;end select
   SET stat = alterlist(cva_inserts->lst,cva_insert_cnt)
   IF (cva_insert_cnt > 0)
    INSERT  FROM code_value_alias cva,
      (dummyt d  WITH seq = value(cva_insert_cnt))
     SET cva.alias = cva_inserts->lst[d.seq].alias, cva.alias_type_meaning = cva_inserts->lst[d.seq].
      alias_type_meaning, cva.code_set = cva_inserts->lst[d.seq].code_set,
      cva.code_value = cva_inserts->lst[d.seq].code_value, cva.contributor_source_cd = contr_cd, cva
      .primary_ind = cva_inserts->lst[d.seq].primary_ind
     PLAN (d)
      JOIN (cva)
     WITH nocounter
    ;end insert
    SET commit_ind = 1
   ENDIF
   SELECT INTO "nl:"
    FROM cmt_code_value_outbnd_load cvol,
     code_value_outbound cvo,
     (dummyt d  WITH seq = value(cv_uuid_cnt)),
     dummyt d2
    PLAN (cvol
     WHERE cvol.contributor_source_mean=cont_src_mean)
     JOIN (d
     WHERE (cvol.code_value_uuid=cv_uuid->lst[d.seq].uuid))
     JOIN (d2)
     JOIN (cvo
     WHERE (cvo.code_value=cv_uuid->lst[d.seq].code_value)
      AND cvo.contributor_source_cd=contr_cd)
    DETAIL
     cvo_insert_cnt = (cvo_insert_cnt+ 1)
     IF (mod(cvo_insert_cnt,10)=1)
      stat = alterlist(cvo_inserts->lst,(cvo_insert_cnt+ 9))
     ENDIF
     cvo_inserts->lst[cvo_insert_cnt].alias = cvol.alias, cvo_inserts->lst[cvo_insert_cnt].
     alias_type_meaning = cvol.alias_type_meaning, cvo_inserts->lst[cvo_insert_cnt].code_set = cvol
     .code_set,
     cvo_inserts->lst[cvo_insert_cnt].code_value = cv_uuid->lst[d.seq].code_value
    WITH nocounter, outerjoin = d2, dontexist
   ;end select
   SET stat = alterlist(cvo_inserts->lst,cvo_insert_cnt)
   IF (cvo_insert_cnt > 0)
    INSERT  FROM code_value_outbound cvo,
      (dummyt d  WITH seq = value(cvo_insert_cnt))
     SET cvo.alias = cvo_inserts->lst[d.seq].alias, cvo.alias_type_meaning = cvo_inserts->lst[d.seq].
      alias_type_meaning, cvo.code_set = cvo_inserts->lst[d.seq].code_set,
      cvo.code_value = cvo_inserts->lst[d.seq].code_value, cvo.contributor_source_cd = contr_cd
     PLAN (d)
      JOIN (cvo)
     WITH nocounter
    ;end insert
    SET commit_ind = 1
   ENDIF
 END ;Subroutine
 SET mod_dt = "14JAN2011"
END GO

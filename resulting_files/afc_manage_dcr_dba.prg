CREATE PROGRAM afc_manage_dcr:dba
 CALL echo("")
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo(concat(curprog," : ","VERSION : ","CHARGSRV-15782.000"))
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo("")
 RECORD dcrorganization(
   1 beg_line = i4
   1 end_line = i4
   1 cur_line = i4
   1 max_scroll = i4
   1 organizations[*]
     2 orgname = vc
     2 organizationid = f8
     2 orginfoid = f8
     2 orginfoupdtcnt = i4
     2 dcrmigrationdate = dq8
 ) WITH protect
 RECORD pmensorginforeq(
   1 objarray[*]
     2 action_type = c3
     2 new_person = c1
     2 org_info_id = f8
     2 organization_id = f8
     2 info_type_cd = f8
     2 info_sub_type_cd = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 long_text_id = f8
     2 value_numeric = i4
     2 value_dt_tm = dq8
     2 chartable_ind_ind = i2
     2 chartable_ind = i2
     2 contributor_system_cd = f8
     2 value_cd = f8
     2 updt_cnt = f8
 )
 RECORD pmensorginforep(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE hi18nclean = i4 WITH noconstant(0)
 CALL uar_i18nlocalizationinit(hi18nclean,curprog," ",curcclrev)
 DECLARE i18n_l_commit = c28 WITH protect, noconstant("")
 SET i18n_commit = uar_i18ngetmessage(hi18nclean,build(curprog,".L_COMMIT"),
  "Commit the changes? (Y/N)")
 DECLARE i18n_p_commit = c1 WITH protect, noconstant("")
 SET i18n_p_commit = uar_i18ngetmessage(hi18nclean,build(curprog,".P_COMMIT"),"Y")
 DECLARE i18n_l_title = c50 WITH protect, noconstant("")
 SET i18n_l_title = uar_i18ngetmessage(hi18nclean,build(curprog,".L_TITLE"),
  "RevElate-CPA Dual Charge Routing")
 DECLARE i18n_l_action = c27 WITH protect, noconstant("")
 SET i18n_l_action = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),
  "Update/Delete/Quit (U/D/Q)?")
 DECLARE i18n_p_update = c1 WITH protect, noconstant("")
 SET i18n_p_update = uar_i18ngetmessage(hi18nclean,build(curprog,".P_UPDATE"),"U")
 DECLARE i18n_p_delete = c1 WITH protect, noconstant("")
 SET i18n_p_delete = uar_i18ngetmessage(hi18nclean,build(curprog,".P_DELETE"),"D")
 DECLARE i18n_p_quit = c1 WITH protect, noconstant("")
 SET i18n_p_quit = uar_i18ngetmessage(hi18nclean,build(curprog,".P_QUIT"),"Q")
 DECLARE i18n_l_date_input = c14 WITH protect, noconstant("")
 SET i18n_l_date_input = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),"Input the date")
 DECLARE i18n_l_org_id = c15 WITH protect, noconstant("")
 SET i18n_l_org_id = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),"Organization Id")
 DECLARE i18n_l_org = c12 WITH protect, noconstant("")
 SET i18n_l_org = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),"Organization")
 DECLARE i18n_l_dcr_date = c9 WITH protect, noconstant("")
 SET i18n_l_dcr_date = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),"DCR Date:")
 DECLARE i18n_l_future_date = c100 WITH protect, noconstant("")
 SET i18n_l_future_date = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),
  "Date must be in future for production domains. Press Enter to return to the utility.")
 DECLARE c_org_name = c12 WITH protect, constant("ORGANIZATION")
 DECLARE c_organization_id = c15 WITH protect, constant("ORGANIZATION_ID")
 DECLARE c_dcr_date = c11 WITH protect, constant("DCR_DATE")
 DECLARE cs355_revelate_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",355,"REVELATE"
    )))
 DECLARE cs356_dcrrevelate_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",356,
    "REVELATEDCR")))
 DECLARE cs48_inactive_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",48,"INACTIVE"))
  )
 DECLARE action = c1 WITH protect, noconstant("")
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE showorganizationmenu(null) = null
 DECLARE scrollorganization(null) = null
 DECLARE displayorganization(null) = null
 SET dcrorganization->cur_line = 1
#main
 CALL clear(1,1)
 CALL video(l)
 CALL showorganizationmenu(0)
 CALL clear(17,1)
 CALL text(17,2,i18n_commit)
 CALL accept(17,30,"P;CU",i18n_p_commit)
 CALL clear(17,1)
 IF (curaccept=i18n_p_commit)
  COMMIT
  CALL clear(1,1)
 ELSE
  ROLLBACK
 ENDIF
 SUBROUTINE showorganizationmenu(null)
   SET stat = alterlist(dcrorganization->organizations,0)
   SELECT INTO "nl:"
    org_name = cnvtupper(o.org_name)
    FROM bill_org_payor bop,
     organization o,
     org_info oi
    PLAN (bop
     WHERE bop.active_ind=1)
     JOIN (o
     WHERE o.organization_id=bop.organization_id
      AND o.active_ind=1)
     JOIN (oi
     WHERE (oi.organization_id= Outerjoin(o.organization_id))
      AND (oi.info_sub_type_cd= Outerjoin(cs356_dcrrevelate_cd))
      AND (oi.info_type_cd= Outerjoin(cs355_revelate_cd))
      AND (oi.active_ind= Outerjoin(1)) )
    ORDER BY org_name, o.organization_id
    HEAD REPORT
     icnt = 0
    HEAD org_name
     null
    HEAD o.organization_id
     icnt += 1
     IF (mod(icnt,10)=1)
      stat = alterlist(dcrorganization->organizations,(icnt+ 9))
     ENDIF
     dcrorganization->organizations[icnt].orgname = org_name, dcrorganization->organizations[icnt].
     organizationid = o.organization_id, dcrorganization->organizations[icnt].orginfoid = oi
     .org_info_id,
     dcrorganization->organizations[icnt].orginfoupdtcnt = oi.updt_cnt, dcrorganization->
     organizations[icnt].dcrmigrationdate = oi.value_dt_tm
    FOOT REPORT
     IF (mod(icnt,10) != 0)
      stat = alterlist(dcrorganization->organizations,icnt)
     ENDIF
    WITH nocounter
   ;end select
   SET dcrorganization->max_scroll = 7
   SET dcrorganization->beg_line = dcrorganization->cur_line
   SET dcrorganization->end_line = ((dcrorganization->beg_line+ dcrorganization->max_scroll) - 1)
   CALL video(n)
   CALL clear(1,1)
   CALL line(1,1,132)
   CALL text(2,1,i18n_l_title,w)
   CALL line(3,1,132)
   CALL video(u)
   CALL text(4,4,c_org_name)
   CALL text(4,105,c_organization_id)
   CALL text(4,121,c_dcr_date)
   CALL video(n)
   CALL line(5,1,132)
   CALL displayorganization(0)
   CALL scrollorganization(0)
   CASE (action)
    OF "U":
    OF "D":
     CALL updateorginfo(dcrorganization->organizations[dcrorganization->cur_line].orgname,
      dcrorganization->organizations[dcrorganization->cur_line].organizationid,dcrorganization->
      organizations[dcrorganization->cur_line].orginfoid,dcrorganization->organizations[
      dcrorganization->cur_line].orginfoupdtcnt,dcrorganization->organizations[dcrorganization->
      cur_line].dcrmigrationdate,
      action)
    OF "Q":
     RETURN
    ELSE
     RETURN
   ENDCASE
 END ;Subroutine
 SUBROUTINE scrollorganization(null)
   DECLARE selected_action = c1 WITH protect, noconstant(" ")
   CALL line(13,1,132)
   CALL text(14,1,i18n_l_action)
   CALL line(15,1,132)
   SET selected_action = " "
   WHILE (selected_action=" ")
     CALL accept(14,29,"p;cus",i18n_p_quit
      WHERE curaccept IN (i18n_p_update, i18n_p_delete, i18n_p_quit))
     CASE (curscroll)
      OF 0:
       SET selected_action = curaccept
      OF 1:
       IF (size(dcrorganization->organizations,5) > 0)
        IF ((dcrorganization->cur_line < size(dcrorganization->organizations,5)))
         SET dcrorganization->cur_line += 1
        ENDIF
       ENDIF
      OF 2:
       IF (size(dcrorganization->organizations,5) > 0)
        IF ((dcrorganization->cur_line > 1))
         SET dcrorganization->cur_line -= 1
        ENDIF
       ENDIF
      OF 5:
       IF (size(dcrorganization->organizations,5) > 0
        AND (size(dcrorganization->organizations,5) > dcrorganization->max_scroll))
        IF (((dcrorganization->cur_line - dcrorganization->max_scroll) > 1))
         SET dcrorganization->cur_line = ((dcrorganization->cur_line - dcrorganization->max_scroll)+
         1)
        ELSE
         SET dcrorganization->cur_line = 1
        ENDIF
       ENDIF
      OF 6:
       IF (size(dcrorganization->organizations,5) > 0
        AND (size(dcrorganization->organizations,5) > dcrorganization->max_scroll))
        IF (((dcrorganization->cur_line+ dcrorganization->max_scroll) <= ((size(dcrorganization->
         organizations,5) - dcrorganization->max_scroll)+ 1)))
         SET dcrorganization->cur_line += dcrorganization->max_scroll
        ELSE
         SET dcrorganization->cur_line = ((size(dcrorganization->organizations,5) - dcrorganization->
         max_scroll)+ 1)
        ENDIF
       ENDIF
     ENDCASE
     CALL displayorganization(0)
   ENDWHILE
   SET action = selected_action
 END ;Subroutine
 SUBROUTINE displayorganization(null)
   DECLARE display_line = i4 WITH protect, noconstant(5)
   DECLARE org_name = c128 WITH protect, noconstant(fillstring(132," "))
   DECLARE org_id = f8 WITH protect
   DECLARE dcrmigrationdate = c11 WITH protect
   IF (size(dcrorganization->organizations,5) > 0)
    SET dcrorganization->beg_line = dcrorganization->cur_line
    SET dcrorganization->end_line = ((dcrorganization->cur_line+ dcrorganization->max_scroll) - 1)
    IF ((dcrorganization->end_line > size(dcrorganization->organizations,5)))
     SET dcrorganization->end_line = size(dcrorganization->organizations,5)
    ENDIF
    IF ((((dcrorganization->end_line - dcrorganization->beg_line)+ 1) < dcrorganization->max_scroll))
     SET dcrorganization->beg_line = ((dcrorganization->end_line - dcrorganization->max_scroll)+ 1)
     IF ((dcrorganization->beg_line < 1))
      SET dcrorganization->beg_line = 1
     ENDIF
    ENDIF
    SET display_line = 5
    FOR (index = dcrorganization->beg_line TO dcrorganization->end_line)
      SET display_line += 1
      IF ((dcrorganization->cur_line=index))
       CALL video(n)
       CALL video(r)
      ELSE
       CALL video(n)
      ENDIF
      SET org_name = fillstring(100," ")
      SET org_name = substring(1,75,dcrorganization->organizations[index].orgname)
      SET org_id = dcrorganization->organizations[index].organizationid
      SET dcrmigrationdate = format(cnvtdatetime(dcrorganization->organizations[index].
        dcrmigrationdate),"DD-MMM-YYYY;;d")
      CALL text(display_line,4,notrim(org_name))
      CALL text(display_line,105,notrim(cnvtstring(org_id)))
      CALL text(display_line,121,notrim(dcrmigrationdate))
      CALL video(n)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateorginfo(porgname=vc,porgid=f8,porginfoid=f8,porginfoupdtcnt=i4,pdcrmigrationdate=
  dq8,paction=c1) =i2)
   SET stat = initrec(pmensorginforeq)
   SET stat = initrec(pmensorginforep)
   DECLARE dcrdate = vc WITH protect, noconstant("")
   DECLARE action_begin = i4 WITH protect, noconstant(1)
   DECLARE action_end = i4 WITH protect, noconstant(1)
   IF (paction="U")
    CALL video(n)
    CALL clear(1,1)
    CALL line(1,1,132)
    CALL text(2,1,i18n_l_date_input,w)
    CALL line(3,1,132)
    CALL video(u)
    CALL text(4,5,i18n_l_org_id)
    CALL text(4,30,i18n_l_org)
    CALL video(n)
    CALL text(5,5,cnvtstring(porgid))
    CALL text(5,30,porgname)
    CALL video(u)
    CALL text(8,5,i18n_l_dcr_date)
    CALL video(n)
    SET temp_end_date = cnvtdatetime((curdate+ 1),0)
    CALL accept(8,30,"NNDCCCDNNNN;CS;CU",format(cnvtdatetime(temp_end_date),"DD-MMM-YYYY;;D"))
    CALL line(9,1,132)
    SET dcrdate = curaccept
    CALL text(11,1,build(i18n_l_org,":"))
    CALL text(11,20,porgname)
    CALL text(12,1,i18n_l_dcr_date)
    CALL text(12,20,dcrdate)
    CALL line(13,1,132)
    IF (cnvtupper(substring(1,1,curdomain))="P")
     IF (cnvtdatetime(dcrdate) < cnvtdatetime(curdate,curtime))
      CALL text(17,2,i18n_l_future_date)
      CALL accept(18,1,"P;CU","")
      GO TO main
     ENDIF
    ENDIF
    CALL clear(17,1)
    CALL text(17,2,uar_i18ngetmessage(hi18nclean,build(curprog,".L_CORRECT"),"Correct? (Y/N)"))
    CALL accept(17,18,"P;CU",uar_i18ngetmessage(hi18nclean,build(curprog,".P_CORRECT"),"Y"))
    CALL clear(17,1)
    IF (curaccept="Y")
     SET stat = alterlist(pmensorginforeq->objarray,1)
     SET pmensorginforeq->objarray[1].organization_id = porgid
     SET pmensorginforeq->objarray[1].info_type_cd = cs355_revelate_cd
     SET pmensorginforeq->objarray[1].info_sub_type_cd = cs356_dcrrevelate_cd
     SET pmensorginforeq->objarray[1].active_ind_ind = 1
     SET pmensorginforeq->objarray[1].active_ind = 1
     SET pmensorginforeq->objarray[1].value_dt_tm = cnvtdatetime(dcrdate)
     IF (porginfoid > 0)
      SET pmensorginforeq->objarray[1].org_info_id = porginfoid
      SET pmensorginforeq->objarray[1].updt_cnt = porginfoupdtcnt
      IF (size(pmensorginforeq->objarray,5) > 0)
       EXECUTE pm_upt_org_info  WITH replace("REQUEST",pmensorginforeq), replace("REPLY",
        pmensorginforep)
      ENDIF
     ELSE
      SET pmensorginforeq->objarray[1].beg_effective_dt_tm = cnvtdatetime(sysdate)
      IF (size(pmensorginforeq->objarray,5) > 0)
       EXECUTE pm_add_org_info  WITH replace("REQUEST",pmensorginforeq), replace("REPLY",
        pmensorginforep)
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (paction="D"
    AND porginfoid > 0)
    SET stat = alterlist(pmensorginforeq->objarray,1)
    SET pmensorginforeq->objarray[1].org_info_id = porginfoid
    SET pmensorginforeq->objarray[1].active_status_cd = cs48_inactive_cd
    IF (size(pmensorginforeq->objarray,5) > 0)
     SET action_begin = 1
     SET action_end = 1
     EXECUTE pm_rmv_org_info  WITH replace("REQUEST",pmensorginforeq), replace("REPLY",
      pmensorginforep)
    ENDIF
   ENDIF
   GO TO main
 END ;Subroutine
END GO

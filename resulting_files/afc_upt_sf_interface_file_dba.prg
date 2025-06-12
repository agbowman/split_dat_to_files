CREATE PROGRAM afc_upt_sf_interface_file:dba
 CALL echo("")
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo(concat(curprog," : ","VERSION : ","CHARGSRV-14679.000"))
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo("")
 RECORD interfacefilerecord(
   1 beg_line = i4
   1 end_line = i4
   1 cur_line = i4
   1 max_scroll = i4
   1 interfacefileids[*]
     2 interfacefiledesc = vc
     2 interfacefileid = f8
     2 sfind = i2
 ) WITH protect
 DECLARE hi18nclean = i4 WITH noconstant(0)
 CALL uar_i18nlocalizationinit(hi18nclean,curprog," ",curcclrev)
 DECLARE i18n_l_commit = c28 WITH protect, noconstant("")
 SET i18n_commit = uar_i18ngetmessage(hi18nclean,build(curprog,".L_COMMIT"),
  "Commit the changes? (Y/N)")
 DECLARE i18n_p_commit = c1 WITH protect, noconstant("")
 SET i18n_p_commit = uar_i18ngetmessage(hi18nclean,build(curprog,".P_COMMIT"),"Y")
 DECLARE i18n_l_title = c130 WITH protect, noconstant("")
 SET i18n_l_title = uar_i18ngetmessage(hi18nclean,build(curprog,".L_TITLE"),
  "Select the Interface File to Update the SF_HL7_IND")
 DECLARE i18n_l_action = c23 WITH protect, noconstant("")
 SET i18n_l_action = uar_i18ngetmessage(hi18nclean,build(curprog,".L_ACTION"),"Update/Quit (U/Q)?")
 DECLARE i18n_p_update = c1 WITH protect, noconstant("")
 SET i18n_p_update = uar_i18ngetmessage(hi18nclean,build(curprog,".P_UPDATE"),"U")
 DECLARE i18n_p_quit = c1 WITH protect, noconstant("")
 SET i18n_p_quit = uar_i18ngetmessage(hi18nclean,build(curprog,".P_QUIT"),"Q")
 DECLARE c_interface_file_desc = c19 WITH protect, constant("INTERFACE_FILE_DESC")
 DECLARE c_interface_file_id = c17 WITH protect, constant("INTERFACE_FILE_ID")
 DECLARE c_sf_hl7_ind = c10 WITH protect, constant("SF_HL7_IND")
 DECLARE action = c1 WITH protect, noconstant("")
 DECLARE showinterfacefilemenu(null) = null
 DECLARE scrollinterfacefiles(null) = null
 DECLARE displayinterfacefiles(null) = null
 SET interfacefilerecord->cur_line = 1
#main
 CALL clear(1,1)
 CALL video(l)
 CALL showinterfacefilemenu(0)
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
 SUBROUTINE showinterfacefilemenu(null)
   SET stat = alterlist(interfacefilerecord->interfacefileids,0)
   SELECT INTO "nl:"
    if_desc = cnvtupper(i.description)
    FROM interface_file i
    PLAN (i
     WHERE i.active_ind=1)
    ORDER BY if_desc
    HEAD REPORT
     icnt = 0
    DETAIL
     icnt += 1
     IF (mod(icnt,10)=1)
      stat = alterlist(interfacefilerecord->interfacefileids,(icnt+ 9))
     ENDIF
     interfacefilerecord->interfacefileids[icnt].interfacefiledesc = i.description,
     interfacefilerecord->interfacefileids[icnt].interfacefileid = i.interface_file_id,
     interfacefilerecord->interfacefileids[icnt].sfind = i.sf_hl7_ind
    FOOT REPORT
     IF (mod(icnt,10) != 0)
      stat = alterlist(interfacefilerecord->interfacefileids,icnt)
     ENDIF
    WITH nocounter
   ;end select
   SET interfacefilerecord->max_scroll = 7
   SET interfacefilerecord->beg_line = interfacefilerecord->cur_line
   SET interfacefilerecord->end_line = ((interfacefilerecord->beg_line+ interfacefilerecord->
   max_scroll) - 1)
   CALL video(n)
   CALL clear(1,1)
   CALL line(1,1,132)
   CALL text(2,1,i18n_l_title,w)
   CALL line(3,1,132)
   CALL video(u)
   CALL text(4,4,c_interface_file_desc)
   CALL text(4,80,c_interface_file_id)
   CALL text(4,100,c_sf_hl7_ind)
   CALL video(n)
   CALL line(5,1,132)
   CALL displayinterfacefiles(0)
   CALL scrollinterfacefiles(0)
   CASE (action)
    OF "U":
     CALL updateinterfacefile(interfacefilerecord->interfacefileids[interfacefilerecord->cur_line].
      interfacefiledesc,interfacefilerecord->interfacefileids[interfacefilerecord->cur_line].
      interfacefileid,interfacefilerecord->interfacefileids[interfacefilerecord->cur_line].sfind)
    OF "Q":
     RETURN
    ELSE
     RETURN
   ENDCASE
 END ;Subroutine
 SUBROUTINE scrollinterfacefiles(null)
   DECLARE selected_action = c1 WITH protect, noconstant(" ")
   CALL line(13,1,132)
   CALL text(14,1,i18n_l_action)
   CALL line(15,1,132)
   SET selected_action = " "
   WHILE (selected_action=" ")
     CALL accept(14,25,"p;cus",i18n_p_quit
      WHERE curaccept IN (i18n_p_update, i18n_p_quit))
     CASE (curscroll)
      OF 0:
       SET selected_action = curaccept
      OF 1:
       IF (size(interfacefilerecord->interfacefileids,5) > 0)
        IF ((interfacefilerecord->cur_line < size(interfacefilerecord->interfacefileids,5)))
         SET interfacefilerecord->cur_line += 1
        ENDIF
       ENDIF
      OF 2:
       IF (size(interfacefilerecord->interfacefileids,5) > 0)
        IF ((interfacefilerecord->cur_line > 1))
         SET interfacefilerecord->cur_line -= 1
        ENDIF
       ENDIF
      OF 5:
       IF (size(interfacefilerecord->interfacefileids,5) > 0
        AND (size(interfacefilerecord->interfacefileids,5) > interfacefilerecord->max_scroll))
        IF (((interfacefilerecord->cur_line - interfacefilerecord->max_scroll) > 1))
         SET interfacefilerecord->cur_line = ((interfacefilerecord->cur_line - interfacefilerecord->
         max_scroll)+ 1)
        ELSE
         SET interfacefilerecord->cur_line = 1
        ENDIF
       ENDIF
      OF 6:
       IF (size(interfacefilerecord->interfacefileids,5) > 0
        AND (size(interfacefilerecord->interfacefileids,5) > interfacefilerecord->max_scroll))
        IF (((interfacefilerecord->cur_line+ interfacefilerecord->max_scroll) <= ((size(
         interfacefilerecord->interfacefileids,5) - interfacefilerecord->max_scroll)+ 1)))
         SET interfacefilerecord->cur_line += interfacefilerecord->max_scroll
        ELSE
         SET interfacefilerecord->cur_line = ((size(interfacefilerecord->interfacefileids,5) -
         interfacefilerecord->max_scroll)+ 1)
        ENDIF
       ENDIF
     ENDCASE
     CALL displayinterfacefiles(0)
   ENDWHILE
   SET action = selected_action
 END ;Subroutine
 SUBROUTINE displayinterfacefiles(null)
   DECLARE display_line = i4 WITH protect, noconstant(5)
   DECLARE int_file_desc = c100 WITH protect, noconstant(fillstring(100," "))
   DECLARE int_file_id = f8 WITH protect
   DECLARE sf_ind = i2 WITH protect
   IF (size(interfacefilerecord->interfacefileids,5) > 0)
    SET interfacefilerecord->beg_line = interfacefilerecord->cur_line
    SET interfacefilerecord->end_line = ((interfacefilerecord->cur_line+ interfacefilerecord->
    max_scroll) - 1)
    IF ((interfacefilerecord->end_line > size(interfacefilerecord->interfacefileids,5)))
     SET interfacefilerecord->end_line = size(interfacefilerecord->interfacefileids,5)
    ENDIF
    IF ((((interfacefilerecord->end_line - interfacefilerecord->beg_line)+ 1) < interfacefilerecord->
    max_scroll))
     SET interfacefilerecord->beg_line = ((interfacefilerecord->end_line - interfacefilerecord->
     max_scroll)+ 1)
     IF ((interfacefilerecord->beg_line < 1))
      SET interfacefilerecord->beg_line = 1
     ENDIF
    ENDIF
    SET display_line = 5
    FOR (index = interfacefilerecord->beg_line TO interfacefilerecord->end_line)
      SET display_line += 1
      IF ((interfacefilerecord->cur_line=index))
       CALL video(n)
       CALL video(r)
      ELSE
       CALL video(n)
      ENDIF
      SET int_file_desc = fillstring(100," ")
      SET int_file_desc = substring(1,75,interfacefilerecord->interfacefileids[index].
       interfacefiledesc)
      SET int_file_id = interfacefilerecord->interfacefileids[index].interfacefileid
      SET sf_ind = interfacefilerecord->interfacefileids[index].sfind
      CALL text(display_line,4,notrim(int_file_desc))
      CALL text(display_line,80,notrim(cnvtstring(int_file_id)))
      CALL text(display_line,100,notrim(cnvtstring(sf_ind)))
      CALL video(n)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateinterfacefile(pifdesc=vc,pifid=f8,psfind=i2) =i2)
   DECLARE newsfind = i2 WITH protect, noconstant(1)
   IF (psfind)
    SET newsfind = false
   ENDIF
   UPDATE  FROM interface_file i
    SET i.sf_hl7_ind = newsfind, i.updt_cnt = (i.updt_cnt+ 1), i.updt_dt_tm = cnvtdatetime(sysdate),
     i.updt_id = reqinfo->updt_id, i.updt_applctx = 0
    WHERE i.interface_file_id=pifid
    WITH nocounter
   ;end update
   GO TO main
 END ;Subroutine
END GO

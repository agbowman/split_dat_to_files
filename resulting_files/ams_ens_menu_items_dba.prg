CREATE PROGRAM ams_ens_menu_items:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD ams_dminfo_reqi(
   1 allow_partial_ind = i2
   1 info_domaini = i2
   1 info_namei = i2
   1 info_datei = i2
   1 info_daten = i2
   1 info_chari = i2
   1 info_charn = i2
   1 info_numberi = i2
   1 info_numbern = i2
   1 info_long_idi = i2
   1 qual[*]
     2 info_domain = c80
     2 info_name = c255
     2 info_date = dq8
     2 info_char = c255
     2 info_number = f8
     2 info_long_id = f8
 )
 RECORD ams_dminfo_reqw(
   1 allow_partial_ind = i2
   1 force_updt_ind = i2
   1 info_domainw = i2
   1 info_namew = i2
   1 info_datew = i2
   1 info_charw = i2
   1 info_numberw = i2
   1 info_long_idw = i2
   1 updt_applctxw = i2
   1 updt_dt_tmw = i2
   1 updt_cntw = i2
   1 updt_idw = i2
   1 updt_taskw = i2
   1 info_domainf = i2
   1 info_namef = i2
   1 info_datef = i2
   1 info_charf = i2
   1 info_numberf = i2
   1 info_long_idf = i2
   1 updt_cntf = i2
   1 qual[*]
     2 info_domain = c80
     2 info_name = c255
     2 info_date = dq8
     2 info_char = c255
     2 info_number = f8
     2 info_long_id = f8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_task = i4
 )
 RECORD ams_dminfo_rep(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 info_domain = c80
     2 info_name = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD rgroup
 RECORD rgroup(
   1 qual_knt = i4
   1 qual[*]
     2 group_name = vc
     2 group_cd = f8
 )
 DECLARE emenuitem = c1 WITH protect, constant("M")
 DECLARE esubmenuitem = c1 WITH protect, constant("S")
 DECLARE eprogramitem = c1 WITH protect, constant("P")
 DECLARE ilistsize = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE breactivatemenuitem = i2 WITH protect, noconstant(false)
 DECLARE dpreviousmenuid = f8 WITH protect, noconstant(0.0)
 DECLARE dnewmenuid = f8 WITH protect, noconstant(0.0)
 DECLARE findmenuid(citemtype=c1,dparentid=f8,pidx=i4) = f8 WITH protect
 DECLARE setsecuritymenuitem(ditemid=f8,pidx=i4) = i2 WITH protect
 DECLARE getnewmenuid(null) = f8 WITH protect
 DECLARE addmenuitem(ditemid=f8,dparentid=f8,pidx=i4) = i2 WITH protect
 DECLARE activatemenuitem(ditemid=f8) = i2 WITH protect
 DECLARE inactivatemenuitem(ditemid=f8) = i2 WITH protect
 DECLARE haschildren(ditemid=f8) = f8 WITH protect
 DECLARE removemenuitem(ditemid=f8) = i2 WITH protect
 DECLARE setdminfochar(sdomain=vc,sname=vc,schar=vc) = i2 WITH protect
 DECLARE setdminfonbr(sdomain=vc,sname=vc,dnbr=f8) = i2 WITH protect
 FOR (fidx = 1 TO ilistsize)
   CALL echo("***")
   CALL echo(build2("***   Processing (",trim(cnvtstring(fidx))," of ",trim(cnvtstring(ilistsize)),
     ") ",
     requestin->list_0[fidx].type,"<->",requestin->list_0[fidx].name,"<->",requestin->list_0[fidx].
     description,
     "<->",requestin->list_0[fidx].group_string,"<->",requestin->list_0[fidx].action))
   CALL echo("***")
   IF (cnvtupper(requestin->list_0[fidx].type)="T")
    IF (setdminfochar(trim(requestin->list_0[fidx].name,3),trim(requestin->list_0[fidx].description,3
      ),trim(requestin->list_0[fidx].group_string,3)) != true)
     SET readme_data->status = "F"
     SET readme_data->message = "Readme Failed: Adding DM_INFO CHAR Version"
     GO TO exit_script
    ENDIF
    IF (isnumeric(trim(requestin->list_0[fidx].group_string,3)))
     IF (setdminfonbr(trim(requestin->list_0[fidx].name,3),trim(requestin->list_0[fidx].description,3
       ),cnvtreal(trim(requestin->list_0[fidx].group_string,3))) != true)
      SET readme_data->status = "F"
      SET readme_data->message = "Readme Failed: Adding DM_INFO NBR Version"
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SET dnewmenuid = 0.0
    IF (cnvtupper(requestin->list_0[fidx].type)="M")
     SET dpreviousmenuid = 0.0
    ENDIF
    SET breactivatemenuitem = false
    SET dmenuitemid = findmenuid(cnvtupper(requestin->list_0[fidx].type),dpreviousmenuid,fidx)
    IF (dmenuitemid < 0)
     SET readme_data->status = "F"
     SET readme_data->message = "SCRIPT ERROR: Find Menu Item Id"
     GO TO exit_script
    ELSEIF (dmenuitemid > 0)
     IF (breactivatemenuitem=true)
      IF (cnvtupper(trim(requestin->list_0[fidx].action,3)) != "DELETE")
       IF ( NOT (activatemenuitem(dmenuitemid)))
        SET readme_data->status = "F"
        SET readme_data->message = "SCRIPT ERROR: Activating Menu Item"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     SET dpreviousmenuid = dmenuitemid
     IF (cnvtupper(trim(requestin->list_0[fidx].action,3))="DELETE")
      IF (removemenuitem(dmenuitemid) != 1)
       SET readme_data->status = "F"
       SET readme_data->message = "SCRIPT ERROR: Removing Menu Item"
       GO TO exit_script
      ENDIF
     ELSE
      IF (size(trim(requestin->list_0[fidx].group_string,3)) > 0
       AND cnvtupper(trim(requestin->list_0[fidx].action,3)) != "DELETE")
       IF ( NOT (setsecuritymenuitem(dmenuitemid,fidx)))
        SET readme_data->status = "F"
        SET readme_data->message = "SCRIPT ERROR: Seting Menu Item Security"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (cnvtupper(trim(requestin->list_0[fidx].action,3)) != "DELETE")
     SET dnewmenuid = getnewmenuid(null)
     IF (dnewmenuid < 1)
      SET readme_data->status = "F"
      SET readme_data->message = "SCRIPT ERROR: Generating New Menu Id"
      GO TO exit_script
     ENDIF
     IF (addmenuitem(dnewmenuid,dpreviousmenuid,fidx))
      SET dpreviousmenuid = dnewmenuid
      IF (size(trim(requestin->list_0[fidx].group_string,3)) > 0)
       IF ( NOT (setsecuritymenuitem(dnewmenuid,fidx)))
        SET readme_data->status = "F"
        SET readme_data->message = "SCRIPT ERROR: Seting Menu Item Security"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = "SCRIPT ERROR: Inserting Menu Items"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("***")
 CALL echo("***   Copy Provider Search Files")
 CALL echo("***")
 DECLARE scmdstring = vc WITH protect, noconstant(" ")
 DECLARE idclstatus = i4 WITH protect, noconstant(0)
 DECLARE icmdlength = i4 WITH protect, noconstant(0)
 IF (findfile("cer_install:ccps_provider_selection_lite.dat")
  AND  NOT (findfile("cclsource:ccps_provider_selection_lite.js")))
  SET scmdstring =
  "cp $cer_install/ccps_provider_selection_lite.dat $CCLSOURCE/ccps_provider_selection_lite.js"
  SET icmdlength = textlen(trim(scmdstring,3))
  CALL dcl(scmdstring,icmdlength,idclstatus)
  CALL echo("***")
  CALL echo("***   COPY ccps_provider_selection_lite.dat")
  CALL echo(build2("***   iDCLStatus: ",idclstatus))
  CALL echo("***")
 ENDIF
 IF (findfile("cer_install:ccps_pm_search.dat")
  AND  NOT (findfile("cclsource:ccps_pm_search.js")))
  SET scmdstring = "cp $cer_install/ccps_pm_search.dat $CCLSOURCE/ccps_pm_search.js"
  SET icmdlength = textlen(trim(scmdstring,3))
  CALL dcl(scmdstring,icmdlength,idclstatus)
  CALL echo("***")
  CALL echo("***   COPY ccps_pm_search.dat")
  CALL echo(build2("***   iDCLStatus: ",idclstatus))
  CALL echo("***")
 ENDIF
 SUBROUTINE setdminfochar(sdomain,sname,schar)
   CALL echo("***")
   CALL echo("***   SetDmInfoChar")
   CALL echo("***")
   DECLARE breturnstatus = i2 WITH protect, noconstant(false)
   SET stat = alterlist(ams_dminfo_reqi->qual,0)
   SET ams_dminfo_reqi->allow_partial_ind = 0
   SET ams_dminfo_reqi->info_domaini = 0
   SET ams_dminfo_reqi->info_namei = 0
   SET ams_dminfo_reqi->info_datei = 0
   SET ams_dminfo_reqi->info_daten = 0
   SET ams_dminfo_reqi->info_chari = 0
   SET ams_dminfo_reqi->info_charn = 0
   SET ams_dminfo_reqi->info_numberi = 0
   SET ams_dminfo_reqi->info_numbern = 0
   SET ams_dminfo_reqi->info_long_idi = 0
   SET stat = alterlist(ams_dminfo_reqw->qual,0)
   SET ams_dminfo_reqw->allow_partial_ind = 0
   SET ams_dminfo_reqw->force_updt_ind = 0
   SET ams_dminfo_reqw->info_domainw = 0
   SET ams_dminfo_reqw->info_namew = 0
   SET ams_dminfo_reqw->info_datew = 0
   SET ams_dminfo_reqw->info_charw = 0
   SET ams_dminfo_reqw->info_numberw = 0
   SET ams_dminfo_reqw->info_long_idw = 0
   SET ams_dminfo_reqw->updt_applctxw = 0
   SET ams_dminfo_reqw->updt_dt_tmw = 0
   SET ams_dminfo_reqw->updt_cntw = 0
   SET ams_dminfo_reqw->updt_idw = 0
   SET ams_dminfo_reqw->updt_taskw = 0
   SET ams_dminfo_reqw->info_domainf = 0
   SET ams_dminfo_reqw->info_namef = 0
   SET ams_dminfo_reqw->info_datef = 0
   SET ams_dminfo_reqw->info_charf = 0
   SET ams_dminfo_reqw->info_numberf = 0
   SET ams_dminfo_reqw->info_long_idf = 0
   SET ams_dminfo_reqw->updt_cntf = 0
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = alterlist(ams_dminfo_reqi->qual,1)
    SET ams_dminfo_reqi->qual[1].info_domain = sdomain
    SET ams_dminfo_reqi->qual[1].info_name = sname
    SET ams_dminfo_reqi->qual[1].info_char = schar
    SET ams_dminfo_reqi->info_domaini = 1
    SET ams_dminfo_reqi->info_namei = 1
    SET ams_dminfo_reqi->info_chari = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQI"), replace("REPLY",
     "AMS_DMINFO_REP")
   ELSE
    SET stat = alterlist(ams_dminfo_reqw->qual,1)
    SET ams_dminfo_reqw->qual[1].info_domain = sdomain
    SET ams_dminfo_reqw->qual[1].info_name = sname
    SET ams_dminfo_reqw->qual[1].info_char = schar
    SET ams_dminfo_reqw->info_domainw = 1
    SET ams_dminfo_reqw->info_namew = 1
    SET ams_dminfo_reqw->info_charf = 1
    SET ams_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQW"), replace("REPLY",
     "AMS_DMINFO_REP")
   ENDIF
   IF ((ams_dminfo_rep->status_data.status="F"))
    SET breturnstatus = false
   ELSE
    SET breturnstatus = true
    COMMIT
   ENDIF
   RETURN(breturnstatus)
 END ;Subroutine
 SUBROUTINE setdminfonbr(sdomain,sname,dnbr)
   CALL echo("***")
   CALL echo("***   SetDmInfoNbr")
   CALL echo("***")
   DECLARE breturnstatus = i2 WITH protect, noconstant(false)
   SET stat = alterlist(ams_dminfo_reqi->qual,0)
   SET ams_dminfo_reqi->allow_partial_ind = 0
   SET ams_dminfo_reqi->info_domaini = 0
   SET ams_dminfo_reqi->info_namei = 0
   SET ams_dminfo_reqi->info_datei = 0
   SET ams_dminfo_reqi->info_daten = 0
   SET ams_dminfo_reqi->info_chari = 0
   SET ams_dminfo_reqi->info_charn = 0
   SET ams_dminfo_reqi->info_numberi = 0
   SET ams_dminfo_reqi->info_numbern = 0
   SET ams_dminfo_reqi->info_long_idi = 0
   SET stat = alterlist(ams_dminfo_reqw->qual,0)
   SET ams_dminfo_reqw->allow_partial_ind = 0
   SET ams_dminfo_reqw->force_updt_ind = 0
   SET ams_dminfo_reqw->info_domainw = 0
   SET ams_dminfo_reqw->info_namew = 0
   SET ams_dminfo_reqw->info_datew = 0
   SET ams_dminfo_reqw->info_charw = 0
   SET ams_dminfo_reqw->info_numberw = 0
   SET ams_dminfo_reqw->info_long_idw = 0
   SET ams_dminfo_reqw->updt_applctxw = 0
   SET ams_dminfo_reqw->updt_dt_tmw = 0
   SET ams_dminfo_reqw->updt_cntw = 0
   SET ams_dminfo_reqw->updt_idw = 0
   SET ams_dminfo_reqw->updt_taskw = 0
   SET ams_dminfo_reqw->info_domainf = 0
   SET ams_dminfo_reqw->info_namef = 0
   SET ams_dminfo_reqw->info_datef = 0
   SET ams_dminfo_reqw->info_charf = 0
   SET ams_dminfo_reqw->info_numberf = 0
   SET ams_dminfo_reqw->info_long_idf = 0
   SET ams_dminfo_reqw->updt_cntf = 0
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = alterlist(ams_dminfo_reqi->qual,1)
    SET ams_dminfo_reqi->qual[1].info_domain = sdomain
    SET ams_dminfo_reqi->qual[1].info_name = sname
    SET ams_dminfo_reqi->qual[1].info_number = dnbr
    SET ams_dminfo_reqi->info_domaini = 1
    SET ams_dminfo_reqi->info_namei = 1
    SET ams_dminfo_reqi->info_numberi = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQI"), replace("REPLY",
     "AMS_DMINFO_REP")
   ELSE
    SET stat = alterlist(ams_dminfo_reqw->qual,1)
    SET ams_dminfo_reqw->qual[1].info_domain = sdomain
    SET ams_dminfo_reqw->qual[1].info_name = sname
    SET ams_dminfo_reqw->qual[1].info_number = dnbr
    SET ams_dminfo_reqw->info_domainw = 1
    SET ams_dminfo_reqw->info_namew = 1
    SET ams_dminfo_reqw->info_numberf = 1
    SET ams_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQW"), replace("REPLY",
     "AMS_DMINFO_REP")
   ENDIF
   IF ((ams_dminfo_rep->status_data.status="F"))
    SET breturnstatus = false
   ELSE
    SET breturnstatus = true
    COMMIT
   ENDIF
   RETURN(breturnstatus)
 END ;Subroutine
 SUBROUTINE addmenuitem(did,doldid,cidx)
   CALL echo("***")
   CALL echo("***   AddMenuItem")
   CALL echo("***")
   DECLARE breturnstatus = i2 WITH protect, noconstant(true)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM explorer_menu em
    SET em.menu_id = did, em.item_name = trim(cnvtupper(requestin->list_0[cidx].name),3), em
     .item_desc = trim(requestin->list_0[cidx].description,3),
     em.item_type =
     IF (cnvtupper(requestin->list_0[cidx].type) IN ("M", "S")) "M"
     ELSE "P"
     ENDIF
     , em.menu_parent_id = doldid, em.active_ind = 1,
     em.updt_dt_tm = cnvtdatetime(curdate,curtime3), em.updt_id = reqinfo->updt_id, em.updt_task =
     reqinfo->updt_task,
     em.updt_applctx = reqinfo->updt_applctx, em.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET breturnstatus = false
   ENDIF
   RETURN(breturnstatus)
 END ;Subroutine
 SUBROUTINE getnewmenuid(null)
   CALL echo("***")
   CALL echo("***   GetNewMenuId")
   CALL echo("***")
   DECLARE dseqid = f8 WITH protect, noconstant(0.0)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    a_val = seq(explorer_menu_seq,nextval)
    FROM dual
    DETAIL
     dseqid = cnvtreal(a_val)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET dseqid = 0.0
   ENDIF
   RETURN(dseqid)
 END ;Subroutine
 SUBROUTINE setsecuritymenuitem(did,cidx)
   CALL echo("***")
   CALL echo("***   SetSecurityMenuItem")
   CALL echo("***")
   FREE RECORD rtemp
   RECORD rtemp(
     1 qual_knt = i4
     1 qual[*]
       2 grp_idx = i4
       2 grp_exist_ind = i2
   )
   DECLARE breturnstatus = i2 WITH protect, noconstant(true)
   DECLARE bfoundnewgroup = i2 WITH protect, noconstant(false)
   DECLARE igpos = i4 WITH protect, noconstant(0)
   DECLARE ignum = i4 WITH protect, noconstant(0)
   DECLARE igsemicolon = i4 WITH protect, noconstant(0)
   DECLARE igbegidx = i4 WITH protect, noconstant(1)
   DECLARE itpos = i4 WITH protect, noconstant(0)
   DECLARE itnum = i4 WITH protect, noconstant(0)
   DECLARE sgroupstring = vc WITH protect, noconstant(trim(requestin->list_0[cidx].group_string,3))
   DECLARE stempgroup = vc WITH protect, noconstant("")
   SET igsemicolon = findstring(";",sgroupstring,igbegidx,0)
   IF (igsemicolon > 0)
    WHILE (igsemicolon > 0)
      SET stempgroup = cnvtupper(cnvtalphanum(substring(1,(igsemicolon - 1),sgroupstring)))
      SET igpos = 0
      SET ignum = 0
      SET igpos = locateval(ignum,1,rgroup->qual_knt,stempgroup,rgroup->qual[ignum].group_name)
      IF (igpos < 1)
       SET bfoundnewgroup = true
       SET rgroup->qual_knt = (rgroup->qual_knt+ 1)
       SET stat = alterlist(rgroup->qual,rgroup->qual_knt)
       SET rgroup->qual[rgroup->qual_knt].group_name = stempgroup
       SET igpos = rgroup->qual_knt
      ENDIF
      SET itpos = 0
      SET itnum = 0
      SET itpos = locateval(itnum,1,rtemp->qual_knt,igpos,rtemp->qual[itnum].grp_idx)
      IF (itpos < 1)
       SET rtemp->qual_knt = (rtemp->qual_knt+ 1)
       SET stat = alterlist(rtemp->qual,rtemp->qual_knt)
       SET itpos = rtemp->qual_knt
      ENDIF
      SET rtemp->qual[itpos].grp_idx = igpos
      SET sgroupstring = substring((igsemicolon+ 1),(textlen(sgroupstring) - (igsemicolon+ 1)),
       sgroupstring)
      SET igsemicolon = findstring(";",sgroupstring,igbegidx,0)
      IF (igsemicolon < 1)
       SET stempgroup = cnvtupper(cnvtalphanum(sgroupstring))
       SET igpos = 0
       SET ignum = 0
       SET igpos = locateval(ignum,1,rgroup->qual_knt,stempgroup,rgroup->qual[ignum].group_name)
       IF (igpos < 1)
        SET bfoundnewgroup = true
        SET rgroup->qual_knt = (rgroup->qual_knt+ 1)
        SET stat = alterlist(rgroup->qual,rgroup->qual_knt)
        SET rgroup->qual[rgroup->qual_knt].group_name = stempgroup
        SET igpos = rgroup->qual_knt
       ENDIF
       SET itpos = 0
       SET itnum = 0
       SET itpos = locateval(itnum,1,rtemp->qual_knt,igpos,rtemp->qual[itnum].grp_idx)
       IF (itpos < 1)
        SET rtemp->qual_knt = (rtemp->qual_knt+ 1)
        SET stat = alterlist(rtemp->qual,rtemp->qual_knt)
        SET itpos = rtemp->qual_knt
       ENDIF
       SET rtemp->qual[itpos].grp_idx = igpos
      ENDIF
    ENDWHILE
   ELSE
    SET stempgroup = cnvtupper(cnvtalphanum(sgroupstring))
    SET igpos = 0
    SET ignum = 0
    SET igpos = locateval(ignum,1,rgroup->qual_knt,stempgroup,rgroup->qual[ignum].group_name)
    IF (igpos < 1)
     SET bfoundnewgroup = true
     SET rgroup->qual_knt = (rgroup->qual_knt+ 1)
     SET stat = alterlist(rgroup->qual,rgroup->qual_knt)
     SET rgroup->qual[rgroup->qual_knt].group_name = stempgroup
     SET igpos = rgroup->qual_knt
    ENDIF
    SET itpos = 0
    SET itnum = 0
    SET itpos = locateval(itnum,1,rtemp->qual_knt,igpos,rtemp->qual[itnum].grp_idx)
    IF (itpos < 1)
     SET rtemp->qual_knt = (rtemp->qual_knt+ 1)
     SET stat = alterlist(rtemp->qual,rtemp->qual_knt)
     SET itpos = rtemp->qual_knt
    ENDIF
    SET rtemp->qual[itpos].grp_idx = igpos
   ENDIF
   IF (bfoundnewgroup=true)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(rgroup->qual_knt)),
      code_value cv
     PLAN (d
      WHERE (rgroup->qual[d.seq].group_cd < 1))
      JOIN (cv
      WHERE cv.code_set=500
       AND (cv.display_key=rgroup->qual[d.seq].group_name)
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     HEAD d.seq
      rgroup->qual[d.seq].group_cd = cv.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     RETURN(false)
    ENDIF
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(rtemp->qual_knt)),
     explorer_menu_security ems
    PLAN (d
     WHERE (rtemp->qual[d.seq].grp_idx > 0))
     JOIN (ems
     WHERE ems.menu_id=did
      AND (ems.app_group_cd=rgroup->qual[rtemp->qual[d.seq].grp_idx].group_cd))
    HEAD d.seq
     rtemp->qual[d.seq].grp_exist_ind = 1
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    RETURN(false)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM explorer_menu_security ems,
     (dummyt d  WITH seq = value(rtemp->qual_knt))
    SET ems.menu_id = did, ems.app_group_cd = rgroup->qual[rtemp->qual[d.seq].grp_idx].group_cd, ems
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ems.updt_id = reqinfo->updt_id, ems.updt_task = reqinfo->updt_task, ems.updt_applctx = reqinfo->
     updt_applctx,
     ems.updt_cnt = 0
    PLAN (d
     WHERE (rtemp->qual[d.seq].grp_exist_ind=0))
     JOIN (ems
     WHERE 1=1)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE activatemenuitem(did)
   CALL echo("***")
   CALL echo("***   ActivateMenuItem")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM explorer_menu em
    SET em.active_ind = 1, em.updt_dt_tm = cnvtdatetime(curdate,curtime3), em.updt_id = reqinfo->
     updt_id,
     em.updt_task = reqinfo->updt_task, em.updt_applctx = reqinfo->updt_applctx, em.updt_cnt = (em
     .updt_cnt+ 1)
    PLAN (em
     WHERE em.menu_id=did)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE haschildren(did)
   CALL echo("***")
   CALL echo("***   HasChildren")
   CALL echo("***")
   DECLARE dreturnval = f8 WITH protect, noconstant(- (2.0))
   SELECT INTO "nl:"
    FROM explorer_menu em
    PLAN (em
     WHERE em.menu_parent_id=did)
    ORDER BY em.menu_id
    HEAD REPORT
     dreturnval = em.menu_id,
     CALL echo("***"),
     CALL echo(build2("***   CHILD FOUND MENU_ID: ",trim(cnvtstring(em.menu_id,17,0),3)," (",trim(em
       .item_desc,3),")")),
     CALL echo("***")
    WITH nocounter
   ;end select
   RETURN(dreturnval)
 END ;Subroutine
 SUBROUTINE removemenuitem(did)
   CALL echo("***")
   CALL echo(build2("***   BEG - RemoveMenuItem (dId = ",trim(cnvtstring(did,17,0),3),")"))
   CALL echo("***")
   DECLARE ireturnval = i2 WITH protect, noconstant(1)
   DECLARE dchildid = f8 WITH protect, noconstant(0.00)
   DECLARE dchildmenuid = f8 WITH protect, noconstant(0.00)
   DECLARE bcontinue = i2 WITH protect, noconstant(true)
   DECLARE dtempid = f8 WITH protect, noconstant(did)
   DECLARE citemtype = c1 WITH protect, noconstant("N")
   DECLARE bfoundmenu = i2 WITH protect, noconstant(false)
   DECLARE bfoundprog = i2 WITH protect, noconstant(false)
   DECLARE dstat = f8 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM explorer_menu em
    PLAN (em
     WHERE em.menu_id=did)
    DETAIL
     citemtype = cnvtupper(em.item_type)
    WITH nocounter
   ;end select
   CALL echo("***")
   CALL echo(build2("***      RemoveMenuItem (dId = ",trim(cnvtstring(did,17,0),3),") cItemType = ",
     citemtype))
   CALL echo("***")
   IF (citemtype="M")
    SET bfoundmenu = false
    SET bfoundprog = false
    SET dtempid = 0.00
    SELECT INTO "nl:"
     FROM explorer_menu em
     PLAN (em
      WHERE em.menu_parent_id=did)
     ORDER BY em.menu_id
     DETAIL
      IF (em.item_type="M"
       AND bfoundmenu=false)
       bfoundmenu = true, dtempid = em.menu_id
      ENDIF
      IF (em.item_type="P"
       AND bfoundprog=false)
       bfoundprog = true
      ENDIF
     WITH nocounter
    ;end select
    CALL echo("***")
    CALL echo(build2("***      RemoveMenuItem (dId = ",trim(cnvtstring(did,17,0),3),")  bFoundMenu: ",
      bfoundmenu," bFoundProg: ",
      bfoundprog))
    CALL echo("***")
    IF (bfoundmenu=true)
     IF (removemenuitem(dtempid)=1)
      IF (removemenuitem(did)=1)
       SET ireturnval = 1
      ELSE
       SET ireturnval = 0
      ENDIF
     ELSE
      SET ireturnval = 0
     ENDIF
    ELSE
     IF (bfoundprog=false)
      CALL echo("***")
      CALL echo(build2("***      Delete Menu Item from Security RemoveMenuItem (dId = ",trim(
         cnvtstring(did,17,0),3),")"))
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM explorer_menu_security ems
       WHERE ems.menu_id=did
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU_SECURITY (menu_id = ",
        trim(cnvtstring(did,17,0),3),")")
       ROLLBACK
       SET ireturnval = 0
      ELSE
       CALL echo("***")
       CALL echo(build2("***      Delete Menu Item from Explorer Menu RemoveMenuItem (dId = ",trim(
          cnvtstring(did,17,0),3),")"))
       CALL echo("***")
       DELETE  FROM explorer_menu em
        WHERE em.menu_id=did
         AND em.item_type="P"
        WITH nocounter
       ;end delete
       IF (ierrcode > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU (menu_id = ",trim(
          cnvtstring(did,17,0),3),")")
        ROLLBACK
        SET ireturnval = 0
       ELSE
        COMMIT
        SET ireturnval = 1
       ENDIF
      ENDIF
     ELSE
      CALL echo("***")
      CALL echo(build2("***      Delete Child Programs from Security RemoveMenuItem (dId = ",trim(
         cnvtstring(did,17,0),3),")"))
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM explorer_menu_security ems
       WHERE ems.menu_id IN (
       (SELECT
        em.menu_id
        FROM explorer_menu em
        WHERE em.menu_parent_id=did
         AND em.item_type="P"))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU_SECURITY (menu_id = ",
        trim(cnvtstring(did,17,0),3),")")
       ROLLBACK
       SET ireturnval = 0
      ELSE
       CALL echo("***")
       CALL echo(build2("***      Delete Child Programs from Explorer Menu RemoveMenuItem (dId = ",
         trim(cnvtstring(did,17,0),3),")"))
       CALL echo("***")
       DELETE  FROM explorer_menu em
        WHERE em.menu_id IN (
        (SELECT
         em.menu_id
         FROM explorer_menu em
         WHERE em.menu_parent_id=did
          AND em.item_type="P"))
        WITH nocounter
       ;end delete
       IF (ierrcode > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU (menu_id = ",trim(
          cnvtstring(did,17,0),3),")")
        ROLLBACK
        SET ireturnval = 0
       ELSE
        CALL echo("***")
        CALL echo(build2("***      Delete Menu Item from Security RemoveMenuItem (dId = ",trim(
           cnvtstring(did,17,0),3),")"))
        CALL echo("***")
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        DELETE  FROM explorer_menu_security ems
         WHERE ems.menu_id=did
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET readme_data->status = "F"
         SET readme_data->message = concat(
          "SCRIPT ERROR: Deleting EXPLORER_MENU_SECURITY (menu_id = ",trim(cnvtstring(did,17,0),3),
          ")")
         ROLLBACK
         SET ireturnval = 0
        ELSE
         CALL echo("***")
         CALL echo(build2("***      Delete Menu Item from Explorer Menu RemoveMenuItem (dId = ",trim(
            cnvtstring(did,17,0),3),")"))
         CALL echo("***")
         DELETE  FROM explorer_menu em
          WHERE em.menu_id=did
          WITH nocounter
         ;end delete
         IF (ierrcode > 0)
          SET readme_data->status = "F"
          SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU (menu_id = ",trim(
            cnvtstring(did,17,0),3),")")
          ROLLBACK
          SET ireturnval = 0
         ELSE
          COMMIT
          SET ireturnval = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    CALL echo("***")
    CALL echo(build2("***      Delete Menu Program Item from Security RemoveMenuItem (dId = ",trim(
       cnvtstring(did,17,0),3),")"))
    CALL echo("***")
    DELETE  FROM explorer_menu_security ems
     WHERE ems.menu_id=did
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU_SECURITY (menu_id = ",
      trim(cnvtstring(did,17,0),3),")")
     ROLLBACK
     SET ireturnval = 0
    ELSE
     CALL echo("***")
     CALL echo(build2("***      Delete Menu Program Item from Explorer Menu RemoveMenuItem (dId = ",
       trim(cnvtstring(did,17,0),3),")"))
     CALL echo("***")
     DELETE  FROM explorer_menu em
      WHERE em.menu_id=did
      WITH nocounter
     ;end delete
     IF (ierrcode > 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("SCRIPT ERROR: Deleting EXPLORER_MENU (menu_id = ",trim(
        cnvtstring(did,17,0),3),")")
      ROLLBACK
      SET ireturnval = 0
     ELSE
      COMMIT
      SET ireturnval = 1
     ENDIF
    ENDIF
   ENDIF
   CALL echo("***")
   CALL echo(build2("***   END - RemoveMenuItem (dId = ",trim(cnvtstring(did,17,0),3),
     ") - iReturnVal: ",trim(cnvtstring(ireturnval,17,0),3)))
   CALL echo("***")
   RETURN(ireturnval)
 END ;Subroutine
 SUBROUTINE inactivatemenuitem(did)
   CALL echo("***")
   CALL echo("***   InActivateMenuItem")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM explorer_menu em
    SET em.active_ind = 0, em.updt_dt_tm = cnvtdatetime(curdate,curtime3), em.updt_id = reqinfo->
     updt_id,
     em.updt_task = reqinfo->updt_task, em.updt_applctx = reqinfo->updt_applctx, em.updt_cnt = (em
     .updt_cnt+ 1)
    PLAN (em
     WHERE em.menu_id=did)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE findmenuid(ctype,did,cidx)
   CALL echo("***")
   CALL echo("***   FindMenuId")
   CALL echo("***")
   DECLARE vitemname = vc WITH protect, constant(trim(requestin->list_0[cidx].name,3))
   DECLARE vitemdesc = vc WITH protect, constant(trim(requestin->list_0[cidx].description,3))
   DECLARE cthetype = c1 WITH protect, noconstant(ctype)
   DECLARE dmenuid = f8 WITH protect, noconstant(0.0)
   IF (cthetype="S")
    SET cthetype = "M"
   ENDIF
   CALL echo("***")
   CALL echo(build2("***   cTheType: ",cthetype))
   CALL echo(build2("***   dId  : ",did))
   CALL echo(build2("***   cidx : ",cidx))
   CALL echo(build2("***   name : ",vitemname))
   CALL echo(build2("***   desc : ",vitemdesc))
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM explorer_menu em
    PLAN (em
     WHERE cnvtupper(em.item_name)=cnvtupper(vitemname)
      AND em.item_desc=vitemdesc
      AND em.item_type=cthetype
      AND em.menu_parent_id=did)
    DETAIL
     CALL echo("***"),
     CALL echo(build("***   menu_id :",em.menu_id)),
     CALL echo("***"),
     dmenuid = em.menu_id
     IF (em.active_ind=0)
      breactivatemenuitem = true
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    RETURN(- (1.0))
   ENDIF
   CALL echo("***")
   CALL echo(build2("***   dMenuId: ",dmenuid))
   CALL echo("***")
   RETURN(dmenuid)
 END ;Subroutine
#exit_script
 SET script_ver = "006 06/19/15 Copy of ams_ens_menu_items for readme"
END GO

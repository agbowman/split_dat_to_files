CREATE PROGRAM ams_get_toolkit_version:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
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
 RECORD ams_dminfo_reqd(
   1 allow_partial_ind = i2
   1 info_domainw = i2
   1 info_namew = i2
   1 qual[*]
     2 info_domain = c80
     2 info_name = c255
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
 DECLARE get_dminfo_number(sdomain,sname) = f8
 SUBROUTINE get_dminfo_number(sdomain,sname)
   DECLARE datgdminfovalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     datgdminfovalue = di.info_number
    WITH nocounter
   ;end select
   RETURN(datgdminfovalue)
 END ;Subroutine
 DECLARE get_dminfo_char(sdomain,sname) = c255
 SUBROUTINE get_dminfo_char(sdomain,sname)
   DECLARE satgdminfovalue = c255 WITH protect, noconstant("")
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     satgdminfovalue = di.info_char
    WITH nocounter
   ;end select
   RETURN(satgdminfovalue)
 END ;Subroutine
 DECLARE get_dminfo_date(sdomain,sname) = dq8
 SUBROUTINE get_dminfo_date(sdomain,sname)
   DECLARE dtatgdminfovalue = dq8 WITH protect, noconstant
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     dtatgdminfovalue = cnvtdatetime(di.info_date)
    WITH nocounter
   ;end select
   RETURN(dtatgdminfovalue)
 END ;Subroutine
 DECLARE get_dminfo_longid(sdomain,sname) = f8
 SUBROUTINE get_dminfo_longid(sdomain,sname)
   DECLARE datgdminfovalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     datgdminfovalue = di.info_long_id
    WITH nocounter
   ;end select
   RETURN(datgdminfovalue)
 END ;Subroutine
 SUBROUTINE set_dminfo_number(sdomain,sname,dvalue)
   CALL clear_dminfo(null)
   SELECT INTO "NL:"
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
    SET ams_dminfo_reqi->qual[1].info_number = dvalue
    SET ams_dminfo_reqi->info_domaini = 1
    SET ams_dminfo_reqi->info_namei = 1
    SET ams_dminfo_reqi->info_numberi = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQI"), replace("REPLY",
     "AMS_DMINFO_REP")
   ELSE
    SET stat = alterlist(ams_dminfo_reqw->qual,1)
    SET ams_dminfo_reqw->qual[1].info_domain = sdomain
    SET ams_dminfo_reqw->qual[1].info_name = sname
    SET ams_dminfo_reqw->qual[1].info_number = dvalue
    SET ams_dminfo_reqw->info_domainw = 1
    SET ams_dminfo_reqw->info_namew = 1
    SET ams_dminfo_reqw->info_numberf = 1
    SET ams_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQW"), replace("REPLY",
     "AMS_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE set_dminfo_date(sdomain,sname,dtvalue)
   CALL clear_dminfo(null)
   SELECT INTO "NL:"
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
    SET ams_dminfo_reqi->qual[1].info_date = cnvtdatetime(dtvalue)
    SET ams_dminfo_reqi->info_domaini = 1
    SET ams_dminfo_reqi->info_namei = 1
    SET ams_dminfo_reqi->info_datei = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQI"), replace("REPLY",
     "AMS_DMINFO_REP")
   ELSE
    SET stat = alterlist(ams_dminfo_reqw->qual,1)
    SET ams_dminfo_reqw->qual[1].info_domain = sdomain
    SET ams_dminfo_reqw->qual[1].info_name = sname
    SET ams_dminfo_reqw->qual[1].info_date = cnvtdatetime(dtvalue)
    SET ams_dminfo_reqw->info_domainw = 1
    SET ams_dminfo_reqw->info_namew = 1
    SET ams_dminfo_reqw->info_datef = 1
    SET ams_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQW"), replace("REPLY",
     "AMS_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE set_dminfo_char(sdomain,sname,svalue)
   CALL clear_dminfo(null)
   SELECT INTO "NL:"
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
    SET ams_dminfo_reqi->qual[1].info_char = svalue
    SET ams_dminfo_reqi->info_domaini = 1
    SET ams_dminfo_reqi->info_namei = 1
    SET ams_dminfo_reqi->info_chari = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQI"), replace("REPLY",
     "AMS_DMINFO_REP")
   ELSE
    SET stat = alterlist(ams_dminfo_reqw->qual,1)
    SET ams_dminfo_reqw->qual[1].info_domain = sdomain
    SET ams_dminfo_reqw->qual[1].info_name = sname
    SET ams_dminfo_reqw->qual[1].info_char = svalue
    SET ams_dminfo_reqw->info_domainw = 1
    SET ams_dminfo_reqw->info_namew = 1
    SET ams_dminfo_reqw->info_charf = 1
    SET ams_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQW"), replace("REPLY",
     "AMS_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE set_dminfo_longid(sdomain,sname,dvalue)
   CALL clear_dminfo(null)
   SELECT INTO "NL:"
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
    SET ams_dminfo_reqi->qual[1].info_long_id = dvalue
    SET ams_dminfo_reqi->info_domaini = 1
    SET ams_dminfo_reqi->info_namei = 1
    SET ams_dminfo_reqi->info_long_idi = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQI"), replace("REPLY",
     "AMS_DMINFO_REP")
   ELSE
    SET stat = alterlist(ams_dminfo_reqw->qual,1)
    SET ams_dminfo_reqw->qual[1].info_domain = sdomain
    SET ams_dminfo_reqw->qual[1].info_name = sname
    SET ams_dminfo_reqw->qual[1].info_long_id = dvalue
    SET ams_dminfo_reqw->info_domainw = 1
    SET ams_dminfo_reqw->info_namew = 1
    SET ams_dminfo_reqw->info_long_idf = 1
    SET ams_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQW"), replace("REPLY",
     "AMS_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE remove_dminfo(sdomain,sname)
   CALL clear_dminfo(null)
   SET stat = alterlist(ams_dminfo_reqd->qual,1)
   SET ams_dminfo_reqd->qual[1].info_domain = sdomain
   SET ams_dminfo_reqd->qual[1].info_name = sname
   SET ams_dminfo_reqd->info_domainw = 1
   SET ams_dminfo_reqd->info_namew = 1
   EXECUTE gm_d_dm_info2388  WITH replace("REQUEST","AMS_DMINFO_REQD"), replace("REPLY",
    "AMS_DMINFO_REP")
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE clear_dminfo(null)
   IF (currev=8)
    SET stat = initrec(ams_dminfo_reqi)
    SET stat = initrec(ams_dminfo_reqw)
    SET stat = initrec(ams_dminfo_reqd)
   ELSE
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
    SET stat = alterlist(ams_dminfo_reqd->qual,0)
    SET ams_dminfo_reqd->allow_partial_ind = 0
    SET ams_dminfo_reqd->info_domainw = 0
    SET ams_dminfo_reqd->info_namew = 0
   ENDIF
 END ;Subroutine
 DECLARE sversion = vc WITH protect, noconstant("")
 SET sversion = get_dminfo_char("AMS ToolKit","Version")
 IF (textlen(trim(sversion,3)) > 0)
  SET sversion = concat("AMS Toolkit Version: ",trim(sversion,3))
 ELSE
  SET sversion = "AMS Toolkit Version: Can Not Be Determined"
 ENDIF
 SELECT INTO value( $OUTDEV)
  FROM dummyt d
  DETAIL
   row + 3, col 10, sversion,
   row + 1
  WITH nocounter
 ;end select
#exit_script
 SET script_ver = "000 04/09/13 Initial Release"
END GO

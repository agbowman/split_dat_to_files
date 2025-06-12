CREATE PROGRAM da_copy_updt_omf_security:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Would you like to Grant or Copy security  settings ?" = 0,
  "Search user(s) to update security for:" = "",
  "Select a user to update :" = 0,
  "Search user to copy security from:" = "",
  "Select a user to copy securities from  :" = 0,
  "What security settings do you want to copy?" = 0,
  "Reporting Domain:" = 0,
  "Subject Area:" = 0
  WITH outdev, modtype, tolastname,
  selectedtouser, fromlastname, selectedfromuser,
  copymode, selecteddomainid, selectedgridcd
 DECLARE mtype = i2 WITH constant( $MODTYPE)
 DECLARE mfromuser = f8 WITH constant( $SELECTEDFROMUSER)
 DECLARE mdomainid = f8 WITH constant( $SELECTEDDOMAINID)
 DECLARE current_prsnl_id = f8 WITH noconstant(0.0)
 DECLARE strstatusmsg = vc WITH protect
 DECLARE strprogramstat = vc WITH protect
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE igetallusers = i4 WITH constant(1)
 DECLARE discern_analytics_admin = i4 WITH constant(956100), protect
 DECLARE happ = i4 WITH noconstant(0), protect
 DECLARE domainqual = vc
 DECLARE gridndx = i4 WITH noconstant(0)
 DECLARE paramndx = i4 WITH noconstant(0)
 DECLARE par = c20
 FREE RECORD i18n
 RECORD i18n(
   1 program_status = vc
   1 update_success = vc
   1 need_valid_login = vc
   1 app_not_auth = vc
   1 invalid_mode_param = vc
   1 invalid_touser_param = vc
   1 invalid_fromuser_param = vc
   1 invalid_subarea_param = vc
   1 952508_fail = vc
   1 952525_fail = vc
 )
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
 RECORD omf_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL doi18nonstrings(istat)
 SET current_prsnl_id = reqinfo->updt_id
 IF (current_prsnl_id <= 0)
  SET strstatusmsg = i18n->need_valid_login
  GO TO end_now
 ENDIF
 SET stat = uar_crmbeginapp(discern_analytics_admin,happ)
 IF (stat)
  SET strstatusmsg = i18n->app_not_auth
  GO TO end_now
 ENDIF
 SET strstatusmsg = i18n->update_success
 FREE SET copygrant_req
 RECORD copygrant_req(
   1 copyuserid = f8
   1 users[*]
     2 user_id = f8
   1 grids[*]
     2 grid_cd = f8
 )
 CASE (mtype)
  OF 1:
   IF (substring(1,1,reflect(parameter(parameter2( $SELECTEDTOUSER),0)))="L")
    SET paramndx = 1
    WHILE (paramndx > 0)
     SET par = reflect(parameter(parameter2( $SELECTEDTOUSER),paramndx))
     IF (par=" ")
      SET paramndx = 0
     ELSE
      SET stat = alterlist(copygrant_req->users,paramndx)
      SET copygrant_req->users[paramndx].user_id = parameter(parameter2( $SELECTEDTOUSER),paramndx)
      SET paramndx += 1
     ENDIF
    ENDWHILE
   ELSE
    IF (parameter(parameter2( $SELECTEDTOUSER),1) > 0)
     SET stat = alterlist(copygrant_req->users,1)
     SET copygrant_req->users[1].user_id = parameter(parameter2( $SELECTEDTOUSER),1)
    ELSE
     SET strstatusmsg = i18n->invalid_fromuser_param
     GO TO end_now
    ENDIF
   ENDIF
   IF (substring(1,1,reflect(parameter(parameter2( $SELECTEDGRIDCD),0)))="L")
    SET paramndx = 1
    WHILE (paramndx > 0)
     SET par = reflect(parameter(parameter2( $SELECTEDGRIDCD),paramndx))
     IF (par=" ")
      SET paramndx = 0
     ELSE
      SET stat = alterlist(copygrant_req->grids,paramndx)
      SET copygrant_req->grids[paramndx].grid_cd = parameter(parameter2( $SELECTEDGRIDCD),paramndx)
      SET paramndx += 1
     ENDIF
    ENDWHILE
   ELSE
    IF (parameter(parameter2( $SELECTEDGRIDCD),1)=0)
     SET strstatusmsg = i18n->invalid_subarea_param
     GO TO end_now
    ELSEIF ((parameter(parameter2( $SELECTEDGRIDCD),1)=- (999)))
     IF (mdomainid > 0)
      SET domainqual = concat(" og.grid_group_cd = ",build(mdomainid))
     ELSE
      SET domainqual = " 1=1"
     ENDIF
     SELECT INTO "nl:"
      og.grid_cd
      FROM omf_grid og
      WHERE og.grid_cd > 0
       AND og.active_ind=1
       AND parser(domainqual)
      HEAD REPORT
       gridndx = 0
      DETAIL
       gridndx += 1
       IF (mod(gridndx,10)=1)
        stat = alterlist(copygrant_req->grids,(gridndx+ 9))
       ENDIF
       copygrant_req->grids[gridndx].grid_cd = og.grid_cd
      FOOT REPORT
       stat = alterlist(copygrant_req->grids,gridndx)
      WITH nocounter
     ;end select
    ELSE
     SET stat = alterlist(copygrant_req->grids,1)
     SET copygrant_req->grids[1].grid_cd = parameter(parameter2( $SELECTEDGRIDCD),1)
    ENDIF
   ENDIF
   EXECUTE omf_ins_all_security_filter  WITH replace("REQUEST","COPYGRANT_REQ"), replace("REPLY",
    "OMF_REPLY")
   IF ((omf_reply->status_data.status="S"))
    SET strstatusmsg = i18n->update_success
    COMMIT
   ELSE
    SET strstatusmsg = i18n->952508_fail
   ENDIF
  OF 2:
   IF (mfromuser > 0)
    SET copygrant_req->copyuserid = mfromuser
   ELSE
    SET strstatusmsg = i18n->invalid_fromuser_param
    GO TO end_now
   ENDIF
   IF (substring(1,1,reflect(parameter(parameter2( $SELECTEDTOUSER),0)))="L")
    SET paramndx = 1
    WHILE (paramndx > 0)
     SET par = reflect(parameter(parameter2( $SELECTEDTOUSER),paramndx))
     IF (par=" ")
      SET paramndx = 0
     ELSE
      SET stat = alterlist(copygrant_req->users,paramndx)
      SET copygrant_req->users[paramndx].user_id = parameter(parameter2( $SELECTEDTOUSER),paramndx)
      SET paramndx += 1
     ENDIF
    ENDWHILE
   ELSE
    IF (parameter(parameter2( $SELECTEDTOUSER),1) > 0)
     SET stat = alterlist(copygrant_req->users,1)
     SET copygrant_req->users[1].user_id = parameter(parameter2( $SELECTEDTOUSER),1)
    ELSE
     SET strstatusmsg = i18n->invalid_fromuser_param
     GO TO end_now
    ENDIF
   ENDIF
   IF (parameter(parameter2( $COPYMODE),1)=2)
    IF (substring(1,1,reflect(parameter(parameter2( $SELECTEDGRIDCD),0)))="L")
     SET paramndx = 1
     WHILE (paramndx > 0)
      SET par = reflect(parameter(parameter2( $SELECTEDGRIDCD),paramndx))
      IF (par=" ")
       SET paramndx = 0
      ELSE
       SET stat = alterlist(copygrant_req->grids,paramndx)
       SET copygrant_req->grids[paramndx].grid_cd = parameter(parameter2( $SELECTEDGRIDCD),paramndx)
       SET paramndx += 1
      ENDIF
     ENDWHILE
    ELSE
     IF (parameter(parameter2( $SELECTEDGRIDCD),1)=0)
      SET strstatusmsg = i18n->invalid_subarea_param
      GO TO end_now
     ELSEIF ((parameter(parameter2( $SELECTEDGRIDCD),1)=- (999)))
      IF (mdomainid > 0)
       SET domainqual = concat(" og.grid_group_cd = ",build(mdomainid))
      ELSE
       SET domainqual = " 1=1"
      ENDIF
      SELECT INTO "nl:"
       og.grid_cd
       FROM omf_grid og
       WHERE og.grid_cd > 0
        AND og.active_ind=1
        AND parser(domainqual)
       HEAD REPORT
        gridndx = 0
       DETAIL
        gridndx += 1
        IF (mod(gridndx,10)=1)
         stat = alterlist(copygrant_req->grids,(gridndx+ 9))
        ENDIF
        copygrant_req->grids[gridndx].grid_cd = og.grid_cd
       FOOT REPORT
        stat = alterlist(copygrant_req->grids,gridndx)
       WITH nocounter
      ;end select
     ELSE
      SET stat = alterlist(copygrant_req->grids,1)
      SET copygrant_req->grids[1].grid_cd = parameter(parameter2( $SELECTEDGRIDCD),1)
     ENDIF
    ENDIF
   ELSE
    SELECT INTO "nl:"
     og.grid_cd
     FROM omf_grid og
     WHERE og.grid_cd > 0
      AND og.active_ind=1
     HEAD REPORT
      gridndx = 0
     DETAIL
      gridndx += 1
      IF (mod(gridndx,10)=1)
       stat = alterlist(copygrant_req->grids,(gridndx+ 9))
      ENDIF
      copygrant_req->grids[gridndx].grid_cd = og.grid_cd
     FOOT REPORT
      stat = alterlist(copygrant_req->grids,gridndx)
     WITH nocounter
    ;end select
   ENDIF
   EXECUTE omf_copy_all_grids  WITH replace("REQUEST","COPYGRANT_REQ"), replace("REPLY","OMF_REPLY")
   IF ((omf_reply->status_data.status="S"))
    SET strstatusmsg = i18n->update_success
    COMMIT
   ELSE
    SET strstatusmsg = i18n->952525_fail
   ENDIF
  ELSE
   SET strstatusmsg = i18n->invalid_mode_param
   GO TO end_now
 ENDCASE
 FREE RECORD copygrant_req
 FREE RECORD omf_reply
#end_now
 SET strprogramstat = i18n->program_status
 SELECT INTO  $OUTDEV
  HEAD REPORT
   row + 1, col 0, strprogramstat,
   row + 1
  FOOT REPORT
   col 4, strstatusmsg, row + 1
  WITH nocounter
 ;end select
 FREE RECORD i18n
 SUBROUTINE (doi18nonstrings(ndummyvar=i2(value)) =null)
   SET i18n->program_status = uar_i18ngetmessage(i18nhandle,"program_status","Program Status")
   SET i18n->update_success = uar_i18ngetmessage(i18nhandle,"update_success",
    "SUCCESS - Security settings successfully applied.")
   SET i18n->need_valid_login = uar_i18ngetmessage(i18nhandle,"need_valid_login",
    "FAILED - User must have valid login to run program.")
   SET i18n->app_not_auth = uar_i18ngetmessage(i18nhandle,"app_not_auth",
    "FAILED - User must have DiscernAnalytics Administrator access.")
   SET i18n->invalid_mode_param = uar_i18ngetmessage(i18nhandle,"invalid_mode_param",
    "FAILED - Please select a valid program mode (Copy or Grant).")
   SET i18n->invalid_touser_param = uar_i18ngetmessage(i18nhandle,"invalid_touser_param",
    "FAILED - Update user not selected.")
   SET i18n->invalid_fromuser_param = uar_i18ngetmessage(i18nhandle,"invalid_touser_param",
    "FAILED - 'Copy From' user not selected.")
   SET i18n->invalid_subarea_param = uar_i18ngetmessage(i18nhandle,"invalid_SubArea_param",
    "FAILED - Subject Area not selected.")
   SET i18n->952508_fail = uar_i18ngetmessage(i18nhandle,"952508_fail",
    "FAILED - A script error has occurred [OMF_INS_ALL_SECURITY_FILTER].")
   SET i18n->952525_fail = uar_i18ngetmessage(i18nhandle,"952525_fail",
    "FAILED - A script error has occurred [OMF_COPY_ALL_GRIDS].")
 END ;Subroutine
END GO

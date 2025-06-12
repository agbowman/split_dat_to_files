CREATE PROGRAM da_copy_saved_views:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Search for the user to copy views FROM (Last Name):" = "",
  "Select the User to copy FROM:" = 0,
  "Select the views to copy from:" = 0,
  "Search for the user to copy views TO (Last Name):" = "",
  "Select the User to copy TO:" = 0
  WITH outdev, copyfromuser, selectedfromuserid,
  selectedpvitems, copytouser, selectedtouserid
 DECLARE mfromuser = f8 WITH constant( $SELECTEDFROMUSERID)
 DECLARE mtouser = f8 WITH constant( $SELECTEDTOUSERID)
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
 DECLARE itemndx = i4 WITH noconstant(0)
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
   1 items[*]
     2 omf_pv_item_id = f8
     2 pv_item_name = vc
     2 schedule_copied_ind = i2
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
 FREE SET copypvitemreq
 RECORD copypvitemreq(
   1 items[*]
     2 omf_pv_item_id = f8
     2 pv_item_name = vc
     2 copy_to_pv_item_id = f8
     2 item_type_flag = i2
   1 copy_to_user_id = f8
   1 copy_to_group_id = f8
   1 copy_schedule_ind = i2
   1 copy_to_folder_id = f8
 )
 IF (substring(1,1,reflect(parameter(parameter2( $SELECTEDPVITEMS),0)))="L")
  SET paramndx = 1
  WHILE (paramndx > 0)
   SET par = reflect(parameter(parameter2( $SELECTEDPVITEMS),paramndx))
   IF (par=" ")
    SET paramndx = 0
   ELSE
    IF (parameter(parameter2( $SELECTEDPVITEMS),paramndx) > 0)
     SET stat = alterlist(copypvitemreq->items,paramndx)
     SET copypvitemreq->items[paramndx].omf_pv_item_id = parameter(parameter2( $SELECTEDPVITEMS),
      paramndx)
     SET paramndx += 1
    ENDIF
   ENDIF
  ENDWHILE
  SELECT INTO "nl:"
   FROM omf_pv_items opi,
    (dummyt d1  WITH seq = value(size(copypvitemreq->items,5)))
   PLAN (d1)
    JOIN (opi
    WHERE (opi.omf_pv_item_id=copypvitemreq->items[d1.seq].omf_pv_item_id))
   DETAIL
    copypvitemreq->items[d1.seq].pv_item_name = opi.pv_item_name
   WITH nocounter
  ;end select
  SET strstatusmsg = i18n->update_success
 ELSE
  IF (parameter(parameter2( $SELECTEDPVITEMS),1) > 0)
   SET stat = alterlist(copypvitemreq->items,1)
   SET copypvitemreq->items[1].omf_pv_item_id = parameter(parameter2( $SELECTEDPVITEMS),1)
  ELSEIF (parameter(parameter2( $SELECTEDPVITEMS),1) < 0)
   SET domainqual = concat(" opi.user_id = ",build(mfromuser))
   SELECT INTO "nl:"
    opi.omf_pv_item_id, opi.pv_item_name
    FROM omf_pv_items opi
    WHERE parser(domainqual)
     AND opi.item_type_flag=0
    ORDER BY opi.pv_item_name
    HEAD REPORT
     itemndx = 0
    DETAIL
     itemndx += 1
     IF (mod(itemndx,10)=1)
      stat = alterlist(copypvitemreq->items,(itemndx+ 9))
     ENDIF
     copypvitemreq->items[itemndx].omf_pv_item_id = opi.omf_pv_item_id, copypvitemreq->items[itemndx]
     .pv_item_name = opi.pv_item_name
    FOOT REPORT
     stat = alterlist(copypvitemreq->items,itemndx)
    WITH nocounter
   ;end select
  ELSE
   SET strstatusmsg = i18n->invalid_fromuser_param
   GO TO end_now
  ENDIF
 ENDIF
 IF (mfromuser > 0)
  SET copypvitemreq->copy_to_user_id = mtouser
  SET copypvitemreq->copy_schedule_ind = 1
 ENDIF
 EXECUTE omf_copy_pv_items  WITH replace("REQUEST","COPYPVITEMREQ"), replace("REPLY","OMF_REPLY")
 IF ((omf_reply->status_data.status="S"))
  SET strstatusmsg = i18n->update_success
  COMMIT
 ELSE
  SET strstatusmsg = i18n->952508_fail
 ENDIF
 FREE RECORD copypvitemreq
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
    "SUCCESS - Selected view(s) copied to user.")
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

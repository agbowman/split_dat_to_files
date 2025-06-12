CREATE PROGRAM auth_profile_manager:dba
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
 DECLARE hi18n = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE i18n_auth_profile_mgr_program_title = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_MGR_TITLE","Authorization Profile Manager"))
 DECLARE i18n_auth_profile_mgr_border_title = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_MGR_BORDER_TITLE","Enter profile information"))
 DECLARE i18n_auth_profile_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_TYPE","Profile Type = "))
 DECLARE i18n_auth_profile_existing_profile = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_EXISTING_PROFILE","Existing Profile user = "))
 DECLARE i18n_auth_profile_current_profile = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_CURRENT_PROFILE","Currently selected Profile user = "))
 DECLARE i18n_auth_profile_selected_profile = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_CURRENT_PROFILE","Profile user = "))
 DECLARE i18n_auth_profile_enter_profile_id = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_ENTER_PROFILE_ID","Enter auth profile personnel Id:"))
 DECLARE i18n_auth_profile_enter_profile_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_ENTER_PROFILE_TYPE","Enter Authorization Profile Type:"))
 DECLARE i18n_auth_profile_type_choices = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_TYPE_CHOICES","(1 - Patient User, 2 - External User, 3 - Direct Patient User)"))
 DECLARE i18n_auth_profile_attempt_another = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "ATTEMPT_ANOTHER_AUTH_PROFILE",
   "Would you like to attempt to enter the authorization profile again? (1 = YES, 0 = NO)"))
 DECLARE i18n_auth_profile_enter_another = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "ENTER_ANOTHER_AUTH_PROFILE","Enter another authorization profile?  (1 = YES, 0 = NO)"))
 DECLARE i18n_auth_profile_override_current_profile = vc WITH protect, constant(uar_i18ngetmessage(
   hi18n,"OVERRIDE_CURRENT_AUTH_PROFILE",
   "Would you like to override it with currently selected user? (1 = YES, 0 = NO)"))
 DECLARE i18n_auth_profile_saved_1 = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_SAVED_1","Authorization Profile for"))
 DECLARE i18n_auth_profile_saved_2 = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_SAVED_2","has been added to the database."))
 DECLARE i18n_auth_profile_not_added = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_SAVED_2","Authorization Profile was not added to the database."))
 DECLARE i18n_auth_profile_exists = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "AUTH_PROFILE_EXISTS","An authorization profile already exists for this type in your domain"))
 DECLARE i18n_auth_profile_invalid_profile_id = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "INVALID_AUTH_PROFILE_ENTERED",
   "The selected authorization profile person Id is not part of your logical domain or is invalid."))
 DECLARE patient_user = f8 WITH constant(uar_get_code_by("MEANING",4002675,"PATIENT")), protect
 DECLARE external_user = f8 WITH constant(uar_get_code_by("MEANING",4002675,"EXTERNAL")), protect
 DECLARE direct_patient_user = f8 WITH constant(uar_get_code_by("MEANING",4002675,"DRECTPTN")),
 protect
 DECLARE sauthprofileid = vc WITH noconstant("0")
 DECLARE sauthprofiletype = c1 WITH noconstant("1")
 DECLARE sauthprofiletypecd = f8 WITH noconstant(0.0)
 DECLARE selectedusernamefullformatted = vc
 DECLARE currentlogicaldomain = f8
 DECLARE displayauthprofileinfo = i2 WITH noconstant(1)
 DECLARE displayauthprofileinfo = i2
 DECLARE currentauthprofileusername = vc
 DECLARE profiletypeinputcursorposition = i2 WITH noconstant(0)
 DECLARE authprofileprompt(invalidauthprofile=i2) = i2
 DECLARE verifyauthprofileid(authprofileid=vc) = i2
 DECLARE saveauthprofile(null) = i2
 EXECUTE cclseclogin
 CALL authprofileprompt(false)
 SUBROUTINE authprofileprompt(invalidauthprofile)
   IF (invalidauthprofile=1)
    CALL clear(1,1)
    CALL text(3,4,i18n_auth_profile_invalid_profile_id)
    CALL text(4,4,i18n_auth_profile_attempt_another)
    CALL accept(4,92,"P(1);C","1"
     WHERE curaccept IN ("1", "0"))
    IF (curaccept IN ("0"))
     GO TO exit_script
    ENDIF
   ELSE
    SET sauthprofileid = "0"
   ENDIF
   CALL clear(1,1)
   CALL box(2,1,23,91)
   CALL text(1,25,i18n_auth_profile_mgr_program_title)
   CALL text(2,4,i18n_auth_profile_mgr_border_title)
   CALL text(5,4,i18n_auth_profile_enter_profile_type)
   CALL text(6,4,i18n_auth_profile_type_choices)
   SET profiletypeinputcursorposition = (textlen(i18n_auth_profile_enter_profile_type)+ 5)
   IF (profiletypeinputcursorposition < 91)
    CALL accept(5,profiletypeinputcursorposition,"n;c","1"
     WHERE curaccept IN ("1", "2", "3"))
   ELSE
    CALL accept(5,90,"n;c","1"
     WHERE curaccept IN ("1", "2", "3"))
   ENDIF
   SET sauthprofiletype = curaccept
   IF (sauthprofiletype="1")
    SET sauthprofiletypecd = patient_user
   ELSEIF (sauthprofiletype="2")
    SET sauthprofiletypecd = external_user
   ELSEIF (sauthprofiletype="3")
    SET sauthprofiletypecd = direct_patient_user
   ENDIF
   IF (sauthprofiletypecd <= 0)
    RETURN(false)
   ENDIF
   CALL text(8,4,i18n_auth_profile_enter_profile_id)
   CALL accept(8,48,"9(16);c","0")
   SET sauthprofileid = curaccept
   IF ( NOT (verifyauthprofileid(sauthprofileid)))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE verifyauthprofileid(authprofileid)
   SELECT INTO "NL:"
    FROM prsnl p
    WHERE p.person_id > 0.0
     AND p.person_id=cnvtreal(authprofileid)
     AND (p.logical_domain_id=
    (SELECT
     prsnl.logical_domain_id
     FROM prsnl prsnl
     WHERE (prsnl.person_id=reqinfo->updt_id)))
    DETAIL
     selectedusernamefullformatted = p.name_full_formatted, currentlogicaldomain = p
     .logical_domain_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF ( NOT (authprofileprompt(true)))
     RETURN(false)
    ENDIF
   ELSE
    IF ( NOT (saveauthprofile(null)))
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE saveauthprofile(null)
   SET displayauthprofileinfo = 1
   SELECT INTO "NL:"
    FROM authorization_profile ap,
     prsnl p
    PLAN (ap
     WHERE ap.profile_type_cd=sauthprofiletypecd
      AND ap.logical_domain_id=currentlogicaldomain)
     JOIN (p
     WHERE p.person_id=outerjoin(ap.profile_prsnl_id))
    DETAIL
     currentauthprofileusername = p.name_full_formatted
    WITH nocounter
   ;end select
   IF (curqual=1)
    CALL clear(1,1)
    CALL text(3,4,i18n_auth_profile_exists)
    CALL text(4,4,concat(i18n_auth_profile_type,uar_get_code_display(sauthprofiletypecd)))
    CALL text(5,4,concat(i18n_auth_profile_existing_profile,currentauthprofileusername))
    CALL text(7,4,concat(i18n_auth_profile_current_profile,selectedusernamefullformatted))
    CALL text(9,4,i18n_auth_profile_override_current_profile)
    CALL accept(9,85,"P(1);C","1"
     WHERE curaccept IN ("1", "0"))
    IF (curaccept IN ("1"))
     UPDATE  FROM authorization_profile ap
      SET ap.profile_prsnl_id = cnvtreal(sauthprofileid), ap.updt_cnt = (ap.updt_cnt+ 1), ap
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ap.updt_id = reqinfo->updt_id, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_task = reqinfo
       ->updt_task
      WHERE ap.profile_type_cd=sauthprofiletypecd
       AND ap.logical_domain_id=currentlogicaldomain
     ;end update
     SET displayauthprofileinfo = 1
    ELSE
     SET displayauthprofileinfo = 0
    ENDIF
   ELSE
    INSERT  FROM authorization_profile ap
     SET ap.authorization_profile_id = seq(reference_seq,nextval), ap.profile_prsnl_id = cnvtreal(
       sauthprofileid), ap.logical_domain_id = currentlogicaldomain,
      ap.profile_type_cd = sauthprofiletypecd, ap.updt_cnt = 1, ap.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      ap.updt_id = reqinfo->updt_id, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_task = reqinfo
      ->updt_task
    ;end insert
    SET displayauthprofileinfo = 1
   ENDIF
   IF (displayauthprofileinfo=1)
    CALL clear(1,1)
    CALL text(3,4,i18n_auth_profile_saved_1)
    CALL text(4,4,concat(i18n_auth_profile_type,uar_get_code_display(sauthprofiletypecd)))
    CALL text(5,4,concat(i18n_auth_profile_selected_profile,selectedusernamefullformatted))
    CALL text(6,4,i18n_auth_profile_saved_2)
    CALL text(9,4,i18n_auth_profile_enter_another)
    CALL accept(9,65,"P(1);C","1"
     WHERE curaccept IN ("1", "0"))
   ELSE
    CALL clear(1,1)
    CALL text(3,4,i18n_auth_profile_not_added)
    CALL text(9,4,i18n_auth_profile_enter_another)
    CALL accept(9,65,"P(1);C","1"
     WHERE curaccept IN ("1", "0"))
   ENDIF
   IF (curaccept IN ("1"))
    IF ( NOT (authprofileprompt(false)))
     RETURN(false)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_script
 COMMIT
 CALL clear(1,1)
END GO

CREATE PROGRAM advinterop_set_unknown_prnsl:dba
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
 DECLARE getcurrentlogicaldomain(null) = f8
 DECLARE getfullnamebypersonnelid(null) = null
 EXECUTE prefrtl
 SUBROUTINE (getcurrentpref(logical_domain_id=f8) =f8)
   DECLARE s_logical_domain_id = vc WITH constant(nullterm(cnvtstring(round(logical_domain_id,2),17,2
      )))
   DECLARE l_pref_stat = i4 WITH noconstant(0)
   DECLARE h_pref_dir = i4 WITH noconstant(0)
   DECLARE i_attrib_cnt = i4 WITH noconstant(0)
   DECLARE i_attrib = i4 WITH noconstant(0)
   DECLARE h_attrib = i4 WITH private, noconstant(0)
   DECLARE s_attrib_name = c255 WITH noconstant("")
   DECLARE i_entry_cnt = i4 WITH noconstant(0)
   DECLARE h_entry = i4 WITH private, noconstant(0)
   DECLARE i_len = i4 WITH noconstant(0)
   DECLARE n_pref_err = i4 WITH private, noconstant(0)
   DECLARE s_pref_err_msg = c255 WITH private, noconstant("")
   DECLARE s_unk_author_id = c10 WITH noconstant("")
   DECLARE d_unk_author_id = f8 WITH noconstant(- (1))
   SET h_pref_dir = uar_prefcreateinstance(18)
   IF (h_pref_dir > 0)
    SET l_pref_stat = uar_prefsetbasedn(h_pref_dir,nullterm(
      "prefcontext=logical domain,prefroot=prefroot"))
    SET l_pref_stat = uar_prefaddfilter(h_pref_dir,nullterm(concat("prefgroup=",s_logical_domain_id))
     )
    SET l_pref_stat = uar_prefaddfilter(h_pref_dir,nullterm("prefgroup=workflow"))
    SET l_pref_stat = uar_prefaddfilter(h_pref_dir,nullterm("prefgroup=advanced interoperability"))
    SET l_pref_stat = uar_prefaddfilter(h_pref_dir,nullterm("prefentry=unknown author prsnl_id"))
    SET l_pref_stat = uar_prefperform(h_pref_dir)
    IF (l_pref_stat=1)
     SET n_pref_err = uar_prefgetlasterror()
     SET i_entry_cnt = 0
     SET l_pref_stat = uar_prefgetentrycount(h_pref_dir,i_entry_cnt)
     SET h_entry = uar_prefgetentry(h_pref_dir,0)
     IF (h_entry > 0)
      SET i_attrib_cnt = 0
      SET l_pref_stat = uar_prefgetentryattrcount(h_entry,i_attrib_cnt)
      FOR (i_attrib = 0 TO (i_attrib_cnt - 1))
        SET h_attrib = uar_prefgetentryattr(h_entry,i_attrib)
        SET i_len = 255
        SET s_attrib_name = ""
        SET l_pref_stat = uar_prefgetattrname(h_attrib,s_attrib_name,i_len)
        IF (s_attrib_name="prefvalue")
         SET i_len = 19
         SET s_unk_author_id = ""
         SET l_pref_stat = uar_prefgetattrval(h_attrib,s_unk_author_id,i_len,0)
         SET d_unk_author_id = cnvtreal(trim(s_unk_author_id))
         SET i_attrib = i_attrib_cnt
        ENDIF
      ENDFOR
     ENDIF
    ELSE
     SET n_pref_err = uar_prefgetlasterror()
     SET l_pref_stat = uar_prefformatmessage(s_pref_err_msg,255)
    ENDIF
   ELSE
    SET n_pref_err = uar_prefgetlasterror()
    SET l_pref_stat = uar_prefformatmessage(s_pref_err_msg,255)
   ENDIF
   CALL uar_prefdestroyinstance(h_pref_dir)
   RETURN(d_unk_author_id)
 END ;Subroutine
 SUBROUTINE (updatepref(logical_domain_id=f8,new_unk_author_id=f8) =i2)
   DECLARE lprefstat = i4 WITH protect, noconstant(0)
   DECLARE lprefstat2 = i4 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE npreferr = i4 WITH protect, noconstant(0)
   DECLARE spreferrmsg = c255 WITH protect, noconstant("")
   SET hpref = uar_prefcreateinstance(1)
   SET lprefstat = uar_prefaddcontext(hpref,nullterm("logical domain"),nullterm(cnvtstring(round(
       logical_domain_id,2),17,2)))
   SET lprefstat = uar_prefsetsection(hpref,nullterm("workflow"))
   SET hgroup = uar_prefcreategroup()
   SET lprefstat = uar_prefsetgroupname(hgroup,nullterm("advanced interoperability"))
   SET lprefstat = uar_prefaddgroup(hpref,hgroup)
   SET hentry = uar_prefaddentrytogroup(hgroup,nullterm("unknown author prsnl_id"))
   SET hattr = uar_prefaddattrtoentry(hentry,nullterm("prefvalue"))
   SET lprefstat = uar_prefaddattrval(hattr,nullterm(cnvtstring(round(new_unk_author_id,2),17,2)))
   SET lprefstat = uar_prefperform(hpref)
   IF (lprefstat < 1)
    SET npreferr = uar_prefgetlasterror()
    CALL echo(build("Last error: ",npreferr))
    SET lprefstat2 = uar_prefformatmessage(spreferrmsg,255)
    CALL echo(build("PrefFormatMessage Status =",lprefstat2,", Message =",nullterm(spreferrmsg)))
   ENDIF
   SET lprefstat2 = uar_prefdestroyattr(hattr)
   SET lprefstat2 = uar_prefdestroyentry(hentry)
   SET lprefstat2 = uar_prefdestroygroup(hgroup)
   SET lprefstat2 = uar_prefdestroyinstance(hpref)
   IF (lprefstat < 1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE paratype = vc WITH constant(reflect(parameter(1,0)))
 DECLARE readcurconfigonlyparam = i2 WITH noconstant(parameter(2,0))
 DECLARE unk_prsnl_id = f8 WITH protect, noconstant(0)
 DECLARE prsnl_name_full_formatted = vc WITH protect, noconstant("")
 DECLARE promptmessage = vc WITH protect, noconstant("")
 DECLARE prsnl_active_ind = i2 WITH protect, noconstant(- (1))
 DECLARE prsnl_logical_domain_id = f8 WITH protect, noconstant(0.0)
 DECLARE current_logical_domain = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD reply(
   1 current_config_prsnl_id = f8
   1 updated_config_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((reqinfo->updt_id=0.0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18ngetmessage(i18nhandle,"LOG_IN",
   "ERROR: You must be logged into a secure CCL session to run this script (Use 'cclseclogin go').")
  GO TO exit_script
 ENDIF
 CALL getcurrentlogicaldomain(null)
 SET reply->current_config_prsnl_id = getcurrentpref(current_logical_domain)
 IF (readcurconfigonlyparam=1)
  CALL echo(uar_i18nbuildmessage(i18nhandle,"LOGICAL_DOMAIN_CUR_CONFIG_PRSNL_ID",
    "Advanced Interop Unknown Author Configuration for Logical Domain (%1): %2","ss",nullterm(trim(
      format(current_logical_domain,"################.##;I;F"),7)),
    nullterm(trim(format(reply->current_config_prsnl_id,"################.##;I;F"),7))))
  GO TO exit_script_without_message
 ENDIF
 IF (trim(paratype)="")
  CALL clear(1,1)
  CALL text(1,1,uar_i18nbuildmessage(i18nhandle,"LOGICAL_DOMAIN",
    "Advanced Interop Unknown Author Configuration for Logical Domain: %1","s",nullterm(trim(format(
       current_logical_domain,"################.##;I;F"),7))))
  CALL text(2,1,
   "================================================================================================="
   )
  CALL clear(3,1)
  SET promptmessage = uar_i18ngetmessage(i18nhandle,"PROMPT_UPDATE",
   "Enter the personnel id to use for items with no author and no authenticator, or 0 to exit: ")
  IF ((reply->current_config_prsnl_id < 0))
   CALL text(4,1,promptmessage)
   CALL accept(5,1,"N(19);C")
  ELSE
   CALL getfullnamebypersonnelid(null)
   IF (prsnl_name_full_formatted="")
    CALL text(4,1,uar_i18nbuildmessage(i18nhandle,"PERSONNEL",
      "Currently configured personnel id: %1.","s",nullterm(trim(format(reply->
         current_config_prsnl_id,"################.##;I;F"),7))))
   ELSE
    CALL text(4,1,uar_i18nbuildmessage(i18nhandle,"PERSONNEL_WITH_NAME",
      "Currently configured personnel id: %1 (%2).","ss",nullterm(trim(format(reply->
         current_config_prsnl_id,"################.##;I;F"),7)),
      nullterm(prsnl_name_full_formatted)))
   ENDIF
   CALL text(6,1,promptmessage)
   CALL accept(7,1,"N(19);C")
  ENDIF
  CALL text(8,1,"")
  SET unk_prsnl_id = cnvtreal(curaccept)
 ELSE
  IF (substring(1,1,paratype)="C")
   SET unk_prsnl_id = cnvtreal(parameter(1,0))
  ELSE
   IF (substring(1,1,paratype)="F")
    SET unk_prsnl_id = parameter(1,0)
   ENDIF
  ENDIF
 ENDIF
 IF (unk_prsnl_id=0.0)
  SET reply->status_data.status = "S"
  GO TO exit_script_without_message
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr
  WHERE pr.person_id=unk_prsnl_id
  DETAIL
   prsnl_name_full_formatted = pr.name_full_formatted, prsnl_active_ind = pr.active_ind,
   prsnl_logical_domain_id = pr.logical_domain_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(i18nhandle,
   "PRSNL_NOT_FOUND","ERROR: Input prsnl_id (%1) cannot be found on PRSNL table.","s",nullterm(trim(
     format(unk_prsnl_id,"################.##;I;F"),7)))
  GO TO exit_script
 ENDIF
 IF (prsnl_active_ind < 1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(i18nhandle,
   "PRSNL_NOT_ACTIVE","ERROR: Input prsnl_id (%1) is not active.","s",nullterm(trim(format(
      unk_prsnl_id,"################.##;I;F"),7)))
  GO TO exit_script
 ENDIF
 IF (prsnl_logical_domain_id != current_logical_domain)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(i18nhandle,
   "NOT_SAME_LOGICAL_DOMAIN",
   "ERROR: Input prsnl_id (%1) is not valid for current logical domain %2.","ss",nullterm(trim(
     format(unk_prsnl_id,"################.##;I;F"),7)),
   nullterm(trim(format(current_logical_domain,"################.##;I;F"),7)))
  GO TO exit_script
 ENDIF
 SET stat = updatepref(current_logical_domain,unk_prsnl_id)
 IF (stat=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18ngetmessage(i18nhandle,
   "FAIL_UPDATE_CONFIG","ERROR: Failed to update the desired configuration.")
  GO TO exit_script
 ENDIF
 SET reply->updated_config_prsnl_id = unk_prsnl_id
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(i18nhandle,
  "SUCCESS",
  "Success: %1 (%2) set as the personnel id to use for Advanced Interop items with no author and no authenticator.",
  "ss",nullterm(trim(format(unk_prsnl_id,"################.##;I;F"),7)),
  nullterm(prsnl_name_full_formatted))
 SUBROUTINE getcurrentlogicaldomain(null)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     current_logical_domain = p.logical_domain_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getfullnamebypersonnelid(null)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reply->current_config_prsnl_id)
    DETAIL
     prsnl_name_full_formatted = p.name_full_formatted
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 CALL echo("")
 CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 CALL echo("")
#exit_script_without_message
 IF ((reply->status_data.status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO

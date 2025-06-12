CREATE PROGRAM cv_get_prefs:dba
 SET modify = predeclare
 DECLARE lccl_error_resource_busy = i4 WITH protect, constant(290)
 DECLARE errorsublastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE errorsubmoddate = c30 WITH private, noconstant(fillstring(30," "))
 SUBROUTINE (checkerrorccl(p_sstatus=c1,p_sopname=vc,p_sopstatus=vc,p_stargetobjname=vc) =i2)
   DECLARE berrorsfound = i2 WITH private, noconstant(false)
   DECLARE lerrcodeccl = i4 WITH private, noconstant(0)
   DECLARE serrmsgccl = vc WITH private, noconstant("")
   DECLARE lerrcnt = i4 WITH private, noconstant(0)
   SET lerrcodeccl = error(serrmsgccl,0)
   IF (lerrcodeccl > 0)
    WHILE (lerrcodeccl > 0
     AND lerrcnt < 10)
      SET lerrcnt += 1
      IF (lerrcodeccl != lccl_error_resource_busy)
       SET berrorsfound = true
       CALL addstatusblock(p_sstatus,p_sopname,p_sopstatus,p_stargetobjname,serrmsgccl)
      ENDIF
      SET lerrcodeccl = error(serrmsgccl,0)
    ENDWHILE
   ENDIF
   IF (berrorsfound=true)
    EXECUTE goto exit_script
   ENDIF
   RETURN(berrorsfound)
 END ;Subroutine
 SUBROUTINE (addstatusblock(p_sstatus=c1,p_sopname=vc,p_sopstatus=vc,p_stargetobjname=vc,
  p_stargetobjvalue=vc) =null)
   DECLARE lsubeventcnt = i4 WITH private, noconstant(0)
   IF (p_sstatus > "")
    SET reply->status_data.status = p_sstatus
   ENDIF
   SET lsubeventcnt = alterstatusblock(1)
   IF (gnprefdebuglevel >= gnpref_debug_echo)
    CALL echo(build2("In AddStatusBlock with size(reply->status_data.SubEventStatus,5) = ",size(reply
       ->status_data.subeventstatus,5)," Updating entry number ",lsubeventcnt))
   ENDIF
   SET reply->status_data.subeventstatus[lsubeventcnt].operationname = p_sopname
   SET reply->status_data.subeventstatus[lsubeventcnt].operationstatus = p_sopstatus
   SET reply->status_data.subeventstatus[lsubeventcnt].targetobjectname = p_stargetobjname
   SET reply->status_data.subeventstatus[lsubeventcnt].targetobjectvalue = p_stargetobjvalue
   IF ((reply->status_data.status="F"))
    SET bscriptfailed = true
   ENDIF
   RETURN(lsubeventcnt)
 END ;Subroutine
 SUBROUTINE (alterstatusblock(p_ndummyvariable=i2) =i4)
   DECLARE lsubeventcnt = i4 WITH private, noconstant(0)
   DECLARE lsubeventstat = i4 WITH private, noconstant(0)
   IF (size(reply->status_data.subeventstatus,5)=1
    AND size(trim(reply->status_data.subeventstatus[1].operationstatus,3))=0)
    SET lsubeventcnt = 1
   ELSE
    SET lsubeventcnt = (size(reply->status_data.subeventstatus,5)+ 1)
    SET lsubeventstat = alterlist(reply->status_data.subeventstatus,lsubeventcnt)
   ENDIF
   RETURN(lsubeventcnt)
 END ;Subroutine
 DECLARE lerrcodeccl = i4 WITH private, noconstant(0)
 DECLARE serrmsgccl = vc WITH private, noconstant("")
 SET lerrcodeccl = error(serrmsgccl,1)
 SET errorsubmoddate = "December 10, 2003"
 SET errorsublastmod = "000"
 IF (validate(gbpref_global_included,false)=true)
  GO TO fn_pref_global_subs
 ENDIF
 DECLARE gbpref_global_included = i2 WITH public, constant(true)
 DECLARE glpref_err_zero_entries = i4 WITH public, constant(5022)
 DECLARE gnpref_len = i2 WITH public, constant(1024)
 EXECUTE prefrtl
 DECLARE gnpref_debug_off = i2 WITH public, constant(0)
 DECLARE gnpref_debug_echo = i2 WITH public, constant(3)
 DECLARE gnpref_debug_echo_record = i2 WITH public, constant(4)
 IF (validate(gnprefdebuglevel,99)=99)
  DECLARE gnprefdebuglevel = i2 WITH public, noconstant(gnpref_debug_off)
 ENDIF
 DECLARE glpref_trans_get = i4 WITH public, constant(0)
 DECLARE glpref_trans_update = i4 WITH public, constant(1)
 DECLARE glpref_trans_delete = i4 WITH public, constant(2)
 DECLARE glpref_trans_getcontext = i4 WITH public, constant(3)
 DECLARE glpref_trans_getcontextid = i4 WITH public, constant(4)
 DECLARE glpref_trans_getsection = i4 WITH public, constant(5)
 DECLARE glpref_trans_getsectionid = i4 WITH public, constant(6)
 DECLARE glpref_trans_getgroup = i4 WITH public, constant(7)
 DECLARE glpref_trans_customcontextids = i4 WITH public, constant(8)
 DECLARE glpref_trans_import = i4 WITH public, constant(9)
 DECLARE glpref_trans_updatecontext = i4 WITH public, constant(10)
 DECLARE glpref_trans_updatecontextid = i4 WITH public, constant(11)
 DECLARE glpref_trans_updatesection = i4 WITH public, constant(12)
 DECLARE glpref_trans_updatesectionid = i4 WITH public, constant(13)
 DECLARE glpref_trans_delcontext = i4 WITH public, constant(14)
 DECLARE glpref_trans_delcontextid = i4 WITH public, constant(15)
 DECLARE glpref_trans_delsection = i4 WITH public, constant(16)
 DECLARE glpref_trans_delsectionid = i4 WITH public, constant(17)
 DECLARE glpref_trans_customsearch = i4 WITH public, constant(18)
 DECLARE glpref_trans_deletedn = i4 WITH public, constant(19)
 DECLARE glpreflasterrcode = i4 WITH public, noconstant(0)
 DECLARE gspreflasterrmsg = vc WITH public, noconstant("")
 DECLARE prefgloballastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE prefglobalmoddate = c30 WITH private, noconstant(fillstring(30," "))
#fn_pref_global_subs
 SUBROUTINE (getprefmsgidtext(p_lprefmsgid=i4) =vc)
   DECLARE sprefmsgidtext = vc WITH private, noconstant("")
   CASE (p_lprefmsgid)
    OF glpref_trans_get:
     SET sprefmsgidtext = "GET"
    OF glpref_trans_update:
     SET sprefmsgidtext = "UPDATE"
    OF glpref_trans_delete:
     SET sprefmsgidtext = "DELETE"
    OF glpref_trans_getcontext:
     SET sprefmsgidtext = "GET CONTEXT"
    OF glpref_trans_getcontextid:
     SET sprefmsgidtext = "GET CONTEXT ID"
    OF glpref_trans_getsection:
     SET sprefmsgidtext = "GETS ECTION"
    OF glpref_trans_getsectionid:
     SET sprefmsgidtext = "GET SECTION ID"
    OF glpref_trans_getgroup:
     SET sprefmsgidtext = "GET GROUP"
    OF glpref_trans_customcontextids:
     SET sprefmsgidtext = "CUSTOM CONTEXT IDS"
    OF glpref_trans_import:
     SET sprefmsgidtext = "IMPORT"
    OF glpref_trans_updatecontext:
     SET sprefmsgidtext = "UPDATE CONTEXT"
    OF glpref_trans_updatecontextid:
     SET sprefmsgidtext = "UPDATE CONTEXT ID"
    OF glpref_trans_updatesection:
     SET sprefmsgidtext = "UPDATE SECTION"
    OF glpref_trans_updatesectionid:
     SET sprefmsgidtext = "UPDATE SECTION ID"
    OF glpref_trans_delcontext:
     SET sprefmsgidtext = "DELETE CONTEXT"
    OF glpref_trans_delcontextid:
     SET sprefmsgidtext = "DELETE CONTEXT ID"
    OF glpref_trans_delsection:
     SET sprefmsgidtext = "DELETE SECTION"
    OF glpref_trans_delsectionid:
     SET sprefmsgidtext = "DELETE SECTION ID"
    OF glpref_trans_customsearch:
     SET sprefmsgidtext = "CUSTOM SEARCH"
    OF glpref_trans_deletedn:
     SET sprefmsgidtext = "DELETE DN"
    ELSE
     SET sprefmsgidtext = "INVALID OPERATION"
   ENDCASE
   RETURN(sprefmsgidtext)
 END ;Subroutine
 SUBROUTINE (logprefresult(p_bprefstat=i4,p_soperation=vc,p_sopvalues=vc) =null)
   DECLARE lpreferrcode = i4 WITH private, noconstant(0)
   DECLARE lpreferrstat = i4 WITH private, noconstant(0)
   DECLARE sprefstattext = vc WITH private, noconstant("")
   DECLARE spreferrmsg = vc WITH private, noconstant(" ")
   CASE (p_bprefstat)
    OF true:
     SET sprefstattext = "SUCCESS"
    OF false:
     SET sprefstattext = "FAILED"
   ENDCASE
   IF (((p_bprefstat=false) OR (gnprefdebuglevel >= gnpref_debug_echo)) )
    CALL echo(concat("..",p_soperation," ",sprefstattext,", ",
      p_sopvalues))
    IF (p_bprefstat=false)
     SET lpreferrcode = uar_prefgetlasterror()
     CALL echo(build("...:PrefGetLastError =",lpreferrcode,", PrefFormatMessage =",spreferrmsg,
       "(PrefFormatMessage Status =",
       lpreferrstat,")"))
     SET glpreflasterrcode = lpreferrcode
     SET gspreflasterrmsg = trim(spreferrmsg,3)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (prefcreateinstance(p_lprefmsgid=i4,pr_hpref=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefmsgidtext = vc WITH private, noconstant("")
   SET pr_hpref = 0
   SET sprefmsgidtext = getprefmsgidtext(p_lprefmsgid)
   SET pr_hpref = uar_prefcreateinstance(p_lprefmsgid)
   IF (pr_hpref > 0)
    SET bprefstat = true
   ENDIF
   CALL logprefresult(bprefstat,build("PrefCreateInstance (",sprefmsgidtext,")"),build("hPref =",
     pr_hpref))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error creating Preference Service instance (PrefCreateInstance FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefaddattr(p_hpref=i4,p_sattrname=vc,pr_hattr=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   SET pr_hattr = 0
   IF (size(trim(p_sattrname,3)) > 0)
    SET pr_hattr = uar_prefaddattr(p_hpref,nullterm(p_sattrname))
    IF (pr_hattr > 0)
     SET bprefstat = true
    ENDIF
   ENDIF
   CALL logprefresult(bprefstat,"PrefAddAttr",build("hPref =",p_hpref,", sAttrName =",p_sattrname,
     ", hAttr =",
     pr_hattr))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error adding Attribute for Preference Service request (PrefAddAttr FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefaddcontext(p_hpref=i4,p_scontextname=vc,p_scontextid=vc) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   IF (size(trim(p_scontextname,3)) > 0
    AND size(trim(p_scontextid,3)) > 0)
    SET bprefstat = uar_prefaddcontext(p_hpref,nullterm(p_scontextname),nullterm(p_scontextid))
   ENDIF
   CALL logprefresult(bprefstat,"PrefAddContext",build("hPref =",p_hpref,", sContextName =",
     p_scontextname,", sContextId =",
     p_scontextid))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error adding Context for Preference Service request (PrefAddContext FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefsetsection(p_hpref=i4,p_ssectionname=vc) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   IF (size(trim(p_ssectionname,3)) > 0)
    SET bprefstat = uar_prefsetsection(p_hpref,nullterm(p_ssectionname))
   ENDIF
   CALL logprefresult(bprefstat,"PrefSetSection",build("hPref =",p_hpref,", sSectionName =",
     p_ssectionname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error setting Section Name for Preference Service request (PrefSetSection FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefsetsectionid(p_hpref=i4,p_ssectionid=vc) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   CALL echo(build2("setting pref section id ",p_ssectionid))
   IF (size(trim(p_ssectionid,3)) > 0)
    SET bprefstat = uar_prefsetsectionid(p_hpref,nullterm(p_ssectionid))
   ENDIF
   CALL echo(build2("done setting pref section id ",p_ssectionid))
   CALL logprefresult(bprefstat,"PrefSetSectionId",build("hPref =",p_hpref,", sSectionId =",
     p_ssectionid))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error setting Section Id for Preference Service request (PrefSetSectionId FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefcreategroup(p_hpref=i4,pr_hgroup=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   SET pr_hgroup = 0
   SET pr_hgroup = uar_prefcreategroup()
   IF (pr_hgroup > 0)
    SET bprefstat = true
   ENDIF
   CALL logprefresult(bprefstat,"PrefCreateGroup",build("hPref =",p_hpref,", hGroup =",pr_hgroup))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error creating group for Preference Service request (PrefCreateGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefsetgroupname(p_hgroup=i4,p_sgroupname=vc) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   IF (size(trim(p_sgroupname,3)) > 0)
    SET bprefstat = uar_prefsetgroupname(p_hgroup,nullterm(p_sgroupname))
   ENDIF
   CALL logprefresult(bprefstat,"PrefSetGroupName",build("hGroup = ",p_hgroup,", sGroupName =",
     p_sgroupname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error setting Group Name for Preference Service request (PrefSetGroupName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefaddgroup(p_hpref=i4,p_hgroup=i4) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   SET bprefstat = uar_prefaddgroup(p_hpref,p_hgroup)
   CALL logprefresult(bprefstat,"PrefAddGroup",build("hPref =",p_hpref,", hGroup =",p_hgroup))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error adding Group for Preference Service request (PrefAddGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefaddsubgroup(p_hgroup=i4,pr_hsubgroup=i4(ref),p_ssubgroupname=vc) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   SET pr_hsubgroup = 0
   IF (size(trim(p_ssubgroupname,3)) > 0)
    SET pr_hsubgroup = uar_prefaddsubgroup(p_hgroup,nullterm(p_ssubgroupname))
    IF (pr_hsubgroup > 0)
     SET bprefstat = true
    ENDIF
   ENDIF
   CALL logprefresult(bprefstat,"PrefAddSubGroup",build("hGroup =",p_hgroup,", hSubGroup =",
     pr_hsubgroup,", sSubGroupName =",
     p_ssubgroupname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error adding SubGroup for Preference Service request (PrefAddSubGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefaddentrytogroup(p_hgroup=i4,pr_hentry=i4(ref),p_sentryname=vc) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   SET pr_hentry = 0
   IF (size(trim(p_sentryname,3)) > 0)
    SET pr_hentry = uar_prefaddentrytogroup(p_hgroup,nullterm(p_sentryname))
    IF (pr_hentry > 0)
     SET bprefstat = true
    ENDIF
   ENDIF
   CALL logprefresult(bprefstat,"PrefAddEntryToGroup",build("hGroup =",p_hgroup,", hEntry =",
     pr_hentry,", sEntryName =",
     p_sentryname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error adding Entry to Group for Preference Service request (PrefAddEntryToGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefperform(p_hpref=i4,p_lprefmsgid=i4) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefmsgidtext = vc WITH private, noconstant("")
   SET sprefmsgidtext = getprefmsgidtext(p_lprefmsgid)
   SET bprefstat = uar_prefperform(p_hpref)
   IF (bprefstat=false
    AND p_lprefmsgid=glpref_trans_get)
    IF (uar_prefgetlasterror()=glpref_err_zero_entries)
     SET bprefstat = true
    ENDIF
   ENDIF
   CALL logprefresult(bprefstat,build("PrefPerform (",sprefmsgidtext,")"),build("hPref =",p_hpref))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error executing Preference Service query (PrefPerform FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefdestroyattr(pr_hattr=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hattrlog = i4 WITH private, noconstant(0)
   IF (pr_hattr > 0)
    SET hattrlog = pr_hattr
    CALL uar_prefdestroyattr(pr_hattr)
    SET bprefstat = true
    SET pr_hattr = 0
    CALL logprefresult(bprefstat,"PrefDestroyAttr",build("hAttr =",hattrlog))
   ELSE
    SET bprefstat = true
   ENDIF
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error destroying Attr for Preference Service request (PrefDestroyAttr FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefdestroyentry(pr_hentry=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hentrylog = i4 WITH private, noconstant(0)
   IF (pr_hentry > 0)
    SET hentrylog = pr_hentry
    CALL uar_prefdestroyentry(pr_hentry)
    SET bprefstat = true
    SET pr_hentry = 0
    CALL logprefresult(bprefstat,"PrefDestroyEntry",build("hEntry =",hentrylog))
   ELSE
    SET bprefstat = true
   ENDIF
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error destroying Entry for Preference Service request (PrefDestroyEntry FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefdestroygroup(pr_hgroup=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgrouplog = i4 WITH private, noconstant(0)
   IF (pr_hgroup > 0)
    SET hgrouplog = pr_hgroup
    IF (uar_prefdestroygroup(pr_hgroup)=true)
     SET bprefstat = true
    ENDIF
    SET pr_hgroup = 0
    CALL logprefresult(bprefstat,"PrefDestroyGroup",build("hGroup =",hgrouplog))
   ELSE
    SET bprefstat = true
   ENDIF
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error destroying Group for Preference Service request (PrefDestroyGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefdestroysection(pr_hsection=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hsectionlog = i4 WITH private, noconstant(0)
   IF (pr_hsection > 0)
    SET hsectionlog = pr_hsection
    IF (uar_prefdestroysection(pr_hsection)=true)
     SET bprefstat = true
     SET pr_hsection = 0
    ENDIF
    CALL logprefresult(bprefstat,"PrefDestroySection",build("hSection =",hsectionlog))
   ELSE
    SET bprefstat = true
   ENDIF
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error destroying Section for Preference Service request (PrefDestroySection FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefdestroyinstance(pr_hpref=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hpreflog = i4 WITH private, noconstant(0)
   IF (pr_hpref > 0)
    SET hpreflog = pr_hpref
    IF (uar_prefdestroyinstance(pr_hpref)=true)
     SET bprefstat = true
    ENDIF
    SET pr_hpref = 0
    CALL logprefresult(bprefstat,"PrefDestroyInstance",build("hPref =",hpreflog))
   ELSE
    SET bprefstat = true
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
#exit_fn_pref_global
 SET prefglobalmoddate = "March 23, 2004"
 SET prefgloballastmod = "001"
 IF (validate(gbpref_parse_included,false)=true)
  GO TO fn_pref_parse_subs
 ENDIF
 RECORD requestentries(
   1 entries[*]
     2 entryname = vc
 ) WITH protect
 DECLARE gbpref_parse_included = i2 WITH public, constant(true)
 DECLARE prefparselastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE prefparsemoddate = c30 WITH private, noconstant(fillstring(30," "))
#fn_pref_parse_subs
 SUBROUTINE (parseprefs(p_hpref=i4,pr_lprefentriesfound=i4(ref)) =i2)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE berrorfound = i2 WITH private, noconstant(false)
   SET pr_lprefentriesfound = 0
   IF (prefgetsectionbyname(p_hpref,ssectionnametoget,hsection)=false)
    RETURN(false)
   ENDIF
   IF (prefgetgroupbyname(hsection,ssectionidtoget,hgroup)=false)
    CALL prefdestroysection(hsection)
    RETURN(false)
   ENDIF
   SET bprefstat = parsegroup(hgroup,"",pr_lprefentriesfound)
   IF (prefdestroygroup(hgroup)=false)
    SET bprefstat = false
   ENDIF
   IF (prefdestroysection(hsection)=false)
    SET bprefstat = false
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (parsegroup(p_hgroup=i4,p_parentgroupname=vc,pr_lprefentriesfound=i4(ref)) =i2)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE nsubgroupcnt = i4 WITH protect, noconstant(0)
   DECLARE ngroupentrycnt = i2 WITH protect, noconstant(0)
   DECLARE lreplygroupcnt = i4 WITH protect, noconstant(0)
   DECLARE lprefentriesfound = i4 WITH protect, noconstant(0)
   DECLARE sgroupname = c1024 WITH protect, noconstant("")
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE bgetentrystat = i2 WITH private, noconstant(false)
   DECLARE berrorfound = i2 WITH private, noconstant(false)
   DECLARE nstat = i2 WITH private, noconstant(0)
   DECLARE nsubgroupidx = i2 WITH private, noconstant(0)
   DECLARE lreqgroupidxtouse = i4 WITH private, noconstant(0)
   DECLARE lreqgroupcnt = i4 WITH private, noconstant(0)
   DECLARE lreqgroupidx = i4 WITH private, noconstant(0)
   DECLARE lreqentryidx = i4 WITH private, noconstant(0)
   DECLARE lreqentrycnt = i4 WITH private, noconstant(0)
   DECLARE ltotalprefentriesfound = i4 WITH private, noconstant(0)
   DECLARE ngroupcnt = i2 WITH protect, noconstant(0)
   IF (gnprefdebuglevel >= gnpref_debug_echo)
    CALL echo(build2("parsing parent group ",p_hgroup,": ",trim(p_parentgroupname)))
   ENDIF
   SET bprefstat = prefgetgroupname(p_hgroup,sgroupname)
   IF (bprefstat=true)
    SET sgroupname = trim(cnvtlower(sgroupname),3)
    IF (p_parentgroupname > ""
     AND sgroupname > "")
     SET sgroupname = build(p_parentgroupname,"/",sgroupname)
    ELSE
     SET sgroupname = build(ssectionnametoget,"/",sgroupname)
    ENDIF
    IF (((srequestedpath=srequestedsection) OR (((sgroupname=srequestedpath) OR ((request->recurse=1)
     AND sgroupname=patstring(concat(srequestedpath,"*")))) )) )
     SET ngroupcnt = (1+ size(reply->group,5))
     SET nstat = alterlist(reply->group,ngroupcnt)
     SET reply->group[ngroupcnt].groupname = sgroupname
     IF (gnprefdebuglevel >= gnpref_debug_echo)
      CALL echo(build2("about to call RetrieveEntries ",p_hgroup,": ",trim(p_parentgroupname)))
     ENDIF
     SET bprefstat = retrieveentries(p_hgroup,ngroupcnt,lprefentriesfound)
     SET ltotalprefentriesfound += lprefentriesfound
    ENDIF
   ENDIF
   IF (((sgroupname != srequestedpath) OR ((request->recurse=1))) )
    IF (gnprefdebuglevel >= gnpref_debug_echo)
     CALL echo(build2("about to recurse. sGroupName = ",sgroupname," request->recurse = ",request->
       recurse))
    ENDIF
    IF (prefgetsubgroupcount(p_hgroup,nsubgroupcnt)=false)
     RETURN(false)
    ENDIF
    FOR (nsubgroupidx = 1 TO nsubgroupcnt)
      IF (bprefstat=true
       AND prefgetsubgroup(p_hgroup,(nsubgroupidx - 1),hsubgroup)=true)
       IF (hsubgroup > 0)
        SET bprefstat = parsegroup(hsubgroup,sgroupname,lprefentriesfound)
        SET ltotalprefentriesfound += lprefentriesfound
        IF (prefdestroygroup(hsubgroup)=false)
         SET bprefstat = false
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET pr_lprefentriesfound += ltotalprefentriesfound
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (retrieveentries(p_hgroup=i4,p_lreplygroupindex=i4,pr_lprefentriesfound=i4(ref)) =i2)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE hentryattr = i4 WITH protect, noconstant(0)
   DECLARE nentryattrcnt = i2 WITH protect, noconstant(0)
   DECLARE nattrvalcnt = i2 WITH protect, noconstant(0)
   DECLARE nentrycnt = i2 WITH protect, noconstant(0)
   DECLARE sentryname = c1024 WITH protect, noconstant("")
   DECLARE sattrvalue = vc WITH protect, noconstant("")
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE berrorfound = i2 WITH private, noconstant(false)
   DECLARE bretrieveentry = i2 WITH private, noconstant(false)
   DECLARE nentrystat = i2 WITH private, noconstant(0)
   DECLARE ngroupentryidx = i2 WITH private, noconstant(0)
   DECLARE nattrvalidx = i2 WITH private, noconstant(0)
   DECLARE lreqentryidx = i4 WITH private, noconstant(0)
   DECLARE lreqentrycnt = i4 WITH private, noconstant(0)
   DECLARE lprefentriescnt = i4 WITH private, noconstant(0)
   IF (gnprefdebuglevel >= gnpref_debug_echo)
    CALL echo(build2("Entering RetrieveEntries(",p_hgroup,", ",p_lreplygroupindex,")"))
   ENDIF
   IF (prefgetgroupentrycount(p_hgroup,nentrycnt)=true)
    IF (gnprefdebuglevel >= gnpref_debug_echo)
     CALL echo(build2(nentrycnt," entries retrieved for group ",trim(reply->group[p_lreplygroupindex]
        .groupname)))
    ENDIF
   ENDIF
   SET pr_lprefentriesfound = 0
   SET nentrystat = alterlist(reply->group[p_lreplygroupindex].entry,nentrycnt)
   FOR (ngroupentryidx = 1 TO nentrycnt)
    IF (prefgetgroupentry(p_hgroup,(ngroupentryidx - 1),hentry)=true)
     IF (prefgetentryname(hentry,sentryname)=true)
      SET bretrieveentry = true
      IF (bretrieveentry=true)
       IF (prefgetentryattrcount(hentry,nentryattrcnt)=true)
        IF (nentryattrcnt > 0)
         IF (prefgetentryattr(hentry,0,hentryattr)=true)
          IF (prefgetattrvalcount(hentryattr,nattrvalcnt)=true)
           IF (nattrvalcnt > 0)
            SET lprefentriescnt += 1
            SET reply->group[p_lreplygroupindex].entry[lprefentriescnt].entryname = sentryname
            SET nentrystat = alterlist(reply->group[p_lreplygroupindex].entry[lprefentriescnt].values,
             nattrvalcnt)
            FOR (nattrvalidx = 1 TO nattrvalcnt)
              IF (prefgetattrval(hentryattr,(nattrvalidx - 1),sattrvalue)=true)
               SET reply->group[p_lreplygroupindex].entry[lprefentriescnt].values[nattrvalidx].value
                = trim(sattrvalue,3)
              ELSE
               SET ngroupentryidx = ngroupentrycnt
               SET nattrvalidx = nattrvalcnt
               SET berrorfound = true
              ENDIF
            ENDFOR
           ENDIF
          ELSE
           SET ngroupentryidx = ngroupentrycnt
           SET berrorfound = true
          ENDIF
          IF (prefdestroyattr(hentryattr)=false)
           SET ngroupentryidx = ngroupentrycnt
           SET berrorfound = true
          ENDIF
         ELSE
          SET ngroupentryidx = ngroupentrycnt
          SET berrorfound = true
         ENDIF
        ENDIF
       ELSE
        SET ngroupentryidx = ngroupentrycnt
        SET berrorfound = true
       ENDIF
      ENDIF
     ELSE
      SET ngroupentryidx = ngroupentrycnt
      SET berrorfound = true
     ENDIF
     IF (prefdestroyentry(hentry)=false)
      SET ngroupentryidx = ngroupentrycnt
      SET berrorfound = true
     ENDIF
    ELSE
     SET ngroupentryidx = ngroupentrycnt
     SET berrorfound = true
    ENDIF
    IF (lprefentriescnt=lreqentrycnt
     AND lreqentrycnt > 0)
     SET ngroupentryidx = ngroupentrycnt
     IF (gnprefdebuglevel >= gnpref_debug_echo)
      CALL echo("====================")
      CALL echo("Found all entries in group/subgroup, exiting loop.")
      CALL echo("====================")
     ENDIF
    ENDIF
   ENDFOR
   SET nentrystat = alterlist(reply->group[p_lreplygroupindex].entry,lprefentriescnt)
   SET pr_lprefentriesfound = lprefentriescnt
   IF (berrorfound=true)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving entries from Group (RetrieveEntries FAILED).")
   ELSE
    SET bprefstat = true
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
#exit_fn_pref_parse
 SET prefparsemoddate = "March 23, 2004"
 SET prefparselastmod = "002"
 IF (validate(gbpref_get_included,false)=true)
  GO TO fn_pref_get_subs
 ENDIF
 DECLARE gbpref_get_included = i2 WITH public, constant(true)
 DECLARE prefgetlastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE prefgetmoddate = c30 WITH private, noconstant(fillstring(30," "))
#fn_pref_get_subs
 SUBROUTINE (prefgetsectioncount(p_hpref=i4,pr_nsectcnt=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE nsectioncnt = i4 WITH protect, noconstant(0)
   SET pr_nsectcnt = 0
   IF (uar_prefgetsectioncount(p_hpref,nsectioncnt)=true)
    SET bprefstat = true
    SET pr_nsectcnt = nsectioncnt
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetSectionCount",build("hPref =",p_hpref,", nSectCnt =",
     pr_nsectcnt))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving section count (PrefGetSectionCount FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetsection(p_hpref=i4,p_lsect=i4,pr_hsect=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetsect = i4 WITH protect, noconstant(0)
   SET pr_hsect = 0
   SET hgetsect = uar_prefgetsectionat(p_hpref,p_lsect)
   IF (hgetsect > 0)
    SET bprefstat = true
    SET pr_hsect = hgetsect
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetSection",build("hPref =",p_hpref,", lSect =",p_lsect,
     ", hSect =",
     pr_hsect))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving section (PrefGetSection FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetsectionbyname(p_hpref=i4,p_ssectionname=vc,pr_hsect=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetsect = i4 WITH protect, noconstant(0)
   SET pr_hsect = 0
   SET hgetsect = uar_prefgetsectionbyname(p_hpref,nullterm(p_ssectionname))
   IF (hgetsect > 0)
    SET bprefstat = true
    SET pr_hsect = hgetsect
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetSectionByName",build("hPref =",p_hpref,", sSectionName =",
     p_ssectionname,", hSect =",
     pr_hsect))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving section (PrefGetSectionByName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetsectionname(p_hsect=i4,pr_ssectionname=vc(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefstring = c1024 WITH private, noconstant("")
   DECLARE nsectionnamelen = i2 WITH protect, noconstant(gnpref_len)
   SET pr_ssectionname = ""
   SET bprefstat = uar_prefgetsectionname(p_hsect,sprefstring,nsectionnamelen)
   IF (size(trim(sprefstring,3)) > 0
    AND nsectionnamelen > 0)
    SET pr_ssectionname = substring(1,(nsectionnamelen - 1),sprefstring)
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetSectionName",build("hSect =",p_hsect,", sSectionName =",
     pr_ssectionname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving section name (PrefGetSectionName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetgroupcount(p_hsect=i4,pr_ngroupcnt=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE ngroupcnt = i4 WITH protect, noconstant(0)
   SET pr_ngroupcnt = 0
   IF (uar_prefgetgroupcount(p_hsect,ngroupcnt)=true)
    SET bprefstat = true
    SET pr_ngroupcnt = ngroupcnt
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetGroupCount",build("hSect =",p_hsect,", nGroupCnt =",
     pr_ngroupcnt))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving group count (PrefGetGroupCount FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetgroup(p_hsect=i4,p_lgroup=i4,pr_hgroup=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetgroup = i4 WITH protect, noconstant(0)
   SET pr_hgroup = 0
   SET hgetgroup = uar_prefgetgroup(p_hsect,p_lgroup)
   IF (hgetgroup > 0)
    SET bprefstat = true
    SET pr_hgroup = hgetgroup
   ENDIF
   IF (gnprefdebuglevel >= gnpref_debug_echo)
    CALL echo("========================================================")
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetGroup",build("hSect =",p_hsect,", lGroup =",p_lgroup,
     ", hGroup =",
     pr_hgroup))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED","Error retrieving group (PrefGetGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetgroupbyname(p_hsect=i4,p_sgroupname=vc,pr_hgroup=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetgroup = i4 WITH protect, noconstant(0)
   SET pr_hgroup = 0
   SET hgetgroup = uar_prefgetgroupbyname(p_hsect,nullterm(p_sgroupname))
   IF (hgetgroup > 0)
    SET bprefstat = true
    SET pr_hgroup = hgetgroup
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetGroupByName",build("hSect =",p_hsect,", sGroupName =",
     p_sgroupname,", hGroup =",
     pr_hgroup))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving group (PrefGetGroupByName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetgroupname(p_hgroup=i4,pr_sgroupname=vc(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefstring = c1024 WITH private, noconstant("")
   DECLARE ngroupnamelen = i4 WITH protect, noconstant(gnpref_len)
   SET pr_sgroupname = ""
   SET bprefstat = uar_prefgetgroupname(p_hgroup,sprefstring,ngroupnamelen)
   IF (size(trim(sprefstring,3)) > 0
    AND ngroupnamelen > 0)
    SET pr_sgroupname = substring(1,(ngroupnamelen - 1),sprefstring)
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetGroupName",build("hGroup =",p_hgroup,", sGroupName =",
     pr_sgroupname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving group name (PrefGetGroupName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetsubgroupcount(p_hgroup=i4,pr_nsubgroupcnt=i4(ref)) =i4)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE nsubgroupcnt = i4 WITH protect, noconstant(0)
   SET pr_nsubgroupcnt = 0
   IF (uar_prefgetsubgroupcount(p_hgroup,nsubgroupcnt)=true)
    SET bprefstat = true
    SET pr_nsubgroupcnt = nsubgroupcnt
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetSubGroupCount",build("hGroup =",p_hgroup,", nSubGroupCnt =",
     pr_nsubgroupcnt))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving subgroup count (PrefGetSubGroupCount FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetsubgroup(p_hgroup=i4,p_lsubgroup=i4,pr_hsubgroup=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetsubgroup = i4 WITH protect, noconstant(0)
   SET pr_hsubgroup = 0
   SET hgetsubgroup = uar_prefgetsubgroup(p_hgroup,p_lsubgroup)
   IF (hgetsubgroup > 0)
    SET bprefstat = true
    SET pr_hsubgroup = hgetsubgroup
   ENDIF
   IF (gnprefdebuglevel >= gnpref_debug_echo)
    CALL echo("========================================================")
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetSubGroup",build("hGroup =",p_hgroup,", lSubGroup =",
     p_lsubgroup,", hSubGroup =",
     pr_hsubgroup))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving subgroup (PrefGetSubGroup FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetgroupentrycount(p_hgroup=i4,pr_nentrycnt=i4(ref)) =i4)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE ngroupentrycnt = i4 WITH protect, noconstant(0)
   SET pr_nentrycnt = 0
   IF (uar_prefgetgroupentrycount(p_hgroup,ngroupentrycnt)=true)
    SET bprefstat = true
    SET pr_nentrycnt = ngroupentrycnt
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetGroupEntryCount",build("hGroup =",p_hgroup,", nEntryCnt =",
     pr_nentrycnt))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving group entry count (PrefGetGroupEntryCount FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetgroupentry(p_hgroup=i4,p_lentry=i4,pr_hentry=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetgroupentry = i4 WITH protect, noconstant(0)
   SET pr_hentry = 0
   SET hgetgroupentry = uar_prefgetgroupentry(p_hgroup,p_lentry)
   IF (hgetgroupentry > 0)
    SET bprefstat = true
    SET pr_hentry = hgetgroupentry
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetGroupEntry",build("hGroup =",p_hgroup,", lEntry =",p_lentry,
     ", hEntry =",
     pr_hentry))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving group entry (PrefGetGroupEntry FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetentryname(p_hentry=i4,pr_sentryname=vc(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefstring = c1024 WITH private, noconstant("")
   DECLARE nentrynamelen = i4 WITH protect, noconstant(gnpref_len)
   SET pr_sentryname = ""
   SET bprefstat = uar_prefgetentryname(p_hentry,sprefstring,nentrynamelen)
   IF (size(trim(sprefstring,3)) > 0
    AND nentrynamelen > 0)
    SET pr_sentryname = substring(1,(nentrynamelen - 1),sprefstring)
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetEntryName",build("hEntry =",p_hentry,", sEntryName =",
     pr_sentryname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving group entry name (PrefGetEntryName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetentryattrcount(p_hentry=i4,pr_nattrcnt=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE nentryattrcnt = i4 WITH protect, noconstant(0)
   SET pr_nattrcnt = 0
   IF (uar_prefgetentryattrcount(p_hentry,nentryattrcnt)=true)
    SET bprefstat = true
    SET pr_nattrcnt = nentryattrcnt
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetEntryAttrCount",build("hEntry =",p_hentry,", nAttrCnt =",
     pr_nattrcnt))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving entry attribute count (PrefGetEntryAttrCount FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetentryattr(p_hentry=i4,p_lattr=i4,pr_hattr=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE hgetentryattr = i4 WITH protect, noconstant(0)
   SET pr_hattr = 0
   SET hgetentryattr = uar_prefgetentryattr(p_hentry,p_lattr)
   IF (hgetentryattr > 0)
    SET bprefstat = true
    SET pr_hattr = hgetentryattr
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetEntryAttr",build("hEntry =",p_hentry,", lAttr =",p_lattr,
     ", hAttr=",
     pr_hattr))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving entry attribute (PrefGetEntryAttr FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetattrname(p_hattr=i4,pr_sattrname=vc(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefstring = c1024 WITH private, noconstant("")
   DECLARE nattrnamelen = i2 WITH protect, noconstant(gnpref_len)
   SET pr_sattrname = ""
   SET bprefstat = uar_prefgetattrname(p_hattr,sprefstring,nattrnamelen)
   IF (size(trim(sprefstring,3)) > 0
    AND nattrnamelen > 0)
    SET pr_sattrname = substring(1,(nattrnamelen - 1),sprefstring)
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetAttrName",build("hAttr =",p_hattr,", sAttrName =",
     pr_sattrname))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving attribute name (PrefGetAttrName FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetattrvalcount(p_hattr=i4,pr_nvaluecnt=i4(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE nattrvalcnt = i4 WITH protect, noconstant(0)
   SET pr_nvaluecnt = 0
   IF (uar_prefgetattrvalcount(p_hattr,nattrvalcnt)=true)
    SET bprefstat = true
    SET pr_nvaluecnt = nattrvalcnt
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetAttrValCount",build("hAttr =",p_hattr,", nValueCnt =",
     pr_nvaluecnt))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving attribute value count (PrefGetAttrValCount FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
 SUBROUTINE (prefgetattrval(p_hattr=i4,p_lvalue=i4,pr_svalue=vc(ref)) =i2)
   DECLARE bprefstat = i2 WITH private, noconstant(false)
   DECLARE sprefstring = c1024 WITH private, noconstant(" ")
   DECLARE nattrvallen = i4 WITH protect, noconstant(gnpref_len)
   SET pr_svalue = ""
   SET bprefstat = uar_prefgetattrval(p_hattr,sprefstring,nattrvallen,p_lvalue)
   IF (size(trim(sprefstring,3)) > 0
    AND nattrvallen > 0)
    SET pr_svalue = substring(1,(nattrvallen - 1),sprefstring)
   ENDIF
   CALL logprefresult(bprefstat,"PrefGetAttrVal",build("hAttr =",p_hattr,", lValue =",p_lvalue,
     ", sValue =",
     pr_svalue))
   IF (bprefstat=false)
    CALL addstatusblock("F",sscriptname,"F","FAILED",
     "Error retrieving attribute value (PrefGetAttrVal FAILED).")
   ENDIF
   RETURN(bprefstat)
 END ;Subroutine
#exit_fn_pref_get
 SET prefgetmoddate = "March 23, 2004"
 SET prefgetlastmod = "002"
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 group[*]
      2 name = vc
      2 entry[*]
        3 name = vc
        3 values[*]
          4 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE RECORD subgroup
 RECORD subgroup(
   1 qual[*]
     2 handle = i4
 )
 DECLARE bprefstat = i2 WITH private, noconstant(true)
 DECLARE bscriptfailed = i2 WITH protect, noconstant(false)
 DECLARE lpreffoundcnt = i4 WITH protect, noconstant(0)
 DECLARE hreadpref = i4 WITH protect, noconstant(0)
 DECLARE hprefattr = i4 WITH protect, noconstant(0)
 DECLARE hprefgroup = i4 WITH protect, noconstant(0)
 DECLARE hprefsubgroup = i4 WITH protect, noconstant(0)
 DECLARE sscriptname = vc WITH protect, noconstant("cv_get_prefs")
 DECLARE ssectionnametoget = vc WITH protect, noconstant(request->sectionname)
 DECLARE ssectionidtoget = vc WITH protect, noconstant(request->sectionid)
 DECLARE srequestedpath = vc WITH protect, noconstant("")
 DECLARE srequestedsection = vc WITH protect, noconstant("")
 SET srequestedsection = build(ssectionnametoget,"/",ssectionidtoget)
 SET srequestedpath = srequestedsection
 FOR (idx = 1 TO size(request->grouppath,5))
   SET srequestedpath = build(srequestedpath,"/",request->grouppath[idx].name)
 ENDFOR
 IF ( NOT (validate(stat)))
  DECLARE stat = i2 WITH private, noconstant(0)
 ENDIF
 DECLARE ngroupidx = i2 WITH private, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE scontextid = vc WITH private, noconstant("")
 DECLARE sgroupname = vc WITH private, noconstant("")
 SET gnprefdebuglevel = request->debugind
 IF ((reqdata->loglevel > gnprefdebuglevel))
  SET gnprefdebuglevel = reqdata->loglevel
 ENDIF
 IF (gnprefdebuglevel >= gnpref_debug_echo)
  CALL echo(concat("ENTERING -",sscriptname," -- ",format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  IF (gnprefdebuglevel >= gnpref_debug_echo_record)
   CALL echorecord(request)
  ENDIF
 ENDIF
 IF (prefcreateinstance(glpref_trans_get,hreadpref)=false)
  GO TO exit_script
 ENDIF
 IF (prefaddattr(hreadpref,"prefvalue",hprefattr)=false)
  GO TO exit_script
 ENDIF
 IF (prefdestroyattr(hprefattr)=false)
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(request->context,5))
   IF (prefaddcontext(hreadpref,request->context[idx].name,request->context[idx].id) != true)
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (prefsetsection(hreadpref,ssectionnametoget)=false)
  GO TO exit_script
 ENDIF
 IF (prefcreategroup(hreadpref,hprefgroup)=false)
  GO TO exit_script
 ENDIF
 IF (prefsetgroupname(hprefgroup,ssectionidtoget)=false)
  CALL prefdestroygroup(hprefgroup)
  GO TO exit_script
 ENDIF
 IF (size(request->grouppath,5) > 0)
  SET sgroupname = request->grouppath[1].name
  IF (prefaddsubgroup(hprefgroup,hprefsubgroup,sgroupname)=false)
   GO TO exit_script
  ENDIF
  IF (prefdestroygroup(hprefsubgroup)=false)
   CALL prefdestroygroup(hprefgroup)
   GO TO exit_script
  ENDIF
 ELSE
  IF (gnprefdebuglevel >= gnpref_debug_echo)
   CALL echo("requesting all groups under section id.")
  ENDIF
 ENDIF
 IF (prefdestroygroup(hprefsubgroup)=false)
  CALL prefdestroygroup(hprefgroup)
  GO TO exit_script
 ENDIF
 IF (prefaddgroup(hreadpref,hprefgroup)=false)
  SET stat = 1
  CALL prefdestroygroup(hprefgroup)
  GO TO exit_script
 ENDIF
 IF (prefdestroygroup(hprefgroup)=false)
  GO TO exit_script
 ENDIF
 IF (prefperform(hreadpref,glpref_trans_get)=true)
  IF (parseprefs(hreadpref,lpreffoundcnt)=false)
   GO TO exit_script
  ENDIF
 ELSE
  GO TO exit_script
 ENDIF
#exit_script
 CALL prefdestroyinstance(hreadpref)
 IF (checkerrorccl("F","EXIT_SCRIPT","F","EXIT")=false)
  IF (bscriptfailed=false)
   IF (lpreffoundcnt > 0)
    CALL addstatusblock("S",sscriptname,"S","SUCCESS",build2("successfully retrieved preferences: ",
      lpreffoundcnt))
   ELSE
    CALL addstatusblock("Z",sscriptname,"Z","ZERO","ZERO preferences found.")
   ENDIF
  ENDIF
 ENDIF
 IF (gnprefdebuglevel >= gnpref_debug_echo)
  CALL echo(concat("EXITING -",sscriptname," -- ",format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  IF (gnprefdebuglevel >= gnpref_debug_echo_record)
   CALL echorecord(reply)
  ENDIF
 ENDIF
 SET mod_date = "28 September 2009"
 SET last_mod = "001"
END GO

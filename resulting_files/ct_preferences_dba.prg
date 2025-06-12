CREATE PROGRAM ct_preferences:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 pref[*]
      2 section = vc
      2 section_id = vc
      2 subgroup = vc
      2 entries[*]
        3 pref_exists_ind = i2
        3 entry = vc
        3 values[*]
          4 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE prefrtl
 FREE RECORD dual_maint_prefs
 RECORD dual_maint_prefs(
   1 pref[*]
     2 entry_name = vc
     2 dm_pref_domain = vc
     2 dm_pref_section = vc
     2 dm_pref_name = vc
     2 dm_pref_app_num = i4
     2 dm_pref_person_id = f8
     2 dm_pref_value_flag = i4
 )
 DECLARE nprefstr = i4 WITH protected, constant(1)
 DECLARE nprefnum = i4 WITH protected, constant(2)
 DECLARE nprefcd = i4 WITH protected, constant(4)
 SET stat = alterlist(dual_maint_prefs->pref,2)
 SET dual_maint_prefs->pref[1].entry_name = "FILTER_ORGTYPES"
 SET dual_maint_prefs->pref[1].dm_pref_domain = "HNAUSER"
 SET dual_maint_prefs->pref[1].dm_pref_section = "ORG FILTER"
 SET dual_maint_prefs->pref[1].dm_pref_name = "FILTERTYPE"
 SET dual_maint_prefs->pref[1].dm_pref_app_num = 3000
 SET dual_maint_prefs->pref[1].dm_pref_value_flag = nprefstr
 SET dual_maint_prefs->pref[2].entry_name = "FILTER_UNAUTH"
 SET dual_maint_prefs->pref[2].dm_pref_domain = "HNAUSER"
 SET dual_maint_prefs->pref[2].dm_pref_section = "ORG FILTER"
 SET dual_maint_prefs->pref[2].dm_pref_name = "FILTER UNAUTHENTICATED"
 SET dual_maint_prefs->pref[2].dm_pref_app_num = 3000
 SET dual_maint_prefs->pref[2].dm_pref_value_flag = nprefnum
 SUBROUTINE (is_dual_maint_required(sprefname=vc(value)) =i2 WITH protect)
   DECLARE ncnt = i4 WITH private, noconstant(0)
   FOR (ncnt = 1 TO size(dual_maint_prefs->pref,5))
     IF ((trim(cnvtupper(sprefname))=dual_maint_prefs->pref[ncnt].entry_name))
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_pref_index(sprefname=vc(value)) =i4 WITH protect)
   DECLARE ncnt = i4 WITH private, noconstant(0)
   FOR (ncnt = 1 TO size(dual_maint_prefs->pref,5))
     IF ((trim(cnvtupper(sprefname))=dual_maint_prefs->pref[ncnt].entry_name))
      RETURN(ncnt)
     ENDIF
   ENDFOR
   RETURN(- (1))
 END ;Subroutine
 SUBROUTINE (lookup_dm_prefs(sprefname=vc(value),sprefvalue=vc(ref)) =c1 WITH protect)
   IF ( NOT (validate(ppr_dmprefs,0)))
    RECORD ppr_dmprefs(
      1 pref[*]
        2 application_nbr = i4
        2 parent_entity_id = f8
        2 parent_entity_name = c32
        2 person_id = f8
        2 pref_cd = f8
        2 pref_domain = vc
        2 pref_dt_tm = dq8
        2 pref_id = f8
        2 pref_name = vc
        2 pref_nbr = i4
        2 pref_section = vc
        2 pref_str = vc
        2 reference_ind = i2
        2 write_ind = i2
        2 status = c1
    )
   ENDIF
   DECLARE nindex = i4 WITH private, noconstant(0)
   SET nindex = get_pref_index(sprefname)
   IF (nindex < 1)
    RETURN("F")
   ENDIF
   SET stat = alterlist(ppr_dmprefs->pref,1)
   SET ppr_dmprefs->pref[1].application_nbr = dual_maint_prefs->pref[nindex].dm_pref_app_num
   SET ppr_dmprefs->pref[1].person_id = dual_maint_prefs->pref[nindex].dm_pref_person_id
   SET ppr_dmprefs->pref[1].pref_domain = dual_maint_prefs->pref[nindex].dm_pref_domain
   SET ppr_dmprefs->pref[1].pref_section = dual_maint_prefs->pref[nindex].dm_pref_section
   SET ppr_dmprefs->pref[1].pref_name = dual_maint_prefs->pref[nindex].dm_pref_name
   SET ppr_dmprefs->pref[1].write_ind = 0
   EXECUTE ppr_upd_dm_prefs
   IF ((ppr_dmprefs->pref[1].status > " "))
    IF ((ppr_dmprefs->pref[1].status="S"))
     IF ((dual_maint_prefs->pref[nindex].dm_pref_value_flag=nprefnum))
      SET sprefvalue = cnvtstring(ppr_dmprefs->pref[1].pref_nbr)
     ELSEIF ((dual_maint_prefs->pref[nindex].dm_pref_value_flag=nprefcd))
      SET sprefvalue = cnvtstring(ppr_dmprefs->pref[1].pref_cd)
     ELSE
      SET sprefvalue = ppr_dmprefs->pref[1].pref_str
     ENDIF
     RETURN("S")
    ELSE
     RETURN(ppr_dmprefs->pref[1].status)
    ENDIF
   ELSE
    RETURN("F")
   ENDIF
 END ;Subroutine
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE lprefstat = i4 WITH protect, noconstant(0)
 DECLARE hpref = i4 WITH protect, noconstant(0)
 DECLARE hcnt = i2 WITH protect, noconstant(0)
 DECLARE hentry = i4 WITH protect, noconstant(0)
 DECLARE hsect = i4 WITH protect, noconstant(0)
 DECLARE hattr = i4 WITH protect, noconstant(0)
 DECLARE hgroup = i4 WITH protect, noconstant(0)
 DECLARE husegroup = i4 WITH protect, noconstant(0)
 DECLARE hsubgroup = i4 WITH protect, noconstant(0)
 DECLARE sentryname = c255 WITH private, noconstant("")
 DECLARE sattrname = c255 WITH private, noconstant("")
 DECLARE svalue = c255 WITH private, noconstant("")
 DECLARE lentrycnt = i4 WITH private, noconstant(0)
 DECLARE lattrcnt = i4 WITH private, noconstant(0)
 DECLARE lvalcnt = i4 WITH private, noconstant(0)
 DECLARE lattr = i4 WITH protect, noconstant(0)
 DECLARE lvalue = i4 WITH protect, noconstant(0)
 DECLARE preflen = i4 WITH private, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE ctxtcnt = i4 WITH protect, noconstant(0)
 DECLARE entrycnt = i4 WITH protect, noconstant(0)
 DECLARE valcnt = i4 WITH protect, noconstant(0)
 DECLARE lreplycnt = i4 WITH protect, noconstant(0)
 DECLARE lentry = i4 WITH protect, noconstant(0)
 DECLARE lreqentrycnt = i4 WITH protect, noconstant(0)
 DECLARE lreqvalcnt = i4 WITH protect, noconstant(0)
 DECLARE npreferr = i4 WITH protect, noconstant(0)
 DECLARE spreferrmsg = c255 WITH protect, noconstant("")
 DECLARE nsubgrpind = i2 WITH protect, noconstant(0)
 DECLARE ssubgrp = vc WITH protect, noconstant("")
 DECLARE sdmprefvalue = vc WITH protect, noconstant("")
 DECLARE nentrylen = i4 WITH protect, noconstant(0)
 DECLARE delete_ind = i2 WITH protect, noconstant(0)
 DECLARE sprefstatus = c1 WITH protect, noconstant("F")
 SET stat = alterlist(reply->pref,size(request->pref,5))
 IF (validate(request->pref[1].subgroup,"<undefined>") != "<undefined>"
  AND validate(reply->pref[1].subgroup,"<undefined>") != "<undefined>")
  SET nsubgrpind = 1
 ENDIF
 IF ((validate(request->delete_ind,- (1)) != - (1))
  AND (request->write_ind=1))
  SET delete_ind = request->delete_ind
 ENDIF
 FOR (pcnt = 1 TO size(request->pref,5))
   CALL echo("******")
   CALL echo("******")
   SET reply->pref[pcnt].section = request->pref[pcnt].section
   SET reply->pref[pcnt].section_id = request->pref[pcnt].section_id
   IF (nsubgrpind=1)
    SET reply->pref[pcnt].subgroup = request->pref[pcnt].subgroup
   ENDIF
   SET stat = alterlist(reply->pref[pcnt].entries,size(request->pref[pcnt].entries,5))
   FOR (lentry = 1 TO size(request->pref[pcnt].entries,5))
    CALL echo(build("Pref # ",cnvtstring(pcnt),"; Entry: ",request->pref[pcnt].entries[lentry].entry)
     )
    SET reply->pref[pcnt].entries[lentry].entry = request->pref[pcnt].entries[lentry].entry
   ENDFOR
   CALL echo("*****")
   IF ((request->write_ind=0))
    SET hpref = uar_prefcreateinstance(0)
    CALL echo(build("hPref = ",hpref))
    FOR (ctxtcnt = 1 TO size(request->pref[pcnt].contexts,5))
      SET lprefstat = uar_prefaddcontext(hpref,nullterm(request->pref[pcnt].contexts[ctxtcnt].context
        ),nullterm(request->pref[pcnt].contexts[ctxtcnt].context_id))
    ENDFOR
    IF (size(request->pref[pcnt].contexts,5) < 1)
     SET lprefstat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
    ENDIF
    CALL echo(build("stat on context = ",lprefstat))
    SET lprefstat = uar_prefsetsection(hpref,nullterm(request->pref[pcnt].section))
    CALL echo(build("stat on section = ",lprefstat))
    SET hgroup = uar_prefcreategroup()
    CALL echo(build("handle on group = ",hgroup))
    SET lprefstat = uar_prefsetgroupname(hgroup,nullterm(request->pref[pcnt].section_id))
    CALL echo(build("stat on setting group name = ",lprefstat))
    IF (nsubgrpind=1)
     SET ssubgrp = trim(request->pref[pcnt].subgroup)
     IF (ssubgrp > " ")
      SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgrp))
      CALL echo(build("handle on subgroup = ",hsubgroup))
     ENDIF
    ENDIF
    SET lprefstat = uar_prefaddgroup(hpref,hgroup)
    CALL echo(build("stat on adding group = ",lprefstat))
    SET lprefstat = uar_prefperform(hpref)
    CALL echo(build("stat PERFORM = ",lprefstat))
    IF (lprefstat > 0)
     SET hsect = uar_prefgetsectionbyname(hpref,nullterm(request->pref[pcnt].section))
     CALL echo(build("hSect = ",hsect))
     SET hgroup = uar_prefgetgroupbyname(hsect,nullterm(request->pref[pcnt].section_id))
     CALL echo(build("hGroup = ",hgroup))
     IF (ssubgrp > " ")
      SET husegroup = uar_prefgetsubgroup(hgroup,0)
      CALL echo(build("hSubGroup = ",husegroup))
     ELSE
      SET husegroup = hgroup
     ENDIF
     SET lprefstat = uar_prefgetgroupentrycount(husegroup,lentrycnt)
     CALL echo(build("lEntryCnt = ",lentrycnt))
     FOR (lreqentrycnt = 1 TO size(request->pref[pcnt].entries,5))
      FOR (lentry = 0 TO (lentrycnt - 1))
       SET hentry = uar_prefgetgroupentry(husegroup,lentry)
       IF (hentry > 0)
        SET preflen = 100
        SET sentryname = ""
        SET lprefstat = uar_prefgetentryname(hentry,sentryname,preflen)
        CALL echo(build("hEntry sEntryName = ",trim(sentryname),"                lPrefStat = ",
          lprefstat))
        SET nentrylen = size(trim(sentryname),1)
        SET sentryname = substring(1,nentrylen,sentryname)
        IF (trim(sentryname,3)=trim(request->pref[pcnt].entries[lreqentrycnt].entry,3))
         SET reply->pref[pcnt].entries[lreqentrycnt].pref_exists_ind = 1
         SET lattrcnt = 0
         SET lprefstat = uar_prefgetentryattrcount(hentry,lattrcnt)
         CALL echo(build("lAttrCnt = ",lattrcnt,"                  lPrefStat = ",lprefstat))
         FOR (lattr = 0 TO (lattrcnt - 1))
           SET hattr = uar_prefgetentryattr(hentry,lattr)
           SET preflen = 100
           SET lprefstat = uar_prefgetattrname(hattr,sattrname,preflen)
           CALL echo(build("hEntry sAttrName = ",sattrname,"                lPrefStat = ",lprefstat))
           IF (sattrname="prefvalue")
            SET lprefstat = uar_prefgetattrvalcount(hattr,lvalcnt)
            CALL echo(build("Num of values = ",lvalcnt,"                lPrefStat = ",lprefstat))
            SET stat = alterlist(reply->pref[pcnt].entries[lreqentrycnt].values,lvalcnt)
            FOR (lvalue = 0 TO (lvalcnt - 1))
              SET svalue = ""
              SET preflen = 100
              SET lprefstat = uar_prefgetattrval(hattr,svalue,preflen,lvalue)
              SET reply->pref[pcnt].entries[lreqentrycnt].values[(lvalue+ 1)].value = substring(1,(
               preflen - 1),svalue)
              CALL echo(build("PrefValue = ",trim(svalue),"                lPrefStat = ",lprefstat))
            ENDFOR
            SET lattr = lattrcnt
           ENDIF
         ENDFOR
         SET lentry = lentrycnt
        ENDIF
       ENDIF
      ENDFOR
      IF ((reply->pref[pcnt].entries[lreqentrycnt].pref_exists_ind=0))
       IF (is_dual_maint_required(request->pref[pcnt].entries[lreqentrycnt].entry))
        IF (lookup_dm_prefs(request->pref[pcnt].entries[lreqentrycnt].entry,sdmprefvalue)="S")
         SET reply->pref[pcnt].entries[lreqentrycnt].pref_exists_ind = 2
         SET stat = return_pref_values(pcnt,lreqentrycnt,sdmprefvalue)
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     FOR (lreqentrycnt = 1 TO size(request->pref[pcnt].entries,5))
       IF (is_dual_maint_required(request->pref[pcnt].entries[lreqentrycnt].entry))
        IF (lookup_dm_prefs(request->pref[pcnt].entries[lreqentrycnt].entry,sdmprefvalue)="S")
         SET reply->pref[pcnt].entries[lreqentrycnt].pref_exists_ind = 2
         SET lprefstat = return_pref_values(pcnt,lreqentrycnt,sdmprefvalue)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    IF (delete_ind=1)
     SET hpref = uar_prefcreateinstance(2)
    ELSE
     SET hpref = uar_prefcreateinstance(1)
    ENDIF
    CALL echo(build("hPref = ",hpref))
    IF (size(request->pref[pcnt].contexts,5) < 1)
     SET lprefstat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
    ELSE
     SET lprefstat = uar_prefaddcontext(hpref,nullterm(request->pref[pcnt].contexts[1].context),
      nullterm(request->pref[pcnt].contexts[1].context_id))
    ENDIF
    CALL echo(build("stat on context = ",lprefstat))
    SET lprefstat = uar_prefsetsection(hpref,nullterm(request->pref[pcnt].section))
    CALL echo(build("stat on section = ",lprefstat))
    SET hgroup = uar_prefcreategroup()
    CALL echo(build("handle on group = ",hgroup))
    SET lprefstat = uar_prefsetgroupname(hgroup,nullterm(request->pref[pcnt].section_id))
    CALL echo(build("stat on setting group name = ",lprefstat))
    IF (nsubgrpind=1)
     SET ssubgrp = trim(request->pref[pcnt].subgroup)
     IF (size(ssubgrp,1) > 0)
      SET husegroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgrp))
      CALL echo(build("handle on subgroup = ",husegroup))
     ELSE
      SET husegroup = hgroup
     ENDIF
    ENDIF
    FOR (entrycnt = 1 TO size(request->pref[pcnt].entries,5))
      SET hentry = uar_prefaddentrytogroup(husegroup,nullterm(request->pref[pcnt].entries[entrycnt].
        entry))
      CALL echo(build("handle on entry = ",hentry))
      IF (delete_ind != 1)
       SET hattr = uar_prefaddattrtoentry(hentry,nullterm("prefvalue"))
       CALL echo(build("handle on attr = ",hattr))
       SET lreqvalcnt = size(request->pref[pcnt].entries[entrycnt].values,5)
       IF (lreqvalcnt > 1)
        FOR (valcnt = 1 TO lreqvalcnt)
         SET lprefstat = uar_prefaddattrval(hattr,nullterm(trim(request->pref[pcnt].entries[entrycnt]
            .values[valcnt].value)))
         CALL echo(build("stat on adding value = ",lprefstat))
        ENDFOR
       ELSEIF (lreqvalcnt=1)
        SET lprefstat = add_pref_values(hattr,request->pref[pcnt].entries[entrycnt].values[1].value)
       ENDIF
      ENDIF
    ENDFOR
    SET lprefstat = uar_prefaddgroup(hpref,hgroup)
    CALL echo(build("stat on adding group name = ",lprefstat))
    SET lprefstat = uar_prefperform(hpref)
    CALL echo(build("stat PERFORM = ",lprefstat))
    IF (lprefstat < 1)
     SET npreferr = uar_prefgetlasterror()
     CALL echo(build("Last error: ",npreferr))
     SET lprefstat = uar_prefformatmessage(spreferrmsg,255)
     CALL echo(build("PrefFormatMessage Status =",lprefstat,", Message =",spreferrmsg))
     SET reply->status_data.subeventstatus[1].targetobjectname = spreferrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET sprefstatus = "S"
 SUBROUTINE (return_pref_values(nprefidx=i4(value),nentryidx=i4(value),sprefvalue=vc(value)) =i2
  WITH protect)
   DECLARE svalues = vc WITH private, noconstant("")
   DECLARE snewvalue = vc WITH private, noconstant("")
   DECLARE nlen = i4 WITH private, noconstant(0)
   DECLARE npos = i4 WITH private, noconstant(1)
   DECLARE nvaluelen = i4 WITH private, noconstant(0)
   DECLARE nvaluecnt = i4 WITH private, noconstant(0)
   IF (sprefvalue <= " ")
    RETURN(1)
   ENDIF
   SET svalues = build(sprefvalue,",")
   SET nlen = size(svalues)
   WHILE (nlen > 0)
     SET nvaluelen = (findstring(",",svalues,npos) - 1)
     SET snewvalue = substring(npos,nvaluelen,svalues)
     SET npos = (nvaluelen+ 2)
     IF (size(svalues) >= npos)
      SET svalues = substring(npos,((nlen - npos)+ 1),svalues)
     ELSE
      SET nlen = 0
     ENDIF
     SET npos = 1
     SET nvaluecnt += 1
     SET stat = alterlist(reply->pref[nprefidx].entries[nentryidx].values,nvaluecnt)
     SET reply->pref[nprefidx].entries[nentryidx].values[nvaluecnt].value = snewvalue
   ENDWHILE
   CALL echo("echoing out from pref script")
   CALL echorecord(reply)
   RETURN(1)
   CALL echo("in pref script")
 END ;Subroutine
 SUBROUTINE add_pref_values(hattribute,sprefvalue)
   DECLARE svalues = vc WITH private, noconstant("")
   DECLARE snewvalue = vc WITH private, noconstant("")
   DECLARE nlen = i4 WITH private, noconstant(0)
   DECLARE npos = i4 WITH private, noconstant(1)
   DECLARE nvaluelen = i4 WITH private, noconstant(0)
   IF (sprefvalue <= " ")
    RETURN(1)
   ENDIF
   SET svalues = build(sprefvalue,",")
   SET nlen = size(svalues)
   WHILE (nlen > 0)
     SET nvaluelen = (findstring(",",svalues,npos) - 1)
     SET snewvalue = substring(npos,nvaluelen,svalues)
     SET npos = (nvaluelen+ 2)
     IF (size(svalues) >= npos)
      SET svalues = substring(npos,((nlen - npos)+ 1),svalues)
     ELSE
      SET nlen = 0
     ENDIF
     SET npos = 1
     SET lprefstat = uar_prefaddattrval(hattribute,nullterm(snewvalue))
     CALL echo(build("stat on adding value = ",lprefstat))
   ENDWHILE
   RETURN(1)
 END ;Subroutine
#exit_script
 SET lprefstat = uar_prefdestroyattr(hattr)
 CALL echo(build("stat on destroying Attribute = ",lprefstat))
 SET lprefstat = uar_prefdestroyentry(hentry)
 CALL echo(build("stat on destroying Entry = ",lprefstat))
 SET lprefstat = uar_prefdestroygroup(husegroup)
 CALL echo(build("stat on destroying Subgroup = ",lprefstat))
 SET lprefstat = uar_prefdestroygroup(hgroup)
 CALL echo(build("stat on destroying Group = ",lprefstat))
 SET lprefstat = uar_prefdestroysection(hsect)
 CALL echo(build("stat on destroying Section = ",lprefstat))
 SET lprefstat = uar_prefdestroyinstance(hpref)
 CALL echo(build("stat on destroying Instance = ",lprefstat))
 SET reply->status_data.status = sprefstatus
 SET last_mod = "001"
 SET mod_date = "May 19, 2009"
END GO

CREATE PROGRAM cvgetsectionprefs:dba
 DECLARE thesection = vc WITH constant(value( $1)), protect
 DECLARE theusername = vc WITH constant(cnvtupper(value( $2))), protect
 IF (((thesection <= "") OR (theusername <= "")) )
  CALL echo("---------------------------------------------------------------------------")
  CALL echo("Usage: ")
  CALL echo("  cvGetSectionPrefs '<section name>', '<user name>' go")
  CALL echo("Example: ")
  CALL echo("  cvGetSectionPrefs 'module/cvnet/refletters', 'cvcardiologist' go")
  CALL echo("---------------------------------------------------------------------------")
  CALL echo("")
  CALL echo("")
  GO TO exit_script
 ENDIF
 DECLARE dpositioncd = f8 WITH noconstant(0.0), protect
 DECLARE spositioncd = vc WITH noconstant(""), protect
 DECLARE dpersonid = f8 WITH noconstant(0.0), protect
 DECLARE spersonid = vc WITH noconstant(""), protect
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=theusername
  DETAIL
   dpositioncd = p.position_cd, dpersonid = p.person_id, spositioncd = build(trim(format(p
      .position_cd,";L;F")),".00"),
   spersonid = build(trim(format(p.person_id,";L;F")),".00")
  WITH nocounter
 ;end select
 IF (((dpersonid=0) OR (dpositioncd=0)) )
  CALL echo(
   "------------------------------------------------------------------------------------------")
  CALL echo(build2("username ",theusername," not in the prsnl table or does not have a position_cd"))
  CALL echo(
   "------------------------------------------------------------------------------------------")
  CALL echo("")
  CALL echo("")
  GO TO exit_script
 ENDIF
 DECLARE thesectionname = vc WITH noconstant("")
 DECLARE thesectionid = vc WITH noconstant("")
 DECLARE thegrouppath = vc WITH noconstant("")
 DECLARE delimpos1 = i4 WITH noconstant(0)
 DECLARE delimpos2 = i4 WITH noconstant(0)
 SET delimpos1 = findstring("/",thesection)
 SET delimpos2 = findstring("/",thesection,(1+ delimpos1))
 SET thesectionname = substring(1,(delimpos1 - 1),thesection)
 IF (delimpos2 > 0)
  SET thesectionid = substring((delimpos1+ 1),((delimpos2 - delimpos1) - 1),thesection)
  SET thegrouppath = substring((delimpos2+ 1),(size(thesection) - delimpos2),thesection)
 ELSE
  SET thesectionid = substring((delimpos1+ 1),(size(thesection) - delimpos1),thesection)
 ENDIF
 CALL echo(build2("theSectionName = ",thesectionname,"; theSectionId = ",thesectionid,
   "; theGroupPath = ",
   thegrouppath))
 EXECUTE cv_get_prefs_request  WITH replace("REQUEST",pref_req)
 EXECUTE cv_get_prefs_reply  WITH replace("REPLY",pref_rep)
 SET stat = alterlist(pref_req->context,3)
 SET pref_req->context[1].name = "default"
 SET pref_req->context[1].id = "system"
 SET pref_req->context[2].name = "position"
 SET pref_req->context[2].id = spositioncd
 SET pref_req->context[3].name = "user"
 SET pref_req->context[3].id = spersonid
 SET pref_req->sectionname = thesectionname
 SET pref_req->sectionid = thesectionid
 SET pref_req->recurse = 1
 IF (delimpos2 > 0)
  SET stat = alterlist(pref_req->grouppath,1)
  SET pref_req->grouppath[1].name = thegrouppath
 ENDIF
 EXECUTE cv_get_prefs  WITH replace("REQUEST",pref_req), replace("REPLY",pref_rep)
 DECLARE pagewidth = i4 WITH constant(255), protect
 DECLARE pageheight = i4 WITH constant(60), protect
 DECLARE outputline = vc WITH protect
 DECLARE maxentrycount = i4 WITH noconstant(0)
 FOR (groupidx = 1 TO size(pref_rep->group,5))
   IF (maxentrycount < size(pref_rep->group[groupidx].entry,5))
    SET maxentrycount = size(pref_rep->group[groupidx].entry,5)
   ENDIF
 ENDFOR
 FOR (groupidx = 1 TO size(pref_rep->group,5))
   SET stat = alterlist(pref_rep->group[groupidx].entry,maxentrycount)
 ENDFOR
 SELECT
  x = 0
  FROM (dummyt dgroup  WITH seq = size(pref_rep->group,5)),
   (dummyt dentry  WITH seq = maxentrycount)
  ORDER BY dgroup.seq, pref_rep->group[dgroup.seq].entry[dentry.seq].entryname
  HEAD REPORT
   "----------------------------------------------------------------------------", row + 1, "    ",
   thesection, "   preferences for ", theusername,
   row + 1, "----------------------------------------------------------------------------", row + 1
  HEAD dgroup.seq
   outputline = trim(substring(1,(pagewidth - 1),pref_rep->group[dgroup.seq].groupname),3),
   outputline, row + 1
   IF ((row > (pageheight - 1)))
    BREAK
   ENDIF
  DETAIL
   IF ((pref_rep->group[dgroup.seq].entry[dentry.seq].entryname > ""))
    col 5, outputline = trim(substring(1,((pagewidth - col) - 1),pref_rep->group[dgroup.seq].entry[
      dentry.seq].entryname),3), outputline,
    row + 1
    IF ((row > (pageheight - 1)))
     BREAK
    ENDIF
    FOR (valueidx = 1 TO size(pref_rep->group[dgroup.seq].entry[dentry.seq].values,5))
      col 10, outputline = trim(substring(1,((pagewidth - col) - 1),pref_rep->group[dgroup.seq].
        entry[dentry.seq].values[valueidx].value),3), outputline,
      row + 1
      IF ((row > (pageheight - 1)))
       BREAK
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter, maxcol = value(pagewidth), maxrow = value(pageheight)
 ;end select
#exit_script
END GO

CREATE PROGRAM cv_get_cvnet_prefs:dba
 DECLARE spositioncd = vc
 DECLARE spersonid = vc
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.username= $1)
  DETAIL
   spositioncd = build(trim(format(p.position_cd,";L;F")),".00"), spersonid = build(trim(format(p
      .person_id,";L;F")),".00")
  WITH nocounter
 ;end select
 EXECUTE cv_get_prefs_request  WITH replace("REQUEST",pref_req)
 EXECUTE cv_get_prefs_reply  WITH replace("REPLY",pref_rep)
 SET stat = alterlist(pref_req->context,3)
 SET pref_req->context[1].name = "default"
 SET pref_req->context[1].id = "system"
 SET pref_req->context[2].name = "position"
 SET pref_req->context[2].id = spositioncd
 SET pref_req->context[3].name = "user"
 SET pref_req->context[3].id = spersonid
 SET pref_req->sectionname = "module"
 SET pref_req->sectionid = "cvnet"
 SET pref_req->recurse = 1
 EXECUTE cv_get_prefs  WITH replace("REQUEST",pref_req), replace("REPLY",pref_rep)
 DECLARE pagewidth = i4 WITH constant(255)
 DECLARE pageheight = i4 WITH constant(60)
 DECLARE outputline = vc
 SELECT
  x = 0
  FROM dummyt
  DETAIL
   FOR (groupidx = 1 TO size(pref_rep->group,5))
     outputline = trim(substring(1,(pagewidth - 1),pref_rep->group[groupidx].groupname),3),
     outputline, row + 1
     IF ((row > (pageheight - 1)))
      BREAK
     ENDIF
     FOR (entryidx = 1 TO size(pref_rep->group[groupidx].entry,5))
       col 5, outputline = trim(substring(1,((pagewidth - col) - 1),pref_rep->group[groupidx].entry[
         entryidx].entryname),3), outputline,
       row + 1
       IF ((row > (pageheight - 1)))
        BREAK
       ENDIF
       FOR (valueidx = 1 TO size(pref_rep->group[groupidx].entry[entryidx].values,5))
         col 10, outputline = trim(substring(1,((pagewidth - col) - 1),pref_rep->group[groupidx].
           entry[entryidx].values[valueidx].value),3), outputline,
         row + 1
         IF ((row > (pageheight - 1)))
          BREAK
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
  WITH nocounter, maxcol = value(pagewidth), maxrow = value(pageheight)
 ;end select
END GO

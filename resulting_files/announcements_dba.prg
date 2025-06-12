CREATE PROGRAM announcements:dba
 PAINT
 SET header = fillstring(60," ")
 SET annl[1000] = fillstring(75," ")
 SET footer = fillstring(60," ")
 SET blankline = fillstring(75," ")
 SET annline = fillstring(75," ")
 SET outline = fillstring(125," ")
 SET blank_cnt = 0
 SET pos = 0
 SET wr = "\par "
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"P O W E R C H A R T    A N N O U N C E M E N T S")
 CALL text(4,3,"Header:")
 CALL text(5,3,"Body:")
 CALL text(20,3,"Footer:")
 CALL text(22,3,"Correct? Y/N/R   ('R' to save & reset so all user's will see the updates.)")
#accepts
 CALL accept(4,11,"P(60);CU","ANNOUNCEMENTS")
 SET header = curaccept
#search_head
 SET pos = findstring("'",header)
 IF (pos > 0)
  SET stat = movestring("^",1,header,pos,1)
  GO TO search_head
 ENDIF
 SET l = 6
 SET x = 1
#body
 SET l = (l+ 1)
 IF (l > 18)
  SET l = 7
 ENDIF
 CALL text((l+ 1),3,blankline)
 CALL accept(l,3,"P(75);CDS")
 SET annline = curaccept
#search_body
 SET pos = findstring("'",annline)
 IF (pos > 0)
  SET stat = movestring("^",1,annline,pos,1)
  GO TO search_body
 ENDIF
 IF (substring(1,5,annline)="     ")
  SET blank_cnt = (blank_cnt+ 1)
  SET annl[x] = wr
  IF (blank_cnt > 1)
   GO TO footer
  ENDIF
 ELSE
  SET blank_cnt = 0
  IF (substring(74,2,annline)="  ")
   SET annl[x] = annline
   SET x = (x+ 1)
   SET annl[x] = wr
  ELSE
   SET annl[x] = annline
  ENDIF
 ENDIF
 IF (x < 1000)
  SET x = (x+ 1)
  GO TO body
 ENDIF
#footer
 SET maxlines = x
 CALL accept(20,11,"P(60);CU")
 SET footer = curaccept
#search_foot
 SET pos = findstring("'",footer)
 IF (pos > 0)
  SET stat = movestring("^",1,footer,pos,1)
  GO TO search_footer
 ENDIF
#correctyn
 CALL accept(22,18,"C;CU","R")
 SET correctyn = curaccept
 IF (((correctyn="Y") OR (correctyn="R")) )
  GO TO writefile
 ELSE
  GO TO accepts
 ENDIF
#writefile
 SELECT INTO "cclsource:dcp_announce.inc"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   disp1 = concat("set header = ","'",trim(header),"'"), disp1, row + 1,
   disp2 = concat("set footer = ","'",trim(footer),"'"), disp2, row + 1,
   disp3 = concat("set maxlines = ",trim(cnvtstring(maxlines))), disp3, row + 1,
   disp4 = concat("set annl[",trim(cnvtstring(maxlines)),"] = fillstring(75,' ')"), disp4, row + 1
   FOR (x = 1 TO maxlines)
     IF (substring(2,3,annl[x])="par")
      outline = concat("set annl[",trim(cnvtstring(x)),"]=' ",trim(annl[x])," '"), outline, row + 1
     ELSE
      outline = concat("set annl[",trim(cnvtstring(x)),"]='",trim(annl[x]),"'"), outline, row + 1
     ENDIF
   ENDFOR
  WITH maxcol = 300, maxrow = 1000
 ;end select
#resetprefs
 IF (correctyn="Y")
  GO TO theend
 ENDIF
 SET one_found = "N"
 SELECT INTO "nl:"
  n.name_value_prefs_id
  FROM name_value_prefs n
  WHERE n.pvc_name="SHOW_ANNOUNCE"
  DETAIL
   one_found = "Y"
  WITH nocounter
 ;end select
 IF (one_found="Y")
  UPDATE  FROM name_value_prefs n
   SET n.pvc_value = "1"
   WHERE n.pvc_name="SHOW_ANNOUNCE"
   WITH nocounter
  ;end update
  COMMIT
  GO TO theend
 ENDIF
 SET ap_id = 0
 SELECT INTO "nl:"
  a.app_prefs_id
  FROM app_prefs a
  WHERE a.application_number=600005
   AND a.position_cd=0
   AND a.prsnl_id=0
  DETAIL
   ap_id = a.app_prefs_id
  WITH nocounter
 ;end select
 IF (ap_id > 0)
  INSERT  FROM name_value_prefs n
   SET n.name_value_prefs_id = seq(carenet_seq,nextval), n.parent_entity_name = "APP_PREFS", n
    .parent_entity_id = ap_id,
    n.pvc_name = "SHOW_ANNOUNCE", n.pvc_value = "1", n.active_ind = 1,
    n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0, n.updt_task = 0,
    n.updt_applctx = 0, n.updt_cnt = 0
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#theend
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"P O W E R C H A R T    A N N O U N C E M E N T S")
 CALL text(10,5,"Please type %i cclsource:dcp_get_genview_announce.prg upon exit.")
 CALL text(12,15,"Press any key to exit.")
 CALL accept(15,38,"P;CU","X")
END GO

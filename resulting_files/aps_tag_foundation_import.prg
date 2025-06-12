CREATE PROGRAM aps_tag_foundation_import
 RECORD request(
   1 group_qual[1]
     2 group_desc = vc
     2 qual[*]
       3 display = c7
       3 sequence = i4
 )
 SET group_desc = fillstring(100," ")
 SET list_cnt = size(requestin->list_0,5)
 SET grp_cnt = 0
 SET tag_cnt = 0
 SET x = 0
 FOR (x = 1 TO list_cnt)
   IF ((group_desc != requestin->list_0[x].group_desc))
    SET grp_cnt = (grp_cnt+ 1)
    IF (grp_cnt > 1)
     SET stat = alter(request->group_qual,grp_cnt)
    ENDIF
    SET request->group_qual[grp_cnt].group_desc = requestin->list_0[x].group_desc
    SET group_desc = requestin->list_0[x].group_desc
    SET tag_cnt = 0
   ENDIF
   SET tag_cnt = (tag_cnt+ 1)
   SET stat = alterlist(request->group_qual[grp_cnt].qual,tag_cnt)
   SET request->group_qual[grp_cnt].qual[tag_cnt].display = requestin->list_0[x].display
   SET request->group_qual[grp_cnt].qual[tag_cnt].sequence = cnvtint(requestin->list_0[x].sequence)
 ENDFOR
 EXECUTE aps_insert_tag_foundation
END GO

CREATE PROGRAM bed_get_locs_for_position:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 locations[*]
       3 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = size(request->positions,5)
 SET stat = alterlist(reply->positions,pcnt)
 FOR (p = 1 TO pcnt)
   SET reply->positions[p].code_value = request->positions[p].code_value
   SET lcnt = 0
   DECLARE pos = vc
   DECLARE posstr = c255 WITH noconstant("")
   SET b = 0
   SET pos = cnvtstring(request->positions[p].code_value,20,2)
   SET b = (textlen(pos)+ 10)
   SET posstr = concat("prefgroup=",trim(pos))
   SELECT INTO "NL:"
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=position location,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id
      AND substring(1,b,p2.dist_name)=posstr)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id)
    DETAIL
     lcnt = (lcnt+ 1), stat = alterlist(reply->positions[p].locations,lcnt), a = findstring(
      "prefgroup=",p2.dist_name,1,1),
     b = findstring("=",p2.dist_name,a), c = findstring(",",p2.dist_name,a), grpstr = substring((b+ 1
      ),((c - b) - 1),p2.dist_name),
     a = findstring("^",grpstr), b = textlen(grpstr), reply->positions[p].locations[lcnt].code_value
      = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
    WITH nocounter
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

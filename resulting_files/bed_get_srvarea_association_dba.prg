CREATE PROGRAM bed_get_srvarea_association:dba
 FREE SET reply
 RECORD reply(
   1 srvareas[*]
     2 code_value = f8
     2 facilities[*]
       3 code_value = f8
       3 disp = vc
       3 mean = vc
       3 desc = vc
       3 buildings[*]
         4 code_value = f8
         4 disp = vc
         4 mean = vc
         4 desc = vc
         4 units[*]
           5 code_value = f8
           5 disp = vc
           5 mean = vc
           5 desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 unit_cd = f8
 )
 FREE SET bld
 RECORD bld(
   1 qual[*]
     2 cd = f8
 )
 DECLARE srvarea_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"SRVAREA"))
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE building_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE index1 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 FOR (x = 1 TO size(request->srvareas,5))
   SET stat = alterlist(reply->srvareas,x)
   SET reply->srvareas[x].code_value = request->srvareas[x].code_value
   SET cnt = 0
   SELECT INTO "nl:"
    FROM location_group lg
    PLAN (lg
     WHERE (lg.parent_loc_cd=request->srvareas[x].code_value)
      AND lg.location_group_type_cd=srvarea_cd
      AND lg.active_ind=1)
    ORDER BY lg.sequence
    HEAD REPORT
     stat = alterlist(temp->qual,100), cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1
      AND cnt > 100)
      stat = alterlist(temp->qual,(cnt+ 10))
     ENDIF
     temp->qual[cnt].unit_cd = lg.child_loc_cd
    FOOT REPORT
     stat = alterlist(temp->qual,cnt)
    WITH nocounter
   ;end select
   IF (cnt > 0)
    SET bcnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt)),
      location_group l
     PLAN (d)
      JOIN (l
      WHERE (l.child_loc_cd=temp->qual[d.seq].unit_cd)
       AND l.location_group_type_cd=building_cd
       AND l.root_loc_cd=0
       AND l.active_ind=1)
     HEAD REPORT
      stat = alterlist(bld->qual,100), bcnt = 0
     HEAD l.parent_loc_cd
      bcnt = (bcnt+ 1)
      IF (mod(bcnt,10)=1
       AND bcnt > 100)
       stat = alterlist(bld->qual,(bcnt+ 10))
      ENDIF
      bld->qual[bcnt].cd = l.parent_loc_cd
     FOOT  l.parent_loc_cd
      row + 0
     FOOT REPORT
      stat = alterlist(bld->qual,bcnt)
     WITH nocounter
    ;end select
    SET fcnt = 0
    SET bldcnt = 0
    IF (bcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(bcnt)),
       location_group l,
       code_value c1,
       code_value c2
      PLAN (d)
       JOIN (l
       WHERE (l.child_loc_cd=bld->qual[d.seq].cd)
        AND l.location_group_type_cd=facility_cd
        AND l.root_loc_cd=0
        AND l.active_ind=1)
       JOIN (c1
       WHERE c1.code_value=l.parent_loc_cd
        AND c1.active_ind=1)
       JOIN (c2
       WHERE c2.code_value=l.child_loc_cd
        AND c2.active_ind=1)
      ORDER BY l.parent_loc_cd, l.child_loc_cd
      HEAD REPORT
       stat = alterlist(reply->srvareas[x].facilities,100), fcnt = 0
      HEAD l.parent_loc_cd
       bldcnt = 0, fcnt = (fcnt+ 1)
       IF (mod(fcnt,10)=1
        AND fcnt > 100)
        stat = alterlist(reply->srvareas[x].facilities,(fcnt+ 10))
       ENDIF
       reply->srvareas[x].facilities[fcnt].code_value = l.parent_loc_cd, reply->srvareas[x].
       facilities[fcnt].disp = c1.display, reply->srvareas[x].facilities[fcnt].mean = c1.cdf_meaning,
       reply->srvareas[x].facilities[fcnt].desc = c1.description, stat = alterlist(reply->srvareas[x]
        .facilities[fcnt].buildings,100)
      HEAD l.child_loc_cd
       bldcnt = (bldcnt+ 1)
       IF (mod(bldcnt,10)=1
        AND bldcnt > 100)
        stat = alterlist(reply->srvareas[x].facilities[fcnt].buildings,(bldcnt+ 10))
       ENDIF
       reply->srvareas[x].facilities[fcnt].buildings[bldcnt].code_value = l.child_loc_cd, reply->
       srvareas[x].facilities[fcnt].buildings[bldcnt].disp = c2.display, reply->srvareas[x].
       facilities[fcnt].buildings[bldcnt].mean = c2.cdf_meaning,
       reply->srvareas[x].facilities[fcnt].buildings[bldcnt].desc = c2.description
      FOOT  l.parent_loc_cd
       stat = alterlist(reply->srvareas[x].facilities[fcnt].buildings,bldcnt)
      FOOT REPORT
       stat = alterlist(reply->srvareas[x].facilities,fcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(fcnt)),
       location_group l,
       code_value c
      PLAN (d1)
       JOIN (l
       WHERE expand(idx1,1,size(reply->srvareas[x].facilities[d1.seq].buildings,5),l.parent_loc_cd,
        reply->srvareas[x].facilities[d1.seq].buildings[idx1].code_value)
        AND expand(idx2,1,size(temp->qual,5),l.child_loc_cd,temp->qual[idx2].unit_cd)
        AND l.location_group_type_cd=building_cd
        AND l.root_loc_cd=0
        AND l.active_ind=1)
       JOIN (c
       WHERE c.code_value=l.child_loc_cd
        AND c.active_ind=1)
      ORDER BY l.parent_loc_cd, l.child_loc_cd
      HEAD l.parent_loc_cd
       ucnt = 0, bldcnt = locateval(index1,1,size(reply->srvareas[x].facilities[d1.seq].buildings,5),
        l.parent_loc_cd,reply->srvareas[x].facilities[d1.seq].buildings[index1].code_value)
      HEAD l.child_loc_cd
       IF (bldcnt > 0)
        ucnt = (ucnt+ 1), stat = alterlist(reply->srvareas[x].facilities[d1.seq].buildings[bldcnt].
         units,ucnt), reply->srvareas[x].facilities[d1.seq].buildings[bldcnt].units[ucnt].code_value
         = l.child_loc_cd,
        reply->srvareas[x].facilities[d1.seq].buildings[bldcnt].units[ucnt].disp = c.display, reply->
        srvareas[x].facilities[d1.seq].buildings[bldcnt].units[ucnt].mean = c.cdf_meaning, reply->
        srvareas[x].facilities[d1.seq].buildings[bldcnt].units[ucnt].desc = c.description
       ENDIF
      WITH nocounter, expand = 1
     ;end select
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (size(reply->srvareas,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

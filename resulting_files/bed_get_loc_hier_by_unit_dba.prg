CREATE PROGRAM bed_get_loc_hier_by_unit:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facilities[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 buildings[*]
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 units[*]
          4 code_value = f8
          4 display = vc
          4 description = vc
          4 location_type
            5 loc_type_code = f8
            5 loc_type_disp = vc
            5 loc_type_mean = vc
          4 active_ind = i2
          4 active_rel_ind = i2
        3 active_ind = i2
        3 active_rel_ind = i2
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE bcnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE ucnt = i4 WITH noconstant(0)
 DECLARE idx1 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET ucnt = 0
 SET facility_cd = 0
 SET facility_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET ucnt = size(request->location_units,5)
 IF (ucnt=0)
  GO TO exit_script
 ENDIF
 FREE SET bld
 RECORD bld(
   1 qual[*]
     2 cd = f8
 )
 SET idx1 = 0
 SELECT INTO "nl:"
  FROM location_group l
  WHERE expand(idx1,1,ucnt,l.child_loc_cd,request->location_units[idx1].code_value)
   AND l.root_loc_cd=0
   AND ((l.active_ind=1) OR ((request->inc_inactive_ind=1)))
  HEAD REPORT
   stat = alterlist(bld->qual,100), bcnt = 0
  HEAD l.parent_loc_cd
   bcnt = (bcnt+ 1)
   IF (mod(bcnt,10)=1
    AND bcnt > 100)
    stat = alterlist(bld->qual,(bcnt+ 10))
   ENDIF
   bld->qual[bcnt].cd = l.parent_loc_cd
  FOOT REPORT
   stat = alterlist(bld->qual,bcnt)
  WITH nocounter, expand = 1
 ;end select
 SET fcnt = 0
 SET bldcnt = 0
 SET idx1 = 0
 IF (bcnt > 0)
  SELECT INTO "nl:"
   FROM location_group l,
    code_value c1,
    code_value c2
   PLAN (l
    WHERE expand(idx1,1,bcnt,l.child_loc_cd,bld->qual[idx1].cd)
     AND l.location_group_type_cd=facility_cd
     AND l.root_loc_cd=0
     AND ((l.active_ind=1) OR ((request->inc_inactive_ind=1))) )
    JOIN (c1
    WHERE c1.code_value=l.parent_loc_cd
     AND ((c1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
    JOIN (c2
    WHERE c2.code_value=l.child_loc_cd
     AND ((c2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
   ORDER BY l.parent_loc_cd, l.child_loc_cd
   HEAD REPORT
    stat = alterlist(reply->facilities,100), fcnt = 0
   HEAD l.parent_loc_cd
    bldcnt = 0, fcnt = (fcnt+ 1)
    IF (mod(fcnt,10)=1
     AND fcnt > 100)
     stat = alterlist(reply->facilities,(fcnt+ 10))
    ENDIF
    reply->facilities[fcnt].code_value = l.parent_loc_cd, reply->facilities[fcnt].display = c1
    .display, reply->facilities[fcnt].description = c1.description,
    reply->facilities[fcnt].active_ind = c1.active_ind, stat = alterlist(reply->facilities[fcnt].
     buildings,100), bldcnt = 0
   HEAD l.child_loc_cd
    bldcnt = (bldcnt+ 1)
    IF (mod(bldcnt,10)=1
     AND bldcnt > 100)
     stat = alterlist(reply->facilities[fcnt].buildings,(bldcnt+ 10))
    ENDIF
    reply->facilities[fcnt].buildings[bldcnt].code_value = l.child_loc_cd, reply->facilities[fcnt].
    buildings[bldcnt].display = c2.display, reply->facilities[fcnt].buildings[bldcnt].description =
    c2.description,
    reply->facilities[fcnt].buildings[bldcnt].active_ind = c2.active_ind, reply->facilities[fcnt].
    buildings[bldcnt].active_rel_ind = l.active_ind
   FOOT  l.parent_loc_cd
    stat = alterlist(reply->facilities[fcnt].buildings,bldcnt)
   FOOT REPORT
    stat = alterlist(reply->facilities,fcnt)
   WITH nocounter, expand = 1
  ;end select
  SET idx1 = 0
  SET idx2 = 0
  SET fcnt = 0
  SET bcnt = 0
  SET ucnt = 0
  FOR (fcnt = 1 TO size(reply->facilities,5))
    SELECT INTO "nl:"
     FROM location_group l,
      code_value c,
      location l1,
      code_value cv
     PLAN (l
      WHERE expand(idx1,1,size(reply->facilities[fcnt].buildings,5),l.parent_loc_cd,reply->
       facilities[fcnt].buildings[idx1].code_value)
       AND expand(idx2,1,size(request->location_units,5),l.child_loc_cd,request->location_units[idx2]
       .code_value)
       AND l.root_loc_cd=0
       AND ((l.active_ind=1) OR ((request->inc_inactive_ind=1))) )
      JOIN (c
      WHERE c.code_value=l.child_loc_cd
       AND ((c.active_ind=1) OR ((request->inc_inactive_ind=1))) )
      JOIN (l1
      WHERE l1.location_cd=l.child_loc_cd)
      JOIN (cv
      WHERE cv.code_value=l1.location_type_cd
       AND cv.active_ind=1)
     ORDER BY l.parent_loc_cd, l.child_loc_cd
     HEAD REPORT
      ucnt = 0, bcnt = 0
     HEAD l.parent_loc_cd
      ucnt = 0, bcnt = (bcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,100)
     HEAD l.child_loc_cd
      IF (l.child_loc_cd > 0)
       ucnt = (ucnt+ 1)
       IF (mod(ucnt,10)=1
        AND ucnt > 100)
        stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,(ucnt+ 10))
       ENDIF
       reply->facilities[fcnt].buildings[bcnt].units[ucnt].code_value = l.child_loc_cd, reply->
       facilities[fcnt].buildings[bcnt].units[ucnt].display = c.display, reply->facilities[fcnt].
       buildings[bcnt].units[ucnt].description = c.description,
       reply->facilities[fcnt].buildings[bcnt].units[ucnt].location_type.loc_type_code = l1
       .location_type_cd, reply->facilities[fcnt].buildings[bcnt].units[ucnt].location_type.
       loc_type_disp = cv.display, reply->facilities[fcnt].buildings[bcnt].units[ucnt].location_type.
       loc_type_mean = cv.cdf_meaning,
       reply->facilities[fcnt].buildings[bcnt].units[ucnt].active_ind = c.active_ind, reply->
       facilities[fcnt].buildings[bcnt].units[ucnt].active_rel_ind = l.active_ind
      ENDIF
     FOOT  l.parent_loc_cd
      stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,ucnt)
     WITH nocounter, expand = 1
    ;end select
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

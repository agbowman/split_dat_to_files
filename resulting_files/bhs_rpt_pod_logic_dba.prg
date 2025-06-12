CREATE PROGRAM bhs_rpt_pod_logic:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD loc(
   1 qual[*]
     2 loc = vc
     2 unit = vc
     2 room = vc
     2 bed = vc
 )
 RECORD locf(
   1 qual[*]
     2 poddesc = vc
     2 loc = vc
     2 unit = vc
     2 room = vc
     2 bed = vc
     2 printer = vc
 )
 SET cnt = 0
 SET cnt2 = 0
 SELECT DISTINCT
  l.location_cd, unit = trim(substring(1,10,uar_get_code_display(l.location_cd)),3), room = trim(
   substring(1,7,uar_get_code_display(lg2.child_loc_cd)),3),
  bed = trim(substring(1,4,uar_get_code_display(lg3.child_loc_cd)),3)
  FROM location l,
   location_group lg,
   location_group lg2,
   location_group lg3
  PLAN (l
   WHERE l.location_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
     AND code_set=222))
    AND l.active_ind=1)
   JOIN (lg
   WHERE lg.child_loc_cd=l.location_cd
    AND lg.parent_loc_cd IN (
   (SELECT
    child_loc_cd
    FROM location_group
    WHERE (parent_loc_cd=
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=220
      AND cdf_meaning="FACILITY"
      AND active_ind=1
      AND description="BAYSTATE MEDICAL CENTER"))
     AND active_ind=1)))
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg.child_loc_cd
    AND lg2.active_ind=1)
   JOIN (lg3
   WHERE lg3.parent_loc_cd=lg2.child_loc_cd
    AND lg3.active_ind=1)
  ORDER BY l.location_cd, unit, room,
   bed
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(loc->qual,cnt), loc->qual[cnt].loc = build("BMCBMC",unit,room,bed
    ),
   loc->qual[cnt].unit = unit, loc->qual[cnt].room = room, loc->qual[cnt].bed = bed
  WITH nocounter
 ;end select
 CALL echorecord(loc)
 SELECT INTO "NL:"
  FROM code_value cv1,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=103026)
   JOIN (cv2
   WHERE cv2.code_set=outerjoin(104103)
    AND cv2.display=outerjoin(cv1.definition))
  HEAD REPORT
   cnt2 = (cnt2+ 1), stat = alterlist(locf->qual,cnt2), locf->qual[cnt2].loc =
   "No printer = not complete in podlog",
   cnt2 = (cnt2+ 1), stat = alterlist(locf->qual,cnt2), locf->qual[cnt2].loc =
   "no unit = in PodLog but not a true location"
  DETAIL
   pos = 0, locnum = 0, pos = locateval(locnum,1,cnt,cv1.display,loc->qual[locnum].loc),
   cnt2 = (cnt2+ 1), stat = alterlist(locf->qual,cnt2), locf->qual[cnt2].poddesc = cv1.display,
   locf->qual[cnt2].printer = cv2.definition
   IF (pos > 0)
    locf->qual[cnt2].loc = loc->qual[pos].loc, locf->qual[cnt2].unit = loc->qual[pos].unit, locf->
    qual[cnt2].room = loc->qual[pos].room,
    locf->qual[cnt2].bed = loc->qual[pos].bed
   ENDIF
  WITH separator = " ", format
 ;end select
 CALL echorecord(locf)
 SELECT INTO  $OUTDEV
  poddesc = substring(1,40,locf->qual[d.seq].poddesc), loc = substring(1,40,locf->qual[d.seq].loc),
  unit = substring(1,10,locf->qual[d.seq].unit),
  room = substring(1,7,locf->qual[d.seq].room), bed = substring(1,5,locf->qual[d.seq].bed), printer
   = substring(1,30,locf->qual[d.seq].printer)
  FROM (dummyt d  WITH seq = cnt2)
  PLAN (d)
  WITH separator = " ", format
 ;end select
END GO

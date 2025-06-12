CREATE PROGRAM bbd_get_print_mult_info:dba
 RECORD reply(
   1 print_location_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status = "S"
 SET cdfmeaning = fillstring(12," ")
 SET cdfmeaning = request->print_type
 SET code_cnt = 1
 SET print_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,cdfmeaning,code_cnt,print_type_cd)
 IF ((request->debug_ind=1))
  CALL echo(build("Print type code:",print_type_cd))
 ENDIF
 IF (print_type_cd=0)
  SET reply->status = "F"
  GO TO exitscript
 ENDIF
 SELECT INTO "nl:"
  l.location_cd, l2.location_cd, l3.location_cd,
  l4.location_cd, l5.location_cd, l6.location_cd,
  l7.location_cd, l8.location_cd
  FROM location_group lg,
   location_group lg2,
   location_group lg3,
   location_group lg4,
   location_group lg5,
   location_group lg6,
   location_group lg7,
   location_group lg8,
   location l,
   location l2,
   location l3,
   location l4,
   location l5,
   location l6,
   location l7,
   location l8,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d5,
   dummyt d6,
   dummyt d7
  PLAN (lg
   WHERE (lg.parent_loc_cd=request->location_cd)
    AND (lg.root_loc_cd=request->root_cd)
    AND lg.active_ind=1)
   JOIN (l
   WHERE l.location_cd=lg.child_loc_cd
    AND l.active_ind=1)
   JOIN (d1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg.child_loc_cd
    AND (lg2.root_loc_cd=request->root_cd)
    AND lg2.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg2.child_loc_cd
    AND l2.active_ind=1)
   JOIN (d2)
   JOIN (lg3
   WHERE lg3.parent_loc_cd=lg2.child_loc_cd
    AND (lg3.root_loc_cd=request->root_cd)
    AND lg3.active_ind=1)
   JOIN (l3
   WHERE l3.location_cd=lg3.child_loc_cd
    AND l3.active_ind=1)
   JOIN (d3)
   JOIN (lg4
   WHERE lg4.parent_loc_cd=lg3.child_loc_cd
    AND (lg4.root_loc_cd=request->root_cd)
    AND lg4.active_ind=1)
   JOIN (l4
   WHERE l4.location_cd=lg4.child_loc_cd
    AND l4.active_ind=1)
   JOIN (d4)
   JOIN (lg5
   WHERE lg5.parent_loc_cd=lg4.child_loc_cd
    AND (lg5.root_loc_cd=request->root_cd)
    AND lg5.active_ind=1)
   JOIN (l5
   WHERE l5.location_cd=lg5.child_loc_cd
    AND l5.active_ind=1)
   JOIN (d5)
   JOIN (lg6
   WHERE lg6.parent_loc_cd=lg5.child_loc_cd
    AND (lg6.root_loc_cd=request->root_cd)
    AND lg6.active_ind=1)
   JOIN (l6
   WHERE l6.location_cd=lg6.child_loc_cd
    AND l6.active_ind=1)
   JOIN (d6)
   JOIN (lg7
   WHERE lg7.parent_loc_cd=lg6.child_loc_cd
    AND (lg7.root_loc_cd=request->root_cd)
    AND lg7.active_ind=1)
   JOIN (l7
   WHERE l7.location_cd=lg7.child_loc_cd
    AND l7.active_ind=1)
   JOIN (d7)
   JOIN (lg8
   WHERE lg8.parent_loc_cd=lg7.child_loc_cd
    AND (lg8.root_loc_cd=request->root_cd)
    AND lg8.active_ind=1)
   JOIN (l8
   WHERE l8.location_cd=lg8.child_loc_cd
    AND l8.active_ind=1)
  DETAIL
   IF ((request->debug_ind=1))
    CALL echo(build("LOCATION TYPE CODE1",l.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE2",l2.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE3",l3.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE4",l4.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE5",l5.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE6",l6.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE7",l7.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE8",l8.location_type_cd))
   ENDIF
   IF (l.location_type_cd=print_type_cd)
    reply->print_location_cd = l.location_cd
   ELSEIF (l2.location_type_cd=print_type_cd)
    reply->print_location_cd = l2.location_cd
   ELSEIF (l3.location_type_cd=print_type_cd)
    reply->print_location_cd = l3.location_cd
   ELSEIF (l4.location_type_cd=print_type_cd)
    reply->print_location_cd = l4.location_cd
   ELSEIF (l5.location_type_cd=print_type_cd)
    reply->print_location_cd = l5.location_cd
   ELSEIF (l6.location_type_cd=print_type_cd)
    reply->print_location_cd = l6.location_cd
   ELSEIF (l7.location_type_cd=print_type_cd)
    reply->print_location_cd = l7.location_cd
   ELSEIF (l8.location_type_cd=print_type_cd)
    reply->print_location_cd = l8.location_cd
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4, outerjoin = d5,
   outerjoin = d6, outerjoin = d7, outerjoin = d8
 ;end select
 IF (curqual=0)
  SET reply->print_location_cd = 0
 ELSE
  IF ((reply->print_location_cd > 0))
   GO TO exitscript
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  l.location_cd, l2.location_cd, l3.location_cd,
  l4.location_cd, l5.location_cd, l6.location_cd,
  l7.location_cd, l8.location_cd
  FROM location_group lg,
   location_group lg2,
   location_group lg3,
   location_group lg4,
   location_group lg5,
   location_group lg6,
   location_group lg7,
   location_group lg8,
   location l,
   location l2,
   location l3,
   location l4,
   location l5,
   location l6,
   location l7,
   location l8,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d5,
   dummyt d6,
   dummyt d7
  PLAN (lg
   WHERE (lg.child_loc_cd=request->location_cd)
    AND (lg.root_loc_cd=request->root_cd)
    AND lg.active_ind=1)
   JOIN (l
   WHERE l.location_cd=lg.parent_loc_cd
    AND l.active_ind=1)
   JOIN (d1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND (lg2.root_loc_cd=request->root_cd)
    AND lg2.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg2.parent_loc_cd
    AND l2.active_ind=1)
   JOIN (d2)
   JOIN (lg3
   WHERE lg3.child_loc_cd=lg2.parent_loc_cd
    AND (lg3.root_loc_cd=request->root_cd)
    AND lg3.active_ind=1)
   JOIN (l3
   WHERE l3.location_cd=lg3.parent_loc_cd
    AND l3.active_ind=1)
   JOIN (d3)
   JOIN (lg4
   WHERE lg4.child_loc_cd=lg3.parent_loc_cd
    AND (lg4.root_loc_cd=request->root_cd)
    AND lg4.active_ind=1)
   JOIN (l4
   WHERE l4.location_cd=lg4.parent_loc_cd
    AND l4.active_ind=1)
   JOIN (d4)
   JOIN (lg5
   WHERE lg5.child_loc_cd=lg4.parent_loc_cd
    AND (lg5.root_loc_cd=request->root_cd)
    AND lg5.active_ind=1)
   JOIN (l5
   WHERE l5.location_cd=lg5.parent_loc_cd
    AND l5.active_ind=1)
   JOIN (d5)
   JOIN (lg6
   WHERE lg6.child_loc_cd=lg5.parent_loc_cd
    AND (lg6.root_loc_cd=request->root_cd)
    AND lg6.active_ind=1)
   JOIN (l6
   WHERE l6.location_cd=lg6.parent_loc_cd
    AND l6.active_ind=1)
   JOIN (d6)
   JOIN (lg7
   WHERE lg7.child_loc_cd=lg6.parent_loc_cd
    AND (lg7.root_loc_cd=request->root_cd)
    AND lg7.active_ind=1)
   JOIN (l7
   WHERE l7.location_cd=lg7.parent_loc_cd
    AND l7.active_ind=1)
   JOIN (d7)
   JOIN (lg8
   WHERE lg8.child_loc_cd=lg7.parent_loc_cd
    AND (lg8.root_loc_cd=request->root_cd)
    AND lg8.active_ind=1)
   JOIN (l8
   WHERE l8.location_cd=lg8.parent_loc_cd
    AND l8.active_ind=1)
  DETAIL
   IF ((request->debug_ind=1))
    CALL echo(build("LOCATION TYPE CODE1",l.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE2",l2.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE3",l3.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE4",l4.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE5",l5.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE6",l6.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE7",l7.location_type_cd)),
    CALL echo(build("LOCATION TYPE CODE8",l8.location_type_cd))
   ENDIF
   IF (l.location_type_cd=print_type_cd)
    reply->print_location_cd = l.location_cd
   ELSEIF (l2.location_type_cd=print_type_cd)
    reply->print_location_cd = l2.location_cd
   ELSEIF (l3.location_type_cd=print_type_cd)
    reply->print_location_cd = l3.location_cd
   ELSEIF (l4.location_type_cd=print_type_cd)
    reply->print_location_cd = l4.location_cd
   ELSEIF (l5.location_type_cd=print_type_cd)
    reply->print_location_cd = l5.location_cd
   ELSEIF (l6.location_type_cd=print_type_cd)
    reply->print_location_cd = l6.location_cd
   ELSEIF (l7.location_type_cd=print_type_cd)
    reply->print_location_cd = l7.location_cd
   ELSEIF (l8.location_type_cd=print_type_cd)
    reply->print_location_cd = l8.location_cd
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4, outerjoin = d5,
   outerjoin = d6, outerjoin = d7, outerjoin = d8
 ;end select
 IF (curqual=0)
  SET reply->print_location_cd = 0
 ENDIF
#exitscript
 IF ((reply->status="F"))
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->debug_ind=1))
  CALL echo(build("location code...",reply->print_location_cd))
  CALL echo(build("reply->status...",reply->status))
 ENDIF
END GO

CREATE PROGRAM bed_get_mdro_defined_loc:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facility_cds[*]
      2 facility_cd = f8
      2 facility_disp = c40
      2 facility_desc = vc
      2 facility_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 facility_cds[*]
     2 facility_cd = f8
     2 facility_display = vc
     2 facility_description = vc
 )
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 SET cnt = 0
 SET index = 0
 IF ((request->all_loc_ind=1))
  SELECT INTO "nl:"
   FROM br_mdro_cat_event e
   PLAN (e
    WHERE e.location_cd > 0)
   ORDER BY e.location_cd
   HEAD e.location_cd
    cnt = (cnt+ 1), stat = alterlist(reply->facility_cds,cnt), reply->facility_cds[cnt].facility_cd
     = e.location_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM br_mdro_cat_organism o
   PLAN (o
    WHERE o.location_cd > 0)
   ORDER BY o.location_cd
   HEAD o.location_cd
    index = locateval(num,start,size(reply->facility_cds,5),o.location_cd,reply->facility_cds[num].
     facility_cd)
    IF (index=0)
     cnt = (cnt+ 1), stat = alterlist(reply->facility_cds,cnt), reply->facility_cds[cnt].facility_cd
      = o.location_cd
    ENDIF
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF ((request->mdro_type_ind=1))
  SELECT INTO "nl:"
   FROM br_mdro_cat_event e,
    br_mdro_cat cat
   PLAN (e
    WHERE e.location_cd > 0)
    JOIN (cat
    WHERE cat.br_mdro_cat_id=e.br_mdro_cat_id
     AND (cat.cat_type_flag=request->category_type_ind))
   ORDER BY e.location_cd
   HEAD e.location_cd
    cnt = (cnt+ 1), stat = alterlist(reply->facility_cds,cnt), reply->facility_cds[cnt].facility_cd
     = e.location_cd
   WITH nocounter
  ;end select
 ELSEIF ((request->mdro_type_ind=2))
  SELECT INTO "nl:"
   FROM br_mdro_cat_organism o,
    br_mdro_cat cat
   PLAN (o
    WHERE o.location_cd > 0)
    JOIN (cat
    WHERE cat.br_mdro_cat_id=o.br_mdro_cat_id
     AND (cat.cat_type_flag=request->category_type_ind))
   ORDER BY o.location_cd
   HEAD o.location_cd
    cnt = (cnt+ 1), stat = alterlist(reply->facility_cds,cnt), reply->facility_cds[cnt].facility_cd
     = o.location_cd
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

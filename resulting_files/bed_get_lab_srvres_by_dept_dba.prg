CREATE PROGRAM bed_get_lab_srvres_by_dept:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 activity_type_code_value = f8
    1 departments[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 departments[*]
      2 code_value = f8
      2 sections[*]
        3 code_value = f8
        3 display = c40
        3 description = c60
        3 subsections[*]
          4 code_value = f8
          4 display = c40
          4 description = c60
          4 multiplexor_ind = i2
          4 resources[*]
            5 code_value = f8
            5 display = c40
            5 description = c60
            5 mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE glb_code = f8 WITH public, noconstant(0.0)
 DECLARE hlx_code = f8 WITH public, noconstant(0.0)
 DECLARE ptl_code = f8 WITH public, noconstant(0.0)
 DECLARE ci_code = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(106,"GLB",1,glb_code)
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 SET stat = uar_get_meaning_by_codeset(106,"PTL",1,ptl_code)
 SET stat = uar_get_meaning_by_codeset(106,"CI",1,ci_code)
 CALL echo(request->activity_type_code_value)
 CALL echo(request->departments[1].code_value)
 SET reply->status_data.status = "F"
 SET lab_disclipline_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
   AND cv.active_ind=1
  DETAIL
   lab_disclipline_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE sr_parse = vc
 IF ((request->activity_type_code_value=0))
  SET sr_parse = build("sr.service_resource_cd = cv.code_value"," and sr.discipline_type_cd	= ",
   lab_disclipline_cd," and sr.active_ind = 1")
 ELSEIF ((request->activity_type_code_value=hlx_code))
  SET sr_parse = build("sr.service_resource_cd = cv.code_value"," and sr.discipline_type_cd	= ",
   lab_disclipline_cd," and sr.active_ind = 1"," and sr.activity_type_cd IN (",
   hlx_code,", ",glb_code,", ",ptl_code,
   ", ",ci_code,")")
 ELSE
  SET type_cd = build(request->activity_type_code_value)
  SET sr_parse = build("sr.service_resource_cd = cv.code_value"," and sr.discipline_type_cd	= ",
   lab_disclipline_cd," and sr.active_ind = 1"," and sr.activity_type_cd = ",
   type_cd)
 ENDIF
 CALL echo(sr_parse)
 SET dcnt = size(request->departments,5)
 SET stat = alterlist(reply->departments,dcnt)
 IF (dcnt > 0)
  FOR (d = 1 TO dcnt)
    SET reply->departments[d].code_value = request->departments[d].code_value
  ENDFOR
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = dcnt),
    resource_group rg,
    code_value cv,
    service_resource sr
   PLAN (d)
    JOIN (rg
    WHERE (rg.parent_service_resource_cd=reply->departments[d.seq].code_value)
     AND rg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=rg.child_service_resource_cd
     AND cv.code_set=221
     AND cv.cdf_meaning="SECTION"
     AND cv.active_ind=1)
    JOIN (sr
    WHERE parser(sr_parse))
   ORDER BY rg.parent_service_resource_cd
   HEAD rg.parent_service_resource_cd
    scnt = 0
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(reply->departments[d.seq].sections,scnt), reply->departments[d
    .seq].sections[scnt].code_value = cv.code_value,
    reply->departments[d.seq].sections[scnt].display = cv.display, reply->departments[d.seq].
    sections[scnt].description = cv.description
   WITH nocounter
  ;end select
  FOR (d = 1 TO dcnt)
   SET scnt = size(reply->departments[d].sections,5)
   IF (scnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = scnt),
      resource_group rg,
      code_value cv,
      service_resource sr,
      sub_section ss
     PLAN (d)
      JOIN (rg
      WHERE (rg.parent_service_resource_cd=reply->departments[d].sections[d.seq].code_value)
       AND rg.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=rg.child_service_resource_cd
       AND cv.code_set=221
       AND cv.cdf_meaning="SUBSECTION"
       AND cv.active_ind=1)
      JOIN (sr
      WHERE parser(sr_parse))
      JOIN (ss
      WHERE ss.service_resource_cd=outerjoin(sr.service_resource_cd))
     ORDER BY rg.parent_service_resource_cd
     HEAD rg.parent_service_resource_cd
      sscnt = 0
     DETAIL
      sscnt = (sscnt+ 1), stat = alterlist(reply->departments[d].sections[d.seq].subsections,sscnt),
      reply->departments[d].sections[d.seq].subsections[sscnt].code_value = cv.code_value,
      reply->departments[d].sections[d.seq].subsections[sscnt].display = cv.display, reply->
      departments[d].sections[d.seq].subsections[sscnt].description = cv.description
      IF (ss.service_resource_cd > 0)
       reply->departments[d].sections[d.seq].subsections[sscnt].multiplexor_ind = ss.multiplexor_ind
      ELSE
       reply->departments[d].sections[d.seq].subsections[sscnt].multiplexor_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  FOR (d = 1 TO dcnt)
   SET scnt = size(reply->departments[d].sections,5)
   FOR (s = 1 TO scnt)
    SET sscnt = size(reply->departments[d].sections[s].subsections,5)
    IF (sscnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = sscnt),
       resource_group rg,
       code_value cv,
       service_resource sr
      PLAN (d)
       JOIN (rg
       WHERE (rg.parent_service_resource_cd=reply->departments[d].sections[s].subsections[d.seq].
       code_value)
        AND rg.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=rg.child_service_resource_cd
        AND cv.code_set=221
        AND cv.cdf_meaning IN ("BENCH", "INSTRUMENT")
        AND cv.active_ind=1)
       JOIN (sr
       WHERE parser(sr_parse))
      ORDER BY rg.parent_service_resource_cd
      HEAD rg.parent_service_resource_cd
       rcnt = 0
      DETAIL
       rcnt = (rcnt+ 1), stat = alterlist(reply->departments[d].sections[s].subsections[d.seq].
        resources,rcnt), reply->departments[d].sections[s].subsections[d.seq].resources[rcnt].
       code_value = cv.code_value,
       reply->departments[d].sections[s].subsections[d.seq].resources[rcnt].display = cv.display,
       reply->departments[d].sections[s].subsections[d.seq].resources[rcnt].description = cv
       .description, reply->departments[d].sections[s].subsections[d.seq].resources[rcnt].mean = cv
       .cdf_meaning
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

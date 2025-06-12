CREATE PROGRAM bed_get_rel_dept_sect:dba
 FREE SET reply
 RECORD reply(
   1 sect_list[*]
     2 sect_code_value = f8
     2 sect_disp = vc
     2 sect_desc = vc
     2 sect_mean = vc
     2 sequence = i4
     2 subsect_list[*]
       3 subsect_code_value = f8
       3 subsect_disp = vc
       3 subsect_desc = vc
       3 subsect_mean = vc
       3 sequence = i4
       3 res_list[*]
         4 res_code_value = f8
         4 res_disp = vc
         4 res_desc = vc
         4 res_mean = vc
         4 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET sectcnt = 0
 SET subsectcnt = 0
 SET rescnt = 0
 SET error_flag = "F"
 SET sect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   sect_cd = cv.code_value
  WITH nocounter
 ;end select
 SET subsect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SUBSECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   subsect_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM resource_group rg,
   service_resource sr,
   code_value cv,
   br_name_value b
  PLAN (rg
   WHERE (rg.parent_service_resource_cd=request->dept_code_value)
    AND rg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=rg.child_service_resource_cd)
   JOIN (sr
   WHERE sr.service_resource_cd=outerjoin(rg.child_service_resource_cd))
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("SR_SECTION")
    AND b.br_value=outerjoin(cnvtstring(rg.child_service_resource_cd)))
  ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value,
   sr.service_resource_cd
  HEAD REPORT
   sectcnt = 0
  HEAD rg.child_service_resource_cd
   sectcnt = (sectcnt+ 1), stat = alterlist(reply->sect_list,sectcnt), reply->sect_list[sectcnt].
   sect_code_value = rg.child_service_resource_cd,
   reply->sect_list[sectcnt].sequence = rg.sequence
  HEAD cv.code_value
   reply->sect_list[sectcnt].sect_disp = cv.display, reply->sect_list[sectcnt].sect_desc = cv
   .description
   IF (b.br_name > "  ")
    reply->sect_list[sectcnt].sect_mean = b.br_name
   ENDIF
  WITH nocounter
 ;end select
 IF (sectcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = sectcnt),
    resource_group rg,
    service_resource sr,
    code_value cv,
    sub_section ss,
    br_name_value b
   PLAN (d)
    JOIN (rg
    WHERE (rg.parent_service_resource_cd=reply->sect_list[d.seq].sect_code_value)
     AND rg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=rg.child_service_resource_cd)
    JOIN (sr
    WHERE sr.service_resource_cd=outerjoin(rg.child_service_resource_cd))
    JOIN (ss
    WHERE ss.service_resource_cd=outerjoin(rg.child_service_resource_cd))
    JOIN (b
    WHERE b.br_nv_key1=outerjoin("SR_SUBSECTION")
     AND b.br_value=outerjoin(cnvtstring(rg.child_service_resource_cd)))
   ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value,
    sr.service_resource_cd
   HEAD d.seq
    subsectcnt = 0
   HEAD rg.child_service_resource_cd
    subsectcnt = (subsectcnt+ 1), stat = alterlist(reply->sect_list[d.seq].subsect_list,subsectcnt),
    reply->sect_list[d.seq].subsect_list[subsectcnt].subsect_code_value = rg
    .child_service_resource_cd,
    reply->sect_list[d.seq].subsect_list[subsectcnt].sequence = rg.sequence
   HEAD cv.code_value
    reply->sect_list[d.seq].subsect_list[subsectcnt].subsect_disp = cv.display, reply->sect_list[d
    .seq].subsect_list[subsectcnt].subsect_desc = cv.description
    IF (b.br_name > "  ")
     reply->sect_list[d.seq].subsect_list[subsectcnt].subsect_mean = b.br_name
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO sectcnt)
  SET subcnt = size(reply->sect_list[i].subsect_list,5)
  IF (subcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = subcnt),
     resource_group rg,
     service_resource sr,
     code_value cv,
     br_name_value b
    PLAN (d
     WHERE (reply->sect_list[i].subsect_list[d.seq].subsect_code_value > 0))
     JOIN (rg
     WHERE (rg.parent_service_resource_cd=reply->sect_list[i].subsect_list[d.seq].subsect_code_value)
      AND rg.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=rg.child_service_resource_cd)
     JOIN (sr
     WHERE sr.service_resource_cd=outerjoin(rg.child_service_resource_cd))
     JOIN (b
     WHERE b.br_nv_key1=outerjoin("SR_RESOURCE")
      AND b.br_value=outerjoin(cnvtstring(rg.child_service_resource_cd)))
    ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value
    HEAD rg.parent_service_resource_cd
     rescnt = 0
    HEAD rg.child_service_resource_cd
     rescnt = (rescnt+ 1), stat = alterlist(reply->sect_list[i].subsect_list[d.seq].res_list,rescnt),
     reply->sect_list[i].subsect_list[d.seq].res_list[rescnt].sequence = rg.sequence,
     reply->sect_list[i].subsect_list[d.seq].res_list[rescnt].res_code_value = rg
     .child_service_resource_cd
    HEAD cv.code_value
     reply->sect_list[i].subsect_list[d.seq].res_list[rescnt].res_disp = cv.display, reply->
     sect_list[i].subsect_list[d.seq].res_list[rescnt].res_desc = cv.description
     IF (b.br_name > "  ")
      reply->sect_list[i].subsect_list[d.seq].res_list[rescnt].res_mean = b.br_name
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->error_msg = concat("  >> PROGRAM NAME:  bed_get_rel_dept_sect  >>  ERROR MESSAGE:  ",
   error_msg)
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

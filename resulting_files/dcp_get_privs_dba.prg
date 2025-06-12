CREATE PROGRAM dcp_get_privs:dba
 RECORD reply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = c60
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = c60
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET priv_cnt = size(request->plist,5)
 SET stat = alterlist(reply->qual,priv_cnt)
 SET noexcepts = 0
 SET count1 = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 IF ((request->prsnl_id=0))
  SET request->prsnl_id = reqinfo->updt_id
 ENDIF
 IF ((request->position_cd=0))
  SET request->position_cd = reqinfo->position_cd
 ENDIF
 CALL echo(build("PLIST CNT = ",priv_cnt))
 FOR (x = 1 TO priv_cnt)
   IF ((request->plist[x].privilege_cd=0)
    AND (request->plist[x].privilege_mean > ""))
    SET code_set = 6016
    SET cdf_meaning = request->plist[x].privilege_mean
    EXECUTE cpm_get_cd_for_cdf
    SET request->plist[x].privilege_cd = code_value
    CALL echo(build("priv_mean   ",request->plist[x].privilege_mean))
    CALL echo(build("priv_cd   ",request->plist[x].privilege_cd))
   ENDIF
 ENDFOR
 FOR (x = 1 TO priv_cnt)
   SET reply->qual[x].priv_status = "F"
   SET count1 = 0
   SET noexcepts = 0
   SET reply->qual[x].privilege_cd = request->plist[x].privilege_cd
   IF ((request->chk_prsnl_ind=1)
    AND (request->prsnl_id > 0))
    SELECT INTO "NL:"
     p.privilege_id, pe.exception_id
     FROM priv_loc_reltn pl,
      privilege p,
      (dummyt d  WITH seq = 1),
      privilege_exception pe,
      (dummyt d1  WITH seq = 1),
      code_value cv
     PLAN (pl
      WHERE (pl.person_id=request->prsnl_id)
       AND pl.location_cd=0)
      JOIN (p
      WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
       AND (p.privilege_cd=request->plist[x].privilege_cd))
      JOIN (d
      WHERE d.seq=1)
      JOIN (pe
      WHERE pe.privilege_id=p.privilege_id)
      JOIN (d1
      WHERE d1.seq=1)
      JOIN (cv
      WHERE pe.event_set_name > " "
       AND cv.code_set=93
       AND cv.display_key=trim(cnvtupper(cnvtalphanum(pe.event_set_name))))
     ORDER BY pe.exception_id
     HEAD p.privilege_id
      count1 = 0, reply->qual[x].priv_value_cd = p.priv_value_cd, reply->qual[x].restr_method_cd = p
      .restr_method_cd
     DETAIL
      IF (pe.privilege_exception_id > 0)
       count1 = (count1+ 1)
       IF (count1 > size(reply->qual[x].excepts,5))
        stat = alterlist(reply->qual[x].excepts,(count1+ 10))
       ENDIF
       reply->qual[x].excepts[count1].exception_entity_name = pe.exception_entity_name, reply->qual[x
       ].excepts[count1].exception_type_cd = pe.exception_type_cd
       IF (pe.exception_id > 0)
        reply->qual[x].excepts[count1].exception_id = pe.exception_id
       ELSE
        reply->qual[x].excepts[count1].exception_id = cv.code_value
       ENDIF
      ELSE
       noexcepts = 1
      ENDIF
     FOOT  p.privilege_id
      IF (count1 > 0)
       stat = alterlist(reply->qual[x].excepts,count1), reply->qual[x].except_cnt = count1
      ENDIF
     WITH nocounter, outerjoin = d, outerjoin = d1
    ;end select
    IF (count1=0
     AND noexcepts=0)
     SET reply->qual[x].priv_status = "Z"
     SET reply->qual[x].priv_value_mean = "NOTDEFINED"
    ELSE
     SET reply->qual[x].priv_status = "S"
    ENDIF
   ENDIF
   CALL echo(build("count from prsnl level is:",count1))
   IF ((reply->qual[x].priv_status != "S")
    AND (request->chk_ppr_ind=1)
    AND (request->ppr_cd > 0))
    SELECT INTO "NL:"
     p.privilege_id, pe.exception_id
     FROM priv_loc_reltn pl,
      privilege p,
      (dummyt d  WITH seq = 1),
      privilege_exception pe,
      (dummyt d1  WITH seq = 1),
      code_value cv
     PLAN (pl
      WHERE (pl.ppr_cd=request->ppr_cd)
       AND pl.location_cd=0)
      JOIN (p
      WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
       AND (p.privilege_cd=request->plist[x].privilege_cd))
      JOIN (d
      WHERE d.seq=1)
      JOIN (pe
      WHERE pe.privilege_id=p.privilege_id)
      JOIN (d1
      WHERE d1.seq=1)
      JOIN (cv
      WHERE pe.event_set_name > " "
       AND cv.code_set=93
       AND cv.display_key=trim(cnvtupper(cnvtalphanum(pe.event_set_name))))
     ORDER BY pe.exception_id
     HEAD p.privilege_id
      count1 = 0, reply->qual[x].priv_value_cd = p.priv_value_cd, reply->qual[x].restr_method_cd = p
      .restr_method_cd
     DETAIL
      IF (pe.privilege_exception_id > 0)
       count1 = (count1+ 1)
       IF (count1 > size(reply->qual[x].excepts,5))
        stat = alterlist(reply->qual[x].excepts,(count1+ 10))
       ENDIF
       reply->qual[x].excepts[count1].exception_entity_name = pe.exception_entity_name, reply->qual[x
       ].excepts[count1].exception_type_cd = pe.exception_type_cd
       IF (pe.exception_id > 0)
        reply->qual[x].excepts[count1].exception_id = pe.exception_id
       ELSE
        reply->qual[x].excepts[count1].exception_id = cv.code_value
       ENDIF
      ELSE
       noexcepts = 1
      ENDIF
     FOOT  p.privilege_id
      IF (count1 > 0)
       stat = alterlist(reply->qual[x].excepts,count1), reply->qual[x].except_cnt = count1
      ENDIF
     WITH nocounter, outerjoin = d, outerjoin = d1
    ;end select
    IF (count1=0
     AND noexcepts=0)
     SET reply->qual[x].priv_status = "Z"
     SET reply->qual[x].priv_value_mean = "NOTDEFINED"
    ELSE
     SET reply->qual[x].priv_status = "S"
    ENDIF
   ENDIF
   CALL echo(build("count from ppr level is:",count1))
   IF ((reply->qual[x].priv_status != "S")
    AND (request->chk_psn_ind=1)
    AND (request->position_cd > 0))
    SELECT INTO "NL:"
     p.privilege_id, pe.exception_id
     FROM priv_loc_reltn pl,
      privilege p,
      (dummyt d  WITH seq = 1),
      privilege_exception pe,
      (dummyt d1  WITH seq = 1),
      code_value cv
     PLAN (pl
      WHERE (pl.position_cd=request->position_cd)
       AND pl.location_cd=0)
      JOIN (p
      WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
       AND (p.privilege_cd=request->plist[x].privilege_cd))
      JOIN (d
      WHERE d.seq=1)
      JOIN (pe
      WHERE pe.privilege_id=p.privilege_id)
      JOIN (d1
      WHERE d1.seq=1)
      JOIN (cv
      WHERE pe.event_set_name > " "
       AND cv.code_set=93
       AND cv.display_key=trim(cnvtupper(cnvtalphanum(pe.event_set_name))))
     ORDER BY pe.exception_id
     HEAD p.privilege_id
      count1 = 0, reply->qual[x].priv_value_cd = p.priv_value_cd, reply->qual[x].restr_method_cd = p
      .restr_method_cd
     DETAIL
      IF (pe.privilege_exception_id > 0)
       count1 = (count1+ 1)
       IF (count1 > size(reply->qual[x].excepts,5))
        stat = alterlist(reply->qual[x].excepts,(count1+ 10))
       ENDIF
       reply->qual[x].excepts[count1].exception_entity_name = pe.exception_entity_name, reply->qual[x
       ].excepts[count1].exception_type_cd = pe.exception_type_cd
       IF (pe.exception_id > 0)
        reply->qual[x].excepts[count1].exception_id = pe.exception_id
       ELSE
        reply->qual[x].excepts[count1].exception_id = cv.code_value
       ENDIF
      ELSE
       noexcepts = 1
      ENDIF
     FOOT  p.privilege_id
      IF (count1 > 0)
       stat = alterlist(reply->qual[x].excepts,count1), reply->qual[x].except_cnt = count1
      ENDIF
     WITH nocounter, outerjoin = d, outerjoin = d1
    ;end select
    IF (count1=0
     AND noexcepts=0)
     SET reply->qual[x].priv_status = "Z"
     SET reply->qual[x].priv_value_mean = "NOTDEFINED"
    ELSE
     SET reply->qual[x].priv_status = "S"
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(build("count from pos level is:",count1))
 FOR (x = 1 TO priv_cnt)
   CALL echo(build("priv cd:",reply->qual[x].privilege_cd))
   CALL echo(build("status:",reply->qual[x].priv_status))
   CALL echo(build("value:",reply->qual[x].priv_value_cd))
   CALL echo(build("mean:",reply->qual[x].priv_value_mean))
   FOR (i = 1 TO count1)
     CALL echo(build("exception_id = ",reply->qual[x].excepts[i].exception_id))
   ENDFOR
 ENDFOR
END GO

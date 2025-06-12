CREATE PROGRAM dcp_load_privs:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_id = f8
     2 position_cd = f8
     2 ppr_cd = f8
     2 location_cd = f8
     2 privs[*]
       3 privilege_id = f8
       3 privilege_cd = f8
       3 privilege_disp = c40
       3 privilege_desc = c60
       3 privilege_mean = c12
       3 priv_value_cd = f8
       3 priv_value_disp = c40
       3 priv_value_desc = c60
       3 priv_value_mean = c12
       3 restr_method_cd = f8
       3 restr_method_disp = c40
       3 restr_method_desc = c60
       3 restr_method_mean = c12
       3 except_cnt = i4
       3 exceptions[*]
         4 exception_entity_name = c40
         4 exception_type_cd = f8
         4 exception_type_disp = c40
         4 exception_type_desc = c60
         4 exception_type_mean = c12
         4 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD privtemp(
   1 positioncnt = i4
   1 positions[*]
     2 position_cd = f8
   1 pprcnt = i4
   1 pprs[*]
     2 ppr_cd = f8
   1 prsnlcnt = i4
   1 prsnls[*]
     2 prsnl_id = f8
   1 locationcnt = i4
   1 locations[*]
     2 location_cd = f8
   1 privs[*]
     2 privilege_id = f8
     2 qual = i4
     2 priv = i4
 )
 DECLARE requestcnt = i4 WITH constant(size(request->privs,5))
 DECLARE privcnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE includecd = f8 WITH constant(uar_get_code_by("MEANING",6017,"INCLUDE"))
 DECLARE excludecd = f8 WITH constant(uar_get_code_by("MEANING",6017,"EXCLUDE"))
 DECLARE initialize(null) = null
 DECLARE validatepriv(poscd=f8,pprcd=f8,prsnlid=f8,loccd=f8) = i4
 DECLARE locateidx(poscd=f8,pprcd=f8,prsnlid=f8,loccd=f8) = i4
 DECLARE loadprivs(null) = null
 DECLARE loadexceptions(null) = null
 SET reply->status_data.status = "F"
 CALL initialize(null)
 CALL loadprivs(null)
 IF (qualcnt > 0)
  IF (privcnt > 0)
   CALL loadexceptions(null)
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 FREE SET privtemp
 SUBROUTINE initialize(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE code = f8 WITH noconstant(0.0)
   DECLARE temp = f8 WITH noconstant(0.0)
   DECLARE add = i4 WITH noconstant(0)
   SET stat = alterlist(privtemp->positions,requestcnt)
   SET stat = alterlist(privtemp->pprs,requestcnt)
   SET stat = alterlist(privtemp->prsnls,requestcnt)
   SET stat = alterlist(privtemp->locations,requestcnt)
   FOR (i = 1 TO requestcnt)
     IF ((request->privs[i].position_cd > 0.0))
      SET code = request->privs[i].position_cd
      SET add = 1
      FOR (j = 1 TO privtemp->positioncnt)
        IF ((privtemp->positions[j].position_cd=code))
         SET add = 0
         SET j = (privtemp->positioncnt+ 1)
        ELSEIF ((privtemp->positions[j].position_cd > code))
         SET temp = privtemp->positions[j].position_cd
         SET privtemp->positions[j].position_cd = code
         SET code = temp
        ENDIF
      ENDFOR
      IF (add > 0)
       SET privtemp->positioncnt = (privtemp->positioncnt+ 1)
       SET privtemp->positions[privtemp->positioncnt].position_cd = code
      ENDIF
     ENDIF
     IF ((request->privs[i].ppr_cd > 0.0))
      SET code = request->privs[i].ppr_cd
      SET add = 1
      FOR (j = 1 TO privtemp->pprcnt)
        IF ((privtemp->pprs[j].ppr_cd=code))
         SET add = 0
         SET j = (privtemp->pprcnt+ 1)
        ELSEIF ((privtemp->pprs[j].ppr_cd > code))
         SET temp = privtemp->pprs[j].ppr_cd
         SET privtemp->pprs[j].ppr_cd = code
         SET code = temp
        ENDIF
      ENDFOR
      IF (add > 0)
       SET privtemp->pprcnt = (privtemp->pprcnt+ 1)
       SET privtemp->pprs[privtemp->pprcnt].ppr_cd = code
      ENDIF
     ENDIF
     IF ((request->privs[i].prsnl_id > 0.0))
      SET code = request->privs[i].prsnl_id
      SET add = 1
      FOR (j = 1 TO privtemp->prsnlcnt)
        IF ((privtemp->prsnls[j].prsnl_id=code))
         SET add = 0
         SET j = (privtemp->prsnlcnt+ 1)
        ELSEIF ((privtemp->prsnls[j].prsnl_id > code))
         SET temp = privtemp->prsnls[j].prsnl_id
         SET privtemp->prsnls[j].prsnl_id = code
         SET code = temp
        ENDIF
      ENDFOR
      IF (add > 0)
       SET privtemp->prsnlcnt = (privtemp->prsnlcnt+ 1)
       SET privtemp->prsnls[privtemp->prsnlcnt].prsnl_id = code
      ENDIF
     ENDIF
     SET code = request->privs[i].location_cd
     SET add = 1
     FOR (j = 1 TO privtemp->locationcnt)
       IF ((privtemp->locations[j].location_cd=code))
        SET add = 0
        SET j = (privtemp->locationcnt+ 1)
       ELSEIF ((privtemp->locations[j].location_cd > code))
        SET temp = privtemp->locations[j].location_cd
        SET privtemp->locations[j].location_cd = code
        SET code = temp
       ENDIF
     ENDFOR
     IF (add > 0)
      SET privtemp->locationcnt = (privtemp->locationcnt+ 1)
      SET privtemp->locations[privtemp->locationcnt].location_cd = code
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE validatepriv(poscd,pprcd,prsnlid,loccd)
   DECLARE m = i4 WITH noconstant(0)
   FOR (m = 1 TO requestcnt)
     IF ((request->privs[m].position_cd=poscd)
      AND (request->privs[m].ppr_cd=pprcd)
      AND (request->privs[m].prsnl_id=prsnlid)
      AND (request->privs[m].location_cd=loccd))
      RETURN(m)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE locateidx(poscd,pprcd,prsnlid,loccd)
   DECLARE m = i4 WITH noconstant(0)
   FOR (m = 1 TO qualcnt)
     IF ((reply->qual[m].position_cd=poscd)
      AND (reply->qual[m].ppr_cd=pprcd)
      AND (reply->qual[m].prsnl_id=prsnlid)
      AND (reply->qual[m].location_cd=loccd))
      RETURN(m)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE loadprivs(null)
   DECLARE text = vc WITH noconstant(fillstring(1000," "))
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE l = i4 WITH noconstant(0)
   DECLARE position_cnt = i4 WITH constant(privtemp->positioncnt)
   DECLARE ppr_cnt = i4 WITH constant(privtemp->pprcnt)
   DECLARE prsnl_cnt = i4 WITH constant(privtemp->prsnlcnt)
   DECLARE location_cnt = i4 WITH constant(privtemp->locationcnt)
   IF (position_cnt > 0
    AND ppr_cnt > 0
    AND prsnl_cnt > 0)
    SET text = concat(
     "(expand (x, 1, position_cnt, plr.position_cd, privTemp->positions[x].position_cd)",
     " or expand (y, 1, ppr_cnt, plr.ppr_cd, privTemp->pprs[y].ppr_cd)",
     " or expand (z, 1, prsnl_cnt, plr.person_id, privTemp->prsnls[z].prsnl_id))")
   ELSEIF (position_cnt > 0
    AND ppr_cnt > 0)
    SET text = concat(
     "(expand (x, 1, position_cnt, plr.position_cd, privTemp->positions[x].position_cd)",
     " or expand (y, 1, ppr_cnt, plr.ppr_cd, privTemp->pprs[y].ppr_cd))")
   ELSEIF (position_cnt > 0
    AND prsnl_cnt > 0)
    SET text = concat(
     "(expand (x, 1, position_cnt, plr.position_cd, privTemp->positions[x].position_cd)",
     " or expand (z, 1, prsnl_cnt, plr.person_id, privTemp->prsnls[z].prsnl_id))")
   ELSEIF (position_cnt > 0)
    SET text = "expand (x, 1, position_cnt, plr.position_cd, privTemp->positions[x].position_cd)"
   ELSEIF (ppr_cnt > 0
    AND prsnl_cnt > 0)
    SET text = concat("(expand (y, 1, ppr_cnt, plr.ppr_cd, privTemp->pprs[y].ppr_cd)",
     " or expand (z, 1, prsnl_cnt, plr.person_id, privTemp->prsnls[z].prsnl_id))")
   ELSEIF (ppr_cnt > 0)
    SET text = "expand (y, 1, ppr_cnt, plr.ppr_cd, privTemp->pprs[y].ppr_cd)"
   ELSEIF (prsnl_cnt > 0)
    SET text = "expand (z, 1, prsnl_cnt, plr.person_id, privTemp->prsnls[z].prsnl_id)"
   ENDIF
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr,
     privilege p
    PLAN (plr
     WHERE parser(text)
      AND expand(l,1,privtemp->locationcnt,plr.location_cd,privtemp->locations[l].location_cd))
     JOIN (p
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id)
    ORDER BY plr.priv_loc_reltn_id, p.privilege_id
    HEAD REPORT
     qualcnt = 0, idx = 0
    HEAD plr.priv_loc_reltn_id
     valid = validatepriv(plr.position_cd,plr.ppr_cd,plr.person_id,plr.location_cd)
     IF (valid > 0)
      idx = locateidx(plr.position_cd,plr.ppr_cd,plr.person_id,plr.location_cd)
      IF (idx=0)
       qualcnt = (qualcnt+ 1)
       IF (mod(qualcnt,100)=1)
        stat = alterlist(reply->qual,(qualcnt+ 99))
       ENDIF
       reply->qual[qualcnt].location_cd = plr.location_cd, reply->qual[qualcnt].position_cd = plr
       .position_cd, reply->qual[qualcnt].ppr_cd = plr.ppr_cd,
       reply->qual[qualcnt].prsnl_id = plr.person_id, idx = qualcnt, cnt = 0,
       pcnt = 0
      ELSE
       pcnt = size(reply->qual[idx].privs,5), cnt = pcnt
      ENDIF
     ENDIF
    HEAD p.privilege_id
     IF (valid > 0)
      cnt = (cnt+ 1)
      IF (cnt > pcnt)
       pcnt = (pcnt+ 50), stat = alterlist(reply->qual[idx].privs,pcnt)
      ENDIF
      reply->qual[idx].privs[cnt].except_cnt = 0, reply->qual[idx].privs[cnt].privilege_id = p
      .privilege_id, reply->qual[idx].privs[cnt].priv_value_cd = p.priv_value_cd,
      reply->qual[idx].privs[cnt].privilege_cd = p.privilege_cd, reply->qual[idx].privs[cnt].
      restr_method_cd = p.restr_method_cd
      IF (((p.priv_value_cd=includecd) OR (p.priv_value_cd=excludecd)) )
       privcnt = (privcnt+ 1)
       IF (mod(privcnt,100)=1)
        stat = alterlist(privtemp->privs,(privcnt+ 99))
       ENDIF
       privtemp->privs[privcnt].privilege_id = p.privilege_id, privtemp->privs[privcnt].qual = idx,
       privtemp->privs[privcnt].priv = cnt
      ENDIF
     ENDIF
    FOOT  plr.priv_loc_reltn_id
     IF (valid > 0)
      stat = alterlist(reply->qual[idx].privs,cnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,qualcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadexceptions(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM privilege_exception pe
    PLAN (pe
     WHERE expand(x,1,privcnt,pe.privilege_id,privtemp->privs[x].privilege_id))
    ORDER BY pe.privilege_id
    HEAD pe.privilege_id
     idx = locateval(y,1,privcnt,pe.privilege_id,privtemp->privs[y].privilege_id), qual = privtemp->
     privs[idx].qual, priv = privtemp->privs[idx].priv,
     exceptcnt = 0
    DETAIL
     exceptcnt = (exceptcnt+ 1)
     IF (mod(exceptcnt,50)=1)
      stat = alterlist(reply->qual[qual].privs[priv].exceptions,(exceptcnt+ 49))
     ENDIF
     reply->qual[qual].privs[priv].exceptions[exceptcnt].exception_type_cd = pe.exception_type_cd,
     reply->qual[qual].privs[priv].exceptions[exceptcnt].exception_entity_name = pe
     .exception_entity_name
     IF (pe.exception_id > 0.0)
      reply->qual[qual].privs[priv].exceptions[exceptcnt].exception_id = pe.exception_id
     ELSE
      reply->qual[qual].privs[priv].exceptions[exceptcnt].exception_id = uar_get_code_by("DISPLAYKEY",
       93,cnvtupper(cnvtalphanum(pe.event_set_name)))
     ENDIF
    FOOT  pe.privilege_id
     stat = alterlist(reply->qual[qual].privs[priv].exceptions,exceptcnt)
    FOOT REPORT
     reply->qual[qual].privs[priv].except_cnt = exceptcnt, stat = alterlist(reply->qual[qual].privs[
      priv].exceptions,exceptcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
END GO

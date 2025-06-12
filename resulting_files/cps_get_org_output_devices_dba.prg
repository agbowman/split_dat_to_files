CREATE PROGRAM cps_get_org_output_devices:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 org[*]
     2 organization_id = f8
     2 org_name = vc
     2 org_type_cd = f8
     2 org_type_disp = c40
     2 org_type_mean = c12
     2 output_dest_knt = i4
     2 phone_num = vc
     2 contact = vc
     2 address_type_cd = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 zipcode = vc
     2 country = vc
     2 country_cd = f8
     2 output_dest[*]
       3 output_dest_cd = f8
       3 output_dest_name = vc
       3 usage_type_cd = f8
       3 fax_nbr_ind = i2
       3 fax_number = vc
     2 group_qual[*]
       3 group_id = f8
     2 adhoc_ind = i2
   1 org_knt = i4
   1 regional_group_knt = i4
   1 regional_group[*]
     2 group_id = f8
     2 group_name = vc
     2 grouping_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dvar = 0
 SET knt = 0
 SET fax_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 DECLARE org_knt = i4 WITH protect, noconstant(0)
 SET code_value = 0.0
 SET code_set = 3000
 SET cdf_meaning = "FAX"
 EXECUTE cpm_get_cd_for_cdf
 SET fax_type_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find CODE_VALUE for CDF_MEANING ",trim(cdf_meaning)," in CODE_SET ",
   trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM output_dest_xref ox,
   output_dest od,
   remote_device rd,
   station s,
   organization o,
   org_type_reltn otr
  PLAN (ox
   WHERE ox.parent_entity_name="ORGANIZATION"
    AND ox.usage_type_cd=fax_type_cd)
   JOIN (o
   WHERE o.organization_id=ox.parent_entity_id)
   JOIN (otr
   WHERE otr.organization_id=o.organization_id)
   JOIN (od
   WHERE od.output_dest_cd=ox.output_dest_cd)
   JOIN (rd
   WHERE rd.device_cd=od.device_cd
    AND ((rd.area_code=null) OR (rd.area_code=" "))
    AND ((rd.exchange=null) OR (rd.exchange=" "))
    AND ((rd.phone_suffix=null) OR (rd.phone_suffix=" ")) )
   JOIN (s
   WHERE s.output_dest_cd=od.output_dest_cd)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->org,1), oknt = 0
  DETAIL
   knt = (knt+ 1)
   IF (knt=1)
    oknt = 1, stat = alterlist(reply->org[knt].output_dest,oknt), reply->org[knt].output_dest_knt =
    oknt,
    reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
    output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].fax_nbr_ind = 0,
    reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name, reply
    ->org[knt].org_type_cd = otr.org_type_cd,
    reply->org[knt].adhoc_ind = 1
   ENDIF
  FOOT REPORT
   IF (oknt=1)
    reply->org_knt = oknt, stat = alterlist(reply->org,oknt)
   ELSE
    reply->org_knt = 0, stat = alterlist(reply->org,reply->org_knt)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AD HOC FAX OUPUT_DEST_XREF"
  GO TO exit_script
 ENDIF
 IF ((reply->org_knt=0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM device_xref dx,
    output_dest od,
    remote_device rd,
    station s,
    organization o,
    org_type_reltn otr
   PLAN (dx
    WHERE dx.parent_entity_name="ORGANIZATION"
     AND dx.usage_type_cd=fax_type_cd)
    JOIN (o
    WHERE o.organization_id=dx.parent_entity_id)
    JOIN (otr
    WHERE otr.organization_id=o.organization_id)
    JOIN (od
    WHERE od.device_cd=dx.device_cd)
    JOIN (rd
    WHERE rd.device_cd=dx.device_cd
     AND ((rd.area_code=null) OR (rd.area_code=" "))
     AND ((rd.exchange=null) OR (rd.exchange=" "))
     AND ((rd.phone_suffix=null) OR (rd.phone_suffix=" ")) )
    JOIN (s
    WHERE s.output_dest_cd=od.output_dest_cd)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->org,1), oknt = 0
   DETAIL
    knt = (knt+ 1)
    IF (knt=1)
     oknt = 1, stat = alterlist(reply->org[knt].output_dest,oknt), reply->org[knt].output_dest_knt =
     oknt,
     reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
     output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].fax_nbr_ind = 0,
     reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
     reply->org[knt].org_type_cd = otr.org_type_cd,
     reply->org[knt].adhoc_ind = 1
    ENDIF
   FOOT REPORT
    IF (oknt=1)
     reply->org_knt = oknt, stat = alterlist(reply->org,oknt)
    ELSE
     reply->org_knt = 0, stat = alterlist(reply->org,reply->org_knt)
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "AD HOC FAX DEVICE_XREF"
   GO TO exit_script
  ENDIF
 ENDIF
 SET org_knt = 0
 IF (validate(request->usr_org_qual))
  CALL echo("Request is valid",1)
  SET org_knt = size(request->usr_org_qual,5)
  IF ((request->pat_org_id > 0))
   SET org_knt = (org_knt+ 1)
  ENDIF
 ELSE
  CALL echo("Invalid request found",1)
  SET org_knt = 0
 ENDIF
 IF (org_knt=0)
  CALL get_output_dest_no_org(dvar)
 ELSE
  CALL get_output_dest_with_org(dvar)
 ENDIF
 GO TO exit_script
 SUBROUTINE get_output_dest_no_org(lvar)
   IF ((request->org_type_knt > 0))
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(request->org_type_knt)),
      org_type_reltn otr,
      organization o,
      output_dest_xref ox,
      output_dest od,
      remote_device rd
     PLAN (d
      WHERE d.seq > 0)
      JOIN (otr
      WHERE (otr.org_type_cd=request->org_type[d.seq].org_type_cd)
       AND otr.active_ind=1
       AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (o
      WHERE o.organization_id=otr.organization_id
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (ox
      WHERE ox.parent_entity_name="ORGANIZATION"
       AND ox.parent_entity_id=o.organization_id
       AND ox.usage_type_cd=fax_type_cd)
      JOIN (od
      WHERE od.output_dest_cd=ox.output_dest_cd)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd
       AND rd.phone_suffix != null
       AND rd.phone_suffix > " ")
     HEAD REPORT
      knt = reply->org_knt
     HEAD o.organization_id
      dvar = 0
     HEAD otr.org_type_cd
      knt = (knt+ 1)
      IF (knt > size(reply->org,5))
       stat = alterlist(reply->org,(knt+ 9))
      ENDIF
      reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
      reply->org[knt].org_type_cd = otr.org_type_cd,
      oknt = reply->org[knt].output_dest_knt
     DETAIL
      oknt = (oknt+ 1)
      IF (oknt > size(reply->org[knt].output_dest,5))
       stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
      ENDIF
      reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
      output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
       = ox.usage_type_cd,
      reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
     FOOT  otr.org_type_cd
      reply->org[knt], output_dest_knt = oknt, stat = alterlist(reply->org[knt].output_dest,oknt)
     FOOT REPORT
      reply->org_knt = knt, stat = alterlist(reply->org,knt)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "OUTPUT_DEST_XREF"
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(request->org_type_knt)),
      org_type_reltn otr,
      organization o,
      device_xref dx,
      output_dest od,
      remote_device rd
     PLAN (d
      WHERE d.seq > 0)
      JOIN (otr
      WHERE (otr.org_type_cd=request->org_type[d.seq].org_type_cd)
       AND otr.active_ind=1
       AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (o
      WHERE o.organization_id=otr.organization_id
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (dx
      WHERE dx.parent_entity_name="ORGANIZATION"
       AND dx.parent_entity_id=o.organization_id
       AND dx.usage_type_cd=fax_type_cd)
      JOIN (od
      WHERE od.device_cd=dx.device_cd)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd
       AND rd.phone_suffix != null
       AND rd.phone_suffix > " ")
     HEAD REPORT
      knt = reply->org_knt, wknt = knt
     HEAD o.organization_id
      dvar = 0
     HEAD otr.org_type_cd
      add_org = true
      IF (wknt > 0)
       continue = true, iorg = 0, lknt = 1
       WHILE (continue=true
        AND lknt <= wknt)
        IF ((reply->org[lknt].organization_id=o.organization_id)
         AND (reply->org[lknt].org_type_cd=otr.org_type_cd))
         continue = false, add_org = false, iorg = lknt
        ENDIF
        ,lknt = (lknt+ 1)
       ENDWHILE
      ENDIF
      IF (add_org=true)
       knt = (knt+ 1)
       IF (knt > size(reply->org,5))
        stat = alterlist(reply->org,(knt+ 9))
       ENDIF
       reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
       reply->org[knt].org_type_cd = otr.org_type_cd,
       oknt = reply->org[knt].output_dest_knt
      ENDIF
     DETAIL
      IF (add_org=true)
       oknt = (oknt+ 1)
       IF (oknt > size(reply->org[knt].output_dest,5))
        stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
       ENDIF
       reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
       output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
        = dx.usage_type_cd,
       reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
      ELSE
       oknt = reply->org[iorg].output_dest_knt, w_oknt = oknt, continue = true,
       add_output = true, zknt = 1
       IF (w_oknt > 0)
        WHILE (continue=true
         AND zknt <= w_oknt)
         IF ((reply->org[iorg].output_dest[zknt].output_dest_cd=od.output_dest_cd))
          continue = false, add_output = false
         ENDIF
         ,zknt = (zknt+ 1)
        ENDWHILE
       ENDIF
       IF (add_output=true)
        oknt = (oknt+ 1)
        IF (oknt > size(reply->org[knt].output_dest,5))
         stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
        ENDIF
        reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
        output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
         = dx.usage_type_cd,
        reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
       ENDIF
      ENDIF
     FOOT  otr.org_type_cd
      IF (add_org=true)
       fknt = knt
      ELSE
       fknt = iorg
      ENDIF
      reply->org[fknt].output_dest_knt = oknt, stat = alterlist(reply->org[knt].output_dest,oknt)
     FOOT REPORT
      reply->org_knt = knt, stat = alterlist(reply->org,knt)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "DEVICE_XREF"
     GO TO exit_script
    ENDIF
    GO TO get_phone_addr
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM output_dest_xref ox,
     org_type_reltn otr,
     organization o,
     output_dest od,
     remote_device rd
    PLAN (ox
     WHERE ox.parent_entity_name="ORGANIZATION"
      AND ox.usage_type_cd=fax_type_cd)
     JOIN (o
     WHERE o.organization_id=ox.parent_entity_id
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND otr.active_ind=1
      AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (od
     WHERE od.output_dest_cd=ox.output_dest_cd)
     JOIN (rd
     WHERE rd.device_cd=od.device_cd
      AND rd.phone_suffix != null
      AND rd.phone_suffix > " ")
    HEAD REPORT
     knt = reply->org_knt
    HEAD o.organization_id
     dvar = 0
    HEAD otr.org_type_cd
     knt = (knt+ 1)
     IF (knt > size(reply->org,5))
      stat = alterlist(reply->org,(knt+ 9))
     ENDIF
     reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
     reply->org[knt].org_type_cd = otr.org_type_cd,
     oknt = reply->org[knt].output_dest_knt
    DETAIL
     oknt = (oknt+ 1)
     IF (oknt > size(reply->org[knt].output_dest,5))
      stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
     ENDIF
     reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
     output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd =
     ox.usage_type_cd,
     reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
    FOOT  otr.org_type_cd
     reply->org[knt], output_dest_knt = oknt, stat = alterlist(reply->org[knt].output_dest,oknt)
    FOOT REPORT
     reply->org_knt = knt, stat = alterlist(reply->org,knt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "OUTPUT_DEST_XREF"
    GO TO exit_script
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM device_xref dx,
     org_type_reltn otr,
     organization o,
     output_dest od,
     remote_device rd
    PLAN (dx
     WHERE dx.parent_entity_name="ORGANIZATION"
      AND dx.usage_type_cd=fax_type_cd)
     JOIN (o
     WHERE o.organization_id=dx.parent_entity_id
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND otr.active_ind=1
      AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (od
     WHERE od.device_cd=dx.device_cd)
     JOIN (rd
     WHERE rd.device_cd=od.device_cd
      AND rd.phone_suffix != null
      AND rd.phone_suffix > " ")
    HEAD REPORT
     knt = reply->org_knt, wknt = knt
    HEAD o.organization_id
     dvar = 0
    HEAD otr.org_type_cd
     add_org = true
     IF (wknt > 0)
      continue = true, iorg = 0, lknt = 1
      WHILE (continue=true
       AND lknt <= wknt)
       IF ((reply->org[lknt].organization_id=o.organization_id)
        AND (reply->org[lknt].org_type_cd=otr.org_type_cd))
        continue = false, add_org = false, iorg = lknt
       ENDIF
       ,lknt = (lknt+ 1)
      ENDWHILE
     ENDIF
     IF (add_org=true)
      knt = (knt+ 1)
      IF (knt > size(reply->org,5))
       stat = alterlist(reply->org,(knt+ 9))
      ENDIF
      reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
      reply->org[knt].org_type_cd = otr.org_type_cd,
      oknt = reply->org[knt].output_dest_knt
     ENDIF
    DETAIL
     IF (add_org=true)
      oknt = (oknt+ 1)
      IF (oknt > size(reply->org[knt].output_dest,5))
       stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
      ENDIF
      reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
      output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
       = dx.usage_type_cd,
      reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
     ELSE
      oknt = reply->org[iorg].output_dest_knt, w_oknt = oknt, continue = true,
      add_output = true, zknt = 1
      IF (w_oknt > 0)
       WHILE (continue=true
        AND zknt <= w_oknt)
        IF ((reply->org[iorg].output_dest[zknt].output_dest_cd=od.output_dest_cd))
         continue = false, add_output = false
        ENDIF
        ,zknt = (zknt+ 1)
       ENDWHILE
      ENDIF
      IF (add_output=true)
       oknt = (oknt+ 1)
       IF (oknt > size(reply->org[knt].output_dest,5))
        stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
       ENDIF
       reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
       output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
        = dx.usage_type_cd,
       reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
      ENDIF
     ENDIF
    FOOT  otr.org_type_cd
     IF (add_org=true)
      fknt = knt
     ELSE
      fknt = iorg
     ENDIF
     reply->org[fknt].output_dest_knt = oknt, stat = alterlist(reply->org[knt].output_dest,oknt)
    FOOT REPORT
     reply->org_knt = knt, stat = alterlist(reply->org,knt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "DEVICE_XREF"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_output_dest_with_org(lvar)
   FREE RECORD ppr_req
   RECORD ppr_req(
     1 showgrpentityind = i2
     1 qual[*]
       2 group_id = f8
       2 group_name = vc
   )
   FREE RECORD ppr_reply
   RECORD ppr_reply(
     1 qual[*]
       2 group_id = f8
       2 reltn_qual[*]
         3 related_id = f8
         3 related_name = vc
         3 related_disp = vc
         3 related_type_cd = f8
         3 related_type_disp = c40
         3 member_qual[*]
           4 member_id = f8
           4 member_name = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD tmp_org
   RECORD tmp_org(
     1 qual[*]
       2 org_id = f8
   )
   FREE RECORD tmp_group
   RECORD tmp_group(
     1 regional_group[*]
       2 group_id = f8
       2 group_name = vc
       2 grouping_ind = i2
       2 sort_ind = i2
   )
   DECLARE max_group_knt = i4 WITH protect, noconstant(0)
   DECLARE group_knt = i4 WITH protect, noconstant(0)
   DECLARE ifoundinusrorg = i2 WITH protect, noconstant(0)
   DECLARE max_org_knt = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   IF (org_knt > 0)
    SET knt = size(request->usr_org_qual,5)
    SET stat = alterlist(ppr_req->qual,knt)
    SET ppr_req->showgrpentityind = 1
    FOR (x = 1 TO knt)
      SET ppr_req->qual[x].group_id = request->usr_org_qual[x].org_id
      SET ppr_req->qual[x].group_name = "ORGANIZATION"
      IF ((request->pat_org_id=ppr_req->qual[x].group_id))
       SET ifoundinusrorg = 1
      ENDIF
    ENDFOR
    IF (ifoundinusrorg=0)
     SET knt = (knt+ 1)
     SET stat = alterlist(ppr_req->qual,knt)
     SET ppr_req->qual[knt].group_id = request->pat_org_id
     SET ppr_req->qual[knt].group_name = "ORGANIZATION"
    ENDIF
    CALL echorecord(ppr_req)
    EXECUTE ppr_get_group_entity_reltn  WITH replace("REQUEST","PPR_REQ"), replace("REPLY",
     "PPR_REPLY")
    CALL echo("Finished executing PPR script",1)
    CALL echorecord(ppr_reply)
    IF ((ppr_reply->status_data.status != "S"))
     GO TO exit_script
    ENDIF
    SET knt = size(ppr_reply->qual,5)
    FOR (x = 1 TO knt)
      SET group_knt = size(ppr_reply->qual[x].reltn_qual,5)
      IF (max_group_knt < group_knt)
       SET max_group_knt = group_knt
      ENDIF
      FOR (y = 1 TO group_knt)
       SET org_knt = size(ppr_reply->qual[x].reltn_qual[y].member_qual,5)
       IF (max_org_knt < org_knt)
        SET max_org_knt = org_knt
       ENDIF
      ENDFOR
    ENDFOR
    CALL echo(build("max_group_knt = ",max_group_knt))
    CALL echo(build("max_org_knt = ",max_org_knt))
    SELECT INTO "nl:"
     group_id = ppr_reply->qual[d.seq].reltn_qual[d2.seq].related_id, group_name = ppr_reply->qual[d
     .seq].reltn_qual[d2.seq].related_disp, org_id = ppr_reply->qual[d.seq].reltn_qual[d2.seq].
     member_qual[d3.seq].member_id
     FROM (dummyt d  WITH seq = value(size(ppr_reply->qual,5))),
      (dummyt d2  WITH seq = value(max_group_knt)),
      (dummyt d3  WITH seq = value(max_org_knt))
     PLAN (d)
      JOIN (d2
      WHERE d2.seq <= size(ppr_reply->qual[d.seq].reltn_qual,5))
      JOIN (d3
      WHERE d3.seq <= size(ppr_reply->qual[d.seq].reltn_qual[d2.seq].member_qual,5))
     ORDER BY group_id, org_id
     HEAD REPORT
      knt = 0, org_list_knt = 0, col 0,
      "Setting grouping_ind first round", row + 1
     HEAD group_id
      knt = (knt+ 1), stat = alterlist(tmp_group->regional_group,knt), tmp_group->regional_group[knt]
      .group_id = group_id,
      tmp_group->regional_group[knt].group_name = ppr_reply->qual[d.seq].reltn_qual[d2.seq].
      related_disp, ibelongtopatorgind = 0
     HEAD org_id
      ifoundinorgqual = 0, org_knt = size(tmp_org->qual,5)
      FOR (x = 1 TO org_knt)
        IF ((org_id=tmp_org->qual[x].org_id))
         ifoundinorgqual = 1, x = (org_knt+ 1)
        ENDIF
      ENDFOR
      IF (ifoundinorgqual=0)
       org_list_knt = (org_list_knt+ 1), stat = alterlist(tmp_org->qual,org_list_knt), tmp_org->qual[
       org_list_knt].org_id = org_id,
       col 10, tmp_org->qual[org_list_knt].org_id, row + 1
      ENDIF
     DETAIL
      IF ((request->pat_org_id=ppr_reply->qual[d.seq].group_id))
       ibelongtopatorgind = 1
      ENDIF
     FOOT  group_id
      IF (ibelongtopatorgind=1
       AND ifoundinusrorg=0)
       tmp_group->regional_group[knt].grouping_ind = - (1), tmp_group->regional_group[knt].sort_ind
        = 1
      ELSEIF (ibelongtopatorgind=1)
       tmp_group->regional_group[knt].grouping_ind = - (3), tmp_group->regional_group[knt].sort_ind
        = 1
      ELSE
       tmp_group->regional_group[knt].grouping_ind = - (2), tmp_group->regional_group[knt].sort_ind
        = 2
      ENDIF
      col 1, group_id, col 20,
      ppr_reply->qual[d.seq].group_id, col 40, request->pat_org_id,
      col 60, ifoundinusrorg"###;l", col 65,
      tmp_group->regional_group[knt].grouping_ind"###;l", col 70, tmp_group->regional_group[knt].
      sort_ind"###;l",
      row + 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "DUMMYT"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     group_name = tmp_group->regional_group[d.seq].group_name, sort_ind = tmp_group->regional_group[d
     .seq].sort_ind
     FROM (dummyt d  WITH seq = size(tmp_group->regional_group,5))
     PLAN (d)
     ORDER BY sort_ind, group_name
     HEAD REPORT
      knt = 0
     DETAIL
      col 0, sort_ind"##;l", col 10,
      group_name, col 40, tmp_group->regional_group[d.seq].grouping_ind,
      row + 1
      IF ((tmp_group->regional_group[d.seq].grouping_ind != 0))
       knt = (knt+ 1), reply->regional_group_knt = knt, stat = alterlist(reply->regional_group,knt),
       reply->regional_group[knt].group_id = tmp_group->regional_group[d.seq].group_id, reply->
       regional_group[knt].group_name = tmp_group->regional_group[d.seq].group_name, reply->
       regional_group[knt].grouping_ind = tmp_group->regional_group[d.seq].grouping_ind
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "DUMMYT2"
     GO TO exit_script
    ENDIF
    CALL echorecord(reply)
    SET org_knt = value(size(tmp_org->qual,5))
    DECLARE new_list_size = i4
    DECLARE cur_list_size = i4
    DECLARE batch_size = i4 WITH constant(10)
    DECLARE nstart = i4
    DECLARE loop_cnt = i4
    SET cur_list_size = size(tmp_org->qual,5)
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(tmp_org->qual,new_list_size)
    SET nstart = 1
    FOR (idx = (cur_list_size+ 1) TO new_list_size)
      SET tmp_org->qual[idx].org_id = tmp_org->qual[cur_list_size].org_id
    ENDFOR
    IF ((request->org_type_knt=0))
     SET stat = alterlist(request->org_type,1)
     SET request->org_type[1].org_type_cd = 0.0
     SET request->org_type_knt = 1
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     o.*
     FROM (dummyt d1  WITH seq = value(loop_cnt)),
      (dummyt d2  WITH seq = value(request->org_type_knt)),
      org_type_reltn otr,
      organization o,
      output_dest_xref ox,
      output_dest od,
      remote_device rd
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
      JOIN (o
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),o.organization_id,tmp_org->qual[idx].org_id)
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d2)
      JOIN (otr
      WHERE otr.organization_id=o.organization_id
       AND (((otr.org_type_cd=request->org_type[d2.seq].org_type_cd)) OR ((request->org_type[d2.seq].
      org_type_cd=0)))
       AND otr.active_ind=1
       AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (ox
      WHERE ox.parent_entity_name="ORGANIZATION"
       AND ox.parent_entity_id=otr.organization_id
       AND ox.usage_type_cd=fax_type_cd)
      JOIN (od
      WHERE od.output_dest_cd=ox.output_dest_cd)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd
       AND rd.phone_suffix != null
       AND rd.phone_suffix > " ")
     ORDER BY o.org_name, o.organization_id, otr.org_type_cd,
      od.output_dest_cd
     HEAD REPORT
      knt = reply->org_knt
     HEAD o.organization_id
      dvar = 0
     HEAD otr.org_type_cd
      knt = (knt+ 1)
      IF (knt > size(reply->org,5))
       stat = alterlist(reply->org,(knt+ 9))
      ENDIF
      reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
      reply->org[knt].org_type_cd = otr.org_type_cd,
      oknt = reply->org[knt].output_dest_knt
     HEAD od.output_dest_cd
      oknt = (oknt+ 1)
      IF (oknt > size(reply->org[knt].output_dest,5))
       stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
      ENDIF
      reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
      output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
       = ox.usage_type_cd,
      reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
     FOOT  otr.org_type_cd
      reply->org[knt], output_dest_knt = oknt, stat = alterlist(reply->org[knt].output_dest,oknt)
     FOOT REPORT
      reply->org_knt = knt, stat = alterlist(reply->org,knt)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "OUTPUT_DEST_XREF"
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT
     o.*
     FROM (dummyt d1  WITH seq = value(loop_cnt)),
      (dummyt d2  WITH seq = value(request->org_type_knt)),
      org_type_reltn otr,
      organization o,
      device_xref dx,
      output_dest od,
      remote_device rd
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
      JOIN (o
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),o.organization_id,tmp_org->qual[idx].org_id)
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d2)
      JOIN (otr
      WHERE otr.organization_id=o.organization_id
       AND (((otr.org_type_cd=request->org_type[d2.seq].org_type_cd)) OR ((request->org_type[d2.seq].
      org_type_cd=0)))
       AND otr.active_ind=1
       AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (dx
      WHERE dx.parent_entity_name="ORGANIZATION"
       AND dx.parent_entity_id=o.organization_id
       AND dx.usage_type_cd=fax_type_cd)
      JOIN (od
      WHERE od.device_cd=dx.device_cd)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd
       AND rd.phone_suffix != null
       AND rd.phone_suffix > " ")
     ORDER BY o.org_name, o.organization_id, otr.org_type_cd,
      od.output_dest_cd
     HEAD REPORT
      knt = reply->org_knt, wknt = knt
     HEAD o.organization_id
      dvar = 0
     HEAD otr.org_type_cd
      add_org = true
      IF (wknt > 0)
       continue = true, iorg = 0, lknt = 1
       WHILE (continue=true
        AND lknt <= wknt)
        IF ((reply->org[lknt].organization_id=o.organization_id)
         AND (reply->org[lknt].org_type_cd=otr.org_type_cd))
         continue = false, add_org = false, iorg = lknt
        ENDIF
        ,lknt = (lknt+ 1)
       ENDWHILE
      ENDIF
      IF (add_org=true)
       knt = (knt+ 1)
       IF (knt > size(reply->org,5))
        stat = alterlist(reply->org,(knt+ 9))
       ENDIF
       reply->org[knt].organization_id = o.organization_id, reply->org[knt].org_name = o.org_name,
       reply->org[knt].org_type_cd = otr.org_type_cd,
       oknt = reply->org[knt].output_dest_knt
      ENDIF
     HEAD od.output_dest_cd
      IF (add_org=true)
       oknt = (oknt+ 1)
       IF (oknt > size(reply->org[knt].output_dest,5))
        stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
       ENDIF
       reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
       output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
        = dx.usage_type_cd,
       reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
      ELSE
       oknt = reply->org[iorg].output_dest_knt, w_oknt = oknt, continue = true,
       add_output = true, zknt = 1
       IF (w_oknt > 0)
        WHILE (continue=true
         AND zknt <= w_oknt)
         IF ((reply->org[iorg].output_dest[zknt].output_dest_cd=od.output_dest_cd))
          continue = false, add_output = false
         ENDIF
         ,zknt = (zknt+ 1)
        ENDWHILE
       ENDIF
       IF (add_output=true)
        oknt = (oknt+ 1)
        IF (oknt > size(reply->org[knt].output_dest,5))
         stat = alterlist(reply->org[knt].output_dest,(oknt+ 9))
        ENDIF
        reply->org[knt].output_dest[oknt].output_dest_cd = od.output_dest_cd, reply->org[knt].
        output_dest[oknt].output_dest_name = od.name, reply->org[knt].output_dest[oknt].usage_type_cd
         = dx.usage_type_cd,
        reply->org[knt].output_dest[oknt].fax_nbr_ind = 1
       ENDIF
      ENDIF
     FOOT  otr.org_type_cd
      IF (add_org=true)
       fknt = knt
      ELSE
       fknt = iorg
      ENDIF
      reply->org[fknt].output_dest_knt = oknt, stat = alterlist(reply->org[knt].output_dest,oknt)
     FOOT REPORT
      reply->org_knt = knt, stat = alterlist(reply->org,knt)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "DEVICE_XREF"
     GO TO exit_script
    ENDIF
    SELECT
     group_id = ppr_reply->qual[d.seq].reltn_qual[d2.seq].related_id, org_id = reply->org[d4.seq].
     organization_id
     FROM (dummyt d  WITH seq = value(size(ppr_reply->qual,5))),
      (dummyt d2  WITH seq = value(max_group_knt)),
      (dummyt d3  WITH seq = value(max_org_knt)),
      (dummyt d4  WITH seq = value(size(reply->org,5)))
     PLAN (d)
      JOIN (d2
      WHERE d2.seq <= size(ppr_reply->qual[d.seq].reltn_qual,5))
      JOIN (d3
      WHERE d3.seq <= size(ppr_reply->qual[d.seq].reltn_qual[d2.seq].member_qual,5))
      JOIN (d4
      WHERE d4.seq <= value(reply->org_knt)
       AND (reply->org[d4.seq].organization_id=ppr_reply->qual[d.seq].reltn_qual[d2.seq].member_qual[
      d3.seq].member_id))
     ORDER BY org_id, group_id
     HEAD REPORT
      col 0, "Organization_ID", col 20,
      "Group_ID", row + 1
     HEAD org_id
      group_knt = 0
     HEAD group_id
      group_knt = (group_knt+ 1), stat = alterlist(reply->org[d4.seq].group_qual,group_knt), reply->
      org[d4.seq].group_qual[group_knt].group_id = ppr_reply->qual[d.seq].reltn_qual[d2.seq].
      related_id,
      col 0, org_id, col 20,
      group_id, row + 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "DUMMYT3"
     GO TO exit_script
    ENDIF
    GO TO get_phone_addr
   ENDIF
 END ;Subroutine
#get_phone_addr
 DECLARE dbusphone = f8 WITH protect, noconstant(0.0)
 DECLARE dbusaddr = f8 WITH protect, noconstant(0.0)
 DECLARE lmaxdest = i4 WITH protect, noconstant(0)
 DECLARE lsize = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",1,dbusphone)
 SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",1,dbusaddr)
 SELECT INTO "nl:"
  FROM phone p
  WHERE expand(j,1,size(reply->org,5),p.parent_entity_id,reply->org[j].organization_id)
   AND p.parent_entity_name="ORGANIZATION"
   AND dbusphone=p.phone_type_cd
   AND p.active_ind=1
  DETAIL
   pos = locateval(j,1,size(reply->org,5),p.parent_entity_id,reply->org[j].organization_id)
   IF (p.phone_id > 0
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
    reply->org[pos].phone_num = trim(cnvtphone(p.phone_num,p.phone_format_cd)), reply->org[pos].
    contact = trim(p.contact)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address a
  WHERE expand(j,1,size(reply->org,5),a.parent_entity_id,reply->org[j].organization_id)
   AND a.parent_entity_name="ORGANIZATION"
   AND a.address_type_cd=dbusaddr
   AND a.active_ind=1
  DETAIL
   pos = locateval(j,1,size(reply->org,5),a.parent_entity_id,reply->org[j].organization_id)
   IF (a.address_id > 0
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
    reply->org[pos].street_addr = trim(a.street_addr), reply->org[pos].street_addr2 = trim(a
     .street_addr2), reply->org[pos].street_addr3 = trim(a.street_addr3),
    reply->org[pos].street_addr4 = trim(a.street_addr4), reply->org[pos].city = trim(a.city), reply->
    org[pos].state = trim(a.state),
    reply->org[pos].state_cd = a.state_cd, reply->org[pos].zipcode = trim(a.zipcode), reply->org[pos]
    .country = trim(a.country),
    reply->org[pos].country_cd = a.country_cd
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO value(reply->org_knt))
  SET lsize = value(size(reply->org[x].output_dest,5))
  IF (lsize > lmaxdest)
   SET lmaxdest = lsize
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(reply->org_knt)),
   (dummyt d2  WITH seq = value(lmaxdest)),
   output_dest od,
   remote_device rd,
   rrd_phone_mask rpm
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= reply->org[d.seq].output_dest_knt)
    AND (reply->org[d.seq].output_dest[d2.seq].fax_nbr_ind=1))
   JOIN (od
   WHERE (od.output_dest_cd=reply->org[d.seq].output_dest[d2.seq].output_dest_cd))
   JOIN (rd
   WHERE rd.device_cd=od.device_cd)
   JOIN (rpm
   WHERE outerjoin(rd.phone_mask_id)=rpm.phone_mask_id)
  DETAIL
   sfaxnbr = concat(trim(rd.country_access),trim(rd.area_code),trim(rd.exchange),trim(rd.phone_suffix
     ))
   IF (rpm.phone_mask_id > 0)
    sformat = concat(trim(rpm.country_code),trim(rpm.area_code),trim(rpm.exchange),trim(rpm.suffix)),
    sfaxnbr = format(sfaxnbr,sformat)
   ENDIF
   reply->org[d.seq].output_dest[d2.seq].fax_number = sfaxnbr
  WITH nocounter
 ;end select
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->org_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "005 05/11/06 AC013650"
END GO

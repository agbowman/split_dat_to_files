CREATE PROGRAM ce_get_event_codes:dba
 DECLARE batchsize = i4 WITH constant((request->batch_size+ 1))
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE gcnt = i4 WITH noconstant(0)
 DECLARE defeventclasscdmean = c12 WITH noconstant("")
 DECLARE codestatuscdmean = c12 WITH noconstant("")
 DECLARE eventcodestatuscdmean = c12 WITH noconstant("")
 DECLARE defeventconfidlevelcdmean = c12 WITH noconstant("")
 DECLARE defdocmntstoragecdmean = c12 WITH noconstant("")
 DECLARE defdocmntformatcdmean = c12 WITH noconstant("")
 DECLARE eventcdsubclasscdmean = c12 WITH noconstant("")
 DECLARE codestatuscdmean = c12 WITH noconstant("")
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  cva.contributor_source_cd, cva.alias, ec.event_cd,
  ec.event_cd_disp, cv1.cki, ec.event_cd_descr,
  ec.event_cd_definition, cv1.updt_dt_tm, ec.def_event_class_cd,
  ec.event_set_name, ec.event_add_access_ind, ec.event_chg_access_ind,
  ec.collating_seq, x.rn
  FROM v500_event_code ec,
   code_value_alias cva,
   code_value cv1,
   (
   (
   (SELECT
    rn = row_number() OVER(
    ORDER BY vec.event_cd), vec.event_cd, cv2.code_value
    FROM v500_event_code vec,
     code_value cv2
    WHERE (vec.event_cd > request->last_event_cd)
     AND cv2.code_value=vec.event_cd
    WITH sqltype("f8","f8","f8")))
   x)
  WHERE x.rn <= batchsize
   AND ec.event_cd=x.event_cd
   AND cv1.code_value=ec.event_cd
   AND (cva.code_value= Outerjoin(cv1.code_value))
  ORDER BY ec.event_cd
  HEAD REPORT
   gcnt += 1, stat = alterlist(reply->reply_list,gcnt)
  DETAIL
   IF (x.rn < batchsize)
    cnt += 1
    IF (cnt > 60000
     AND (ec.event_cd != reply->reply_list[gcnt].code_list[(cnt - 1)].event_cd))
     stat = alterlist(reply->reply_list[gcnt].code_list,(cnt - 1)), cnt = 1, gcnt += 1,
     stat = alterlist(reply->reply_list,gcnt)
    ENDIF
    IF (mod(cnt,500)=1)
     stat = alterlist(reply->reply_list[gcnt].code_list,(cnt+ 499))
    ENDIF
    reply->reply_list[gcnt].code_list[cnt].contributor_source_cd = cva.contributor_source_cd, reply->
    reply_list[gcnt].code_list[cnt].alias = trim(cva.alias), reply->reply_list[gcnt].code_list[cnt].
    event_cd = ec.event_cd,
    reply->reply_list[gcnt].code_list[cnt].event_cd_disp = trim(ec.event_cd_disp), reply->reply_list[
    gcnt].code_list[cnt].cki = trim(cv1.cki), reply->reply_list[gcnt].code_list[cnt].event_cd_descr
     = trim(ec.event_cd_descr),
    reply->reply_list[gcnt].code_list[cnt].event_cd_definition = trim(ec.event_cd_definition), reply
    ->reply_list[gcnt].code_list[cnt].code_status_cd_mean = uar_get_code_meaning(ec.code_status_cd),
    reply->reply_list[gcnt].code_list[cnt].event_code_status_cd_mean = uar_get_code_meaning(ec
     .event_code_status_cd),
    reply->reply_list[gcnt].code_list[cnt].updt_dt_tm = cv1.updt_dt_tm
    IF (ec.def_event_level=0)
     reply->reply_list[gcnt].code_list[cnt].def_event_level = "D"
    ELSE
     reply->reply_list[gcnt].code_list[cnt].def_event_level = "G"
    ENDIF
    reply->reply_list[gcnt].code_list[cnt].def_event_class_cd_mean = uar_get_code_meaning(ec
     .def_event_class_cd), reply->reply_list[gcnt].code_list[cnt].def_event_confid_level_cd_mean =
    uar_get_code_meaning(ec.def_event_confid_level_cd), reply->reply_list[gcnt].code_list[cnt].
    event_set_name = trim(ec.event_set_name),
    reply->reply_list[gcnt].code_list[cnt].def_docmnt_storage_cd_mean = uar_get_code_meaning(ec
     .def_docmnt_storage_cd), reply->reply_list[gcnt].code_list[cnt].def_docmnt_format_cd_mean =
    uar_get_code_meaning(ec.def_docmnt_format_cd), reply->reply_list[gcnt].code_list[cnt].
    event_code_subclass_cd_mean = uar_get_code_meaning(ec.event_cd_subclass_cd),
    reply->reply_list[gcnt].code_list[cnt].event_add_access_ind = ec.event_add_access_ind, reply->
    reply_list[gcnt].code_list[cnt].event_chg_access_ind = ec.event_chg_access_ind, reply->
    reply_list[gcnt].code_list[cnt].collating_seq = ec.collating_seq
   ENDIF
  FOOT REPORT
   IF (x.rn >= batchsize)
    reply->has_more_ind = 1, reply->last_event_cd = reply->reply_list[gcnt].code_list[cnt].event_cd
   ENDIF
 ;end select
 SET stat = alterlist(reply->reply_list[gcnt].code_list,cnt)
 SET stat = alterlist(reply->reply_list,gcnt) WITH nocounter
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO

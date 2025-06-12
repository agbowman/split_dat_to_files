CREATE PROGRAM dcp_get_act_tz_exceptions:dba
 SET modify = predeclare
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lfindindex = i4 WITH protect, noconstant(0)
 DECLARE lcount = i4 WITH protect, noconstant(0)
 DECLARE lsize = i4 WITH protect, noconstant(0)
 DECLARE lreplyphasesize = i4 WITH protect, noconstant(0)
 DECLARE ltimezeroexceptioncount = i4 WITH protect, noconstant(0)
 DECLARE ltimezeroexceptionsize = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 SET lsize = size(request->phaselist,5)
 SET stat = alterlist(reply->phaselist,lsize)
 FOR (lcount = 1 TO lsize)
   SET reply->phaselist[lcount].pathway_id = request->phaselist[lcount].pathwayid
 ENDFOR
 SET lreplyphasesize = size(reply->phaselist,5)
 SELECT INTO "nl:"
  FROM act_pw_comp_r apcr
  WHERE expand(num,1,lreplyphasesize,apcr.pathway_id,reply->phaselist[num].pathway_id)
   AND apcr.type_mean="TIMEZERODOT"
  ORDER BY apcr.pathway_id
  HEAD REPORT
   ndummy = 0
  HEAD apcr.pathway_id
   ltimezeroexceptioncount = 0, ltimezeroexceptionsize = 0, idx = locateval(lfindindex,1,
    lreplyphasesize,apcr.pathway_id,reply->phaselist[lfindindex].pathway_id)
  DETAIL
   IF (idx > 0)
    ltimezeroexceptioncount = (ltimezeroexceptioncount+ 1)
    IF (ltimezeroexceptioncount > ltimezeroexceptionsize)
     ltimezeroexceptionsize = (ltimezeroexceptionsize+ 5), stat = alterlist(reply->phaselist[idx].
      timezeroexceptionlist,ltimezeroexceptionsize)
    ENDIF
    reply->phaselist[idx].timezeroexceptionlist[ltimezeroexceptioncount].act_pw_comp_s_id = apcr
    .act_pw_comp_s_id, reply->phaselist[idx].timezeroexceptionlist[ltimezeroexceptioncount].
    act_pw_comp_t_id = apcr.act_pw_comp_t_id, reply->phaselist[idx].timezeroexceptionlist[
    ltimezeroexceptioncount].type_mean = apcr.type_mean,
    reply->phaselist[idx].timezeroexceptionlist[ltimezeroexceptioncount].offset_quantity = apcr
    .offset_quantity, reply->phaselist[idx].timezeroexceptionlist[ltimezeroexceptioncount].
    offset_unit_cd = apcr.offset_unit_cd
   ENDIF
  FOOT  apcr.pathway_id
   IF (ltimezeroexceptioncount > 0)
    stat = alterlist(reply->phaselist[idx].timezeroexceptionlist,ltimezeroexceptioncount)
   ENDIF
  FOOT REPORT
   ndummy = 0
  WITH nocounter
 ;end select
 IF (lreplyphasesize > 0)
  SET cstatus = "S"
 ENDIF
 SET reply->status_data.status = cstatus
END GO

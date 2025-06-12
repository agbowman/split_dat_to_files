CREATE PROGRAM dcp_solcap_routing_selections:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 solcap[*]
      2 identifier = vc
      2 degree_of_use_num = i4
      2 degree_of_use_str = vc
      2 distinct_user_count = i4
      2 position[*]
        3 display = vc
        3 value_num = i4
        3 value_str = vc
      2 facility[*]
        3 display = vc
        3 value_num = i4
        3 value_str = vc
      2 other[*]
        3 category_name = vc
        3 value[*]
          4 display = vc
          4 value_num = i4
          4 value_str = vc
  )
 ENDIF
 DECLARE dcustompatpreferredpharmcd = f8 WITH constant(uar_get_code_by("MEANING",355,"DEFPATPHARM"))
 DECLARE itotaluserscnt = i4 WITH protect, noconstant(0)
 DECLARE itotalpharmaciescnt = i4 WITH protect, noconstant(0)
 DECLARE ipatientpharmaciescnt = i4 WITH protect, noconstant(0)
 DECLARE itotalpatientscnt = i4 WITH protect, noconstant(0)
 DECLARE icurpatcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE last_mod = vc
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.2.00100.3"
 SELECT INTO "nl:"
  itotalpharmacies = count(pi.person_info_id), itotalusers = count(DISTINCT pi.updt_id)
  FROM person_info pi
  WHERE pi.beg_effective_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
   AND pi.info_type_cd=dcustompatpreferredpharmcd
   AND pi.long_text_id > 0.0
  DETAIL
   itotalpharmaciescnt = itotalpharmacies, itotaluserscnt = itotalusers, reply->solcap[1].
   distinct_user_count = itotaluserscnt,
   reply->solcap[1].degree_of_use_num = itotalpharmaciescnt
   IF (itotalpharmaciescnt > 0)
    reply->solcap[1].degree_of_use_str = "YES"
   ELSE
    reply->solcap[1].degree_of_use_str = "NA"
   ENDIF
  WITH nocounter
 ;end select
 IF (itotalpharmaciescnt > 0)
  SET stat = alterlist(reply->solcap[1].other,1)
  SET reply->solcap[1].other[1].category_name = "Added/Updated pharmacies within given date/time"
  SELECT INTO "nl:"
   FROM person_info pi
   WHERE pi.beg_effective_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pi.info_type_cd=dcustompatpreferredpharmcd
    AND pi.long_text_id > 0.0
   ORDER BY pi.person_id
   HEAD pi.person_id
    icurpatcnt += 1
    IF (icurpatcnt > size(reply->solcap[1].other[1].value,5))
     stat = alterlist(reply->solcap[1].other[1].value,(icurpatcnt+ 10))
    ENDIF
    reply->solcap[1].other[1].value[icurpatcnt].display = build2("person_id: ",trim(format(pi
       .person_id,";T(1);F"),3))
   DETAIL
    ipatientpharmaciescnt += 1
   FOOT  pi.person_id
    reply->solcap[1].other[1].value[icurpatcnt].value_num = ipatientpharmaciescnt,
    ipatientpharmaciescnt = 0
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->solcap[1].other[1].value,icurpatcnt)
 ENDIF
 SET last_mod = "001"
END GO

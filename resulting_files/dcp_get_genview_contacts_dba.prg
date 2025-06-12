CREATE PROGRAM dcp_get_genview_contacts:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs20 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs20 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs20 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs20 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs20 \i \cb2 \pard\sl0 "
 SET reol = "\par"
 SET rtab = "\tab"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET code_value = 0.0
 SET code_set = 0
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE temp_phone = c50 WITH public, noconstant(fillstring(50," "))
 DECLARE fmt_phone = c50 WITH public, noconstant(fillstring(50," "))
 DECLARE fmt_zipcode = c25 WITH public, noconstant(fillstring(25," "))
 DECLARE temp = c100 WITH public, noconstant(fillstring(100," "))
 SET code_set = 281
 SET cdf_meaning = "DEFAULT"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE default_format_cd = f8 WITH public, constant(code_value)
 SET code_set = 43
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE home_phone_cd = f8 WITH public, constant(code_value)
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE bus_phone_cd = f8 WITH public, constant(code_value)
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE home_address_cd = f8 WITH public, constant(code_value)
 SET code_set = 351
 SET cdf_meaning = "GUARDIAN"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE guardian_reltn_cd = f8 WITH public, constant(code_value)
 SET cdf_meaning = "EMC"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE emc_reltn_cd = f8 WITH public, constant(code_value)
 SET cdf_meaning = "FAMILY"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE family_reltn_cd = f8 WITH public, constant(code_value)
 SET cdf_meaning = "NOK"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE nok_reltn_cd = f8 WITH public, constant(code_value)
 SET reply->text = rhead
 SELECT INTO "nl:"
  p.person_id, ph.phone_type_cd, a.address_id
  FROM encounter e,
   encntr_person_reltn epr,
   person_person_reltn ppr,
   phone ph,
   address a,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (epr
   WHERE (((epr.encntr_id=request->visit[1].encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND epr.person_reltn_type_cd IN (guardian_reltn_cd, emc_reltn_cd, family_reltn_cd, nok_reltn_cd))
    OR (epr.encntr_person_reltn_id=0)) )
   JOIN (ppr
   WHERE ((ppr.person_id=e.person_id
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ppr.person_reltn_type_cd IN (guardian_reltn_cd, emc_reltn_cd, family_reltn_cd, nok_reltn_cd))
    OR (ppr.person_person_reltn_id=0)) )
   JOIN (p
   WHERE ((p.person_id=epr.related_person_id) OR (p.person_id=ppr.related_person_id))
    AND p.active_ind=1
    AND ((epr.encntr_person_reltn_id > 0
    AND ppr.person_person_reltn_id <= 0) OR (epr.encntr_person_reltn_id <= 0
    AND ppr.person_person_reltn_id > 0)) )
   JOIN (ph
   WHERE ((ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ph.phone_type_cd IN (home_phone_cd, bus_phone_cd)) OR (ph.phone_id=0)) )
   JOIN (a
   WHERE ((a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.address_type_cd=home_address_cd) OR (a.address_id=0)) )
  ORDER BY uar_get_collation_seq(ppr.person_reltn_type_cd), uar_get_collation_seq(epr
    .person_reltn_type_cd), p.person_id,
   a.address_id DESC, ph.phone_type_seq, ph.phone_type_cd
  HEAD REPORT
   reply->text = concat(reply->text,rh2bu), reply->text = concat(reply->text,"Patient Contacts",reol)
  HEAD p.person_id
   addr_cnt = 0, reply->text = concat(reply->text,reol,wb,trim(p.name_full_formatted),reol)
   IF (epr.encntr_person_reltn_id > 0)
    IF (epr.person_reltn_type_cd > 0)
     reply->text = concat(reply->text,rtab,wr,trim(uar_get_code_display(epr.person_reltn_type_cd)),
      reol)
    ENDIF
    IF (epr.person_reltn_cd > 0)
     reply->text = concat(reply->text,rtab,wr,trim(uar_get_code_display(epr.person_reltn_cd)),reol)
    ENDIF
   ELSEIF (ppr.person_person_reltn_id > 0)
    IF (ppr.person_reltn_type_cd > 0)
     reply->text = concat(reply->text,rtab,wr,trim(uar_get_code_display(ppr.person_reltn_type_cd)),
      reol)
    ENDIF
    IF (ppr.person_reltn_cd > 0)
     reply->text = concat(reply->text,rtab,wr,trim(uar_get_code_display(ppr.person_reltn_cd)),reol)
    ENDIF
   ENDIF
  HEAD a.address_id
   addr_cnt = (addr_cnt+ 1)
   IF (a.address_id > 0)
    IF (a.street_addr > " ")
     reply->text = concat(reply->text,rtab,wr,trim(a.street_addr),reol), fmt_address = a.street_addr
    ENDIF
    IF (a.street_addr2 > " ")
     reply->text = concat(reply->text,rtab,wr,trim(a.street_addr2),reol)
    ENDIF
    IF (a.city > " ")
     reply->text = concat(reply->text,rtab,wr,trim(a.city))
     IF (a.state > " ")
      temp = a.state, reply->text = concat(reply->text,", ",trim(temp))
     ELSEIF (a.state_cd > 0)
      temp = uar_get_code_display(a.state_cd), reply->text = concat(reply->text,", ",trim(temp))
     ENDIF
    ELSE
     IF (a.state > " ")
      temp = a.state, reply->text = concat(reply->text,rtab,wr,trim(temp))
     ELSEIF (a.state_cd > 0)
      temp = uar_get_code_display(a.state_cd), reply->text = concat(reply->text,rtab,wr,trim(temp))
     ENDIF
    ENDIF
    IF (a.zipcode > " ")
     fmt_zipcode = ""
     IF (size(trim(a.zipcode)) > 5)
      fmt_zipcode = format(trim(a.zipcode),"#####-####")
     ELSE
      fmt_zipcode = format(trim(a.zipcode),"#####")
     ENDIF
     IF (((a.city > " ") OR (temp > " ")) )
      reply->text = concat(reply->text,"  ",wr,trim(fmt_zipcode))
     ELSE
      reply->text = concat(reply->text,rtab,wr,trim(fmt_zipcode))
     ENDIF
    ENDIF
    reply->text = concat(reply->text,reol)
   ENDIF
  HEAD ph.phone_type_cd
   IF (addr_cnt <= 1)
    fmt_phone = " "
    IF (ph.phone_num > " "
     AND ph.parent_entity_id > 0)
     temp_phone = cnvtalphanum(ph.phone_num)
     IF (temp_phone != ph.phone_num)
      fmt_phone = ph.phone_num
     ELSEIF (ph.phone_format_cd > 0)
      fmt_phone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSEIF (default_format_cd > 0)
      fmt_phone = cnvtphone(trim(ph.phone_num),default_format_cd)
     ELSEIF (size(trim(temp_phone)) < 8)
      fmt_phone = format(trim(ph.phone_num),"###-####")
     ELSE
      fmt_phone = format(trim(ph.phone_num),"(###) ###-####")
     ENDIF
     IF (fmt_phone <= " ")
      fmt_phone = ph.phone_num
     ENDIF
     reply->text = concat(reply->text,rtab,wr,trim(uar_get_code_display(ph.phone_type_cd)),": ",
      fmt_phone,reol)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO

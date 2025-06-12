CREATE PROGRAM dcp_get_genview_providers:dba
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
 DECLARE temp_phone = c22 WITH public, noconstant(fillstring(12," "))
 DECLARE fmt_phone = c22 WITH public, noconstant(fillstring(12," "))
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
 SET cdf_meaning = "FAX BUS"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE bus_fax_cd = f8 WITH public, constant(code_value)
 SET cdf_meaning = "PAGER BUS"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE bus_pager_cd = f8 WITH public, constant(code_value)
 SET cdf_meaning = "PORT BUS"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE bus_cell_cd = f8 WITH public, constant(code_value)
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_prsnl_reltn epr,
   person_prsnl_reltn ppr,
   phone ph,
   prsnl prs
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (epr
   WHERE (((epr.encntr_id=request->visit[1].encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND epr.expiration_ind=0) OR (epr.encntr_prsnl_reltn_id=0)) )
   JOIN (ppr
   WHERE ((ppr.person_id=e.person_id
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ppr.person_prsnl_reltn_id=0)) )
   JOIN (prs
   WHERE ((prs.person_id=epr.prsnl_person_id) OR (prs.person_id=ppr.prsnl_person_id))
    AND prs.active_ind=1
    AND ((epr.encntr_prsnl_reltn_id > 0
    AND ppr.person_prsnl_reltn_id <= 0) OR (ppr.person_prsnl_reltn_id > 0
    AND epr.encntr_prsnl_reltn_id <= 0)) )
   JOIN (ph
   WHERE ((ph.parent_entity_id=prs.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ph.phone_type_cd IN (home_phone_cd, bus_phone_cd, bus_fax_cd, bus_pager_cd, bus_cell_cd)) OR
   (ph.phone_id=0)) )
  ORDER BY prs.person_id, ph.phone_type_seq, ph.phone_type_cd
  HEAD REPORT
   reply->text = concat(rhead,rh2bu), reply->text = concat(reply->text,"Provider Contact Information",
    reol)
  HEAD prs.person_id
   reply->text = concat(reply->text,reol,wb,trim(prs.name_full_formatted),reol), reply->text = concat
   (reply->text,rtab,wr,trim(uar_get_code_display(prs.position_cd)))
   IF (epr.encntr_prsnl_reltn_id > 0)
    reply->text = concat(reply->text,"  -  ",trim(uar_get_code_display(epr.encntr_prsnl_r_cd)))
   ELSEIF (ppr.person_prsnl_reltn_id > 0)
    reply->text = concat(reply->text,"  -  ",trim(uar_get_code_display(ppr.person_prsnl_r_cd)))
   ENDIF
   reply->text = concat(reply->text,reol)
  HEAD ph.phone_type_cd
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
  FOOT  prs.person_id
   IF (prs.email > " ")
    reply->text = concat(reply->text,rtab,wr,"E-mail: ",trim(prs.email),
     reol,wr)
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO

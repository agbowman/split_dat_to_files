CREATE PROGRAM dcp_get_genview_phys:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswissArial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 SET temp_disp1 = fillstring(200," ")
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 RECORD temp(
   1 admit_doc_id = f8
   1 admit = vc
   1 ad_phone = vc
   1 ad_pager = vc
   1 attend_doc_id = f8
   1 attend = vc
   1 at_phone = vc
   1 at_pager = vc
 )
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET fmtphone = fillstring(22," ")
 SET bus_phone_cd = 0
 SET pager_cd = 0
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_phone_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "PAGER BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET pager_cd = code_value
 SET visit_cnt = 1
 FOR (x = 1 TO visit_cnt)
  SELECT INTO "nl:"
   epr.prsnl_person_id, p.name_full_formatted, ph.phone_num
   FROM encntr_prsnl_reltn epr,
    prsnl p,
    (dummyt d  WITH seq = 1),
    phone ph
   PLAN (epr
    WHERE (epr.encntr_id=request->visit[x].encntr_id)
     AND epr.active_ind=1
     AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null))
     AND epr.encntr_prsnl_r_cd IN (attend_doc_cd, admit_doc_cd))
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
    JOIN (d)
    JOIN (ph
    WHERE ph.parent_entity_name="PERSON"
     AND ph.parent_entity_id=p.person_id
     AND ph.parent_entity_id != 0
     AND ((ph.phone_type_cd=bus_phone_cd) OR (ph.phone_type_cd=pager_cd)) )
   ORDER BY epr.encntr_prsnl_r_cd
   HEAD epr.encntr_prsnl_r_cd
    IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
     temp->admit_doc_id = p.person_id, temp->admit = trim(p.name_full_formatted)
    ELSE
     temp->attend_doc_id = p.person_id, temp->attend = trim(p.name_full_formatted)
    ENDIF
   DETAIL
    IF (ph.phone_type_cd=bus_phone_cd)
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSE
      fmtphone = ph.phone_num
     ENDIF
     IF (ph.extension > " ")
      fmtphone = concat(trim(fmtphone)," x",ph.extension)
     ENDIF
     IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
      temp->ad_phone = fmtphone
     ELSE
      temp->at_phone = fmtphone
     ENDIF
    ENDIF
    IF (ph.phone_type_cd=pager_cd)
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSE
      fmtphone = ph.phone_num
     ENDIF
     IF (ph.extension > " ")
      fmtphone = concat(trim(fmtphone)," x",ph.extension)
     ENDIF
     IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
      temp->ad_pager = fmtphone
     ELSE
      temp->at_pager = fmtphone
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,"PHYSICIAN INFO",reol,wr)
    IF ((temp->attend > " "))
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     drec->line_qual[lidx].disp_line = concat("   Attending:  ",trim(temp->attend),reol)
     IF ((temp->at_phone > " "))
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      drec->line_qual[lidx].disp_line = concat("       Phone:  ",trim(temp->at_phone),reol)
     ENDIF
     IF ((temp->at_pager > " "))
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      drec->line_qual[lidx].disp_line = concat("       Pager:  ",trim(temp->at_pager),reol)
     ENDIF
    ENDIF
    IF ((temp->admit > " "))
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     drec->line_qual[lidx].disp_line = concat("   Admitting:  ",trim(temp->admit),reol)
     IF ((temp->ad_phone > " "))
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      drec->line_qual[lidx].disp_line = concat("       Phone:  ",trim(temp->ad_phone),reol)
     ENDIF
     IF ((temp->ad_pager > " "))
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      drec->line_qual[lidx].disp_line = concat("       Pager:  ",trim(temp->ad_pager),reol)
     ENDIF
    ENDIF
   FOOT REPORT
    FOR (x = 1 TO lidx)
      reply->text = concat(reply->text,drec->line_qual[x].disp_line)
    ENDFOR
   WITH nocounter, maxcol = 500, maxrow = 800
  ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO

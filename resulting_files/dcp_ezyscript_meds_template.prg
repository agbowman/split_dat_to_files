CREATE PROGRAM dcp_ezyscript_meds_template
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs24 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs20 \cb2 "
 SET wb = " \plain \f0 \fs20 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET rtfeof = "}"
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD lab(
   1 cnt = i2
   1 qual[*]
     2 val = vc
     2 date = vc
     2 label = vc
     2 unit = vc
 )
 RECORD ord(
   1 cnt = i2
   1 qual[*]
     2 type = vc
     2 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET lidx = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name = fillstring(50," ")
 SET dob = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET person_id = 0
 SET encntr_id = 0
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET pharm_cd = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharm_cd = code_value
 SET canceled_cd = 0
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET inerror_cd = 0
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET completed_cd = 0.0
 SET code_set = 6004
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET completed_cd = code_value
 SELECT INTO "nl:"
  FROM encntr_domain e,
   person p,
   (dummyt d  WITH seq = 1),
   person_alias pa,
   (dummyt d1  WITH seq = 1)
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
   JOIN (d1)
  DETAIL
   name = substring(1,40,p.name_full_formatted), mrn = substring(1,20,pa.alias), person_id = e
   .person_id,
   encntr_id = e.encntr_id
  WITH nocounter, outerjoin = d, dontcare = pa,
   outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_type_cd=pharm_cd
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag IN (1, 2)
    AND o.order_status_cd IN (ordered_cd, completed_cd))
   JOIN (od
   WHERE o.order_id=od.order_id)
  ORDER BY o.order_mnemonic
  HEAD REPORT
   ord->cnt = 0
  HEAD o.order_id
   ord->cnt = (ord->cnt+ 1), stat = alterlist(ord->qual,ord->cnt), ord->qual[ord->cnt].type = o
   .order_mnemonic,
   ord->qual[ord->cnt].line = o.clinical_display_line, ord->qual[ord->cnt].line = concat(trim(ord->
     qual[ord->cnt].type)," - ",trim(ord->qual[ord->cnt].line))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rhead,rh2b,rtab,rtab,rtab,
    "EasyScript Orders ",trim(name),reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wbu,"Discharge Medications",reol)
   IF ((ord->cnt > 0))
    FOR (x = 1 TO ord->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(ord->qual[x].line),reol)
    ENDFOR
   ENDIF
  FOOT REPORT
   FOR (z = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[z].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 132, maxrow = 500
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
END GO

CREATE PROGRAM dcp_get_genview_kardex3:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
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
 SET lidx = 0
 SET temp_disp1 = fillstring(200," ")
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "PENDING REV"
 EXECUTE cpm_get_cd_for_cdf
 SET pendingrev_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "Active Orders:"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,wr)
 SET visit_cnt = 1
 FOR (x = 1 TO visit_cnt)
   SELECT INTO "nl:"
    o.order_id, o.catalog_type_cd, o.orig_order_dt_tm
    FROM orders o
    PLAN (o
     WHERE (o.encntr_id=request->visit[x].encntr_id)
      AND o.order_status_cd IN (ordered_cd, pendingrev_cd, inprocess_cd))
    ORDER BY o.catalog_type_cd, o.orig_order_dt_tm
    HEAD REPORT
     catalog_type = fillstring(30," ")
    HEAD o.catalog_type_cd
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
     stat = alterlist(drec->line_qual,lidx), catalog_type = substring(1,30,uar_get_code_display(o
       .catalog_type_cd)), drec->line_qual[lidx].disp_line = concat(wr,trim(catalog_type),reol,wr)
    DETAIL
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     xyz = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), drec->line_qual[lidx].disp_line = concat(
      wr,"    ",trim(xyz)," ",trim(o.order_mnemonic),
      " ",trim(o.clinical_display_line),reol)
    WITH nocounter, outerjoin = d1, dontcare = n,
     dontcare = r, outerjoin = d2, dontcare = n2,
     maxcol = 500, maxrow = 500
   ;end select
 ENDFOR
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO

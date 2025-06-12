CREATE PROGRAM bhs_athn_get_dd_templates
 RECORD out_rec(
   1 templates[*]
     2 template_title = vc
     2 template_desc = vc
     2 template_id = vc
 )
 SELECT INTO "nl:"
  FROM dd_ref_template drt
  PLAN (drt
   WHERE drt.active_ind=1)
  ORDER BY drt.title_txt
  HEAD REPORT
   cnt = 0
  HEAD drt.title_txt
   cnt = (cnt+ 1), stat = alterlist(out_rec->templates,cnt), out_rec->templates[cnt].template_title
    = drt.title_txt,
   out_rec->templates[cnt].template_desc = drt.description_txt, out_rec->templates[cnt].template_id
    = cnvtstring(drt.dd_ref_template_id)
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO

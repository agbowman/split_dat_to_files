CREATE PROGRAM bhs_athn_encntrtype_by_group
 DECLARE cnt = f8
 SET cnt = 0
 FREE RECORD out_rec
 RECORD out_rec(
   1 qual[*]
     2 parent_cd = vc
     2 parent_disp = vc
     2 parent_code = vc
     2 child_cd = vc
     2 child_disp = vc
 ) WITH protect
 SELECT INTO "nl:"
  cvg.parent_code_value, parent_disp = uar_get_code_display(cvg.parent_code_value), parent_code = cv1
  .display_key,
  cvg.child_code_value, child_disp = uar_get_code_display(cvg.child_code_value)
  FROM code_value_group cvg,
   code_value cv,
   code_value cv1
  PLAN (cvg
   WHERE cvg.code_set=71)
   JOIN (cv
   WHERE cvg.child_code_value=cv.code_value
    AND cv.active_ind=1)
   JOIN (cv1
   WHERE cvg.parent_code_value=cv1.code_value)
  ORDER BY parent_disp, child_disp
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(out_rec->qual,cnt), out_rec->qual[cnt].child_cd = cnvtstring(cvg
    .child_code_value),
   out_rec->qual[cnt].child_disp = child_disp, out_rec->qual[cnt].parent_cd = cnvtstring(cvg
    .parent_code_value), out_rec->qual[cnt].parent_disp = parent_disp,
   out_rec->qual[cnt].parent_code = parent_code
  WITH time = 30
 ;end select
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
END GO

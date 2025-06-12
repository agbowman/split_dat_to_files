CREATE PROGRAM bhs_ma_exam_wo_folder
 PROMPT
  "Output to File/Printer/MINE " = "MINE"
  WITH outdev
 SELECT INTO  $1
  examsnofolder = uar_get_code_display(oc.catalog_cd)
  FROM order_catalog oc
  WHERE oc.activity_type_cd=711
   AND oc.active_ind=1
   AND  NOT ( EXISTS (
  (SELECT
   ef.catalog_cd
   FROM exam_folder ef
   WHERE ef.catalog_cd=oc.catalog_cd)))
  WITH nocounter, separator = " ", format
 ;end select
END GO

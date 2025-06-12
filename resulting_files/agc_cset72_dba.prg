CREATE PROGRAM agc_cset72:dba
 SELECT
  cv.code_value, cv.code_set, cv.cdf_meaning,
  cv.display, cv.display_key, cv.description,
  cv.definition, cva.alias, cva.contributor_source_cd,
  source = uar_get_code_display(cva.contributor_source_cd)
  FROM code_value cv,
   code_value_alias cva
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.active_ind=1)
   JOIN (cva
   WHERE cva.code_value=cv.code_value
    AND cva.code_set=72)
  ORDER BY cv.code_value
  HEAD REPORT
   col 1, "CODE_VALUE", col 50,
   ",CODE_SET", col 100, ",CDF_MEANING",
   col 175, ",DISPLAY", col 250,
   ",DISPLAY_KEY", col 350, ",DESCRIPTION",
   col 400, ",DEFINITION", col 460,
   ", ALIAS", col 500, ",CONTRIBUTOR",
   col 550, ",contrib_disp", row + 1
  DETAIL
   col 1, cv.code_value, col 50,
   ",", cv.code_set, col 100,
   ",", cv.cdf_meaning, col 175,
   ",", cv.display, col 250,
   ",", cv.display_key, col 350,
   ",", cv.description, col 400,
   ",", cv.definition, col 460,
   ",", cva.alias, col 500,
   ",", cva.contributor_source_cd, col 550,
   ",", source, row + 1
  WITH maxcol = 1000
 ;end select
END GO

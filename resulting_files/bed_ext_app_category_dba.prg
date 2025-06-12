CREATE PROGRAM bed_ext_app_category:dba
 SELECT INTO "CER_INSTALL:ps_app_category.csv"
  FROM br_app_category b
  ORDER BY b.display_group_seq, b.sequence
  HEAD REPORT
   "display_group_category, sequence,category,cat_sequence"
  DETAIL
   category = concat('"',trim(b.display_group_desc),'"'), cat_sequence = b.display_group_seq,
   description = concat('"',trim(b.description),'"'),
   sequence = b.sequence, row + 1, line = concat(trim(category),",",trim(cnvtstring(cat_sequence)),
    ",",trim(description),
    ",",trim(cnvtstring(sequence))),
   line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO

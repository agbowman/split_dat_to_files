CREATE PROGRAM afc_rpt_tier_menu:dba
 PAINT
 SET width = 140
 SET modify = system
 RECORD tier(
   1 data[8]
     2 tier_option = vc
 )
 CALL text(2,10,"Press Shift+F5 for a list of TIERS to choose")
 CALL text(5,10,"Tier Option :")
 CALL text(15,10,"Choose 8 of the following fields :")
 SET help =
 SELECT DISTINCT INTO "NL:"
  c.cdf_meaning, c.display
  FROM code_value c
  WHERE c.code_set=13036
   AND ((c.cdf_meaning="FIN CLASS") OR (((c.cdf_meaning="INTERFACE") OR (((c.cdf_meaning=
  "CHARGE POINT") OR (((c.cdf_meaning="SERVICERES") OR (((c.cdf_meaning="VISITTYPE") OR (((c
  .cdf_meaning="ORG") OR (((c.cdf_meaning="PRICESCHED") OR (((c.cdf_meaning="CPT4") OR (((c
  .cdf_meaning="ICD9") OR (((c.cdf_meaning="CDM_SCHED") OR (((c.cdf_meaning="HOLD_SUSP") OR (((c
  .cdf_meaning="FLAT_DISC") OR (((c.cdf_meaning="PAT LOC") OR (((c.cdf_meaning="COL PRIORITY") OR (((
  c.cdf_meaning="RPT PRIORITY") OR (c.cdf_meaning="ADD ON"
   AND c.active_ind=1)) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  WITH nocounter
 ;end select
 CALL accept(5,30,"A(12);CU;",0)
 SET tier->data[1].tier_option = curaccept
 CALL accept(6,30,"A(12);CU;",0)
 SET tier->data[2].tier_option = curaccept
 CALL accept(7,30,"A(12);CU;",0)
 SET tier->data[3].tier_option = curaccept
 CALL accept(8,30,"A(12);CU;",0)
 SET tier->data[4].tier_option = curaccept
 CALL accept(9,30,"A(12);CU;",0)
 SET tier->data[5].tier_option = curaccept
 CALL accept(10,30,"A(12);CU;",0)
 SET tier->data[6].tier_option = curaccept
 CALL accept(11,30,"A(12);CU;",0)
 SET tier->data[7].tier_option = curaccept
 CALL accept(12,30,"A(12);CU;",0)
 SET tier->data[8].tier_option = curaccept
 CALL text(17,10,"Processing...")
 SET g_tier_option_one = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[1].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_one = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_one is: ",g_tier_option_one))
 SET g_tier_option_two = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[2].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_two = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_two is: ",g_tier_option_two))
 SET g_tier_option_three = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[3].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_three = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_three is: ",g_tier_option_three))
 SET g_tier_option_four = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[4].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_four = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_four is: ",g_tier_option_four))
 SET g_tier_option_five = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[5].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_five = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_five is: ",g_tier_option_five))
 SET g_tier_option_six = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[6].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_six = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_six is: ",g_tier_option_six))
 SET g_tier_option_seven = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[7].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_seven = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_seven is: ",g_tier_option_seven))
 SET g_tier_option_eight = fillstring(12," ")
 SELECT INTO "NL:"
  c.cdf_meaning
  FROM code_value c
  WHERE (c.cdf_meaning=tier->data[8].tier_option)
   AND active_ind=1
  DETAIL
   g_tier_option_eight = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL echo(build("g_tier_option_eight is: ",g_tier_option_eight))
 SET option1_heading = g_tier_option_one
 SET option2_heading = g_tier_option_two
 SET option3_heading = g_tier_option_three
 SET option4_heading = g_tier_option_four
 SET option5_heading = g_tier_option_five
 SET option6_heading = g_tier_option_six
 SET option7_heading = g_tier_option_seven
 SET option8_heading = g_tier_option_eight
 FOR (i = 1 TO 8)
   CASE (tier->data[i].tier_option)
    OF "FIN CLASS":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE t.tier_cell_type_cd=c.code_value
        AND c.cdf_meaning="FIN CLASS")
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "CHARGE POINT":
     SELECT
      c.display
      FROM code_value c,
       tier_matrix t
      WHERE c.code_set=14002
       AND c.code_value=t.tier_cell_value
       AND c.cdf_meaning="CHARGE POINT"
       AND t.active_ind=1
     ;end select
    OF "SERVICERES":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE t.tier_cell_type_cd=c.code_value
        AND c.cdf_meaning="SERVICERES")
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "COL PRIORITY":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE t.tier_cell_type_cd=c.code_value
        AND c.cdf_meaning="COL PRIORITY")
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "ORG":
     SELECT
      o.org_name
      FROM code_value c,
       tier_matrix t,
       organization o
      WHERE t.tier_cell_value=o.organization_id
       AND c.cdf_meaning="ORG"
       AND c.code_set=13036
     ;end select
    OF "PRICESCHED":
     SELECT
      p.price_sched_desc
      FROM code_value c,
       tier_matrix t,
       price_sched p
      WHERE t.tier_cell_value=p.price_sched_id
       AND c.cdf_meaning="PRICESCHED"
       AND c.code_set=13036
     ;end select
    OF "CDM_SCHED":
     SELECT
      c.display
      FROM code_value c,
       tier_matrix t
      WHERE t.tier_cell_value=c.code_value
       AND c.cdf_meaning="CDM_SCHED"
       AND c.code_set=14002
     ;end select
    OF "HOLD_SUSP":
     SELECT
      c.display
      FROM code_value c,
       tier_matrix t
      WHERE t.tier_cell_type_cd=c.code_value
       AND c.cdf_meaning="HOLD_SUSP"
     ;end select
    OF "SNMI95":
     SELECT
      c.display
      FROM code_value c,
       tier_matrix t
      WHERE t.tier_cell_value=c.code_value
       AND c.cdf_meaning="SNMI95"
     ;end select
    OF "GL":
     SELECT
      c.display
      FROM code_value c,
       tier_matrix t
      WHERE t.tier_cell_value=c.code_value
       AND c.cdf_meaning="GL"
     ;end select
    OF "VISITTYPE":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="VISITTYPE"
        AND t.tier_cell_type_cd=c.code_value)
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "RPT PRIORITY":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE t.tier_cell_type_cd=c.code_value
        AND c.cdf_meaning="RPT PRIORITY")
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "PAT LOC":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="PAT LOC"
        AND t.tier_cell_type_cd=c.code_value)
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "INTERFACE":
     SELECT
      i.description
      FROM interface_file i,
       code_value c,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (i
       WHERE i.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="INTERFACE"
        AND t.tier_cell_type_cd=c.code_value)
     ;end select
    OF "ADD ON":
     SELECT
      b.key6
      FROM bill_item_modifier b,
       tier_matrix t,
       code_value c
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="ADD ON")
       JOIN (b
       WHERE c.code_value=b.bill_item_type_cd
        AND t.tier_cell_value=b.key1_id
        AND b.active_ind=1
        AND t.tier_cell_value != 0)
     ;end select
    OF "CPT4":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="CPT4"
        AND t.tier_cell_type_cd=c.code_value)
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "FLAT_DISC":
     SELECT
      t.tier_cell_value
      FROM code_value c,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="FLAT_DISC"
        AND t.tier_cell_type_cd=c.code_value)
     ;end select
    OF "ORD LOC":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="ORD LOC"
        AND t.tier_cell_type_cd=c.code_value)
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
     ;end select
    OF "ICD9":
     SELECT
      c1.display
      FROM code_value c,
       code_value c1,
       tier_matrix t
      PLAN (t
       WHERE t.active_ind=1)
       JOIN (c
       WHERE c.cdf_meaning="ICD9"
        AND t.tier_cell_type_cd=c.code_value)
       JOIN (c1
       WHERE t.tier_cell_value=c1.code_value)
      HEAD REPORT
       line = fillstring(132,"=")
      HEAD PAGE
       col 15, "T I E R         M E N U           R E P O R T ", col + 1,
       col 00, option1_heading, col 18,
       option2_heading, col 35, option3_heading,
       col 52, option4_heading, col 69,
       option5_heading, col 86, option6_heading,
       col 99, option7_heading, col 110,
       option8_heading
     ;end select
   ENDCASE
 ENDFOR
 FREE SET tier
END GO

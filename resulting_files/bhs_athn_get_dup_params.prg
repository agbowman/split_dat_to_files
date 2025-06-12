CREATE PROGRAM bhs_athn_get_dup_params
 SELECT INTO  $1
  d.catalog_cd, oc.dup_checking_ind, d.dup_check_seq,
  d_exact_hit_action_disp = uar_get_code_display(d.exact_hit_action_cd), d.min_ahead,
  d_min_ahead_action_disp = uar_get_code_display(d.min_ahead_action_cd),
  d.min_behind, d_min_behind_action_disp = uar_get_code_display(d.min_behind_action_cd),
  oc_stop_type_meaning = uar_get_code_meaning(oc.stop_type_cd),
  d.outpat_flex_ind, d_outpat_exact_hit_action_disp = uar_get_code_display(d
   .outpat_exact_hit_action_cd), d.outpat_min_ahead,
  d_outpat_min_ahead_action_disp = uar_get_code_display(d.outpat_min_ahead_action_cd), d
  .outpat_min_behind, d_outpat_min_behind_action_disp = uar_get_code_display(d
   .outpat_min_behind_action_cd),
  oc.disable_order_comment_ind
  FROM dup_checking d,
   order_catalog oc
  PLAN (d
   WHERE (d.catalog_cd= $2)
    AND d.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=d.catalog_cd)
  HEAD REPORT
   xml_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, xml_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD d.catalog_cd
   col + 1, "<DuplicateParams>", row + 1,
   v1 = build("<DupOrderCheckInd>",cnvtint(oc.dup_checking_ind),"</DupOrderCheckInd>"), col + 1, v1,
   row + 1, v2 = build("<ExactHitAction>",d_exact_hit_action_disp,"</ExactHitAction>"), col + 1,
   v2, row + 1, v3 = build("<MinAhead>",cnvtint(d.min_ahead),"</MinAhead>"),
   col + 1, v3, row + 1,
   v4 = build("<MinAheadAction>",d_min_ahead_action_disp,"</MinAheadAction>"), col + 1, v4,
   row + 1, v5 = build("<MinBehind>",cnvtint(d.min_behind),"</MinBehind>"), col + 1,
   v5, row + 1, v6 = build("<MinBehindAction>",d_min_behind_action_disp,"</MinBehindAction>"),
   col + 1, v6, row + 1,
   v7 = build("<DupCheckSequence>",cnvtint(d.dup_check_seq),"</DupCheckSequence>"), col + 1, v7,
   row + 1, v8 = build("<StopTypeCd>",cnvtint(oc.stop_type_cd),"</StopTypeCd>"), col + 1,
   v8, row + 1, v9 = build("<StopTypeMeaning>",oc_stop_type_meaning,"</StopTypeMeaning>"),
   col + 1, v9, row + 1,
   v10 = build("<StopDuration>",cnvtint(oc.stop_duration),"</StopDuration>"), col + 1, v10,
   row + 1, v11 = build("<OutpatFlexIndicator>",d.outpat_flex_ind,"</OutpatFlexIndicator>"), col + 1,
   v11, row + 1, v12 = build("<OutpatExactHitAction>",d_outpat_exact_hit_action_disp,
    "</OutpatExactHitAction>"),
   col + 1, v12, row + 1,
   v13 = build("<OutpatMinAhead>",cnvtstring(d.outpat_min_ahead),"</OutpatMinAhead>"), col + 1, v13,
   row + 1, v14 = build("<OutpatMinAheadAction>",d_outpat_min_ahead_action_disp,
    "</OutpatMinAheadAction>"), col + 1,
   v14, row + 1, v15 = build("<OutpatMinBehind>",cnvtstring(d.outpat_min_behind),"</OutpatMinBehind>"
    ),
   col + 1, v15, row + 1,
   v16 = build("<OutpatMinBehindAction>",d_outpat_min_behind_action_disp,"</OutpatMinBehindAction>"),
   col + 1, v16,
   row + 1, v17 = build("<DisableOrderCommentFlag>",cnvtint(oc.disable_order_comment_ind),
    "</DisableOrderCommentFlag>"), col + 1,
   v17, row + 1, col + 1,
   "</DuplicateParams>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO

CREATE PROGRAM catalyst_audit_tables:dba
 SELECT INTO "nl:"
  *
  FROM cke_action
  WHERE 1=1
 ;end select
 SET i1 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_actionescalation_state
  WHERE 1=1
 ;end select
 SET i2 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_action_esc_action
  WHERE 1=1
 ;end select
 SET i3 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_action_esc_state
  WHERE 1=1
 ;end select
 SET i4 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_action_keyword
  WHERE 1=1
 ;end select
 SET i5 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_action_ruleinhibition
  WHERE 1=1
 ;end select
 SET i6 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_annotation
  WHERE 1=1
 ;end select
 SET i7 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_annotation_keyword
  WHERE 1=1
 ;end select
 SET i8 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_attributes
  WHERE 1=1
 ;end select
 SET i9 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_commentary
  WHERE 1=1
 ;end select
 SET i10 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_commentary_comment
  WHERE 1=1
 ;end select
 SET i11 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_dx_grammar
  WHERE 1=1
 ;end select
 SET i12 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_dx_grammar_exp
  WHERE 1=1
 ;end select
 SET i13 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_dx_relations
  WHERE 1=1
 ;end select
 SET i14 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_dx_template_answer
  WHERE 1=1
 ;end select
 SET i15 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_entity_workspace
  WHERE 1=1
 ;end select
 SET i16 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_idsequence
  WHERE 1=1
 ;end select
 SET i17 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_operand
  WHERE 1=1
 ;end select
 SET i18 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_qnaire_element
  WHERE 1=1
 ;end select
 SET i19 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_qnaire_element_item
  WHERE 1=1
 ;end select
 SET i20 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_qnaire_element_tag
  WHERE 21=1
 ;end select
 SET i21 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_querylog
  WHERE 1=1
 ;end select
 SET i22 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_question
  WHERE 1=1
 ;end select
 SET i23 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionnaire
  WHERE 1=1
 ;end select
 SET i24 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionnaire_keyword
  WHERE 1=1
 ;end select
 SET i25 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionset
  WHERE 1=1
 ;end select
 SET i26 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionset_conceptcode
  WHERE 1=1
 ;end select
 SET i27 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionset_hierarchy
  WHERE 1=1
 ;end select
 SET i28 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionset_keyword
  WHERE 1=1
 ;end select
 SET i29 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_questionset_member
  WHERE 1=1
 ;end select
 SET i30 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_question_keyword
  WHERE 1=1
 ;end select
 SET i31 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_rendering_action
  WHERE 1=1
 ;end select
 SET i32 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_rendering_response
  WHERE 1=1
 ;end select
 SET i33 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_rendering_rule
  WHERE 1=1
 ;end select
 SET i34 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_rule
  WHERE 1=1
 ;end select
 SET i35 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_ruleset
  WHERE 1=1
 ;end select
 SET i36 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_ruleset_rule
  WHERE 1=1
 ;end select
 SET i37 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_rule_action
  WHERE 1=1
 ;end select
 SET i38 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_rule_keyword
  WHERE 1=1
 ;end select
 SET i39 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_state
  WHERE 1=1
 ;end select
 SET i40 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_state_keyword
  WHERE 1=1
 ;end select
 SET i41 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_temp_state_stack
  WHERE 1=1
 ;end select
 SET i42 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_temp_state_tree
  WHERE 1=1
 ;end select
 SET i43 = curqual
 SELECT INTO "nl:"
  *
  FROM cke_timeperiod
  WHERE 1=1
 ;end select
 SET i44 = curqual
 CALL clear(1,1)
 CALL echo(build("CATALYST TABLES & number of rows on each"))
 CALL echo("--------TABLE-------------------------# ROWS-------")
 CALL echo(build("curqual CKE_ACTION                    = ",i1))
 CALL echo(build("curqual CKE_ACTIONESCALATION_STATE    = ",i2))
 CALL echo(build("curqual CKE_ACTION_ESC_ACTION         = ",i3))
 CALL echo(build("curqual CKE_ACTION_ESC_STATE          = ",i4))
 CALL echo(build("curqual CKE_ACTION_KEYWORD            = ",i5))
 CALL echo(build("curqual CKE_ACTION_RULEINHIBITION     = ",i6))
 CALL echo(build("curqual CKE_ANNOTATION                = ",i7))
 CALL echo(build("curqual CKE_ANNOTATION_KEYWORD        = ",i8))
 CALL echo(build("curqual CKE_ATTRIBUTES                = ",i9))
 CALL echo(build("curqual CKE_COMMENTARY                = ",i10))
 CALL echo(build("curqual CKE_COMMENTARY_COMMENT        = ",i11))
 CALL echo(build("curqual CKE_DX_GRAMMAR                = ",i12))
 CALL echo(build("curqual CKE_DX_GRAMMAR_EXP            = ",i13))
 CALL echo(build("curqual CKE_DX_RELATIONS              = ",i14))
 CALL echo(build("curqual CKE_DX_TEMPLATE_ANSWER        = ",i15))
 CALL echo(build("curqual CKE_ENTITY_WORKSPACE          = ",i16))
 CALL echo(build("curqual CKE_IDSEQUENCE                = ",i17))
 CALL echo(build("curqual CKE_OPERAND                   = ",i18))
 CALL echo(build("curqual CKE_QNAIRE_ELEMENT            = ",i19))
 CALL echo(build("curqual CKE_QNAIRE_ELEMENT_ITEM       = ",i20))
 CALL echo(build("curqual CKE_QNAIRE_ELEMENT_TAG        = ",i21))
 CALL echo(build("curqual CKE_QUERYLOG                  = ",i22))
 CALL echo(build("curqual CKE_QUESTION                  = ",i23))
 CALL echo(build("curqual CKE_QUESTIONNAIRE             = ",i24))
 CALL echo(build("curqual CKE_QUESTIONNAIRE_KEYWORD     = ",i25))
 CALL echo(build("curqual CKE_QUESTIONSET               = ",i26))
 CALL echo(build("curqual CKE_QUESTIONSET_CONCEPTCODE   = ",i27))
 CALL echo(build("curqual CKE_QUESTIONSET_HIERARCHY     = ",i28))
 CALL echo(build("curqual CKE_QUESTIONSET_KEYWORD       = ",i29))
 CALL echo(build("curqual CKE_QUESTIONSET_MEMBER        = ",i30))
 CALL echo(build("curqual CKE_QUESTION_KEYWORD          = ",i31))
 CALL echo(build("curqual CKE_RENDERING_ACTION          = ",i32))
 CALL echo(build("curqual CKE_RENDERING_RESPONSE        = ",i33))
 CALL echo(build("curqual CKE_RENDERING_RULE            = ",i34))
 CALL echo(build("curqual CKE_RULE                      = ",i35))
 CALL echo(build("curqual CKE_RULESET                   = ",i36))
 CALL echo(build("curqual CKE_RULESET_RULE              = ",i37))
 CALL echo(build("curqual CKE_RULE_ACTION               = ",i38))
 CALL echo(build("curqual CKE_RULE_KEYWORD              = ",i39))
 CALL echo(build("curqual CKE_STATE                     = ",i40))
 CALL echo(build("curqual CKE_STATE_KEYWORD             = ",i41))
 CALL echo(build("curqual CKE_TEMP_STATE_STACK          = ",i42))
 CALL echo(build("curqual CKE_TEMP_STATE_TREE           = ",i43))
 CALL echo(build("curqual CKE_TIMEPERIOD                = ",i44))
END GO

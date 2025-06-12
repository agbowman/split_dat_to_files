CREATE PROGRAM catalyst_delete_tables:dba
 DELETE  FROM cke_attributes
  WHERE 1=1
 ;end delete
 SET i9 = curqual
 DELETE  FROM cke_operand
  WHERE 1=1
 ;end delete
 SET i18 = curqual
 DELETE  FROM cke_qnaire_element
  WHERE 1=1
 ;end delete
 SET i19 = curqual
 DELETE  FROM cke_qnaire_element_item
  WHERE 1=1
 ;end delete
 SET i20 = curqual
 DELETE  FROM cke_qnaire_element_tag
  WHERE 21=1
 ;end delete
 SET i21 = curqual
 DELETE  FROM cke_question
  WHERE 1=1
 ;end delete
 SET i23 = curqual
 DELETE  FROM cke_questionnaire
  WHERE 1=1
 ;end delete
 SET i24 = curqual
 DELETE  FROM cke_questionnaire_keyword
  WHERE 1=1
 ;end delete
 SET i25 = curqual
 DELETE  FROM cke_questionset
  WHERE 1=1
 ;end delete
 SET i26 = curqual
 DELETE  FROM cke_questionset_keyword
  WHERE 1=1
 ;end delete
 SET i29 = curqual
 DELETE  FROM cke_questionset_member
  WHERE 1=1
 ;end delete
 SET i30 = curqual
 DELETE  FROM cke_question_keyword
  WHERE 1=1
 ;end delete
 SET i31 = curqual
 DELETE  FROM cke_rendering_action
  WHERE 1=1
 ;end delete
 SET i32 = curqual
 DELETE  FROM cke_rendering_response
  WHERE 1=1
 ;end delete
 SET i33 = curqual
 DELETE  FROM cke_rendering_rule
  WHERE 1=1
 ;end delete
 SET i34 = curqual
 DELETE  FROM cke_criterion_token
  WHERE 1=1
 ;end delete
 SET i45 = curqual
 DELETE  FROM cke_attribute_token
  WHERE 1=1
 ;end delete
 SET i46 = curqual
 DELETE  FROM cke_object_attribute
  WHERE 1=1
 ;end delete
 SET i47 = curqual
 DELETE  FROM cke_attribute_path
  WHERE attribute_path_id != 0
 ;end delete
 SET i48 = curqual
 CALL clear(1,1)
 CALL echo(build("CATALYST TABLES & number of rows deleted on each"))
 CALL echo("--------TABLE-------------------------# ROWS-------")
 CALL echo(build("curqual CKE_ATTRIBUTES                = ",i9))
 CALL echo(build("curqual CKE_OPERAND                   = ",i18))
 CALL echo(build("curqual CKE_QNAIRE_ELEMENT            = ",i19))
 CALL echo(build("curqual CKE_QNAIRE_ELEMENT_ITEM       = ",i20))
 CALL echo(build("curqual CKE_QNAIRE_ELEMENT_TAG        = ",i21))
 CALL echo(build("curqual CKE_QUESTION                  = ",i23))
 CALL echo(build("curqual CKE_QUESTIONNAIRE             = ",i24))
 CALL echo(build("curqual CKE_QUESTIONNAIRE_KEYWORD     = ",i25))
 CALL echo(build("curqual CKE_QUESTIONSET               = ",i26))
 CALL echo(build("curqual CKE_QUESTIONSET_KEYWORD       = ",i29))
 CALL echo(build("curqual CKE_QUESTIONSET_MEMBER        = ",i30))
 CALL echo(build("curqual CKE_QUESTION_KEYWORD          = ",i31))
 CALL echo(build("curqual CKE_RENDERING_ACTION          = ",i32))
 CALL echo(build("curqual CKE_RENDERING_RESPONSE        = ",i33))
 CALL echo(build("curqual CKE_RENDERING_RULE            = ",i34))
 CALL echo(build("curqual CKE_CRITERION_TOKEN           = ",i45))
 CALL echo(build("curqual CKE_ATTRIBUTE_TOKEN           = ",i46))
 CALL echo(build("curqual CKE_OBJECT_ATTRIBUTE          = ",i47))
 CALL echo(build("curqual CKE_ATTRIBUTE_PATH            = ",i48))
END GO

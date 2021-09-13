  METHOD conv_raw_to_str.

    SPLIT raw_data AT ',' INTO TABLE DATA(segments).

    DATA(lv_i) = 1.

    LOOP AT segments INTO DATA(segment).
      TRY.
          DATA(struct_descr) = CAST cl_abap_structdescr(
            cl_abap_typedescr=>describe_by_data( string_data ) ).
        CATCH cx_sy_move_cast_error.
          RETURN.
      ENDTRY.
      LOOP AT struct_descr->components FROM lv_i TO lv_i
              ASSIGNING FIELD-SYMBOL(<comp_descr>).
        ASSIGN COMPONENT <comp_descr>-name
               OF STRUCTURE string_data TO FIELD-SYMBOL(<comp>).
        IF sy-subrc EQ 0.
          <comp> = segment.
        ENDIF.
      ENDLOOP.

      ADD 1 TO lv_i.
    ENDLOOP.

  ENDMETHOD.
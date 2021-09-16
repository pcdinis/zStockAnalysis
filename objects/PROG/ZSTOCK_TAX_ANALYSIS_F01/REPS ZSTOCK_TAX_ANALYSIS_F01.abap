*----------------------------------------------------------------------*
***INCLUDE ZSTOCK_TAX_ANALYSIS_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form transform_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM transform_data .
* Take file data and transform to stock transaction structure
  LOOP AT gt_file_data INTO gs_file_data.
*   Ignore header row
    CHECK sy-tabix NE 1.
    CONCATENATE gs_file_data-trdate+6(4) gs_file_data-trdate+3(2) gs_file_data-trdate(2) INTO gs_stock_transactions-trdate.
    CONCATENATE gs_file_data-trhour(2) gs_file_data-trhour+3(2) '00' INTO gs_stock_transactions-trhour.
    MOVE gs_file_data-product TO gs_stock_transactions-product.
    MOVE gs_file_data-isin TO gs_stock_transactions-isin.
    MOVE gs_file_data-xchange TO gs_stock_transactions-xchange.
    MOVE gs_file_data-xchange2 TO gs_stock_transactions-xchange2.
    MOVE gs_file_data-quantity TO gs_stock_transactions-quantity.
    MOVE gs_file_data-price TO gs_stock_transactions-price.
    MOVE gs_file_data-curr TO gs_stock_transactions-curr.
    MOVE gs_file_data-tax_exchange TO gs_stock_transactions-tax_exchange.
    MOVE gs_file_data-trans_costs_value TO gs_stock_transactions-trans_costs_value.
    MOVE gs_file_data-trans_costs_curr TO gs_stock_transactions-trans_costs_curr.
    MOVE gs_file_data-total_price TO gs_stock_transactions-total_price.
    MOVE gs_file_data-total_curr TO gs_stock_transactions-total_curr.
    MOVE gs_file_data-order_id TO gs_stock_transactions-order_id.
    gs_stock_transactions-quantity_balance = 0.

    APPEND gs_stock_transactions TO gt_stock_transactions.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form aggregation_by_year
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM aggregation_by_year .
* If Aggregation is selected than show the total values by YEAR
  IF p_agg EQ abap_true.
    DATA: lt_stock_data LIKE gt_stock_data.
    DATA: ls_stock_data LIKE gs_stock_data.
    DATA: lv_year       TYPE gjahr.
    REFRESH lt_stock_data.
    CLEAR ls_stock_data.
    CLEAR lv_year.
    LOOP AT gt_stock_data ASSIGNING FIELD-SYMBOL(<fs_stock_data>).
      IF lv_year NE <fs_stock_data>-tryear.
        ls_stock_data-tryear = <fs_stock_data>-tryear.
        ls_stock_data-cap_gains_value = <fs_stock_data>-cap_gains_value.
        ls_stock_data-cap_gains_curr = <fs_stock_data>-cap_gains_curr.
        ls_stock_data-tax_value = <fs_stock_data>-cap_gains_value * 28 / 100.
        ls_stock_data-tax_curr = <fs_stock_data>-cap_gains_curr.
        APPEND ls_stock_data TO lt_stock_data.
      ELSE.
        ls_stock_data-cap_gains_value = ls_stock_data-cap_gains_value + <fs_stock_data>-cap_gains_value.
        ls_stock_data-tax_value = ls_stock_data-tax_value + ( <fs_stock_data>-cap_gains_value * 28 / 100 ).
        MODIFY TABLE lt_stock_data
       FROM VALUE #( BASE ls_stock_data tryear = lv_year ).
      ENDIF.
      lv_year = <fs_stock_data>-tryear.
    ENDLOOP.
    REFRESH gt_stock_data.
    gt_stock_data[] = lt_stock_data[].
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form show_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM show_data .
* Show data
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = gr_salv
        CHANGING
          t_table      = gt_stock_data.
      ##NO_HANDLER.
    CATCH cx_salv_msg .
  ENDTRY.

  gr_functions = gr_salv->get_functions( ).
  gr_functions->set_all( abap_true ).

  CALL METHOD gr_salv->display.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form upload_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM upload_file .
* Upload file
  zcl_stock_utils=>upload_file(
    EXPORTING
      filename   = gv_file
    IMPORTING
      data_table = gt_datatab ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form convert_raw_to_str
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM convert_raw_to_str .
* Convert filetable rawstring to a specific table
  LOOP AT gt_datatab INTO DATA(ls_datatab).
    zcl_stock_utils=>conv_raw_to_str(
      EXPORTING
        raw_data    = ls_datatab
      IMPORTING
        string_data = gs_file_data ).

    APPEND gs_file_data TO gt_file_data.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form do_tax_calculation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM do_tax_calculation .
* Do the maths
  CALL METHOD zcl_stock_analysis=>do_tax_calculation(
    EXPORTING
      iv_isin               = p_isin
      it_stock_transactions = gt_stock_transactions
    IMPORTING
      et_stock_tax_data     = gt_stock_data ).
ENDFORM.
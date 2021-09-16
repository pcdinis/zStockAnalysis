  METHOD do_tax_calculation.
    DATA: ls_sell_movemts    TYPE zstock_transactions.
    DATA: lt_sell_movemts    TYPE ztt_stock_transactions.
    DATA: ls_buy_movemts     TYPE zstock_transactions.
    DATA: lt_buy_movemts     TYPE ztt_stock_transactions.
    DATA: ls_res_movemts     TYPE zstock_tax_data.
    DATA: lt_res_movemts     TYPE ztt_stock_tax_data.
    DATA: lv_unit_sell_value TYPE p DECIMALS 4.
    DATA: lv_unit_buy_value  TYPE p DECIMALS 4.

    REFRESH: lt_sell_movemts.
    REFRESH: lt_buy_movemts.
    CLEAR: ls_sell_movemts.
    CLEAR: ls_buy_movemts.

*   Split SELL and BUY data
    LOOP AT it_stock_transactions ASSIGNING FIELD-SYMBOL(<fs_stock_transactions>).
*     Check if it's a SELL MOVEMENT
      IF <fs_stock_transactions>-quantity LT 0.
        MOVE-CORRESPONDING <fs_stock_transactions> TO ls_sell_movemts.
        ls_sell_movemts-quantity = ls_sell_movemts-quantity * ( -1 ).
*       Update QUANTITY BALANCE!!! This is the value to DECREASE
        MOVE ls_sell_movemts-quantity TO ls_sell_movemts-quantity_balance.
        APPEND ls_sell_movemts TO lt_sell_movemts.
*     Check if it's a BUY MOVEMENT
      ELSEIF <fs_stock_transactions>-quantity GE 0.
        MOVE-CORRESPONDING <fs_stock_transactions> TO ls_buy_movemts.
*       Update QUANTITY BALANCE!!!
        MOVE ls_buy_movemts-quantity TO ls_buy_movemts-quantity_balance.
        ls_buy_movemts-price = ls_buy_movemts-price * ( -1 ).
        "ls_buy_movemts-total_price = ls_buy_movemts-total_price * ( -1 ).
        APPEND ls_buy_movemts TO lt_buy_movemts.
      ENDIF.
    ENDLOOP.

*   Filter ISIN if it's filled
    IF iv_isin IS NOT INITIAL.
      DELETE lt_sell_movemts WHERE isin NE iv_isin.
      DELETE lt_buy_movemts WHERE isin NE iv_isin.
    ENDIF.

*   Sort by transaction date/hour
    SORT lt_sell_movemts BY trdate trhour.
    SORT lt_buy_movemts  BY trdate trhour.

*   Iterate SELL movements
    LOOP AT lt_sell_movemts ASSIGNING FIELD-SYMBOL(<fs_sell_movemts>).
*     Find BUY movements to SUBTRACT quantity and calculate
      LOOP AT lt_buy_movemts ASSIGNING FIELD-SYMBOL(<fs_buy_movemts>) WHERE isin EQ <fs_sell_movemts>-isin
                                                                        AND quantity_balance GT 0.
*       Only iterates BUYing rows until QUANTITY_BALANCE greater than 0!
        CHECK <fs_sell_movemts>-quantity_balance GT 0.
*       Init variables
        CLEAR ls_res_movemts.
        CLEAR lv_unit_buy_value.
        CLEAR lv_unit_sell_value.
*       Get common data!!
        ls_res_movemts-trmonth = <fs_sell_movemts>-trdate+4(2).
        ls_res_movemts-tryear  = <fs_sell_movemts>-trdate(4).
        ls_res_movemts-trhour  = <fs_sell_movemts>-trhour.
        ls_res_movemts-isin    = <fs_sell_movemts>-isin.
        ls_res_movemts-product = <fs_sell_movemts>-product.

*       Start to SUBTRACT QUANTITY
*       Check if the SELL quantity is higher than the BUYing transaction
        IF <fs_sell_movemts>-quantity_balance GT <fs_buy_movemts>-quantity_balance.

          ls_res_movemts-sell_quantity   = <fs_buy_movemts>-quantity_balance.
*         Get unit value from the SELLING movement
          "lv_unit_sell_value             = <fs_sell_movemts>-total_price / <fs_sell_movemts>-quantity.
          lv_unit_sell_value             = <fs_sell_movemts>-price / <fs_sell_movemts>-quantity.
          ls_res_movemts-sell_value      = lv_unit_sell_value * <fs_buy_movemts>-quantity_balance.
          "ls_res_movemts-sell_curr       = <fs_sell_movemts>-total_curr.
          ls_res_movemts-sell_curr       = <fs_sell_movemts>-curr.

          ls_res_movemts-buy_quantity    = <fs_buy_movemts>-quantity_balance.
*         Get unit value from the BUYING movement
          "lv_unit_buy_value              = <fs_buy_movemts>-total_price / <fs_buy_movemts>-quantity.
          lv_unit_buy_value              = <fs_buy_movemts>-price / <fs_buy_movemts>-quantity.
          ls_res_movemts-buy_value       = lv_unit_buy_value * <fs_buy_movemts>-quantity_balance.
          "ls_res_movemts-buy_curr        = <fs_buy_movemts>-total_curr.
          ls_res_movemts-buy_curr        = <fs_buy_movemts>-curr.

*         Remove BUY QUANTITY BALANCE from SELL row
          SUBTRACT <fs_buy_movemts>-quantity_balance FROM <fs_sell_movemts>-quantity_balance.
*         Remove all the BUY quantity balance
          <fs_buy_movemts>-quantity_balance = 0.

        ELSE.

          ls_res_movemts-sell_quantity   = <fs_sell_movemts>-quantity_balance.
*         Get unit value from the SELLING movement
          "lv_unit_sell_value             = <fs_sell_movemts>-total_price / <fs_sell_movemts>-quantity.
          lv_unit_sell_value             = <fs_sell_movemts>-price / <fs_sell_movemts>-quantity.
          ls_res_movemts-sell_value      = lv_unit_sell_value * <fs_sell_movemts>-quantity_balance.
          "ls_res_movemts-sell_curr       = <fs_sell_movemts>-total_curr.
          ls_res_movemts-sell_curr       = <fs_sell_movemts>-curr.

          ls_res_movemts-buy_quantity    = <fs_sell_movemts>-quantity_balance.
*         Get unit value from the BUYING movement
          "lv_unit_buy_value              = <fs_buy_movemts>-total_price / <fs_buy_movemts>-quantity.
          lv_unit_buy_value              = <fs_buy_movemts>-price / <fs_buy_movemts>-quantity.
          ls_res_movemts-buy_value       = lv_unit_buy_value * <fs_sell_movemts>-quantity_balance. "<fs_buy_movemts>-total_price.
          "ls_res_movemts-buy_curr        = <fs_buy_movemts>-total_curr.
          ls_res_movemts-buy_curr        = <fs_buy_movemts>-curr.

*         Remove SELL quantity balance from BUYING movement
          SUBTRACT <fs_sell_movemts>-quantity_balance FROM <fs_buy_movemts>-quantity_balance.
*         Remove all the SELL quantity balance
          <fs_sell_movemts>-quantity_balance = 0.

        ENDIF.

        ls_res_movemts-cap_gains_value = ls_res_movemts-sell_value - ls_res_movemts-buy_value.
        ls_res_movemts-cap_gains_curr  = <fs_buy_movemts>-total_curr.

        ls_res_movemts-tax_value = ls_res_movemts-cap_gains_value * 28 / 100.
        "ls_res_movemts-tax_curr  = <fs_buy_movemts>-total_curr.
        ls_res_movemts-tax_curr  = <fs_buy_movemts>-curr.
        APPEND ls_res_movemts TO et_stock_tax_data.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.
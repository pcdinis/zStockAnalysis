  METHOD do_tax_calculation.
    DATA: ls_sell_movemts TYPE zSTOCK_TRANSACTIONS.
    DATA: lt_sell_movemts TYPE ztt_stock_transactions.
    DATA: ls_buy_movemts TYPE zSTOCK_TRANSACTIONS.
    DATA: lt_buy_movemts TYPE ztt_stock_transactions.

    REFRESH: lt_sell_movemts.
    REFRESH: lt_buy_movemts.
    CLEAR: ls_sell_movemts.
    CLEAR: ls_buy_movemts.

*   Split SELL and BUY data
    LOOP AT it_stock_transactions ASSIGNING FIELD-SYMBOL(<fs_stock_transactions>).
*     Check if it's a SELL MOVEMENT
      IF <fs_stock_transactions>-total_price LT 0.
        MOVE-CORRESPONDING <fs_stock_transactions> TO ls_sell_movemts.
        APPEND ls_sell_movemts TO lt_sell_movemts.
*     Check if it's a BUY MOVEMENT
      ELSEIF <fs_stock_transactions>-total_price GE 0.
        MOVE-CORRESPONDING <fs_stock_transactions> TO ls_buy_movemts.
        APPEND ls_buy_movemts TO lt_buy_movemts.
      ENDIF.
    ENDLOOP.

*   Sort by transaction date/hour

  ENDMETHOD.
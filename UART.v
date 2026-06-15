/*
EVIDENCIA 2: PARTE 1 ---> IMPLEMENTACION DE UART EN VERILOG
Módulo UART

Javier Oswaldo Pérez Trevizo | A01241493
Celeste Anahí Nuñez Gallarza | A01241637
Monserrat Vargas Rodriguez   | A01242043
*/

module UART(
    input        clk,
    input        rst,
    // Por el lado del transmisor TX
    input        wr_enb,
    input  [7:0] data_in,
    output       tx,
    output       tx_busy,
    // Por el lado del receptor RX
    input        rx,
    input        rdy_cr,
    output [7:0] data_out,
    output       rdy
);
    // Señales internas del baud rate generator
    wire tx_enb;
    wire rx_enb;

    // Instancia de puertos del generador de baud rate
    baud_rate_generator brg (
        .clk    (clk),
        .rst    (rst),
        .tx_enb (tx_enb),
        .rx_enb (rx_enb)
    );

    // Instancia de puertos del transmisor
    transmitter uart_tx (
        .clk     (clk),
        .rst     (rst),
        .tx_enb  (tx_enb),
        .wr_enb  (wr_enb),
        .data_in (data_in),
        .tx      (tx),
        .busy    (tx_busy)
    );

    // Instancia de puertos del receptor
    reciever uart_rx (
        .clk      (clk),
        .rst      (rst),
        .rx       (rx),
        .rdy_cr   (rdy_cr),
        .clk_enb  (rx_enb),    // RX usa el enable de 16x oversampling
        .data_out (data_out),
        .rdy      (rdy)
    );

endmodule
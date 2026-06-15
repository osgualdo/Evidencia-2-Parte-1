/*
EVIDENCIA 2: PARTE 1 ---> IMPLEMENTACION DE UART EN VERILOG
Módulo generador de baud rate

Javier Oswaldo Pérez Trevizo | A01241493
Celeste Anahí Nuñez Gallarza | A01241637
Monserrat Vargas Rodriguez   | A01242043
*/


module baud_rate_generator(
    input  clk,
    input  rst,
    output tx_enb, // Habilita la maquina de estados del transmisor
    output rx_enb // Habilita la maquina de estados del receptor
);
    reg [12:0] tx_counter; // 13 bits
    reg [9:0]  rx_counter; // 10 bits

    // TX: baud rate normal (ej. 9600 baud @ 50MHz, divisor 5208)
    always @(posedge clk) begin
        if (rst || tx_counter == 5208)
            tx_counter <= 13'h0;
        else
            tx_counter <= tx_counter + 1'b1;
    end

    // RX: muestrea 16x más rápido que TX
    always @(posedge clk) begin
        if (rst || rx_counter == 325)
            rx_counter <= 10'h0;
        else
            rx_counter <= rx_counter + 1'b1;
    end

    assign tx_enb = (tx_counter == 0) ? 1'b1 : 1'b0; // Habilitador de transmisor es 1 si el contador tx es 0, de lo contrario, manda 0
    assign rx_enb = (rx_counter == 0) ? 1'b1 : 1'b0; // Habilitador de receptor es 1 si el contador rx es 0, de lo contrario, manda 0

endmodule
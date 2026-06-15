/*
EVIDENCIA 2: PARTE 1 ---> IMPLEMENTACION DE UART EN VERILOG
Módulo transmisor

Javier Oswaldo Pérez Trevizo | A01241493
Celeste Anahí Nuñez Gallarza | A01241637
Monserrat Vargas Rodriguez   | A01242043
*/


module transmitter(
    input        clk, rst, tx_enb, wr_enb, // recibe como entradas salidas del baud rate generator y del modulo principal UART
    input  [7:0] data_in, // Datos de entrada
    output reg   tx,
    output       busy
);
    parameter IDLE_STATE  = 2'b00;
    parameter START_STATE = 2'b01;
    parameter DATA_STATE  = 2'b10;
    parameter STOP_STATE  = 2'b11;

    reg [7:0] data; // 8 bits de datos
    reg [2:0] index;
    reg [1:0] state = IDLE_STATE;

    always @(posedge clk) begin
        if (rst) begin          // Condociones a cumplir cuando se active el reset
            tx    <= 1'b1;
            state <= IDLE_STATE;
            index <= 3'h0;
            data  <= 8'h00;
        end
    end
    // FSM de transmisor
    always @(posedge clk) begin
        if (!rst) begin
            case(state)
                IDLE_STATE: begin
                    tx <= 1'b1;
                    if (wr_enb) begin
                        data  <= data_in;
                        state <= START_STATE;
                        index <= 3'h0;
                    end
                end
                START_STATE: begin
                    if (tx_enb) begin   
                        tx    <= 1'b0;
                        state <= DATA_STATE;
                    end
                end
                DATA_STATE: begin
                    if (tx_enb) begin
                        tx    <= data[index];
                        if (index == 3'h7)
                            state <= STOP_STATE;
                        else
                            index <= index + 1'b1;
                    end
                end
                STOP_STATE: begin
                    if (tx_enb) begin
                        tx    <= 1'b1;
                        state <= IDLE_STATE;
                    end
                end
                default: begin
                    tx    <= 1'b1;
                    state <= IDLE_STATE;
                end
            endcase
        end
    end

    assign busy = (state != IDLE_STATE); // Señal de estado ocupado cuando el estado sea diferente al estado de espera, 
                                            // es decir, cuando se estén transmitiendo datos

endmodule
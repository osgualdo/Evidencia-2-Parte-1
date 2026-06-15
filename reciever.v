/*
EVIDENCIA 2: PARTE 1 ---> IMPLEMENTACION DE UART EN VERILOG
Módulo receptor

Javier Oswaldo Pérez Trevizo | A01241493
Celeste Anahí Nuñez Gallarza | A01241637
Monserrat Vargas Rodriguez   | A01242043
*/


module reciever(
    input            clk, rst, rx, rdy_cr, clk_enb,
    output reg [7:0] data_out,
    output reg       rdy
);
    parameter START_STATE = 2'b00;
    parameter DATA_OUT    = 2'b01;
    parameter STOP_STATE  = 2'b10;

    reg [1:0] state = START_STATE;
    reg [3:0] sample = 0;
    reg [3:0] index  = 0;
    reg [7:0] temp_register = 8'h00;

    always @(posedge clk) begin
        if (rst) begin
            rdy      <= 0;
            data_out <= 0;  
            state    <= START_STATE;
            sample   <= 0;
            index    <= 0;
        end else begin
            if (rdy_cr) rdy <= 0;

            if (clk_enb)
                case(state)    
                    START_STATE: begin
                        // Detecta flanco de inicio en rx
                        if (rx == 0)
                            sample <= sample + 1'b1;
                        else
                            sample <= 0;

                        if (sample == 7) begin   // centro del start bit
                            state   <= DATA_OUT;
                            sample  <= 0;
                            index   <= 0;
                            temp_register <= 8'h00;
                        end
                    end

                    DATA_OUT: begin
                        sample <= sample + 1'b1;
                        if (sample == 4'h8)
                            temp_register[index] <= rx;
                        if (sample == 15) begin
                            sample <= 0;
                            if (index == 7)         
                                state <= STOP_STATE;
                            else
                                index <= index + 1'b1;
                        end
                    end

                    STOP_STATE: begin
                        if (sample == 15) begin
                            state    <= START_STATE;
                            rdy      <= 1'b1;
                            data_out <= temp_register;
                            sample   <= 0;
                        end else
                            sample <= sample + 1'b1;
                    end

                    default: state <= START_STATE;  
                endcase
        end
    end

endmodule
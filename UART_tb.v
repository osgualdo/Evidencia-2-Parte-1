/*
EVIDENCIA 2: PARTE 1 ---> IMPLEMENTACION DE UART EN VERILOG
Módulo testbench de UART

Javier Oswaldo Pérez Trevizo | A01241493
Celeste Anahí Nuñez Gallarza | A01241637
Monserrat Vargas Rodriguez   | A01242043
*/



/*  Archivos requeridos para compilar:
    iverilog -o uart_sim UART_tb.v baud_rate_generator.v transmitter.v reciever.v UART.v
*/
`timescale 1ns / 1ps // escala de tiempo

module UART_tb;

    // Señales del DUT
    reg        clk;
    reg        rst;

    // TX 
    reg        wr_enb;
    reg  [7:0] data_in;
    wire       tx;
    wire       tx_busy;

    // RX 
    wire [7:0] data_out;
    wire       rdy;
    reg        rdy_cr;

    // Instancias de puertos del modulo
    UART DUT (
        .clk      (clk),
        .rst      (rst),
        .wr_enb   (wr_enb),
        .data_in  (data_in),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .rx       (tx),       // Loopback: TX conectado directo a RX
        .rdy_cr   (rdy_cr),
        .data_out (data_out),
        .rdy      (rdy)
    );

    // Reloj: 50 MHz → periodo 20 ns
    initial clk = 0;
    always #10 clk = ~clk;

    // Tarea a realizar: transmitir un byte y esperar que llegue al RX
    task send_byte;
        input [7:0] byte_to_send;
        begin
            // Esperar a que el transmisor esté libre
            wait (!tx_busy);
            @(posedge clk);

            // Cargar dato y habilitar escritura por 1 ciclo
            data_in = byte_to_send;
            wr_enb  = 1'b1;
            @(posedge clk);
            wr_enb  = 1'b0;

            $display("[%0t ns] TX enviando: 0x%02X ('%0s')",
                     $time, byte_to_send, byte_to_send);

            // Esperar a que el receptor señale dato listo
            wait (rdy == 1'b1);
            @(posedge clk);

            // Verificar dato recibido
            if (data_out === byte_to_send)
                $display("[%0t ns] RX OK  --> recibido: 0x%02X ok", $time, data_out);
            else
                $display("[%0t ns] RX ERROR --> esperado: 0x%02X  recibido: 0x%02X no",
                         $time, byte_to_send, data_out);

            // Limpiar flag rdy
            rdy_cr = 1'b1;
            @(posedge clk);
            rdy_cr = 1'b0;
            @(posedge clk);
        end
    endtask

    // Secuencia principal de las pruebas
    initial begin
        // Volcado de señales en dump file para GTKWave
        $dumpfile("uart_dump.vcd");
        $dumpvars(0, UART_tb);

        // Condiciones iniciales
        rst     = 1'b1;
        wr_enb  = 1'b0;
        rdy_cr  = 1'b0;
        data_in = 8'h00;

        // Reset durante 5 ciclos
        repeat(5) @(posedge clk);
        rst = 1'b0;
        repeat(2) @(posedge clk);

        $display(" ");
        $display("Inicio de pruebas");
        $display(" ");

        //Prueba 1: byte simple
        send_byte(8'h41);   // 'A'

        //Prueba 2: otro carácter
        send_byte(8'h55);   // 'U'

        //Prueba 3: valor 0x00 (caso borde)
        send_byte(8'h00);

        // Prueba 4: valor 0xFF (todos en 1)
        send_byte(8'hFF);

        // Prueba 5: para un byte aleatorio
        send_byte(8'hA5);

        $display(" ");
        $display("Fin de pruebas");
        $display(" ");

        // Se espera un tiempo pequeño antes de finalizar la simulación
        repeat(20) @(posedge clk);
        $finish;
    end

    // Se establece el monitor de Timeout a 50 ms para evitar que la simulacion continúe de manera 
    // infinita en caso de que se tenga algún error.
    initial begin
        #50_000_000;  // 50 ms máximo
        $display("TIMEOUT");
        $finish;
    end

endmodule

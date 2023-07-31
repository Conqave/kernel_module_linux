`timescale 1ns/1ps

module gpioemu_tb;

    reg n_reset = 1;
    reg [15:0] saddress = 0;
    reg srd = 0;
    reg swr = 0;
    reg [31:0] sdata_in = 0;
    wire [31:0] sdata_out = 0;
    reg [31:0] gpio_in = 0;
    reg gpio_latch = 0;
    wire [31:0] gpio_out = 0;
    reg clk = 0;
    wire [31:0] gpio_in_s_insp = 0;
    wire [31:0] sdata_out_s = 0;




    integer i;

    initial begin
		$dumpfile("gpioemu.vcd");
		$dumpvars(0, gpioemu_tb);
		clk = 0;
	end


    always #1 clk <= ~clk;


    // Reset
    initial begin
        n_reset = 0;
        n_reset = 1;
    end

    initial begin


        // Sprawdzenie: 2 * 7 = 14

        #5 sdata_in = 24'h2;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'h7;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Oczekiwany wynik W: E
        #5 srd = 1;
        #5 srd = 0;

	// Sprawdzenie: 7 * 2 = 14

        #5 sdata_in = 24'h7;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'h2;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Oczekiwany wynik W: E
        #5 srd = 1;
        #5 srd = 0;


        // Sprawdzenie: 0 * 8 = 0


        #5 sdata_in = 24'h0;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'h8;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Oczekiwany wynik W: 0
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h120; // Oczekiwany wynik L: 0
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h128; // Oczekiwany wynik B: 0
        #5 srd = 1;
        #5 srd = 0;



        // Sprawdzenie: 5 * 4 = 20


        #5 sdata_in = 24'h5;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'h4;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Oczekiwany wynik W: 14
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h120; // Oczekiwany wynik L: 0
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h128; // Oczekiwany wynik B: 0
        #5 srd = 1;
        #5 srd = 0;




        // Sprawdzenie: 1 * 1 = 1


        #5 sdata_in = 24'h1;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'h1;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Oczekiwany wynik W: 1
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h120; // Oczekiwany wynik L: 0
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h128; // Oczekiwany wynik B: 0
        #5 srd = 1;
        #5 srd = 0;



        // Sprawdzenie: 237 * 250 = 59 250


        #5 sdata_in = 24'hED;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'hFA;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Oczekiwany wynik W: E772
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h120; // Oczekiwany wynik L: 0
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h128; // Oczekiwany wynik B: 0
        #5 srd = 1;
        #5 srd = 0;


        // Sprawdzenie przepełnienia


        #5 sdata_in = 24'hFFFFFF;
        #5 saddress = 16'h108;
        #5 swr = 1;
        #5 swr = 0;

        #5 sdata_in = 24'hFFFFFF;
        #5 saddress = 16'h110;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h118; // Wynik W
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h120; // Oczekiwany wynik L: 0
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h128; // Oczekiwany wynik B: 0
        #5 srd = 1;
        #5 srd = 0;


        # 3000 $finish;
    end

    gpioemu e1(n_reset, saddress, srd, swr, sdata_in, sdata_out, gpio_in, gpio_latch, gpio_out, clk, gpio_in_s_insp);


endmodule
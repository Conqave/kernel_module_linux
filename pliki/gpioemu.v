/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off COMBDLY */
/* verilator lint_off WIDTH */
/* verilator lint_off BLKSEQ */
/* verilator lint_off BLKANDNBLK */
/* verilator lint_off CASEINCOMPLETE */

module gpioemu(n_reset,             // magistrala CPU
    saddress[15:0], srd, swr,       // wektor 16 bitowy reprezentujący adresy
    sdata_in[31:0], sdata_out[31:0], //dane wejściowe
    gpio_in[31:0], gpio_latch,      // styk GPIO - wejscia
    gpio_out[31:0],                 // styk GPIO = wyjscia
    clk,                            // zegar 1kHz
    gpio_in_s_insp[31:0]);          // sygnały testowe, inspekcyjne


    
	input 				clk;
	input 				n_reset;

	input  [15:0] 		saddress;
	input 				srd;
	input 				swr;
	input  [31:0] 		sdata_in;
    output [31:0] 		sdata_out;
    reg    [31:0]       sdata_out_s;

	input  [31:0] 		gpio_in;
    reg    [31:0]       gpio_in_s;
	input				gpio_latch;
    output [31:0]       gpio_in_s_insp;
	
	output [31:0] 		gpio_out;
    reg    [31:0]       gpio_out_s;

    reg  [23:0]       A1;  // Pierwsza liczba - 24 bity
    reg  [23:0]       A2;  // Druga liczba - 24 bity
    reg  [31:0]       W;   // Wynik mnozenia - 32 bity
    reg  [31:0]       L;   // Liczba jedynek, ktore wystapily w wyniku
    reg  [1:0]       B;   // Stan operacji: czy zakończona - 1, czy poprawna - 0, czy przepelnienie - 2;

	reg	 [47:0]		  temp; // Zmienna tymczasowa potrzebna do wykonania mnozenia - 24 bity * 2 = 48 bitow

	integer mul_i = 0; // Zmienna całkowitoliczbowa potrzebna w działaniu mnożenia
	integer ones_i = 0; // Zmienna całkowitoliczbowa potrzebna w działaniu zliczania jedynek



    always @(posedge gpio_latch) // Przypisanie po wykryciu narastajacego zbocza gpio_latch, gpio_in do rejestru gpio_in_s
	    begin
		    gpio_in_s <= gpio_in;
	    end

    always @(negedge n_reset) // Wyzerowanie zmiennych, po wykryciu sygnału resetu
	    begin
		    sdata_out_s <= 0;
		    gpio_out_s <= 0;
            A1 <= 0;
            A2 <= 0;
		    W <= 0;
		    L <= 0;
		    B <= 16'h0; 
		    mul_i <= 0;
		    ones_i <= 0;
		    temp <= 0;
	    end



    always @(posedge swr) // Blok odpowiedzialny za odczyt danych wejściowych, czyli liczb, jesli zostana odczytane, nastepuje zmiana flagi B
        begin
            if (B == 0) begin
                case(saddress)
                    16'h108: begin
                        A1 <= sdata_in;
                        W <= 0;
                        L <= 0;
                        B <= 0;
                    end
                    16'h110: begin
                        A2 <= sdata_in;
                        B <= 16'h1;
                    end
                endcase
            end
        end



    always @(posedge srd) // Blok odpowiedzialny za przekazanie danych wyjściowych
		begin
            case(saddress)                     
                16'h108: sdata_out_s <= A1;
                16'h110: sdata_out_s <= A2;
                16'h118: sdata_out_s <= W;
                16'h120: sdata_out_s <= L;
                16'h128: sdata_out_s <= B;
                default: sdata_out_s <= 0;
            endcase
		end



    always @(posedge clk) begin
        if (B == 1) begin
            temp <= 0;

            // Petla mnozy liczby metoda bit po bicie
            for (mul_i = 0; mul_i < 23; mul_i = mul_i + 1) begin
                if(A2[mul_i] == 1)
                begin
                    temp = temp + (A1<<mul_i);
                end
            end

            // Petla zlicza jedynki, jesli wystapila jedynka, nastepuje dodanie jej do wyniku
            for (ones_i = 0; ones_i < 47; ones_i = ones_i + 1) begin
                L = L + (temp[ones_i] == 1);
            end
            
            // Sprawdzenie czy nieprzepełnione, jeśli nie - koniec działań, ustawioenie flagi B na 0
            if (temp < 2**32) begin
                
                W <= temp;
                B <= 16'h0;
            end

            // Jeśli przepełnione, ustawienie flagi B na 2
            else begin                

                 B <= 16'h2;

                A1 <= 0;
                A2 <= 0;
                W <= temp[47:16];
            end
            gpio_out_s <= gpio_out_s + 1;

            mul_i <= 0;
            ones_i <= 0;
        end
    end


    assign gpio_out = gpio_out_s[15:0];
	assign sdata_out = sdata_out_s;
	assign gpio_in_s_insp = gpio_in_s;



endmodule
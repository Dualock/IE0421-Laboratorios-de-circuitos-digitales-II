// cache de 1kB/8 bytes por bloque = 128 bloques
`define ADDR 16
`define TOPOFMEM 4'hFFFF
// cache state machine states
`define RESET       3'b111
`define IDLE        3'b000
`define LOOKUP      3'b001
`define ALLOCATE    3'b010
`define WRITE_BACK  3'b011
`define UNCACHEABLE 3'b100

`define WRITE_WORD 3'b001
`define READ_WORD  3'b001




module cache_2_way_random #(
	// parametros del modulo
	
	// Seccion 1
	
	parameter CACHETOTALSIZE = 1024,
	parameter WAYS = 2,
	parameter WORDS = 2
	
	
	// Seccion 2.1
	/*
	parameter CACHETOTALSIZE = 2048,
	parameter WAYS = 2,
	parameter WORDS = 2
	*/
	
	// Seccion 2.2
	/*
	parameter CACHETOTALSIZE = 2048,
	parameter WAYS = 2,
	parameter WORDS = 4
	*/
	
	// Seccion 2.3
	/*
	parameter CACHETOTALSIZE = 4096,
	parameter WAYS = 2,
	parameter WORDS = 2
	*/
	// Seccion 2.4
	/*
	parameter CACHETOTALSIZE = 4096,
	parameter WAYS = 2,
	parameter WORDS = 4
	*/
) (
    input               clk,
    input               resetn,
    // interfaz al procesador
    input               core_mem_valid,
    input               core_mem_instr,
    input       [31:0]  core_mem_addr,
    input       [31:0]  core_mem_wdata,
    input        [3:0]  core_mem_wstrb,
    output  reg         core_mem_ready,
    output  reg [31:0]  core_mem_rdata,

    // interfaz al controlador de memoria
    output  reg         mem_valid,
    output  reg         mem_instr,
    output  reg [31:0]  mem_addr,
    output  reg [31:0]  mem_wdata,
    output  reg  [3:0]  mem_wstrb,
    input               mem_ready,
    input       [31:0]  mem_rdata
);
    reg [2:0] state, next_state;
    reg [2:0] read_state, read_next_state;
    reg [2:0] write_state, write_next_state;
    reg [31:0] hit_counter, miss_counter;
    reg [31:0] memTransaction_counter, ioTransaction_counter;
    parameter ADDRSIZE = 32;
    parameter BLOCKSIZE = ADDRSIZE*WORDS; // tamaño de bloque en bits
    parameter BLOCKBYTES = BLOCKSIZE/8; // tamaño de bloque en bytes
    parameter CACHESIZE = CACHETOTALSIZE/(WAYS*BLOCKBYTES); //tamaño de arreglo de lineas de cache
    parameter OFFSET = $clog2(BLOCKBYTES);
    parameter INDEX = $clog2(CACHESIZE);
    parameter TAG = ADDRSIZE-INDEX-OFFSET;
    parameter WAY_BIT_SEL = $clog2(WAYS); //cantidad de bits necesarios para seleccionar el way

    wire [INDEX-1:0]    core_index;
    wire [OFFSET-1:0]   core_offset;
    wire [TAG-1:0]      core_tag;

    assign core_offset = core_mem_addr[OFFSET-1:0];
    assign core_index = core_mem_addr[INDEX+OFFSET-1:OFFSET];
    assign core_tag = core_mem_addr[TAG+INDEX+OFFSET-1:INDEX+OFFSET];

    // arreglos de la cache
    reg [BLOCKSIZE-1:0]    data [WAY_BIT_SEL:0] [0:CACHESIZE-1];
    reg [TAG-1:0]          tag [WAY_BIT_SEL:0] [0:CACHESIZE-1];
    reg                     valid [WAY_BIT_SEL:0] [0:CACHESIZE-1];
    reg                     dirty[WAY_BIT_SEL:0] [0:CACHESIZE-1];
    
    // registros del controlador
    reg               reset_done;
    reg  [INDEX-1:0] reset_cnt;
    wire [INDEX-1:0] next_reset_cnt;

    assign next_reset_cnt = reset_cnt +1;

    wire highmem;
    assign highmem = |core_mem_addr[31:16];

    reg [1:0] complete_all;
    wire wcomplete_all;
    reg read_block;
    reg write_block;
    reg [3:0] words;
    wire complete;
    assign complete = ~|(words-WORDS);
    wire [3:0] wnext_word;
    assign wnext_word = words + 1;
    reg [31:0]  current_address;
    wire [31:0]  wnext_address;
    assign wnext_address = current_address + 4;
    assign wcomplete_all = &complete_all;
    // Esta logica de matching solo sirve para 2 ways
    wire [1:0] validhit, match_way0, match_way1;
    assign validhit [1:0] = {valid[1][core_index], valid[0][core_index]}; 
    assign match_way0[1:0] = (tag[0][core_index] == core_tag) && valid[0][core_index];
    assign match_way1[1:0] = (tag[1][core_index] == core_tag) && valid[1][core_index];


    // instrumentacion
    wire [31:0] next_hit_counter, next_miss_counter;
    wire [31:0] next_memTransaction_counter, next_ioTransaction_counter;
    assign next_hit_counter = hit_counter + 1;
    assign next_miss_counter = miss_counter + 1;
    assign next_memTransaction_counter = memTransaction_counter + 1;
    assign next_ioTransaction_counter = ioTransaction_counter + 1;
    
    // Linear feedback shift register
    reg [7:0] LFSR;
    wire feedback_taps;
    reg feedback_reg;
    assign feedback_taps = LFSR[1] ^ LFSR[3] ^ LFSR[6]; // xor de los bits 3 y 5 para realimentar

    always @(posedge clk) begin
        if (~resetn) begin
            reset_done <= 0;
            reset_cnt <= 0;
            core_mem_ready <= 0;
            core_mem_rdata <= 0;
            mem_valid <= 0;
            mem_instr <= 0;
            mem_addr <= 0;
            mem_wdata <= 0;
            mem_wstrb <= 0;
            next_state <= `RESET;
            hit_counter <= 0;
            miss_counter <= 0;
            memTransaction_counter <= 0;
            ioTransaction_counter <= 0;
            complete_all[0] <= 1;

            read_block <= 0;
            read_next_state <= `IDLE;
            words <= 0;
            write_block <= 0;
            write_next_state <= `IDLE;
            //LFSR init
            LFSR <= 8'b00100101;
        end 
        else begin

            core_mem_ready <= 0;
            mem_valid <= 0;
            complete_all[1] <= complete_all[0];

            case(state)
                // limpia los valid bits de toda la cache
                `RESET: begin
                    if (~reset_done) next_state <= `RESET;
                    else             next_state <= `IDLE;
                    valid[0][reset_cnt] <= 0;
                    dirty[0][reset_cnt] <= 0;
                    tag[0][reset_cnt] <= 0;
                    data[0][reset_cnt] <= 0;
                    valid[1][reset_cnt] <= 0;
                    dirty[1][reset_cnt] <= 0;
                    tag[1][reset_cnt] <= 0;
                    data[1][reset_cnt] <= 0;
                    if (~|next_reset_cnt) reset_done = 1;
                    else reset_cnt <= next_reset_cnt;

                end
                `IDLE:  begin
                    if (core_mem_valid & wcomplete_all & ~highmem) begin
                    	feedback_reg <= LFSR[0]; //asignar el LSB del LFSR al registro de feedback
                        memTransaction_counter <= next_memTransaction_counter;
                        next_state <= `LOOKUP;
                    end
                    else if (core_mem_valid & wcomplete_all & highmem) begin
                        ioTransaction_counter <= next_ioTransaction_counter;
                        next_state <= `UNCACHEABLE;
                    end
                    else next_state <= `IDLE;
                    mem_valid <= 0;
                    complete_all[0] <= 1;  

                end
                `LOOKUP: begin
                    complete_all[0] <= 0;
                    if (validhit[0] && match_way0) begin: HIT0
                        // instrumentacion
                        if (complete_all[0]) hit_counter <= next_hit_counter;
                        core_mem_ready <= 1;
                        if  (~|core_mem_wstrb) begin: READ_HIT0                          
                            // leer cache y poner valores en interfaz core-cache way 0
                            if (core_offset[OFFSET-1] == 0) core_mem_rdata <= data[0][core_index][31:0];
                            if (core_offset[OFFSET-1] == 1) core_mem_rdata <= data[0][core_index][63:32];
                        end
                        if (|core_mem_wstrb) begin: WRITE_HIT0
                            // escribir cache y poner valores en interfaz core-cache way 0
                            // escribir dirty bit del bloque way 0
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[0] == 1) data[0][core_index][7:0]   <= core_mem_wdata[7:0];
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[1] == 1) data[0][core_index][15:8]  <= core_mem_wdata[15:8];
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[2] == 1) data[0][core_index][23:16] <= core_mem_wdata[23:16];
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[3] == 1) data[0][core_index][31:24] <= core_mem_wdata[31:24];

                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[0] == 1) data[0][core_index][39:32] <= core_mem_wdata[7:0];
                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[1] == 1) data[0][core_index][47:40] <= core_mem_wdata[15:8];
                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[2] == 1) data[0][core_index][55:48] <= core_mem_wdata[23:16];
                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[3] == 1) data[0][core_index][63:56] <= core_mem_wdata[31:24];

                            dirty[0][core_index] <= 1;
                        end
                        next_state <= `IDLE;
                    end
                    else if (validhit[1] && match_way1) begin: HIT1
                        // instrumentacion
                        if (complete_all[0]) hit_counter <= next_hit_counter;
                        core_mem_ready <= 1;
                        if  (~|core_mem_wstrb) begin: READ_HIT1                           
                            // leer cache y poner valores en interfaz core-cache way 1
                            if (core_offset[OFFSET-1] == 0) core_mem_rdata <= data[1][core_index][31:0];
                            if (core_offset[OFFSET-1] == 1) core_mem_rdata <= data[1][core_index][63:32];
                        end
                        if (|core_mem_wstrb) begin: WRITE_HIT1
                            // escribir cache y poner valores en interfaz core-cache
                            // escribir dirty bit del bloque
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[0] == 1) data[1][core_index][7:0]   <= core_mem_wdata[7:0];
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[1] == 1) data[1][core_index][15:8]  <= core_mem_wdata[15:8];
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[2] == 1) data[1][core_index][23:16] <= core_mem_wdata[23:16];
                            if (core_offset[OFFSET-1] == 0 && core_mem_wstrb[3] == 1) data[1][core_index][31:24] <= core_mem_wdata[31:24];

                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[0] == 1) data[1][core_index][39:32] <= core_mem_wdata[7:0];
                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[1] == 1) data[1][core_index][47:40] <= core_mem_wdata[15:8];
                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[2] == 1) data[1][core_index][55:48] <= core_mem_wdata[23:16];
                            if (core_offset[OFFSET-1] == 1 && core_mem_wstrb[3] == 1) data[1][core_index][63:56] <= core_mem_wdata[31:24];

                            dirty[1][core_index] <= 1;
                        end
                        next_state <= `IDLE;
                    end
                    else begin: MISS
                        // revisar estado dirty del bloque por reemplazar.
                        // en una cache directamente mapeada, corresponde univocamente al indice
                        // en una cache de 2 ways se victimiza uno de los 2 ways con politica de remplazo aleatoria
                        core_mem_ready <= 0;
                        // instrumentacion
                        miss_counter <= next_miss_counter;
                        // se revisa aleatoriamente la via que se va a remplazar
                        if  (valid[feedback_reg][core_index] & dirty[feedback_reg][core_index]) next_state <= `WRITE_BACK;
                        else next_state <= `ALLOCATE;
                    end
                end
                // reemplazar bloque por leido de memoria
                `ALLOCATE: begin
                    // asertar maquina de estados para lectura de bloque
                    if (~read_block && ~complete) read_block <= 1;
                    else if (complete) next_state <= `LOOKUP;
                    else next_state <= `ALLOCATE;
                end
                `WRITE_BACK: begin
                    // asertar maquina de estados para escritura de bloque
                    if(~write_block && ~complete) write_block <= 1;
                    else if (complete) next_state <= `ALLOCATE;
                    else next_state <= `WRITE_BACK;                 
                end
                `UNCACHEABLE: begin
                    complete_all[0] <= 0;                    
                    mem_valid <= 1;
                    mem_addr <= core_mem_addr;
                    mem_wstrb <= core_mem_wstrb;
                    if (|core_mem_wstrb) mem_wdata <= core_mem_wdata;
                    if (mem_ready) begin
                        if (~|core_mem_wstrb) core_mem_rdata <= mem_rdata;                        
                        core_mem_ready <= 1;
                        mem_valid <= 0;
                        mem_wstrb <= 0;
                        mem_wdata <= 0;
                        next_state <= `IDLE;
                    end
                end


            endcase

            // maquina de estados para lectura de bloque
             case(read_state)
                `IDLE: begin
                    if (read_block && ~write_block) begin
                        words <= 0;                        
                        current_address <= {core_tag, core_index, {OFFSET{1'b0}}};
                        read_next_state <= `READ_WORD;
                    end
                    else read_next_state <= `IDLE;

                end
                `READ_WORD: begin
                    if (~complete && ~mem_ready) begin
                        mem_valid <= 1;
                        mem_addr <= current_address;
                        mem_wstrb <= 0;
                        mem_instr <= 0;
                    end 
                    else if (~complete && mem_ready) begin
                        mem_valid <= 0;
                        if (words == 0) data[feedback_reg][core_index][31:0]  <= mem_rdata;
                        if (words == 1) data[feedback_reg][core_index][63:32] <= mem_rdata;
                        words <= wnext_word;
                        current_address <= wnext_address;
                        read_next_state <= `READ_WORD;                       
                    end
                    else if (complete) begin
                        // todo el bloque ha sido leido y guardado, 
                        // setear valid a 1 y escribir tag correspondiente
                        // bug: setear dirty en 0
                        valid[feedback_reg][core_index] <= 1;
                        tag[feedback_reg][core_index] <= core_tag;
                        dirty[feedback_reg][core_index] <= 0;
                        read_block <= 0;
                        words <= 0;
                        read_next_state <= `IDLE;
                    end
                    else read_next_state <= `READ_WORD;
                end

            endcase

            // maquina de estados para escritura de bloque
            case(write_state)
                `IDLE: begin
                    if (write_block && ~read_block) begin
                        words <= 0;
                        // bug: al hacer writeback, se usa el tag de la victima,
                        // no el del core
                        current_address <= {tag[feedback_reg][core_index], core_index, {OFFSET{1'b0}}};
                        write_next_state <= `WRITE_WORD;
                    end
                    else write_next_state <= `IDLE;

                end
                `WRITE_WORD: begin
                    if (~complete && ~mem_ready) begin
                        mem_valid <= 1;
                        mem_addr <= current_address;
                        mem_wstrb <= 4'b1111;
                        if (words == 0) mem_wdata <= data[feedback_reg][core_index][31:0];
                        if (words == 1) mem_wdata <= data[feedback_reg][core_index][63:32];
                    end 
                    else if (~complete && mem_ready) begin
                        mem_valid <= 0;
                        words <= wnext_word;
                        current_address <= wnext_address;
                        write_next_state <= `WRITE_WORD;                       
                    end
                    else if (complete) begin
                        // todo el bloque ha sido escrito de vuelta a la memoria principal, 
                        // setear valid a 0
                        valid[feedback_reg][core_index] <= 0;
                        write_block <= 0;
                        words <= 0;
                        write_next_state <= `IDLE;
                    end
                    else write_next_state <= `READ_WORD;
                end

            endcase



        end
    end
        // Linear feedback shift register
   /* always@(posedge clk) begin
	LFSR <= LFSR << 1; 
    	LFSR[0] <= feedback_taps;
    end*/    
    always @(negedge clk) begin
        LFSR <= LFSR << 1; 
    	LFSR[0] <= feedback_taps;
        state <= next_state;
        read_state <= read_next_state;
        write_state <= write_next_state;
        
    end


endmodule

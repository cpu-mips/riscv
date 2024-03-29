#include "ascii.h"
#include "uart.h"
#include "string.h"
#include "memory.h"
#include "graphics.h"

int8_t* read_n(int8_t*b, uint32_t n) 
{
    for (uint32_t i = 0; i < n;  i++) {
        b[i] =  uread_int8();
    }
    b[n] = '\0';
    return b;
}

int8_t* read_token(int8_t* b, uint32_t n, int8_t* ds)
{
    for (uint32_t i = 0; i < n; i++) {
        int8_t ch = uread_int8();
        for (uint32_t j = 0; ds[j] != '\0'; j++) {
            if (ch == ds[j]) {
                b[i] = '\0';
                return b;
            }
        }
        b[i] = ch;
    }
    b[n - 1] = '\0';
    return b;
}

void store(uint32_t address, uint32_t length)
{
    for (uint32_t i = 0; i*4 < length; i++) {
        int8_t buffer[9];
        int8_t* ascii_instruction = read_n(buffer,8);
        volatile uint32_t* p = (volatile uint32_t*)(address+i*4);
        *p = ascii_hex_to_uint32(ascii_instruction);
    }
}


#define BUFFER_LEN 128

typedef void (*entry_t)(void);

int main(void)
{
    uwrite_int8s("\r\n");

    for ( ; ; ) {
        uwrite_int8s("Hell> ");

        int8_t buffer[BUFFER_LEN];
        int8_t* input = read_token(buffer, BUFFER_LEN, " \x0d");

        if (strcmp(input, "file") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t file_length = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            store(address, file_length);
        } else if (strcmp(input, "jal") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));

            entry_t start = (entry_t)(address);
            start();
        } else if (strcmp(input, "lw") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint32_t* p = (volatile uint32_t*)(address);

            uwrite_int8s(uint32_to_ascii_hex(address, buffer, BUFFER_LEN));
            uwrite_int8s(":");
            uwrite_int8s(uint32_to_ascii_hex(*p, buffer, BUFFER_LEN));
            uwrite_int8s("\r\n");
        } else if (strcmp(input, "lhu") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint16_t* p = (volatile uint16_t*)(address);

            uwrite_int8s(uint32_to_ascii_hex(address, buffer, BUFFER_LEN));
            uwrite_int8s(":");
            uwrite_int8s(uint16_to_ascii_hex(*p, buffer, BUFFER_LEN));
            uwrite_int8s("\r\n");
        } else if (strcmp(input, "lbu") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint8_t* p = (volatile uint8_t*)(address);

            uwrite_int8s(uint32_to_ascii_hex(address, buffer, BUFFER_LEN));
            uwrite_int8s(":");
            uwrite_int8s(uint8_to_ascii_hex(*p, buffer, BUFFER_LEN));
            uwrite_int8s("\r\n");
        } else if (strcmp(input, "sw") == 0) {
            uint32_t word = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));

            volatile uint32_t* p = (volatile uint32_t*)(address);
            *p = word;
        } else if (strcmp(input, "sh") == 0) {
            uint16_t half = ascii_hex_to_uint16(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));

            volatile uint16_t* p = (volatile uint16_t*)(address);
            *p = half;
        } else if (strcmp(input, "sb") == 0) {
            uint8_t byte = ascii_hex_to_uint8(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));

            volatile uint8_t* p = (volatile uint8_t*)(address);
            *p = byte;
        } else if (strcmp(input, "fill") == 0) {
            uint32_t color = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            fill(color);
        } else if (strcmp(input, "hwline") == 0) {
	    int8_t buffer[64];
            uint32_t color = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t x0 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t y0 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t x1 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t y1 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
	    uwrite_int8s("\r\n");
	    uwrite_int8s(uint32_to_ascii_hex(color, buffer, 64));
	    uwrite_int8s("\r\n");
	    uwrite_int8s(uint32_to_ascii_hex(x0, buffer, 64));
	    uwrite_int8s("\r\n");
	    uwrite_int8s(uint32_to_ascii_hex(y0, buffer, 64));
	    uwrite_int8s("\r\n");
	    uwrite_int8s(uint32_to_ascii_hex(x1, buffer, 64));
	    uwrite_int8s("\r\n");
	    uwrite_int8s(uint32_to_ascii_hex(y1, buffer, 64));
	    uwrite_int8s("\r\n");
	    uwrite_int8s("\r\n");
            hwline(color, x0, y0, x1, y1);
        } else if (strcmp(input, "swline") == 0) {
            uint32_t color = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t x0 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t y0 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t x1 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            uint32_t y1 = ascii_dec_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            swline(color, x0, y0, x1, y1);
        } else {
            uwrite_int8s("\n\rGo fuck yourself: ");
            uwrite_int8s(input);
            uwrite_int8s("\n\r");
        }
    }

    return 0;
}

// arm-linux-gnueabi-gcc firmware.c -o firmware
// arm-linux-gnueabi-objcopy -O ihex firmware firmware.hex

#include <stdint.h>
#include <string.h>
#include <stdio.h>

#define PINSEL0         (*((volatile unsigned long *) 0xE002C000))

#define S0SPCR          (*((volatile unsigned short*) 0xE0020000))
#define S0SPSR          (*((volatile unsigned char *) 0xE0020004))
#define S0SPDR          (*((volatile unsigned short*) 0xE0020008))
#define S0SPCCR         (*((volatile unsigned char *) 0xE002000C))
#define S0SPINT         (*((volatile unsigned char *) 0xE002001C))
#define IO0CLR          (*((volatile unsigned long *) 0xE002800C))
#define IO0SET          (*((volatile unsigned long *) 0xE0028004))
#define IO0DIR          (*((volatile unsigned long *) 0xE0028008))
#define IO0PIN          (*((volatile unsigned long *) 0xE0028000))

void LCD_Char (char msg)
{
		IO0PIN = ( (IO0PIN & 0xFFFF00FF) | (msg<<8) );
		IO0SET = 0x00050000; /* RS = 1, , EN = 1 */
		IO0CLR = 0x00020000; /* RW = 0 */
		IO0CLR = 0x00040000; /* EN = 0, RS and RW unchanged(i.e. RS = 1, RW = 0) */
}

void LCD_String (char* msg)
{
	uint8_t i=0;
	while(msg[i]!=0)
	{
		LCD_Char(msg[i]);
		i++;
	}
}

void SPI_Init()
{
	PINSEL0 = PINSEL0 | 0x00001500; /* Select P0.4, P0.5, P0.6, P0.7 as SCK0, MISO0, MOSI0 and GPIO */
	S0SPCR = 0x0020; /* SPI Master mode, 8-bit data, SPI0 mode */
	S0SPCCR = 0x10; /* Even number, minimum value 8, pre scalar for SPI Clock */
}

void SPI_Write(char data)
{
	char flush;
	IO0CLR = (1<<7);  /* SSEL = 0, enable SPI communication with slave */
	S0SPDR = data;  /* Load data to be written into the data register */
	while ( (S0SPSR & 0x80) == 0 );  /* Wait till data transmission is completed */
	flush = S0SPDR;
	IO0SET = (1<<7);  /* SSEL = 1, disable SPI communication with slave */
}

int main(void)
{
	//ACVCTF{b4r3_m3t4l_r3v3rs1ng}
	const unsigned char s[] = {0x5b, 0x59, 0x4c, 0x59, 0x4e, 0x5c, 0x61, 0x78, 0x2e, 0x68, 0x29};
	const unsigned char d[] = {0xcc, 0xa8, 0x14, 0x9a, 0x1a, 0xaa, 0xcc};
	const unsigned char e[] = {0x96, 0x14, 0x9e, 0x14, 0x96, 0x94, 0x10, 0xae, 0xbc, 0x88};
	LCD_String("SPI Initialization");
	SPI_Init();
	LCD_String("Start bit set");
	SPI_Write(0x01);
	LCD_String("Transmitting data to slave");
	for(int i = 0; i < 12; i++) {
		SPI_Write(s[i]^0x1a);
	}
	for(int i = 0; i < 8; i++) {
		SPI_Write((d[i]>>1)^0x39);
	}
	for(int i = 0; i < 11; i++) {
		SPI_Write((e[i]>>1)^0x39);
	}
	LCD_String("Data transfer is completed");
	SPI_Write('\0');
	return 0;
}

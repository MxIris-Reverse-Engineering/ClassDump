//
//  blowfish.m
//  
//
//  Created by JH on 2024/5/31.
//

#import <Foundation/Foundation.h>
#import "blowfish.h"

void Blowfish_Encrypt(BLOWFISH_CTX *ctx, uint32_t *xl, uint32_t *xr){
  uint32_t  Xl;
  uint32_t  Xr;
  uint32_t  temp;
  int16_t   i;

  Xl = *xl;
  Xr = *xr;

  for (i = 0; i < N; ++i) {
    Xl = Xl ^ ctx->P[i];
    Xr = F(ctx, Xl) ^ Xr;

    temp = Xl;
    Xl = Xr;
    Xr = temp;
  }

  temp = Xl;
  Xl = Xr;
  Xr = temp;

  Xr = Xr ^ ctx->P[N];
  Xl = Xl ^ ctx->P[N + 1];

  *xl = Xl;
  *xr = Xr;
}


void Blowfish_Decrypt(BLOWFISH_CTX *ctx, uint32_t *xl, uint32_t *xr){
  uint32_t  Xl;
  uint32_t  Xr;
  uint32_t  temp;
  int16_t   i;

  Xl = *xl;
  Xr = *xr;

  for (i = N + 1; i > 1; --i) {
    Xl = Xl ^ ctx->P[i];
    Xr = F(ctx, Xl) ^ Xr;

    /* Exchange Xl and Xr */
    temp = Xl;
    Xl = Xr;
    Xr = temp;
  }

  /* Exchange Xl and Xr */
  temp = Xl;
  Xl = Xr;
  Xr = temp;

  Xr = Xr ^ ctx->P[1];
  Xl = Xl ^ ctx->P[0];

  *xl = Xl;
  *xr = Xr;
}


void Blowfish_Init(BLOWFISH_CTX *ctx, uint8_t *key, int32_t keyLen) {
  int32_t i, j, k;
  uint32_t data, datal, datar;

  for (i = 0; i < 4; i++) {
    for (j = 0; j < 256; j++)
      ctx->S[i][j] = ORIG_S[i][j];
  }

  j = 0;
  for (i = 0; i < N + 2; ++i) {
    data = 0x00000000;
    for (k = 0; k < 4; ++k) {
      data = (data << 8) | key[j];
      j = j + 1;
      if (j >= keyLen)
        j = 0;
    }
    ctx->P[i] = ORIG_P[i] ^ data;
  }

  datal = 0x00000000;
  datar = 0x00000000;

  for (i = 0; i < N + 2; i += 2) {
    Blowfish_Encrypt(ctx, &datal, &datar);
    ctx->P[i] = datal;
    ctx->P[i + 1] = datar;
  }

  for (i = 0; i < 4; ++i) {
    for (j = 0; j < 256; j += 2) {
      Blowfish_Encrypt(ctx, &datal, &datar);
      ctx->S[i][j] = datal;
      ctx->S[i][j + 1] = datar;
    }
  }
}

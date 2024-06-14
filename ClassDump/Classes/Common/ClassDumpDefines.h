//
//  Header.h
//  
//
//  Created by JH on 2024/6/13.
//


#ifdef __cplusplus
#define CD_EXTERN        extern "C" __attribute__((visibility ("default")))
#define CD_PRIVATE_EXTERN    __attribute__((visibility("hidden"))) extern "C"
#define CD_PRIVATE          __attribute__((visibility("hidden")))
#else
#define CD_EXTERN        extern __attribute__((visibility ("default")))
#define CD_PRIVATE_EXTERN    __attribute__((visibility("hidden"))) extern
#define CD_PRIVATE          __attribute__((visibility("hidden")))
#endif

